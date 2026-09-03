local _, ns = ...

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

-- Inventory cache. Rebuilt on demand by ScanInventory().
local inventory = nil

--------------------------------------------------------------------------------
-- Accessors
--------------------------------------------------------------------------------

function ns.GetInventoryItem(id)
	return inventory and inventory[id] or nil
end

--------------------------------------------------------------------------------
-- Inventory Scan
--------------------------------------------------------------------------------

local function ClearInventory()
	inventory = nil
end
ns.ClearInventory = ClearInventory

--[[
    Builds the inventory table from bag contents. Each entry has a Bags list of
    {Bag, Slot, Count, Full, Bound} per occupied slot. Returns true if anything
    changed in a way that may affect a fill.

    Bag items are tagged to their collection (via ns.ITEM_TO_COLLECTION) even
    when the player doesn't know the conjure spell, so a non-mage holding
    conjured water still announces it as MageWater.
]]
local function ScanInventory()
	local previous = inventory
	inventory = {}

	for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local slots = ns.GetContainerNumSlots(bag)
		for slot = 1, slots do
			local info = ns.GetContainerItemInfo(bag, slot)
			if info then
				local itemId = info.itemID

				local itemName, _, _, _, itemMinLevel, _, _, itemStackCount, _, itemIcon = ns.GetItemInfo(itemId)

				-- nil itemName = uncached item. Request a load so the next scan is warm; don't trust the other returns this pass.
				if not itemName and C_Item and C_Item.RequestLoadItemDataByID then
					C_Item.RequestLoadItemDataByID(itemId)
				end

				--[[
					Every occupied slot is tracked, with no view taken on item class. The player
					decides what gets dispensed, and explosives, trade goods and quest items are
					all giveable, so a Consumable gate here would silently hide them.

					No bindType gate either -- conjured items report BoP but trade fine. What
					cannot be traded is filtered per slot by the Bound flag below.
				]]
				local collectionKey = ns.ITEM_TO_COLLECTION[itemId]
				-- One entry per item ID; ranks of a collection stay separate and BestRankItemId picks across them.
				local rank = collectionKey and ns.ITEM_RANK[itemId] or nil
				local effectiveLevel = ns.ITEM_LEVEL[itemId] or itemMinLevel or 0

				if not inventory[itemId] then
					inventory[itemId] = {
						Id = itemId,
						Link = info.hyperlink,
						Name = itemName,
						Icon = itemIcon,
						Level = effectiveLevel,
						Collection = collectionKey,
						Rank = rank,
						-- True once any tradable (unbound) slot is seen. Drives the Add Item picker.
						HasUnbound = false,
						Bags = {},
					}
				else
					--[[
						Backfill only missing fields so a cold GetItemInfo can't blank out good
						values; tag the collection here for players who have the item but not the spell.
					]]
					local existing = inventory[itemId]
					if collectionKey and not existing.Collection then
						existing.Collection = collectionKey
						existing.Rank = rank
					end
					existing.Link = existing.Link or info.hyperlink
					existing.Name = existing.Name or itemName
					existing.Icon = existing.Icon or itemIcon
					if (not existing.Level or existing.Level == 0) and effectiveLevel > 0 then
						existing.Level = effectiveLevel
					end
				end

				--[[
					Max stack is nil while uncached; treat unknown as full so a genuine full
					stack isn't skipped for full-stack-only items. The next warm scan corrects it.
				]]
				local slotCount = info.stackCount or 0
				local isFull = true
				if itemStackCount then
					isFull = slotCount == itemStackCount
				end

				--[[
					Soulbound slots can't be traded. Built-in collections are exempt downstream
					(conjured items report bound but trade fine); this flag gates only user-added items.
				]]
				local bound = info.isBound and true or false
				table.insert(inventory[itemId].Bags, {
					Bag = bag,
					Slot = slot,
					Count = slotCount,
					Full = isFull,
					Bound = bound,
				})
				if not bound then
					inventory[itemId].HasUnbound = true
				end
			end
		end
	end

	if not previous then
		return true
	end
	for id, item in pairs(inventory) do
		local previousItem = previous[id]
		if not previousItem or #item.Bags ~= #previousItem.Bags then
			return true
		end
		for i, bagEntry in ipairs(item.Bags) do
			local previousEntry = previousItem.Bags[i]
			if not previousEntry or bagEntry.Count ~= previousEntry.Count then
				return true
			end
		end
	end
	for id in pairs(previous) do
		if not inventory[id] then
			return true
		end
	end
	return false
end
ns.ScanInventory = ScanInventory

--[[
    ScanInventory is a full bag walk. The options panels read the inventory from
    several render callbacks in the same frame; this coalesces those into one
    scan per frame (GetTime is constant within a frame), while a reopen on a
    later frame still rescans so freshly looted items appear. It also scans when
    the cache is empty. Trade and fill paths call ScanInventory directly and
    always scan fresh -- this wrapper is only for the options/display reads.
]]
local lastDisplayScan = nil
local function ScanInventoryForDisplay()
	local now = GetTime()
	if inventory == nil or now ~= lastDisplayScan then
		ScanInventory()
		lastDisplayScan = now
	end
end

--------------------------------------------------------------------------------
-- Inventory Helpers
--------------------------------------------------------------------------------

-- Total individual items across all bag slots (announcement counts, not stacks).
local function TotalItemCount(inventoryItem)
	local total = 0
	for _, bagEntry in ipairs(inventoryItem.Bags) do
		total = total + (bagEntry.Count or 0)
	end
	return total
end
ns.TotalItemCount = TotalItemCount

-- Total individual items across tradable (unbound) slots only, so a user-item announcement never advertises what can't be given.
local function UnboundItemCount(inventoryItem)
	local total = 0
	for _, bagEntry in ipairs(inventoryItem.Bags) do
		if not bagEntry.Bound then
			total = total + (bagEntry.Count or 0)
		end
	end
	return total
end

--[[
	Highest-rank item the player has stacks of in a collection, or nil. With a
	levelLimit, only entries usable at that level count; if none fit, falls back
	to the lowest rank held so a low-level partner gets the closest usable option.
]]
local function BestRankItemId(collectionKey, levelLimit)
	local bestId, bestRank = nil, -1
	for id, item in pairs(inventory or {}) do
		if item.Collection == collectionKey and #item.Bags > 0 then
			local rank = item.Rank or 0
			if rank > bestRank and (not levelLimit or (item.Level or 0) <= levelLimit) then
				bestId, bestRank = id, rank
			end
		end
	end
	if bestId or not levelLimit then
		return bestId
	end
	local fallbackId, fallbackLevel = nil, math.huge
	for id, item in pairs(inventory or {}) do
		if item.Collection == collectionKey and #item.Bags > 0 then
			local level = item.Level or 0
			if level < fallbackLevel then
				fallbackId, fallbackLevel = id, level
			end
		end
	end
	return fallbackId
end
ns.BestRankItemId = BestRankItemId

--[[
	Inventory entries for a collection the partner can use, ordered best (highest)
	rank first, so a fill can cascade down through ranks. Only ranks usable at
	levelLimit are included -- handing over water/food above the partner's level is
	useless to them. If none qualify (partner below every rank held, or no level
	known), the single lowest-rank stack on hand is returned as the closest option.
]]
local function UsableRankEntries(collectionKey, levelLimit)
	local entries = {}
	if levelLimit and levelLimit > 0 then
		for _, item in pairs(inventory or {}) do
			if item.Collection == collectionKey and #item.Bags > 0 and (item.Level or 0) <= levelLimit then
				entries[#entries + 1] = item
			end
		end
	end

	if #entries == 0 then
		local lowest
		for _, item in pairs(inventory or {}) do
			if item.Collection == collectionKey and #item.Bags > 0 then
				if not lowest or (item.Level or 0) < (lowest.Level or 0) then
					lowest = item
				end
			end
		end
		if lowest then
			entries[1] = lowest
		end
	end

	table.sort(entries, function(a, b)
		return (a.Rank or 0) > (b.Rank or 0)
	end)
	return entries
end
ns.UsableRankEntries = UsableRankEntries

--------------------------------------------------------------------------------
-- Public Inventory Access for Options
--------------------------------------------------------------------------------

function ns.GetAvailableItemsToAdd()
	ScanInventoryForDisplay()
	local list = {}
	if not inventory then
		return list
	end
	for id, item in pairs(inventory) do
		local isCollectionItem = item.Collection ~= nil
		local isConfigured = ns.db.profile.Items[id] ~= nil
		--[[
			Only items with at least one tradable copy, matching the L["OPTIONS_ADD_DESC"]
			promise that soulbound items won't appear. A name is required too: the scan
			now tracks every slot, so an item the client hasn't cached yet would reach the
			picker with no label. It has already been requested, so it lists once warm.
		]]
		if not isCollectionItem and not isConfigured and item.HasUnbound and item.Name then
			table.insert(list, {
				Id = id,
				Name = item.Name,
				Icon = item.Icon,
			})
		end
	end
	table.sort(list, function(a, b)
		return (a.Name or "") < (b.Name or "")
	end)
	return list
end

--------------------------------------------------------------------------------
-- Public Inventory Access for Announcements
--------------------------------------------------------------------------------

--[[
    Giveaway entries for the announcement macro, ordered as a trade fills:
    built-in collections (water, food, healthstones) then user items by name.
    Each entry: {Link, Name, Count, IncludeQuantity, Collection}. Count is
    items on hand minus the item's reserve; entries with nothing left to give are
    omitted. IncludeQuantity is the per-item "show count" toggle.
]]
function ns.BuildAnnouncementSnapshot()
	ScanInventoryForDisplay()

	local entries = {}
	if not inventory or not ns.db or not ns.db.profile.Items then
		return entries
	end

	-- Built-in collections first, in stable display order.
	for _, key in ipairs(ns.BUILTIN_ORDER) do
		local itemConfig = ns.db.profile.Items[key]
		if itemConfig and ns.IsItemActiveForPlayer(itemConfig) and ns.IsItemDistributableNow(itemConfig) then
			local bestId = BestRankItemId(key)
			local inventoryItem = bestId and inventory[bestId] or nil
			if inventoryItem and #inventoryItem.Bags > 0 then
				local total = TotalItemCount(inventoryItem)
				local keep = ns.GetItemReserve(itemConfig)
				local count = math.max(0, total - keep)
				if count > 0 then
					-- Default true when missing (old saved data).
					local includeQuantity = itemConfig.IncludeQuantity
					if includeQuantity == nil then
						includeQuantity = true
					end
					table.insert(entries, {
						Link = inventoryItem.Link or ("[" .. (inventoryItem.Name or "?") .. "]"),
						Name = inventoryItem.Name,
						Count = count,
						IncludeQuantity = includeQuantity,
						Collection = key,
					})
				end
			end
		end
	end

	-- User-added items, sorted by name.
	local custom = {}
	for id, itemConfig in pairs(ns.db.profile.Items) do
		if
			not ns.COLLECTION_META[id]
			and ns.IsItemActiveForPlayer(itemConfig)
			and ns.IsItemDistributableNow(itemConfig)
		then
			local inventoryItem = inventory[id]
			if inventoryItem and #inventoryItem.Bags > 0 then
				-- Only tradable copies count: soulbound ones can't be given.
				local total = UnboundItemCount(inventoryItem)
				local keep = ns.GetItemReserve(itemConfig)
				local count = math.max(0, total - keep)
				if count > 0 then
					local includeQuantity = itemConfig.IncludeQuantity
					if includeQuantity == nil then
						includeQuantity = true
					end
					table.insert(custom, {
						Link = inventoryItem.Link or ("[" .. (inventoryItem.Name or "?") .. "]"),
						Name = inventoryItem.Name or tostring(id),
						Count = count,
						IncludeQuantity = includeQuantity,
						Collection = nil,
					})
				end
			end
		end
	end
	table.sort(custom, function(a, b)
		return (a.Name or "") < (b.Name or "")
	end)
	for _, entry in ipairs(custom) do
		table.insert(entries, entry)
	end

	return entries
end

--------------------------------------------------------------------------------
-- Public Inventory Access for Group Spares
--------------------------------------------------------------------------------

--[[
    Every configured item the player is actually carrying, with the plain bag
    count. This is the tooltip list.

    Deliberately simpler than the announcement snapshot: no reserve subtracted, no
    class filter, no distribution rules. Configuring an item is the statement that
    it is up for grabs, so the only question left is how many they have. Soulbound
    copies of a user-added item still do not count, because they cannot be traded
    at all.

    IncludeQuantity rides along: the same per-item switch the announcement macro
    obeys, so a unique item reads "Healthstone" rather than "Healthstone 1" on
    both surfaces.
]]
function ns.BuildTooltipSnapshot()
	ScanInventoryForDisplay()

	local entries = {}
	if not inventory or not (ns.db and ns.db.profile.Items) then
		return entries
	end

	for key in pairs(ns.db.profile.Items) do
		local isCollection = ns.COLLECTION_META[key] ~= nil
		--[[
			The one rule this snapshot does apply. Everything else here is deliberately
			unfiltered -- configuring an item is the statement that it is up for grabs --
			but Distribute is not a rule about who deserves it, it is a statement that the
			item is not on offer at all right now. Advertising a raid consumable in a
			five-man invites a whisper the add-on would then refuse.
		]]
		local gated = not ns.IsItemDistributableNow(ns.db.profile.Items[key])
		-- A collection is reported as the best rank on hand, the same item the fill would reach for.
		local id = (not gated) and (isCollection and BestRankItemId(key) or key) or nil
		local inventoryItem = id and inventory[id] or nil
		if inventoryItem and #inventoryItem.Bags > 0 then
			local count = isCollection and TotalItemCount(inventoryItem) or UnboundItemCount(inventoryItem)
			if count > 0 then
				-- Default true when missing (old saved data), matching the macro.
				local includeQuantity = ns.db.profile.Items[key].IncludeQuantity
				if includeQuantity == nil then
					includeQuantity = true
				end
				entries[#entries + 1] =
					{ Id = id, Name = inventoryItem.Name, Count = count, IncludeQuantity = includeQuantity }
			end
		end
	end

	return entries
end
