local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor
local URLS = ns.URLS

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
			-- /Commands
			spaceCommands0 = Spacer(6),
			headerCommands = Header(L["OPTIONS_COMMANDS_HEADER"], 7),
			spaceCommands1 = Spacer(8),
			descCommands = Desc(
				GetColor("INFO") .. L["OPTIONS_COMMAND"] .. "|r" .. "  " .. L["OPTIONS_COMMAND_DESCRIPTION"],
				9
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
					return GetColor("MUTED") .. L["VERSION"] .. " " .. ns.Version .. "|r"
				end,
				fontSize = "medium",
				order = 999,
			},
		},
	}

	AddLinkRows(options.args, 72)

	return options
end
