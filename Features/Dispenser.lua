local _, ns = ...

local L = ns.L

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
	Splits issued during this trade, and the ceiling on them.

	A portion is driven by the bag update it causes: split, re-fill, place. That is
	self-limiting while the server cooperates, but a split the server accepts and
	then bounces back is *also* a bag change, so a bouncing item would re-enter the
	fill forever, shuffling the bags on every pass. The counter is what stops that.

	Twelve is deliberately generous -- six trade slots' worth across a couple of
	items, so a legitimate fill can never reach it -- and resets on TRADE_SHOW,
	because the ceiling is meant to catch one wedged trade, not to ration the day.
]]
local MAX_PORTIONS_PER_TRADE = 12
local portionsThisTrade = 0

-- Items whose session cap has already been reported this trade, so the notice is said once and not once per bag update.
local capNoticed = {}

-- Items a portion has already been attempted for this trade, so one bad split cannot loop.
local portionTried = {}

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

--[[
	How many individual items the player's own trade slots hold, grouped by config
	key (collection key for built-ins, item-ID key for user items).

	A non-forced refill subtracts these from the target so a mid-trade restock tops
	up instead of over-filling; the same counts are what the session budget is
	measured in, and are the snapshot credited when a trade goes through.
]]
local function CountOffered()
	local items = {}
	if not (GetTradePlayerItemLink and GetTradePlayerItemInfo) then
		return items
	end
	if not (ns.db and ns.db.profile.Items) then
		return items
	end
	for slot = 1, MAX_TRADABLE_ITEMS do
		local link = GetTradePlayerItemLink(slot)
		local _, _, slotCount = GetTradePlayerItemInfo(slot)
		if link and slotCount and slotCount > 0 then
			local itemId = tonumber(link:match("item:(%d+)"))
			if itemId then
				local key = ns.ITEM_TO_COLLECTION[itemId]
				if not key and ns.db.profile.Items[itemId] ~= nil then
					key = itemId
				end
				if key ~= nil then
					items[key] = (items[key] or 0) + slotCount
				end
			end
		end
	end
	return items
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

-- Places (bag, slot)'s whole contents into the next open trade slot; false if none was open.
local function PlaceStack(bag, slot)
	ClearCursor()
	PickupWhole(bag, slot)

	local tradePos = TradeFrame_GetAvailableSlot()
	if not tradePos then
		ClearCursor()
		return false
	end
	ClickTradeButton(tradePos)
	return true
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

	-- A forced fill clears the window first, so nothing is already offered against it.
	local offeredItems = {}
	if not forced then
		offeredItems = CountOffered()
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
				bag slot, so the job is to cover `needed` items out of the slots on hand:
				whole slots that fit inside the remainder go first, biggest first, because
				there are only six trade slots and the biggest cover the most ground. The
				reserve counts individual items and guards only the best-overall rank;
				lower-rank leftovers are pure giveaway.
			]]
			local aborted, portioned = false, false
			for _, entry in ipairs(entries) do
				if needed <= 0 or aborted then
					break
				end
				local keep = (entry.Id == bestOverallId) and ns.GetItemReserve(itemConfig) or 0
				-- What this rank may part with at all, once the reserve has taken its share.
				local giveable = ns.TotalItemCount(entry) - keep

				local slots = {}
				for _, bagEntry in ipairs(entry.Bags) do
					if (bagEntry.Count or 0) > 0 and not (skipBound and bagEntry.Bound) then
						slots[#slots + 1] = bagEntry
					end
				end
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

				local placed = {}
				for index, bagEntry in ipairs(slots) do
					if needed <= 0 then
						break
					end
					local count = bagEntry.Count
					if count <= needed and count <= giveable then
						if not PlaceStack(bagEntry.Bag, bagEntry.Slot) then
							aborted = true
							break
						end
						placed[index] = true
						needed = needed - count
						giveable = giveable - count
					end
				end

				--[[
					Still short, and every slot left over holds more than the remainder. Split
					the remainder off into an empty bag slot so the next pass can hand it over
					whole -- this is what lets one potion out of a stack of five go.

					Capped by what the reserve still allows, so a target the bags can't legally
					cover hands over everything it may rather than stopping at the last whole
					slot that happened to fit. Short is then still short, and flagged below.

					The smallest oversized slot is the source: breaking a 7 to find 5 leaves a
					full stack of 20 intact where breaking the 20 would not.

					Not while a conjure is waiting to be placed. The split makes a bag slot
					appear, and PlaceConjured offers any slot that appeared since its snapshot,
					so it would hand the portion over as though the player had just cast it.
					The conjure lands first and the bag update after it comes back here.
				]]
				local portion = needed < giveable and needed or giveable
				if
					portion > 0
					and not aborted
					and next(conjureWatch) == nil
					and portionsThisTrade < MAX_PORTIONS_PER_TRADE
				then
					local source
					for index = #slots, 1, -1 do
						local bagEntry = slots[index]
						if not placed[index] and bagEntry.Count > portion then
							source = bagEntry
							break
						end
					end
					--[[
						One attempt per item per trade. A split lands in a bag, so the next pass
						sees it and places it whole -- and if the client handed over the whole
						stack instead, that pass finds the bags rearranged but still short and
						would otherwise ask for another split, and another, shuffling stacks for
						as long as the window stayed open.
					]]
					if source and not portionTried[configId] then
						portionTried[configId] = true
						portionsThisTrade = portionsThisTrade + 1
						if PortionIntoBag(source, portion) then
							--[[
								Waiting on the server now. Leaving `needed` unmet sets MissingStack
								below, and the bag update the move causes re-enters the fill, where
								a slot of the right size is just another whole-slot candidate.
							]]
							portioned = true
							break
						end
						--[[
							Nothing reached the cursor at all, which is the only unambiguous signal
							that this client will not split, and it is available immediately. Never
							infer a refusal from a fill that is still short on a later pass: a pass
							running before the move settles is also still short, so a good split
							would report itself refused a fraction of a second before handing the
							items over. Opt-in, since by then the player has usually seen the trade
							work.
						]]
						if ns.db.profile.MissingStackWarnings then
							local name = ns.GetItemConfigName(configId, itemConfig) or "?"
							ns.PrintMessage(format(L["CHAT_SPLIT_REFUSED"], name, portion))
						end
					end
				end
			end

			if needed > 0 then
				-- Always flag so OnBagUpdate retries after a restock, or after a portion settles.
				ns.State.MissingStack = true
				--[[
					A portion in flight is not a shortfall -- the items exist and are on their
					way into a slot of the right size -- so it must not print a warning the next
					pass will contradict. A refused split has already said its own piece.
				]]
				if ns.db.profile.MissingStackWarnings and not portioned then
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
					if not PlaceStack(bag, slot) then
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
	portionsThisTrade = 0
	wipe(capNoticed)
	wipe(portionTried)
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
