local _, ns = ...

local L = ns.L

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

local ICON_COORDS = ns.ICON_COORDS

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

-- FillTrade was requested but deferred by combat.
local pendingCombatFill = false

-- Latches the "nothing configured for your class" hint to once per session.
local noneActiveWarned = false

-- Set from a conjure until its restack-then-fill runs, so OnBagUpdate holds off dispensing unmerged partials.
local restackPending = false

-- The queued restack was deferred by combat; replayed on PLAYER_REGEN_ENABLED.
local pendingCombatRestack = false

-- Active restack debounce timer handle, if any.
local restackTimer = nil

--------------------------------------------------------------------------------
-- Trade Filling
--------------------------------------------------------------------------------

function ns.ClearTrade()
	if ns.IsInCombat() then
		ns.PrintMessage(L["CHAT_COMBAT_PAUSED"])
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
	Counts stacks already offered in the player's trade slots, grouped by config
	key (collection key for built-ins, item-ID key for user items). One occupied
	slot is one "stack". A non-forced refill subtracts these from the target so a
	mid-trade restock tops up to the configured count instead of over-filling.
]]
local function CountOfferedStacks()
	local offered = {}
	if not (GetTradePlayerItemLink and GetTradePlayerItemInfo) then
		return offered
	end
	if not (ns.db and ns.db.profile.Items) then
		return offered
	end
	for slot = 1, MAX_TRADABLE_ITEMS do
		local link = GetTradePlayerItemLink(slot)
		local _, _, slotCount = GetTradePlayerItemInfo(slot)
		if link and slotCount and slotCount > 0 then
			local itemId = tonumber(link:match("item:(%d+)"))
			if itemId then
				local key = ns.ITEM_TO_COLLECTION[itemId]
				if not key then
					if ns.db.profile.Items[itemId] ~= nil then
						key = itemId
					elseif ns.db.profile.Items[tostring(itemId)] ~= nil then
						key = tostring(itemId)
					end
				end
				if key ~= nil then
					offered[key] = (offered[key] or 0) + 1
				end
			end
		end
	end
	return offered
end

-- Classic Era can't split stacks from an addon (SplitContainerItem ignores count), so each slot is one "stack".
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

local function ReportMissing(itemConfig, inv, count)
	local icon = inv and inv.Icon or itemConfig.Icon
	local name = (inv and inv.Name) or itemConfig.Name or "?"
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
		pendingCombatFill = true
		ns.PrintMessage(L["CHAT_COMBAT_PAUSED"])
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

	-- Non-forced refills count already-offered stacks as progress (avoids over-filling on a mid-trade restock); a forced fill clears first.
	local offered = (not forced) and CountOfferedStacks() or {}

	-- Count of items enabled for the player's class, so a forced fill can report when none is.
	local activeForPlayer = 0

	for configId, itemConfig in pairs(ns.db.profile.Items) do
		local isActive = ns.IsItemActiveForPlayer(itemConfig)
		if isActive then
			activeForPlayer = activeForPlayer + 1
		end
		local needed = isActive and CountForScope(itemConfig, scope, trade.Class) or 0
		-- Stacks already in the trade window count toward the target.
		needed = needed - (offered[configId] or 0)

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
				-- KeepAtLeast guards only the player's top-tier stash, so it's resolved without the partner-level cap.
				bestOverallId = ns.BestRankItemId(configId, nil)
				reportInv = entries[1] or (bestOverallId and ns.GetInventoryItem(bestOverallId)) or nil
			else
				-- User-added item: one concrete ID, no alternate rank, so FactorLevel skips it outright when the partner is too low.
				local inv = ns.GetInventoryItem(configId)
				local skip = false
				if itemConfig.FactorLevel and trade.Level and trade.Level > 0 then
					local requiredLevel = inv and inv.Level
					if not requiredLevel and type(configId) == "number" then
						local _, _, _, _, itemMinLevel = ns.GetItemInfo(configId)
						requiredLevel = itemMinLevel
					end
					if requiredLevel and requiredLevel > trade.Level then
						skip = true
					end
				end
				entries = (inv and not skip) and { inv } or {}
				bestOverallId = configId
				reportInv = inv
			end

			--[[
				Fill from the resolved entries, best rank first. Within each rank, full stacks
				go first, then partial stacks if the item allows -- one bag slot per "stack"
				(Classic Era can't split from an addon). KeepAtLeast counts individual items
				and reserves only the best-overall rank; lower-rank leftovers are pure
				giveaway. Each placement is checked so a stack that would dip below it is skipped.
			]]
			local aborted = false
			for _, entry in ipairs(entries) do
				if needed <= 0 or aborted then
					break
				end
				local keep = (entry.Id == bestOverallId) and (itemConfig.KeepAtLeast or 0) or 0
				local remaining = ns.TotalItemCount(entry)

				-- Full stacks of this rank first.
				for _, bagEntry in ipairs(entry.Bags) do
					if needed <= 0 then
						break
					end
					if bagEntry.Full and not (skipBound and bagEntry.Bound) then
						local count = bagEntry.Count or 0
						if remaining - count >= keep then
							if not PlaceStack(bagEntry.Bag, bagEntry.Slot) then
								aborted = true
								break
							end
							needed = needed - 1
							remaining = remaining - count
						end
					end
				end

				-- Then partial stacks of this rank, if the item allows.
				if needed > 0 and not aborted and itemConfig.UseNotFullStack then
					for _, bagEntry in ipairs(entry.Bags) do
						if needed <= 0 then
							break
						end
						if not bagEntry.Full and (bagEntry.Count or 0) > 0 and not (skipBound and bagEntry.Bound) then
							local count = bagEntry.Count or 0
							if remaining - count >= keep then
								if not PlaceStack(bagEntry.Bag, bagEntry.Slot) then
									aborted = true
									break
								end
								needed = needed - 1
								remaining = remaining - count
							end
						end
					end
				end
			end

			if needed > 0 then
				-- Always flag so OnBagUpdate retries after a restock; the chat warning is opt-in.
				ns.State.MissingStack = true
				if ns.db.profile.MissingStackWarnings then
					ReportMissing(itemConfig, reportInv, needed)
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
-- Stack Consolidation
--------------------------------------------------------------------------------

-- Debounce so a burst of conjures (each fires UNIT_SPELLCAST_SUCCEEDED) collapses into one restack-then-fill.
local RESTACK_DEBOUNCE = 0.2

--[[
	Merges partial stacks of one item into as few stacks as possible. Only whole
	stacks can be picked up (Classic Era blocks addon stack splitting), so each
	step drops a whole stack onto the running target: the target tops off at
	maxStack and any overflow returns to the now-empty source slot, which becomes
	the next target. Planned from the passed-in snapshot -- no mid-op bag re-reads.
]]
local function ConsolidatePartials(slots, maxStack)
	local targetIndex = 1
	for i = 2, #slots do
		local target = slots[targetIndex]
		local source = slots[i]
		local total = target.Count + source.Count

		ns.PickupContainerItem(source.Bag, source.Slot)
		ns.PickupContainerItem(target.Bag, target.Slot)

		if total > maxStack then
			-- Target full; the overflow returns to the now-empty source slot, which seeds the next target.
			ns.PickupContainerItem(source.Bag, source.Slot)
			target.Count = maxStack
			source.Count = total - maxStack
			targetIndex = i
		else
			target.Count = total
			source.Count = 0
		end
	end
end

-- Consolidates partial stacks of every built-in collection item so the fill hands over full stacks. One bag walk, grouped by item.
local function RestackCollections()
	if not (ns.PickupContainerItem and ns.GetContainerNumSlots and ns.GetContainerItemInfo) then
		return
	end

	local partialsById = {}
	for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local slots = ns.GetContainerNumSlots(bag)
		for slot = 1, slots do
			local info = ns.GetContainerItemInfo(bag, slot)
			if info and ns.ITEM_TO_COLLECTION[info.itemID] then
				local _, _, _, _, _, _, _, maxStack = ns.GetItemInfo(info.itemID)
				local count = info.stackCount or 0
				if maxStack and maxStack > 1 and count > 0 and count < maxStack then
					local entry = partialsById[info.itemID]
					if not entry then
						entry = { MaxStack = maxStack, Slots = {} }
						partialsById[info.itemID] = entry
					end
					entry.Slots[#entry.Slots + 1] = { Bag = bag, Slot = slot, Count = count }
				end
			end
		end
	end

	local merged = false
	for _, entry in pairs(partialsById) do
		if #entry.Slots >= 2 then
			ConsolidatePartials(entry.Slots, entry.MaxStack)
			merged = true
		end
	end

	if merged then
		-- Safety: drop anything still on the cursor (e.g. a maxStack mismatch) back to its origin rather than leaving it stuck.
		ClearCursor()
	end
end

-- Runs the queued conjure response: merge partials, then dispense, so the trade gets full stacks. Defers in combat, replays on combat end.
local function RunRestackThenFill()
	restackTimer = nil
	if not ns.State.Trade.Active then
		restackPending = false
		return
	end
	if ns.IsInCombat() then
		pendingCombatRestack = true
		return
	end
	RestackCollections()
	restackPending = false
	ns.FillTrade(false)
end

-- Debounced trigger; restackPending latches immediately so OnBagUpdate holds off until the restack merges the partials.
local function ScheduleRestack()
	restackPending = true
	if restackTimer then
		return
	end
	if not (C_Timer and C_Timer.NewTimer) then
		RunRestackThenFill()
		return
	end
	restackTimer = C_Timer.NewTimer(RESTACK_DEBOUNCE, RunRestackThenFill)
end

-- A collection-spell conjure queues the restack-then-fill, gated to an active trade so bags are never reshuffled in normal play.
local function OnSpellcastSucceeded(_, unit, _, spellId)
	if unit ~= "player" then
		return
	end
	if not ns.SPELL_TO_COLLECTION[spellId] then
		return
	end
	if not ns.State.Trade.Active then
		return
	end
	ScheduleRestack()
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

	if ns.TradeUI then
		ns.TradeUI:Attach(TradeFrame)
	end
	ns.ClearInventory()

	local dispenseKey = "DispenseSolo"
	if trade.Party then
		dispenseKey = IsInRaid() and "DispenseRaid" or "DispenseGroup"
	end

	if ns.db.profile.Dispense and ns.db.profile[dispenseKey] then
		if ns.IsInCombat() then
			pendingCombatFill = true
			ns.PrintMessage(L["CHAT_COMBAT_PAUSED"])
		else
			ns.FillTrade(false)
		end
	end
end

local function OnTradeClosed()
	local trade = ns.State.Trade
	trade.Active = false
	trade.Class = nil
	trade.Level = nil
	trade.Party = false

	pendingCombatFill = false
	pendingCombatRestack = false
	restackPending = false
	if restackTimer then
		restackTimer:Cancel()
		restackTimer = nil
	end
	ns.ClearInventory()
	if ns.TradeUI then
		ns.TradeUI:Detach()
	end
end

local function OnBagUpdate()
	if not ns.State.Trade.Active then
		return
	end
	if restackPending then
		-- A conjure-triggered restack is queued; it merges the partials then fills, so don't dispense the half-size stacks early.
		return
	end
	if not ns.State.MissingStack then
		return
	end
	if ns.IsInCombat() then
		pendingCombatFill = true
		return
	end
	ns.FillTrade(false)
end

local function OnCombatEnd()
	if not ns.State.Trade.Active then
		return
	end

	if pendingCombatRestack then
		pendingCombatRestack = false
		pendingCombatFill = false
		ns.PrintMessage(L["CHAT_COMBAT_RESUMED"])
		ScheduleRestack()
		return
	end

	if pendingCombatFill then
		pendingCombatFill = false
		ns.PrintMessage(L["CHAT_COMBAT_RESUMED"])
		ns.FillTrade(false)
	end
end

local function OnSpellsChanged()
	--[[
		Pre-warm the item cache so the first ScanInventory resolves synchronously.
		Every collection item, so a non-mage holding mage water also benefits.
	]]
	for _, c in pairs(ns.COLLECTIONS) do
		for itemId in pairs(c.Items) do
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
	ns.RegisterEvent("BAG_UPDATE", OnBagUpdate)
	ns.RegisterEvent("PLAYER_REGEN_ENABLED", OnCombatEnd)
	--[[
		SPELLS_CHANGED alone covers the cache pre-warm: it fires on login and on any
		spellbook change, including learning a rank. Don't add LEARNED_SPELL_IN_TAB as
		a companion -- it's redundant here and isn't a valid event on TBC (2.5.5).
	]]
	ns.RegisterEvent("SPELLS_CHANGED", OnSpellsChanged)
	-- A conjure of water/food/healthstone triggers a restack (merge partials into full stacks) then a fill, so the trade gets full stacks.
	ns.RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", OnSpellcastSucceeded)
end
