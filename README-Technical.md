# Water Dispenser — Technical Reference

This document combines architecture notes and contribution guidance for developers working on Water Dispenser. For end-user documentation, see [README.md](README.md).

---

## File Map

```text
Water-Dispenser/
├── Water-Dispenser.toc                 Load order and metadata
├── Data.lua                            Colors, URLs, classes, collection tables, defaults
├── Core.lua                            State, version, helpers, lifecycle, slash commands
├── Dispenser.lua                       Inventory scan, trade fill, side UI, trade events
├── Announcements.lua                   Auto-managed `- Dispenser` macro
├── Options.lua                         Main options page (general, auto-fill, support)
├── Options-Distribution-Rules.lua      Per-item rules (sliders, settings, class filter)
├── Options-Announcements.lua           Macro toggle and live preview
├── Includes/                           Bundled libraries (LibStub, Ace3, LibDBIcon, etc.)
└── Locales/
    └── enUS.lua                        English strings (other locales fall through here)
```

TOC load order matters: `Locales → Data → Core → Dispenser → Announcements → Options-Distribution-Rules → Options-Announcements → Options`. `Options.lua` loads last so its `InitOptions` can call into `ns.InitOptionsItems` / `ns.InitOptionsAnnouncements` defined by the earlier sub-pages, and so the shared `ns.OptionsHelpers` table (defined in Core) is already on the namespace.

---

## Architecture

### Event Loop

Core.lua creates a single hidden frame and a `ns.RegisterEvent(event, handler)` dispatcher. Modules register through it rather than each owning a frame. The main events handled:

- `PLAYER_LOGIN` — runs the migration chain, populates `ns.DB`, calls each module's `Init*()`, and prints the welcome message (if the user opts in).
- `TRADE_SHOW` / `TRADE_CLOSED` — captures or clears the trade partner's class, level, and group membership, attaches/detaches the side UI, kicks off auto-fill if enabled.
- `BAG_UPDATE` — retries the trade fill if a previous attempt reported missing stacks.
- `BAG_UPDATE_DELAYED` — debounced trigger for the announcement-macro sync.
- `GROUP_ROSTER_UPDATE` — re-syncs the macro so the channel slash matches solo/party/raid.
- `PLAYER_ENTERING_WORLD` — initial macro sync once item names are warm.
- `PLAYER_REGEN_DISABLED` / `PLAYER_REGEN_ENABLED` — combat begin / end. Disabled hides the secure cast buttons in the side UI; enabled re-applies any deferred spell or macro updates.
- `SPELLS_CHANGED` / `LEARNED_SPELL_IN_TAB` — pre-warms the item cache by touching `GetItemInfo` for every collection item so the first `ScanInventory` after a spell change is synchronous.

### Combat Lockdown

Two protected paths defer during combat:

1. **Trade fill.** `ns.FillTrade()` checks `InCombatLockdown()` (via `ns.IsInCombat`) and sets `pendingCombatFill = true` if locked. The `PLAYER_REGEN_ENABLED` handler in Dispenser.lua replays the deferred fill once combat ends.
2. **Side-panel cast buttons.** The "missing conjure" buttons are `SecureActionButtonTemplate` frames. Their `SetAttribute` calls would error during combat, so `SecureButton_SetSpell` parks the spell ID in `_PendingSpell` and `frame:FlushPendingSpells()` re-applies them on combat end.

The macro update path (`Announcements.lua`) is also deferred via a `pendingCombatUpdate` flag. `EditMacro` and `CreateMacro` aren't strictly protected, but combat is a noisy time to be touching the macro UI and we'd rather not race with anything.

### ScanInventory → Resolve → Fill

`ns.FillTrade(forced)` runs three phases per call:

1. **Scan** (`ScanInventory` in Dispenser.lua): walks every bag slot, tags collection items via `ns.ITEM_TO_COLLECTION`, and stores per-slot `{Bag, Slot, Count, Full}` records in an `inventory` table keyed by item ID. Each entry's `Level` field comes from `ns.ITEM_LEVEL` when available (authoritative) and falls back to `GetItemInfo`'s `itemMinLevel` for non-collection items. `ScanInventory` returns `true` if the inventory changed in a way that may affect a fill — bag-update retries skip the work otherwise.

2. **Resolve** (`BestRankItemId` in Dispenser.lua, called per-item): for built-in collections the call site picks two item IDs:
    - `resolvedItemId = BestRankItemId(collectionKey, levelLimit)` — highest rank ≤ partner level when `FactorLevel` is on, otherwise highest rank period.
    - `bestOverallId = BestRankItemId(collectionKey, nil)` — highest rank the player has, no level filter.

   `isBestOverall = (resolvedItemId == bestOverallId)` decides whether `KeepAtLeast` applies during fill. The point: `KeepAtLeast` protects the player's top-tier stash (their drinking water), so it shouldn't reserve lower-rank leftovers that exist only as giveaway material.

3. **Fill**: places one bag slot per "stack" of `needed`. Full stacks first, then partial stacks if `UseNotFullStack` is on. Classic Era's `C_Container.SplitContainerItem` silently ignores its `count` argument when called from an addon, so partial-stack splits aren't possible — each bag slot is one "stack" in the addon's terminology.

If `needed > 0` after the fill loop, `ns.State.MissingStack` is set so `OnBagUpdate` retries. The chat warning is gated on `ns.DB.MissingStackWarnings`.

### Item Data Caching

`GetItemInfo` returns nil on a fresh client for items not yet seen. Two mitigations:

1. `OnSpellsChanged` (which fires on `SPELLS_CHANGED` and `LEARNED_SPELL_IN_TAB`) walks every collection item ID and every configured user-added item ID, calling `GetItemInfo` purely to seed the cache. By the time the player opens a trade, item info is warm.
2. `ns.ITEM_LEVEL` overrides `itemMinLevel` for built-in collection items at scan time. Some conjured items return 0 from `GetItemInfo` even when they have a level requirement (cache miss or stale data); the hard-coded levels keep the partner-level filter accurate regardless of cache state.

### Announcement Macro

`Announcements.lua` owns a single per-character macro named `- Dispenser`. The whole lifecycle goes through `SyncMacroState`, which is invoked via a debounced `ScheduleUpdate` (250 ms) on:

- `BAG_UPDATE_DELAYED` — bag changed
- `GROUP_ROSTER_UPDATE` — channel slash needs updating
- `PLAYER_ENTERING_WORLD` — initial sync after login
- `PLAYER_REGEN_ENABLED` — replay any deferred update
- The "Enable Announcement Macro" toggle in the options UI (via `ns.RefreshAnnouncementMacro`)
- The "Keep at Least" and "Include Quantity Remaining" sliders/toggles in Distribution Rules → Settings

`SyncMacroState` reads `ns.DB.Announcements.Enabled` and converges the world to it:

- Enabled + macro missing → `CreateMacro`, print `CHAT_MACRO_CREATED`.
- Enabled + macro exists → silent `EditMacro` with fresh body.
- Disabled + macro exists → `DeleteMacro`, print `CHAT_MACRO_DELETED`.

The `macroFullWarned` flag latches the "all character macro slots in use" warning so it fires once per slot-exhaustion run instead of every bag update.

### 255-Character Macro Body

`BuildMacroBody` composes the channel slash plus the announcement message. If the result exceeds 255 characters, it truncates at the last comma boundary inside the safe range and appends a space followed by `...` — never slicing through a bracketed item name like `[Crystal Wa...`. With item links averaging 50–60 chars each, the truncation kicks in around three or four items.

The macro name is intentionally short. WoW silently truncates macro names past 16 characters, so `- Dispenser` (11 chars) was chosen over `- Water Dispenser` (17). The leading `- ` sorts the macro to the top of the alphabetical macro list, making it quick to find when dragging onto an action bar.

---

## Saved Variables

One per-character table: **`WaterDispenserCharDB`**. No account-wide variable currently — the addon has no minimap button or UI placement that would warrant one.

A legacy **`WaterDispenserDB`** is also listed in the .toc. It exists only so `MigrateLegacy` can read forward from older saved data; once migrated, the table is cleared and will be dropped from the .toc entirely in a future release.

### Migration Chain

`InitDB` runs migrations in order, then applies `EnsureDefaults`:

1. `MigrateLegacy` — copies values from the pre-v5 `WaterDispenserDB` (different schema) into the new table, then sets `_Migrated`.
2. `MigrateToStacks` (≤ v4 → v5) — older builds tracked per-class item *counts*; Classic Era can't split partial stacks from an addon, so we now track stack counts. Divides each saved count by the item's stack size.
3. `MigrateAddPerItemRules` (v5 → v6) — adds `FactorLevel` and `KeepAtLeast` fields, defaulting both to off / 0.
4. `MigrateAddIncludeQuantity` (v6 → v7) — adds the `IncludeQuantity` toggle, defaulting to `true` for everything except healthstones.
5. `MigrateAddPlayerClasses` (v7 → v8) — adds the `PlayerClasses` table for per-item class filtering. User-added items default to all classes; built-in collections get their canonical class restriction via `EnsureDefaults` (Mage for water and food, Warlock for healthstones).

`EnsureDefaults` is recursive and only fills *nil* fields; it never overrides explicit user values. That means changes to default *values* (e.g. raising `KeepAtLeast` to 20 for Mage Water) only land for fresh characters — existing characters can hit the global Reset to pick them up.

When adding a new migration, append to the chain in `InitDB` and bump the version. `EnsureDefaults` runs *after* migrations so newly-introduced fields can pick up sensible defaults the same release.

---

## Adding a New Built-in Collection

1. Add the spell-ID and item-ID maps to `ns.COLLECTIONS` in `Data.lua`. Each row needs an identifying `-- Name (rank N)` comment; reverse-lookup tables (`ns.ITEM_TO_COLLECTION`, `ns.ITEM_RANK`, `ns.SPELL_TO_COLLECTION`) are built from these automatically.
2. Add an entry to `ns.COLLECTION_META` with a `NameKey` (locale string) and `Icon` path. The key must match the collection's key in `ns.COLLECTIONS`.
3. Add the collection key to `ns.BUILTIN_ORDER` in the position you want it to appear in the Distribution Rules sidebar and the announcement message.
4. Each `Items` entry uses `[id] = {rank, level, heal?}` metadata. `level` is the player level required to *use* the item (authoritative; bypasses any wonky `GetItemInfo` data). `heal` is optional metadata used for healthstones. The reverse-lookup tables `ns.ITEM_RANK` and `ns.ITEM_LEVEL` are built from these automatically.
5. Add the default item config to `ns.DB_DEFAULTS.Items[key]` — `NoRemove = true`, the standard per-item flags, `PlayerClasses` (which classes dispense it), and the `Solo` / `Group` / `Raid` per-class stack counts.
6. Add the locale key (`L["ITEM_*"]`) and any new chat strings to `Locales/enUS.lua`.

`ScanInventory`'s spell-side seed loop will pick up the new collection automatically as long as `c.Spells` is populated.

---

## Adding a New Locale

Copy `Locales/enUS.lua` to `Locales/<locale>.lua`. Drop the `true` argument from the `NewLocale("WaterDispenser", "<locale>", true)` call (the `true` flag marks the file as the default fallback — only `enUS.lua` should set it). Translate every string. Add the file to the .toc immediately after `Locales/enUS.lua`.

For Spanish, follow the pattern in the style guide: a single `esES.lua` file that registers the same strings table for both `esES` and `esMX` to avoid the early-return bug when `NewLocale` returns nil for the second locale.

---

## Common Pitfalls

- **Editing trade slots in combat**: silently fails. The fill path defers via `pendingCombatFill`; do the same for any new code that touches trade slots.
- **Reading `GetItemInfo` cold**: returns nil on a fresh client. The `OnSpellsChanged` prewarm covers built-in collections; for user-added items, prefer the cached `inventory[itemId]` over a fresh `GetItemInfo` call.
- **Trusting `itemMinLevel` from `GetItemInfo`**: returns 0 for some conjured items. Use `ns.ITEM_LEVEL` for built-in collections; the cached `inv.Level` already incorporates that override.
- **Splitting partial stacks**: Classic Era's `C_Container.SplitContainerItem` silently ignores its `count` argument when called from an addon. The codebase tracks bag *slots* as "stacks" precisely because of this. If you find yourself wanting to split, you can't.
- **Macro names past 16 chars**: silently truncated by the WoW client. Keep `MACRO_NAME` short.
- **Macro bodies past 255 chars**: silently truncated by the WoW client. `BuildMacroBody`'s comma-boundary truncation is the existing solution; don't extend the body without checking the worst case.
- **`SetAttribute` on secure buttons during combat**: forbidden. The `SecureButton_SetSpell` pattern in Dispenser.lua is the model for any new secure-button code.
- **Forgetting the legacy SavedVariables line**: removing `WaterDispenserDB` from the .toc before the legacy migration has run on every active character will drop their data. Wait at least one full release after the migration is in place.

---

## Contributing

Pull requests welcome at https://github.com/Gogo1951/Water-Dispenser. For bugs or feature ideas, please open a GitHub issue with:

- Game version (Classic Era / TBC / Retail) and locale
- Class and level
- Reproduction steps
- A copy of the relevant macro body or chat output

Discussion happens on Discord: https://discord.gg/eh8hKq992Q.

When opening a PR:

- Keep changes scoped — one concern per PR is easier to review.
- Match the existing code style (4-space indent, no trailing whitespace, 80-char dashed dividers between logical sections, see the project's Add-on Coding & Style Guide).
- If you change saved-variable structure, append a new migration to `InitDB` and bump the version.
- If you change the macro body composition, walk the worst-case 255-char check with full item hyperlinks and the longest spell names you can find.
- Update this document if the architecture or file map changes.
