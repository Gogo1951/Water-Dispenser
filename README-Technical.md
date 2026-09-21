# Water Dispenser // Technical Reference

This document combines architecture notes and contribution guidance for developers working on Water Dispenser. For end-user documentation, see [README.md](https://github.com/Gogo1951/Water-Dispenser/blob/main/README.md).

## File Map

```text
Water-Dispenser/
├── .github/
│   └── workflows/
│       └── package.yml              CurseForge release plus library vendoring
├── .gitattributes                   Line-ending normalization
├── .gitignore                       Dev-clutter ignore list
├── .luacheckrc                      Lint config, excludes Includes/
├── .pkgmeta                         Externals and the packager ignore list
├── Water-Dispenser_Vanilla.toc      Classic Era
├── Water-Dispenser_TBC.toc          TBC Anniversary
├── Water-Dispenser_Camelot.toc      WoW Forever
├── Data/
│   ├── Flavor.lua                   Flavor identity from the TOC's X-Flavor, and the data folder it loaded
│   ├── Data.lua                     Locale init, identity constants, palette, classes, links, options grid, collection metadata
│   ├── Era/Collections.lua          Classic Era rows of the built-in collections and the healthstone talent
│   ├── SoD/Collections.lua          Season of Discovery, listed after Era/ by the Vanilla TOC; an IS_SOD guard picks one
│   ├── TBC/Collections.lua          TBC Anniversary
│   ├── Forever/Collections.lua      WoW Forever
│   ├── Wrath/Collections.lua        Wrath, ahead of any TOC
│   ├── MoP/Collections.lua          MoP Classic, ahead of any TOC
│   ├── Retail/Collections.lua       Retail, ahead of any TOC
│   └── Default-Settings.lua         The AceDB defaults table, profile scope only
├── Features/
│   ├── Core.lua                     Shared state, version, the dispatcher, AceDB init, the login sequence
│   ├── Utilities.lua                Combat and secret-value guards, colors, collection lookups, amount readers, item gates
│   ├── Announcements.lua            Branded print, channel resolver, the auto-managed - Dispenser macro
│   ├── Inventory-Scanner.lua        Bag scan and cache, rank resolution, the two giveaway snapshots
│   ├── Bag-Moves.lua                The only bag writes: merges and splits for the fill, and the post-trade restack
│   ├── Session-Ledger.lua           Per-partner session totals and the per-trade cap-notice latch
│   ├── Dispenser.lua                Trade fill and stack shaping, conjure placement, the trade events, the Dispense switch
│   ├── Trade-UI.lua                 Clear and Fill buttons anchored beside the trade window
│   ├── Group-Spares.lua             Addon-message broadcast of the giveaway list, and the player tooltip block
│   ├── Item-Tooltips.lua            The bag-item line naming what the add-on will hand over
│   ├── Diagnostics.lua              Report builders, event log, API and event probes, validator, taint log
│   └── Minimap-Button.lua           LDB object, tooltip composition, click handlers
├── Includes/
│   ├── Images/
│   │   └── Water-Dispenser.tga      The TOC's IconTexture
│   └── Libraries/                   Vendored Ace3 stack plus LibDataBroker and LibDBIcon, never hand-edited
├── Locales/
│   ├── enUS.lua                     Source strings
│   └── deDE.lua … zhTW.lua          Ten translations
├── Options/
│   ├── Options-Utilities.lua        Widget helpers, sub-option rows, profile accessors, the number box
│   ├── Options-General.lua          Root panel: welcome, mini-map, /Commands, links, version
│   ├── Options-Dispenser.lua        Dispense master and its sub-toggles, and the combat notice
│   ├── Options-Dispensed-Items.lua  Item tree: the per-class grid, Everyone row, settings, Add an Item
│   ├── Options-Announcements.lua    Macro toggle with live preview
│   ├── Options-Group-Spares.lua     Inventory Tooltips: the player and bag tooltip toggles, and sharing
│   ├── Options-Profiles.lua         Stock AceDBOptions-3.0 table, returned unmodified
│   ├── Options-Diagnostics.lua      Diagnostic Tools panel, registered last
│   └── Options.lua                  Registration, ns:OpenOptionsPanel, the /wd command
├── LICENSE                          MIT
├── README.md                        Player-facing documentation
├── README-Technical.md              This document
└── README-Testing.md                Manual test plan, run before a release
```

`.github/`, `.gitattributes`, `.gitignore`, `.luacheckrc`, `.pkgmeta` and `LICENSE` are repo-only: the packager strips them, so an installed copy does not carry them. There are no deprecated or dead files. Everything under `Features/` and `Options/` is listed in all three TOCs, which differ only in their `## Interface`, their `## X-Flavor` and their flavor-folder lines (the Vanilla TOC lists `Era/` and `SoD/`, the other two one folder each). `Wrath/`, `MoP/` and `Retail/` are deliberate forward-prep that no TOC loads yet. Each client loads only its own TOC and its own folder, so there is no unsuffixed `Water-Dispenser.toc` and no data file outside the flavor folders. `Includes/Libraries/` is rewritten by the release workflow from `.pkgmeta` on every tag, so a hand edit there is overwritten by the next release.

Every flavor folder holds one `Collections.lua` declaring the same two tables whole, `ns.COLLECTIONS` and `ns.HEALTHSTONE_TALENT_SPELLS`, with the rows true on that client. A row changed in one folder is looked up in the other six (Style Guide → DATA → Flavor Folders).

The TOC load order is `Includes → Locales → Data → Features → Options`. Five ordering constraints are load-bearing:

- `Locales` loads before `Data`, because `Data/Data.lua` calls `GetLocale` and needs every `NewLocale` already registered.
- `Data/Flavor.lua` opens the Data block. The Vanilla TOC lists both `Data/Era/` and `Data/SoD/`, and each of those files opens with an `ns.IS_SOD` guard, so exactly one of the pair builds its tables.
- The TOC's flavor folder loads before `Features/Utilities.lua`, which builds the reverse-lookups (`ns.ITEM_TO_COLLECTION`, `ns.ITEM_RANK`, `ns.ITEM_LEVEL`, `ns.SPELL_TO_COLLECTION`, `ns.SPELL_TO_ITEMS`) from it at file scope.
- Within `Options`, `Options-Utilities.lua` loads first because every panel file aliases its helpers at file scope, and `Options.lua` loads last so `ns.RegisterOptionsPanels` can see every `ns.Build*Options` builder.
- `Features/Bag-Moves.lua`'s `ns.InitRestacker` runs *after* `ns.InitDispenser` in the login sequence, not because of the TOC but because both claim `TRADE_CLOSED` and the restack pass reads the `ns.State.Trade.Active` flag the dispenser's handler clears.

## Architecture

### Event Loop

`Features/Core.lua` creates one hidden frame and a `ns.RegisterEvent(event, handler, ...)` dispatcher. Feature files never register an event on a frame of their own. The Event Registration probe's throwaway frame registers and immediately unregisters each name with no handler, which is a test, not a listener. Several handlers may claim the same event: they are stored as a list and called in registration order, which is the order the modules initialize in `Core.lua`. Of those, four register anything -- Dispenser, Announcements, Group Spares, then Bag Moves; the options panels and the mini-map button register no events at all.

Registration is wrapped in `pcall`, so an event name invalid on one client is skipped rather than erroring at load. The name is appended to `ns.EVENT_NAMES` before that attempt, in first-seen order, so a name this client rejects still reaches the Diagnostic Tools event-registration probe, which reports it as a failure. The probe and the event log both read that one list, so neither can drift from what the add-on registers.

Trailing arguments are unit tokens: when present the dispatcher calls `RegisterUnitEvent` instead. **The filter is fixed by the first registration of that event name**, because `RegisterUnitEvent` binds per frame-and-event and every module shares this one frame.

The twelve registered events:

- `PLAYER_LOGIN` (Core) runs `SetupDatabase`, registers the options panels, calls each module's `Init*()`, schedules the bag-item tooltip hook one frame later, and prints the welcome message if opted in. Saved variables are loaded and the item cache is warm enough for a first scan; nothing initializes at file scope.
- `TRADE_SHOW` / `TRADE_CLOSED` (Dispenser). `TRADE_SHOW` captures the partner's class, level, group state, guild membership and key, resets the per-trade move ceilings, placement record and cap-notice latch, attaches the side panel, and kicks off the fill when `Dispense` and the matching scope toggle (`DispenseSolo`, `DispenseGroup` or `DispenseRaid`) are both on. `TRADE_CLOSED` credits the accepted offer to the session ledger, clears the partner state and the conjure watch, and detaches the panel. It carries a second handler in Bag Moves, which arms the post-trade restack; it registers last, so the dispenser's handler has already cleared `ns.State.Trade.Active` before the restack chain reads it.
- `TRADE_ACCEPT_UPDATE` (Dispenser) snapshots the offer the moment the **player** accepts, for crediting to the session ledger on `TRADE_CLOSED`. Waiting for both sides would silently break Maximum per Session: when the partner has already accepted and the player clicks second, the server completes the trade and `TRADE_CLOSED` arrives with no `(1, 1)` update ever firing, so nothing would be credited and the cap would never accumulate.
- `BAG_UPDATE` (Dispenser) places anything a mid-trade conjure just produced, and retries the fill when an earlier pass in *this* trade flagged `ns.State.MissingStack`. It returns immediately when neither applies.
- `SPELLS_CHANGED` (Dispenser, Group Spares) pre-warms the item cache and re-broadcasts the giveaway list, since a talent change moves a warlock's healthstone rank. It fires on login and on any spellbook change, including learning a rank, so it covers the prewarm alone; `LEARNED_SPELL_IN_TAB` is deliberately not registered as a companion, and is not a valid event on TBC Anniversary.
- `UNIT_SPELLCAST_SUCCEEDED`, **filtered to `"player"`** (Dispenser), arms the conjure watch. Without the filter this fires for every nearby unit, which in a raid both wastes dispatcher work in combat and floods the diagnostic event log.
- `BAG_UPDATE_DELAYED` (Announcements, Group Spares) is the debounced bag trigger: it fires once after a batch settles, where `BAG_UPDATE` fires per slot change.
- `GROUP_ROSTER_UPDATE` (Announcements, Group Spares) rewrites the macro's channel slash, prunes anyone who left, and re-broadcasts for whoever just joined.
- `PLAYER_ENTERING_WORLD` (Announcements, Group Spares) is the first sync once item names are cached. Nothing that touches saved variables hangs off it, since it refires on every loading screen.
- `PLAYER_REGEN_ENABLED` (Announcements, Group Spares) replays what combat deferred: a macro update, and a roster change Group Spares would not prune against mid-fight. Nothing in `Dispenser.lua` listens: a fill blocked by combat is abandoned, not queued.
- `CHAT_MSG_ADDON` (Group Spares) receives another member's giveaway list on `ns.ADDON_MESSAGE_PREFIX`.

There is no `PLAYER_REGEN_DISABLED` handler. Nothing needs to react to combat starting; the protected paths below check `InCombatLockdown` when they run.

### Combat Lockdown

**Nothing about a trade is deferred.** `ns.FillTrade` and `ns.ClearTrade` check `ns.IsInCombat()` and abandon the attempt, printing `CHAT_COMBAT_BLOCKED` when `CombatNotifications` is on. There is no pending flag and no replay: a trade window does not survive a fight, so queueing work for combat end buys a message nobody needed. `OnBagUpdate` drops the conjure watch on the same check, silently, because a cast whose bag update lands mid-fight is stale by the time combat ends.

Two paths defer instead, and neither is a trade:

- `Features/Announcements.lua` debounces macro updates by 250 ms, and if combat is active when the timer fires it sets `pendingCombatUpdate` and re-schedules on `PLAYER_REGEN_ENABLED`. `EditMacro` and `CreateMacro` are not strictly protected, but combat is a bad time to race the macro UI, and a stale macro body would otherwise persist until the next out-of-combat bag change.
- `Features/Group-Spares.lua` sets `rosterChangedInCombat` for a `GROUP_ROSTER_UPDATE` that arrives mid-fight and runs the prune and re-broadcast on `PLAYER_REGEN_ENABLED`, because on Forever the roster's names can come back hidden in combat and a prune that could not read them would drop real groupmates.

The post-trade restack abandons its chain in combat rather than deferring it. The fill's own merges and splits never run in combat either, since `ns.FillTrade` refuses before reaching them.

`ns:OpenOptionsPanel` refuses outright: `InCombatLockdown()` is the first thing it does, it prints `CHAT_OPTIONS_IN_COMBAT` every time the player asks, and it returns rather than queueing. That one gate sits in front of the whole routing chain and is never duplicated in the slash handler or the mini-map click handler.

The group broadcast and the unit-tooltip block both stand down in combat as well: the client can drop addon traffic under load, and nobody is reading tooltips mid-fight.

**Hidden values on Forever.** Forever runs the Retail engine, which hides some values from add-ons in combat (unit names, cast spell IDs), and comparing or indexing with one throws. `ns.IsSecretValue` wraps the client's `issecretvalue`, which Era and TBC ship too; only Forever is known to hand an add-on a hidden value. The unit-tooltip hook stands down in combat before it reads the unit, `OnSpellcastSucceeded` checks the trade and combat before it looks the spell up, `OnAddonMessage` and `UnitKey` drop a hidden value, a roster change in combat is replayed on `PLAYER_REGEN_ENABLED` rather than pruning against names it cannot read, and the event log writes `<secret>` in place of a hidden argument.

The trade side panel needs no combat handling at all. It holds plain insecure buttons and stays parented to `UIParent`, so it shows and hides freely.

### Scan → Resolve → Fill

`ns.FillTrade(forced)` runs three phases per call, and can run several times per trade because every bag update re-enters it.

**It stands down first if anything is on the cursor.** Every phase reaches for the cursor itself (clearing the window, lifting a slot, a merge, a split), so filling now would drop what the player is holding. The window is not a narrow one: picking an item up locks its slot, which is a bag update, which re-enters the fill, so this fires exactly while the player is moving things by hand mid-trade. It sets `ns.State.MissingStack` on the way out, so the player's next drop, itself a bag update, runs the pass again.

1. **Scan** (`ScanInventory`, `Features/Inventory-Scanner.lua`) walks every bag slot and stores per-slot `{Bag, Slot, Count, Full, Bound, Locked}` records, plus the item's `StackSize` from the cache, in an `inventory` table keyed by item ID. Every occupied slot is tracked with no view taken on item class: the player decides what is dispensed, and a Consumable gate would silently hide trade goods and explosives. Items are tagged to their collection through `ns.ITEM_TO_COLLECTION` even when the player does not know the conjure spell, so a non-mage carrying conjured water still announces it as Conjured Water. `ScanInventory` returns `true` only when the inventory changed in a way that may affect a fill, so a non-forced retry can skip the work. A slot's lock state counts as such a change: a freshly split slot can report locked on the first bag update and settle on the next, and that second update has to re-enter the fill.

2. **Resolve** decides whether an item is owed anything, how much, and which held item IDs to give from, best first:
    - **Three gates come before any count.** `ns.IsItemActiveForPlayer` is the item's player-class filter. `ns.IsItemDistributableNow` is its `Distribute` rule, about where the *player* is: `Always`, or `Instance` for a dungeon, raid, battleground or arena. `ns.IsItemAllowedForPartner` is `GuildiesOnly`, about who opened the trade, tested against `ns.State.Trade.Guild`, which `OnTradeShow` reads from `UnitIsInMyGuild("NPC")` while the unit still exists. Only the class filter counts toward `activeForPlayer`, which drives the `CHAT_NONE_ACTIVE_FOR_CLASS` hint: an item held back by place or partner is still set up for the class.
    - The target is the item's per-class count for the partner's class, in the scope column `PickScope` resolves: `Solo` unless the partner is in the player's party or raid, then `Raid` or `Group` by `IsInRaid()`.
    - For built-in collections the partner-level cap is **intrinsic**: water or food above the partner's level is useless to them, so it applies regardless of `FactorLevel`, and the toggle is hidden on those panels. `UsableRankEntries(collectionKey, levelLimit)` returns every held rank the partner can use, highest first, so the fill cascades down when the best rank runs short. If nothing held is usable it falls back to the single lowest-rank stack on hand.
    - The reserve (`ns.GetItemReserve`) applies only to `BestRankItemId(collectionKey, nil)`, the player's top-tier stash. Lower ranks surfaced by the cap are pure giveaway material and are never reserved.
    - User-added items have one concrete ID and no alternate rank, so `FactorLevel` gates them directly: skipped outright when the partner is below the item's required level.
    - When `UnitLevel("NPC")` comes back nil, `-1` or `0` (unknown or still loading), `OnTradeShow` substitutes the player's own level plus ten rather than leaving the cap to lock everything out.

3. **Fill** iterates the resolved entries best-rank-first, covering `needed` **individual items**. Every number in this add-on is a count of items, never of stacks. On a non-forced pass it first subtracts what is already sitting in the trade window, read through `GetTradePlayerItemLink` / `GetTradePlayerItemInfo` and mapped back to its config key, so a mid-trade restock tops up instead of over-filling.

    "Already in the window" is read two ways and the larger per key wins. `CountOffered` reads the trade API, which lags: `ClickTradeButton` is a server round trip, and the lock it puts on the bag slot fires a bag update before the acknowledgement lands, so a pass in that gap would read the target as unmet and hand over a second stack. `PendingOffer` reads `placedThisTrade`, the fill's own record of every slot it has placed, pruned of any slot that is no longer locked (refused by the server, or taken back out by the player). The API misses a placement until it is acknowledged; the record misses a stack the player dragged in by hand. Each is a lower bound, so the larger is the closer, and both err toward giving less.

    Within a rank, **locked slots are off the table** before anything else is decided. With a trade open a locked slot is either already sitting in the window or still settling from a move, and lifting one is a silent no-op. The offered items were subtracted from the target; listing their slots as candidates too would count the same items twice, once as given and once as still available, and stop the fill one stack short. Locked slots **beyond** the ones the window accounts for (the larger of the API's and the record's slot tallies for that item ID) are moves still in flight -- a split landing, a merge settling, a cleared window unlocking -- and the rank waits for their bag update rather than filling around what is about to land. The reserve is measured against the unlocked total, since what is in the window leaves the bags the moment the trade goes through, and never exceeds what the tradable slots hold.

    **Whole slots go in only when they do not fragment the offer**: a full stack (`Full` from the scan, which is also true while the stack size is uncached, so a cold cache places any slot no larger than what is owed) or a slot holding exactly what is still owed, biggest first. A loose 1 inside a target of 2 waits: placing it would put a second 1, split off on the next pass, in another trade slot beside it -- two Runecloth as two trade slots of one. `PlaceStack` checks each slot **before** lifting it -- not locked, the live count still matches the scan, and the cursor actually holds something after the pickup -- and any of those failing skips the slot for this pass rather than trusting it. Only a full trade window ends the pass.

    **Whatever is still owed is shaped in the bags first.** `ShapeStack` builds one slot of exactly the remainder (capped at a full stack) from the loose slots, cheapest move first since each is a server round trip: two loose slots that add up to it merge into one; else the *smallest* slot larger than it has that much split off into an empty bag slot (breaking a 7 to find 5 leaves a full 20 intact, and the scrap stays where it falls); else everything loose is smaller than the remainder and merges pairwise, smallest onto largest, for the next pass to look again. The move's own bag update re-enters the fill, where the shaped slot is an exact match for the whole-slot rule, which is why a fill can end with `MissingStack` set and no warning printed: `inFlight` distinguishes "on its way" from "genuinely short". If the bags cannot be shaped at all -- the move budget is spent, the client will not split, a single loose slot is all there is -- the loose slots go over as they are, since several slots is worse than one but better than none.

    The shaped amount is capped by what the reserve still allows, so a target the bags cannot legally cover hands over everything it may rather than stopping at the last whole slot that happened to fit. Soulbound slots are skipped for user-added items but not for built-in collections, because conjured items report bound yet trade fine.

**Two per-item amounts sit behind toggles**, and both are read only through `Features/Utilities.lua` so a switched-off amount can never take effect: `ns.GetItemReserve` returns 0 unless `KeepAtLeastEnabled`, and `ns.GetItemSessionCap` returns nil unless `SessionCapEnabled`. The stored number lives beside its toggle rather than being zeroed, so switching off and back on returns the player's own value. Both are typed in freely, like every other amount in the panel.

**Changing an amount clears that item's session ledger.** `ns.ResetSessionLedger(configKey)` is called from every control that changes how much of an item goes out: the per-class grid, the Everyone row, and the Maximum per Session row. Credited giving is only meaningful against the limit it was measured under, so leaving it in place makes a cap raised from 2 to 10 hand over nothing until the next reload, which reads as the setting being ignored. It is keyed per item, so editing one never resets another.

Five notices explain an empty window, and they are deliberately gated differently:

| Notice | Gate | Latch |
|---|---|---|
| `CHAT_COMBAT_BLOCKED` | `CombatNotifications` (ships on) | None |
| `CHAT_SESSION_CAP_REACHED` | Ungated | Per item, per trade (`capNoticed`) |
| `CHAT_MISSING_STACK` | `MissingStackWarnings` (ships off), and never while `inFlight` | None |
| `CHAT_SPLIT_REFUSED` | `MissingStackWarnings` | Per item, per trade (a refusal spends the item's move budget) |
| `CHAT_NONE_ACTIVE_FOR_CLASS` | `MissingStackWarnings`, forced fill only | Once per session (`noneActiveWarned`) |

The session-cap line is the one that is not opt-in. `MissingStackWarnings` ships off, and that line is the only explanation for a trade window the player expected to fill sitting empty; hiding it behind an opt-in makes an obedient cap look like a broken add-on. A `Distribute` or `GuildiesOnly` gate that empties the window prints nothing.

If `needed > 0` after the loop, `ns.State.MissingStack` is set so the next out-of-combat `BAG_UPDATE` retries. **The flag lives and dies with one trade.** `OnTradeShow` clears it before deciding whether to fill, and `OnTradeClosed` clears it again. Left standing between trades it becomes a second, invisible way in, because `OnBagUpdate` fills on the flag alone: the next trade would top itself up on any bag change even though `OnTradeShow` had just declined to fill it.

### Item Data Caching

`GetItemInfo` returns nil on a fresh client for items it has not seen. Three mitigations, in the order they take effect:

1. `OnSpellsChanged` (`Features/Dispenser.lua`) touches `C_Item.GetItemInfo` for every collection item ID and every configured user-added ID purely to seed the cache, so the first trade-time scan resolves synchronously. Every collection, not just the player's own, so a non-mage carrying mage water benefits too.
2. `ns.ITEM_LEVEL` (built in `Features/Utilities.lua` from the flavor folder's `Collections.lua`) overrides `itemMinLevel` for built-in collection items. Some conjured items report 0 even when they have a use level, so the static table keeps the partner-level cap correct regardless of cache state.
3. `ScanInventory` calls `C_Item.RequestLoadItemDataByID` for any uncached item and refuses to trust the other returns from that pass. A later scan backfills only the fields still missing, so a cold call can never blank out good data. An uncached max stack is treated as "full", so a genuine full stack is not skipped; the next warm scan corrects it.

The options panels read the inventory from several render callbacks in the same frame, so `ScanInventoryForDisplay` coalesces those into one scan per frame (`GetTime` is constant within a frame) while a reopen on a later frame still rescans. Trade and fill paths call `ScanInventory` directly and always scan fresh.

### Identity Constants

The installed folder and packaged name are `Water-Dispenser`, but the in-Lua identity is `WaterDispenser` with no hyphen. `Data/Data.lua` pins it as `ns.LOCALE_NAME`, and that constant -- never the `ADDON_NAME` vararg -- backs the `GetLocale` call, the LibDataBroker object name, the LibDBIcon registration key and the number-box widget type. APIs keyed off the *packaged* add-on still take `ADDON_NAME`: `C_AddOns.GetAddOnMetadata` for the version and the flavor, and `ns.OPTIONS_REGISTRY`, whose names are derived from it.

The literal appears in two other places. `Locales/*.lua` has to repeat it: every `NewLocale` runs before `Data/Data.lua` has defined the constant, which is why the Style Guide has the locale files repeat the literal. `ns.ADDON_MESSAGE_PREFIX`, also in `Data/Data.lua`, is the addon-message prefix: a separate constant that shares the spelling, read by the Group Spares send path, its receive path and the event log's prefix filter alike, so the three cannot disagree. Renaming the identity leaves the prefix alone unless it is changed too, and changing the prefix splits a group across releases, since a copy listening on the old prefix neither hears nor is heard by one on the new. The client caps prefixes at 16 characters, and `Water-Dispenser` fits only by luck.

### Colors

`ns.PALETTE` (`Data/Data.lua`) holds raw six-character hex with no `|cff` prefix. `Features/Utilities.lua` derives the escape-code table at file scope and exposes `ns.GetColor(key)`, which returns the prefix and falls back to `TEXT`; callers append `|r` themselves. `BODY` is white for descriptions and options body text, `HELP` is silver for helper text. The two are distinct roles rather than shades of one: sub-option captions and diagnostics hints use `HELP`, everything else descriptive uses `BODY`. `ns.CLASS_COLORS` colors the class labels on the Dispensed Items grid, and `ns.ITEM_QUALITY_COLORS` is the parallel table the group-spares tooltip reads, indexed by the quality `GetItemInfo` returns.

## Trade Side Panel

`Features/Trade-UI.lua` builds a small frame holding two plain `UIPanelButtonTemplate` buttons, Clear and Fill. The panel stays parented to `UIParent` and only **anchors** to the right of Blizzard's `TradeFrame`, matching its frame strata so it sits clickable beside it. It is never re-parented into `TradeFrame`. Because the buttons are insecure, the panel shows and hides with no combat handling.

- **Clear** calls `ns.ClearTrade`, walking `MAX_TRADABLE_ITEMS` slots and forgetting the fill's placement record, so the pass after it waits for the cleared slots to unlock rather than filling around them.
- **Fill** calls `ns.FillTrade(true)`. The `forced` flag clears the window first and bypasses the "did inventory change?" early-out, and it is also what arms the `CHAT_NONE_ACTIVE_FOR_CLASS` hint.

`OnTradeShow` calls `ns.TradeUI:Attach(TradeFrame)`; `OnTradeClosed` calls `ns.TradeUI:Detach()`.

Level-aware in-trade conjure buttons are deliberately absent: add-on-created secure cast buttons did not fire reliably on TBC Anniversary. Do not reintroduce them.

## Conjure During a Trade

Conjured items arrive in small partial stacks, and portioning cannot invent items the player does not have yet, so casting mid-trade would show nothing until enough casts had piled up, which reads as broken. `Features/Dispenser.lua` short-circuits that by offering the conjured slot directly.

A filtered `UNIT_SPELLCAST_SUCCEEDED` for any spell in `ns.SPELL_TO_COLLECTION`, during an active trade, calls `WatchConjure`. That snapshots every bag slot currently holding one of that spell's items into `conjureWatch[itemId][bag .. ":" .. slot] = count`. Which items a spell can produce comes from `ns.SPELL_TO_ITEMS`, built in `Features/Utilities.lua` by matching each spell's rank against the collection's item ranks, so a rank's horizontal variants are all watched.

The next `BAG_UPDATE` runs `PlaceConjured`: one bag walk, offering every watched slot whose count rose above its snapshot or that was not in the snapshot at all, then clearing the watch either way. Locked slots are skipped, because the move is still in flight server-side and the following bag update sees them settled.

Three consequences are deliberate:

- **The conjured slot bypasses the reserve, the session cap and the per-class counts.** Casting during an open trade is an explicit instruction to hand it over, so none of the distribution rules apply to that slot. They still govern the automatic fill.
- **A stack already sitting in the trade window may not accept merged items.** When it does not, each later cast lands in a fresh bag slot and is offered separately, so a long casting session can consume the six trade slots. `PlaceStack` reporting the window full ends the pass rather than looping; a slot it merely declines to lift is left for the next bag update.
- **`FillTrade` will not shape a stack while a watch is armed.** A split or merge makes a bag slot appear or grow, and `PlaceConjured` offers any slot that did since its snapshot, so it would hand the result over as though the player had just cast it. That check is why `conjureWatch` is declared with the module's other state at the top of `Dispenser.lua` rather than beside `PlaceConjured`.

Placement and the missing-stack refill share the one `OnBagUpdate` handler, which writes the firing back through `ns:LogEventNow` when either path acts, since the event log excludes `BAG_UPDATE` as a firehose. Do not reintroduce a merge-partials step ahead of the fill: it would make a mid-trade cast wait for a full stack, which is the problem this design exists to remove. Merging is the fill's own step, sized to what is owed.

## Bag Moves

`Features/Bag-Moves.lua` holds the only two ways this add-on writes to a bag, a merge and a split. Both exist because a trade slot takes a whole bag slot: the fill hands over slots, so the bags have to already hold slots of the right size. The fill drives both, through `ns.MergeSlots`, `ns.MergePartials` and `ns.SplitToCursor`, to shape the one slot it is about to hand over. The merge runs once more on its own, just after a trade window closes; that is the only bag write that happens outside a fill.

Both follow the same rules, learned the hard way in sibling add-on Consumable-Connoisseur's Restocker: **never move against a locked slot, and never leave an item stranded on the cursor.** A stranded cursor is what makes the *next* split fail with "Couldn't split those items". Neither reports success, only that a move was issued; the server has the last word, so the caller re-scans on the bag update that follows. Empty slots are always found with `GetContainerItemInfo`, which is nil only for a genuinely empty slot: a container's free-slot *count* can disagree with its per-slot contents, and `GetContainerItemLink` is also nil for an item that is merely uncached.

### Post-Trade Restack

A conjure drops its items into a fresh bag slot rather than topping up the stack already there, and the fill fragments its own stacks besides -- breaking a 7 to find 5 leaves a 2 behind. `RestackPass` merges those back together so the next fill has whole stacks to reach for.

**It runs in exactly one place: just after `TRADE_CLOSED`.** Nothing listens to bag updates, and that is the whole design rather than an optimization. Driven off `BAG_UPDATE_DELAYED` it would fire every time the player touches their own bags, merging the separate stacks they had just built by hand to give someone and taking manual splits off the cursor -- the cursor does not reliably read as occupied in the frame a split is issued, so a guard that reads it once per pass cannot see them.

**Scope.** Only items the player has configured: the built-in collections through `ns.ITEM_TO_COLLECTION`, plus user-added IDs from `ns.db.profile.Items`, which are keyed by numeric item ID. Rearranging the rest of someone's bags is not this add-on's business. Full stacks and items that do not stack are left out, since neither can absorb anything, and an uncached max stack is skipped rather than guessed.

**Convergence without a bag hook.** `ns.MergePartials` pairs one item's unlocked partials off fullest-first, smallest onto largest, working inwards, so a single pass only halves them: four loose slots become two. With no bag update to re-enter on, each pass schedules the next one `RESTACK_SETTLE` (0.5s) later **only if it actually issued a merge**, so the chain ends by itself the moment there is nothing left to do. The first pass waits out the same settle, so the closing trade's own bag changes have landed before anything is measured. `RESTACK_MAX_PASSES` (5) is a backstop, not the usual exit.

**Five guards, and each abandons the chain rather than deferring it**, because every one of them means the bags stopped being the add-on's to tidy: `Dispense` off, `RestackBags` off, in combat, a trade open again, or something on the cursor. Reading the master as well as its own switch is the sub-option rule: the control hides when `Dispense` is off, and nothing may act from behind a hidden control. Ticking `RestackBags` on deliberately does **not** kick a pass, since tidying the bags the instant a checkbox is ticked is the surprise this shape exists to avoid. `ns.MergePartials` re-reads the cursor before every individual merge as well, since a pass-level check goes stale the moment the player picks something up.

**The cursor dance.** `C_Container.PickupContainerItem(src)` then `C_Container.PickupContainerItem(dst)` merges what fits and leaves any remainder on the cursor. A third `C_Container.PickupContainerItem(src)` puts that back into the now-empty source slot, and `ClearCursor` closes out. Both trailing calls no-op when the merge was clean.

### Portion

Two primitives rather than one call, because where the split lands is the caller's business and the difference is a whole server round trip. `ns.SplitToCursor(bag, slot, count)` asks the client to split `count` off onto the cursor; `ns.StowCursorItem()` parks whatever the cursor ends up holding in an empty bag slot. `PortionIntoBag` in `Dispenser.lua` is the only caller and always runs the pair together. Together they are what lets one potion out of a stack of five go, and the reason every per-class number can be an item count rather than a stack count.

**`SplitToCursor` does not promise the cursor holds `count`.** Nothing can: `GetCursorInfo` names the item and never the amount, and the source slot has not reliably updated by the next line. The design does not need the promise. A portion goes into a *bag*, the next scan reports what actually landed, and the whole-slot rule places nothing larger than what is still owed, so a client that hands back the whole stack has only moved a stack between bag slots. The trade window is deliberately not involved: dropping a just-split stack straight into it would save a round trip while staking everything on a count nothing can read, and getting that wrong puts a whole stack in front of a partner who was owed two.

**One split entry point, and no check that it landed.** `C_Container.SplitContainerItem` is the only split path; there is no legacy fallback. Nothing verifies that the client honored the count, because nothing can: the cursor does not reliably read as occupied in the frame the split was issued, so an empty cursor there proves nothing. Treating it as a no-op and asking again is what puts a red "Couldn't split those items" on screen, the second call landing on a slot the first had already locked while the trade filled correctly regardless.

This runs **with a trade open**, which is the whole point. It never touches a slot already offered (those are locked), and `FillTrade` will not call it while a conjure is waiting to be placed.

Order of operations: refuse if the source is locked, if `count` is the slot's whole contents (the client refuses that split, and the caller should have placed the slot whole), or if anything is already on the cursor, all three checked *before* the stack is disturbed. Then split, and only afterwards go looking for somewhere to put it. `StowCursorItem` tries **every** empty slot rather than just the first, because a profession bag has empty slots that will not take a potion and a refused drop is silent. If nothing takes it, `ClearCursor` puts it back.

**A refusal is detected, never inferred.** `SplitToCursor` returns false only when nothing reached the cursor at all. That is the one signal available in the same frame that means anything: a fill that is merely still short proves nothing, because a pass running before the move settles is also still short, and reading the source slot back to decide would report perfectly good splits as refusals. While the event log is running, `SplitToCursor` records one `SPLIT` line through `ns:LogEventNow` carrying `asked`, `before`, `took` and `left`, captured as a clue for a bug report and explicitly not acted on.

**Three ceilings, because the retry is implicit.** A move -- split or merge -- is driven by the bag update it causes: move, re-fill, place. That is self-limiting while the server cooperates, but a move the server accepts and then bounces back is *also* a bag change, so a bouncing item would re-enter the fill forever, reshuffling the bags each pass. All three live in `Dispenser.lua` beside `ShapeStack` and reset on `TRADE_SHOW`.

- `lastShape[configId]` remembers the item's loose slot counts as they stood when its last move was issued. A move that lands always changes them (a split adds a slot, a merge removes one), so finding them unchanged once the move has had its settle window means the move bounced -- on Classic Era the split call has been seen moving the whole stack to a fresh slot, which leaves the same counts in different places. One bounce ends shaping for that item this trade. A refused split (nothing reached the cursor) does the same, so the notice is said once and not on every bag update.
- `shapeSettling[configId]` gives each move one second to land before the item is shaped again, handed over loose, or judged for a bounce; a slot that already matches is still placed whole meanwhile. On Forever a split takes several bag updates to land: the portion reads as an empty slot until the server confirms it, and the source slot can unlock with its old count first. Without the window a pass in that gap would split a second portion into the same still-empty-looking slot, or read the unchanged counts as a bounce and trade the loose 1 left over from 20, 20, 1 instead of the 3 on its way. `ScheduleSettleCheck` runs one more pass when the window closes, in case the move's last bag update came while it was still settling, and `StowCursorItem` skips any slot it dropped into within the last second for the same reason.
- `MAX_MOVES_PER_ITEM` (8) covers one merge and one split with room for a handful of loose scraps to be worked through.
- `MAX_MOVES_PER_TRADE` (24) is the backstop across every item. It is deliberately generous, since a legitimate fill cannot reach it, and it is per trade rather than per session because it exists to unwedge one bad trade, not to ration the day.

The bag-to-bag route is the path Connoisseur has proven, and it is the only route here: the portion lands in a bag, and the pass after it hands that slot over whole.

## Session Ledger

`Features/Session-Ledger.lua` keeps `sessionGiven[configKey][partnerKey] = items` in a file-local table that is **never saved**, so a reload or a logout starts every partner's budget over. That is the whole definition of "session" here. It reaches the fill through `ns.GivenThisSession`, `ns.CreditSession` and `ns.ResetSessionLedger`, and owns the per-trade cap-notice latch behind `ns.ClaimSessionCapNotice` / `ns.ResetSessionCapNotices` so the "they have had their share" line is said once per item per trade rather than once per bag update. The partner key comes from `ns.TradePartnerKey` and is captured into `ns.State.Trade.Partner` at `TRADE_SHOW`, because `UnitName("NPC")` is already gone by the time the trade closes.

The cap is counted in individual items and simply clamps the fill's target, so the fill hands over no more than what is left of the budget. `CountOffered` returns what is already sitting in the window, charged against the budget before the fill adds to it, because the credit only happens on a completed trade and without it a re-fill would let the same offer through twice. A trade that fails after the player accepted is credited anyway, spending budget the partner never received; for a cap, erring toward giving less is the safe direction.

## Group Spares

`Features/Group-Spares.lua` puts what a player would hand over onto their unit tooltip, for party and raid members and always for the player themselves.

**What travels.** `ns.BuildTooltipSnapshot` (`Features/Inventory-Scanner.lua`) lists every item on the player's Dispensed Items list that they have something to give away, **net of the item's reserve** (`ns.GetItemReserve`), with anything down to 0 left out. The number beside a name is a promise to whoever reads it, and a reserve is the player saying that part of the stack is not on offer, so the tooltip counts the same way the macro and the fill do. The reserve guards the best-overall rank, which is the entry a collection reports here, so it is the same arithmetic in all three places. Two more rules apply, for the same reason the reserve does, that the tooltip must never advertise what the fill would refuse: `Distribute`, because an item gated to instances is not a rule about who deserves it but a statement that it is not on offer at all right now, and the player-class filter, because a character the item is switched off for never hands it over at all. An instance-only consumable listed out in the world, or mage water listed on a warlock, invites a whisper the fill would turn down. `GuildiesOnly` is deliberately *not* applied here: it is a fact about the trade partner, not about the player, so there is no one to test it against until a trade opens. **Per-class counts are the other thing not applied**: they shape a single trade, where this is the whole stash on offer, so an item whose counts are all 0 still lists.

A collection is reported as the best rank on hand, the same item the fill would reach for, so a receiver names and colors the row from `GetItemInfo` without knowing collections exist. Soulbound copies of a user-added item are excluded, since they cannot be traded at all.

**One composed offer, cached.** `ComposeOffer` builds the offer from that snapshot, and `BuildOffer` holds it in `cachedOffer`; the player's own tooltip and the broadcast both read that one table, so they cannot disagree. The cache matters because the client rebuilds a hovered unit tooltip about five times a second, and uncached each refresh walked every bag slot for an answer that had not moved. `ScheduleBroadcast` is the single place it is dropped, ahead of the debounce early-out, since every trigger that schedules a broadcast is one that could have changed the offer.

**Wire format.** `<chunk>/<total>|<itemId>:<count>;..` on `ns.ADDON_MESSAGE_PREFIX`. An item whose quantity is switched off adds a third field, `<itemId>:<count>:0`, left out otherwise so the common case stays short. A warlock also sends `H:<rank>` (with the same optional `:0`), which is not an item and so cannot collide with an item chunk. The payload budget is `ns.CHAT_MESSAGE_MAX_LENGTH` less 25 bytes of headroom for the header this file prepends; a player with many configured items overruns one message, and a silently truncated list is worse than a slow one. A receiver resets its buffer on chunk 1, so a broadcast that restarts mid-way replaces rather than merges.

**When it sends.** Debounced by 2 seconds off `BAG_UPDATE_DELAYED`, `GROUP_ROSTER_UPDATE` (someone who just joined has heard nothing yet; one that arrives in combat is replayed on `PLAYER_REGEN_ENABLED`), `PLAYER_ENTERING_WORLD`, `SPELLS_CHANGED` (a talent change moves the healthstone rank), and any change to what is on offer through `ns.RefreshGiveaways`, including the `Dispense` master toggle from the options panel or the mini-map button. Never ungrouped, never in combat, and never a list with either of `ShowInventoryTooltips` (the master) or `ShareInventory` off, since sharing is a sub-option of reading and the master gates both. Switching either off broadcasts one empty offer to clear the group rather than falling silent on a stale list.

**An unchanged payload is not sent.** `lastBroadcast` holds the encoded messages joined into one string and `lastChannel` the channel they went to; a broadcast matching both returns before sending. Bags settle far more often than the giveaway list changes, and the client throttles addon traffic, so a party of dispensers repeating an identical list through a dungeon's worth of looting delays each other's real updates. Anything that must reach the group regardless of the payload clears `lastBroadcast` first: `GROUP_ROSTER_UPDATE`, so a new member hears the current list, and `ns.RefreshGroupSpares`, since a rule change can alter what a list means without altering the list.

**`Dispense` off means nothing is on offer.** `ComposeOffer` returns empty, which drops the block from the player's own tooltip and sends one empty broadcast to clear them from everyone else's. That empty offer is covered by the unchanged-payload rule like any other, so it goes out once and is not repeated. The announcement macro and the bag-item tooltip line follow the same rule, so all three advertising surfaces go quiet together.

**What is kept.** `receivedSpares[playerKey]` is runtime only, so nothing another player sends is ever written to disk, and it is emptied for anyone who leaves the group, along with any half-received broadcast in `incoming`. Player keys are `Name-Realm` throughout, which is how `CHAT_MSG_ADDON` reports its sender; `UnitKey` fills in the local realm and strips its spaces to match. The prune walks real unit tokens (`party1..4` plus the player, or `raid1..40`) rather than looking players up by a spelled name, so the whole feature rests on one assumption: that `UnitKey`'s output matches the sender spelling.

**One branded line.** The block's header comes from `ns.BuildBrandedLine` (`Features/Announcements.lua`), the same builder `ns.PrintMessage` uses, so a chat print and a tooltip header can never brand the add-on differently. Rows lead with `ROW_INDENT` and keep the item's quality color, where a plain label elsewhere would be silver.

**The warlock healthstone row.** Before Wrath, a stone made at 0, 1 or 2 points of Improved Healthstone was three *different* unique items, so a raid could carry one of each. That is why each rank in `ns.COLLECTIONS.WarlockHealthstone` has three entries with matching rank and level but heals 10% apart. Which rank a warlock took is therefore something the raid coordinates around, so the tooltip states it whether or not a stone is in their bags.

The rank comes from `ns.HEALTHSTONE_TALENT_SPELLS` (`18692`, `18693`): talents grant passive spells, so the highest one known (by `ns.IsSpellLearned`) is the rank taken. That keeps it locale-independent, unlike reading talent names. Healthstone items are folded out of the normal rows into this one, but only for a warlock; a priest carrying a stone someone gave them lists it as an ordinary item.

**The count preference travels with the talent**, not with a carried stone: a warlock holding none sends no healthstone item, and the row still has to know whether to print its `0`. With the per-item quantity switch off (the shipped default) the row reads `Healthstone (Rank 2/2)` with no number at all.

**Two tooltip paths, picked by what the client has.** Where `TooltipDataProcessor` exists (Forever, and TBC Anniversary) the block rides a Unit post-call gated to `GameTooltip`; Era has no `TooltipDataProcessor`, so there it is `GameTooltip:HookScript("OnTooltipSetUnit")`. Forever has no `OnTooltipSetUnit` script at all, and hooking it there throws, which takes the rest of the login sequence down with it. The chosen path is recorded in `ns.unitTooltipPath`, which the context report prints.

## Bag Item Tooltips

`Features/Item-Tooltips.lua` appends one branded line to a carried bag item's tooltip when that item is set to be given out, so the player can see what the add-on will hand over without opening the panel. Read-only: it reports the same two answers the fill reads, through the same helpers.

**Which items.** `ns.GetItemConfigKey` (`Features/Utilities.lua`, shared with the fill) says whether the item is configured at all, and `ns.IsItemActiveForPlayer` whether it is switched on for the class being played. A warlock holding conjured water gets no line, because that item is mage-only and would never leave their bags. Everything is gated on the master `Dispense` switch as well, and on `ShowBagTooltips`.

**Which line.** An item that stacks also names the post-trade tidy-up, but only while `RestackBags` is on: the line is a statement about what will happen to the player's bags, so it reads the same key `CanRestack` does rather than promising a pass that has been switched off. A cold item cache reads as non-stacking rather than guessing: the shorter line is true either way, where promising to combine stacks of something that cannot stack is not.

**Two hook paths, and why the line lands last.** Where the client exposes `TooltipDataProcessor` (Forever, and TBC Anniversary) the line rides an Item post-call gated to carried bag slots; on Era the live path is a `hooksecurefunc` on `GameTooltip:SetBagItem`. The chosen path is recorded in `ns.bagTooltipPath`. Only one is ever active, so the line cannot double. Hooking the *setter* rather than the shared `OnTooltipSetItem` script is what keeps the line alive when a heavy tooltip add-on clears and re-fills the tooltip. `ns.SetupItemTooltips` is installed from `Features/Core.lua` at `PLAYER_LOGIN` behind a `C_Timer.After(0, ...)`, so every other add-on's own login setup has finished and our secure hook wraps the outermost wrapper they installed. That is what puts the line at the bottom of a crowded tooltip. Running outermost also means the tooltip is already sized and shown, so the hook re-`Show()`s it when it added a line, or the line would draw outside the frame.

**Bag scoping.** The `SetBagItem` path is bag-scoped by its own arguments, with bank bags excluded by an `ns.LAST_BAG_INDEX` range check, so it needs no owner sniffing and keeps working under replacement bag add-ons. Only the `TooltipDataProcessor` path needs `GetCarriedBagSlot`, since it fires for every item tooltip including merchant, bank and chat links.

## Announcement Macro

Water Dispenser never calls `SendChatMessage`. Instead `Features/Announcements.lua` keeps a single per-character macro named `- Dispenser` in sync, and the player clicks it to broadcast their giveaway list. The file therefore has no send path, only `ns.PrintMessage`, and no `ns:Announce`-style sender should be added back.

The lifecycle runs through `SyncMacroState`, invoked through a debounced `ScheduleUpdate` (250 ms) on `BAG_UPDATE_DELAYED`, `GROUP_ROSTER_UPDATE`, `PLAYER_ENTERING_WORLD`, the combat-end retry, and `ns.RefreshAnnouncementMacro`, which the options panels reach through `ns.RefreshGiveaways` after a settings change. `SyncMacroState` reads `ns.db.profile.Announcements.Enabled` and converges:

- Enabled and missing: silent `CreateMacro` into the per-character slot (`1`), so each alt gets its own body.
- Enabled and present: silent `EditMacro` with a fresh body, and only when the body actually changed. Bags settle far more often than the giveaway list does, so `lastMacroBody` skips the write entirely otherwise.
- Disabled and present: `DeleteMacro`, and print `CHAT_MACRO_DELETED`.

`macroFullWarned` latches the "all character macro slots are in use" warning to once per slot-exhaustion run. The body comes from `ns.BuildAnnouncementSnapshot` through `BuildMacroBody`, in `ns.BUILTIN_ORDER` and then user items by name, honoring the master `Dispense` switch, each item's reserve, its `Distribute` gate, its player-class filter, and `IncludeQuantity`. With `Dispense` off the snapshot is empty, so the body is empty and firing the macro does nothing; the macro's existence stays governed by `Announcements.Enabled` alone, and the Announcements panel's preview says so through `OPTIONS_ANNOUNCEMENTS_PREVIEW_DISPENSE_OFF` rather than the generic empty notice.

**`ns.RefreshGiveaways` (`Features/Utilities.lua`) is the single entry point** for "what I have to give away just changed". It refreshes the macro body and the group broadcast together, so a new call site cannot remember one and forget the other.

**`ns.SetDispense` (`Features/Dispenser.lua`) is the single entry point** for the master Dispense switch, which has two front ends: the toggle on the Dispense panel and the mini-map button's left-click. It writes the setting, calls `ns.RefreshGiveaways`, and calls `NotifyChange` on the Dispense panel so a panel left open repaints when the mini-map button flips it.

### Message Template and Truncation

The sentence is a **single locale template with one `%s`**, not a set of concatenated fragments:

```lua
L["ANNOUNCEMENTS_BODY"] = "I have %s. Open trade!"
```

`BodyTemplateParts` splits it at the `%s` into a head and a tail, and a template with no `%s` degrades to lead-only rather than erroring. That shape exists so translators control word order: Korean renders with an empty head and the whole sentence in the tail, putting the item list first and the verb last, which a fixed intro and outro pair made impossible.

`BuildMacroBody` prepends the channel slash (`/i`, `/raid`, `/p` or `/s`, resolved by `ns.GetGroupChatChannel` with instance chat first so a battleground raid posts to instance chat), then lays down `channel + marker + title + " // " + head` as a single lead. `AnnouncementPrefix` leaves the marker off on WoW Forever, which blocks raid-marker tokens in chat, and keeps the rest of the format. If the full message fits the ceiling it is used as-is, the item parts joined with commas and the localized `ANNOUNCEMENTS_AND` before the last. If not, the lead is laid down once and whole item parts are appended with `, ` joiners while the running total stays within the ceiling minus the ` ...` reserve; the first part that would overflow stops the loop, ` ...` closes the message, and the template's tail is dropped. Truncation happens only at **part boundaries**, never inside an item link (which the client rejects) and never through a comma search, since item names can contain commas.

The ceiling is `ns.CHAT_MESSAGE_MAX_LENGTH` (255) and is measured in **bytes** with `#body`, per Style Guide → MESSAGES → Message Length: byte length is never smaller than character length, so a `#body` guard cannot overflow either the chat unit or the macro unit. Never convert that to a character count. With item hyperlinks averaging 50 to 60 bytes, truncation kicks in around three or four items. Walk that worst case in ruRU before changing the body composition.

The Announcements panel previews `ns.BuildAnnouncementMessage`, the same message without the channel slash and before any truncation, so a long list previews in full.

The macro name is deliberately short: WoW silently truncates macro names past 16 characters, so `- Dispenser` (11) was chosen over `- Water Dispenser` (17), and the leading `- ` sorts it to the top of the macro list.

## Dispensed Items Panel

`Options/Options-Dispensed-Items.lua` is the largest panel file, and most of its size is layout working around what AceConfig does not offer.

**The item tree.** Each configured item is one flat page in the sidebar, built-ins first in `ns.BUILTIN_ORDER` and then user items by name, with Add an Item last. A page opens with its amounts (the grid, then the Maximum per Session and Reserve rows) and then its settings (`Distribute`, `GuildiesOnly`, `FactorLevel` for user items only, `IncludeQuantity`, the player-class filter, and Remove for user items only, confirmed). A tree node's own non-group args feed the content pane and nothing is nested underneath, so no item draws an expand toggle. `TreeSpacer` puts a blank, `disabled` group between entries, because AceGUI stacks tree lines at a fixed height with no spacing property. AceConfig arg keys must be strings, so user items (keyed by numeric item ID in the database) are encoded as `item_<id>` and decoded back.

**The pane has its own row width.** This is the add-on's one `childGroups = "tree"` panel, so its rows are laid out in the tree's content pane, which is narrower than the options frame. A row built to the shared `ns.OPTIONS_ROW_WIDTH` (3.4) overflows it, and AceGUI wraps an overflowing row rather than clipping it, which strands a caption on a line above its own control. Every row that pairs cells is built to `PANEL_ROW_WIDTH` (2.4) instead -- the class cell and three scope cells, the two amount rows, the Distribute caption and dropdown, the Add an Item picker and its button -- so they all end in the same column.

**The grid.** AceConfig has no table widget, so a class per row and a scope per column is built from fixed-width cells pinned inside one unnamed `inline` group per row. Laid out flat, the cells would pack onto whatever space is left on the line and the columns would drift apart. Each cell closes over its item, scope and class rather than reading them back from the info path, because inside the row's group the path ends at the group's own arg key.

**Every amount is a free-typed count of individual items.** Dropdowns were fine while a number meant a stack, but counting items pushes the useful range past a hundred and no ladder short enough to pick from covers both "1 potion" and "120 water". Blank reads as zero, so clearing a field says "never", and anything that is not a number is rejected by `validate` rather than silently becoming one. `ns.OptionsValidateCount` also enforces the per-item ceiling, which is 1 for a collection carrying `Unique = true`. Every other box accepts any number and `ns.OptionsParseCount` clamps it to `NUMBER_MAX` (1000) on the way in -- a sanity stop, not a refusal, so it is applied silently.

**`ns.NUMBER_BOX_WIDGET_TYPE`** (`Options/Options-Utilities.lua`, named from `ns.LOCALE_NAME`) is a registered AceGUI widget type wrapping the stock EditBox constructor, purely to relabel its accept button from Blizzard's "Okay" to "Apply" and widen it to fit. It is registered as its own type rather than patched into the library, because `Includes/Libraries/` is re-fetched at package time and the label is a global string that is not ours to change for every add-on in the client. It is guarded throughout, so a future AceGUI that renames its internals costs the label and nothing else. It lives in Options-Utilities alongside `ns.OptionsParseCount` and `ns.OptionsValidateCount`, the shared number parsing behind every box in the panel.

**The Everyone row writes straight through.** Each of its three boxes sets all nine classes in its own `set`, and there is no gather-on-click button. AceConfigDialog commits an `input` on `OnEnterPressed` and nothing else, so a button reading the three boxes would see only whichever ones happened to be committed. It shows what a column already agrees on and goes blank when the classes differ.

**The reserve and the session cap share one builder.** `AmountRow` produces both, so the pair cannot drift apart, and the number box is grayed rather than hidden when its toggle is off, because hiding it would reflow every row below it on each click. Arming a toggle re-parses the stored amount and falls back to 1 only when nothing numeric is stored, so a built-in that ships `KeepAtLeast = 0` still reads 0 the first time Enable Reserves is ticked.

**Distribute and Guildies Only differ in what they touch.** Distribute is about where the player is, so its `set` calls `ns.RefreshGiveaways`: an item gated to instances also drops off the macro and the player tooltip. Guildies Only is about who opened the trade, so its `set` refreshes nothing; it cannot change what is advertised, and the fill reads it at the next trade. The Distribute dropdown carries an explicit `sorting` built from `ns.DISTRIBUTE_MODES`, and its `get` reads through `ns.NormalizeDistribute`, so a profile still holding a retired value shows `Always`, the gate it actually runs under, rather than an empty box. Its caption and dropdown are two flat args rather than one inline group, because a group's content is narrower again than the pane and the pair would wrap inside it. Beneath Guildies Only a panel line names the guild the gate would hold the item for, or says the player has none, since a guildless player with the gate on gives the item to nobody. `FactorLevel` hides on built-in pages, with its spacer inlined so it hides too, because the partner-level cap is intrinsic there.

**Pickers carry an explicit `sorting`.** A `select` with none reaches AceGUI unordered, and AceGUI sorts the keys itself, reading a numeric-looking key as a number, so item-ID keys would list the Add an Item dropdown by item ID. `ns.GetAvailableItemsToAdd` returns the list sorted by name and `BuildAddableSorting` walks it in that order. Any future dropdown keyed by ID needs the same treatment.

`ns.RebuildDispensedItemsOptions` re-registers the rebuilt tree and calls `NotifyChange` on `ns.OPTIONS_REGISTRY.DispensedItems`. It runs after an item is added or removed, and on any profile switch. After an add, `AceConfigDialog:SelectGroup` opens the new item's page (its arg key, `item_<id>`), since every amount starts at 0 and that page is where the player sets them; after a remove it opens Add an Item (`addItem`), where the tree would otherwise fall back to its first entry. Both calls come after the rebuild, which is what puts the target page in the tree.

## Options Panel Routing

`ns:OpenOptionsPanel` (`Options/Options.lua`) backs both the `/wd` slash command and the mini-map button's Shift + Middle-Click. It routes **entirely by handles captured at registration**: `AddToBlizOptions` returns `(frame, categoryID)`, and both are stored on `ns.optionsFrames` when the root General panel registers.

The order is the combat gate, then `Settings.OpenToCategory(<captured categoryID>)`, then `AceConfigDialog:Open` as a genuine last resort that a correctly-routed add-on never reaches.

**Never resolve the category by display name.** AceConfigDialog aliases `category.ID` to the panel title *only* when `C_SettingsUtil.OpenSettingsPanel` is absent. Classic Era lacks that API, so a name lookup happens to work there and silently returns nil on any client that has it, which is why this failure mode passes casual testing on one flavor and breaks on the others.

Registration is deferred, never at file scope: the Profiles builder calls `AceDBOptions:GetOptionsTable(ns.db)`, and `ns.db` does not exist until `PLAYER_LOGIN`. Child order is fixed by the order of the `AddToBlizOptions` calls: General (root), Dispense, Dispensed Items, Announcements, Inventory Tooltips, Profiles second-to-last, Diagnostic Tools last. `Options-Dispenser.lua` and `Options-Dispensed-Items.lua` both pair with `Features/Dispenser.lua`: the Dispense switches (with the restack and warning sub-options) on one, the per-item config the fill reads on the other. `Options-Announcements.lua` pairs with `Announcements.lua`, and `Options-Group-Spares.lua`, titled Inventory Tooltips, carries the toggles for both `Group-Spares.lua` and `Item-Tooltips.lua`.

## Diagnostic Tools

`Features/Diagnostics.lua` backs the **Diagnostic Tools** panel with read-only reports for bug triage: the event log, an event-registration probe over `ns.EVENT_NAMES`, an API existence and shape probe (`ns.DIAGNOSTIC_API_CHECKS`), a Trade & Inventory Context probe, an installed-add-on list, a saved-variable dump, one Validate Data export per data file, a library-version list, and taint-log control. Every report opens with a header naming the client build, locale, `ns.FLAVOR` and `ns.DATA_FOLDER`.

The panel is gated by `ns.diagnostics`, an in-memory table that is **never persisted**: it starts `{ enabled = false, logging = false, log = nil }` at every login. Every gated section hides on that one condition, so the panel file defines a local `SectionHeader` builder that bakes the condition in rather than repeating it per widget. The dispatcher's logging tap is one boolean check before any allocation, so diagnostics off costs nothing measurable. The only state this panel ever writes is the `taintLog` CVar, through its explicit button.

**Off means off.** `ns:SetDiagnosticsEnabled(false)` stops the log and then releases the buffer and every report built while the panel was on, clearing `ns.diagnostics` by exception so a new report field cannot be forgotten. Only the two state flags survive, which is what keeps the panel's footprint zero once it is switched off. `ns:StopEventLog` deliberately keeps its capture: the Stop button exists so start, reproduce, stop, show returns a report rather than an empty one.

`ns.DIAGNOSTIC_EVENT_EXCLUDE` holds only `BAG_UPDATE`, which fires per slot change; `BAG_UPDATE_DELAYED` is kept because it fires once per settle. The fill writes its own trail through `ns:LogEventNow` instead: `OnBagUpdate` logs each `BAG_UPDATE` it acts on, `PlaceStack` each slot it skips and why (`PLACE`), `ShapeStack` each move it issues or judges bounced (`SHAPE`), `FillTrade` each item it holds while a move settles (`SHAPE`) and its cursor stand-down (`FILL`), and `SplitToCursor` each split (`SPLIT`), so an excluded firehose still leaves the entries the log exists to carry. Entries go into a fixed 500-entry ring, capped at 8 arguments and 255 bytes each, with pipes escaped after the length cut so a truncated argument cannot leave a dangling pipe. `CHAT_MSG_ADDON` carries every add-on's traffic in the group, so it is filtered at capture by prefix (`ns.MESSAGE_ID_FILTERED_EVENTS`, `ns:SuppressUncorrelatedMessage`): a firing on `ns.ADDON_MESSAGE_PREFIX`, the constant the Group Spares handler reads, logs in full; any other prefix is counted instead, and the report ends with a suppressed-traffic block, biggest first (`CHAT_MSG_ADDON(BigWigs) x469`). A firing with no prefix, or one hidden in combat on Forever, logs verbatim.

**Trade & Inventory Context** is this add-on's own context probe, aimed at the one report it actually gets: nothing fills. It prints the player's class and level; the trade partner's class, level and group state, both as captured at `TRADE_SHOW` and as read live; the resolved scope; the `Dispense` master and scope toggles with whether the resolved scope would auto-fill; and `RestackBags`. Per item it prints the active state, the normalized `Distribute` and whether it allows the item right now, `GuildiesOnly`, the reserve, the session cap and the scope's per-class counts, since a reserve or a gate silently stops a fill the counts say should happen. It then prints the highest rank the character knows in each spell table `ns.DIAGNOSTIC_SPELLS` names (each collection's `Spells` and `ns.HEALTHSTONE_TALENT_SPELLS`, by path, so no spell ID lives in the diagnostics file). The verdict comes from `ns.IsSpellLearned`, the same test the add-on uses (`IsSpellKnown` or `IsPlayerSpell`, since `IsSpellKnown` misses some trained ranks on Classic Era), and the Improved Healthstone rank comes from `ns.HealthstoneTalentRank`, the number the group broadcast sends. Last, it prints which path each tooltip hook took (`ns.unitTooltipPath`, `ns.bagTooltipPath`: `TooltipDataProcessor` wherever the client has it (Forever, and TBC Anniversary), the script and setter on Era), and `not hooked` when a hook never ran.

`ns:RunValidateData` walks `ns.DIAGNOSTIC_DATA_SOURCES`, one entry per static data file listing each table in it and whether its keys are item or spell IDs, and emits TSV of everything the client knows about every ID, flagging what it does not recognize with `NOT ON CLIENT`. That is how a renumbered or flavor-missing ID is caught without waiting for a player report. The manifest names each table by its path on `ns`, so a table the loaded folder never built prints one `TABLE MISSING` row, and the section is labeled with the folder this client loaded (`Forever/Collections.lua`). A clean run flags nothing: a flagged ID is a row in the wrong folder. A folder's copy is pruned only against a Validate Data run on its own client. `IdFrom = "value"` handles a plain array of IDs such as `ns.HEALTHSTONE_TALENT_SPELLS`. Item data loads asynchronously, so the walk runs in batches of 100 per tick with a progress line in the output, and a pending ID is requeued for the *next* tick rather than re-polled in the same frame (the cache cannot answer differently within one frame) until a retry cap flags it. Each run is stamped, so switching the panel off or pressing the button again stops an older run writing. Adding a data file means adding a manifest row, not a builder.

Strings here are developer-facing and deliberately live in `ns.DiagnosticsStrings` as plain English, never in `Locales/`.

## Saved Variables

Water Dispenser declares one SavedVariables global, `WaterDispenserDB`, holding the add-on's whole configuration, and hands it to AceDB-3.0 in `SetupDatabase` on `PLAYER_LOGIN`. There is no second table and no `SavedVariablesPerCharacter` line.

**Model: Simple.** `AceDB:New("WaterDispenserDB", ns.DATABASE_DEFAULTS, true)` passes the shared-Default third argument, so every character starts on one shared `"Default"` profile and per-character setups are opt-in through the stock Profiles panel. **Reset Profile therefore clears everything back to install defaults, the mini-map position and the whole Dispensed Items list included.** Nothing the add-on stores differs by character, which is what makes it Simple: everything lives in `ns.db.profile`, `ns.db.global` is unused, and a new setting is a profile key.

The shape is `ns.DATABASE_DEFAULTS` in `Data/Default-Settings.lua`: the general and panel toggles, the `minimap` table LibDBIcon reads, `Announcements`, and `Items`, the per-item configuration. `Items` is keyed by collection name for the built-ins and by numeric item ID for user-added items. Each entry carries its gates, its reserve and session cap beside their toggles, its player-class filter, and its `Solo` / `Group` / `Raid` per-class counts; a user-added entry also stores its `Name` and `Icon`.

Defaults come from `ns.DATABASE_DEFAULTS` and are applied by AceDB-3.0 when a scope is first accessed, and explicit user values, including `false`, are never overridden. Note that scalar and table defaults are physically copied into the saved table (`copyDefaults` via `rawset`); only `*`/`**` wildcard defaults resolve through metatables. This add-on defines no wildcard defaults.

That physical copy is load-bearing rather than incidental. `FillTrade` iterates `pairs(ns.db.profile.Items)`, which only sees the three built-in collections because their table defaults were copied into the profile the first time the scope was touched. Do not "optimize" that into a lazy metatable lookup.

There is no refill-on-empty logic and none is wanted. The built-in collections cannot be removed at all (`ns.RefreshCollectionMeta` re-stamps `NoRemove = true` after the database exists and on every profile switch), and a user-added item the player deleted, or a per-class count they zeroed, is a deliberate state that must survive a login untouched.

**`PlayerClasses` is stored explicitly.** A class the player unchecks is written as an explicit `false`, never `nil`, because a missing key gets re-supplied from the built-in default (`MageWater`'s `MAGE = true`, for instance), so an unchecked class must be a concrete `false` or it reappears next login.

A built-in collection's name and icon are never stored: `ns.GetItemConfigName` and `ns.GetItemConfigIcon` read them from `ns.COLLECTION_META` for a collection key, and from the saved config only for user-added items. A translated string therefore never reaches the player's file, and a rename or a new icon follows the add-on.

**`Distribute` values are part of the saved format.** The strings in `ns.DISTRIBUTE_MODES` (`"Always"`, `"Instance"`) are stored verbatim, and every read goes through `ns.NormalizeDistribute`, which folds anything else -- a missing value, or a `"Group"` or `"Raid"` saved before those modes were retired -- to `"Always"`. Nothing rewrites the file, so the same profile still opens on an older release.

`ns:OnProfileRefresh` is wired to `OnProfileChanged`, `OnProfileCopied` and `OnProfileReset` immediately after `AceDB:New`. It re-stamps the collection metadata, rebuilds the Dispensed Items tree, calls `ns.RefreshGiveaways`, fires `NotifyChange` for every registered panel so an open one repaints, and re-points LibDBIcon at the new profile's `minimap` table. That last step is load-bearing: LibDBIcon holds the table it was registered with, so without the `Refresh` the button keeps reading and writing the old profile's position until a `/reload`.

There is no migration chain. The AceDB conversion shipped without a bridge by maintainer decision, so a pre-conversion mini-map position and reserve amount fall back to defaults. A future change to the shape, name or scope of saved data ships its own 30-day migration (Style Guide → SAVED VARIABLES → Migration Windows), and a retired key is nil'd explicitly (`ns.db.profile.oldField = nil`).

## Adding a New Built-in Collection

1. Add the item and spell maps to `ns.COLLECTIONS` in every flavor folder's `Collections.lua`, with the rows that are true on that client (Style Guide → DATA → Flavor Folders); the Era and SoD files keep their `ns.IS_SOD` guards. Each `Items` row is a **positional array**: `[itemId] = {rank, level}` for water and food, `[itemId] = {rank, level, heal}` for healthstones, where `[1]` is the in-collection tier (1 = lowest, shared by horizontal variants), `[2]` the player level required to *use* it (authoritative, since `GetItemInfo`'s `itemMinLevel` is 0 or stale for some conjured items), and `[3]` the heal amount (healthstone only, informational). Each `Spells` row is `[spellId] = rank`. Keep the column-legend comment above each table and the originating SQL query above that. The reverse-lookups in `Features/Utilities.lua` read those columns **by index** (`meta[1]`, `meta[2]`), so any column-order change must be mirrored there.
2. Add an entry to `ns.COLLECTION_META` in `Data/Data.lua` with a `NameKey` and `Icon`, and set `Unique = true` for items that only ever trade 0 or 1. The key must match the `ns.COLLECTIONS` key.
3. Add the key to `ns.BUILTIN_ORDER`, in the position you want in the Dispensed Items sidebar and the announcement message. `ns.DIAGNOSTIC_SPELLS` is built from this list, so the context probe picks the collection's spells up with nothing more.
4. Add the default config to `ns.DATABASE_DEFAULTS.profile.Items[key]` in `Data/Default-Settings.lua`: `NoRemove = true`, `Distribute = "Always"`, `GuildiesOnly = false`, the other per-item flags, `PlayerClasses`, and the `Solo` / `Group` / `Raid` per-class counts. An unarmed reserve ships as `KeepAtLeastEnabled = false` with `KeepAtLeast = 0`.
5. Add `COLLECTIONS.<Key>.Items` and `COLLECTIONS.<Key>.Spells` to the `Collections.lua` entry's `Tables` in `ns.DIAGNOSTIC_DATA_SOURCES` (`Features/Diagnostics.lua`), so Validate Data covers them. A new data *file* gets its own entry.
6. Add the `L["ITEM_*"]` key and any new chat strings to `Locales/enUS.lua` only, then run the Localization pass to translate them. Watch length: announcement strings feed the 255-byte macro budget (Style Guide → MESSAGES → Message Length).

Mid-trade conjure placement picks up the new collection automatically once `Spells` is populated, since `ns.SPELL_TO_COLLECTION` and `ns.SPELL_TO_ITEMS` are both rebuilt from it. Ranks are matched by the `[1]` column, so a spell only ever arms the items of its own rank.

## Adding a New Registered Event

1. Call `ns.RegisterEvent(name, handler)` from the owning module's `Init*()`. Never register it on a frame of your own: it would escape both the diagnostics tap and `ns.EVENT_NAMES`.
2. If the add-on only cares about one unit, pass the unit tokens as trailing arguments so the dispatcher uses `RegisterUnitEvent`. Remember the filter is fixed by the first registration of that event name anywhere in the add-on.
3. If the event is a firehose that would bury the log, classify it rather than dropping it. One that carries an id the add-on acts on goes in `ns.MESSAGE_ID_FILTERED_EVENTS` with the id's argument position, with its correlated ids added to `CORRELATED_IDS` in `Features/Diagnostics.lua`, read from the same constant the handler uses. One with no id goes in `ns.DIAGNOSTIC_EVENT_EXCLUDE`, and the handler that acts on it writes those firings back through `ns:LogEventNow`.

The name lands in `ns.EVENT_NAMES` automatically, which is what the event-registration probe and the event log both read, so there is no second list to update. An event invalid on one client is skipped there by the dispatcher's `pcall` and reported by the probe.

## Adding a New Setting

1. Add the key and its default to `ns.DATABASE_DEFAULTS.profile` in `Data/Default-Settings.lua`. Under the Simple model every setting is a profile key; `ns.db.global` is unused.
2. Add the widget to the panel that owns the feature, reading and writing through `ns.OptionsGetDB` / `ns.OptionsSetDB` when the arg key is the setting name. AceDB applies the default when the scope is first accessed, so there is nothing to initialize.
3. A control that only means anything while a toggle above it is on goes in `ns.OptionsSubRow` with `hidden` on the row, never on the members, built with `ns.OptionsSubToggle` (which reads the profile directly, since inside the row's group the info path no longer ends at the setting name) and captioned through `ns.OptionsSubLabel`.
4. **If the control is hidden behind a master toggle, the code behind it must read that master too.** Nothing may act from behind a hidden control: `Features/Group-Spares.lua`'s `Broadcast` reads `ShowInventoryTooltips` as well as `ShareInventory`, and `CanRestack` reads `Dispense` as well as `RestackBags`, for exactly this reason.
5. If the setting changes what the player has to give away, call `ns.RefreshGiveaways()` in its `set`, so the macro body and the group broadcast move together. If it changes how much of an item goes out, call `ns.ResetSessionLedger(itemKey)` first. A per-item rule about the trade partner rather than the player, like `GuildiesOnly`, changes neither: it is read by the fill alone and must stay out of the two snapshots.
6. Add the label and its `desc` to `Locales/enUS.lua`; the Localization pass carries them into the other ten. The explanation lives in the mouseover `desc` and nowhere else (Style Guide → OPTIONS PANEL → Helper Text Lives in the Tooltip).

## Localization

Locale files live in `Locales/<locale>.lua`, each registered through AceLocale-3.0's `NewLocale("WaterDispenser", "<locale>")`, the literal `ns.LOCALE_NAME` pins. WoW ships a fixed locale set and **every supported locale file already exists**, so this is maintenance, not expansion. There is no "add a new locale" step.

- **`enUS.lua` is the source of truth** and the only file that passes the `true` default-fallback flag. Every string originates there, and AceLocale falls back to it through `__index` for any key a locale does not define. The other ten are owned by the Localization pass (`3 - Copy Cleanup & Localization Prompt.md`) and are never hand-edited during ordinary work. A renamed key leaves harmless orphans in the translated files until that pass runs, and a retired key name is never reused, because a stale translation of a reused name would silently win over the English fallback.
- **Placeholders** must match `enUS` in count, type and order per key in every locale, or the string crashes at runtime. The lines to watch are `FORMAT_ITEM_COUNT` (`%s`, `%d`), `CHAT_LOADED` (`%s`), `CHAT_SESSION_CAP_REACHED` (`%s`, `%d`), `CHAT_SPLIT_REFUSED` (`%s`, `%d`), `CHAT_NONE_ACTIVE_FOR_CLASS` (`%s`), `TOOLTIP_HEALTHSTONE` (`%d`, `%d`), `OPTIONS_ITEM_COUNT_TOO_HIGH` (`%d`), `OPTIONS_ITEM_GUILDIES_ONLY_HELP` (`%s`) and `ANNOUNCEMENTS_BODY` (`%s`). `FORMAT_ITEM_COUNT` is the shared item-and-count format, so it is reached from both the chat prints and the macro body and a locale that drops one of its two placeholders takes both down.
- **`ANNOUNCEMENTS_BODY` is a whole sentence around one `%s`**, deliberately, so translators control word order. Never split it into an intro and an outro pair; Korean puts the list first and the verb last.
- **One key family is composed at runtime.** The Distribute labels are read as `L["OPTIONS_ITEM_DISTRIBUTE_" .. mode:upper()]`, so a search for `OPTIONS_ITEM_DISTRIBUTE_INSTANCE` finds no call site. Those keys are not orphans, and adding a mode to `ns.DISTRIBUTE_MODES` means adding its key.
- **Overflow canary: ruRU.** The macro budget is measured in bytes, so the widest-encoding locale overflows first. The fixed lead alone (the party slash, marker, title, separator and template head) measures 49 bytes in Russian against 35 in English and 37 in German, so a body that fits in English can still truncate an item early in Russian. Check truncation against ruRU, not German.
- **Not localized:** `ns.DiagnosticsStrings` (developer-facing), the AceConfig registry names in `ns.OPTIONS_REGISTRY`, the `ns.DISTRIBUTE_MODES` values (`"Always"`, `"Instance"`, stored verbatim in the profile, with `OPTIONS_ITEM_DISTRIBUTE_*` as their labels), the `- Dispenser` macro name, and AceDB profile names.

Everything else, including the Spanish file pairing, is per Style Guide → LOCALIZATION and MESSAGES → Message Length.

## Common Pitfalls

- **Resolving the options category by display name**: returns nil on any client that has `C_SettingsUtil.OpenSettingsPanel`, so the panel silently opens as a floating window. It still works on Classic Era, so one-flavor testing misses it. Route by the captured `categoryID` and frame handle only.
- **Registering a `UNIT_*` event unfiltered**: wakes the shared dispatcher for every nearby unit and floods the diagnostic event log in a raid. Pass unit tokens to `ns.RegisterEvent`, and remember the filter is fixed by the first registration of that name.
- **Editing trade slots or macros in combat**: silently fails. The fill is abandoned outright, deliberately; the macro defers through `pendingCombatUpdate`.
- **Acting from behind a hidden control**: a sub-option hides with its master, so code reading only the sub-option keeps running with no visible way to stop it. `Broadcast` reads `ShowInventoryTooltips` as well as `ShareInventory`, and `CanRestack` reads `Dispense` as well as `RestackBags`.
- **Applying a partner rule to what is advertised**: `GuildiesOnly` is about whoever opens the trade, and there is no one to test it against until a trade opens. Applied in `ns.BuildTooltipSnapshot` or `ns.BuildAnnouncementSnapshot`, it would hide the item from guildies and strangers alike. Keep it in `FillTrade`, where `ns.IsItemAllowedForPartner` reads it.
- **Reading `Distribute` raw**: a profile can still hold a retired `"Group"` or `"Raid"`, which matches no mode. Compare it raw and the item is gated one way in one place and another way elsewhere, and the dropdown draws an empty box. Read it through `ns.NormalizeDistribute` or `ns.IsItemDistributableNow`.
- **Changing what is on offer without dropping the cached offer**: `cachedOffer` in `Group-Spares.lua` is dropped only by `ScheduleBroadcast`. A new trigger that changes the offer must reach it, normally through `ns.RefreshGiveaways`, or the player's own tooltip keeps showing the old list.
- **Reading `GetItemInfo` cold**: returns nil on a fresh client. The `OnSpellsChanged` prewarm covers collections; elsewhere prefer the cached `inventory[itemId]` over a fresh call.
- **Trusting `itemMinLevel` from `GetItemInfo`**: 0 for some conjured items. Use `ns.ITEM_LEVEL` for built-ins; the cached `Level` field already incorporates it.
- **Re-gating the collection rank cap on `FactorLevel`**: do not. For built-in collections the partner-level cap is intrinsic and the toggle is hidden on their panels; it governs only single-rank user-added items.
- **Trying to find out what is on the cursor**: you cannot. `GetCursorInfo` names the item and never the count, and the source slot has not reliably updated by the next line either. Splitting does work on Classic Era 1.15.9, and a portion does reach a trade partner, but only because nothing here ever needs the cursor's stack size: `SplitToCursor` puts the split in a *bag*, and the next scan reports what actually landed. Any design that reads the split back in the same frame reports refusals that never happened; any design that hands the cursor straight to a trade slot is trusting a number it cannot see. The answer arrives one bag update later, so wait for it.
- **Taking an item back out of a trade slot**: `ClickTradeButton` on an occupied slot is a server round trip, so the item is *not* on the cursor by the next line. A "place it, check it, pull it back" pattern strands it on the pointer, visible as an empty trade window with one slot glowing gold. There is no verify-after-placing; place only what is already known good.
- **Expecting a button to read a text box**: AceConfigDialog commits an `input` on `OnEnterPressed` and nothing else, so text the player typed but did not enter is invisible to the add-on. A widget that gathers several boxes on click sees only whichever ones happened to be committed. Anything typed must act on its own `set`; a button may only act on values already stored.
- **Reading a bag slot's count back too soon**: a move is not done when the call returns. The source slot locks for the round trip, and a second move issued against a locked slot is dropped with no error. One move per slot per pass, then re-scan on the bag update.
- **Counting a locked slot as available**: with a trade open, a locked slot is either already in the window or mid-move. The offer has already been charged against the target, so treating the slot as a candidate on top counts the items twice, and "placing" it is a no-op that reads as success. This is exactly how two Runecloth from a 20 and a 1 once handed over one: the 1 went in, a 1 was split off the 20, and the next pass "placed" the locked original instead of the new slot. Filter on `Locked` from the scan, treat locked slots the window does not account for as in flight, and let `PlaceStack` verify before it lifts.
- **Trusting the trade API right after placing**: `ClickTradeButton` is a round trip, and the bag update from the slot lock arrives first. A pass in that gap reads the target as unmet. `placedThisTrade` is the fill's own record for exactly that gap; keep it, and keep pruning it by lock state so a refused or withdrawn placement is forgotten.
- **Placing a loose slot because it fits**: a 1 inside a target of 2 fits, and placing it means the other 1 arrives in a second trade slot. Whole slots go in only when full or exact; everything else is shaped first. The fallback that hands loose slots over as they are runs only when the bags cannot be shaped at all.
- **Moving bag items without checking the cursor**: picking an item up locks its slot and fires a bag update, so a bag-update handler that moves items runs precisely while the player is dragging something. Check `GetCursorInfo()` first or you will drop what they were holding; `FillTrade` stands down on it before anything else.
- **Counting in stacks**: every number in the config and in `FillTrade` is a count of *individual items*. The two are silently interchangeable at 1, which is exactly how a default of "1" reads as sensible while meaning 20 water.
- **Retrying a bag move without a ceiling**: a split or merge is driven by the bag update it causes, so a client that bounces it back re-enters the fill forever. `lastShape` catches a move that changed nothing, `shapeSettling` keeps a slow move from being read as a bounce, `MAX_MOVES_PER_ITEM` caps the rest per item and `MAX_MOVES_PER_TRADE` per trade; keep all four.
- **Assuming a legacy global exists**: the Retail engine behind Forever has dropped the legacy item, spell and container globals (`GetItemInfo`, `GetSpellInfo`, `GetContainerItemInfo`), and every supported client ships the namespaced versions. So `C_Item`, `C_Spell`, `C_Container` and `C_AddOns` are called directly everywhere, with no existence guard and no legacy fallback.
- **Deriving the locale, LibDBIcon key or addon-message prefix from `ADDON_NAME`**: the installed folder is `Water-Dispenser` but the in-Lua identity is `WaterDispenser`. Reach for `ns.LOCALE_NAME`, or `ns.ADDON_MESSAGE_PREFIX` for the prefix; `Locales/*.lua` is the one place that cannot, since it loads before `Data/Data.lua` defines the constant.
- **Macro names past 16 characters or bodies past 255 bytes**: both silently truncated by the client. Keep `MACRO_NAME` short and rely on `BuildMacroBody`'s part-boundary truncation.
- **Editing `Includes/Libraries/` by hand**: the release workflow re-exports every external from `.pkgmeta` on each tag, so the edit is gone with the next release.

## Contributing

Issues and pull requests go on [GitHub](https://github.com/Gogo1951/Water-Dispenser/issues). Discussion happens on [Discord](https://discord.gg/eh8hKq992Q).

Bug reports should include the game version (Classic Era 1.15.x, Season of Discovery included; TBC Anniversary 2.5.x; or WoW Forever 1.60.x) and locale, class and level, reproduction steps, and the relevant macro body or chat output. The Diagnostic Tools panel produces copy-paste-ready reports for exactly this, and the **Trade & Inventory Context** probe answers most "nothing fills" reports on its own.

PR guidelines:

- **One concern per PR.** A locale update, a data change and a logic change are three PRs.
- **Match the existing style**: 80-character section dividers, the `ns` namespace, `L["UPPER_SNAKE_CASE"]` for every player-facing string, and the shared `ns.Options*` and `ns.GetColor` helpers. Run StyLua with its default configuration and a clean `luacheck .` before committing. The repo ships no `.stylua.toml`; do not add one.
- **New saved-variable fields** seed their defaults through `ns.DATABASE_DEFAULTS.profile` and let AceDB apply them. Never hand-merge, and never write `db.field = db.field or default`, which overwrites an explicit `false`.
- **Migration discipline.** A change to the shape, name or scope of saved data ships with a migration for the data players already have, tagged `-- MIGRATION (remove after YYYY-MM-DD)` 30 days past its release and deleted once that date passes. A retired key is nil'd explicitly.
- **Data changes land in every flavor folder they are true for**, and the PR says which copies changed, which were left, and why.
- **Output length**: any change to the announcement body or the group-spares wire format is measured in bytes against `ns.CHAT_MESSAGE_MAX_LENGTH`, in ruRU, with full item hyperlinks (Style Guide → MESSAGES → Message Length).
- **Strings**: add or change them in `Locales/enUS.lua` only; the Localization pass reconciles the other ten.
- **Run `README-Testing.md`** on every flavor the add-on ships a TOC for before tagging a release, WoW Forever included, and cite the step number when something fails.
- **Update this document** when the architecture, the file map or the saved-variable shape changes.
- **Commit and PR descriptions require a User Story.** Do not just say "I changed X" or "I fixed Y"; frame the change by who it helps and why.

  **Format:** *As a [role], I [needed / wanted] [behavior] so that [outcome]. This change [does X].*

  **Example:** *As a high-level mage trading a low-level player, I wanted Dispense to hand over water the partner can actually drink instead of my top rank, so the trade is not useless to them. This change caps the fill at the partner's level and cascades down through the usable ranks.*
