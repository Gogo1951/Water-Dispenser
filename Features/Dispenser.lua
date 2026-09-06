local _, ns = ...

local L = ns.L

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

local ICON_COORDS = ns.ICON_COORDS

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

-- Latches the "nothing configured for your class" hint to once per session.
local noneActiveWarned = false

--[[
	Items handed to each player this session, per configured item:
	sessionGiven[configKey][partnerKey] = items. Runtime only and deliberately never
	saved, so a reload or a logout starts everyone's budget over. That is the whole
	definition of "session" here.
]]
local sessionGiven = {}

-- What we were offering the moment the player last accepted, keyed by config key.
local acceptedOffer = nil

--[[
	Bag slots a mid-trade conjure is waiting to place, as [itemId][bag:slot] = count.
	Declared up here rather than beside PlaceConjured because FillTrade reads it too:
	a portioning split makes a slot appear, which the watch would misread as a cast.
]]
local conjureWatch = {}

--[[
	Bag moves issued during this trade, and the ceilings on them.

	A move -- a split, or a merge -- is driven by the bag update it causes: move,
	re-fill, place. That is self-limiting while the server cooperates, but a move
	the server accepts and then bounces back is *also* a bag change, so a bouncing
	item would re-enter the fill forever, shuffling the bags on every pass. The
	counters are what stop that; ShapeStack is where they are spent.

	Per item, eight covers a bag the restack has been keeping tidy (one merge and
	one split at most) with room for a handful of loose scraps. Per trade,
	twenty-four is deliberately generous, so a legitimate fill can never reach it.
	Both reset on TRADE_SHOW, because the ceilings are meant to catch one wedged
	trade, not to ration the day.
]]
local MAX_MOVES_PER_TRADE = 24
local MAX_MOVES_PER_ITEM = 8
local movesThisTrade = 0
local movesPerItem = {}

--[[
	The loose slot counts of each item as they stood when its last move was issued,
	as a sorted string. A move that lands always changes them -- a split adds a
	slot, a merge removes one -- so finding them unchanged on the next pass means the
	move bounced: on Classic Era the split call has been seen moving the whole
	stack to a fresh slot instead, which leaves the same counts in different
	places. One bounce ends shaping for that item this trade, where the ceilings
	alone would let it reshuffle the bags several more times first.
]]
local lastShape = {}

--[[
	Bag slots this trade's fill has put in the window, as
	placedThisTrade[itemId][bag:slot] = count.

	The trade API is the record of what is offered, but it lags: ClickTradeButton is
	a server round trip, and the lock it puts on the bag slot fires a bag update
	before the acknowledgement lands. A pass running in that gap would read the
	target as unmet and hand over a second stack. This record closes the gap. A
	recorded slot that is no longer locked has left the window -- the server
	refused it, or the player took it back out -- and is forgotten on the next read.
]]
local placedThisTrade = {}

-- Items whose session cap has already been reported this trade, so the notice is said once and not once per bag update.
local capNoticed = {}

--------------------------------------------------------------------------------
-- Combat Notices
--------------------------------------------------------------------------------

--[[
	Tells the player why nothing filled. Not a warning about something that might
	go wrong: the attempt has already failed, and without this the add-on looks
	broken rather than blocked.

	A fill blocked by combat is abandoned, never queued. A trade window does not
	stay open through a fight, so there is nothing worth replaying afterwards.
]]
local function PrintCombatBlocked()
	if ns.db and ns.db.profile.CombatNotifications then
		ns.PrintMessage(L["CHAT_COMBAT_BLOCKED"])
	end
end

--------------------------------------------------------------------------------
-- Session Ledger
--------------------------------------------------------------------------------

-- Name-realm for a partner from another realm, plain name otherwise.
local function TradePartnerKey()
	local name, realm = UnitName("NPC")
	if not name then
		return nil
	end
	if realm and realm ~= "" then
		return name .. "-" .. realm
	end
	return name
end

local function GivenThisSession(configKey, partnerKey)
	local perPlayer = sessionGiven[configKey]
	return (perPlayer and perPlayer[partnerKey]) or 0
end

--[[
	Forgets what everyone has already been given of an item, so a limit changed
	part-way through a session is measured from now rather than against giving that
	happened under the old number. Without it, raising Maximum per Session from 2 to
	10 hands over nothing until the next reload, which reads as the setting being
	ignored. Passing nil clears every item.
]]
function ns.ResetSessionLedger(configKey)
	if configKey == nil then
		wipe(sessionGiven)
		return
	end
	sessionGiven[configKey] = nil
end

local function CreditSession(configKey, partnerKey, count)
	local perPlayer = sessionGiven[configKey]
	if not perPlayer then
		perPlayer = {}
		sessionGiven[configKey] = perPlayer
	end
	perPlayer[partnerKey] = (perPlayer[partnerKey] or 0) + count
end

--------------------------------------------------------------------------------
-- Dispense Toggle
--------------------------------------------------------------------------------

--[[
	The only place the master Dispense switch is written. The options toggle and
	the mini-map button both route through here, so neither can pick up a step the
	other forgets: telling the group what is on offer, resuming the restack that
	hangs off this switch, and repainting an options panel that is already open on
	the toggle the mini-map button just flipped.
]]
function ns.SetDispense(value)
	if not ns.db then
		return
	end
	value = value and true or false
	ns.db.profile.Dispense = value
	ns.RefreshGiveaways()
	-- Restacking is a sub-option of this one, so switching back on resumes it.
	if value then
		ns.RestackBags()
	end
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.Dispenser)
end

--------------------------------------------------------------------------------
-- Trade Filling
--------------------------------------------------------------------------------

function ns.ClearTrade()
	if ns.IsInCombat() then
		PrintCombatBlocked()
		return
	end
	if not ns.State.Trade.Active then
		ns.PrintMessage(L["CHAT_NO_TRADE"])
		return
	end

	for i = 1, MAX_TRADABLE_ITEMS do
		ClearCursor()
		ClickTradeButton(i)
	end
	ClearCursor()
	--[[
		The cleared slots stay locked until the server acknowledges, and a locked
		slot the fill did not place reads as still moving, so the pass after this one
		waits for that unlock rather than filling around it.
	]]
	wipe(placedThisTrade)
end

local function CountForScope(itemConfig, scope, class)
	return (itemConfig[scope] and itemConfig[scope][class]) or 0
end

local function PickScope()
	local trade = ns.State.Trade
	if trade.Party then
		return IsInRaid() and "Raid" or "Group"
	end
	return "Solo"
end

-- Config key for an item ID: collection key for built-ins, the ID itself for user items, nil if not configured.
local function ConfigKeyFor(itemId)
	local key = ns.ITEM_TO_COLLECTION[itemId]
	if not key and ns.db.profile.Items[itemId] ~= nil then
		key = itemId
	end
	return key
end

--[[
	How many individual items the player's own trade slots hold, grouped by config
	key (collection key for built-ins, item-ID key for user items), and how many
	trade slots each item ID occupies.

	A non-forced refill subtracts the counts from the target so a mid-trade restock
	tops up instead of over-filling; the same counts are what the session budget is
	measured in, and are the snapshot credited when a trade goes through. The slot
	tally is what lets the fill tell a locked bag slot that is in the window from
	one that is still mid-move.
]]
local function CountOffered()
	local items, slotsByItem = {}, {}
	if not (GetTradePlayerItemLink and GetTradePlayerItemInfo) then
		return items, slotsByItem
	end
	if not (ns.db and ns.db.profile.Items) then
		return items, slotsByItem
	end
	for slot = 1, MAX_TRADABLE_ITEMS do
		local link = GetTradePlayerItemLink(slot)
		local _, _, slotCount = GetTradePlayerItemInfo(slot)
		if link and slotCount and slotCount > 0 then
			local itemId = tonumber(link:match("item:(%d+)"))
			if itemId then
				slotsByItem[itemId] = (slotsByItem[itemId] or 0) + 1
				local key = ConfigKeyFor(itemId)
				if key ~= nil then
					items[key] = (items[key] or 0) + slotCount
				end
			end
		end
	end
	return items, slotsByItem
end

--[[
	What this trade's own placements still hold in the window, in the same two
	shapes as CountOffered, read from placedThisTrade with stale entries pruned: a
	recorded slot that is unlocked, empty, or holding something else has left the
	window.

	The two views are reconciled by taking the larger per key. The trade API
	misses a placement until the server acknowledges it; this record misses a stack
	the player dragged in by hand. Each is a lower bound on the truth, so the larger
	is the closer one, and both err toward giving less.
]]
local function PendingOffer()
	local items, slotsByItem = {}, {}
	if not ns.GetContainerItemInfo then
		return items, slotsByItem
	end
	for itemId, slots in pairs(placedThisTrade) do
		for key, count in pairs(slots) do
			local bag, slot = key:match("^(%-?%d+):(%d+)$")
			local info = bag and ns.GetContainerItemInfo(tonumber(bag), tonumber(slot))
			if info and info.isLocked and info.itemID == itemId then
				slotsByItem[itemId] = (slotsByItem[itemId] or 0) + 1
				local configKey = ConfigKeyFor(itemId)
				if configKey ~= nil then
					items[configKey] = (items[configKey] or 0) + count
				end
			else
				slots[key] = nil
			end
		end
		if next(slots) == nil then
			placedThisTrade[itemId] = nil
		end
	end
	return items, slotsByItem
end

--[[
	PickupWhole lifts a bag slot's entire contents and PlaceStack drops all of it
	into the next free trade slot. This is the path for an amount a whole slot
	already matches; anything smaller goes through PortionIntoBag below.
]]
local function PickupWhole(bag, slot)
	if ns.PickupContainerItem then
		ns.PickupContainerItem(bag, slot)
	end
end

--[[
	Places (bag, slot)'s whole contents into the next open trade slot.

	Returns placed, full. `placed` means the slot was lifted and dropped into the
	window. `full` means no trade slot was open, which ends the pass: nothing else
	will fit either. Both false means this one slot could not be used and the
	caller moves on to the next.

	Everything is checked *before* the slot is disturbed, because there is no
	verify-after-placing (README-Technical, Pitfalls). A locked slot is already in
	the window or still mid-move, and lifting one is a silent no-op -- which used
	to count as a placement, so the fill believed the partner had been handed a
	stack that never left the bag and stopped one short. A count that no longer
	matches the scan means the bag changed under the pass; the update that changed
	it re-enters the fill with a fresh scan, so the slot is left to that pass. The
	cursor is the last word: pickup is the only thing that puts an item on it, so
	an empty cursor after pickup is proof nothing was lifted.
]]
local function PlaceStack(bag, slot, expectedCount)
	local info = ns.GetContainerItemInfo and ns.GetContainerItemInfo(bag, slot)
	local reason
	if not info then
		reason = "empty"
	elseif info.isLocked then
		reason = "locked"
	elseif expectedCount and (info.stackCount or 0) ~= expectedCount then
		reason = "count=" .. tostring(info.stackCount or 0) .. "/" .. expectedCount
	end

	if not reason then
		ClearCursor()
		PickupWhole(bag, slot)
		if not CursorHasItem() then
			reason = "cursor"
		end
	end

	if reason then
		if ns.diagnostics and ns.diagnostics.logging then
			ns:LogEventNow("PLACE", bag, slot, "skip=" .. reason)
		end
		return false, false
	end

	local tradePos = TradeFrame_GetAvailableSlot()
	if not tradePos then
		ClearCursor()
		if ns.diagnostics and ns.diagnostics.logging then
			ns:LogEventNow("PLACE", bag, slot, "skip=full")
		end
		return false, true
	end
	ClickTradeButton(tradePos)

	local placed = placedThisTrade[info.itemID]
	if not placed then
		placed = {}
		placedThisTrade[info.itemID] = placed
	end
	placed[bag .. ":" .. slot] = info.stackCount or 0
	return true, false
end

--[[
	Splits `portion` off (bag, slot) into a free bag slot, so the pass that follows
	can hand that slot over whole. True if a move was issued.

	The trade window is deliberately not involved. Dropping a just-split stack
	straight into it would save a round trip but stakes everything on the cursor
	holding the amount that was asked for, which nothing can verify -- and getting
	it wrong put a whole stack in front of a partner who was owed two. Landing in a
	bag first means the next scan reports what actually happened, and the whole-slot
	rule refuses to place anything larger than what is still owed.
]]
local function PortionIntoBag(source, portion)
	if not ns.SplitToCursor(source.Bag, source.Slot, portion) then
		return false
	end
	-- Never leaves the cursor holding anything, whatever the client did with the split.
	ns.StowCursorItem()
	return true
end

--[[
	Shapes one bag slot holding exactly `want` of an item out of `loose`: the slots
	of that item the fill has not used this pass, sorted biggest first. The partner
	then receives one stack, where handing the loose slots over as they are gave
	them a trade slot per scrap -- two Runecloth as two slots of one.

	Returns moved, waiting. `moved` means a bag move was issued and the bag update it
	causes re-enters the fill, where the shaped slot is an exact match for the
	whole-slot rule. `waiting` means nothing was issued but nothing should be placed
	either: the player is holding something on the cursor, and their next drop is a
	bag update of its own. Both false means the bags cannot be shaped and the caller
	hands the loose slots over as they are.

	Cheapest move first, since every one is a server round trip:

	  1. Two loose slots that add up to exactly `want` merge into one. One move, and
	     it leaves no scrap behind.
	  2. A slot larger than `want` has `want` split off it into an empty bag slot --
	     the smallest such slot, so breaking a 7 to find 5 leaves a full 20 intact.
	     One move; the scrap it leaves is the restack's to tidy after the trade.
	  3. Otherwise every loose slot is smaller than `want`, so they merge pairwise,
	     smallest onto largest, and the pass after finds one big enough for step 2
	     or an exact match. Bags the restack keeps tidy rarely get here: they hold
	     one partial per item, so it is step 1 or 2 or nothing.

	Every move is retried implicitly by the bag update it causes, so each is charged
	against the per-item and per-trade ceilings declared at the top. A refused split
	-- nothing reached the cursor, the one unambiguous signal that this client will
	not split -- spends the item's whole budget at once, so it is said once and not
	retried on every bag update.
]]
local function ShapeStack(configId, itemConfig, loose, want)
	if #loose == 0 then
		return false, false
	end
	if (movesPerItem[configId] or 0) >= MAX_MOVES_PER_ITEM or movesThisTrade >= MAX_MOVES_PER_TRADE then
		return false, false
	end
	-- Something already held is the player's; a merge or split would drop it.
	if GetCursorInfo() then
		return false, true
	end

	local counts = {}
	for index, bagEntry in ipairs(loose) do
		counts[index] = bagEntry.Count
	end
	local shape = table.concat(counts, ",")
	local logging = ns.diagnostics and ns.diagnostics.logging
	if shape == lastShape[configId] then
		movesPerItem[configId] = MAX_MOVES_PER_ITEM
		if logging then
			ns:LogEventNow("SHAPE", configId, "want=" .. want, "loose=" .. shape, "bounced")
		end
		return false, false
	end

	local function Spend(moves, how)
		movesPerItem[configId] = (movesPerItem[configId] or 0) + moves
		movesThisTrade = movesThisTrade + moves
		lastShape[configId] = shape
		if logging then
			ns:LogEventNow("SHAPE", configId, "want=" .. want, "loose=" .. shape, how)
		end
	end

	-- 1. An exact pair. Sorted biggest first, so the later slot is the smaller and moves onto the earlier.
	for i = 1, #loose - 1 do
		for j = i + 1, #loose do
			if loose[i].Count + loose[j].Count == want then
				Spend(1, "pair")
				ns.MergeSlots(loose[j], loose[i])
				return true, false
			end
		end
	end

	-- 2. The smallest slot larger than `want`.
	local source
	for index = #loose, 1, -1 do
		if loose[index].Count > want then
			source = loose[index]
			break
		end
	end
	if source then
		Spend(1, "split")
		if PortionIntoBag(source, want) then
			return true, false
		end
		movesPerItem[configId] = MAX_MOVES_PER_ITEM
		--[[
			Opt-in, since by then the player has usually seen the trade work. Never
			inferred from a fill that is still short on a later pass: a pass running
			before the move settles is also still short, so a good split would report
			itself refused a fraction of a second before handing the items over.
		]]
		if ns.db.profile.MissingStackWarnings then
			local name = ns.GetItemConfigName(configId, itemConfig) or "?"
			ns.PrintMessage(format(L["CHAT_SPLIT_REFUSED"], name, want))
		end
		return false, false
	end

	-- 3. Everything is smaller than `want`: combine, and let the next pass look again.
	local merges = ns.MergePartials(loose)
	if merges > 0 then
		Spend(merges, "combine")
		return true, false
	end
	return false, false
end

local function ReportMissing(configId, itemConfig, inventoryItem, count)
	local icon = (inventoryItem and inventoryItem.Icon) or ns.GetItemConfigIcon(configId, itemConfig)
	local name = (inventoryItem and inventoryItem.Name) or ns.GetItemConfigName(configId, itemConfig) or "?"
	local iconTag = icon and ("|T" .. icon .. ICON_COORDS .. "|t ") or ""
	ns.PrintMessage(L["CHAT_MISSING_STACK"], iconTag .. name .. " x" .. count)
end

function ns.FillTrade(forced)
	local trade = ns.State.Trade
	if not trade.Active then
		ns.PrintMessage(L["CHAT_NO_TRADE"])
		return
	end

	if ns.IsInCombat() then
		PrintCombatBlocked()
		return
	end

	local changed = ns.ScanInventory()
	if not changed and not forced then
		return
	end

	ns.State.MissingStack = false
	if forced then
		ns.ClearTrade()
	end

	local scope = PickScope()

	--[[
		What is already in the window, from the trade API and from this trade's own
		placements, the larger per key (see PendingOffer). A forced fill has just
		cleared the window and forgotten its placements, so nothing counts against
		it; the cleared slots stay locked until the server says so, and read as
		mid-move below until then.
	]]
	local offeredItems, offeredSlots, pendingSlots = {}, {}, {}
	if not forced then
		local pendingItems
		offeredItems, offeredSlots = CountOffered()
		pendingItems, pendingSlots = PendingOffer()
		for key, count in pairs(pendingItems) do
			if count > (offeredItems[key] or 0) then
				offeredItems[key] = count
			end
		end
	end

	-- Count of items enabled for the player's class, so a forced fill can report when none is.
	local activeForPlayer = 0

	for configId, itemConfig in pairs(ns.db.profile.Items) do
		local isActive = ns.IsItemActiveForPlayer(itemConfig)
		if isActive then
			activeForPlayer = activeForPlayer + 1
		end
		--[[
			The group gate is kept out of activeForPlayer on purpose: that count drives the
			"nothing is set up for your class" hint, and an item held back only because you
			are not in a raid is very much set up for your class.
		]]
		local canDistribute = isActive and ns.IsItemDistributableNow(itemConfig)
		-- Every count here is in individual items, the configured amount included.
		local needed = canDistribute and CountForScope(itemConfig, scope, trade.Class) or 0
		-- Items already in the trade window count toward the target.
		needed = needed - (offeredItems[configId] or 0)

		--[[
			The per-person session budget is in items too, so it simply clamps the target
			rather than being tracked alongside it. What is already in the window counts
			against it: the credit only happens on a completed trade, so without this a
			re-fill would let the same offer through twice.
		]]
		local sessionCap = ns.GetItemSessionCap(itemConfig)
		if sessionCap and trade.Partner then
			local budget = sessionCap - GivenThisSession(configId, trade.Partner) - (offeredItems[configId] or 0)
			if budget < needed then
				--[[
					Say so when the cap is what empties the trade, rather than leaving the
					player staring at a window that filled itself with nothing. This is the
					same reasoning as the combat notice: the attempt has already failed, and
					silence makes the add-on look broken instead of obedient. Latched per item
					per trade, since a fill re-runs on every bag update.
				]]
				if budget <= 0 and needed > 0 and not capNoticed[configId] then
					capNoticed[configId] = true
					--[[
						Not gated on MissingStackWarnings. That setting ships off, and this is the
						one line explaining why a trade window the player expected to fill sat
						empty -- hiding it behind an opt-in is how the cap came to look like the
						add-on being broken. Latched per item per trade, so it is said once.
					]]
					local name = ns.GetItemConfigName(configId, itemConfig) or "?"
					ns.PrintMessage(format(L["CHAT_SESSION_CAP_REACHED"], name, sessionCap))
				end
				needed = budget
			end
		end

		if needed > 0 then
			--[[
				Soulbound slots can't be traded. Skip them for user-added items; built-in
				collections are exempt (conjured items report bound but trade fine).
			]]
			local skipBound = ns.COLLECTIONS[configId] == nil

			-- Resolve which inventory entries to give from, best (highest) rank first. reportInv backs the "missing stack" warning if we fall short.
			local entries, bestOverallId, reportInv

			if ns.COLLECTIONS[configId] then
				--[[
					Collections always dispense the best rank the partner can actually use --
					water/food above their level is useless to them -- and cascade down through
					lower usable ranks when the best one runs short. The partner-level cap is
					intrinsic here, so FactorLevel only governs user-added items below.
				]]
				local levelLimit = (trade.Level and trade.Level > 0) and trade.Level or nil
				entries = ns.UsableRankEntries(configId, levelLimit)
				-- The reserve guards only the player's top-tier stash, so it's resolved without the partner-level cap.
				bestOverallId = ns.BestRankItemId(configId, nil)
				reportInv = entries[1] or (bestOverallId and ns.GetInventoryItem(bestOverallId)) or nil
			else
				-- User-added item: one concrete ID, no alternate rank, so FactorLevel skips it outright when the partner is too low.
				local inventoryItem = ns.GetInventoryItem(configId)
				local skip = false
				if itemConfig.FactorLevel and trade.Level and trade.Level > 0 then
					local requiredLevel = inventoryItem and inventoryItem.Level
					if not requiredLevel and type(configId) == "number" then
						local _, _, _, _, itemMinLevel = ns.GetItemInfo(configId)
						requiredLevel = itemMinLevel
					end
					if requiredLevel and requiredLevel > trade.Level then
						skip = true
					end
				end
				entries = (inventoryItem and not skip) and { inventoryItem } or {}
				bestOverallId = configId
				reportInv = inventoryItem
			end

			--[[
				Fill from the resolved entries, best rank first. A trade slot takes a whole
				bag slot, so the job is to cover `needed` items out of the slots on hand in
				as few trade slots as it takes -- ideally one. Whole slots go in only when
				they do not fragment the offer: a full stack, or the exact remainder.
				Anything else is shaped in the bags first (ShapeStack) and handed over on
				the pass after it lands, so a partner owed two never sees two slots of one.
				The reserve counts individual items and guards only the best-overall rank;
				lower-rank leftovers are pure giveaway.
			]]
			local aborted, inFlight = false, false
			for _, entry in ipairs(entries) do
				if needed <= 0 or aborted then
					break
				end
				local keep = (entry.Id == bestOverallId) and ns.GetItemReserve(itemConfig) or 0

				--[[
					A locked slot is off the table: with a trade open it is either already
					sitting in the window or still settling from a move, and either way it is
					not something this pass can hand over. The offered ones were subtracted
					from `needed` above; listing them here as well would count the same items
					twice, once as given and once as still available.

					Locked slots beyond the ones the window accounts for are moves still in
					flight -- a split landing, a merge settling, a cleared window unlocking.
					Their bag update is on its way and re-enters the fill with a fresh scan, so
					this rank waits for it rather than filling around what is about to land.
				]]
				local slots = {}
				local onHand, available, locked = 0, 0, 0
				for _, bagEntry in ipairs(entry.Bags) do
					if bagEntry.Locked then
						locked = locked + 1
					elseif (bagEntry.Count or 0) > 0 then
						onHand = onHand + bagEntry.Count
						if not (skipBound and bagEntry.Bound) then
							slots[#slots + 1] = bagEntry
							available = available + bagEntry.Count
						end
					end
				end
				local inWindow = math.max(offeredSlots[entry.Id] or 0, pendingSlots[entry.Id] or 0)
				if locked > inWindow then
					inFlight = true
					break
				end

				--[[
					What this rank may part with at all: the reserve takes its share of what is
					in hand, and no more can go than the tradable slots hold. A bound copy of a
					user item counts toward the reserve it is staying home for, but never toward
					the offer.
				]]
				local giveable = math.min(onHand - keep, available)
				-- Bag and slot break the tie, so the comparator is a strict ordering table.sort can't fault on.
				table.sort(slots, function(a, b)
					if a.Count ~= b.Count then
						return a.Count > b.Count
					end
					if a.Bag ~= b.Bag then
						return a.Bag < b.Bag
					end
					return a.Slot < b.Slot
				end)

				--[[
					Whole slots first, biggest first, but only ones that do not fragment the
					offer: a full stack, or a slot holding exactly what is still owed. A loose
					1 that fit inside a target of 2 used to go straight in, and the pass after
					split another 1 to sit beside it. Now the 1 waits and the shaping below
					builds the 2.

					`Full` is true while the stack size is uncached, so a cold cache degrades to
					the old whole-slot rule rather than refusing to place anything.
				]]
				local spent = {}
				for index, bagEntry in ipairs(slots) do
					local want = math.min(needed, giveable)
					if want <= 0 then
						break
					end
					local count = bagEntry.Count
					if count <= want and (count == want or bagEntry.Full) then
						local placed, full = PlaceStack(bagEntry.Bag, bagEntry.Slot, count)
						if full then
							aborted = true
							break
						end
						spent[index] = true
						if placed then
							needed = needed - count
							giveable = giveable - count
						end
					end
				end

				--[[
					Still short: shape one stack of exactly what is owed, capped at a full
					stack, out of the slots not used this pass. The bag update the move causes
					re-enters the fill, where the shaped slot is an exact match above.

					Not while a conjure is waiting to be placed. A split or merge makes a slot
					appear or grow, and PlaceConjured offers any slot that did since its
					snapshot, so it would hand the result over as though the player had just
					cast it. The conjure lands first and the bag update after it comes back here.
				]]
				local want = math.min(needed, giveable)
				if entry.StackSize and entry.StackSize > 0 and want > entry.StackSize then
					want = entry.StackSize
				end
				if want > 0 and not aborted and next(conjureWatch) == nil then
					local loose = {}
					for index, bagEntry in ipairs(slots) do
						if not spent[index] then
							loose[#loose + 1] = bagEntry
						end
					end
					local moved, waiting = ShapeStack(configId, itemConfig, loose, want)
					if moved or waiting then
						inFlight = true
					else
						--[[
							The bags cannot be shaped: the move budget is spent, the client will not
							split, or one loose slot is all there is. Hand over what fits as it is,
							so the partner still gets what the bags can give -- several slots is
							worse than one, but better than none.
						]]
						for _, bagEntry in ipairs(loose) do
							local room = math.min(needed, giveable)
							if room <= 0 then
								break
							end
							local count = bagEntry.Count
							if count <= room then
								local placed, full = PlaceStack(bagEntry.Bag, bagEntry.Slot, count)
								if full then
									aborted = true
									break
								end
								if placed then
									needed = needed - count
									giveable = giveable - count
								end
							end
						end
					end
				end
			end

			if needed > 0 then
				-- Always flag so OnBagUpdate retries after a restock, or after a portion settles.
				ns.State.MissingStack = true
				--[[
					A move in flight is not a shortfall -- the items exist and a slot of the
					right size is on its way -- so it must not print a warning the next pass
					will contradict. A refused split has already said its own piece.
				]]
				if ns.db.profile.MissingStackWarnings and not inFlight then
					ReportMissing(configId, itemConfig, reportInv, needed)
				end
			end
		end
	end

	-- On a forced fill with nothing eligible for the class, explain why (opt-in, latched once per session).
	if forced and activeForPlayer == 0 and ns.db.profile.MissingStackWarnings and not noneActiveWarned then
		noneActiveWarned = true
		local _, playerClass = UnitClass("player")
		ns.PrintMessage(format(L["CHAT_NONE_ACTIVE_FOR_CLASS"], ns.GetClassName(playerClass)))
	end
end

--------------------------------------------------------------------------------
-- Conjure During a Trade
--------------------------------------------------------------------------------

--[[
	Conjured items arrive in small partial stacks, and neither of the things that
	normally handle that is available with a trade already open: the restack stands
	down, and portioning cannot invent items the player does not have yet. Casting
	mid-trade would otherwise show nothing until enough casts had piled up. Instead
	the bag slots holding that spell's items are snapshotted at cast time, and
	whatever grew by the next bag update goes into the window as-is.

	The conjured slot bypasses the reserve, the session cap and the per-class
	counts: casting during an open trade is the player saying to hand it over.

	conjureWatch itself is declared with the other module state at the top, because
	FillTrade has to see it: a portioning split would otherwise be read as a cast.
]]

-- Snapshots every bag slot currently holding one of the cast spell's items, as [bag:slot] = count.
local function WatchConjure(spellId)
	local itemIds = ns.SPELL_TO_ITEMS[spellId]
	if not itemIds or not (ns.GetContainerNumSlots and ns.GetContainerItemInfo) then
		return
	end

	for _, itemId in ipairs(itemIds) do
		conjureWatch[itemId] = {}
	end
	for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local slots = ns.GetContainerNumSlots(bag)
		for slot = 1, slots do
			local info = ns.GetContainerItemInfo(bag, slot)
			local watched = info and conjureWatch[info.itemID]
			if watched then
				watched[bag .. ":" .. slot] = info.stackCount or 0
			end
		end
	end
end

-- Offers every watched slot that grew or appeared since the snapshot, then drops the watch either way.
local function PlaceConjured()
	if not (ns.GetContainerNumSlots and ns.GetContainerItemInfo) then
		wipe(conjureWatch)
		return
	end

	for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local slots = ns.GetContainerNumSlots(bag)
		for slot = 1, slots do
			local info = ns.GetContainerItemInfo(bag, slot)
			local watched = info and conjureWatch[info.itemID]
			-- A locked slot is still moving server-side; leaving it be lets the next bag update catch it settled.
			if watched and not info.isLocked then
				local before = watched[bag .. ":" .. slot]
				if not before or (info.stackCount or 0) > before then
					local _, full = PlaceStack(bag, slot)
					if full then
						-- Trade window full: nothing more will fit this pass.
						wipe(conjureWatch)
						return
					end
				end
			end
		end
	end

	wipe(conjureWatch)
end

-- The player's own conjure during a trade arms the watch; the bag update that follows does the placing.
local function OnSpellcastSucceeded(_, _, _, spellId)
	if not ns.SPELL_TO_COLLECTION[spellId] then
		return
	end
	if not ns.State.Trade.Active then
		return
	end
	WatchConjure(spellId)
end

--------------------------------------------------------------------------------
-- Trade Events
--------------------------------------------------------------------------------

local function OnTradeShow()
	local trade = ns.State.Trade
	trade.Active = true
	local _, npcClass = UnitClass("NPC")
	trade.Class = npcClass
	trade.Level = UnitLevel("NPC")
	-- UnitLevel can be nil, -1, or 0 (unknown/loading); fall back to player level + 10 so the level filter doesn't lock out everything.
	if not trade.Level or trade.Level <= 0 then
		trade.Level = UnitLevel("player") + 10
	end
	trade.Party = UnitInParty("NPC") or UnitInRaid("NPC")
	trade.Partner = TradePartnerKey()
	movesThisTrade = 0
	wipe(movesPerItem)
	wipe(lastShape)
	wipe(placedThisTrade)
	wipe(capNoticed)
	--[[
		Scoped to one trade. OnBagUpdate re-fills on this flag, so a shortfall left
		behind by the last trade would fill this one on the next bag update, past a
		Dispense toggle the player switched off.
	]]
	ns.State.MissingStack = false

	if ns.TradeUI then
		ns.TradeUI:Attach(TradeFrame)
	end
	ns.ClearInventory()

	local dispenseKey = "DispenseSolo"
	if trade.Party then
		dispenseKey = IsInRaid() and "DispenseRaid" or "DispenseGroup"
	end

	if ns.db.profile.Dispense and ns.db.profile[dispenseKey] then
		ns.FillTrade(false)
	end
end

--[[
	Snapshot on the *player's* own accept, never on both sides, and credit it to the
	session ledger when the window closes. When the partner has accepted first and
	the player clicks second, the server completes the trade immediately and
	TRADE_CLOSED arrives with no (1,1) update ever firing: a both-sides snapshot
	never happens, so nothing is credited and the session cap silently never
	accumulates. Watching one side also survives the partner toggling theirs, which
	fires further updates that would wipe a good snapshot.

	A trade that fails at the last instant is credited anyway, spending budget the
	partner never received: for a cap, erring toward giving less is the safe
	direction.
]]
local function OnTradeAcceptUpdate(_, playerAccepted)
	if playerAccepted == 1 then
		acceptedOffer = CountOffered()
	else
		acceptedOffer = nil
	end
end

local function OnTradeClosed()
	local trade = ns.State.Trade

	if acceptedOffer and trade.Partner then
		for configKey, count in pairs(acceptedOffer) do
			CreditSession(configKey, trade.Partner, count)
		end
	end
	acceptedOffer = nil

	trade.Active = false
	trade.Class = nil
	trade.Level = nil
	trade.Party = false
	trade.Partner = nil
	ns.State.MissingStack = false

	wipe(conjureWatch)
	ns.ClearInventory()
	if ns.TradeUI then
		ns.TradeUI:Detach()
	end
end

local function OnBagUpdate()
	if not ns.State.Trade.Active then
		return
	end
	if ns.IsInCombat() then
		-- Nothing can move into the window now, and the conjure is stale by the time combat ends.
		wipe(conjureWatch)
		return
	end

	local placing = next(conjureWatch) ~= nil
	local refilling = ns.State.MissingStack
	if not (placing or refilling) then
		return
	end

	--[[
		This handler is the only thing that acts on BAG_UPDATE, which the event log
		excludes as a firehose; write the firings it acts on back into the log.
	]]
	if ns.diagnostics and ns.diagnostics.logging then
		ns:LogEventNow("BAG_UPDATE")
	end

	if placing then
		PlaceConjured()
	end
	if refilling then
		ns.FillTrade(false)
	end
end

local function OnSpellsChanged()
	--[[
		Pre-warm the item cache so the first ScanInventory resolves synchronously.
		Every collection item, so a non-mage holding mage water also benefits.
	]]
	for _, collection in pairs(ns.COLLECTIONS) do
		for itemId in pairs(collection.Items) do
			ns.GetItemInfo(itemId)
		end
	end
	if ns.db and ns.db.profile.Items then
		for id in pairs(ns.db.profile.Items) do
			local numericId = tonumber(id)
			if numericId then
				ns.GetItemInfo(numericId)
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function ns.InitDispenser()
	ns.TradeUI = ns.CreateTradeUI()

	ns.RegisterEvent("TRADE_SHOW", OnTradeShow)
	ns.RegisterEvent("TRADE_CLOSED", OnTradeClosed)
	ns.RegisterEvent("TRADE_ACCEPT_UPDATE", OnTradeAcceptUpdate)
	ns.RegisterEvent("BAG_UPDATE", OnBagUpdate)
	--[[
		SPELLS_CHANGED alone covers the cache pre-warm: it fires on login and on any
		spellbook change, including learning a rank. Don't add LEARNED_SPELL_IN_TAB as
		a companion -- it's redundant here and isn't a valid event on TBC (2.5.5).
	]]
	ns.RegisterEvent("SPELLS_CHANGED", OnSpellsChanged)
	-- The player's own conjure of water/food/healthstone puts the new stack into an open trade; the "player" filter is what keeps every other unit's casts off the dispatcher.
	ns.RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", OnSpellcastSucceeded, "player")
end
