# Water Dispenser // Technical Reference

> Code map for working on Water Dispenser: where things live, how they connect, and the traps. Where this and the code disagree, the code wins. For players, see [README.md](https://github.com/Gogo1951/Water-Dispenser/blob/main/README.md).

## File Map

```text
Water-Dispenser/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── config.yml                 Started from Common-Core's starter, edited per add-on
│   │   ├── defect.yml                 Shared Common-Core copy
│   │   └── request.yml                Shared Common-Core copy
│   └── workflows/
│       ├── ci.yml                     Calls Common-Core: shared-file, syntax, luacheck and StyLua checks
│       ├── issue-labels.yml           Calls Common-Core: fills in missing issue labels
│       └── package.yml                Calls Common-Core: library refresh, then CurseForge and Wago upload on a tag
├── .gitattributes                     Shared Common-Core copy
├── .gitignore                         Shared Common-Core copy
├── .luacheckrc                        Lint config
├── .pkgmeta                           Externals; ignore list also strips Data/Wrath, Data/Mists, Data/Mainline
├── Water-Dispenser_Vanilla.toc        Classic Era; loads Data/Vanilla and Data/Discovery
├── Water-Dispenser_TBC.toc            TBC Anniversary
├── Water-Dispenser_Camelot.toc        WoW Forever
├── Data/
│   ├── Flavor.lua                     ns.FLAVOR from the TOC, ns.IS_DISCOVERY, ns.DATA_FOLDER
│   ├── Data.lua                       Locale init, identity constants, registry names, layout grid, palette, classes, collection meta
│   ├── Default-Settings.lua           ns.DATABASE_DEFAULTS, profile scope only
│   ├── Vanilla/
│   │   └── Collections-Vanilla.lua    ns.COLLECTIONS and ns.HEALTHSTONE_TALENT_SPELLS; returns early under Discovery
│   ├── Discovery/
│   │   └── Collections-Discovery.lua  Season of Discovery; returns early unless ns.IS_DISCOVERY
│   ├── TBC/
│   │   └── Collections-TBC.lua
│   ├── Camelot/
│   │   └── Collections-Camelot.lua
│   ├── Wrath/
│   │   └── Collections-Wrath.lua      Forward-prep: no TOC loads it, .pkgmeta strips it
│   ├── Mists/
│   │   └── Collections-Mists.lua      Forward-prep: no TOC loads it, .pkgmeta strips it
│   └── Mainline/
│       └── Collections-Mainline.lua   Forward-prep: no TOC loads it, .pkgmeta strips it
├── Diagnostics/                       Copied framework; Manifests.lua is this add-on's part
├── Features/
│   ├── Core.lua                       ns.State, version, the event dispatcher, AceDB setup, other-client prune, login sequence
│   ├── Utilities.lua                  Combat and hidden-value guards, colors, reverse-lookups, amount readers, item gates
│   ├── Announcements.lua              Branded print lines, group-channel resolver, the "- Dispenser" macro
│   ├── Inventory-Scanner.lua          Bag scan and cache, rank pickers, the macro and tooltip snapshots
│   ├── Bag-Moves.lua                  The only bag writes: merge, split, stow, and the post-trade restack
│   ├── Session-Ledger.lua             Per-partner session totals, partner key, cap-notice latch
│   ├── Trade-Status.lua               The trade panel's status line
│   ├── Stack-Shaping.lua              ns.ShapeStack, its move ceilings, bounce check and settle window
│   ├── Dispenser.lua                  The fill, placement, mid-trade conjure placement, trade events, ns.SetDispense
│   ├── Trade-UI.lua                   Clear and Fill buttons and the status line beside the trade window
│   ├── Conjure-Buttons.lua            Secure conjure buttons under Fill, ranked for the partner
│   ├── Group-Spares.lua               Addon-message broadcast of the offer, and the unit-tooltip block
│   ├── Item-Tooltips.lua              The bag-item tooltip line
│   └── Minimap-Button.lua             LDB launcher, tooltip with the Dispense Report, clicks
├── Includes/
│   ├── Images/
│   │   └── Water-Dispenser.tga        TOC icon
│   └── Libraries/                     Vendored; refreshed from .pkgmeta on every tag
├── Locales/
│   ├── enUS.lua                       Source strings
│   ├── deDE.lua
│   ├── esES.lua
│   ├── esMX.lua
│   ├── frFR.lua
│   ├── itIT.lua
│   ├── koKR.lua
│   ├── ptBR.lua
│   ├── ruRU.lua
│   ├── zhCN.lua
│   └── zhTW.lua
├── Options/
│   ├── Options-Utilities.lua          Shared row builders, sub-option rows, number parsing, the number-box widget
│   ├── Options-General.lua            Root panel; Features section mirrors four master switches
│   ├── Options-Dispenser.lua          Dispense master and its sub-toggles, Combat section
│   ├── Options-Dispensed-Items.lua    Item tree: per-class grid, amounts, gates, Add an Item
│   ├── Options-Announcements.lua      Macro switch and live preview
│   ├── Options-Group-Spares.lua       Inventory Tooltips panel (Group-Spares.lua and Item-Tooltips.lua)
│   ├── Options-Profiles.lua           Stock AceDBOptions-3.0 table
│   ├── Options-Feedback-Support.lua
│   └── Options.lua                    Registration, ns:OpenOptionsPanel, /wd
├── LICENSE
├── README.md
├── README-Notes.md
├── README-Technical.md
└── README-Testing.md
```

- No `Tests/` folder, so CI runs no offline tests.
- The three TOCs differ only in `## Interface`, `## X-Flavor` and their flavor-folder lines.
- `Diagnostics/Locale-Reports.lua` is the retired name of `Diagnostics/Localization-Reports.lua`; don't bring it back.
- Every flavor folder's `Collections-<Folder>.lua` declares the same two tables whole, `ns.COLLECTIONS` and `ns.HEALTHSTONE_TALENT_SPELLS`.

## Architecture

### Load Order

TOC blocks: `Includes → Locales → Data → Features → Diagnostics → Options`, with `Diagnostics/Options-Diagnostics.lua` inside the Options block just before `Options.lua`. Load-bearing constraints:

- `Locales` before `Data`: `Data/Data.lua` calls `GetLocale` on `ns.LOCALE_NAME`.
- `Data/Flavor.lua` first in Data: the Vanilla and Discovery data files both load on the Vanilla TOC and each returns early on `ns.IS_DISCOVERY`, so exactly one builds the tables.
- Flavor folder before `Features/Utilities.lua`, which builds `ns.ITEM_TO_COLLECTION`, `ns.ITEM_RANK`, `ns.ITEM_LEVEL`, `ns.SPELL_TO_COLLECTION`, `ns.SPELL_TO_ITEMS` and `ns.COLLECTION_NAME_ITEM_ID` at file scope. `Features/Conjure-Buttons.lua` builds its `RANKS` lists from those at file scope too.
- `Options-Utilities.lua` first in Options (panels alias its helpers at file scope); `Options.lua` last (`ns.RegisterOptionsPanels` needs every `ns.Build*Options`).
- Nothing touching `ns.db` runs at file scope; everything initializes from the `PLAYER_LOGIN` handler in `Features/Core.lua`.

### Event Loop

- One hidden frame in `Features/Core.lua`; feature files register through `ns.RegisterEvent(event, handler, ...)`, never on a frame of their own.
- Handlers per event are a list, called in registration order, which is the `Init*` order in the `PLAYER_LOGIN` handler: `ns.RegisterOptionsPanels`, `ns.InitDispenser`, `ns.InitConjureButtons`, `ns.InitAnnouncements`, `ns.InitGroupSpares`, `ns.InitMinimap`, `ns.InitRestacker`, then `ns.SetupItemTooltips` one frame later (`C_Timer.After(0, ...)`), then the welcome print.
- Ordering that matters: Conjure Buttons' `TRADE_SHOW` runs after the dispenser's, which attaches the panel they sit under. Bag Moves registers `TRADE_CLOSED` last, after the dispenser's handler has cleared `ns.State.Trade.Active`.
- Registration is `pcall`-guarded, so a name invalid on one client is skipped. The name is appended to `ns.EVENT_NAMES` first, in first-seen order, so the Event Registration probe still reports it as a failure. A name joins at its first registration, so a conditionally registered event is absent in sessions that never registered it.
- Trailing unit tokens switch to `RegisterUnitEvent`. The filter is fixed by the first registration of that name, since every module shares the frame.
- `ns.UnregisterEvent` drops one handler, releases the frame's registration once none is left, and keeps the name in `ns.EVENT_NAMES`.
- The dispatcher's diagnostics tap is one boolean check (`ns.diagnostics.logging`) before any work.

Registered events:

| Event | Owners | Does |
|---|---|---|
| `PLAYER_LOGIN` | Core | DB setup, panel registration, every `Init*` |
| `TRADE_SHOW` | Dispenser, Conjure Buttons | Capture partner, reset per-trade state, attach panel, maybe fill; place the conjure buttons |
| `TRADE_CLOSED` | Dispenser, Conjure Buttons, Bag Moves | Credit ledger, clear state, detach; hide buttons; arm the restack |
| `TRADE_ACCEPT_UPDATE` | Dispenser | Snapshot the offer on the player's own accept |
| `TRADE_PLAYER_ITEM_CHANGED` | Dispenser | Repaint the status line |
| `BAG_UPDATE` | Dispenser | Place a mid-trade conjure; retry a fill flagged by `ns.State.MissingStack` |
| `BAG_UPDATE_DELAYED` | Conjure Buttons, Announcements, Group Spares | The debounced bag trigger |
| `SPELLS_CHANGED` | Dispenser, Conjure Buttons, Group Spares | Item-cache prewarm; re-rank buttons mid-trade; rebroadcast (talent moves the healthstone rank) |
| `UNIT_SPELLCAST_SUCCEEDED` (`"player"`) | Dispenser | Arm the conjure watch |
| `GROUP_ROSTER_UPDATE` | Announcements, Group Spares | Channel slash; prune and rebroadcast |
| `PLAYER_ENTERING_WORLD` | Announcements, Group Spares | First sync once item names are cached; nothing touches saved variables here |
| `PLAYER_REGEN_ENABLED` | Conjure Buttons, Announcements, Group Spares | Replay what combat deferred |
| `CHAT_MSG_ADDON` | Group Spares | Receive a groupmate's offer |
| `GET_ITEM_INFO_RECEIVED` | Dispensed Items panel, Trade Status | Only while a Loading placeholder is pending; each unregisters itself when its pending set empties |

No `PLAYER_REGEN_DISABLED` handler: protected paths check `ns.IsInCombat()` when they run. `LEARNED_SPELL_IN_TAB` is deliberately not registered (redundant with `SPELLS_CHANGED`, invalid on TBC Anniversary).

### Combat Lockdown

**Refused, never queued:**

- `ns.FillTrade` and `ns.ClearTrade` abandon the attempt and print `CHAT_COMBAT_BLOCKED` when `CombatNotifications` is on. A trade window doesn't survive a fight, so there is nothing to replay; nothing in `Dispenser.lua` listens to `PLAYER_REGEN_ENABLED`.
- `OnBagUpdate` drops the conjure watch silently in combat (stale by combat end).
- The post-trade restack abandons its chain (`CanRestack`).
- `ns:OpenOptionsPanel`: the stock Combat Guard.
- The unit-tooltip block stands down (checked before `GetUnit`).

**Deferred to `PLAYER_REGEN_ENABLED`:**

- Conjure Buttons: `pendingHide` (the holder holds protected children). `ns.RefreshConjureButtons` returns in combat, and the holder's `OnUpdate` stops repositioning, so ranks, attributes, visibility and position change only out of combat.
- Announcements: the debounce timer firing in combat sets `pendingCombatUpdate`.
- Group Spares: `broadcastHeldForCombat` for a broadcast that comes due; `rosterChangedInCombat` for a roster change, because Forever can hide roster names in combat and a prune that can't read them drops real groupmates. A replayed roster change schedules its own broadcast, so only one goes out.

**Hidden values (Forever).** `ns.IsSecretValue` wraps `issecretvalue`. Checked before use in `OnSpellcastSucceeded` (spell ID), `OnAddonMessage` (every argument), `UnitKey` (name and realm), the unit-tooltip hook (the unit), and the event log (written as `<secret>`).

The trade side panel needs no combat handling: plain insecure buttons parented to `UIParent`.

### Main Pipeline: Scan → Resolve → Fill

`ns.FillTrade(forced)` in `Features/Dispenser.lua`. Re-entered by every relevant bag update, so it runs many times per trade.

**Entry.** `OnTradeShow` decides whether the automatic fill runs; Fill (`forced = true`) bypasses all of it. Stand-downs, each writing a `TRADE_STATUS_*` note rather than chat: `Dispense` off, the partner's scope toggle off (`DispenseSolo` / `DispenseGroup` / `DispenseRaid`), or `HoldForMasterLoot` with the player master looter (`ns.IsPlayerMasterLooter`) inside a party or raid instance. Then, inside `FillTrade`: no trade → `CHAT_NO_TRADE`; combat → refused; anything on the cursor → log `FILL skip=cursor`, set `ns.State.MissingStack` so the player's next drop (a bag update) re-runs the pass, and return.

**1. Scan** (`ns.ScanInventory`, `Features/Inventory-Scanner.lua`)

- Walks carried bags into `inventory[itemId] = { ..., Bags = { {Bag, Slot, Count, Full, Bound, Locked} } }`.
- Every occupied slot is tracked, no item-class gate (the player decides what is dispensed).
- Tags collection items via `ns.ITEM_TO_COLLECTION` even without the conjure spell.
- Returns true only when the inventory changed versus `fillBaseline`; a lock change with no count change counts, since a split slot can settle locked-then-unlocked across two updates. Non-forced passes return early on no change.

**2. Resolve** (per configured item, `pairs(ns.db.profile.Items)`)

- Gates: `ns.IsItemActiveForPlayer` (player-class filter), `ns.IsItemDistributableNow` (`Distribute`, about where the player is), `ns.IsItemAllowedForPartner` (`GuildiesOnly`, against `ns.State.Trade.Guild` read at `TRADE_SHOW`). Only the class filter feeds `activeForPlayer`, which drives the `CHAT_NONE_ACTIVE_FOR_CLASS` hint.
- Target: the item's count for the partner's class in the scope `PickScope` picks (`Solo` unless the partner is grouped with the player, then `Raid` or `Group` by `IsInRaid()`), minus what is already in the window.
- Session cap clamps the target (`ns.GetItemSessionCap` minus `ns.GivenThisSession` minus what's in the window).
- Built-in collections: `ns.UsableRankEntries(key, partnerLevel)` gives every held rank the partner can use, best first (cascade), else the single lowest rank held. The partner-level cap is intrinsic; `FactorLevel` doesn't apply and is hidden on their pages.
- The reserve (`ns.GetItemReserve`) guards only `ns.BestRankItemId(key, nil)`, the player's top rank; lower ranks are pure giveaway.
- User items: one concrete ID; `FactorLevel` skips the item outright when the partner is below its required level. Bound slots are skipped for user items only (conjured items report bound but trade).
- Unknown partner level (`nil`, `-1`, `0`) becomes the player's level plus ten in `OnTradeShow`.

**3. Fill**

- "Already in the window" = the larger per key of `CountOffered` (the trade API, which lags a placement by a server round trip) and `PendingOffer` (`placedThisTrade`, the fill's own record, pruned of any slot no longer locked). Each is a lower bound; both err toward giving less.
- Locked slots are never candidates. Locked slots beyond those the window accounts for are moves in flight: the rank sets `inFlight` and waits.
- Whole slots go in only when full (or stack size uncached) or exactly what is owed, biggest first. `PlaceStack` verifies before lifting (not locked, count still matches, cursor holds something after pickup) and returns `placed, full`; only `full` ends the pass.
- Still short: `ns.ShapeStack` builds one slot of exactly the remainder (capped at a full stack and at what the reserve allows) for the next pass to place whole. Skipped while the item is settling, and while a conjure watch is armed. If shaping is impossible, loose slots go over as they are.
- Short after all that: set `ns.State.MissingStack`, record a short note, and print `CHAT_MISSING_STACK` only with `MissingStackWarnings` on and nothing in flight.
- Ends with `ns.RefreshTradeStatus()`.

**`ns.State.MissingStack` lives and dies with one trade**: cleared in `OnTradeShow` and `OnTradeClosed`. `OnBagUpdate` fills on the flag alone, so a leftover flag would auto-fill the next trade past a declined `OnTradeShow`.

Notices that explain an empty window, gated differently on purpose:

| Notice | Gate | Latch |
|---|---|---|
| `CHAT_COMBAT_BLOCKED` | `CombatNotifications` | None |
| `CHAT_PLAYER_CAP_REACHED` | Ungated | Per item per trade (`ns.ClaimSessionCapNotice`) |
| `CHAT_MISSING_STACK` | `MissingStackWarnings`, never while `inFlight` | None |
| `CHAT_SPLIT_NEEDS_FULL_STACK` | `MissingStackWarnings` | Per item per trade (spends the item's move budget) |
| `CHAT_NONE_ACTIVE_FOR_CLASS` | `MissingStackWarnings`, forced fill only | Once per session |

A `Distribute` or `GuildiesOnly` gate that empties the window prints nothing; the status line says it.

### Caching

`C_Item.GetItemInfo` is nil on a cold cache:

- `OnSpellsChanged` (`Dispenser.lua`) touches every collection item and every user-added ID purely to warm the cache, so the first trade scan resolves.
- `ns.ITEM_LEVEL` overrides `itemMinLevel` for built-ins (some conjured items report 0); the scan's `Level` field already folds it in.
- `BuildInventory` calls `C_Item.RequestLoadItemDataByID` for an uncached item, distrusts that pass's other returns, and later scans backfill only missing fields. Uncached `StackSize` reads as `Full` so a real full stack isn't skipped.
- Names shown to the player are never stored: `ns.GetItemConfigName` returns the client's name or the `ITEM_LOADING` placeholder. Two places watch for the real name with a temporary `GET_ITEM_INFO_RECEIVED` handler and their own pending set: the Dispensed Items tree (`Options-Dispensed-Items.lua`, rebuilds since a name can change sort order) and the trade status line (`StatusItemName` in `Trade-Status.lua`, repaints).

Inventory cache (`Inventory-Scanner.lua`):

- `inventory` is rebuilt by every scan; `fillBaseline` is replaced only by the fill's own `ns.ScanInventory`. A display read mid-trade (macro, broadcast, mini-map hover) rebuilds `inventory` without making the fill's next bag update read "no change".
- `ScanInventoryForDisplay` coalesces display reads to one bag walk per frame (`GetTime` is constant within a frame). Trade paths always scan fresh.

Group Spares caches its composed offer (`cachedOffer`); see Group Spares.

### Trade Side Panel and Conjure Buttons

- `Features/Trade-UI.lua`: Clear (`ns.ClearTrade`) and Fill (`ns.FillTrade(true)`) in a frame parented to `UIParent`, anchored to the right of `TradeFrame` with its strata. Never re-parented into `TradeFrame`. Attached in `OnTradeShow` only when `ns.HasItemsForPlayer()`; Dispense off still shows it, since Fill is then the manual path.
- `ns.ClearTrade` wipes `placedThisTrade`, so the next pass reads the still-locked cleared slots as in flight and waits.
- **Status line** (`ns.RefreshTradeStatus`, `Trade-Status.lua`): never chat. With items in the window, `TRADE_STATUS_ADDED` over the window's own slots plus the first short note. Empty, `ns.State.Trade.Note` (trade-wide reason) else the first `HoldReasons` entry. "First" walks `ns.BUILTIN_ORDER` then sorted user keys, never `pairs()` order. Repaints at the end of each fill pass, on Clear, on `TRADE_PLAYER_ITEM_CHANGED`, and when a pending name arrives.
- **Conjure buttons** (`Conjure-Buttons.lua`): one `SecureActionButtonTemplate` per built-in collection the player knows a spell for.
    - `ns.GetConjureSpell(key, partnerLevel)`: best known rank whose item the partner can use; a `Unique` collection skips a tier already carried; else the lowest known rank (second return `true`). The choice goes to `ns.conjureChoices` for the tooltip and the report.
    - `spell` attribute is the spell ID; the label is `C_Spell.GetSpellName`, and an unloaded name hides that button.
    - Registered `"AnyUp", "AnyDown"`: a single-stroke registration never fires when `ActionButtonUseKeyDown` picks the other stroke (seen on TBC Anniversary).
    - The holder is parented to `UIParent` and **positioned by screen coordinates** under Fill (`PlaceHolder`, scale-corrected), never anchored to it. Its `OnUpdate` follows the trade window out of combat. When Fill has no position yet (anchored this frame), `ns.RefreshConjureButtons` retries next frame via `C_Timer.After(0, ...)`.
    - Shown only beside a showing trade panel with `ConjureButtons` and `Dispense` both on. The status line re-anchors under the holder (`SetStatusAnchor`) while it shows.

### Conjure During a Trade

Conjured items land as small partial stacks, and shaping can't invent items, so a mid-trade cast would show nothing until casts piled up. Instead (`Dispenser.lua`):

- `OnSpellcastSucceeded` (player-filtered, trade open, out of combat) → `WatchConjure` snapshots every slot holding one of `ns.SPELL_TO_ITEMS[spellId]` into `conjureWatch`.
- The next `BAG_UPDATE` → `PlaceConjured` offers each unlocked watched slot that grew or appeared, then wipes the watch.
- The conjured slot bypasses reserve, session cap and per-class counts: casting into an open trade is the instruction.
- `FillTrade` won't shape while `conjureWatch` is armed: a split or merge makes a slot appear or grow, which `PlaceConjured` would hand over as a cast. That's why `conjureWatch` is declared at the top of the file.
- A stack already in the window may not take merged items, so long casting can use up the six trade slots; a full window ends the pass.

### Bag Moves and Stack Shaping

`Features/Bag-Moves.lua` holds the only bag writes; `Features/Stack-Shaping.lua` decides which to make for the fill.

- Rules for every move: never against a locked slot, never leave an item on the cursor (a stranded cursor makes the next split fail with "Couldn't split those items"). No move reports that it landed; the caller re-scans on the following bag update.
- Empty slots are found by `C_Container.GetContainerItemInfo` returning nil, not by free-slot counts or a nil item link.
- `ns.MergeSlots` / `ns.MergePartials`: pickup src, pickup dst, pickup src again to return a remainder, `ClearCursor`. `MergePartials` pairs smallest onto largest without reusing a slot, so one pass halves the loose slots; it re-reads the cursor before every merge.
- Portioning is two primitives: `ns.SplitToCursor` then `ns.StowCursorItem`, only ever paired, inside `PortionIntoBag`. The portion lands in a bag and the next pass places it whole; it never goes cursor-to-trade, because nothing can read the cursor's count. `SplitToCursor` refuses before touching anything (locked source, whole-stack split, occupied cursor) and returns false only when nothing reached the cursor. `StowCursorItem` tries every empty slot (profession bags refuse silently), skipping one dropped into within `STOW_SETTLE`.
- `ns.ShapeStack(configId, loose, want)` tries, cheapest first: an exact pair merge; split from the smallest slot larger than `want`; else merge partials and look again next pass.
- Four brakes, all reset on `TRADE_SHOW` (`ns.ResetShaping`), because each move's bag update re-enters the fill and a bouncing move would loop forever:
    - `lastShape[configId]`: loose counts unchanged after a move's settle window means it bounced; one bounce ends shaping for that item this trade. A refused split does the same.
    - `shapeSettling[configId]` (`SHAPE_SETTLE`): a move gets time to land before the item is reshaped, handed over loose, or judged bounced. Forever can take several bag updates to land a split. `ScheduleSettleCheck` runs one more pass when the window closes.
    - `MAX_MOVES_PER_ITEM` and `MAX_MOVES_PER_TRADE`.
- **Post-trade restack** (`RestackPass`): runs only from `TRADE_CLOSED`, after `RESTACK_SETTLE`, and chains another pass only if it merged something (`RESTACK_MAX_PASSES` is a backstop). Scope: built-in collection items and user-added IDs only; full stacks, non-stackers and uncached stack sizes are skipped. `CanRestack` abandons on `Dispense` or `RestackBags` off, combat, a trade open, or anything on the cursor. Ticking `RestackBags` on doesn't kick a pass.

### Session Ledger

- `Features/Session-Ledger.lua`: `sessionGiven[configKey][partnerKey]`, never saved; a reload resets every budget. That is what "session" means.
- `ns.TradePartnerKey` is captured into `ns.State.Trade.Partner` at `TRADE_SHOW`, because `UnitName("NPC")` is gone by `TRADE_CLOSED`.
- `TRADE_ACCEPT_UPDATE` snapshots `CountOffered()` when the **player** accepts; `OnTradeClosed` credits it. Waiting for both sides misses the case where the partner accepted first: the trade completes with no `(1, 1)` update, so nothing would be credited.
- A trade that fails after the player accepted is still credited (errs toward giving less).
- Every control that changes how much of an item goes out calls `ns.ResetSessionLedger(configKey)`, so a raised cap takes effect now.

### Group Spares

`Features/Group-Spares.lua` puts what a player would hand over on their unit tooltip: party and raid members, and always the player themselves.

- **What travels**: `ns.BuildTooltipSnapshot` (`Inventory-Scanner.lua`): net of reserve, gated by `Distribute` and the player-class filter, so the tooltip never advertises what the fill would refuse. `GuildiesOnly` and per-class counts are deliberately not applied (they're about one trade's partner). A collection reports its best rank on hand; bound copies of user items don't count.
- `ComposeOffer` returns empty with `Dispense` off. `BuildOffer` caches it in `cachedOffer` (unit tooltips rebuild about five times a second); `ScheduleBroadcast` is the only place it is dropped, ahead of its debounce early-out.
- **Wire**: `<chunk>/<total>|<itemId>:<count>[:0];...` on `ns.ADDON_MESSAGE_PREFIX`, `:0` when quantity is switched off, plus `H:<rank>[:0]` for a warlock. Chunked to `ns.CHAT_MESSAGE_MAX_LENGTH` less header room. Chunk 1 resets the sender's buffer.
- **When**: debounced (`BROADCAST_DEBOUNCE`) off `BAG_UPDATE_DELAYED`, `GROUP_ROSTER_UPDATE`, `PLAYER_ENTERING_WORLD`, `SPELLS_CHANGED` and `ns.RefreshGroupSpares`. Never ungrouped, never in combat. With `ShowInventoryTooltips` or `ShareInventory` off it sends one empty offer to clear the group.
- An unchanged payload on the same channel isn't resent (`lastBroadcast`, `lastChannel`). The client throttles addon traffic. `GROUP_ROSTER_UPDATE` and `ns.RefreshGroupSpares` clear `lastBroadcast` to force a send.
- **Receive**: only `PARTY`, `RAID`, `INSTANCE_CHAT`. `receivedSpares` is runtime only and pruned to the roster.
- **Keys**: `Name-Realm`, matching `CHAT_MSG_ADDON`'s sender. `UnitKey` fills a missing realm from `GetNormalizedRealmName`, falling back to `GetRealmName` (nil during a loading screen), and strips spaces, hyphens and periods. The prune walks real unit tokens (`RosterKeys`), so the feature rests on one assumption: `UnitKey`'s output matches the sender spelling. A mismatch is silent; the Inventory Tooltips report flags `no roster match`.
- **Healthstone row**: before Wrath, a stone made at 0, 1 or 2 points of Improved Healthstone is a different unique item, so a raid coordinates on the rank. A warlock always gets a talent row (rank = highest of `ns.HEALTHSTONE_TALENT_SPELLS` known, locale-independent), named by `C_Spell.GetSpellName`, with carried healthstones folded into it. The count preference travels with the talent (`TalentShowQuantity`), since a warlock with no stone sends no item.
- **Hook path**: `GameTooltip:HasScript("OnTooltipSetUnit")` picks it. Era and TBC Anniversary hook the script (TBC ships `TooltipDataProcessor`, but its `GameTooltip` never passes through it). Forever has no such script (hooking it throws and kills the rest of login) and uses a Unit post-call gated to `GameTooltip`. Recorded in `ns.unitTooltipPath`.
- Header: `ns.BuildTooltipBrandedLine` (the Short Name); rows keep item quality color.

### Bag Item Tooltips

- `Features/Item-Tooltips.lua` adds one `TOOLTIP_WILL_DISPENSE` line (Short Name branding) when the item has a config key (`ns.GetItemConfigKey`) and is active for the player's class, gated on `Dispense` and `ShowBagTooltips`.
- Path picked by `GameTooltip:HasScript("OnTooltipSetItem")`. Era/TBC: `hooksecurefunc(GameTooltip, "SetBagItem")`, bag-scoped by its own arguments with `ns.LAST_BAG_INDEX`, so it survives replacement bag add-ons. Forever: an Item post-call gated by `GetCarriedBagSlot`. Recorded in `ns.bagTooltipPath`.
- Hooking the setter, not `OnTooltipSetItem`, keeps the line when a tooltip add-on clears and refills. Installed one frame after `PLAYER_LOGIN` so it wraps everyone else's hooks and lands last; it re-`Show()`s the tooltip after adding.

### Mini-map Button

- `Features/Minimap-Button.lua`: one LDB launcher under `ns.LOCALE_NAME`; LibDBIcon gets `ns.db.profile.minimap`. Left-click → `ns.SetDispense`; Shift + Middle-Click → `ns:OpenOptionsPanel`.
- `ns.ToggleMinimapButton` writes `minimap.hide` and applies it through `LDBIcon:Refresh`, the same call the profile switch uses.
- On Camelot and Mainline the icon is fitted by hand rather than `SetButtonIcon`, whose reset errors when another add-on replaced the icon.
- **Dispense Report** (README-Notes exception): `ns.BuildAnnouncementSnapshot(true)`, the macro's entries with the reserve *not* subtracted; left out when empty or `Dispense` off.

### Announcement Macro

- No `SendChatMessage` anywhere. `Features/Announcements.lua` keeps one per-character macro, `MACRO_NAME`, in sync; the player fires it. Don't add a send path.
- `SyncMacroState`, via the debounced `ScheduleUpdate` (`UPDATE_DEBOUNCE`) on `BAG_UPDATE_DELAYED`, `GROUP_ROSTER_UPDATE`, `PLAYER_ENTERING_WORLD`, combat end and `ns.RefreshAnnouncementMacro`. Enabled and missing: silent `CreateMacro` in the per-character slot. Enabled and present: `EditMacro` only when the body differs from `lastMacroBody`. Disabled and present: delete and print `CHAT_MACRO_DELETED`. `macroFullWarned` latches the slots-full print until a create succeeds.
- Body source: `ns.BuildAnnouncementSnapshot()`, in `ns.BUILTIN_ORDER` then user items by name; empty with `Dispense` off (the macro stays, with an empty body).
- **Sent format**: channel slash + `ns.TARGET_MARKER` + head + item list + tail + ` // ` + `ADDON_SHORT_NAME`, assembled in code on every client. `ns.GetGroupChatChannel` (instance chat first) is shared with Group Spares.
- `ANNOUNCEMENTS_BODY` is one locale sentence with one `%s`; `BodyTemplateParts` splits it into head and tail (koKR has an empty head) and strips a trailing ASCII or full-width period from the tail.
- `ns.BuildAnnouncementMacroBody(parts, channelSlash)` is a pure builder (the Message Length report measures with it). It measures in bytes against `ns.CHAT_MESSAGE_MAX_LENGTH`. Over the limit, it lays the lead once, appends whole parts while the total stays under the limit minus the ` ...` and suffix reserves, then closes with ` ...` and the suffix, dropping the tail. It truncates only at part boundaries: never inside a link, never by comma search.
- The Announcements panel previews `ns.BuildAnnouncementMessage` (no slash, untruncated) in `HELP`, swapping the marker token for `ns.TARGET_MARKER_TEXTURE` and re-opening the tint after each link's `|r`.

### Single Entry Points

- `ns.RefreshGiveaways` (`Utilities.lua`): "what I have to give changed". It refreshes the macro and the group broadcast together.
- `ns.SetDispense` (`Dispenser.lua`): the only writer of `Dispense`. It is shared by the Dispense panel, the General panel's Features switch and the mini-map click, and it refreshes giveaways and conjure buttons and notifies both panels.
- `ns.SetAnnouncementsEnabled` (`Announcements.lua`): the same shape for the macro switch.

### Options Panels

- `ns:OpenOptionsPanel` routes by `ns.optionsFrames.categoryID` captured from `AddToBlizOptions` (`Settings.OpenToCategory`), with `AceConfigDialog:Open` as last resort. Never by display name.
- `ns.RegisterOptionsPanels` runs from `PLAYER_LOGIN` (Profiles needs `ns.db`). Child order is the call order in `Options/Options.lua`; Diagnostic Tools registers its builder function, so every repaint rebuilds it.
- Mirrored switches: the General panel's Features section repeats Dispense, the macro, Show Inventory in Player Tooltips and the bag tooltips. Each copy notifies the other panel's registry.
- **Dispensed Items** (`Options-Dispensed-Items.lua`), the one `childGroups = "tree"` panel:
    - One flat page per item: built-ins in `ns.BUILTIN_ORDER`, user items by name, Add an Item last. `TreeSpacer` adds the vertical gap AceGUI lacks.
    - Arg keys must be strings: user items are `item_<id>` (`EncodeItemKey` / decode).
    - Rows in the tree pane use `PANEL_ROW_WIDTH`, not `ns.OPTIONS_ROW_WIDTH`. The pane is narrower, and an overflowing row wraps and strands its caption.
    - The grid is fixed-width cells inside one `inline` group per row. Each cell closes over its scope and class, because inside the group the info path ends at the group's key; `info[1]` is still the item key.
    - Amounts are free-typed item counts: `ns.OptionsParseCount` rounds and clamps to `NUMBER_MAX`; `ns.OptionsValidateCount` rejects non-numbers and enforces 1 for a `Unique` collection's grid and Everyone row.
    - The Everyone row writes all classes in each box's own `set`. AceConfigDialog commits an `input` only on Enter, so a gather-on-click button would see uncommitted boxes.
    - `AmountRow` builds both Reserve and Maximum per Player; the box grays rather than hides so rows don't reflow.
    - Distribute's `set` refreshes giveaways; Guildies Only's doesn't (it never changes what's advertised).
    - The Distribute dropdown and the Add an Item picker carry an explicit `sorting`; AceGUI would otherwise sort numeric-looking keys numerically.
    - After add or remove: `ns.RebuildDispensedItemsOptions` then `AceConfigDialog:SelectGroup` (new item's page, or `addItem`).
- `ns.NUMBER_BOX_WIDGET_TYPE` (`Options-Utilities.lua`) wraps the stock EditBox to relabel its button "Apply". It's its own registered type, guarded, never a library patch.
- `ns.OptionsExample` wraps a line in `SAMPLE_EXAMPLE`, re-opening silver after it for locales whose label continues past `%s`. The Dispense panel's Example lines pass `ns.BuildPrintLine`, so they show the exact chat print.

### Identity Constants

- Folder and packaged name `Water-Dispenser`; in-Lua identity `WaterDispenser` = `ns.LOCALE_NAME` (`Data/Data.lua`). It backs `GetLocale`, the LDB object, the LibDBIcon key and the number-box widget type. `ns.SAVED_VARIABLES_NAME` spells the saved global once.
- `ADDON_NAME` (the vararg) still keys `C_AddOns.GetAddOnMetadata` (version, flavor) and `ns.OPTIONS_REGISTRY`.
- `Locales/*.lua` repeat the literal (they load before `Data.lua`).
- `ns.ADDON_MESSAGE_PREFIX` shares the spelling but is a separate constant, read by Group Spares' send and receive paths and the event log's filter.
- `ADDON_TITLE` (prints, panel titles) and `ADDON_SHORT_NAME` (sent macro, tooltip blocks) are separate locale keys.

### Diagnostic Tools

Copied framework (Style Guide → DIAGNOSTIC TOOLS); this add-on's surface is `Diagnostics/Manifests.lua` plus the event filters in `Event-Log.lua`.

- `ns.DIAGNOSTIC_API_CHECKS`: existence and shape checks for every API the add-on reads.
- Four context reports, each answering one silent failure: `ns:BuildTradeFillReport`, `ns:BuildConjureRestackReport`, `ns:BuildAnnouncementReport`, `ns:BuildInventoryTooltipsReport`. They read through the copy-returning state getters (`ns.GetFillState`, `ns.GetShapingState`, `ns.GetConjureButtonsState`, `ns.GetRestackState`, `ns.GetAnnouncementState`, `ns.GetGroupSparesState`) and never change state. They never call `ns.ScanInventory` (it moves `fillBaseline`): Trade & Fill walks the bags itself, and the Announcement report builds its would-be body only with no trade open.
- `ns.DIAGNOSTIC_SPELLS`, `ns.DIAGNOSTIC_NAME_LOOKUPS`, `ns.DIAGNOSTIC_DATA_SOURCES`: built from the data by path, so no ID lives in the diagnostics files. `ns.COLLECTIONS` rows are read by position (`RowField`).
- Event log: `ns.DIAGNOSTIC_EVENT_EXCLUDE` drops `BAG_UPDATE`; the fill writes its own trail through `ns:LogEventNow` (`BAG_UPDATE`, `PLACE`, `SHAPE`, `FILL`, `SPLIT`), each only while logging. `ns.MESSAGE_ID_FILTERED_EVENTS` filters `CHAT_MSG_ADDON` and `GET_ITEM_INFO_RECEIVED`; `CORRELATED_IDS` keeps a firing on `ns.ADDON_MESSAGE_PREFIX` or for an item `ns.IsItemNamePending` reports (the Dispensed Items tree only, not the status line), and counts the rest.
- `ns.diagnostics` is in-memory, so the panel starts off every login.

## Files That Change Together

- **New built-in collection**: `ns.COLLECTIONS` in every flavor folder's `Collections-<Folder>.lua` (positional `Items` rows read by index in `Features/Utilities.lua` and by `RowField` in `Manifests.lua`); `ns.COLLECTION_META` (`Icon`, `Unique`) and `ns.BUILTIN_ORDER` in `Data/Data.lua`; a block in `ns.DATABASE_DEFAULTS.profile.Items`. Its label, spells, Validate Data rows and name lookups follow automatically.
- **New registered event**: `ns.RegisterEvent` in the owning `Init*`. A firehose also goes in `ns.MESSAGE_ID_FILTERED_EVENTS` + `CORRELATED_IDS`, or `ns.DIAGNOSTIC_EVENT_EXCLUDE` + `ns:LogEventNow` in its handler (`Diagnostics/Event-Log.lua`).
- **New setting**: its key in `ns.DATABASE_DEFAULTS.profile`, its options row, its label and `desc` in `Locales/enUS.lua`. It also needs `ns.RefreshGiveaways()` in `set` if it changes what's on offer, and `NotifyChange` on both registries if it's mirrored on the General panel.
- **New per-item field**: each built-in block under `Items` in `Data/Default-Settings.lua`, *and* the literal the Add an Item button writes in `Options/Options-Dispensed-Items.lua`; readers tolerate nil (older user items). A field that changes amounts calls `ns.ResetSessionLedger(key)`.
- **New `Distribute` mode**: `ns.DISTRIBUTE_MODES`, `ns.IsItemDistributableNow`, and an `OPTIONS_ITEM_DISTRIBUTE_<MODE>` key (looked up by composed name).
- **Announcement format**: `AnnouncementPrefix` / `AnnouncementSuffix` / `BodyTemplateParts` in `Announcements.lua`; the preview's marker swap in `Options-Announcements.lua` (`ns.TARGET_MARKER` and `ns.TARGET_MARKER_TEXTURE` must name the same mark); the Announcement report in `Manifests.lua`.
- **Wire format**: `EncodeOffer` and `DecodeInto` in `Group-Spares.lua`, together; a format or prefix change splits groups across releases.

## Saved Variables

- `WaterDispenserDB` (`ns.SAVED_VARIABLES_NAME`): the whole configuration, via AceDB-3.0 in `SetupDatabase` at `PLAYER_LOGIN`.
- **Model: Simple.** One shared `"Default"` profile; everything in `ns.db.profile`, `ns.db.global` unused. Nothing stored differs by character, so a new setting is a profile key. **Reset Profile clears everything**: mini-map position, every per-item amount, and every user-added item.
- `PruneOtherClientCharacters` runs right after `AceDB:New` (Style Guide → SAVED VARIABLES → Other-Client Characters).
- `ns:ApplyProfile` (on `OnProfileChanged` / `OnProfileReset` / `OnProfileCopied`) re-stamps collection meta, rebuilds the item tree, refreshes giveaways and conjure buttons, notifies every panel, and re-points LibDBIcon at the new `minimap` table (LibDBIcon keeps the table it was registered with).
- **No default-list seeding.** The three built-ins are AceDB table defaults, physically copied into the profile when first read. `ns.RefreshCollectionMeta` reads each (re-stamping `NoRemove`), which is what puts them in `FillTrade`'s `pairs()` walk; don't make that a lazy metatable. User items get no AceDB defaults. Nothing refills on empty.
- `Items` is keyed by collection name (built-ins) or numeric item ID (user items). No name or icon is stored.
- `PlayerClasses` stores an unchecked class as explicit `false`; a missing key would be re-supplied from the built-in default.
- `Distribute` strings are saved format; every read goes through `ns.NormalizeDistribute`, which folds retired `"Group"` / `"Raid"` (or anything unknown) to `"Always"` without rewriting the file.
- No migration chain at present.

## Pitfalls & Why

- **Anchoring the conjure holder to Fill**: a protected frame anchored to another protects that frame, and with it the trade panel and `TradeFrame`. Position by screen coordinates (`PlaceHolder`).
- **Registering a secure button for one click stroke**: never fires when `ActionButtonUseKeyDown` picks the other. Keep `"AnyUp", "AnyDown"`.
- **Resolving the options category by display name**: works on Classic Era only (no `C_SettingsUtil.OpenSettingsPanel`), nil elsewhere. Route by the captured `categoryID`.
- **Registering a `UNIT_*` event unfiltered**: wakes the dispatcher for every nearby unit and floods the log. Pass unit tokens; the first registration fixes the filter.
- **Queueing a fill for combat end**: deliberately absent. The trade window won't survive the fight.
- **Acting from behind a hidden control**: a sub-option hides with its master, so its code must read the master too: `Broadcast` reads `ShowInventoryTooltips` with `ShareInventory`, `CanRestack` reads `Dispense` with `RestackBags`, the conjure buttons read `Dispense`.
- **Applying `GuildiesOnly` to an advertising surface**: there's no partner until a trade opens, so it would hide the item from everyone. Keep it in `FillTrade`.
- **Reading `Distribute` raw**: retired values match nothing. Use `ns.NormalizeDistribute` / `ns.IsItemDistributableNow`.
- **Changing the offer without dropping `cachedOffer`**: the player's own tooltip goes stale. Route through `ns.RefreshGiveaways`.
- **Reading an amount field directly**: a disabled reserve or cap would apply. Use `ns.GetItemReserve` / `ns.GetItemSessionCap`.
- **Re-gating the collection rank cap on `FactorLevel`**: the cap is intrinsic for built-ins; `FactorLevel` is for single-rank user items.
- **Counting in stacks**: every number in config and the fill is individual items.
- **Reading the cursor's count, or placing straight from a split**: `GetCursorInfo` never gives the amount and the source slot hasn't updated by the next line. Portion into a bag; the next scan says what landed.
- **Retrying a split that "looks" refused**: the cursor can read empty in the frame a good split is issued; asking again hits a locked slot and shows "Couldn't split those items". Only `SplitToCursor`'s nothing-on-cursor return is a refusal.
- **Taking an item back out of a trade slot**: `ClickTradeButton` is a round trip; "place, check, pull back" strands it on the cursor. Verify before placing (`PlaceStack`).
- **Trusting the trade API right after placing**: the slot-lock bag update arrives before the acknowledgement. Keep `placedThisTrade` and its lock-based pruning.
- **Counting a locked slot as available**: it's in the window or mid-move; counting it double-counts and "placing" it is a silent no-op.
- **Placing a loose slot because it fits**: puts the remainder in a second trade slot. Full or exact only; shape the rest.
- **Moving bag items from a bag-update handler without checking the cursor**: picking up locks a slot and fires a bag update, so the handler runs while the player is dragging.
- **Driving the restack off bag updates**: merges stacks the player just built by hand and takes manual splits off the cursor. `TRADE_CLOSED` only.
- **Dropping a move brake**: a bouncing move re-enters the fill forever. Keep `lastShape`, `shapeSettling` and both move ceilings.
- **Leaving `ns.State.MissingStack` set between trades**: a hidden auto-fill path past a declined `OnTradeShow`.
- **Crediting the session ledger on a both-sides accept**: the partner-first case completes with no `(1, 1)` update.
- **Expecting a button to read a text box**: AceConfigDialog commits `input` only on Enter. Typed values must act in their own `set`.
- **A `select` keyed by ID with no `sorting`**: AceGUI sorts numeric-looking keys as numbers.
- **Hooking `OnTooltipSetUnit` / `OnTooltipSetItem` on Forever**: the script doesn't exist and the hook throws, killing the rest of login. Test `HasScript`, never `TooltipDataProcessor`'s presence (TBC ships it but `GameTooltip` ignores it).
- **Spelling a groupmate's key a second way**: Group Spares depends on `UnitKey` matching `CHAT_MSG_ADDON`'s sender spelling; any self-spelled lookup adds a silent failure.
- **Deriving the locale, LibDBIcon key or prefix from `ADDON_NAME`**: wrong spelling (`Water-Dispenser`). Use `ns.LOCALE_NAME` / `ns.ADDON_MESSAGE_PREFIX`.
- **Mixing `ADDON_TITLE` and `ADDON_SHORT_NAME`**: identical text in every locale today, so a wrong key goes unnoticed until a locale shortens one.
- **Expecting `ANNOUNCEMENTS_BODY`'s closing punctuation in the macro**: `BodyTemplateParts` strips a trailing `.` or `。`; other punctuation (`!`) stays.
- **Measuring the macro body in characters**: always bytes (`#body`); ruRU is the widest. Truncate only at part boundaries.
- **Renaming `MACRO_NAME` past 16 characters**: the client silently truncates it.
- **Expecting the event log to keep every `GET_ITEM_INFO_RECEIVED` the add-on handles**: the trade status line's pending names aren't in `ns.IsItemNamePending`, so they're counted, not logged.
- **Calling a legacy global**: Forever lacks them; `C_Item`, `C_Spell`, `C_Container`, `C_AddOns` are called directly. Only stats (`ns.GetItemStats`) and tooltip text (`ns.GetTooltipLines`) resolve per client, modern first.
- **Translated words for game names**: never in `Locales/`. Collection labels come from `ns.COLLECTION_NAME_ITEM_ID`, conjure labels from `C_Spell.GetSpellName`, classes from `ns.GetClassName`.
