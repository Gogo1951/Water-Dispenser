local _, ns = ...

local L = ns.L

--------------------------------------------------------------------------------
-- API Compatibility
--------------------------------------------------------------------------------

-- Consumable item class, resolved once. LE_ITEM_CLASS_CONSUMABLE is nil on
-- Classic Era 1.15.8 / TBC 2.5.5, so Enum.ItemClass is the primary source.
ns.CONSUMABLE_ITEM_CLASS = (Enum and Enum.ItemClass and Enum.ItemClass.Consumable) or LE_ITEM_CLASS_CONSUMABLE or 0

-- IsSpellKnown misses some trained ranks on Classic Era, so IsPlayerSpell is a
-- fallback; either returning true counts as known.
function ns.IsSpellLearned(spellId)
    if IsSpellKnown and IsSpellKnown(spellId) then
        return true
    end
    if IsPlayerSpell and IsPlayerSpell(spellId) then
        return true
    end
    return false
end

-- Item and bag APIs resolved once. GetItemInfo keeps a legacy fallback -- the
-- global still exists and works on both Era and TBC.
ns.GetItemInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo

-- The C_Container bag APIs have no legacy fallback: the GetContainerNumSlots /
-- PickupContainerItem / GetContainerItemInfo globals are gone on both target
-- clients (Era 1.15.8 and TBC 2.5.5), so we call C_Container directly. (The
-- positional GetContainerItemInfo global never returned the table shape the
-- scanner reads anyway.)
ns.GetContainerNumSlots = C_Container and C_Container.GetContainerNumSlots
ns.PickupContainerItem = C_Container and C_Container.PickupContainerItem
ns.GetContainerItemInfo = C_Container and C_Container.GetContainerItemInfo

--------------------------------------------------------------------------------
-- Combat Guard
--------------------------------------------------------------------------------

function ns.IsInCombat()
    return InCombatLockdown()
end

--------------------------------------------------------------------------------
-- Colors
--------------------------------------------------------------------------------

-- Escape codes derived from ns.HEX. GetColor returns the prefix; callers
-- append "|r" themselves.
local COLOR_PREFIX = "|cff"
local COLORS = {}
for key, hex in pairs(ns.HEX) do
    COLORS[key] = COLOR_PREFIX .. hex
end

function ns.GetColor(key)
    return COLORS[key] or COLORS.TEXT
end

--------------------------------------------------------------------------------
-- Collection Lookups
--------------------------------------------------------------------------------

-- Reverse-lookups derived from ns.COLLECTIONS (Data/Collections.lua loads
-- first). ITEM_TO_COLLECTION tags a bag item to its collection even when the
-- player doesn't know the conjure spell; ITEM_RANK and ITEM_LEVEL drive
-- best-tier selection and partner-level filtering.
ns.ITEM_TO_COLLECTION = {}
ns.SPELL_TO_COLLECTION = {}
ns.ITEM_RANK = {}
ns.ITEM_LEVEL = {}
for key, c in pairs(ns.COLLECTIONS) do
    for itemId, meta in pairs(c.Items) do
        ns.ITEM_TO_COLLECTION[itemId] = key
        ns.ITEM_RANK[itemId] = meta[1]
        ns.ITEM_LEVEL[itemId] = meta[2]
    end
    for spellId in pairs(c.Spells) do
        ns.SPELL_TO_COLLECTION[spellId] = key
    end
end

--------------------------------------------------------------------------------
-- Class Name Helpers
--------------------------------------------------------------------------------

function ns.GetClassName(class)
    local names = LOCALIZED_CLASS_NAMES_MALE
    return (names and names[class]) or class
end

-- Fresh table with every class token set to true (the default for new items).
function ns.AllClassesEnabled()
    local t = {}
    for _, class in ipairs(ns.CLASSES) do
        t[class] = true
    end
    return t
end

-- True if the item's PlayerClasses includes the player's class. Missing
-- PlayerClasses (very old saved data) counts as all classes.
function ns.IsItemActiveForPlayer(itemConfig)
    if not itemConfig or not itemConfig.PlayerClasses then
        return true
    end
    local _, playerClass = UnitClass("player")
    return itemConfig.PlayerClasses[playerClass] == true
end

--------------------------------------------------------------------------------
-- Table Utilities
--------------------------------------------------------------------------------

local function DeepCopy(value)
    if type(value) ~= "table" then
        return value
    end
    local out = {}
    for k, v in pairs(value) do
        out[k] = DeepCopy(v)
    end
    return out
end
ns.DeepCopy = DeepCopy

-- Keys whose default tables are atomic sets, not deep-merge targets. A class
-- the player unchecks is stored as a missing key, so deep-merging would re-add
-- it every login: seed the whole table once (when the item has none) and never
-- recurse into an existing one.
local ATOMIC_DEFAULT_KEYS = {
    PlayerClasses = true
}

local function EnsureDefaults(target, defaults)
    for key, default in pairs(defaults) do
        if type(default) == "table" then
            if type(target[key]) ~= "table" then
                target[key] = DeepCopy(default)
            elseif not ATOMIC_DEFAULT_KEYS[key] then
                EnsureDefaults(target[key], default)
            end
        elseif target[key] == nil then
            target[key] = default
        end
    end
end
ns.EnsureDefaults = EnsureDefaults

--------------------------------------------------------------------------------
-- Saved Variables
--------------------------------------------------------------------------------

-- v4 (item counts) -> v5 (stack counts): divide each class count by the item's
-- max stack size. Item counts were unworkable because Classic Era's
-- SplitContainerItem can't pick up partial stacks from an addon. Stack size
-- falls back to 20 (almost every Era/TBC consumable) when the cache is cold.
local function MigrateToStacks(db)
    if (db.Version or 0) >= 5 then
        return
    end
    if (db.Version or 0) < 4 then
        -- v3 configs already stored stack counts; just bump the version.
        db.Version = 5
        return
    end

    local function StackSizeFor(dbKey)
        if dbKey == "WarlockHealthstone" then
            return 1
        end
        if dbKey == "MageWater" or dbKey == "MageFood" then
            return 20
        end
        if type(dbKey) == "number" then
            local _, _, _, _, _, _, _, maxStack = ns.GetItemInfo(dbKey)
            return maxStack or 20
        end
        return 20
    end

    for dbKey, itemConfig in pairs(db.Items or {}) do
        local stackSize = StackSizeFor(dbKey)
        if stackSize > 1 then
            for _, scope in ipairs({"Solo", "Group", "Raid"}) do
                local scopeTable = itemConfig[scope]
                if type(scopeTable) == "table" then
                    for class, count in pairs(scopeTable) do
                        if type(count) == "number" and count > 0 then
                            scopeTable[class] = math.floor(count / stackSize + 0.5)
                        end
                    end
                end
            end
        end
        itemConfig.UseNotFullStack = itemConfig.UseNotFullStack or false
    end

    db.Version = 5
end

-- v5 -> v6: add per-item FactorLevel (off) and KeepAtLeast (0) to existing items.
local function MigrateAddPerItemRules(db)
    if (db.Version or 0) >= 6 then
        return
    end
    for _, itemConfig in pairs(db.Items or {}) do
        if itemConfig.FactorLevel == nil then
            itemConfig.FactorLevel = false
        end
        if itemConfig.KeepAtLeast == nil then
            itemConfig.KeepAtLeast = 0
        end
    end
    db.Version = 6
end

-- v6 -> v7: add per-item IncludeQuantity, true for everything but healthstones
-- (which read better without a count).
local function MigrateAddIncludeQuantity(db)
    if (db.Version or 0) >= 7 then
        return
    end
    for key, itemConfig in pairs(db.Items or {}) do
        if itemConfig.IncludeQuantity == nil then
            itemConfig.IncludeQuantity = (key ~= "WarlockHealthstone")
        end
    end
    db.Version = 7
end

-- v7 -> v8: add PlayerClasses to user-added items (all classes). Built-in
-- collections get theirs from DEFAULT_CONFIGURATION via EnsureDefaults.
local function MigrateAddPlayerClasses(db)
    if (db.Version or 0) >= 8 then
        return
    end
    for key, itemConfig in pairs(db.Items or {}) do
        if itemConfig.PlayerClasses == nil and not ns.COLLECTION_META[key] then
            itemConfig.PlayerClasses = ns.AllClassesEnabled()
        end
    end
    db.Version = 8
end

-- v8 -> v9: enable UseNotFullStack for MageWater and MageFood, which come in
-- small stacks at low rank.
local function MigrateConjuredPartialStacks(db)
    if (db.Version or 0) >= 9 then
        return
    end
    for _, key in ipairs({"MageWater", "MageFood"}) do
        local itemConfig = db.Items and db.Items[key]
        if itemConfig then
            itemConfig.UseNotFullStack = true
        end
    end
    db.Version = 9
end

-- v9 -> v10: rename the auto-fill toggles to the "Dispense" branding, carrying
-- each character's existing on/off choice across to the new field.
local function MigrateRenameDispenseFields(db)
    if (db.Version or 0) >= 10 then
        return
    end
    local renames = {
        AutoFill = "Dispense",
        AutoFillSolo = "DispenseSolo",
        AutoFillGroup = "DispenseGroup",
        AutoFillRaid = "DispenseRaid"
    }
    for oldKey, newKey in pairs(renames) do
        if db[newKey] == nil and db[oldKey] ~= nil then
            db[newKey] = db[oldKey]
        end
        db[oldKey] = nil
    end
    db.Version = 10
end

-- v10 -> v11: conjured water/food are dispensed as full stacks only now -- the
-- restack-on-conjure merges their partials in the bags -- so clear the
-- partial-stack flag the v8 -> v9 step had set for them.
local function MigrateConjuredFullStacksOnly(db)
    if (db.Version or 0) >= 11 then
        return
    end
    for _, key in ipairs({"MageWater", "MageFood"}) do
        local itemConfig = db.Items and db.Items[key]
        if itemConfig then
            itemConfig.UseNotFullStack = false
        end
    end
    db.Version = 11
end

function ns.InitDB()
    -- Account-wide table holds the minimap button and the welcome toggle;
    -- per-character holds the rest.
    WaterDispenserDB = WaterDispenserDB or {}
    WaterDispenserDB.minimap = WaterDispenserDB.minimap or {}

    WaterDispenserCharDB = WaterDispenserCharDB or {}
    local db = WaterDispenserCharDB

    -- WelcomeMessage moved per-character -> account-wide. Seed the account value
    -- from this character's legacy per-character setting the first time (so a
    -- disabled preference isn't lost), default on for fresh installs, then clear
    -- the retired per-character key on every character.
    if WaterDispenserDB.WelcomeMessage == nil then
        if db.WelcomeMessage ~= nil then
            WaterDispenserDB.WelcomeMessage = db.WelcomeMessage
        else
            WaterDispenserDB.WelcomeMessage = true
        end
    end
    db.WelcomeMessage = nil

    MigrateToStacks(db)
    MigrateAddPerItemRules(db)
    MigrateAddIncludeQuantity(db)
    MigrateAddPlayerClasses(db)
    MigrateConjuredPartialStacks(db)
    MigrateRenameDispenseFields(db)
    MigrateConjuredFullStacksOnly(db)
    EnsureDefaults(db, ns.DEFAULT_CONFIGURATION)

    -- Retired flag from a dropped migration.
    db._Migrated = nil

    -- Refresh collection name/icon every load so they follow code, not stale data.
    for key, meta in pairs(ns.COLLECTION_META) do
        if db.Items[key] then
            db.Items[key].Name = L[meta.NameKey]
            db.Items[key].Icon = meta.Icon
            db.Items[key].NoRemove = true
        end
    end

    ns.DB = db
end

-- Wipes this character's settings back to defaults, preserving the table
-- reference so it still persists. Account-wide data (minimap) is untouched.
function ns.ResetToDefaults()
    for key in pairs(WaterDispenserCharDB) do
        WaterDispenserCharDB[key] = nil
    end

    ns.InitDB()

    if ns.RebuildDistributionRulesOptions then
        ns.RebuildDistributionRulesOptions()
    end

    -- Reset re-enables announcements by default; resync the macro now rather
    -- than waiting for the next bag event.
    if ns.RefreshAnnouncementMacro then
        ns.RefreshAnnouncementMacro()
    end

    ns.PrintMessage(L["CHAT_RESET"])
end
