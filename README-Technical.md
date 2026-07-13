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
│   ├── Data.lua                         Locale handle, colors, classes, URLs, option-registry IDs, icon coords
│   ├── Collections.lua                  Built-in collections: item/spell/rank/level tables + ns.COLLECTION_META
│   └── Default-Settings.lua             ns.DATABASE_DEFAULTS — AceDB profile/global defaults
├── Features/
│   ├── Core.lua                         Shared ns.State, version, event dispatcher, PLAYER_LOGIN lifecycle
│   ├── Utilities.lua                    API shims, color/class helpers, collection reverse-lookups, SavedVariables + migrations
│   ├── Announcements.lua                ns.PrintMessage + the auto-managed "- Dispenser" macro
│   ├── Inventory-Scanner.lua            Bag scan, inventory cache, rank/level resolution (BestRankItemId, UsableRankEntries)
│   ├── Dispenser.lua                    Trade fill (FillTrade), restack-on-conjure, and the trade-window events
│   ├── Trade-UI.lua                     Side panel: Clear and Fill buttons anchored beside the trade window
│   ├── Diagnostics.lua                  Read-only diagnostic report (event/API probes, trade context, saved-var dump)
│   └── Minimap-Button.lua               LibDataBroker launcher + LibDBIcon minimap button
├── Options/
│   ├── Options-Utilities.lua            Shared AceConfig helpers (ns.OptionsDesc, ns.OptionsSpacer)
│   ├── Options-General.lua              General page (auto-fill toggles, support links)
│   ├── Options-Distribution-Rules.lua   Per-item rules: per-class stack sliders, settings, class filter, add-item
│   ├── Options-Announcements.lua        Announcement-macro toggle + live preview
│   ├── Options-Profiles.lua             Stock AceDBOptions-3.0 profiles panel
│   ├── Options-Diagnostics.lua          Diagnostic Tools panel
│   └── Options.lua                      Slash commands (/wd, /waterdispenser) + ns.RegisterOptionsPanels orchestration
├── Includes/                            Bundled libraries (LibStub, Ace3, LibDataBroker, LibDBIcon, CallbackHandler)
└── Locales/
    ├── enUS.lua                         English strings + default fallback (NewLocale(..., true))
    └── <locale>.lua                     Per-locale translations; untranslated keys fall through to enUS
```

The `.toc` load order is `Includes → Locales → Data → Features → Options`. Two ordering constraints matter:

- Within `Features`, `Core.lua` loads first (it defines `ns.State`, `ns.RegisterEvent`, and `SetupDatabase`), and `Utilities.lua` next (it builds the collection reverse-lookups from `Data/Collections.lua` and owns the legacy migrations and `ns.RefreshCollectionMeta`).
- Within `Options`, `Options-Utilities.lua` loads first (it defines the shared `ns.OptionsDesc` / `ns.OptionsSpacer` helpers the sub-pages use) and `Options.lua` loads last, so its `ns.RegisterOptionsPanels` can register each sub-page's `ns.Build*Options` builder.

No dead or deprecated files — keep it that way.

---

## Architecture

### Event Loop

`Core.lua` creates one hidden frame and a `ns.RegisterEvent(event, handler)` dispatcher; modules register through it rather than each owning a frame. Multiple handlers can register for the same event (they're stored as a list and called in registration order — `PLAYER_REGEN_ENABLED` has handlers in both `Dispenser.lua` and `Announcements.lua`). Registration is wrapped in `pcall` so an event that isn't valid on a given client is skipped instead of erroring. Every event name passed through `RegisterEvent` is recorded in `ns.EVENT_NAMES` so the diagnostic probe can't drift from what's actually registered.

Events handled:

- `PLAYER_LOGIN` (Core) — runs `SetupDatabase` (AceDB creation + legacy seed), registers the options panels, runs each feature module's `Init*()`, then prints the welcome message if opted in.
- `TRADE_SHOW` / `TRADE_CLOSED` (Dispenser) — captures or clears the partner's class, level, and group state; attaches/detaches the side panel; kicks off auto-fill if the matching Dispense toggle is on.
- `BAG_UPDATE` (Dispenser) — retries the fill if a previous attempt flagged `ns.State.MissingStack`.
- `SPELLS_CHANGED` (Dispenser) — pre-warms the item cache (see **Item Data Caching**). Fires on login and on any spellbook change, including learning a rank, so it covers the prewarm on its own. (The old `LEARNED_SPELL_IN_TAB` companion was dropped: redundant here, and not a valid event on TBC 2.5.5.)
- `UNIT_SPELLCAST_SUCCEEDED` (Dispenser) — when the player conjures one of the collection spells during a trade, queues a restack-then-fill (see **Restack on Conjure**).
- `PLAYER_REGEN_ENABLED` (Dispenser + Announcements) — combat end. Replays a deferred trade fill, a deferred restack, and a deferred macro update.
- `BAG_UPDATE_DELAYED` / `GROUP_ROSTER_UPDATE` / `PLAYER_ENTERING_WORLD` (Announcements) — debounced triggers for the announcement-macro sync.

There is no `PLAYER_REGEN_DISABLED` handler — nothing needs to react to combat starting; the protected paths below simply defer until `PLAYER_REGEN_ENABLED`.

### Combat Lockdown

Three protected paths defer during combat:

1. **Trade fill.** `ns.FillTrade()` checks `InCombatLockdown()` (via `ns.IsInCombat`) and sets `pendingCombatFill = true` if locked. `OnCombatEnd` (the `PLAYER_REGEN_ENABLED` handler in `Dispenser.lua`) replays it.
2. **Restack + fill.** The conjure-triggered restack moves bag items (`C_Container.PickupContainerItem`), so it defers via `pendingCombatRestack` and replays on combat end (see **Restack on Conjure**).
3. **Macro update.** `Announcements.lua` debounces updates and, if combat is active when the timer fires, sets `pendingCombatUpdate = true`; `PLAYER_REGEN_ENABLED` re-schedules it. `EditMacro` / `CreateMacro` aren't strictly protected, but combat is a bad time to race the macro UI.

The side panel needs no combat handling: it holds only plain (insecure) Clear and Fill buttons and stays parented to `UIParent`, so it shows and hides freely.

### Scan → Resolve → Fill

`ns.FillTrade(forced)` runs three phases per call:

1. **Scan** (`ScanInventory`, Inventory-Scanner.lua): walks every bag slot, tags collection items via `ns.ITEM_TO_COLLECTION`, and stores per-slot `{Bag, Slot, Count, Full}` records in an `inventory` table keyed by item ID. Each entry's `Level` comes from `ns.ITEM_LEVEL` when available (authoritative) and falls back to `GetItemInfo`'s `itemMinLevel` otherwise. `ScanInventory` returns `true` only if the inventory changed in a way that may affect a fill, so bag-update retries can skip the work.

2. **Resolve** (`UsableRankEntries` / `BestRankItemId`, Inventory-Scanner.lua, per configured item):
    - For built-in collections the partner-level cap is **intrinsic** — handing over water/food above the partner's level is useless, so the cap applies regardless of `FactorLevel`. `UsableRankEntries(collectionKey, levelLimit)` returns every held rank the partner can use, ordered highest-rank-first, so the fill can cascade down through ranks if the best one runs short. If nothing held is usable, it falls back to the lowest-rank stack on hand.
    - `KeepAtLeast` is applied only to `bestOverallId = BestRankItemId(collectionKey, nil)` — the player's top-tier stash (their drinking water). Lower ranks resolved by the cap exist only as giveaway material, so they're never reserved.
    - User-added items have one concrete ID and no alternate rank, so `FactorLevel` still gates them directly: the item is skipped when the partner is below its required level.

3. **Fill**: iterates the resolved entries best-rank-first, placing one bag slot per "stack" of `needed`. On a non-forced pass it first subtracts the stacks already offered in the trade window (read via `GetTradePlayerItemLink` / `GetTradePlayerItemInfo` and mapped back to their config key), so a mid-trade restock tops up to the configured count instead of over-filling and `MissingStack` clears once the window holds enough. Within each rank, full stacks go first, then partial stacks only if `UseNotFullStack` is on — it ships `false` for the built-in conjured collections, so they dispense full stacks only and the restack consolidates the leftovers. A `KeepAtLeast` check guards every placement against dipping the best-overall rank below the reserve. Classic Era's `C_Container.SplitContainerItem` silently ignores its `count` argument from an addon, so splits aren't possible — each bag slot is one "stack."

If `needed > 0` after the loop, `ns.State.MissingStack` is set so the next `BAG_UPDATE` retries; the chat warning is gated on `ns.DB.MissingStackWarnings`.

### Item Data Caching

`GetItemInfo` returns nil on a fresh client for items not yet seen. Two mitigations:

1. `OnSpellsChanged` (Dispenser.lua, on `SPELLS_CHANGED`) touches `GetItemInfo` for every collection item ID and every configured user-added item ID purely to seed the cache, so the first trade-time scan resolves synchronously.
2. `ns.ITEM_LEVEL` (built in `Utilities.lua` from `Data/Collections.lua`) overrides `itemMinLevel` for built-in collection items. Some conjured items return 0 from `GetItemInfo` even when they have a use-level; the hard-coded levels keep the partner-level cap accurate regardless of cache state.

---

## Trade Side Panel

`Trade-UI.lua` builds a small frame holding two plain `UIPanelButtonTemplate` buttons — Clear and Fill. The panel stays parented to `UIParent` and only **anchors** to the right of Blizzard's `TradeFrame` (matching its frame strata so it sits clickable beside it); it is never re-parented into `TradeFrame`. Because the buttons are insecure, the panel shows and hides freely with no combat handling.

- **Clear** calls `ns.ClearTrade`, walking `MAX_TRADABLE_ITEMS` slots.
- **Fill** calls `ns.FillTrade(true)` — `forced = true` clears the window first and bypasses the "did inventory change?" early-out.

`OnTradeShow` calls `ns.TradeUI:Attach(TradeFrame)`; `OnTradeClosed` calls `ns.TradeUI:Detach()`.

> Level-aware in-trade conjure buttons were removed: addon-created secure cast buttons did not fire reliably on the TBC 2.5.5 client. For one-click level-appropriate conjuring, the README points players to Consumable Connoisseur.

---

## Restack on Conjure

Conjured water/food arrive in small partial stacks, but a trade can only move whole bag slots (Classic Era's `SplitContainerItem` ignores its count from an addon) and the built-in collections dispense full stacks only. To bridge that, `Dispenser.lua` consolidates partial stacks into full ones, then fills.

`UNIT_SPELLCAST_SUCCEEDED` for any spell in `ns.SPELL_TO_COLLECTION`, during an active trade, arms a debounced `ScheduleRestack`. `restackPending` latches immediately so `OnBagUpdate` holds off dispensing the partials before they merge. When the debounce fires, `RestackCollections` does one bag walk, groups the partial stacks of each collection item, and merges them with whole-stack pickups — each step drops a whole stack onto a running target and returns any overflow to the now-empty source slot, planned from a single snapshot so no mid-operation bag re-reads are needed. Then `ns.FillTrade(false)` runs.

Because it moves bag items, the whole pass defers in combat (`pendingCombatRestack`) and replays on `PLAYER_REGEN_ENABLED`. Restacking touches only built-in collection items, never user-added ones.

---

## Announcement Macro

Water Dispenser never calls `SendChatMessage`. Instead, `Announcements.lua` keeps a single per-character macro named `- Dispenser` in sync; the player clicks it to broadcast their giveaway list. This is an intentional deviation from the shared style guide's send-path helpers — do not add `ns:Announce`-style senders back.

The whole lifecycle runs through `SyncMacroState`, invoked via a debounced `ScheduleUpdate` (250 ms) on `BAG_UPDATE_DELAYED`, `GROUP_ROSTER_UPDATE`, `PLAYER_ENTERING_WORLD`, the combat-end retry, and `ns.RefreshAnnouncementMacro` (called by the options panel after a settings change). `SyncMacroState` reads `ns.DB.Announcements.Enabled` and converges:

- Enabled + missing → `CreateMacro` (per-character slot), print `CHAT_MACRO_CREATED`.
- Enabled + exists → silent `EditMacro` with a fresh body.
- Disabled + exists → `DeleteMacro`, print `CHAT_MACRO_DELETED`.

`macroFullWarned` latches the "all character macro slots in use" warning to once per slot-exhaustion run. The body itself comes from `ns.BuildAnnouncementSnapshot` (Inventory-Scanner.lua) → `ns.BuildAnnouncementMessage`, in `ns.BUILTIN_ORDER` then user items by name, honoring each item's `KeepAtLeast` and `IncludeQuantity`.

### 255-Character Macro Body

`BuildMacroBody` prepends the channel slash (`/raid`, `/p`, or `/s`). If the full message fits the 255-**byte** `SendChatMessage` limit it is sent as-is (the list joined with a localized "and", closed by the outro). If not, it is rebuilt from the parts list: the decorated prefix (channel + marker + title + separator + intro) is laid down once, then whole item parts (link + optional count) are appended with `, ` joiners while the running byte total stays within 255 minus the ` ...` reserve; the first part that would overflow stops the loop and ` ...` is appended. Truncation happens only at **part boundaries** — never inside an item link (which `SendChatMessage` rejects), and never via a comma search, since item names can themselves contain commas. Byte length, not character count, is what governs: `#string` counts bytes, matching the client's limit. With item hyperlinks averaging 50–60 bytes, truncation kicks in around three or four items — walk this worst case (full hyperlinks, longest names) before changing the body composition.

The macro name is deliberately short: WoW silently truncates macro names past 16 characters, so `- Dispenser` (11) was chosen over `- Water Dispenser` (17), and the leading `- ` sorts it to the top of the macro list.

---

## Diagnostic Report

`Diagnostics.lua` backs the **Diagnostic Tools** options panel with read-only reports for bug triage: an event-registration probe (over `ns.EVENT_NAMES`), an API existence/shape probe (`ns.DIAGNOSTIC_API_CHECKS`), the live trade/inventory context behind a "nothing fills" complaint, and a saved-variable dump. When adding a new event or guarded API, the probes pick it up automatically only if it flows through `ns.RegisterEvent` / is listed in `DIAGNOSTIC_API_CHECKS` — keep that list to APIs the addon actually calls or guards.

---

## Saved Variables

One account-wide table, `WaterDispenserDB`, managed by **AceDB-3.0** (declared in the `.toc`). AceDB owns the standard `profiles` / `global` / `profileKeys` structure:

- **`ns.db.profile`** — every user setting: `showWelcome`, `MissingStackWarnings`, the `Dispense` / `DispenseSolo` / `DispenseGroup` / `DispenseRaid` toggles, `Announcements.Enabled`, and `Items`. Each `Items` entry (built-in `MageWater` / `MageFood` / `WarlockHealthstone` plus any user-added numeric IDs) holds `UseNotFullStack`, `FactorLevel`, `KeepAtLeast`, `IncludeQuantity`, `PlayerClasses`, and per-class `Solo` / `Group` / `Raid` stack counts; built-ins also carry `NoRemove`, `Name`, `Icon`.
- **`ns.db.global`** — only `minimap` (the table LibDBIcon reads, e.g. `minimap.hide`), account-wide and profile-independent so switching or resetting profiles never moves the button.

Every character starts on one shared **Default** profile (`AceDB:New("WaterDispenserDB", ns.DATABASE_DEFAULTS, true)` — the `true` is mandatory). Per-character setups are opt-in via the stock **Profiles** panel (`Options/Options-Profiles.lua`, the unmodified AceDBOptions-3.0 table). Reset is the stock **Reset Profile** on that panel; there is no custom reset. Defaults live in `ns.DATABASE_DEFAULTS` (`Data/Default-Settings.lua`) and are applied by AceDB via metatables — no hand-merge.

`Features/Core.lua` (`SetupDatabase`, run on `PLAYER_LOGIN`) creates the database, seeds the profile from any legacy data (below), calls `ns.RefreshCollectionMeta()` to point each built-in collection's `Name` / `Icon` / `NoRemove` at code rather than stored data, and registers `OnProfileChanged` / `OnProfileCopied` / `OnProfileReset` callbacks that re-run that refresh, rebuild the Distribution Rules panel, and resync the announcement macro on any profile switch.

**`PlayerClasses` is stored explicitly.** A class the player unchecks is written as an explicit `false`, never `nil` — AceDB re-supplies a missing key from the built-in default (e.g. `MageWater`'s `MAGE = true`), so an unchecked class must be a concrete `false` or it would reappear next login.

### Legacy Migration (temporary — remove after 2026-10-12)

The pre-AceDB build kept two raw tables: account-wide `WaterDispenserDB` (with root-level `minimap` and `WelcomeMessage`) and per-character `WaterDispenserCharDB` (`Version`, the toggles, `Items`, `Announcements`). `SetupDatabase` folds these into AceDB on first login, per the "first login seeds Default" ruling:

- The account-wide flag `ns.db.global.legacySeedDone` makes the seed a one-time move. The **first** character to log in runs the v4 → v11 chain (`ns.RunLegacyMigrations`, Utilities.lua) against its own `WaterDispenserCharDB`, copies the normalized toggles / `Announcements` / `Items` into `ns.db.profile`, and seeds `showWelcome` from the legacy account `WelcomeMessage`. **Later** characters skip the seed and inherit Default.
- Every character clears its `WaterDispenserCharDB` after the check, and the stray root `WaterDispenserDB.minimap` / `.WelcomeMessage` keys are moved to their new homes and niled.
- The `.toc` keeps `SavedVariablesPerCharacter: WaterDispenserCharDB` listed (tagged) so the client still loads the legacy table for the seed.

The whole path — the tagged blocks in `Core.lua`, `ns.RunLegacyMigrations` and the seven `Migrate*` steps in `Utilities.lua`, the legacy dump in `Diagnostics.lua`, and the `.toc` line — is deleted when the window closes.

The v4 → v11 chain, applied only to a legacy table before its values are folded in:

1. `MigrateToStacks` (≤ v4 → v5) — older builds tracked per-class item *counts*; Classic Era can't split partial stacks from an addon, so counts are divided by stack size into stack counts. v3 data already stored stacks, so it just bumps the version.
2. `MigrateAddPerItemRules` (v5 → v6) — adds `FactorLevel` and `KeepAtLeast`, defaulting to off / 0.
3. `MigrateAddIncludeQuantity` (v6 → v7) — adds `IncludeQuantity`, true for everything except healthstones.
4. `MigrateAddPlayerClasses` (v7 → v8) — adds `PlayerClasses` to user-added items (all classes); built-ins get their canonical restriction from `ns.DATABASE_DEFAULTS` via AceDB.
5. `MigrateConjuredPartialStacks` (v8 → v9) — set `UseNotFullStack` for `MageWater` and `MageFood` (later reversed by v11).
6. `MigrateRenameDispenseFields` (v9 → v10) — renames the `AutoFill*` toggles to `Dispense*`, carrying each character's choice forward.
7. `MigrateConjuredFullStacksOnly` (v10 → v11) — clears `UseNotFullStack` on `MageWater` / `MageFood`: the restack now consolidates conjured partials into full stacks, so the built-in collections dispense full stacks only.

---

## Adding a New Built-in Collection

1. Add the spell-ID and item-ID maps to `ns.COLLECTIONS` in `Data/Collections.lua`. Each `Items` row is a **positional array** — `[itemId] = {rank, level}` for water/food, `[itemId] = {rank, level, heal}` for healthstones: `[1]` rank (in-collection tier, 1 = lowest, shared by horizontal variants), `[2]` level (player level required to *use* it — authoritative, bypasses wonky `GetItemInfo` data), `[3]` heal (healthstone-only, informational). Each `Spells` row is `[spellId] = rank`. Keep the one-line column-legend comment above each table. The reverse-lookups (`ns.ITEM_TO_COLLECTION`, `ns.ITEM_RANK`, `ns.ITEM_LEVEL`, `ns.SPELL_TO_COLLECTION`) are built in `Utilities.lua` by index (`meta[1]`, `meta[2]`), so any column-order change must be mirrored there.
2. Add an entry to `ns.COLLECTION_META` (`Data/Collections.lua`) with a `NameKey` (locale string) and `Icon`; set `Unique = true` for items that only ever trade 0 or 1 (healthstones). The key must match the `ns.COLLECTIONS` key.
3. Add the collection key to `ns.BUILTIN_ORDER` in the position you want it in the Distribution Rules sidebar and the announcement message.
4. Add the default config to `ns.DATABASE_DEFAULTS.profile.Items[key]` in `Data/Default-Settings.lua` — `NoRemove = true`, the per-item flags (`UseNotFullStack`, `FactorLevel`, `KeepAtLeast`, `IncludeQuantity`), `PlayerClasses`, and the `Solo` / `Group` / `Raid` per-class stack counts.
5. Add the locale key (`L["ITEM_*"]`) and any new chat strings to `Locales/enUS.lua`. Watch length: announcement strings feed the **255-character macro body**, and German (the usual overflow canary) runs long — re-check truncation with the longest translation.

The restack trigger picks up the new collection automatically once `c.Spells` is populated, since `ns.SPELL_TO_COLLECTION` is rebuilt from it.

---

## Adding a New Locale

Copy `Locales/enUS.lua` to `Locales/<locale>.lua`. Drop the `true` argument from `NewLocale("WaterDispenser", "<locale>", true)` — that flag marks the default fallback; only `enUS.lua` should set it. Translate every string. Add the file to the `.toc` immediately after `Locales/enUS.lua`.

For Spanish, follow the style guide's shared-`strings`-table pattern: a single `esES.lua` registers the same table for both `esES` and `esMX`, avoiding the early-return bug when `NewLocale` returns nil for the second locale.

German is the usual overflow canary — after translating, sanity-check that the longest announcement strings still truncate cleanly inside the 255-character macro body.

---

## Common Pitfalls

- **Editing trade slots in combat**: silently fails. The fill defers via `pendingCombatFill`; do the same for any new trade-slot code.
- **Reading `GetItemInfo` cold**: returns nil on a fresh client. The `OnSpellsChanged` prewarm covers collections; for user-added items, prefer the cached `inventory[itemId]` over a fresh call.
- **Trusting `itemMinLevel` from `GetItemInfo`**: 0 for some conjured items. Use `ns.ITEM_LEVEL` for built-ins; the cached `inv.Level` already incorporates it.
- **Re-gating the collection rank cap on `FactorLevel`**: don't. For built-in collections the partner-level cap is intrinsic, and the `FactorLevel` toggle is hidden for them — it governs only single-rank user-added items.
- **Splitting partial stacks**: Classic Era's `C_Container.SplitContainerItem` ignores its `count` from an addon. The code tracks bag *slots* as "stacks" because of this — you can't split.
- **Assuming an event or legacy global exists on every client**: `LEARNED_SPELL_IN_TAB` is invalid on TBC; the `GetContainerNumSlots` / `PickupContainerItem` globals are gone on both Era and TBC (use `C_Container`). Register events through `ns.RegisterEvent` (it `pcall`-guards) and resolve APIs through the shims in `Utilities.lua`.
- **Macro names past 16 chars / bodies past 255 bytes**: both silently truncated by the client. Keep `MACRO_NAME` short; rely on `BuildMacroBody`'s part-boundary truncation (never mid-link) and re-walk the worst case before changing the body.

---

## Contributing

Issues and pull requests are welcome on [GitHub](https://github.com/Gogo1951/Water-Dispenser/issues). For bug reports, include:

- Game version (Classic Era / TBC) and locale
- Class and level
- Reproduction steps
- The relevant macro body or chat output (the Diagnostic Tools panel's reports are ideal)

Discussion happens on [Discord](https://discord.gg/eh8hKq992Q).

When opening a PR:

- Keep changes scoped — one concern per PR.
- Match the existing style (4-space indent, no trailing whitespace, 80-char dashed dividers between logical sections; see the project's Add-on Coding & Style Guide).
- If you add a saved-variable field, add it to `ns.DATABASE_DEFAULTS` — AceDB applies it via metatables. For a reshaping change (renamed or moved keys), add a dated migration in `SetupDatabase` following the SavedVariables migration-window rule in the style guide.
- If you change the macro body, walk the worst-case 255-character check with full item hyperlinks and the longest spell names.
- Update this document if the architecture or file map changes.
- **Write commit and PR descriptions as a User Story.** Don't just say "I changed X." Frame it by who it helps and why:

  **Format:** *As a [role], I [needed / wanted] [behavior] so that [outcome]. This change [does X].*

  **Example:** *As a high-level mage trading a low-level player, I wanted Dispense to hand over water the partner can actually drink instead of my top rank, so the trade isn't useless. This change makes the fill cap to the partner's level, cascading down through usable ranks.*

  The User Story speeds up review and gives future maintainers context the diff alone won't carry.
