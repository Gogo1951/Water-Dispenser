local _, ns = ...

local L = ns.L
local COLORS = ns.COLORS
local CLASS_COLORS = ns.CLASS_COLORS

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local Desc = ns.OptionsHelpers.Desc
local Spacer = ns.OptionsHelpers.Spacer

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local itemsAppName
local selectedItemToAdd

--------------------------------------------------------------------------------
-- Slider bounds
--------------------------------------------------------------------------------

-- Stacks-per-class sliders are capped at 6; more than six stacks of any one
-- consumable per player is vanishingly rare in practice and a lower cap gives
-- the sliders meaningful granularity.
local STACK_MIN = 0
local STACK_MAX = 6

--------------------------------------------------------------------------------
-- Class Ordering (alphabetical by localized name)
--------------------------------------------------------------------------------

-- ns.CLASSES is the file-order list (Warrior, Paladin, Hunter, ...). The new
-- layout sorts classes alphabetically by their localized name so that the
-- slider stack reads naturally top-to-bottom.
local function GetSortedClasses()
    local list = {}
    for _, class in ipairs(ns.CLASSES) do
        table.insert(list, class)
    end
    table.sort(
        list,
        function(a, b)
            return ns.GetClassName(a) < ns.GetClassName(b)
        end
    )
    return list
end

--------------------------------------------------------------------------------
-- Item Key Encoding
--------------------------------------------------------------------------------

-- AceConfig requires string keys in an args table. Built-in item keys are
-- already strings ("MageWater") but user-added items are keyed by their
-- numeric item ID in the DB. We prefix those with "item_" for use as arg keys
-- and strip the prefix back off when looking them up in the DB.

local function EncodeItemKey(dbKey)
    if type(dbKey) == "number" then
        return "item_" .. tostring(dbKey)
    end
    return dbKey
end

local function DecodeItemKey(argKey)
    local numId = type(argKey) == "string" and argKey:match("^item_(%d+)$")
    if numId then
        return tonumber(numId)
    end
    return argKey
end

--------------------------------------------------------------------------------
-- Display Helpers
--------------------------------------------------------------------------------

local function ItemDisplayName(itemId, itemConfig)
    local icon = itemConfig.Icon
    local name = itemConfig.Name
    if not name then
        local itemName, _, _, _, _, _, _, _, _, itemIcon = GetItemInfo(itemId)
        name = itemName or tostring(itemId)
        icon = icon or itemIcon
    end
    local iconTag = icon and ("|T" .. icon .. ":16|t ") or ""
    return iconTag .. name
end

local function ClassLabel(class)
    local color = CLASS_COLORS[class] or "FFFFFF"
    return "|cff" .. color .. ns.GetClassName(class) .. "|r"
end

--------------------------------------------------------------------------------
-- Item Config Accessors
--------------------------------------------------------------------------------

-- Options args are nested as:
--     [itemKey] -> [scopeKey] -> [classField]
-- where scopeKey is "solo" / "group" / "raid" and classField is the raw
-- class token ("HUNTER", "MAGE", ...). info[1] is the item key, info[2] is
-- the scope node, and info[#info] is the slider field.

local SCOPE_DB_KEY = {
    solo = "Solo",
    group = "Group",
    raid = "Raid"
}

local function GetItemConfig(info)
    local itemKey = DecodeItemKey(info[1])
    return ns.DB.Items[itemKey]
end

local function GetCountValue(info)
    local config = GetItemConfig(info)
    if not config then
        return 0
    end
    local scopeKey = SCOPE_DB_KEY[info[2]]
    local class = info[#info]
    if not scopeKey or not class then
        return 0
    end
    return (config[scopeKey] and config[scopeKey][class]) or 0
end

local function SetCountValue(info, value)
    local config = GetItemConfig(info)
    if not config then
        return
    end
    local scopeKey = SCOPE_DB_KEY[info[2]]
    local class = info[#info]
    if not scopeKey or not class then
        return
    end
    config[scopeKey] = config[scopeKey] or {}
    -- Coerce to an integer so we never write e.g. 3.0 into the saved vars.
    config[scopeKey][class] = math.floor((tonumber(value) or 0) + 0.5)
end

local function GetUseNotFullStack(info)
    local config = GetItemConfig(info)
    return config and config.UseNotFullStack or false
end

local function SetUseNotFullStack(info, value)
    local config = GetItemConfig(info)
    if config then
        config.UseNotFullStack = value and true or false
    end
end

local function GetFactorLevel(info)
    local config = GetItemConfig(info)
    return config and config.FactorLevel or false
end

local function SetFactorLevel(info, value)
    local config = GetItemConfig(info)
    if config then
        config.FactorLevel = value and true or false
    end
end

local function GetKeepAtLeast(info)
    local config = GetItemConfig(info)
    return (config and tonumber(config.KeepAtLeast)) or 0
end

local function SetKeepAtLeast(info, value)
    local config = GetItemConfig(info)
    if config then
        config.KeepAtLeast = math.floor((tonumber(value) or 0) + 0.5)
    end
    -- Live-update the announcement macro so a slider move is reflected in
    -- the next click instead of waiting for a bag event.
    if ns.RefreshAnnouncementMacro then
        ns.RefreshAnnouncementMacro()
    end
end

local function GetIncludeQuantity(info)
    local config = GetItemConfig(info)
    if not config then
        return true
    end
    -- Defaults to true when nil so a freshly-added item or a saved-vars
    -- file that pre-dates this toggle still announces with counts.
    if config.IncludeQuantity == nil then
        return true
    end
    return config.IncludeQuantity and true or false
end

local function SetIncludeQuantity(info, value)
    local config = GetItemConfig(info)
    if config then
        config.IncludeQuantity = value and true or false
    end
    -- Live-update the announcement macro so the change is visible in
    -- chat without waiting for the next bag event.
    if ns.RefreshAnnouncementMacro then
        ns.RefreshAnnouncementMacro()
    end
end

-- Player-class filter accessors. info[#info] is the class token (e.g.
-- "MAGE") since each class is a separate toggle widget keyed by its token.
local function GetPlayerClass(info)
    local config = GetItemConfig(info)
    if not config or not config.PlayerClasses then
        return false
    end
    return config.PlayerClasses[info[#info]] == true
end

local function SetPlayerClass(info, value)
    local config = GetItemConfig(info)
    if not config then
        return
    end
    config.PlayerClasses = config.PlayerClasses or {}
    -- Store nil instead of false so a freshly migrated table looks the
    -- same as one set explicitly via the UI.
    config.PlayerClasses[info[#info]] = value and true or nil
    if ns.RefreshAnnouncementMacro then
        ns.RefreshAnnouncementMacro()
    end
end

--------------------------------------------------------------------------------
-- Scope Panels
--------------------------------------------------------------------------------

-- Each scope (Strangers / Party Members / Raid Members) is its own sub-group
-- in the left sidebar. The body is a vertical stack of one full-width slider
-- per class, in alphabetical order, capped at STACK_MAX.
local function BuildScopePanel(scopeLabel, order)
    local args = {}
    local sortedClasses = GetSortedClasses()
    for index, class in ipairs(sortedClasses) do
        args[class] = {
            type = "range",
            width = "full",
            name = ClassLabel(class),
            min = STACK_MIN,
            max = STACK_MAX,
            step = 1,
            order = index,
            get = GetCountValue,
            set = SetCountValue
        }
    end

    return {
        type = "group",
        name = scopeLabel,
        order = order,
        args = args
    }
end

--------------------------------------------------------------------------------
-- Settings Sub-Panel
--------------------------------------------------------------------------------

-- Holds the per-item switches that used to live on the same page as the
-- sliders. Remove is optional: built-in collections (MageWater, MageFood,
-- WarlockHealthstone) have NoRemove = true and skip the button.
local function BuildSettingsPanel(itemKey, itemConfig, order)
    local args = {
        UseNotFullStack = {
            type = "toggle",
            width = "full",
            name = L["OPTIONS_ITEM_USE_NOT_FULL"],
            desc = L["OPTIONS_ITEM_USE_NOT_FULL_DESC"],
            order = 1,
            get = GetUseNotFullStack,
            set = SetUseNotFullStack
        },
        FactorLevel = {
            type = "toggle",
            width = "full",
            name = L["OPTIONS_ITEM_FACTOR_LEVEL"],
            desc = L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"],
            order = 2,
            get = GetFactorLevel,
            set = SetFactorLevel
        },
        spaceKeep = Spacer(3),
        KeepAtLeast = {
            type = "range",
            width = "full",
            name = L["OPTIONS_ITEM_KEEP_AT_LEAST"],
            desc = L["OPTIONS_ITEM_KEEP_AT_LEAST_DESC"],
            -- Range starts at 0 even though the user spec said 1-100, because
            -- warlocks' default for healthstones is 0 (they can summon more).
            min = 0,
            max = 100,
            step = 1,
            order = 4,
            get = GetKeepAtLeast,
            set = SetKeepAtLeast
        },
        spaceQty = Spacer(5),
        IncludeQuantity = {
            type = "toggle",
            width = "full",
            name = L["OPTIONS_ITEM_INCLUDE_QUANTITY"],
            desc = L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"],
            order = 6,
            get = GetIncludeQuantity,
            set = SetIncludeQuantity
        },
        spaceClasses0 = Spacer(7),
        descClasses = Desc(L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"], 8),
        spaceClasses1 = Spacer(9),
        playerClasses = (function()
            local classArgs = {}
            for index, class in ipairs(GetSortedClasses()) do
                classArgs[class] = {
                    type = "toggle",
                    name = ClassLabel(class),
                    order = index,
                    get = GetPlayerClass,
                    set = SetPlayerClass
                }
            end
            return {
                type = "group",
                name = L["OPTIONS_ITEM_PLAYER_CLASSES"],
                inline = true,
                order = 10,
                args = classArgs
            }
        end)()
    }

    if not itemConfig.NoRemove then
        args.spaceRemove = Spacer(20)
        args.remove = {
            type = "execute",
            name = L["OPTIONS_ITEM_REMOVE"],
            order = 21,
            confirm = true,
            confirmText = L["OPTIONS_ITEM_REMOVE_CONFIRM"],
            func = function()
                local name = itemConfig.Name or tostring(itemKey)
                ns.DB.Items[itemKey] = nil
                ns.PrintMessage(L["CHAT_ITEM_REMOVED"], name)
                ns.RebuildItemsOptions()
            end
        }
    end

    return {
        type = "group",
        name = L["OPTIONS_ITEM_SETTINGS"],
        order = order,
        args = args
    }
end

--------------------------------------------------------------------------------
-- Item Panel Builder
--------------------------------------------------------------------------------

-- Each item becomes a tree node in the left sidebar. Its children are the
-- three scope panels plus a Settings panel. childGroups = "tree" makes the
-- scope/settings entries appear as a nested sidebar under the item.
local function BuildItemPanel(itemKey, itemConfig, order)
    return {
        type = "group",
        name = ItemDisplayName(itemKey, itemConfig),
        order = order,
        childGroups = "tree",
        args = {
            solo = BuildScopePanel(L["OPTIONS_SCOPE_SOLO"], 1),
            group = BuildScopePanel(L["OPTIONS_SCOPE_GROUP"], 2),
            raid = BuildScopePanel(L["OPTIONS_SCOPE_RAID"], 3),
            settings = BuildSettingsPanel(itemKey, itemConfig, 4)
        }
    }
end

--------------------------------------------------------------------------------
-- Add Item Panel
--------------------------------------------------------------------------------

local function BuildAddableValues()
    local available = ns.GetAvailableItemsToAdd()
    local values = {}
    for _, entry in ipairs(available) do
        local icon = entry.Icon and ("|T" .. entry.Icon .. ":16|t ") or ""
        values[tostring(entry.Id)] = icon .. entry.Name
    end
    return values
end

local function HasAddableItems()
    return next(BuildAddableValues()) ~= nil
end

local function NoAddableItems()
    return not HasAddableItems()
end

local function BuildAddItemPanel(order)
    -- The picker (dropdown + spacers + add button) is hidden when no items
    -- qualify, so the player sees the empty-bag notice instead of an empty
    -- dropdown. Spacers must be inlined here because the Spacer() helper
    -- does not support `hidden`.
    return {
        type = "group",
        name = L["OPTIONS_ADD_ITEM"],
        order = order,
        args = {
            desc = Desc(L["OPTIONS_ADD_DESC"], 1),
            spaceSelect = {type = "description", name = " ", order = 2, hidden = NoAddableItems},
            selectItem = {
                type = "select",
                style = "dropdown",
                name = L["OPTIONS_ADD_SELECT"],
                width = "double",
                order = 3,
                values = BuildAddableValues,
                hidden = NoAddableItems,
                get = function()
                    return selectedItemToAdd
                end,
                set = function(_, value)
                    selectedItemToAdd = value
                end
            },
            spaceAdd = {type = "description", name = " ", order = 4, hidden = NoAddableItems},
            addButton = {
                type = "execute",
                name = L["OPTIONS_ADD_BUTTON"],
                order = 5,
                hidden = NoAddableItems,
                disabled = function()
                    return not selectedItemToAdd
                end,
                func = function()
                    local id = tonumber(selectedItemToAdd)
                    if not id then
                        return
                    end

                    local itemName, _, _, _, _, _, _, _, _, itemIcon = GetItemInfo(id)
                    local empty = {}
                    for _, class in ipairs(ns.CLASSES) do
                        empty[class] = 0
                    end

                    ns.DB.Items[id] = {
                        Name = itemName or ("Item " .. id),
                        Icon = itemIcon,
                        UseNotFullStack = false,
                        FactorLevel = false,
                        KeepAtLeast = 0,
                        IncludeQuantity = true,
                        PlayerClasses = ns.AllClassesEnabled(),
                        Solo = ns.DeepCopy(empty),
                        Group = ns.DeepCopy(empty),
                        Raid = ns.DeepCopy(empty)
                    }
                    ns.PrintMessage(L["CHAT_ITEM_SAVED"], itemName or tostring(id))
                    selectedItemToAdd = nil
                    ns.RebuildItemsOptions()
                end
            },
            spaceEmpty = {type = "description", name = " ", order = 6, hidden = HasAddableItems},
            emptyNotice = {
                type = "description",
                fontSize = "medium",
                order = 7,
                name = COLORS.DESC .. L["OPTIONS_ADD_EMPTY"] .. "|r",
                hidden = HasAddableItems
            }
        }
    }
end

--------------------------------------------------------------------------------
-- Root Items Options Table
--------------------------------------------------------------------------------

local function BuildItemList()
    local list = {}

    -- Built-in collections first, in stable display order.
    for _, key in ipairs(ns.BUILTIN_ORDER) do
        if ns.DB.Items[key] then
            table.insert(
                list,
                {
                    ArgKey = EncodeItemKey(key),
                    DBKey = key,
                    Config = ns.DB.Items[key],
                    IsBuiltin = true
                }
            )
        end
    end

    -- Then user-added items, sorted by name.
    local custom = {}
    for key, config in pairs(ns.DB.Items) do
        if not ns.COLLECTION_META[key] then
            table.insert(
                custom,
                {
                    ArgKey = EncodeItemKey(key),
                    DBKey = key,
                    Config = config
                }
            )
        end
    end
    table.sort(
        custom,
        function(a, b)
            return (a.Config.Name or "") < (b.Config.Name or "")
        end
    )
    for _, entry in ipairs(custom) do
        table.insert(list, entry)
    end

    return list
end

local function BuildItemsOptions()
    local args = {
        intro = Desc(L["OPTIONS_ITEMS_DESC"], 1),
        introSpacer = Spacer(2)
    }

    local list = BuildItemList()

    if #list == 0 then
        args.emptyNotice = Desc(COLORS.DESC .. L["OPTIONS_ITEMS_EMPTY"] .. "|r", 3)
    end

    local order = 10
    for _, entry in ipairs(list) do
        args[entry.ArgKey] = BuildItemPanel(entry.DBKey, entry.Config, order)
        order = order + 1
    end

    args.addItem = BuildAddItemPanel(order + 10)

    return {
        type = "group",
        name = L["OPTIONS_TITLE"] .. " > " .. L["OPTIONS_ITEMS"],
        childGroups = "tree",
        args = args
    }
end

--------------------------------------------------------------------------------
-- Rebuild Hook
--------------------------------------------------------------------------------

function ns.RebuildItemsOptions()
    if not itemsAppName then
        return
    end
    AceConfig:RegisterOptionsTable(itemsAppName, BuildItemsOptions())
    AceConfigRegistry:NotifyChange(itemsAppName)
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function ns.InitOptionsItems(appName, parentDisplayName)
    itemsAppName = appName
    AceConfig:RegisterOptionsTable(appName, BuildItemsOptions())
    AceConfigDialog:AddToBlizOptions(appName, L["OPTIONS_ITEMS"], parentDisplayName)
end
