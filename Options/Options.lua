local addonName, ns = ...

local L = ns.L
local COLORS = ns.COLORS
local URLS = ns.URLS

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local APP_NAME = "WaterDispenser"
local ITEMS_APP_NAME = "WaterDispenserItems"
local ANNOUNCEMENTS_APP_NAME = "WaterDispenserAnnouncements"

--------------------------------------------------------------------------------
-- AceConfig Helpers
--------------------------------------------------------------------------------

local Header = ns.OptionsHelpers.Header
local Desc = ns.OptionsHelpers.Desc
local Spacer = ns.OptionsHelpers.Spacer

local function ReadOnlyURL(name, url, order)
    return {
        type = "input",
        name = name,
        width = "double",
        order = order,
        get = function()
            return url
        end,
        set = function()
        end
    }
end

--------------------------------------------------------------------------------
-- General Settings Table
--------------------------------------------------------------------------------

local function GetDB(info)
    return ns.DB[info[#info]]
end

local function SetDB(info, value)
    ns.DB[info[#info]] = value
end

local function BuildGeneralOptions()
    return {
        type = "group",
        name = L["OPTIONS_TITLE"],
        args = {
            -- Intro description
            intro = Desc(L["OPTIONS_DESC"], 1),
            -- /Commands
            -- Each command is a single description line that pairs the slash
            -- form (in INFO blue, matching how WoW colors hyperlinks) with a
            -- plain-prose explanation. Spacer rows between commands match the
            -- vertical rhythm of other Gogo1951 addons.
            spaceCommands0 = Spacer(2),
            headerCommands = Header(L["OPTIONS_COMMANDS_HEADER"], 3),
            spaceCommands1 = Spacer(4),
            descCommands = Desc(L["OPTIONS_COMMANDS_DESC"], 5),
            spaceCommands2 = Spacer(6),
            cmdWd = Desc(
                COLORS.INFO .. L["OPTIONS_COMMAND_WD"] .. "|r  " .. L["OPTIONS_COMMAND_WD_DESC"],
                7
            ),
            spaceCmdWd = Spacer(8),
            cmdWdFill = Desc(
                COLORS.INFO .. L["OPTIONS_COMMAND_WD_FILL"] .. "|r  " .. L["OPTIONS_COMMAND_WD_FILL_DESC"],
                9
            ),
            spaceCmdFill = Spacer(10),
            cmdWdClear = Desc(
                COLORS.INFO .. L["OPTIONS_COMMAND_WD_CLEAR"] .. "|r  " .. L["OPTIONS_COMMAND_WD_CLEAR_DESC"],
                11
            ),
            spaceCmdClear = Spacer(12),
            cmdWdAuto = Desc(
                COLORS.INFO .. L["OPTIONS_COMMAND_WD_AUTO"] .. "|r  " .. L["OPTIONS_COMMAND_WD_AUTO_DESC"],
                13
            ),
            spaceCmdAuto = Spacer(14),
            cmdWda = Desc(
                COLORS.INFO .. L["OPTIONS_COMMAND_WDA"] .. "|r  " .. L["OPTIONS_COMMAND_WDA_DESC"],
                15
            ),
            -- General Settings
            spaceGeneral0 = Spacer(16),
            headerGeneral = Header(L["OPTIONS_GENERAL_HEADER"], 17),
            spaceGeneral1 = Spacer(18),
            WelcomeMessage = {
                type = "toggle",
                width = "full",
                name = L["OPTIONS_WELCOME_MESSAGE"],
                desc = L["OPTIONS_WELCOME_MESSAGE_DESC"],
                order = 19,
                get = GetDB,
                set = SetDB
            },
            MissingStackWarnings = {
                type = "toggle",
                width = "full",
                name = L["OPTIONS_MISSING_STACK_WARNINGS"],
                desc = L["OPTIONS_MISSING_STACK_WARNINGS_DESC"],
                order = 20,
                get = GetDB,
                set = SetDB
            },
            -- Automatic Fill
            spaceAuto0 = Spacer(30),
            headerAuto = Header(L["OPTIONS_AUTOFILL_HEADER"], 31),
            spaceAuto1 = Spacer(32),
            descAuto = Desc(L["OPTIONS_AUTOFILL_DESC"], 33),
            spaceAuto2 = Spacer(34),
            AutoFillSolo = {
                type = "toggle",
                width = "full",
                name = L["OPTIONS_AUTOFILL_SOLO"],
                desc = L["OPTIONS_AUTOFILL_SOLO_DESC"],
                order = 35,
                get = GetDB,
                set = SetDB
            },
            AutoFillGroup = {
                type = "toggle",
                width = "full",
                name = L["OPTIONS_AUTOFILL_GROUP"],
                desc = L["OPTIONS_AUTOFILL_GROUP_DESC"],
                order = 36,
                get = GetDB,
                set = SetDB
            },
            AutoFillRaid = {
                type = "toggle",
                width = "full",
                name = L["OPTIONS_AUTOFILL_RAID"],
                desc = L["OPTIONS_AUTOFILL_RAID_DESC"],
                order = 37,
                get = GetDB,
                set = SetDB
            },
            -- Combat
            spaceCombat0 = Spacer(40),
            headerCombat = Header(L["OPTIONS_COMBAT_HEADER"], 41),
            spaceCombat1 = Spacer(42),
            descCombat = Desc(L["OPTIONS_COMBAT_DESC"], 43),
            -- Rogue Lockboxes
            spaceLocked0 = Spacer(60),
            headerLocked = Header(L["OPTIONS_LOCKED_HEADER"], 61),
            spaceLocked1 = Spacer(62),
            descLocked = Desc(L["OPTIONS_LOCKED_DESC"], 63),
            spaceLocked2 = Spacer(64),
            LockedSlot = {
                type = "toggle",
                width = "full",
                name = L["OPTIONS_LOCKED"],
                order = 65,
                get = GetDB,
                set = SetDB
            },
            -- Reset
            spaceReset0 = Spacer(70),
            headerReset = Header(L["OPTIONS_RESET_HEADER"], 71),
            spaceReset1 = Spacer(72),
            descReset = Desc(L["OPTIONS_RESET_DESC"], 73),
            spaceReset2 = Spacer(74),
            resetButton = {
                type = "execute",
                name = L["OPTIONS_RESET_BUTTON"],
                width = "double",
                order = 75,
                confirm = true,
                confirmText = L["OPTIONS_RESET_CONFIRM"],
                func = function()
                    ns.ResetToDefaults()
                end
            },
            -- Feedback & Support
            spaceSupport0 = Spacer(80),
            headerSupport = Header(L["OPTIONS_SUPPORT"], 81),
            spaceSupport1 = Spacer(82),
            descSupport = Desc(L["SUPPORT_DESC"], 83),
            spaceSupport2 = Spacer(84),
            supportCurse = ReadOnlyURL(L["SUPPORT_CURSEFORGE"], URLS.CURSEFORGE, 85),
            supportGithub = ReadOnlyURL(L["SUPPORT_GITHUB"], URLS.GITHUB, 86),
            supportDiscord = ReadOnlyURL(L["SUPPORT_DISCORD"], URLS.DISCORD, 87),
            -- Version footer
            spaceVersion = Spacer(99),
            version = {
                type = "description",
                name = COLORS.MUTED .. "v" .. ns.Version .. "|r",
                fontSize = "medium",
                order = 100
            }
        }
    }
end

--------------------------------------------------------------------------------
-- OpenOptions Helper
--------------------------------------------------------------------------------

function ns.OpenOptions()
    if Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(L["OPTIONS_TITLE"])
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(L["OPTIONS_TITLE"])
        InterfaceOptionsFrame_OpenToCategory(L["OPTIONS_TITLE"])
    end
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function ns.InitOptions()
    AceConfig:RegisterOptionsTable(APP_NAME, BuildGeneralOptions())
    AceConfigDialog:AddToBlizOptions(APP_NAME, L["OPTIONS_TITLE"])

    if ns.InitOptionsItems then
        ns.InitOptionsItems(ITEMS_APP_NAME, L["OPTIONS_TITLE"])
    end

    if ns.InitOptionsAnnouncements then
        ns.InitOptionsAnnouncements(ANNOUNCEMENTS_APP_NAME, L["OPTIONS_TITLE"])
    end
end
