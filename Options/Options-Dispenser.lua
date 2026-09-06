local _, ns = ...

local L = ns.L

local Header = ns.OptionsHeader
local Desc = ns.OptionsDesc
local Spacer = ns.OptionsSpacer
local SubRow = ns.OptionsSubRow
local SubToggle = ns.OptionsSubToggle
local GetDB = ns.OptionsGetDB
local SetDB = ns.OptionsSetDB

--------------------------------------------------------------------------------
-- Dispense Settings Table
--------------------------------------------------------------------------------

-- The per-scope rows only show while the master Dispense toggle is on.
local function DispenseOff()
	return not (ns.db and ns.db.profile.Dispense)
end

function ns.BuildDispenserOptions()
	return {
		type = "group",
		name = L["TAB_DISPENSE"],
		args = {
			-- Dispense: the panel's opening section, titled by the tab rather than a header of its own.
			intro = Desc(L["OPTIONS_DISPENSE_DESC"], 1),
			spaceIntro = Spacer(2),
			Dispense = {
				type = "toggle",
				width = "full",
				name = L["OPTIONS_DISPENSE_MASTER"],
				desc = L["OPTIONS_DISPENSE_MASTER_DESC"],
				order = 3,
				get = GetDB,
				set = function(_, value)
					ns.SetDispense(value)
				end,
			},
			rowDispenseRaid = SubRow(4, DispenseOff, {
				SubToggle("DispenseRaid", L["OPTIONS_DISPENSE_RAID"], L["OPTIONS_DISPENSE_RAID_DESC"]),
			}),
			rowDispenseGroup = SubRow(5, DispenseOff, {
				SubToggle("DispenseGroup", L["OPTIONS_DISPENSE_GROUP"], L["OPTIONS_DISPENSE_GROUP_DESC"]),
			}),
			rowDispenseSolo = SubRow(6, DispenseOff, {
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
			rowRestackBags = SubRow(7, DispenseOff, {
				SubToggle("RestackBags", L["OPTIONS_RESTACK"], L["OPTIONS_RESTACK_DESC"], function()
					-- Switching it on shouldn't wait for the next bag change to tidy what is already there.
					if ns.db.profile.RestackBags then
						ns.RestackBags()
					end
				end),
			}),
			-- Last of the sub-options: the others change what the add-on does, this one only changes what it says.
			rowMissingStackWarnings = SubRow(8, DispenseOff, {
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
		},
	}
end
