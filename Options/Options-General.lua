local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor
local URLS = ns.URLS

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local Header = ns.OptionsHeader
local Desc = ns.OptionsDesc
local Spacer = ns.OptionsSpacer
local GetDB = ns.OptionsGetDB
local SetDB = ns.OptionsSetDB

--[[
	The Feedback & Support rows override the default label-and-control split. Each
	label is one short word, so the standard ns.OPTIONS_LABEL_WIDTH would spend
	most of the row on nothing while the address beside it, the part the player
	came to copy, truncated. The two still total ns.OPTIONS_ROW_WIDTH, so the rows
	end where every other row ends.
]]
local LINK_LABEL_WIDTH = 0.6
local LINK_URL_WIDTH = ns.OPTIONS_ROW_WIDTH - LINK_LABEL_WIDTH

--------------------------------------------------------------------------------
-- Read-only URL Rows
--------------------------------------------------------------------------------

--[[
	One Feedback & Support row per service, in house order: a gold service name,
	then the address in a box the player can select and copy but not edit.

	Built from a list with the orders counted out here, rather than four calls
	slotted into spacer orders reserved further up the table. Reserved orders have
	to be kept in step by hand at two sites, and adding a service in the middle
	means renumbering both.
]]
local function AddLinkRows(args, order)
	local rows = {
		{ L["SUPPORT_DISCORD"], URLS.DISCORD },
		{ L["SUPPORT_GITHUB"], URLS.GITHUB },
		{ L["SUPPORT_CURSEFORGE"], URLS.CURSEFORGE },
		{ L["SUPPORT_WAGO"], URLS.WAGO },
	}

	for index, row in ipairs(rows) do
		if index > 1 then
			args["linkSpace" .. index] = ns.OptionsSpacer(order)
			order = order + 1
		end
		local url = row[2]
		args["linkLabel" .. index] = ns.OptionsRowLabel(GetColor("TITLE") .. row[1] .. "|r", order, LINK_LABEL_WIDTH)
		args["linkURL" .. index] = {
			type = "input",
			name = "",
			order = order + 1,
			width = LINK_URL_WIDTH,
			get = function()
				return url
			end,
			set = function() end,
		}
		order = order + 2
	end
end

--------------------------------------------------------------------------------
-- Feature Switches
--------------------------------------------------------------------------------

--[[
	Two to a line, each the same setting as the switch on its own feature page and
	written through the same path, so flipping one here repaints that page too.
]]
local function FeatureToggle(order, name, desc, get, set)
	return {
		type = "toggle",
		name = name,
		desc = desc,
		width = ns.OPTIONS_ROW_WIDTH / 2,
		order = order,
		get = get,
		set = function(_, value)
			set(value)
		end,
	}
end

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
					ns.ToggleMinimapButton(value)
				end,
			},
			-- Features
			spaceFeatures0 = Spacer(10),
			headerFeatures = Header(L["OPTIONS_FEATURES_HEADER"], 11),
			spaceFeatures1 = Spacer(12),
			featureDispense = FeatureToggle(
				13,
				L["OPTIONS_DISPENSE_MASTER"],
				L["OPTIONS_DISPENSE_MASTER_DESC"],
				function()
					return ns.db.profile.Dispense
				end,
				ns.SetDispense
			),
			featureAnnouncements = FeatureToggle(
				14,
				L["OPTIONS_ANNOUNCEMENTS_ENABLE"],
				L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"],
				function()
					return ns.db.profile.Announcements.Enabled
				end,
				ns.SetAnnouncementsEnabled
			),
			featureInventoryTooltips = FeatureToggle(
				15,
				L["OPTIONS_SHOW_INVENTORY"],
				L["OPTIONS_SHOW_INVENTORY_DESC"],
				function()
					return ns.db.profile.ShowInventoryTooltips
				end,
				function(value)
					ns.db.profile.ShowInventoryTooltips = value
					ns.RefreshGiveaways()
					AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.GroupSpares)
				end
			),
			featureBagTooltips = FeatureToggle(
				16,
				L["OPTIONS_BAG_TOOLTIPS"],
				L["OPTIONS_BAG_TOOLTIPS_DESC"],
				function()
					return ns.db.profile.ShowBagTooltips
				end,
				function(value)
					ns.db.profile.ShowBagTooltips = value
					AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.GroupSpares)
				end
			),
			-- /Commands
			spaceCommands0 = Spacer(20),
			headerCommands = Header(L["OPTIONS_COMMANDS_HEADER"], 21),
			spaceCommands1 = Spacer(22),
			descCommands = Desc(
				GetColor("INFO") .. L["OPTIONS_COMMAND"] .. "|r" .. "  " .. L["OPTIONS_COMMAND_DESCRIPTION"],
				23
			),
			-- Feedback & Support
			spaceLinks0 = Spacer(69),
			headerLinks = Header(L["OPTIONS_SUPPORT"], 70),
			spaceLinks1 = Spacer(71),
			-- Version
			spaceVersion0 = {
				type = "description",
				name = " ",
				width = "full",
				order = 998,
			},
			versionLine = {
				type = "description",
				name = function()
					return GetColor("MUTED") .. L["OPTIONS_VERSION"]:format(ns.Version) .. "|r"
				end,
				fontSize = "medium",
				order = 999,
			},
		},
	}

	AddLinkRows(options.args, 72)

	return options
end
