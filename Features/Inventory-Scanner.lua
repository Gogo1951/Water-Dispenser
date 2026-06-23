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
    {Bag, Slot, Count, Full} per occupied slot. Returns true if anything changed
    in a way that may affect a fill.

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

                local itemName, _, _, _, itemMinLevel, _, _, itemStackCount, _, itemIcon, _, itemClassID =
                    ns.GetItemInfo(itemId)

                -- nil itemName = uncached item. Request a load so the next
                -- scan is warm; don't trust the other returns this pass.
                if not itemName and C_Item and C_Item.RequestLoadItemDataByID then
                    C_Item.RequestLoadItemDataByID(itemId)
                end

                -- Track consumables. Collection and configured items are known
                -- statically (tracked even while GetItemInfo is cold); others
                -- wait for the class to resolve. No bindType gate — conjured
                -- items report BoP but trade fine.
                local collectionKey = ns.ITEM_TO_COLLECTION[itemId]
                local isConfigured = ns.DB and ns.DB.Items and ns.DB.Items[itemId] ~= nil
                local isConsumable = collectionKey ~= nil or isConfigured or itemClassID == ns.CONSUMABLE_ITEM_CLASS

                if isConsumable then
                    -- One entry per item ID; ranks of a collection stay
                    -- separate and BestRankItemId picks across them.
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
                            Bags = {}
                        }
                    else
                        -- Backfill only missing fields so a cold GetItemInfo
                        -- can't blank out good values; tag the collection here
                        -- for players who have the item but not the spell.
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

                    -- Max stack is nil while uncached; treat unknown as full so a
                    -- genuine full stack isn't skipped for full-stack-only items.
                    -- The next warm scan corrects it.
                    local slotCount = info.stackCount or 0
                    local isFull = true
                    if itemStackCount then
                        isFull = slotCount == itemStackCount
                    end
                    table.insert(
                        inventory[itemId].Bags,
                        {
                            Bag = bag,
                            Slot = slot,
                            Count = slotCount,
                            Full = isFull
                        }
                    )
                end
            end
        end
    end

    if not previous then
        return true
    end
    for id, item in pairs(inventory) do
        local prev = previous[id]
        if not prev or #item.Bags ~= #prev.Bags then
            return true
        end
        for i, bagEntry in ipairs(item.Bags) do
            local prevEntry = prev.Bags[i]
            if not prevEntry or bagEntry.Count ~= prevEntry.Count then
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
    local now = GetTime and GetTime()
    if inventory == nil or now == nil or now ~= lastDisplayScan then
        ScanInventory()
        lastDisplayScan = now
    end
end

--------------------------------------------------------------------------------
-- Inventory Helpers
--------------------------------------------------------------------------------

-- Total individual items across all bag slots (announcement counts, not stacks).
local function TotalItemCount(inv)
    local total = 0
    for _, bagEntry in ipairs(inv.Bags) do
        total = total + (bagEntry.Count or 0)
    end
    return total
end
ns.TotalItemCount = TotalItemCount

-- Highest-rank item the player has stacks of in a collection, or nil. With a
-- levelLimit, only entries usable at that level count; if none fit, falls back
-- to the lowest rank held so a low-level partner gets the closest usable option.
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

-- Inventory entries for a collection the partner can use, ordered best (highest)
-- rank first, so a fill can cascade down through ranks. Only ranks usable at
-- levelLimit are included -- handing over water/food above the partner's level is
-- useless to them. If none qualify (the partner is below every rank held, or no
-- level is known), the single lowest-rank stack on hand is returned as the
-- closest usable option.
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

    table.sort(
        entries,
        function(a, b)
            return (a.Rank or 0) > (b.Rank or 0)
        end
    )
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
        local isConfigured = ns.DB.Items[id] ~= nil
        if not isCollectionItem and not isConfigured then
            table.insert(
                list,
                {
                    Id = id,
                    Name = item.Name,
                    Icon = item.Icon
                }
            )
        end
    end
    table.sort(
        list,
        function(a, b)
            return (a.Name or "") < (b.Name or "")
        end
    )
    return list
end

--------------------------------------------------------------------------------
-- Public Inventory Access for Announcements
--------------------------------------------------------------------------------

--[[
    Giveaway entries for the announcement macro, ordered as a trade fills:
    built-in collections (water, food, healthstones) then user items by name.
    Each entry: {Link, Name, Count, IncludeQuantity, Collection}. Count is
    items on hand minus KeepAtLeast; entries with nothing left to give are
    omitted. IncludeQuantity is the per-item "show count" toggle.
]]
function ns.BuildAnnouncementSnapshot()
    ScanInventoryForDisplay()

    local entries = {}
    if not inventory or not ns.DB or not ns.DB.Items then
        return entries
    end

    -- Built-in collections first, in stable display order.
    for _, key in ipairs(ns.BUILTIN_ORDER) do
        local itemConfig = ns.DB.Items[key]
        if itemConfig and ns.IsItemActiveForPlayer(itemConfig) then
            local bestId = BestRankItemId(key)
            local inv = bestId and inventory[bestId] or nil
            if inv and #inv.Bags > 0 then
                local total = TotalItemCount(inv)
                local keep = itemConfig.KeepAtLeast or 0
                local count = math.max(0, total - keep)
                if count > 0 then
                    -- Default true when missing (old saved data).
                    local includeQty = itemConfig.IncludeQuantity
                    if includeQty == nil then
                        includeQty = true
                    end
                    table.insert(
                        entries,
                        {
                            Link = inv.Link or ("[" .. (inv.Name or "?") .. "]"),
                            Name = inv.Name,
                            Count = count,
                            IncludeQuantity = includeQty,
                            Collection = key
                        }
                    )
                end
            end
        end
    end

    -- User-added items, sorted by name.
    local custom = {}
    for id, itemConfig in pairs(ns.DB.Items) do
        if not ns.COLLECTION_META[id] and ns.IsItemActiveForPlayer(itemConfig) then
            local inv = inventory[id]
            if inv and #inv.Bags > 0 then
                local total = TotalItemCount(inv)
                local keep = itemConfig.KeepAtLeast or 0
                local count = math.max(0, total - keep)
                if count > 0 then
                    local includeQty = itemConfig.IncludeQuantity
                    if includeQty == nil then
                        includeQty = true
                    end
                    table.insert(
                        custom,
                        {
                            Link = inv.Link or ("[" .. (inv.Name or "?") .. "]"),
                            Name = inv.Name or tostring(id),
                            Count = count,
                            IncludeQuantity = includeQty,
                            Collection = nil
                        }
                    )
                end
            end
        end
    end
    table.sort(
        custom,
        function(a, b)
            return (a.Name or "") < (b.Name or "")
        end
    )
    for _, entry in ipairs(custom) do
        table.insert(entries, entry)
    end

    return entries
end
