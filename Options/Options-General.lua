local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor
local URLS = ns.URLS

local Header = ns.OptionsHeader
local Desc = ns.OptionsDesc
local Spacer = ns.OptionsSpacer
local SubRow = ns.OptionsSubRow
local SubToggle = ns.OptionsSubToggle
local GetDB = ns.OptionsGetDB
local SetDB = ns.OptionsSetDB

-- The Feedback & Support rows: a caption-sized label, so the URL box gets the rest
-- of the row and a full address fits without being cut off.
local LINK_LABEL_WIDTH = 0.6
local LINK_URL_WIDTH = ns.OPTIONS_ROW_WIDTH - LINK_LABEL_WIDTH

--------------------------------------------------------------------------------
-- Read-only URL Row
--------------------------------------------------------------------------------

-- One Feedback & Support row: a gold service name, then the address in a box the
-- player can select and copy but not edit.
local function AddLinkRow(args, key, name, url, order)
	args[key .. "Label"] = ns.OptionsRowLabel(GetColor("TITLE") .. name .. "|r", order, LINK_LABEL_WIDTH)
	args[key .. "URL"] = {
		type = "input",
		name = "",
		order = order + 1,
		width = LINK_URL_WIDTH,
		get = function()
			return url
		end,
		set = function() end,
	}
end

--------------------------------------------------------------------------------
-- General Settings Table
--------------------------------------------------------------------------------

-- The per-scope rows only show while the master Dispense toggle is on.
local function DispenseOff()
	return not (ns.db and ns.db.profile.Dispense)
end

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
			-- Dispense
			spaceDispense0 = Spacer(30),
			headerDispense = Header(L["OPTIONS_DISPENSE_HEADER"], 31),
			spaceDispense1 = Spacer(32),
			descDispense = Desc(L["OPTIONS_DISPENSE_DESC"], 33),
			spaceDispense2 = Spacer(34),
			Dispense = {
				type = "toggle",
				width = "full",
				name = L["OPTIONS_DISPENSE_MASTER"],
				desc = L["OPTIONS_DISPENSE_MASTER_DESC"],
				order = 35,
				get = GetDB,
				set = function(info, value)
					SetDB(info, value)
					-- Switching off means we are offering nothing; the group needs telling.
					ns.RefreshGiveaways()
					-- Restacking is a sub-option of this one, so switching back on resumes it.
					if value then
						ns.RestackBags()
					end
				end,
			},
			rowDispenseRaid = SubRow(36, DispenseOff, {
				SubToggle("DispenseRaid", L["OPTIONS_DISPENSE_RAID"], L["OPTIONS_DISPENSE_RAID_DESC"]),
			}),
			rowDispenseGroup = SubRow(37, DispenseOff, {
				SubToggle("DispenseGroup", L["OPTIONS_DISPENSE_GROUP"], L["OPTIONS_DISPENSE_GROUP_DESC"]),
			}),
			rowDispenseSolo = SubRow(38, DispenseOff, {
				SubToggle("DispenseSolo", L["OPTIONS_DISPENSE_SOLO"], L["OPTIONS_DISPENSE_SOLO_DESC"]),
			}),
			--[[
				The last two are sub-options of Dispense, like the three scopes above, so
				they indent under it and hide with it.

				Nothing may act from behind a hidden control, which is why Restack reads
				the master toggle too: otherwise switching Dispense off would leave it
				quietly reshuffling bags with no way to see or stop it. The short-warning
				needs no such gate -- it only ever speaks in answer to a fill the player
				asked for, and with Dispense off the side panel's button is the only fill
				left.
			]]
			rowRestackBags = SubRow(39, DispenseOff, {
				SubToggle("RestackBags", L["OPTIONS_RESTACK"], L["OPTIONS_RESTACK_DESC"], function()
					-- Switching it on shouldn't wait for the next bag change to tidy what is already there.
					if ns.db.profile.RestackBags then
						ns.RestackBags()
					end
				end),
			}),
			-- Last of the sub-options: the others change what the add-on does, this one only changes what it says.
			rowMissingStackWarnings = SubRow(40, DispenseOff, {
				SubToggle(
					"MissingStackWarnings",
					L["OPTIONS_MISSING_STACK_WARNINGS"],
					L["OPTIONS_MISSING_STACK_WARNINGS_DESC"]
				),
			}),
			-- Combat
			spaceCombat0 = Spacer(50),
			headerCombat = Header(L["OPTIONS_COMBAT_HEADER"], 51),
			spaceCombat1 = Spacer(52),
			descCombat = Desc(L["OPTIONS_COMBAT_DESC"], 53),
			spaceCombat2 = Spacer(54),
			CombatNotifications = {
				type = "toggle",
				width = "full",
				name = L["OPTIONS_COMBAT_NOTIFY"],
				desc = L["OPTIONS_COMBAT_NOTIFY_DESC"],
				order = 55,
				get = GetDB,
				set = SetDB,
			},
			-- Feedback & Support
			spaceLinks0 = Spacer(69),
			headerLinks = Header(L["OPTIONS_SUPPORT"], 70),
			spaceLinks1 = Spacer(71),
			spaceLinks2 = Spacer(74),
			spaceLinks3 = Spacer(77),
			spaceLinks4 = Spacer(80),
			-- Version
			spaceVersion0 = {
				type = "description",
				name = " ",
				width = "full",
				order = 998,
			},
			versionLine = {
				type = "description",
				name = GetColor("MUTED") .. "Version " .. ns.Version .. "|r",
				fontSize = "medium",
				order = 999,
			},
		},
	}

	-- House order: Discord, GitHub, CurseForge, Wago. Each pair slots between the
	-- spacers reserved for it above.
	AddLinkRow(options.args, "discord", L["SUPPORT_DISCORD"], URLS.DISCORD, 72)
	AddLinkRow(options.args, "github", L["SUPPORT_GITHUB"], URLS.GITHUB, 75)
	AddLinkRow(options.args, "curseforge", L["SUPPORT_CURSEFORGE"], URLS.CURSEFORGE, 78)
	AddLinkRow(options.args, "wago", L["SUPPORT_WAGO"], URLS.WAGO, 81)

	return options
end
