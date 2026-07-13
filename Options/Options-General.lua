local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor
local URLS = ns.URLS

local Header = ns.OptionsHeader
local Desc = ns.OptionsDesc
local Spacer = ns.OptionsSpacer

-- Leading pad that visually nests a toggle under the one above it (AceConfig has no indent property).
local SUB_INDENT = "      "

--------------------------------------------------------------------------------
-- Read-only URL Helper
--------------------------------------------------------------------------------

local function ReadOnlyURL(name, url, order)
	return {
		type = "input",
		name = name,
		width = "double",
		order = order,
		get = function()
			return url
		end,
		set = function() end,
	}
end

--------------------------------------------------------------------------------
-- General Settings Table
--------------------------------------------------------------------------------

local function GetDB(info)
	return ns.db.profile[info[#info]]
end

local function SetDB(info, value)
	ns.db.profile[info[#info]] = value
end

-- The per-scope toggles only show while the master Dispense toggle is on.
local function DispenseHidden()
	return not (ns.db and ns.db.profile.Dispense)
end

function ns.BuildGeneralOptions()
	return {
		type = "group",
		name = L["ADDON_TITLE"],
		args = {
			-- Intro description
			intro = Desc(L["OPTIONS_DESC"], 1),
			spaceGeneral0 = Spacer(2),
			showWelcome = {
				type = "toggle",
				width = "full",
				name = L["OPTIONS_WELCOME_MESSAGE"],
				desc = L["OPTIONS_WELCOME_MESSAGE_DESC"],
				order = 5,
				get = GetDB,
				set = SetDB,
			},
			MinimapButton = {
				type = "toggle",
				width = "full",
				name = L["OPTIONS_MINIMAP"],
				desc = L["OPTIONS_MINIMAP_DESC"],
				order = 5.25,
				-- Reads/writes the LibDBIcon hide flag in ns.db.global.minimap (account-wide, profile-independent).
				get = function()
					return not ns.db.global.minimap.hide
				end,
				set = function(_, value)
					ns.ToggleMinimapButton(value)
				end,
			},
			-- /Commands
			spaceCommands0 = Spacer(10),
			headerCommands = Header(L["OPTIONS_COMMANDS"], 11),
			spaceCommands1 = Spacer(12),
			descCommands = Desc(GetColor("INFO") .. "/wd|r" .. "  " .. L["OPTIONS_COMMANDS_WD"], 13),
			-- Automatic Fill
			spaceAuto0 = Spacer(30),
			headerAuto = Header(L["OPTIONS_DISPENSE_HEADER"], 31),
			spaceAuto1 = Spacer(32),
			descAuto = Desc(L["OPTIONS_DISPENSE_DESC"], 33),
			spaceAuto2 = Spacer(34),
			Dispense = {
				type = "toggle",
				width = "full",
				name = L["OPTIONS_DISPENSE_MASTER"],
				desc = L["OPTIONS_DISPENSE_MASTER_DESC"],
				order = 34.5,
				get = GetDB,
				set = SetDB,
			},
			DispenseRaid = {
				type = "toggle",
				width = "full",
				name = SUB_INDENT .. L["OPTIONS_DISPENSE_RAID"],
				desc = L["OPTIONS_DISPENSE_RAID_DESC"],
				order = 35,
				hidden = DispenseHidden,
				get = GetDB,
				set = SetDB,
			},
			DispenseGroup = {
				type = "toggle",
				width = "full",
				name = SUB_INDENT .. L["OPTIONS_DISPENSE_GROUP"],
				desc = L["OPTIONS_DISPENSE_GROUP_DESC"],
				order = 36,
				hidden = DispenseHidden,
				get = GetDB,
				set = SetDB,
			},
			DispenseSolo = {
				type = "toggle",
				width = "full",
				name = SUB_INDENT .. L["OPTIONS_DISPENSE_SOLO"],
				desc = L["OPTIONS_DISPENSE_SOLO_DESC"],
				order = 37,
				hidden = DispenseHidden,
				get = GetDB,
				set = SetDB,
			},
			MissingStackWarnings = {
				type = "toggle",
				width = "full",
				name = SUB_INDENT .. L["OPTIONS_MISSING_STACK_WARNINGS"],
				desc = L["OPTIONS_MISSING_STACK_WARNINGS_DESC"],
				order = 39,
				hidden = DispenseHidden,
				get = GetDB,
				set = SetDB,
			},
			-- Combat
			spaceCombat0 = Spacer(40),
			headerCombat = Header(L["OPTIONS_COMBAT_HEADER"], 41),
			spaceCombat1 = Spacer(42),
			descCombat = Desc(L["OPTIONS_COMBAT_DESC"], 43),
			-- Feedback & Support
			spaceSupport0 = Spacer(80),
			headerSupport = Header(L["OPTIONS_SUPPORT"], 81),
			spaceSupport1 = Spacer(82),
			descSupport = Desc(L["SUPPORT_DESC"], 83),
			spaceSupport2 = Spacer(84),
			supportDiscord = ReadOnlyURL(L["SUPPORT_DISCORD"], URLS.DISCORD, 85),
			supportGithub = ReadOnlyURL(L["SUPPORT_GITHUB"], URLS.GITHUB, 86),
			supportCurse = ReadOnlyURL(L["SUPPORT_CURSEFORGE"], URLS.CURSEFORGE, 87),
			supportWago = ReadOnlyURL(L["SUPPORT_WAGO"], URLS.WAGO, 88),
			-- Version footer
			spaceVersion = Spacer(99),
			version = {
				type = "description",
				name = GetColor("MUTED") .. "Version " .. ns.Version .. "|r",
				fontSize = "medium",
				order = 100,
			},
		},
	}
end
