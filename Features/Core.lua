local addonName, ns = ...

local L = ns.L
local COLORS = ns.COLORS

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

-- Shared runtime state. Modules read from and write to this table.
ns.State = {
    Trade = {
        Active = false,
        Class = nil,
        Level = nil,
        Party = false
    },
    MissingStack = false
}

--------------------------------------------------------------------------------
-- Version
--------------------------------------------------------------------------------

local function GetVersion()
    local getMeta = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
    local version = getMeta and getMeta(addonName, "Version")
    if not version or version:find("@") then
        return "Dev"
    end
    return version
end

ns.Version = GetVersion()

--------------------------------------------------------------------------------
-- Chat Output
--------------------------------------------------------------------------------

function ns.PrintMessage(msg, detail)
    local line =
        COLORS.INFO .. L["OPTIONS_TITLE"] .. "|r " .. COLORS.SEP .. "//|r " .. COLORS.TEXT .. tostring(msg) .. "|r"
    if detail then
        line = line .. " " .. COLORS.MUTED .. tostring(detail) .. "|r"
    end
    print(line)
end

--------------------------------------------------------------------------------
-- Class Name Helpers
--------------------------------------------------------------------------------

function ns.GetClassName(class)
    local names = LOCALIZED_CLASS_NAMES_MALE
    return (names and names[class]) or class
end

function ns.GetClassColoredName(class)
    local color = ns.CLASS_COLORS[class] or "FFFFFF"
    return "|cff" .. color .. ns.GetClassName(class) .. "|r"
end

-- Fresh table with every class token from ns.CLASSES set to true. Used
-- both by the v8 migration and by the "Add Item" path so a user-added
-- item is active for every class by default.
function ns.AllClassesEnabled()
    local t = {}
    for _, class in ipairs(ns.CLASSES) do
        t[class] = true
    end
    return t
end

-- True if the given item config should be active for the current player
-- — i.e. its PlayerClasses table includes the player's class. Built-in
-- collections default to a single class (MageWater/MageFood = MAGE,
-- WarlockHealthstone = WARLOCK); user-added items default to all classes.
-- Missing PlayerClasses (e.g. very old saved data) is treated as "all
-- classes" so nothing falls off silently.
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

local function EnsureDefaults(target, defaults)
    for key, default in pairs(defaults) do
        if type(default) == "table" then
            if type(target[key]) ~= "table" then
                target[key] = DeepCopy(default)
            else
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

-- The old saved-variables table was WaterDispenserDB (per-character) with a
-- different schema. We keep it declared in the TOC for one release so we can
-- migrate values off of it, then clear it.
local function MigrateLegacy(newDB)
    local legacy = WaterDispenserDB
    if type(legacy) ~= "table" then
        return
    end
    if newDB._Migrated then
        return
    end

    if legacy.AutoFillSolo ~= nil then
        newDB.AutoFillSolo = legacy.AutoFillSolo
    end
    if legacy.AutoFillGroup ~= nil then
        newDB.AutoFillGroup = legacy.AutoFillGroup
    end
    if legacy.AutoFillRaid ~= nil then
        newDB.AutoFillRaid = legacy.AutoFillRaid
    end
    if legacy.Locked ~= nil then
        newDB.LockedSlot = legacy.Locked
    end

    if type(legacy.Item) == "table" then
        newDB.Items = newDB.Items or {}
        for id, item in pairs(legacy.Item) do
            local copy = DeepCopy(item)
            copy.NoRemove = copy.noRemove or copy.NoRemove
            copy.noRemove = nil
            copy.Icon = copy.icon or copy.Icon
            copy.icon = nil
            copy.name = nil
            copy.UseNotFullStack = copy.UseNotFullStack or false
            copy.Solo = copy.Solo or {}
            copy.Group = copy.Group or {}
            copy.Raid = copy.Raid or {}
            newDB.Items[id] = copy
        end
    end

    newDB._Migrated = true
end

-- Reverts any "item count" configs (Version 4) back to "stack count" configs
-- (v5). Earlier iterations of the addon tried to expose per-item counts to
-- users, but Classic Era 1.15.x's C_Container.SplitContainerItem does not
-- support partial stack pickups from an addon — so we moved back to the
-- original stacks-based model. For each configured item, divide every
-- Solo/Group/Raid class count by the item's max stack size and round to the
-- nearest stack. Falls back to a stack size of 20 when the API cache isn't
-- warm yet, which matches almost every Classic Era / TBC consumable.
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
            local _, _, _, _, _, _, _, maxStack = GetItemInfo(dbKey)
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

-- v5 -> v6: Adds the per-item FactorLevel toggle and KeepAtLeast slider.
-- Both default to off / 0 for previously configured items so existing users
-- see no behavior change until they opt in. Healthstone keep is set to a
-- class-aware default below in InitDB.
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

-- v6 -> v7: Adds the per-item IncludeQuantity toggle. Defaults to true for
-- everything except healthstones, where the announcement reads more
-- naturally without a count ("I have a Greater Healthstone" rather than
-- "...x 1"). Built-in collection keys are matched explicitly so a
-- user-added healthstone-like item still defaults to true.
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

-- v7 -> v8: Adds the per-item PlayerClasses table. Built-in collections
-- get their canonical class restriction via DB_DEFAULTS / EnsureDefaults
-- (mage water and food → MAGE, healthstones → WARLOCK). User-added items
-- default to every class so existing configs keep firing exactly as they
-- did before this filter existed.
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

function ns.InitDB()
    WaterDispenserCharDB = WaterDispenserCharDB or {}
    local db = WaterDispenserCharDB

    MigrateLegacy(db)
    MigrateToStacks(db)
    MigrateAddPerItemRules(db)
    MigrateAddIncludeQuantity(db)
    MigrateAddPlayerClasses(db)
    EnsureDefaults(db, ns.DB_DEFAULTS)

    -- Collection metadata is reset on every load so that localized names and
    -- icon paths follow code changes, not stale saved data.
    for key, meta in pairs(ns.COLLECTION_META) do
        if db.Items[key] then
            db.Items[key].Name = L[meta.NameKey]
            db.Items[key].Icon = meta.Icon
            db.Items[key].NoRemove = true
        end
    end

    ns.DB = db
end

-- Wipes every saved setting on this character back to DB_DEFAULTS. The table
-- reference is preserved so Blizzard still persists the saved variable, and
-- _Migrated is set before re-init so the legacy WaterDispenserDB values do not
-- flow back in and undo the reset.
function ns.ResetToDefaults()
    for key in pairs(WaterDispenserCharDB) do
        WaterDispenserCharDB[key] = nil
    end
    WaterDispenserCharDB._Migrated = true

    ns.InitDB()

    if ns.RebuildItemsOptions then
        ns.RebuildItemsOptions()
    end

    ns.PrintMessage(L["CHAT_RESET"])
end

--------------------------------------------------------------------------------
-- Combat Guard
--------------------------------------------------------------------------------

function ns.IsInCombat()
    return InCombatLockdown()
end

--------------------------------------------------------------------------------
-- AceConfig UI Helpers
--------------------------------------------------------------------------------

-- Shared widget builders so every options file produces identical-looking
-- headers, descriptions, and spacers. Defined in Core so files that load
-- before Options.lua (Dispenser, Announcements, etc.) can also reference
-- them without a circular dependency.
local function Header(text, order)
    return {type = "header", name = COLORS.TITLE .. text .. "|r", order = order}
end

local function Desc(text, order)
    return {type = "description", name = text, fontSize = "medium", order = order}
end

local function Spacer(order)
    return {type = "description", name = " ", order = order}
end

local function SubHeader(text, order)
    return {
        type = "description",
        name = "\n" .. COLORS.TITLE .. text .. "|r",
        fontSize = "medium",
        order = order
    }
end

ns.OptionsHelpers = {
    Header = Header,
    Desc = Desc,
    Spacer = Spacer,
    SubHeader = SubHeader
}

--------------------------------------------------------------------------------
-- Event Dispatcher
--------------------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
local eventHandlers = {}

function ns.RegisterEvent(event, handler)
    if not eventHandlers[event] then
        -- pcall guards against events that exist on some clients but not
        -- others (e.g. LEARNED_SPELL_IN_TAB is valid on Era/Retail but not TBC).
        local ok = pcall(eventFrame.RegisterEvent, eventFrame, event)
        if not ok then
            return
        end
        eventHandlers[event] = {}
    end
    table.insert(eventHandlers[event], handler)
end

eventFrame:SetScript(
    "OnEvent",
    function(_, event, ...)
        local handlers = eventHandlers[event]
        if not handlers then
            return
        end
        for _, handler in ipairs(handlers) do
            handler(event, ...)
        end
    end
)

--------------------------------------------------------------------------------
-- Addon Lifecycle
--------------------------------------------------------------------------------

-- PLAYER_LOGIN is the safe init point: saved variables are loaded, item /
-- spell caches are warm enough for first-pass scans, and any features that
-- register events do so before PLAYER_ENTERING_WORLD fires.
ns.RegisterEvent(
    "PLAYER_LOGIN",
    function()
        ns.InitDB()
        if ns.InitDispenser then
            ns.InitDispenser()
        end
        if ns.InitOptions then
            ns.InitOptions()
        end
        if ns.InitAnnouncements then
            ns.InitAnnouncements()
        end
        if ns.DB.WelcomeMessage then
            ns.PrintMessage(format(L["CHAT_LOADED"], COLORS.INFO .. "/wd|r"))
        end
    end
)

--------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------

local function ParseBool(value, current)
    if value == nil or value == "" then
        return not current
    end
    value = value:lower()
    if value == "on" or value == "1" or value == "true" or value == "enable" then
        return true
    end
    if value == "off" or value == "0" or value == "false" or value == "disable" then
        return false
    end
    return current
end

local function StateWord(b)
    return b and L["CHAT_STATE_ON"] or L["CHAT_STATE_OFF"]
end

local function SlashHandler(msg)
    local args = {}
    for word in (msg or ""):gmatch("%S+") do
        table.insert(args, word:lower())
    end

    local cmd, sub, val = args[1], args[2], args[3]

    if cmd == "fill" then
        if ns.FillTrade then
            ns.FillTrade(true)
        end
        return
    end

    if cmd == "clear" then
        if ns.ClearTrade then
            ns.ClearTrade()
        end
        return
    end

    if cmd == "auto" then
        local key, label
        if sub == "solo" then
            key, label = "AutoFillSolo", L["OPTIONS_AUTOFILL_SOLO"]
        elseif sub == "group" then
            key, label = "AutoFillGroup", L["OPTIONS_AUTOFILL_GROUP"]
        elseif sub == "raid" then
            key, label = "AutoFillRaid", L["OPTIONS_AUTOFILL_RAID"]
        end
        if key then
            ns.DB[key] = ParseBool(val, ns.DB[key])
            ns.PrintMessage(format(L["CHAT_AUTO_SET"], label, StateWord(ns.DB[key])))
            return
        end
    end

    if cmd == "announce" then
        if ns.Announce then
            ns.Announce()
        end
        return
    end

    if ns.OpenOptions then
        ns.OpenOptions()
    end
end

SLASH_WATERDISPENSER1 = "/wd"
SLASH_WATERDISPENSER2 = "/waterdispenser"
SlashCmdList["WATERDISPENSER"] = SlashHandler

-- Short alias used inside the auto-generated announcement macro. Macros have
-- a 255-char body limit and the call site benefits from being terse.
SLASH_WATERDISPENSERANNOUNCE1 = "/wda"
SlashCmdList["WATERDISPENSERANNOUNCE"] = function()
    if ns.Announce then
        ns.Announce()
    end
end
