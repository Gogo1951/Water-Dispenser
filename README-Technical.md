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
├── Water-Dispenser.toc              Load order, one TOC for both flavors
├── Data/
│   ├── Data.lua                     Locale init, identity, palette, classes, links, options grid
│   ├── Collections.lua              The three built-in collections, their ranks, and the talent spells
│   └── Default-Settings.lua         The AceDB defaults table, profile scope only
├── Features/
│   ├── Core.lua                     Shared state, version, the dispatcher, AceDB init, the login sequence
│   ├── Utilities.lua                API shims, color accessor, collection reverse-lookups, amount readers
│   ├── Announcements.lua            Branded print, channel resolver, the auto-managed - Dispenser macro
│   ├── Inventory-Scanner.lua        Bag scan and cache, rank resolution, the two giveaway snapshots
│   ├── Bag-Moves.lua                The only bag writes: restacking partials, splitting an exact count off
│   ├── Dispenser.lua                Trade fill, conjure placement, the session ledger, the trade events
│   ├── Trade-UI.lua                 Clear and Fill buttons anchored beside the trade window
│   ├── Group-Spares.lua             Addon-message broadcast of the giveaway list, and the tooltip block
│   ├── Diagnostics.lua              Report builders, event log, API and event probes, validator, taint log
│   └── Minimap-Button.lua           LDB object, tooltip composition, click handlers
├── Includes/
│   ├── Images/
│   │   └── Water-Dispenser.tga      The TOC's IconTexture
│   └── Libraries/                   Vendored Ace3 stack plus LibDataBroker and LibDBIcon, never hand-edited
├── Locales/
│   ├── enUS.lua                     Source of truth, the only file passing AceLocale's default flag
│   └── deDE.lua … zhTW.lua          Ten translations, owned by the Localization pass
├── Options/
│   ├── Options-Utilities.lua        Widget helpers, the sub-option row builders, profile accessors
│   ├── Options-General.lua          Root panel: welcome, mini-map, Dispense and its sub-toggles, links
│   ├── Options-Dispensed-Items.lua  Item tree: the per-class grid, Everyone row, settings, Add an Item
│   ├── Options-Announcements.lua    Macro toggle with live preview, and the tooltip-sharing pair
│   ├── Options-Profiles.lua         Stock AceDBOptions-3.0 table, returned unmodified
│   ├── Options-Diagnostics.lua      Diagnostic Tools panel, registered last
│   └── Options.lua                  Registration, ns:OpenOptionsPanel, the /wd command
├── LICENSE                          MIT
├── README.md                        Player-facing documentation
├── README-Technical.md              This document
└── README-Testing.md                Manual test plan, run on both flavors before a release
```

`.github/`, `.gitattributes`, `.gitignore`, `.luacheckrc`, `.pkgmeta` and `LICENSE` are repo-only: the packager strips them, so an installed copy does not carry them. There are no deprecated or dead files, and everything under `Data/`, `Features/` and `Options/` is listed in the TOC and reachable at runtime. `Includes/Libraries/` is rewritten by the release workflow from `.pkgmeta` on every tag, so a hand edit there is overwritten by the next release.

The TOC load order is `Includes → Locales → Data → Features → Options`. Four ordering constraints are load-bearing:

- `Locales` loads before `Data`, because `Data/Data.lua` calls `GetLocale` and needs every `NewLocale` already registered.
- `Data/Collections.lua` loads before `Features/Utilities.lua`, which builds the reverse-lookups (`ns.ITEM_TO_COLLECTION`, `ns.ITEM_RANK`, `ns.ITEM_LEVEL`, `ns.SPELL_TO_COLLECTION`, `ns.SPELL_TO_ITEMS`) from it at file scope.
- Within `Options`, `Options-Utilities.lua` loads first because every panel file aliases its helpers at file scope, and `Options.lua` loads last so `ns.RegisterOptionsPanels` can see every `ns.Build*Options` builder.
- `Features/Bag-Moves.lua`'s `ns.InitRestacker` runs *after* `ns.InitDispenser` in the login sequence, not because of the TOC but because both claim `TRADE_CLOSED` and the restack pass reads the `ns.State.Trade.Active` flag the dispenser's handler clears.

## Architecture

### Event Loop

`Features/Core.lua` creates one hidden frame and a `ns.RegisterEvent(event, handler, ...)` dispatcher. Feature files never create their own frame and never call `RegisterEvent` on one. Several handlers may claim the same event: they are stored as a list and called in registration order, which is the login order in `Core.lua` (options panels, Dispenser, Announcements, Group Spares, mini-map, restacker).

Registration is wrapped in `pcall`, so an event name invalid on one client is skipped rather than erroring at load. Every name passed through `ns.RegisterEvent` is appended to `ns.EVENT_NAMES` in first-seen order, which is what the Diagnostic Tools event-registration probe and the event log both read, so neither can drift from what the add-on actually registers.

Trailing arguments are unit tokens: when present the dispatcher calls `RegisterUnitEvent` instead. **The filter is fixed by the first registration of that event name**, because `RegisterUnitEvent` binds per frame-and-event and every module shares this one frame.

The twelve registered events:

- `PLAYER_LOGIN` (Core) runs `SetupDatabase`, registers the options panels, calls each module's `Init*()`, and prints the welcome message if opted in. Saved variables are loaded and the item cache is warm enough for a first scan; nothing initializes at file scope.
- `TRADE_SHOW` / `TRADE_CLOSED` (Dispenser) capture or clear the partner's class, level, group state and key, attach or detach the side panel, and kick off the fill when the matching Dispense toggle is on.
- `TRADE_ACCEPT_UPDATE` (Dispenser) snapshots the offer the moment the **player** accepts, for crediting to the session ledger on `TRADE_CLOSED`. Waiting for both sides silently broke Maximum per Session: when the partner has already accepted and the player clicks second, the server completes the trade and `TRADE_CLOSED` arrives with no `(1, 1)` update ever firing, so nothing was credited and the cap never accumulated.
- `BAG_UPDATE` (Dispenser) places anything a mid-trade conjure just produced, and retries the fill when an earlier pass in *this* trade flagged `ns.State.MissingStack`. It returns immediately when neither applies.
- `SPELLS_CHANGED` (Dispenser, Group Spares) pre-warms the item cache and re-broadcasts the giveaway list, since a talent change moves a warlock's healthstone rank. It fires on login and on any spellbook change, including learning a rank, so it covers the prewarm alone; `LEARNED_SPELL_IN_TAB` is deliberately not registered as a companion, and is not a valid event on TBC Anniversary.
- `UNIT_SPELLCAST_SUCCEEDED`, **filtered to `"player"`** (Dispenser), arms the conjure watch. Without the filter this fires for every nearby unit, which in a raid both wastes dispatcher work in combat and floods the diagnostic event log.
- `BAG_UPDATE_DELAYED` (Announcements, Group Spares, Bag-Moves) is the debounced bag trigger: it fires once after a batch settles, where `BAG_UPDATE` fires per slot change. The restack is self-driving on it, because each merge is itself a bag change.
- `GROUP_ROSTER_UPDATE` (Announcements, Group Spares) rewrites the macro's channel slash, prunes anyone who left, and re-broadcasts for whoever just joined.
- `PLAYER_ENTERING_WORLD` (Announcements, Group Spares) is the first sync once item names are cached. Nothing that touches saved variables hangs off it, since it refires on every loading screen.
- `PLAYER_REGEN_ENABLED` (Announcements, Bag-Moves) replays a macro update combat deferred and runs the restack pass combat made the module skip. Nothing in `Dispenser.lua` listens: a fill blocked by combat is abandoned, not queued.
- `CHAT_MSG_ADDON` (Group Spares) receives another member's giveaway list on the `WaterDispenser` prefix.

There is no `PLAYER_REGEN_DISABLED` handler. Nothing needs to react to combat starting; the protected paths below check `InCombatLockdown` when they run.

### Combat Lockdown

**Nothing about a trade is deferred.** `ns.FillTrade` and `ns.ClearTrade` check `ns.IsInCombat()` and abandon the attempt, printing `CHAT_COMBAT_BLOCKED` when `CombatNotifications` is on. There is no pending flag and no replay: a trade window does not survive a fight, so queueing work for combat end buys a message nobody needed. `OnBagUpdate` drops the conjure watch on the same check, silently, because a cast whose bag update lands mid-fight is stale by the time combat ends.

Two paths defer instead, and neither is a trade:

- `Features/Announcements.lua` debounces macro updates by 250 ms, and if combat is active when the timer fires it sets `pendingCombatUpdate` and re-schedules on `PLAYER_REGEN_ENABLED`. `EditMacro` and `CreateMacro` are not strictly protected, but combat is a bad time to race the macro UI, and a stale macro body would otherwise persist until the next out-of-combat bag change.
- `Features/Bag-Moves.lua`'s restack stands down in combat and the same `PLAYER_REGEN_ENABLED` picks the pass back up.

`ns:OpenOptionsPanel` refuses outright: `InCombatLockdown()` is the first thing it does, it prints `CHAT_OPTIONS_IN_COMBAT` every time the player asks, and it returns rather than queueing. That one gate sits in front of the whole routing chain and is never duplicated in the slash handler or the mini-map click handler.

The group broadcast and the unit-tooltip block both stand down in combat as well: the client can drop addon traffic under load, and nobody is reading tooltips mid-fight.

The trade side panel needs no combat handling at all. It holds plain insecure buttons and stays parented to `UIParent`, so it shows and hides freely.

### Scan → Resolve → Fill

`ns.FillTrade(forced)` runs three phases per call, and can run several times per trade because every bag update re-enters it.

1. **Scan** (`ScanInventory`, `Features/Inventory-Scanner.lua`) walks every bag slot and stores per-slot `{Bag, Slot, Count, Full, Bound}` records in an `inventory` table keyed by item ID. Every occupied slot is tracked with no view taken on item class: the player decides what is dispensed, and a Consumable gate would silently hide trade goods and explosives. Items are tagged to their collection through `ns.ITEM_TO_COLLECTION` even when the player does not know the conjure spell, so a non-mage carrying conjured water still announces it as Conjured Water. `ScanInventory` returns `true` only when the inventory changed in a way that may affect a fill, so a non-forced retry can skip the work.

2. **Resolve** decides which held item IDs to give from, best first:
    - For built-in collections the partner-level cap is **intrinsic**: water or food above the partner's level is useless to them, so it applies regardless of `FactorLevel`, and the toggle is hidden on those panels. `UsableRankEntries(collectionKey, levelLimit)` returns every held rank the partner can use, highest first, so the fill cascades down when the best rank runs short. If nothing held is usable it falls back to the single lowest-rank stack on hand.
    - The reserve (`ns.GetItemReserve`) applies only to `BestRankItemId(collectionKey, nil)`, the player's top-tier stash. Lower ranks surfaced by the cap are pure giveaway material and are never reserved.
    - User-added items have one concrete ID and no alternate rank, so `FactorLevel` gates them directly: skipped outright when the partner is below the item's required level.
    - When `UnitLevel("NPC")` comes back nil, `-1` or `0` (unknown or still loading), `OnTradeShow` substitutes the player's own level plus ten rather than leaving the cap to lock everything out.

3. **Fill** iterates the resolved entries best-rank-first, covering `needed` **individual items**. Every number in this add-on is a count of items, never of stacks. On a non-forced pass it first subtracts what is already sitting in the trade window, read through `GetTradePlayerItemLink` / `GetTradePlayerItemInfo` and mapped back to its config key, so a mid-trade restock tops up instead of over-filling.

    Within a rank, whole bag slots that fit inside the remainder go first, **biggest first**: there are only six trade slots, and the biggest slots cover the most ground per slot spent. Whatever is left is smaller than any slot on hand, so the fill portions it. `PortionIntoBag` splits that many off into an empty bag slot and the *next* pass hands that slot over whole, which is why a fill can end with `MissingStack` set and no warning printed: the `portioned` flag distinguishes "in flight" from "genuinely short". The portion source is the **smallest** slot larger than the remainder, so breaking a 7 to find 5 leaves a full stack of 20 intact.

    The portion is capped by what the reserve still allows, so a target the bags cannot legally cover hands over everything it may rather than stopping at the last whole slot that happened to fit. Soulbound slots are skipped for user-added items but not for built-in collections, because conjured items report bound yet trade fine.

**Two per-item amounts sit behind toggles**, and both are read only through `Features/Utilities.lua` so a switched-off amount can never take effect: `ns.GetItemReserve` returns 0 unless `KeepAtLeastEnabled`, and `ns.GetItemSessionCap` returns nil unless `SessionCapEnabled`. The stored number lives beside its toggle rather than being zeroed, so switching off and back on returns the player's own value. Both are typed in freely, like every other amount in the panel.

**Changing an amount clears that item's session ledger.** `ns.ResetSessionLedger(configKey)` is called from every control that changes how much of an item goes out: the per-class grid, the Everyone row, and the Maximum per Session row. Credited giving is only meaningful against the limit it was measured under, so leaving it in place makes a cap raised from 2 to 10 hand over nothing until the next reload, which reads as the setting being ignored. It is keyed per item, so editing one never resets another.

Four notices explain an empty window, and they are deliberately gated differently:

| Notice | Gate | Latch |
|---|---|---|
| `CHAT_COMBAT_BLOCKED` | `CombatNotifications` (ships on) | None |
| `CHAT_SESSION_CAP_REACHED` | Ungated | Per item, per trade (`capNoticed`) |
| `CHAT_MISSING_STACK` | `MissingStackWarnings` (ships off) | None |
| `CHAT_SPLIT_REFUSED` | `MissingStackWarnings` | Per item, per trade (`portionTried`) |
| `CHAT_NONE_ACTIVE_FOR_CLASS` | `MissingStackWarnings`, forced fill only | Once per session (`noneActiveWarned`) |

The session-cap line is the one that is not opt-in. `MissingStackWarnings` ships off, and that line is the only explanation for a trade window the player expected to fill sitting empty; hiding it behind an opt-in makes an obedient cap look like a broken add-on.

If `needed > 0` after the loop, `ns.State.MissingStack` is set so the next out-of-combat `BAG_UPDATE` retries. **The flag lives and dies with one trade.** `OnTradeShow` clears it before deciding whether to fill, and `OnTradeClosed` clears it again. Left standing between trades it becomes a second, invisible way in, because `OnBagUpdate` fills on the flag alone: the next trade would top itself up on any bag change even though `OnTradeShow` had just declined to fill it.

### Item Data Caching

`GetItemInfo` returns nil on a fresh client for items it has not seen. Three mitigations, in the order they take effect:

1. `OnSpellsChanged` (`Features/Dispenser.lua`) touches `GetItemInfo` for every collection item ID and every configured user-added ID purely to seed the cache, so the first trade-time scan resolves synchronously. Every collection, not just the player's own, so a non-mage carrying mage water benefits too.
2. `ns.ITEM_LEVEL` (built in `Features/Utilities.lua` from `Data/Collections.lua`) overrides `itemMinLevel` for built-in collection items. Some conjured items report 0 even when they have a use level, so the static table keeps the partner-level cap correct regardless of cache state.
3. `ScanInventory` calls `C_Item.RequestLoadItemDataByID` for any uncached item and refuses to trust the other returns from that pass. A later scan backfills only the fields still missing, so a cold call can never blank out good data. An uncached max stack is treated as "full", so a genuine full stack is not skipped; the next warm scan corrects it.

The options panels read the inventory from several render callbacks in the same frame, so `ScanInventoryForDisplay` coalesces those into one scan per frame (`GetTime` is constant within a frame) while a reopen on a later frame still rescans. Trade and fill paths call `ScanInventory` directly and always scan fresh.

### Identity Constants

The installed folder and packaged name are `Water-Dispenser`, but the in-Lua identity is `ns.LOCALE_NAME = "WaterDispenser"` with no hyphen. That constant, never the `ADDON_NAME` vararg, is what every `NewLocale` / `GetLocale` call, the LibDataBroker object name, the LibDBIcon registration key and the addon-message prefix use, so they stay in lockstep. APIs keyed off the *packaged* add-on still take `ADDON_NAME`: `C_AddOns.GetAddOnMetadata` for the version, and `ns.OPTIONS_REGISTRY`, whose names are derived from it.

The addon-message prefix has its own reason to be the short form: the client caps prefixes at 16 characters, and `Water-Dispenser` fits only by luck.

### Colors

`ns.PALETTE` (`Data/Data.lua`) holds raw six-character hex with no `|cff` prefix. `Features/Utilities.lua` derives the escape-code table at file scope and exposes `ns.GetColor(key)`, which returns the prefix and falls back to `TEXT`; callers append `|r` themselves. `BODY` is white for descriptions and options body text, `HELP` is silver for helper text. The two are distinct roles rather than shades of one: sub-option captions and diagnostics hints use `HELP`, everything else descriptive uses `BODY`. `ns.ITEM_QUALITY_COLORS` is the parallel table the group-spares tooltip reads, indexed by the quality `GetItemInfo` returns.

## Trade Side Panel

`Features/Trade-UI.lua` builds a small frame holding two plain `UIPanelButtonTemplate` buttons, Clear and Fill. The panel stays parented to `UIParent` and only **anchors** to the right of Blizzard's `TradeFrame`, matching its frame strata so it sits clickable beside it. It is never re-parented into `TradeFrame`. Because the buttons are insecure, the panel shows and hides with no combat handling.

- **Clear** calls `ns.ClearTrade`, walking `MAX_TRADABLE_ITEMS` slots.
- **Fill** calls `ns.FillTrade(true)`. The `forced` flag clears the window first and bypasses the "did inventory change?" early-out, and it is also what arms the `CHAT_NONE_ACTIVE_FOR_CLASS` hint.

`OnTradeShow` calls `ns.TradeUI:Attach(TradeFrame)`; `OnTradeClosed` calls `ns.TradeUI:Detach()`.

Level-aware in-trade conjure buttons are deliberately absent: add-on-created secure cast buttons did not fire reliably on TBC Anniversary. Do not reintroduce them.

## Conjure During a Trade

Conjured items arrive in small partial stacks. Outside a trade `Features/Bag-Moves.lua` merges those back together, and the fill portions an exact amount when it has to, but neither helps while a trade is already open: the restack stands down, and portioning cannot invent items the player does not have yet. Casting mid-trade would therefore show nothing until enough casts had piled up, which reads as broken. `Features/Dispenser.lua` short-circuits that by offering the conjured slot directly.

A filtered `UNIT_SPELLCAST_SUCCEEDED` for any spell in `ns.SPELL_TO_COLLECTION`, during an active trade, calls `WatchConjure`. That snapshots every bag slot currently holding one of that spell's items into `conjureWatch[itemId][bag .. ":" .. slot] = count`. Which items a spell can produce comes from `ns.SPELL_TO_ITEMS`, built in `Features/Utilities.lua` by matching each spell's rank against the collection's item ranks, so a rank's horizontal variants are all watched.

The next `BAG_UPDATE` runs `PlaceConjured`: one bag walk, offering every watched slot whose count rose above its snapshot or that was not in the snapshot at all, then clearing the watch either way. Locked slots are skipped, because the move is still in flight server-side and the following bag update sees them settled.

Three consequences are deliberate:

- **The conjured slot bypasses the reserve, the session cap and the per-class counts.** Casting during an open trade is an explicit instruction to hand it over, so none of the distribution rules apply to that slot. They still govern the automatic fill.
- **A stack already sitting in the trade window may not accept merged items.** When it does not, each later cast lands in a fresh bag slot and is offered separately, so a long casting session can consume the six trade slots. `PlaceStack` returning false ends the pass rather than looping.
- **`FillTrade` will not portion while a watch is armed.** A split makes a bag slot appear, and `PlaceConjured` offers any slot that appeared since its snapshot, so it would hand the portion over as though the player had just cast it. That check is why `conjureWatch` is declared with the module's other state at the top of `Dispenser.lua` rather than beside `PlaceConjured`.

Placement and the missing-stack refill share the one `OnBagUpdate` handler, which writes the firing back through `ns:LogEventNow` when either path acts, since the event log excludes `BAG_UPDATE` as a firehose. Do not reintroduce a merge-partials step ahead of the fill: it made a mid-trade cast wait for a full stack, which is the problem this design exists to remove. Merging belongs between trades, where `Bag-Moves.lua` does it.

## Bag Moves

`Features/Bag-Moves.lua` holds the only two places this add-on writes to a bag. Both exist because a trade slot takes a whole bag slot: the fill hands over slots, so the bags have to already hold slots of the right size.

Both follow the same rules, learned the hard way in sibling add-on Consumable-Connoisseur's Restocker: **never move against a locked slot, and never leave an item stranded on the cursor.** A stranded cursor is what makes the *next* split fail with "Couldn't split those items". Neither reports success, only that a move was issued; the server has the last word, so the caller re-scans on the bag update that follows. Empty slots are always found with `GetContainerItemInfo`, which is nil only for a genuinely empty slot: a container's free-slot *count* can disagree with its per-slot contents, and `GetContainerItemLink` is also nil for an item that is merely uncached.

### Restack

A conjure drops its items into a fresh bag slot rather than topping up the stack already there, and nothing in the game tidies that up, so a mage ends a session holding 19 and 2 rather than 20 and 1. `Restack` merges them so the fill has whole stacks to reach for.

**Scope.** Only items the player has configured: the built-in collections through `ns.ITEM_TO_COLLECTION`, plus user-added IDs from `ns.db.profile.Items`, which are keyed by numeric item ID. Rearranging the rest of someone's bags is not this add-on's business. Full stacks and items that do not stack are left out, since neither can absorb anything, and an uncached max stack is skipped rather than guessed: unlike the scanner, a restack loses nothing by waiting for a warm cache.

**Every disjoint merge per pass.** `MergeDisjoint` pairs each item's unlocked partials off fullest-first, smallest onto largest, working inwards: the stack most likely to disappear entirely, onto the one closest to being usable. The "one move per pass" rule forbids reusing a *slot*, not batching, because merges over disjoint pairs cannot race each other, so pairing the whole list at once turns one round trip per merge into one per pass. The moves' own `BAG_UPDATE_DELAYED` drives the next pass, so no timer is needed. It terminates: a merge either empties its source or fills its destination, so every pass leaves strictly fewer partial stacks of that item than it found.

**The cursor dance.** `PickupContainerItem(src)` then `PickupContainerItem(dst)` merges what fits and leaves any remainder on the cursor. A third `PickupContainerItem(src)` puts that back into the now-empty source slot, and `ClearCursor` closes out. Both trailing calls no-op when the merge was clean.

**Five guards, and all five matter.**

- **`Dispense` off.** Combine Partial Stacks is a sub-option of the master toggle in the panel, so it hides when the master is off. Reading both here is what keeps it from carrying on invisibly once its control is out of sight.
- **`RestackBags` off.** The player said no.
- **In combat.** Bags are left alone, matching every other bag path here; `PLAYER_REGEN_ENABLED` picks the pass back up.
- **A trade is open.** Offered slots are locked, the conjure watch compares raw slot counts and would read a merge as a cast, and partials are already being offered as they land. `TRADE_CLOSED` runs the skipped pass, and this guard is also what keeps the restack on the right side of the merge-partials ban above.
- **Something on the cursor.** Picking an item up locks its slot, which is itself a bag update, so a pass fires exactly when the player is dragging something by hand. Without this guard the merge clears the cursor out from under them and drops what they were holding.

### Portion

Two primitives rather than one call, because where the split lands is the caller's business and the difference is a whole server round trip. `ns.SplitToCursor(bag, slot, count)` asks the client to split `count` off onto the cursor; `ns.StowCursorItem()` parks whatever the cursor ends up holding in an empty bag slot. `PortionIntoBag` in `Dispenser.lua` is the only caller and always runs the pair together. Together they are what lets one potion out of a stack of five go, and the reason every per-class number can be an item count rather than a stack count.

**`SplitToCursor` does not promise the cursor holds `count`.** Nothing can: `GetCursorInfo` names the item and never the amount, and the source slot has not reliably updated by the next line. The design does not need the promise. A portion goes into a *bag*, the next scan reports what actually landed, and the whole-slot rule places nothing larger than what is still owed, so a client that hands back the whole stack has only moved a stack between bag slots. The trade window is deliberately not involved: dropping a just-split stack straight into it would save a round trip while staking everything on a count nothing can read, and getting that wrong put a whole stack in front of a partner who was owed two.

**Two split entry points, tried in turn.** On Classic Era 1.15.9 `C_Container.SplitContainerItem` has been seen answering with the whole stack, and some legacy container globals do survive on that client, so `ns.SplitContainerItemLegacy` gets a go when the first attempt leaves the cursor empty. The two can never both land, because the second runs only when nothing reached the cursor.

Unlike the restack this runs **with a trade open**, which is the whole point. It never touches a slot already offered (those are locked), and `FillTrade` will not call it while a conjure is waiting to be placed.

Order of operations: refuse if the source is locked, if `count` is the slot's whole contents (the client refuses that split, and the caller should have placed the slot whole), or if anything is already on the cursor, all three checked *before* the stack is disturbed. Then split, and only afterwards go looking for somewhere to put it. `StowCursorItem` tries **every** empty slot rather than just the first, because a profession bag has empty slots that will not take a potion and a refused drop is silent. If nothing takes it, `ClearCursor` puts it back.

**A refusal is detected, never inferred.** `SplitToCursor` returns false only when nothing reached the cursor at all. That is the one signal available in the same frame that means anything: a fill that is merely still short proves nothing, because a pass running before the move settles is also still short, and reading the source slot back to decide would report perfectly good splits as refusals. While the event log is running, `SplitToCursor` records one `SPLIT` line through `ns:LogEventNow` carrying `asked`, `before` and `left`, captured as a clue for a bug report and explicitly not acted on.

**Two ceilings, because the retry is implicit.** A portion is driven by the bag update it causes: split, re-fill, place. That is self-limiting while the server cooperates, but a split the server accepts and then bounces back is *also* a bag change, so a bouncing item would re-enter the fill forever, reshuffling the bags each pass.

- `portionTried[configId]` allows **one portion attempt per item per trade**. If the client handed over the whole stack instead of the count asked for, the next pass finds the bags rearranged but still short, and would otherwise ask for another split, and another.
- `MAX_PORTIONS_PER_TRADE` (12, reset on `TRADE_SHOW`) is the backstop across every item. It is deliberately generous, since a legitimate fill cannot reach it, and it is per trade rather than per session because it exists to unwedge one bad trade, not to ration the day.

The bag-to-bag route is the path Connoisseur has proven, and it is the only route here: the portion lands in a bag, and the pass after it hands that slot over whole.

## Group Spares

`Features/Group-Spares.lua` puts what a player would hand over onto their unit tooltip, for party and raid members and always for the player themselves.

**What travels.** `ns.BuildTooltipSnapshot` (`Features/Inventory-Scanner.lua`) lists every item on the player's Dispensed Items list that they are actually carrying, with the plain bag count, and anything at 0 is left out. **No per-class counts, no reserve, no class filter**: configuring an item is the statement that it is up for grabs, so the only question left is how many they have. The single exception is `Distribute`, because an item gated to raids is not a rule about who deserves it but a statement that it is not on offer at all right now, and advertising it invites a whisper the fill would then refuse. An item whose per-class counts are all 0 still lists. This is deliberately *not* `ns.BuildAnnouncementSnapshot`, which subtracts the reserve and filters by the owner's class because the macro is a different promise.

A collection is reported as the best rank on hand, the same item the fill would reach for, so a receiver names and colors the row from `GetItemInfo` without knowing collections exist. Soulbound copies of a user-added item are excluded, since they cannot be traded at all.

**Wire format.** `<chunk>/<total>|<itemId>:<count>;..` on the `WaterDispenser` prefix. An item whose quantity is switched off adds a third field, `<itemId>:<count>:0`, left out otherwise so the common case stays short. A warlock also sends `H:<rank>` (with the same optional `:0`), which is not an item and so cannot collide with an item chunk. The payload budget is `ns.CHAT_MESSAGE_MAX_LENGTH` less 25 bytes of headroom for the header this file prepends; a player with many configured items overruns one message, and a silently truncated list is worse than a slow one. A receiver resets its buffer on chunk 1, so a broadcast that restarts mid-way replaces rather than merges.

**When it sends.** Debounced by 2 seconds off `BAG_UPDATE_DELAYED`, `GROUP_ROSTER_UPDATE` (someone who just joined has heard nothing yet), `PLAYER_ENTERING_WORLD`, `SPELLS_CHANGED` (a talent change moves the healthstone rank), and any change to what is on offer through `ns.RefreshGiveaways`, including the `Dispense` master toggle from the options panel or the mini-map button. Never ungrouped, never in combat, and never with either of `ShowInventoryTooltips` (the master) or `ShareInventory` off, since sharing is a sub-option of reading and the master gates both. Switching either off broadcasts one empty offer to clear the group rather than falling silent on a stale list.

**`Dispense` off means nothing is on offer.** `BuildOffer` returns empty, which drops the block from the player's own tooltip and sends one empty broadcast to clear them from everyone else's. The empty state is announced exactly once (`sentEmpty`); repeating it would be pure noise.

**What is kept.** `receivedSpares[playerKey]` is runtime only, so nothing another player sends is ever written to disk, and it is emptied for anyone who leaves the group. Player keys are `Name-Realm` throughout, which is how `CHAT_MSG_ADDON` reports its sender; `UnitKey` fills in the local realm and strips its spaces to match.

**One branded line.** The block's header comes from `ns.BuildBrandedLine` (`Features/Announcements.lua`), the same builder `ns.PrintMessage` uses, so a chat print and a tooltip header can never brand the add-on differently. Rows lead with `ROW_INDENT` and keep the item's quality color, where a plain label elsewhere would be silver.

**The warlock healthstone row.** Before Wrath, a stone made at 0, 1 or 2 points of Improved Healthstone was three *different* unique items, so a raid could carry one of each. That is why each rank in `ns.COLLECTIONS.WarlockHealthstone` has three entries with matching rank and level but heals 10% apart. Which rank a warlock took is therefore something the raid coordinates around, so the tooltip states it whether or not a stone is in their bags.

The rank comes from `ns.HEALTHSTONE_TALENT_SPELLS` (`18692`, `18693`): talents grant passive spells, so the highest one known is the rank taken. That keeps it locale-independent, unlike reading talent names. Healthstone items are folded out of the normal rows into this one, but only for a warlock; a priest carrying a stone someone gave them lists it as an ordinary item.

**The count preference travels with the talent**, not with a carried stone: a warlock holding none sends no healthstone item, and the row still has to know whether to print its `0`. With the per-item quantity switch off (the shipped default) the row reads `Healthstone (Rank 2/2)` with no number at all.

**One tooltip system.** `GameTooltip:HookScript("OnTooltipSetUnit")`, hooked once at init. `TooltipDataProcessor` arrived in Dragonflight and was never backported: the API probe reports it absent on Era 1.15.9, a client carrying every other modern namespace this add-on uses, so neither supported flavor has it. Do not add that branch without a client that actually passes the probe.

## Announcement Macro

Water Dispenser never calls `SendChatMessage`. Instead `Features/Announcements.lua` keeps a single per-character macro named `- Dispenser` in sync, and the player clicks it to broadcast their giveaway list. The file therefore has no send path, only `ns.PrintMessage`, and no `ns:Announce`-style sender should be added back.

The lifecycle runs through `SyncMacroState`, invoked through a debounced `ScheduleUpdate` (250 ms) on `BAG_UPDATE_DELAYED`, `GROUP_ROSTER_UPDATE`, `PLAYER_ENTERING_WORLD`, the combat-end retry, and `ns.RefreshAnnouncementMacro`, which the options panels call after a settings change. `SyncMacroState` reads `ns.db.profile.Announcements.Enabled` and converges:

- Enabled and missing: silent `CreateMacro` into the per-character slot (`1`), so each alt gets its own body.
- Enabled and present: silent `EditMacro` with a fresh body, and only when the body actually changed. Bags settle far more often than the giveaway list does, so `lastMacroBody` skips the write entirely otherwise.
- Disabled and present: `DeleteMacro`, and print `CHAT_MACRO_DELETED`.

`macroFullWarned` latches the "all character macro slots are in use" warning to once per slot-exhaustion run. The body comes from `ns.BuildAnnouncementSnapshot` through `BuildMacroBody`, in `ns.BUILTIN_ORDER` and then user items by name, honoring each item's reserve, its `Distribute` gate, its player-class filter, and `IncludeQuantity`.

**`ns.RefreshGiveaways` (`Features/Utilities.lua`) is the single entry point** for "what I have to give away just changed". It refreshes the macro body and the group broadcast together, so a new call site cannot remember one and forget the other.

### Message Template and Truncation

The sentence is a **single locale template with one `%s`**, not a set of concatenated fragments:

```lua
L["ANNOUNCEMENTS_BODY"] = "I have %s. Open trade!"
```

`BodyTemplateParts` splits it at the `%s` into a head and a tail, and a template with no `%s` degrades to lead-only rather than erroring. That shape exists so translators control word order: Korean renders with an empty head and the whole sentence in the tail, putting the item list first and the verb last, which a fixed intro and outro pair made impossible.

`BuildMacroBody` prepends the channel slash (`/i`, `/raid`, `/p` or `/s`, resolved by `ns.GetGroupChatChannel` with instance chat first so a battleground raid posts to instance chat), then lays down `channel + marker + title + " // " + head` as a single lead. If the full message fits the ceiling it is used as-is. If not, the lead is laid down once and whole item parts are appended with `, ` joiners while the running total stays within the ceiling minus the ` ...` reserve; the first part that would overflow stops the loop, ` ...` closes the message, and the template's tail is dropped. Truncation happens only at **part boundaries**, never inside an item link (which the client rejects) and never through a comma search, since item names can contain commas.

The ceiling is `ns.CHAT_MESSAGE_MAX_LENGTH` (255) and is measured in **bytes** with `#body`, per Style Guide → MESSAGES → Message Length: byte length is never smaller than character length, so a `#body` guard cannot overflow either the chat unit or the macro unit. Never convert that to a character count. With item hyperlinks averaging 50 to 60 bytes, truncation kicks in around three or four items. Walk that worst case in ruRU before changing the body composition.

The macro name is deliberately short: WoW silently truncates macro names past 16 characters, so `- Dispenser` (11) was chosen over `- Water Dispenser` (17), and the leading `- ` sorts it to the top of the macro list.

## Dispensed Items Panel

`Options/Options-Dispensed-Items.lua` is the largest panel file, and most of its size is layout working around what AceConfig does not offer.

**The item tree.** Each configured item is one flat page in the sidebar: its distribution grid, then its settings. A tree node's own non-group args feed the content pane and nothing is nested underneath, so no item draws an expand toggle. `TreeSpacer` puts a blank, `disabled` group between entries, because AceGUI stacks tree lines at a fixed height with no spacing property. AceConfig arg keys must be strings, so user items (keyed by numeric item ID in the database) are encoded as `item_<id>` and decoded back.

**The grid.** AceConfig has no table widget, so a class per row and a scope per column is built from fixed-width cells pinned inside one unnamed `inline` group per row. Widths total *less* than `ns.OPTIONS_ROW_WIDTH` on purpose: a row sitting exactly on the wrap boundary tips its last cell onto a line of its own.

**Every amount is a free-typed count of individual items.** Dropdowns were fine while a number meant a stack, but counting items pushes the useful range past a hundred and no ladder short enough to pick from covers both "1 potion" and "120 water". Blank reads as zero, so clearing a field says "never", and anything that is not a number is rejected by `validate` rather than silently becoming one. `ValidateCount` also enforces the per-item ceiling, which is 1 for a collection carrying `Unique = true` and uncapped otherwise.

**`WaterDispenserNumberBox`** is a registered AceGUI widget type wrapping the stock EditBox constructor, purely to relabel its accept button from Blizzard's "Okay" to "Apply" and widen it to fit. It is registered as its own type rather than patched into the library, because `Includes/Libraries/` is re-fetched at package time and the label is a global string that is not ours to change for every add-on in the client. It is guarded throughout, so a future AceGUI that renames its internals costs the label and nothing else.

**The Everyone row writes straight through.** Each of its three boxes sets all nine classes in its own `set`, and there is no gather-on-click button. AceConfigDialog commits an `input` on `OnEnterPressed` and nothing else, so a button reading the three boxes would see only whichever ones happened to be committed. It shows what a column already agrees on and goes blank when the classes differ.

**The reserve and the session cap share one builder.** `AmountRow` produces both, so the pair cannot drift apart, and the number box is greyed rather than hidden when its toggle is off, because hiding it would reflow every row below it on each click. Arming a toggle floors the stored amount at 1, so a reset profile does not show a 0 it never saved.

`ns.RebuildDispensedItemsOptions` re-registers the rebuilt tree and calls `NotifyChange` on `ns.OPTIONS_REGISTRY.DispensedItems`. It runs after an item is added or removed, and on any profile switch.

## Options Panel Routing

`ns:OpenOptionsPanel` (`Options/Options.lua`) backs both the `/wd` slash command and the mini-map button's Shift + Middle-Click. It routes **entirely by handles captured at registration**: `AddToBlizOptions` returns `(frame, categoryID)`, and both are stored on `ns.optionsFrames` when the root General panel registers.

The order is the combat gate, then `Settings.OpenToCategory(<captured categoryID>)`, then `AceConfigDialog:Open` as a genuine last resort that a correctly-routed add-on never reaches.

**Never resolve the category by display name.** AceConfigDialog aliases `category.ID` to the panel title *only* when `C_SettingsUtil.OpenSettingsPanel` is absent. Classic Era lacks that API, so a name lookup happens to work there and silently returns nil on any client that has it, which is why this failure mode passes casual testing on one flavor and breaks on the other.

Registration is deferred, never at file scope: the Profiles builder calls `AceDBOptions:GetOptionsTable(ns.db)`, and `ns.db` does not exist until `PLAYER_LOGIN`. Child order is fixed by the order of the `AddToBlizOptions` calls: General (root), Dispensed Items, Announcements, Profiles second-to-last, Diagnostic Tools last.

## Diagnostic Tools

`Features/Diagnostics.lua` backs the **Diagnostic Tools** panel with read-only reports for bug triage: the event log, an event-registration probe over `ns.EVENT_NAMES`, an API existence and shape probe (`ns.DIAGNOSTIC_API_CHECKS`), a Trade & Inventory Context probe, an installed-add-on list, a saved-variable dump, a library-version list, taint-log control, and a **Validate Data** export.

The panel is gated by `ns.diagnostics`, an in-memory table that is **never persisted**: it starts `{ enabled = false, logging = false, log = nil }` at every login. Every gated section hides on that one condition, so the panel file defines a local `SectionHeader` builder that bakes the condition in rather than repeating it per widget. The dispatcher's logging tap is one boolean check before any allocation, so diagnostics off costs nothing measurable. The only state this panel ever writes is the `taintLog` CVar, through its explicit button.

`ns.DIAGNOSTIC_EVENT_EXCLUDE` holds only `BAG_UPDATE`, which fires per slot change; `BAG_UPDATE_DELAYED` is kept because it fires once per settle. `OnBagUpdate` and `SplitToCursor` both write the firings they actually act on back through `ns:LogEventNow`, so an excluded firehose still leaves the entries the log exists to carry. Entries go into a fixed 500-entry ring, capped at 8 arguments and 255 bytes each, with pipes escaped after the length cut so a truncated argument cannot leave a dangling pipe.

**Trade & Inventory Context** is this add-on's own context probe, aimed at the one report it actually gets: nothing fills. It prints the player's class, the trade partner's class and level, the resolved scope, and per-item active state and counts, plus `IsPlayerSpell` and `IsSpellKnown` over `ns.DIAGNOSTIC_SPELLS`. Both spell checks are reported because `IsSpellKnown` misses some trained ranks on Classic Era.

`ns:RunValidateData` walks `ns.DIAGNOSTIC_DATA_SOURCES`, one entry per static data file listing each table in it and whether its keys are item or spell IDs, and emits TSV of everything the client knows about every ID, flagging what it does not recognize with `NOT ON CLIENT`. That is how a renumbered or flavor-missing ID is caught without waiting for a player report, and the TBC-only ranks in `Data/Collections.lua` are expected flags on Classic Era. `IdFrom = "value"` handles a plain array of IDs such as `ns.HEALTHSTONE_TALENT_SPELLS`. Item data loads asynchronously, so the walk runs in batches of 100 per tick with a progress line in the output, and a pending ID is requeued for the *next* tick rather than re-polled in the same frame (the cache cannot answer differently within one frame) until a retry cap flags it. Adding a data file means adding a manifest row, not a builder.

Strings here are developer-facing and deliberately live in `ns.DiagnosticsStrings` as plain English, never in `Locales/`.

## Saved Variables

Water Dispenser declares one SavedVariables global, `WaterDispenserDB`, and hands it to AceDB-3.0 in `SetupDatabase` on `PLAYER_LOGIN`. There is no second table and no `SavedVariablesPerCharacter` line.

**Model: Simple.** `AceDB:New("WaterDispenserDB", ns.DATABASE_DEFAULTS, true)` passes the shared-Default third argument, so every character starts on one shared `"Default"` profile and per-character setups are opt-in through the stock Profiles panel. **Reset Profile therefore clears everything back to install defaults, the mini-map position and the whole Dispensed Items list included.** That is the fact to check before adding a setting: everything lives in `ns.db.profile`, and `ns.db.global` is unused.

- **`ns.db.profile`** holds every user setting: `showWelcome`, the `minimap` table LibDBIcon reads, the `Dispense` master with its `DispenseSolo` / `DispenseGroup` / `DispenseRaid` scopes, `RestackBags`, `MissingStackWarnings`, `CombatNotifications`, `ShowInventoryTooltips`, `ShareInventory`, `Announcements.Enabled`, and `Items`. Each `Items` entry is keyed by collection name for built-ins and by numeric item ID for user-added items.
- **`ns.db.global`** is unused.

Defaults come from `ns.DATABASE_DEFAULTS` and are applied by AceDB-3.0 when a scope is first accessed, and explicit user values, including `false`, are never overridden. Note that scalar and table defaults are physically copied into the saved table (`copyDefaults` via `rawset`); only `*`/`**` wildcard defaults resolve through metatables. This add-on defines no wildcard defaults.

That physical copy is load-bearing rather than incidental. `FillTrade` iterates `pairs(ns.db.profile.Items)`, which only sees the three built-in collections because their table defaults were copied into the profile the first time the scope was touched. Do not "optimize" that into a lazy metatable lookup.

There is no refill-on-empty logic and none is wanted. The built-in collections cannot be removed at all (`ns.RefreshCollectionMeta` re-stamps `NoRemove = true` after the database exists and on every profile switch), and a user-added item the player deleted, or a per-class count they zeroed, is a deliberate state that must survive a login untouched.

**`PlayerClasses` is stored explicitly.** A class the player unchecks is written as an explicit `false`, never `nil`, because a missing key gets re-supplied from the built-in default (`MageWater`'s `MAGE = true`, for instance), so an unchecked class must be a concrete `false` or it reappears next login.

A built-in collection's name and icon are never stored: `ns.GetItemConfigName` and `ns.GetItemConfigIcon` read them from `ns.COLLECTION_META` for a collection key, and from the saved config only for user-added items. A translated string therefore never reaches the player's file, and a rename or a new icon follows the add-on.

`ns:OnProfileRefresh` is wired to `OnProfileChanged`, `OnProfileCopied` and `OnProfileReset` immediately after `AceDB:New`. It re-stamps the collection metadata, rebuilds the Dispensed Items tree, calls `ns.RefreshGiveaways`, fires `NotifyChange` for every registered panel so an open one repaints, and re-points LibDBIcon at the new profile's `minimap` table. That last step is load-bearing: LibDBIcon holds the table it was registered with, so without the `Refresh` the button keeps reading and writing the old profile's position until a `/reload`.

The add-on carries **no migration code and no migration bridges**, by maintainer decision. A retired key is nil'd explicitly (`ns.db.profile.oldField = nil`) and that is the whole story.

### Session Ledger

`Features/Dispenser.lua` keeps `sessionGiven[configKey][partnerKey] = items` in a file-local table that is **never saved**, so a reload or a logout starts every partner's budget over. That is the whole definition of "session" here. The partner key is captured into `ns.State.Trade.Partner` at `TRADE_SHOW`, because `UnitName("NPC")` is already gone by the time the trade closes.

The cap is counted in individual items while only whole stacks can move, so it stops *further* stacks once a partner reaches the number rather than trimming one: a cap of 2 on a potion stacking by 5 hands over one stack and nothing more. `CountOffered` returns what is already sitting in the window, charged against the budget before the fill adds to it, because the credit only happens on a completed trade and without it a re-fill would let the same offer through twice. A trade that fails after the player accepted is credited anyway, spending budget the partner never received; for a cap, erring toward giving less is the safe direction.

## Adding a New Built-in Collection

1. Add the item and spell maps to `ns.COLLECTIONS` in `Data/Collections.lua`. Each `Items` row is a **positional array**: `[itemId] = {rank, level}` for water and food, `[itemId] = {rank, level, heal}` for healthstones, where `[1]` is the in-collection tier (1 = lowest, shared by horizontal variants), `[2]` the player level required to *use* it (authoritative, since `GetItemInfo`'s `itemMinLevel` is 0 or stale for some conjured items), and `[3]` the heal amount (healthstone only, informational). Each `Spells` row is `[spellId] = rank`. Keep the column-legend comment above each table and the originating SQL query above that. The reverse-lookups in `Features/Utilities.lua` read those columns **by index** (`meta[1]`, `meta[2]`), so any column-order change must be mirrored there.
2. Add an entry to `ns.COLLECTION_META` with a `NameKey` and `Icon`, and set `Unique = true` for items that only ever trade 0 or 1. The key must match the `ns.COLLECTIONS` key.
3. Add the key to `ns.BUILTIN_ORDER`, in the position you want in the Dispensed Items sidebar and the announcement message.
4. Add the default config to `ns.DATABASE_DEFAULTS.profile.Items[key]` in `Data/Default-Settings.lua`: `NoRemove = true`, the per-item flags, `PlayerClasses`, and the `Solo` / `Group` / `Raid` per-class counts. An unarmed reserve ships as `KeepAtLeastEnabled = false` with `KeepAtLeast = 0`.
5. Add a `ns.DIAGNOSTIC_DATA_SOURCES` row for any new table, so Validate Data picks it up. A new data *file* gets its own entry; a new table in `Data/Collections.lua` goes in that entry's `Tables` list.
6. Add the `L["ITEM_*"]` key and any new chat strings to `Locales/enUS.lua` only, then run the Localization pass to translate them. Watch length: announcement strings feed the 255-byte macro budget (Style Guide → MESSAGES → Message Length).

Mid-trade conjure placement picks up the new collection automatically once `Spells` is populated, since `ns.SPELL_TO_COLLECTION` and `ns.SPELL_TO_ITEMS` are both rebuilt from it. Ranks are matched by the `[1]` column, so a spell only ever arms the items of its own rank.

## Adding a New Registered Event

1. Call `ns.RegisterEvent(name, handler)` from the owning module's `Init*()`. Never create a frame in a feature file: it would escape the diagnostics tap.
2. If the add-on only cares about one unit, pass the unit tokens as trailing arguments so the dispatcher uses `RegisterUnitEvent`. Remember the filter is fixed by the first registration of that event name anywhere in the add-on.
3. Only add an entry to `ns.DIAGNOSTIC_EVENT_EXCLUDE` if the event is a genuine firehose that would bury the log, and then have the handler that acts on it write those firings back through `ns:LogEventNow`.

The name lands in `ns.EVENT_NAMES` automatically, which is what the event-registration probe and the event log both read, so there is no second list to update.

## Adding a New Setting

1. Add the key and its default to `ns.DATABASE_DEFAULTS.profile` in `Data/Default-Settings.lua`. Under the Simple model every setting is a profile key; `ns.db.global` is unused.
2. Add the widget to the panel that owns the feature, reading and writing through `ns.OptionsGetDB` / `ns.OptionsSetDB` when the arg key is the setting name. AceDB applies the default when the scope is first accessed, so there is nothing to initialize.
3. A control that only means anything while a toggle above it is on goes in `ns.OptionsSubRow` with `hidden` on the row, never on the members, and its caption through `ns.OptionsSubLabel`.
4. **If the control is hidden behind a master toggle, the code behind it must read that master too.** Nothing may act from behind a hidden control: `Restack` reads `Dispense` as well as `RestackBags` for exactly this reason.
5. If the setting changes what the player has to give away, call `ns.RefreshGiveaways()` in its `set`, so the macro body and the group broadcast move together. If it changes how much of an item goes out, call `ns.ResetSessionLedger(itemKey)` first.
6. Add the label and its `desc` to `Locales/enUS.lua`; the Localization pass carries them into the other ten. The explanation lives in the mouseover `desc` and nowhere else (Style Guide → OPTIONS PANEL → Helper Text Lives in the Tooltip).

## Localization

Locale files live in `Locales/<locale>.lua`, each registered through AceLocale-3.0's `NewLocale(ns.LOCALE_NAME, "<locale>")`. WoW ships a fixed locale set and **every supported locale file already exists**, so this is maintenance, not expansion. There is no "add a new locale" step.

- **`enUS.lua` is the source of truth** and the only file that passes the `true` default-fallback flag. Every string originates there, and AceLocale falls back to it through `__index` for any key a locale does not define. The other ten are owned by the Localization pass (`3 - Copy Cleanup & Localization Prompt.md`) and are never hand-edited during ordinary work. A renamed key leaves harmless orphans in the translated files until that pass runs, and a retired key name is never reused, because a stale translation of a reused name would silently win over the English fallback.
- **Placeholders** must match `enUS` in count, type and order per key in every locale, or the string crashes at runtime. The lines to watch are `CHAT_LOADED` (`%s`), `CHAT_SESSION_CAP_REACHED` (`%s`, `%d`), `CHAT_SPLIT_REFUSED` (`%s`, `%d`), `CHAT_NONE_ACTIVE_FOR_CLASS` (`%s`), `TOOLTIP_HEALTHSTONE` (`%d`, `%d`), `OPTIONS_ITEM_COUNT_TOO_HIGH` (`%d`) and `ANNOUNCEMENTS_BODY` (`%s`).
- **`ANNOUNCEMENTS_BODY` is a whole sentence around one `%s`**, deliberately, so translators control word order. Never split it into an intro and an outro pair; Korean puts the list first and the verb last.
- **Overflow canary: ruRU.** The macro budget is measured in bytes, so the widest-encoding locale overflows first. The fixed lead alone (channel slash, marker, translated title, separator, template head) measures 49 bytes in Russian against 35 in English and 37 in German, so a body that fits in English can still truncate an item early in Russian. Check truncation against ruRU, not German.
- **Not localized:** `ns.DiagnosticsStrings` (developer-facing), the AceConfig registry names in `ns.OPTIONS_REGISTRY`, the `ns.DISTRIBUTE_MODES` values (`"Always"`, `"Group"`, `"Raid"`, stored verbatim in the profile, with `OPTIONS_ITEM_DISTRIBUTE_*` as their labels), the `- Dispenser` macro name, and AceDB profile names.

Everything else, including the Spanish file pairing, is per Style Guide → LOCALIZATION and MESSAGES → Message Length.

## Common Pitfalls

- **Resolving the options category by display name**: returns nil on any client that has `C_SettingsUtil.OpenSettingsPanel`, so the panel silently opens as a floating window. It still works on Classic Era, so one-flavor testing misses it. Route by the captured `categoryID` and frame handle only.
- **Registering a `UNIT_*` event unfiltered**: wakes the shared dispatcher for every nearby unit and floods the diagnostic event log in a raid. Pass unit tokens to `ns.RegisterEvent`, and remember the filter is fixed by the first registration of that name.
- **Editing trade slots or macros in combat**: silently fails. The fill is abandoned outright, deliberately; the macro defers through `pendingCombatUpdate`.
- **Acting from behind a hidden control**: a sub-option hides with its master, so code reading only the sub-option keeps running with no visible way to stop it. `Restack` reads `Dispense` as well as `RestackBags`.
- **Reading `GetItemInfo` cold**: returns nil on a fresh client. The `OnSpellsChanged` prewarm covers collections; elsewhere prefer the cached `inventory[itemId]` over a fresh call.
- **Trusting `itemMinLevel` from `GetItemInfo`**: 0 for some conjured items. Use `ns.ITEM_LEVEL` for built-ins; the cached `Level` field already incorporates it.
- **Re-gating the collection rank cap on `FactorLevel`**: do not. For built-in collections the partner-level cap is intrinsic and the toggle is hidden on their panels; it governs only single-rank user-added items.
- **Trying to find out what is on the cursor**: you cannot. `GetCursorInfo` names the item and never the count, and the source slot has not reliably updated by the next line either. Splitting does work on Classic Era 1.15.9, and a portion does reach a trade partner, but only because nothing here ever needs the cursor's stack size: `SplitToCursor` puts the split in a *bag*, and the next scan reports what actually landed. Any design that reads the split back in the same frame reports refusals that never happened; any design that hands the cursor straight to a trade slot is trusting a number it cannot see. The answer arrives one bag update later, so wait for it.
- **Taking an item back out of a trade slot**: `ClickTradeButton` on an occupied slot is a server round trip, so the item is *not* on the cursor by the next line. A "place it, check it, pull it back" pattern strands it on the pointer, visible as an empty trade window with one slot glowing gold. There is no verify-after-placing; place only what is already known good.
- **Expecting a button to read a text box**: AceConfigDialog commits an `input` on `OnEnterPressed` and nothing else, so text the player typed but did not enter is invisible to the add-on. A widget that gathers several boxes on click sees only whichever ones happened to be committed. Anything typed must act on its own `set`; a button may only act on values already stored.
- **Reading a bag slot's count back too soon**: a move is not done when the call returns. The source slot locks for the round trip, and a second move issued against a locked slot is dropped with no error. One move per pass, then re-scan on the bag update.
- **Moving bag items without checking the cursor**: picking an item up locks its slot and fires a bag update, so a bag-update handler that moves items runs precisely while the player is dragging something. Check `GetCursorInfo()` first or you will drop what they were holding.
- **Counting in stacks**: every number in the config and in `FillTrade` is a count of *individual items*. The two are silently interchangeable at 1, which is exactly how a default of "1" reads as sensible while meaning 20 water.
- **Retrying a portion without a ceiling**: a split is driven by the bag update it causes, so a client that bounces the split back re-enters the fill forever. `portionTried` caps it per item and `MAX_PORTIONS_PER_TRADE` caps it per trade; keep both.
- **Assuming a legacy global exists**: the `GetContainerNumSlots` and `PickupContainerItem` globals are gone on both target clients, so call `C_Container` through the shims in `Features/Utilities.lua`. `SplitContainerItem` is the exception, kept only as a second attempt when the modern call leaves the cursor empty.
- **Deriving the locale, LibDBIcon key or addon-message prefix from `ADDON_NAME`**: the folder is `Water-Dispenser` but the in-Lua identity is `WaterDispenser`. Use `ns.LOCALE_NAME`.
- **Macro names past 16 characters or bodies past 255 bytes**: both silently truncated by the client. Keep `MACRO_NAME` short and rely on `BuildMacroBody`'s part-boundary truncation.
- **Editing `Includes/Libraries/` by hand**: the release workflow re-exports every external from `.pkgmeta` on each tag, so the edit is gone with the next release.

## Contributing

Issues and pull requests go on [GitHub](https://github.com/Gogo1951/Water-Dispenser/issues). Discussion happens on [Discord](https://discord.gg/eh8hKq992Q).

Bug reports should include the game version (Classic Era 1.15.x or TBC Anniversary 2.5.x) and locale, class and level, reproduction steps, and the relevant macro body or chat output. The Diagnostic Tools panel produces copy-paste-ready reports for exactly this, and the **Trade & Inventory Context** probe answers most "nothing fills" reports on its own.

PR guidelines:

- **One concern per PR.** A locale update, a data change and a logic change are three PRs.
- **Match the existing style**: 80-character section dividers, the `ns` namespace, `L["UPPER_SNAKE_CASE"]` for every player-facing string, and the shared `ns.Options*` and `ns.GetColor` helpers. Run StyLua with its default configuration and a clean `luacheck .` before committing. The repo ships no `.stylua.toml`; do not add one.
- **New saved-variable fields** seed their defaults through `ns.DATABASE_DEFAULTS.profile` and let AceDB apply them. Never hand-merge, and never write `db.field = db.field or default`, which overwrites an explicit `false`.
- **No migration code.** The add-on ships none and none is wanted. A retired key is nil'd explicitly and that is the whole story.
- **Output length**: any change to the announcement body or the group-spares wire format is measured in bytes against `ns.CHAT_MESSAGE_MAX_LENGTH`, in ruRU, with full item hyperlinks (Style Guide → MESSAGES → Message Length).
- **Strings**: add or change them in `Locales/enUS.lua` only; the Localization pass reconciles the other ten.
- **Run `README-Testing.md`** on both flavors before tagging a release, and cite the step number when something fails.
- **Update this document** when the architecture, the file map or the saved-variable shape changes.
- **Commit and PR descriptions require a User Story.** Do not just say "I changed X" or "I fixed Y"; frame the change by who it helps and why.

  **Format:** *As a [role], I [needed / wanted] [behavior] so that [outcome]. This change [does X].*

  **Example:** *As a high-level mage trading a low-level player, I wanted Dispense to hand over water the partner can actually drink instead of my top rank, so the trade is not useless to them. This change caps the fill at the partner's level and cascades down through the usable ranks.*
