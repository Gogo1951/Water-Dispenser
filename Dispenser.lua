local _, ns = ...

local L = ns.L
local COLORS = ns.COLORS

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

local ICON_COORDS = ns.ICON_COORDS

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

-- Inventory cache. Rebuilt on demand by ScanInventory().
local inventory = nil
local lockbox = nil

-- Side UI frame. Created once on first trade.
local tradeUI

-- Set to true when FillTrade was requested but skipped due to combat.
local pendingCombatFill = false

--------------------------------------------------------------------------------
-- API Compatibility
--------------------------------------------------------------------------------

local function GetSpellName(spellId)
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellId)
        if info and info.name then
            return info.name
        end
    end
    if GetSpellInfo then
        return (GetSpellInfo(spellId))
    end
    return nil
end

local function GetSpellRank(spellId)
    if C_Spell and C_Spell.GetSpellSubtext then
        return C_Spell.GetSpellSubtext(spellId)
    end
    if GetSpellSubtext then
        return GetSpellSubtext(spellId)
    end
    return nil
end

local function IsSpellLearned(spellId)
    if IsSpellKnown then
        return IsSpellKnown(spellId)
    end
    return false
end

--------------------------------------------------------------------------------
-- Inventory Scan
--------------------------------------------------------------------------------

local function ClearInventory()
    inventory = nil
    lockbox = nil
end
ns.ClearInventory = ClearInventory

-- Scans bags for consumables and builds the inventory table.
-- Each inventory entry has a Bags list of { Bag, Slot, Count } describing
-- exactly how many items live in each occupied bag slot. FillTrade walks
-- this list and can split partial stacks to place arbitrary item counts.
-- Returns true if the inventory changed in a way that may affect a fill.
--
-- Collection tagging: every bag-scanned item is checked against
-- ns.ITEM_TO_COLLECTION. If the item is part of a built-in collection, the
-- inventory entry is tagged with Collection / Rank regardless of whether
-- the player knows the matching conjure spell. This is what lets a non-mage
-- with Conjured Crystal Water in their bags announce it as MageWater, and
-- it's also why a mage's announcement reliably populates even if their
-- spell book is in a weird state.
local function ScanInventory()
    local previous = inventory
    inventory = {}
    lockbox = nil

    -- Seed collection entries from the spell side: for each conjure spell
    -- the player knows, find the canonical item ID at that rank and create
    -- an inventory placeholder. The placeholder stays empty until the bag
    -- scan below fills in actual bag entries. The seed is only what makes
    -- "you have nothing in your bags but can conjure this" work in the
    -- trade UI; the bag scan is the source of truth for everything else.
    local function PrimaryItemForRank(collection, targetRank)
        local primary
        for itemId, rank in pairs(collection.Items) do
            if rank == targetRank and (not primary or itemId < primary) then
                primary = itemId
            end
        end
        return primary
    end

    for collectionKey, c in pairs(ns.COLLECTIONS) do
        local rankLevels = ns.COLLECTION_RANK_LEVELS[collectionKey]
        for spellId, rank in pairs(c.Spells) do
            if IsSpellLearned(spellId) then
                local itemId = PrimaryItemForRank(c, rank)
                if itemId then
                    local itemName, itemLink, _, _, itemMinLevel, _, _, _, _, itemIcon = GetItemInfo(itemId)
                    if itemName then
                        inventory[itemId] = {
                            Id = itemId,
                            Link = itemLink,
                            Name = itemName,
                            Icon = itemIcon,
                            Level = (rankLevels and rankLevels[rank]) or itemMinLevel or 0,
                            Collection = collectionKey,
                            Rank = rank,
                            SpellId = spellId,
                            Bags = {}
                        }
                    end
                end
            end
        end
    end

    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        local slots = C_Container.GetContainerNumSlots(bag)
        for slot = 1, slots do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info then
                local itemId = info.itemID
                local hasLoot = info.hasLoot

                if hasLoot and not lockbox then
                    -- Any lootable bag item is considered potentially locked.
                    -- A full tooltip scan would be more accurate, but the
                    -- rogue-trade flow is user-initiated and they'll notice
                    -- if the item they got offered isn't a lockbox.
                    lockbox = {Bag = bag, Slot = slot}
                end

                local itemName, _, _, _, itemMinLevel, _, _, itemStackCount, _, itemIcon, _, itemClassID, _, bindType =
                    GetItemInfo(itemId)

                if itemClassID == LE_ITEM_CLASS_CONSUMABLE and bindType == 0 then
                    -- Bucket inventory entries by item ID. Different ranks
                    -- of the same collection live in separate entries;
                    -- BestRankItemId picks the highest rank across entries
                    -- when consumers need a single answer.
                    local collectionKey = ns.ITEM_TO_COLLECTION[itemId]
                    local rank = collectionKey and ns.ITEM_RANK[itemId] or nil
                    local rankLevels = collectionKey and ns.COLLECTION_RANK_LEVELS[collectionKey]
                    local effectiveLevel = (rankLevels and rank and rankLevels[rank]) or itemMinLevel or 0

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
                        -- Backfill collection metadata onto the spell-seeded
                        -- entry so a player who has the item but not the
                        -- spell still gets tagged correctly.
                        if collectionKey and not inventory[itemId].Collection then
                            inventory[itemId].Collection = collectionKey
                            inventory[itemId].Rank = rank
                        end
                        if not inventory[itemId].Link then
                            inventory[itemId].Link = info.hyperlink
                        end
                    end

                    local slotCount = info.stackCount or 0
                    table.insert(
                        inventory[itemId].Bags,
                        {
                            Bag = bag,
                            Slot = slot,
                            Count = slotCount,
                            Full = itemStackCount and slotCount == itemStackCount or false
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

--------------------------------------------------------------------------------
-- Trade Filling
--------------------------------------------------------------------------------

-- Returns the inventory item ID of the highest-rank entry in the given
-- collection that the player currently has stacks of, or nil if none.
-- When `levelLimit` is non-nil, only entries usable by a partner of that
-- level are considered. Rank comes from ns.ITEM_RANK (the index in the
-- collection's Items list) — more reliable than itemMinLevel from
-- GetItemInfo, which can be 0 or stale for some conjured items.
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
    return bestId
end

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

-- Classic Era 1.15.x limitation: C_Container.SplitContainerItem silently
-- ignores its `count` argument when called from an addon — it picks up the
-- whole stack regardless. The legacy global SplitContainerItem has been
-- removed. Partial stack splits are therefore not possible from an addon,
-- so trade fill is done one whole bag slot at a time. Each bag slot counts
-- as one "stack" for configuration purposes regardless of how many items
-- it actually contains.
local function PickupWhole(bag, slot)
    if C_Container and C_Container.PickupContainerItem then
        C_Container.PickupContainerItem(bag, slot)
        return
    end
    if PickupContainerItem then
        PickupContainerItem(bag, slot)
    end
end

-- Places the entire contents of (bag, slot) into the next available trade
-- slot. Returns true on success, false if no trade slot was open.
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

    local changed = ScanInventory()
    if not changed and not forced then
        return
    end

    ns.State.MissingStack = false
    if forced then
        ns.ClearTrade()
    end

    -- Rogue locked-item slot: place the lockbox into the non-traded slot.
    if ns.DB.LockedSlot and lockbox and trade.Class == "ROGUE" then
        ClearCursor()
        PickupWhole(lockbox.Bag, lockbox.Slot)
        ClickTradeButton(TRADE_ENCHANT_SLOT)
    end

    local scope = PickScope()

    for configId, itemConfig in pairs(ns.DB.Items) do
        local needed = ns.IsItemActiveForPlayer(itemConfig) and CountForScope(itemConfig, scope, trade.Class) or 0

        if needed > 0 then
            local inv, isBestOverall
            if ns.COLLECTIONS[configId] then
                -- For built-in collections, FactorLevel filters the rank
                -- we resolve to: with it on we pick the highest rank the
                -- partner can use; with it off we pick the highest rank
                -- the player has, period. The bestOverallId comparison
                -- below decides whether KeepAtLeast applies — it only
                -- protects the player's top-tier stash.
                -- Belt-and-braces: only apply the level filter when we
                -- actually have a positive partner level. A stray 0 here
                -- would silently exclude every real rank.
                local levelLimit = (itemConfig.FactorLevel and trade.Level and trade.Level > 0) and trade.Level or nil
                local resolvedItemId = BestRankItemId(configId, levelLimit)
                local bestOverallId = BestRankItemId(configId, nil)
                inv = resolvedItemId and inventory[resolvedItemId] or nil
                isBestOverall = (resolvedItemId ~= nil) and (resolvedItemId == bestOverallId)
            else
                -- User-added item: a single concrete item ID, so the
                -- level filter has to fire here directly. There's no
                -- "alternative rank" to fall back to.
                inv = inventory[configId]
                isBestOverall = true
                if itemConfig.FactorLevel and trade.Level then
                    local requiredLevel = inv and inv.Level
                    if not requiredLevel and type(configId) == "number" then
                        local _, _, _, _, itemMinLevel = GetItemInfo(configId)
                        requiredLevel = itemMinLevel
                    end
                    if requiredLevel and requiredLevel > trade.Level then
                        needed = 0
                    end
                end
            end

            -- "Keep at Least N" is measured in individual items, matching
            -- both the announcement macro and how the slider reads in
            -- plain English. Only applies when filling from the
            -- best-overall rank: lower-rank conjures (the leftover lowbie
            -- water in a max-level mage's bags) are pure giveaway material
            -- and aren't worth reserving. Each placed stack is checked
            -- inline so a stack that would dip us below the reserve is
            -- skipped instead of capping the count up front.
            local keep = (isBestOverall and (itemConfig.KeepAtLeast or 0)) or 0
            local remaining = inv and TotalItemCount(inv) or 0

            if needed > 0 and inv then
                -- Place full stacks first, one bag slot per "stack" in the
                -- configuration. Each placement fills one trade slot.
                for _, bagEntry in ipairs(inv.Bags) do
                    if needed <= 0 then
                        break
                    end
                    if bagEntry.Full then
                        local count = bagEntry.Count or 0
                        if remaining - count >= keep then
                            if not PlaceStack(bagEntry.Bag, bagEntry.Slot) then
                                break
                            end
                            needed = needed - 1
                            remaining = remaining - count
                        end
                    end
                end

                -- If still short and the item allows partial fills, use
                -- smaller stacks as substitutes. Each partial stack still
                -- counts as one "stack" toward the configured count.
                if needed > 0 and itemConfig.UseNotFullStack then
                    for _, bagEntry in ipairs(inv.Bags) do
                        if needed <= 0 then
                            break
                        end
                        if not bagEntry.Full and (bagEntry.Count or 0) > 0 then
                            local count = bagEntry.Count or 0
                            if remaining - count >= keep then
                                if not PlaceStack(bagEntry.Bag, bagEntry.Slot) then
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
                -- MissingStack flag is always set so OnBagUpdate can retry
                -- the fill once the player restocks. The chat warning is
                -- gated by an explicit user opt-in.
                ns.State.MissingStack = true
                if ns.DB.MissingStackWarnings then
                    ReportMissing(itemConfig, inv, needed)
                end

                if inv and inv.SpellId and inv.Collection and tradeUI and tradeUI.CollectionButtons[inv.Collection] then
                    tradeUI.CollectionButtons[inv.Collection]:SetSpell(inv.SpellId)
                end
            end
        end
    end

    -- Rogue pick-lock convenience button.
    if IsSpellLearned(ns.SPELL_PICK_LOCK) and tradeUI and tradeUI.PickLockButton then
        tradeUI.PickLockButton:SetSpell(ns.SPELL_PICK_LOCK)
    end
end

--------------------------------------------------------------------------------
-- Trade UI Frame
--------------------------------------------------------------------------------

-- Creates a plain UIPanelButton attached to the parent frame.
local function MakeButton(parent, anchorTo, anchorPos, yOffset, secure)
    local template = secure and "UIPanelButtonTemplate,SecureActionButtonTemplate" or "UIPanelButtonTemplate"
    local button = CreateFrame("Button", nil, parent, template)
    button:SetPoint("TOPLEFT", anchorTo, anchorPos or "BOTTOMLEFT", 0, yOffset or 0)
    button:SetSize(160, 22)
    return button
end

-- Assigns a /cast macro to a secure button. Skipped during combat to avoid
-- protected SetAttribute errors; the caller can retry on PLAYER_REGEN_ENABLED.
local function SecureButton_SetSpell(self, spellId)
    if ns.IsInCombat() then
        self._PendingSpell = spellId
        return
    end
    self._PendingSpell = nil

    local name = GetSpellName(spellId)
    if not name then
        self:Hide()
        return
    end

    local rank = GetSpellRank(spellId)
    local castLine = (rank and rank ~= "") and (name .. "(" .. rank .. ")") or name

    self:SetAttribute("type", "macro")
    self:SetAttribute("macrotext", "/cast " .. castLine)
    self:SetText(castLine)
    self:SetWidth(math.max(160, self:GetTextWidth() + 30))
    self:Show()
end

local function CreateTradeUI()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(180, 220)
    frame:EnableMouse(false)
    frame:Hide()

    local btnClear = MakeButton(frame, frame, "TOPLEFT", 0, false)
    btnClear:SetText(L["BTN_CLEAR"])
    btnClear:SetScript(
        "OnClick",
        function()
            ns.ClearTrade()
        end
    )

    local btnFill = MakeButton(frame, btnClear, "BOTTOMLEFT", -2, false)
    btnFill:SetText(L["BTN_FILL"])
    btnFill:SetScript(
        "OnClick",
        function()
            ns.FillTrade(true)
        end
    )

    local btnConfig = MakeButton(frame, btnFill, "BOTTOMLEFT", -2, false)
    btnConfig:SetText(L["BTN_CONFIG"])
    btnConfig:SetScript(
        "OnClick",
        function()
            if ns.OpenOptions then
                ns.OpenOptions()
            end
        end
    )

    local btnAccept = MakeButton(frame, btnConfig, "BOTTOMLEFT", -6, false)
    btnAccept:SetText(L["BTN_ACCEPT"])
    btnAccept:SetScript(
        "OnClick",
        function()
            AcceptTrade()
        end
    )

    -- Secure buttons for casting missing conjurables / pick-lock.
    local btnSpell1 = MakeButton(frame, btnAccept, "BOTTOMLEFT", -6, true)
    local btnSpell2 = MakeButton(frame, btnSpell1, "BOTTOMLEFT", -2, true)
    local btnSpell3 = MakeButton(frame, btnSpell2, "BOTTOMLEFT", -2, true)

    for _, b in ipairs({btnSpell1, btnSpell2, btnSpell3}) do
        b.SetSpell = SecureButton_SetSpell
        b:Hide()
    end

    frame.CollectionButtons = {
        MageWater = btnSpell1,
        MageFood = btnSpell2,
        WarlockHealthstone = btnSpell3
    }
    frame.PickLockButton = btnSpell3

    function frame:Attach(parent)
        self:SetParent(parent)
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", parent, "TOPRIGHT", 2, 0)
        self:Show()
        btnSpell1:Hide()
        btnSpell2:Hide()
        btnSpell3:Hide()
    end

    function frame:Detach()
        self:SetParent(UIParent)
        self:Hide()
    end

    -- Re-applies any spell assignments that were deferred during combat.
    function frame:FlushPendingSpells()
        for _, b in ipairs({btnSpell1, btnSpell2, btnSpell3}) do
            if b._PendingSpell then
                b:SetSpell(b._PendingSpell)
            end
        end
    end

    return frame
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
    -- UnitLevel returns nil (can't resolve), -1 (level too far above to
    -- estimate), or sometimes 0 in the brief window before the unit's data
    -- finishes loading. Any of those means "unknown"; fall back to the
    -- player's level + 10 so the level filter doesn't lock everything out.
    if not trade.Level or trade.Level <= 0 then
        trade.Level = UnitLevel("player") + 10
    end
    trade.Party = UnitInParty("NPC") or UnitInRaid("NPC")

    if tradeUI then
        tradeUI:Attach(TradeFrame)
    end
    ClearInventory()

    local autoKey = "AutoFillSolo"
    if trade.Party then
        autoKey = IsInRaid() and "AutoFillRaid" or "AutoFillGroup"
    end

    if ns.DB[autoKey] then
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
    ClearInventory()
    if tradeUI then
        tradeUI:Detach()
    end
end

local function OnBagUpdate()
    if not ns.State.Trade.Active then
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

local function OnCombatStart()
    -- Secure-button attribute changes are disallowed during combat, so the
    -- cast shortcuts are hidden rather than updated mid-trade.
    if tradeUI then
        tradeUI.CollectionButtons.MageWater:Hide()
        tradeUI.CollectionButtons.MageFood:Hide()
        tradeUI.CollectionButtons.WarlockHealthstone:Hide()
    end
end

local function OnCombatEnd()
    if not ns.State.Trade.Active then
        return
    end

    if tradeUI then
        tradeUI:FlushPendingSpells()
    end

    if pendingCombatFill then
        pendingCombatFill = false
        ns.PrintMessage(L["CHAT_COMBAT_RESUMED"])
        ns.FillTrade(false)
    end
end

local function OnSpellsChanged()
    -- Pre-warm the item cache so GetItemInfo returns synchronously later.
    -- We touch every collection item (not just the ones the player can
    -- conjure) so a non-mage with mage water in their bags still gets
    -- proper item info on the very first ScanInventory.
    for _, c in pairs(ns.COLLECTIONS) do
        for itemId in pairs(c.Items) do
            GetItemInfo(itemId)
        end
    end
    if ns.DB and ns.DB.Items then
        for id in pairs(ns.DB.Items) do
            local numericId = tonumber(id)
            if numericId then
                GetItemInfo(numericId)
            end
        end
    end
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function ns.InitDispenser()
    tradeUI = CreateTradeUI()
    ns.TradeUI = tradeUI

    ns.RegisterEvent("TRADE_SHOW", OnTradeShow)
    ns.RegisterEvent("TRADE_CLOSED", OnTradeClosed)
    ns.RegisterEvent("BAG_UPDATE", OnBagUpdate)
    ns.RegisterEvent("PLAYER_REGEN_DISABLED", OnCombatStart)
    ns.RegisterEvent("PLAYER_REGEN_ENABLED", OnCombatEnd)
    ns.RegisterEvent("SPELLS_CHANGED", OnSpellsChanged)
    ns.RegisterEvent("LEARNED_SPELL_IN_TAB", OnSpellsChanged)
end

--------------------------------------------------------------------------------
-- Public Inventory Access for Options
--------------------------------------------------------------------------------

function ns.GetAvailableItemsToAdd()
    ScanInventory()
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

-- Sums actual item counts across every bag entry for an inventory item.
-- This is what the announcement reports — "x 200" means 200 individual
-- bottles of water, not 10 stacks of 20.
local function TotalItemCount(inv)
    local total = 0
    for _, bagEntry in ipairs(inv.Bags) do
        total = total + (bagEntry.Count or 0)
    end
    return total
end

-- Returns a list of giveaway entries for the announcement macro. Order in
-- the returned list matches the order in which items would be filled into a
-- trade: collections first (in built-in order: water, food, healthstones)
-- then user-added items alphabetically.
--
-- Each entry: { Link, Name, Count, IncludeQuantity, Collection }
--   Count is the total number of individual items currently giveable, i.e.
--   the sum of stack counts across bag slots minus the item's KeepAtLeast
--   value. Items where the player has nothing left to give after
--   subtracting Keep are omitted.
--   IncludeQuantity is the per-item toggle from the options panel. When
--   false the announcement says "[Greater Healthstone]" with no count;
--   when true it says "[Conjured Crystal Water] x 200".
function ns.BuildAnnouncementSnapshot()
    ScanInventory()

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
                    -- IncludeQuantity defaults to true if missing so that an
                    -- old saved-variables file without the field still
                    -- announces with counts. The migration backfills this,
                    -- but defending against nil is cheap.
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