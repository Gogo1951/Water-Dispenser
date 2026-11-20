local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor

local Header = ns.OptionsHeader
local Desc = ns.OptionsDesc
local Spacer = ns.OptionsSpacer
local GetDB = ns.OptionsGetDB
local SetDB = ns.OptionsSetDB

--------------------------------------------------------------------------------
-- General Settings Table
--------------------------------------------------------------------------------

function ns.BuildGeneralOptions()
	local options = {
		type = "group",
		name = L["ADDON_TITLE"],
		args = {
			-- Brief Description
			descIntro = Desc(L["OPTIONS_DESCRIPTION"], 1),
			space0 = Spacer(2),
			showWelcome = {
				type = "toggle",
				width = "full",
				name = L["OPTIONS_WELCOME_MESSAGE"],
				desc = L["OPTIONS_WELCOME_MESSAGE_DESC"],
				order = 4,
				get = GetDB,
				set = SetDB,
			},
			MinimapButton = {
				type = "toggle",
				width = "full",
				name = L["OPTIONS_MINIMAP"],
				desc = L["OPTIONS_MINIMAP_DESC"],
				order = 5,
				-- Reads/writes the LibDBIcon hide flag; the label reads "Enable", so the stored value is inverted.
				get = function()
					return not ns.db.profile.minimap.hide
				end,
				set = function(_, value)
					ns.db.profile.minimap.hide = not value
					ns:ApplyMinimapButton()
					ns.RefreshSettings()
				end,
			},
			-- Features
			spaceFeatures0 = Spacer(10),
			headerFeatures = Header(L["OPTIONS_FEATURES_HEADER"], 11),
			spaceFeatures1 = Spacer(12),
			-- /Commands
			spaceCommands0 = Spacer(20),
			headerCommands = Header(L["OPTIONS_COMMANDS_HEADER"], 21),
			spaceCommands1 = Spacer(22),
			descCommands = Desc(
				GetColor("INFO") .. L["OPTIONS_COMMAND"] .. "|r" .. "  " .. L["OPTIONS_COMMAND_DESCRIPTION"],
				23
			),
		},
	}
	-- Built from ns.FEATURES, the same list as the mini-map menu, in its order.
	ns.OptionsFeatureSwitches(options.args, 13)
	return options
end
