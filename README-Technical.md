# Water Dispenser — Technical Reference

This document combines architecture notes and contribution guidance for developers working on Water Dispenser. For end-user documentation, see [README.md](https://github.com/Gogo1951/Water-Dispenser/blob/main/README.md).

---

## File Map

```text
Water-Dispenser/
├── Water-Dispenser.toc                  Load order, metadata, SavedVariables declarations
├── README.md                            Player-facing documentation
├── README-Technical.md                  This file
├── Data/
│   ├── Data.lua                         Locale handle, ns.LOCALE_NAME, palette, classes, URLs, registry IDs, icon coords
│   ├── Collections.lua                  Built-in collections: item/spell/rank/level tables + ns.COLLECTION_META
│   └── Default-Settings.lua             ns.DATABASE_DEFAULTS — AceDB profile/global defaults
├── Features/
│   ├── Core.lua                         ns.State, version, event dispatcher, PLAYER_LOGIN lifecycle, SetupDatabase
│   ├── Utilities.lua                    API shims, color/class helpers, collection reverse-lookups, legacy migrations
│   ├── Announcements.lua                ns.PrintMessage + the auto-managed "- Dispenser" macro
│   ├── Inventory-Scanner.lua            Bag scan, inventory cache, rank/level resolution, announcement snapshot
│   ├── Dispenser.lua                    Trade fill (FillTrade), restack-on-conjure, trade-window events
│   ├── Trade-UI.lua                     Side panel: Clear and Fill buttons anchored beside the trade window
│   ├── Diagnostics.lua                  Read-only probes, event log, saved-variable dump, taint-log control
│   └── Minimap-Button.lua               LibDataBroker launcher + LibDBIcon minimap button
├── Options/
│   ├── Options-Utilities.lua            Shared AceConfig helpers (Header, Desc, Spacer, SubHeader)
│   ├── Options-General.lua              Root panel: welcome, mini-map, Dispense toggles, support links, version
│   ├── Options-Distribution-Rules.lua   Per-item rules: per-class stack sliders, settings, class filter, add-item
│   ├── Options-Announcements.lua        Announcement-macro toggle + live preview
│   ├── Options-Profiles.lua             Stock AceDBOptions-3.0 profiles panel
│   ├── Options-Diagnostics.lua          Diagnostic Tools panel
│   └── Options.lua                      Registration, ns:OpenOptionsPanel routing, the /wd slash command
├── Includes/                            Bundled libraries (LibStub, Ace3, LibDataBroker, LibDBIcon, CallbackHandler)
└── Locales/
    ├── enUS.lua                         English strings + default fallback (NewLocale(..., true))
    └── <locale>.lua                     Ten translated locales; missing keys fall through to enUS
```

The `.toc` load order is `Includes → Locales → Data → Features → Options`. Three ordering constraints matter:

- `Locales` loads before `Data`, because `Data/Data.lua` calls `GetLocale` and needs every `NewLocale` already registered.
- Within `Features`, `Core.lua` loads first (it defines `ns.State`, `ns.RegisterEvent`, and `SetupDatabase`) and `Utilities.lua` next (it builds the collection reverse-lookups from `Data/Collections.lua` and owns the legacy migrations and `ns.RefreshCollectionMeta`).
- Within `Options`, `Options-Utilities.lua` loads first (it defines the shared widget helpers every panel uses) and `Options.lua` loads last, so `ns.RegisterOptionsPanels` can register each panel's `ns.Build*Options` builder.

No dead or deprecated files — keep it that way.

---

## Architecture

### Event Loop

`Core.lua` creates one hidden frame and a `ns.RegisterEvent(event, handler, ...)` dispatcher; modules register through it rather than each owning a frame. Multiple handlers can register for the same event (stored as a list, called in registration order — `PLAYER_REGEN_ENABLED` has handlers in both `Dispenser.lua` and `Announcements.lua`). Registration is wrapped in `pcall`, so an event name invalid on a given client is skipped instead of erroring. Every event name passed through `RegisterEvent` is recorded in `ns.EVENT_NAMES`, so the diagnostic probe can't drift from what is actually registered.

Trailing arguments are unit tokens. When present, the dispatcher calls `RegisterUnitEvent` instead of `RegisterEvent`, so the frame never wakes for other units. **The filter is fixed by the first registration of that event** — `RegisterUnitEvent` binds per frame-and-event, and every module shares this one frame.

Events handled:

- `PLAYER_LOGIN` (Core) — runs `SetupDatabase` (AceDB creation + legacy seed), registers the options panels, runs each feature module's `Init*()`, then prints the welcome message if opted in.
- `TRADE_SHOW` / `TRADE_CLOSED` (Dispenser) — captures or clears the partner's class, level, and group state; attaches/detaches the side panel; kicks off the fill if the matching Dispense toggle is on.
- `BAG_UPDATE` (Dispenser) — retries the fill when a previous attempt flagged `ns.State.MissingStack`.
- `SPELLS_CHANGED` (Dispenser) — pre-warms the item cache (see **Item Data Caching**). Fires on login and on any spellbook change, including learning a rank, so it covers the prewarm alone; `LEARNED_SPELL_IN_TAB` is deliberately not registered as a companion.
- `UNIT_SPELLCAST_SUCCEEDED`, **filtered to `"player"`** (Dispenser) — the player conjuring a collection spell during a trade queues a restack-then-fill (see **Restack on Conjure**). Without the filter this event fires for every nearby unit, which in a raid both wastes dispatcher work in combat and floods the diagnostic event log.
- `PLAYER_REGEN_ENABLED` (Dispenser + Announcements) — combat end. Replays a deferred fill, a deferred restack, and a deferred macro update.
- `BAG_UPDATE_DELAYED` / `GROUP_ROSTER_UPDATE` / `PLAYER_ENTERING_WORLD` (Announcements) — debounced triggers for the announcement-macro sync.

There is no `PLAYER_REGEN_DISABLED` handler — nothing needs to react to combat starting; the protected paths below simply defer until `PLAYER_REGEN_ENABLED`.

### Combat Lockdown

Three paths defer during combat:

1. **Trade fill.** `ns.FillTrade()` checks `InCombatLockdown()` (via `ns.IsInCombat`) and sets `pendingCombatFill` if locked. `OnCombatEnd` in `Dispenser.lua` replays it.
2. **Restack + fill.** The conjure-triggered restack moves bag items, so it defers via `pendingCombatRestack` and replays on combat end.
3. **Macro update.** `Announcements.lua` debounces updates and, if combat is active when the timer fires, sets `pendingCombatUpdate`; the combat-end handler re-schedules. `EditMacro` / `CreateMacro` aren't strictly protected, but combat is a bad time to race the macro UI.

The side panel needs no combat handling: it holds only plain (insecure) buttons and stays parented to `UIParent`, so it shows and hides freely.

### Scan → Resolve → Fill

`ns.FillTrade(forced)` runs three phases per call:

1. **Scan** (`ScanInventory`, Inventory-Scanner.lua) walks every bag slot, tags collection items via `ns.ITEM_TO_COLLECTION`, and stores per-slot `{Bag, Slot, Count, Full, Bound}` records in an `inventory` table keyed by item ID. Each entry's `Level` comes from `ns.ITEM_LEVEL` when available (authoritative) and falls back to `GetItemInfo`'s `itemMinLevel`. `ScanInventory` returns `true` only when the inventory changed in a way that may affect a fill, so bag-update retries can skip the work.

2. **Resolve** (`UsableRankEntries` / `BestRankItemId`, Inventory-Scanner.lua, per configured item):
    - For built-in collections the partner-level cap is **intrinsic** — water or food above the partner's level is useless to them — so it applies regardless of `FactorLevel`. `UsableRankEntries(collectionKey, levelLimit)` returns every held rank the partner can use, highest first, so the fill cascades down when the best rank runs short. If nothing held is usable, it falls back to the lowest-rank stack on hand.
    - `KeepAtLeast` applies only to `BestRankItemId(collectionKey, nil)` — the player's top-tier stash. Lower ranks surfaced by the cap are pure giveaway material and are never reserved.
    - User-added items have one concrete ID and no alternate rank, so `FactorLevel` gates them directly: skipped when the partner is below the item's required level.

3. **Fill** iterates the resolved entries best-rank-first, placing one bag slot per "stack" of `needed`. On a non-forced pass it first subtracts the stacks already sitting in the trade window (read via `GetTradePlayerItemLink` / `GetTradePlayerItemInfo` and mapped back to their config key), so a mid-trade restock tops up to the configured count instead of over-filling. Within each rank, full stacks go first, then partials only when `UseNotFullStack` is on — it ships `false` for the built-in conjured collections, so they dispense full stacks only and the restack consolidates the leftovers. A `KeepAtLeast` check guards every placement. Soulbound slots are skipped for user-added items but not for built-in collections, because conjured items report bound yet trade fine.

If `needed > 0` after the loop, `ns.State.MissingStack` is set so the next `BAG_UPDATE` retries; the chat warning itself is gated on `ns.db.profile.MissingStackWarnings`.

### Item Data Caching

`GetItemInfo` returns nil on a fresh client for items not yet seen. Two mitigations:

1. `OnSpellsChanged` (Dispenser.lua) touches `GetItemInfo` for every collection item ID and every configured user-added ID purely to seed the cache, so the first trade-time scan resolves synchronously.
2. `ns.ITEM_LEVEL` (built in `Utilities.lua` from `Data/Collections.lua`) overrides `itemMinLevel` for built-in collection items. Some conjured items return 0 even when they have a use level, so the static table keeps the partner-level cap correct regardless of cache state.

`ScanInventory` also calls `C_Item.RequestLoadItemDataByID` for any uncached item and refuses to trust the other return values that pass; a later scan backfills only the fields still missing, so a cold call can never blank out good data.

### Identity Constants

The installed folder and packaged name are `Water-Dispenser`, but the in-Lua identity is `ns.LOCALE_NAME = "WaterDispenser"` (no hyphen). That constant — not the `ADDON_NAME` vararg — is what every `NewLocale` / `GetLocale` call, the LibDataBroker object name, and the LibDBIcon registration key use, so the three stay in lockstep. APIs keyed off the *packaged* add-on (`GetAddOnMetadata` for the version) still take `ADDON_NAME`.

### Colors

`ns.PALETTE` (Data.lua) holds raw six-character hex with no `|cff` prefix; `Features/Utilities.lua` derives the escape-code table and exposes `ns.GetColor(key)`, which returns the prefix — callers append `|r` themselves. `BODY` is white for descriptions and options body text; `HELP` is silver for pro tips and helper text. The two are distinct roles, not shades of one: diagnostics hints and the External Tools lines use `HELP`, everything else descriptive uses `BODY`.

---

## Trade Side Panel

`Trade-UI.lua` builds a small frame holding two plain `UIPanelButtonTemplate` buttons — Clear and Fill. The panel stays parented to `UIParent` and only **anchors** to the right of Blizzard's `TradeFrame`, matching its frame strata so it sits clickable beside it; it is never re-parented into `TradeFrame`. Because the buttons are insecure, the panel shows and hides with no combat handling.

- **Clear** calls `ns.ClearTrade`, walking `MAX_TRADABLE_ITEMS` slots.
- **Fill** calls `ns.FillTrade(true)` — `forced = true` clears the window first and bypasses the "did inventory change?" early-out.

`OnTradeShow` calls `ns.TradeUI:Attach(TradeFrame)`; `OnTradeClosed` calls `ns.TradeUI:Detach()`.

Level-aware in-trade conjure buttons are deliberately absent: add-on-created secure cast buttons did not fire reliably on TBC Anniversary. Don't reintroduce them.

---

## Restack on Conjure

Conjured water and food arrive in small partial stacks, but a trade can only move whole bag slots and the built-in collections dispense full stacks only. `Dispenser.lua` bridges that by consolidating partials into full stacks, then filling.

A filtered `UNIT_SPELLCAST_SUCCEEDED` for any spell in `ns.SPELL_TO_COLLECTION`, during an active trade, arms a debounced `ScheduleRestack` (200 ms, so a burst of conjures collapses into one pass). `restackPending` latches immediately so `OnBagUpdate` holds off dispensing the partials before they merge. When the debounce fires, `RestackCollections` does one bag walk, groups the partial stacks of each collection item, and merges them with whole-stack pickups — each step drops a whole stack onto a running target and returns any overflow to the now-empty source slot, planned from a single snapshot so no mid-operation bag re-reads are needed. Then `ns.FillTrade(false)` runs.

Because it moves bag items, the whole pass defers in combat (`pendingCombatRestack`) and replays on combat end. Restacking touches only built-in collection items, never user-added ones — which is also why it can't disturb a partial stack already sitting in the trade window.

---

## Announcement Macro

Water Dispenser never calls `SendChatMessage`. Instead, `Announcements.lua` keeps a single per-character macro named `- Dispenser` in sync; the player clicks it to broadcast their giveaway list. This is an intentional deviation from the shared style guide's send-path helpers — do not add `ns:Announce`-style senders back.

The lifecycle runs through `SyncMacroState`, invoked via a debounced `ScheduleUpdate` (250 ms) on `BAG_UPDATE_DELAYED`, `GROUP_ROSTER_UPDATE`, `PLAYER_ENTERING_WORLD`, the combat-end retry, and `ns.RefreshAnnouncementMacro` (called by the options panels after a settings change). `SyncMacroState` reads `ns.db.profile.Announcements.Enabled` and converges:

- Enabled + missing → `CreateMacro` (per-character slot), print `CHAT_MACRO_CREATED`.
- Enabled + exists → silent `EditMacro` with a fresh body.
- Disabled + exists → `DeleteMacro`, print `CHAT_MACRO_DELETED`.

`macroFullWarned` latches the "all character macro slots in use" warning to once per slot-exhaustion run. The body comes from `ns.BuildAnnouncementSnapshot` (Inventory-Scanner.lua) → `ns.BuildAnnouncementMessage`, in `ns.BUILTIN_ORDER` then user items by name, honoring each item's `KeepAtLeast` and `IncludeQuantity`.

### Message Template and Truncation

The sentence is a **single locale template with one `%s`**, not a set of concatenated fragments:

```lua
L["ANNOUNCEMENTS_BODY"] = "I have %s. Open trade!"
```

`BodyTemplateParts` splits it at the `%s` into a head and a tail. That shape exists so translators control word order: Korean renders with an empty head and the entire sentence in the tail, putting the item list first and the verb last, which a fixed intro/outro pair made impossible.

`BuildMacroBody` prepends the channel slash (`/raid`, `/p`, or `/s`), then lays down `channel + prefix + head` as a single lead. If the full message fits 255 it is used as-is. If not, the lead is laid down once and whole item parts (link + optional count) are appended with `, ` joiners while the running total stays within 255 minus the ` ...` reserve; the first part that would overflow stops the loop, ` ...` closes the message, and the template's tail is dropped. Truncation happens only at **part boundaries** — never inside an item link (which the client rejects), and never via a comma search, since item names can contain commas.

Length is measured in **bytes** (`#string`), which is what the chat limit actually counts and is the stricter reading of the 255-character macro-body cap. With item hyperlinks averaging 50–60 bytes, truncation kicks in around three or four items. Walk that worst case before changing the body composition.

The macro name is deliberately short: WoW silently truncates macro names past 16 characters, so `- Dispenser` (11) was chosen over `- Water Dispenser` (17), and the leading `- ` sorts it to the top of the macro list.

---

## Options Panel Routing

`ns:OpenOptionsPanel` (Options.lua) backs both the `/wd` slash command and the mini-map button's Shift + Middle-Click. It routes **entirely by handles captured at registration** — `AddToBlizOptions` returns `(frame, categoryID)`, and both are stored on `ns.optionsFrames` when the root General panel registers.

The order is: `Settings.OpenToCategory(<captured categoryID>)`, then `InterfaceOptionsFrame_OpenToCategory(<captured frame>)` called twice, then `AceConfigDialog:Open` as a genuine last resort.

**Never resolve the category by display name.** AceConfigDialog aliases `category.ID` to the panel title *only* when `C_SettingsUtil.OpenSettingsPanel` is absent. Classic Era lacks that API, so a name lookup happens to work there — and silently returns nil on any client that has it, which is why this failure mode passes casual testing on one flavor and breaks on the other.

---

## Diagnostic Tools

`Diagnostics.lua` backs the **Diagnostic Tools** panel with read-only reports for bug triage: an event-registration probe over `ns.EVENT_NAMES`, an API existence/shape probe (`ns.DIAGNOSTIC_API_CHECKS`), an event log, the live trade/inventory context behind a "nothing fills" complaint, an installed-add-on list, a library-version list, and a saved-variable dump.

The panel is gated by `ns.diagnostics`, an in-memory table that is **never persisted** — it starts `{ enabled = false, logging = false }` at every login. The dispatcher's logging tap is one boolean check before any allocation, so diagnostics off costs nothing measurable. `ns.DIAGNOSTIC_EVENT_EXCLUDE` holds only `BAG_UPDATE`, which fires per slot change; `BAG_UPDATE_DELAYED` is kept because it fires once per settle. The only state this panel ever writes is the `taintLog` CVar, via its explicit button.

Strings here are developer-facing and deliberately live in `ns.DiagnosticsStrings` as plain English, never in `Locales/`.

---

## Saved Variables

One account-wide table, `WaterDispenserDB`, managed by **AceDB-3.0** and declared in the `.toc`. AceDB owns the standard `profiles` / `global` / `profileKeys` structure:

- **`ns.db.profile`** — every user setting: `showWelcome`, `MissingStackWarnings`, the `Dispense` / `DispenseSolo` / `DispenseGroup` / `DispenseRaid` toggles, `Announcements.Enabled`, and `Items`. Each `Items` entry is keyed by collection name for built-ins or by numeric item ID for user-added items.
- **`ns.db.global`** — `minimap` (the table LibDBIcon reads) plus the one-shot `legacySeedDone` flag. Account-wide and profile-independent, so switching or resetting profiles never moves the button.

Every character starts on one shared **Default** profile — `AceDB:New("WaterDispenserDB", ns.DATABASE_DEFAULTS, true)`, where the third argument is mandatory. Per-character setups are opt-in via the stock **Profiles** panel, the unmodified AceDBOptions-3.0 table. Reset is the stock **Reset Profile**; there is no custom reset control anywhere.

Defaults come from `ns.DATABASE_DEFAULTS` in `Data/Default-Settings.lua`. AceDB's `copyDefaults` **writes them into** each section the first time that section is materialized, guarded by `if rawget(dest, k) == nil` — so an explicit user value, including `false`, is never overridden, and there is no hand-rolled merge anywhere in this codebase. The copy (rather than a pure metatable read) is load-bearing here: `FillTrade` iterates `pairs(ns.db.profile.Items)`, which only sees the built-in collections because their defaults are materialized into the table. Don't "optimize" that into a lazy lookup.

`Features/Core.lua` (`SetupDatabase`, on `PLAYER_LOGIN`) creates the database, seeds the profile from any legacy data, calls `ns.RefreshCollectionMeta()` to point each built-in collection's `Name` / `Icon` / `NoRemove` at code rather than stored data, and registers `OnProfileChanged` / `OnProfileCopied` / `OnProfileReset` callbacks that re-run that refresh, rebuild the Distribution Rules panel, and resync the announcement macro on any profile switch.

**`PlayerClasses` is stored explicitly.** A class the player unchecks is written as an explicit `false`, never `nil` — a missing key gets re-supplied from the built-in default (`MageWater`'s `MAGE = true`, for instance), so an unchecked class must be a concrete `false` or it reappears next login.

### Migration Chain

Temporary — the entire path below is deleted after **2026-10-12**: the tagged blocks in `Core.lua`, `ns.RunLegacyMigrations` and its seven steps in `Utilities.lua`, the legacy dump in `Diagnostics.lua`, and the `.toc` line.

The pre-AceDB build kept two raw tables: account-wide `WaterDispenserDB` (with root-level `minimap` and `WelcomeMessage`) and per-character `WaterDispenserCharDB`. `SetupDatabase` folds these into AceDB on first login. The `ns.db.global.legacySeedDone` flag makes the seed one-time: the **first** character to log in runs the chain against its own `WaterDispenserCharDB` and copies the result into the shared Default profile; **later** characters skip the seed and inherit it. Every character clears its legacy table afterwards, and the stray root keys are moved to their new homes and niled. The `.toc` keeps `SavedVariablesPerCharacter: WaterDispenserCharDB` listed (tagged) so the client still loads the legacy table for the seed.

1. `MigrateToStacks` (≤ v4 → v5) — older builds tracked per-class item *counts*; partial stacks can't be split from an add-on, so counts are divided by stack size into stack counts. v3 data already stored stacks, so it just bumps the version.
2. `MigrateAddPerItemRules` (v5 → v6) — adds `FactorLevel` and `KeepAtLeast`, defaulting to off / 0.
3. `MigrateAddIncludeQuantity` (v6 → v7) — adds `IncludeQuantity`, true for everything except healthstones.
4. `MigrateAddPlayerClasses` (v7 → v8) — adds `PlayerClasses` to user-added items; built-ins get their canonical restriction from `ns.DATABASE_DEFAULTS`.
5. `MigrateConjuredPartialStacks` (v8 → v9) — sets `UseNotFullStack` for `MageWater` and `MageFood` (later reversed by v11).
6. `MigrateRenameDispenseFields` (v9 → v10) — renames the `AutoFill*` toggles to `Dispense*`, carrying each character's choice forward.
7. `MigrateConjuredFullStacksOnly` (v10 → v11) — clears `UseNotFullStack` on `MageWater` / `MageFood`: the restack now consolidates conjured partials, so the built-in collections dispense full stacks only.

---

## Adding a New Built-in Collection

1. Add the spell-ID and item-ID maps to `ns.COLLECTIONS` in `Data/Collections.lua`. Each `Items` row is a **positional array** — `[itemId] = {rank, level}` for water and food, `[itemId] = {rank, level, heal}` for healthstones: `[1]` rank (in-collection tier, 1 = lowest, shared by horizontal variants), `[2]` level (player level required to *use* it — authoritative, bypasses unreliable `GetItemInfo` data), `[3]` heal (healthstone-only, informational). Each `Spells` row is `[spellId] = rank`. Keep the column-legend comment above each table, and the originating SQL query above that. The reverse-lookups are built in `Utilities.lua` **by index** (`meta[1]`, `meta[2]`), so any column-order change must be mirrored there.
2. Add an entry to `ns.COLLECTION_META` with a `NameKey` and `Icon`; set `Unique = true` for items that only ever trade 0 or 1. The key must match the `ns.COLLECTIONS` key.
3. Add the key to `ns.BUILTIN_ORDER` in the position you want in the Distribution Rules sidebar and the announcement message.
4. Add the default config to `ns.DATABASE_DEFAULTS.profile.Items[key]` in `Data/Default-Settings.lua` — `NoRemove = true`, the per-item flags, `PlayerClasses`, and the `Solo` / `Group` / `Raid` per-class stack counts.
5. Add the `L["ITEM_*"]` key and any new chat strings to `Locales/enUS.lua` only, then run the Localization pass to translate them. Watch length: announcement strings feed the 255-byte message budget.

The restack trigger picks up the new collection automatically once `Spells` is populated, since `ns.SPELL_TO_COLLECTION` is rebuilt from it.

## Adding a New Registered Event

Call `ns.RegisterEvent(name, handler)` from the owning module's `Init*()` — never create a frame in a feature file. The name lands in `ns.EVENT_NAMES` automatically, which is what the diagnostics event-registration probe and the event log both read, so the three can't drift.

If the event is a `UNIT_*` event the add-on only cares about for one unit, pass the unit tokens as trailing arguments so the dispatcher uses `RegisterUnitEvent`. Remember the filter is fixed by the first registration of that event name across the whole add-on. Only add an entry to `ns.DIAGNOSTIC_EVENT_EXCLUDE` if the event is a genuine firehose that would bury the log.

---

## Localization

Locale files live in `Locales/<locale>.lua`, each registered through AceLocale-3.0's `NewLocale(ns.LOCALE_NAME, "<locale>")`. WoW ships a fixed locale set and **every supported locale file already exists** — there is no "add a new locale" step. This section is maintenance only.

- **`enUS.lua` is the source of truth** and the only file passing the `true` default-fallback flag. Every string originates there; the other ten translate from it, and AceLocale falls back to English via `__index` for anything missing at runtime.
- **Keeping locales in sync** is the job of the Localization pass (`3 - Copy Cleanup & Localization Prompt.md`). Don't hand-edit the non-English files during ordinary work — add or change the key in `enUS.lua` and let that pass reconcile the rest.
- **Placeholders** must match `enUS` in count, type, and order per key in every locale. A `%s`/`%d` mismatch crashes at runtime and is the highest-value locale check.
- **Spanish** — `esES.lua` and `esMX.lua` are two separate, self-contained files. Identical Spanish in both is correct and expected; never share a strings table between them.
- **Overflow canary** — the 255-byte message budget is measured in bytes, so the widest-encoding locale is the one that overflows first. For this add-on that is **ruRU**: a one-item announcement measures roughly 147 bytes in Russian against 118 in English and 124 in German. Check truncation against ruRU, not German.
- Diagnostics strings are developer-facing and deliberately excluded from `Locales/`.

---

## Common Pitfalls

- **Resolving the options category by display name**: returns nil on any client that has `C_SettingsUtil.OpenSettingsPanel`, so the panel silently fails to open — and it still works on Classic Era, so one-flavor testing misses it. Route by the captured `categoryID` and frame handle only.
- **Registering a `UNIT_*` event unfiltered**: wakes the shared dispatcher for every nearby unit and floods the diagnostic event log in a raid. Pass unit tokens to `ns.RegisterEvent`.
- **Editing trade slots or macros in combat**: silently fails. The fill defers via `pendingCombatFill` and the macro via `pendingCombatUpdate`; do the same for any new protected path.
- **Reading `GetItemInfo` cold**: returns nil on a fresh client. The `OnSpellsChanged` prewarm covers collections; for user-added items prefer the cached `inventory[itemId]` over a fresh call.
- **Trusting `itemMinLevel` from `GetItemInfo`**: 0 for some conjured items. Use `ns.ITEM_LEVEL` for built-ins; the cached `inv.Level` already incorporates it.
- **Re-gating the collection rank cap on `FactorLevel`**: don't. For built-in collections the partner-level cap is intrinsic, and the toggle is hidden for them — it governs only single-rank user-added items.
- **Splitting partial stacks**: not possible from an add-on on these clients. The code tracks bag *slots* as "stacks" for exactly this reason.
- **Assuming a legacy global exists**: the `GetContainerNumSlots` / `PickupContainerItem` globals are gone on both target clients — use `C_Container` through the shims in `Utilities.lua`. Register events through `ns.RegisterEvent`, which `pcall`-guards.
- **Deriving the locale or LibDBIcon key from `ADDON_NAME`**: the folder is `Water-Dispenser` but the in-Lua identity is `WaterDispenser`. Use `ns.LOCALE_NAME`.
- **Macro names past 16 chars / bodies past 255 bytes**: both silently truncated by the client. Keep `MACRO_NAME` short and rely on `BuildMacroBody`'s part-boundary truncation.

---

## Contributing

Issues and pull requests are welcome on [GitHub](https://github.com/Gogo1951/Water-Dispenser/issues). For bug reports, include:

- Game version (Classic Era / TBC Anniversary) and locale
- Class and level
- Reproduction steps
- The relevant macro body or chat output — the Diagnostic Tools panel's reports are ideal

Discussion happens on [Discord](https://discord.gg/eh8hKq992Q).

When opening a PR:

- Keep changes scoped — one concern per PR.
- Run StyLua with its default configuration before committing; it owns all whitespace, including tab indentation and table formatting. The repo ships no `.stylua.toml` — don't add one.
- If you add a saved-variable field, add it to `ns.DATABASE_DEFAULTS`. For a reshaping change (renamed or moved keys), add a dated `MIGRATION` comment following the 90-day migration-window rule in the style guide.
- If you change the announcement body, walk the worst case with full item hyperlinks and the longest ruRU strings.
- Add or change strings in `Locales/enUS.lua` only; the Localization pass reconciles the other ten.
- Update this document if the architecture or file map changes.
- **Write commit and PR descriptions as a User Story.** Don't just say "I changed X." Frame it by who it helps and why:

  **Format:** *As a [role], I [needed / wanted] [behavior] so that [outcome]. This change [does X].*

  **Example:** *As a high-level mage trading a low-level player, I wanted Dispense to hand over water the partner can actually drink instead of my top rank, so the trade isn't useless. This change caps the fill to the partner's level, cascading down through usable ranks.*

  The User Story speeds up review and gives future maintainers context the diff alone won't carry.
