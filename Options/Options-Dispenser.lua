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

-- Inside a sub-row a description must carry a width, or it takes a line of its own and strands the indent.
local SUB_EXAMPLE_WIDTH = ns.OPTIONS_ROW_WIDTH - ns.OPTIONS_SUB_INDENT_WIDTH - 0.2

-- The item the run-short example names: the first one this class hands out, else the first built-in.
local function ExampleItemKey()
	local items = ns.db and ns.db.profile.Items or {}
	for _, key in ipairs(ns.BUILTIN_ORDER) do
		if items[key] and ns.IsItemActiveForPlayer(items[key]) then
			return key
		end
	end
	for key, config in pairs(items) do
		if not ns.COLLECTION_META[key] and ns.IsItemActiveForPlayer(config) then
			return key
		end
	end
	return ns.BUILTIN_ORDER[1]
end

local function MissingStackExample()
	local key = ExampleItemKey()
	local icon = ns.GetItemConfigIcon(key)
	local iconTag = icon and ("|T" .. icon .. ns.ICON_COORDS .. "|t ") or ""
	local name = ns.GetItemConfigName(key) or "?"
	return ns.BuildPrintLine(L["CHAT_MISSING_STACK"], iconTag .. format(L["FORMAT_ITEM_COUNT"], name, 20))
end

local function CombatExample()
	return ns.BuildPrintLine(L["CHAT_COMBAT_BLOCKED"])
end

function ns.BuildDispenserOptions()
	return {
		type = "group",
		name = L["TAB_DISPENSE"],
		args = {
			-- Dispense: the panel's opening section, titled by the tab rather than a header of its own.
			intro = Desc(L["OPTIONS_DISPENSE_MASTER_DESC"], 1),
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
			-- Same left-to-right order as the Dispensed Items amount grid's columns.
			rowDispenseSolo = SubRow(4, DispenseOff, {
				SubToggle("DispenseSolo", L["OPTIONS_DISPENSE_SOLO"], L["OPTIONS_DISPENSE_SOLO_DESC"]),
			}),
			rowDispenseGroup = SubRow(5, DispenseOff, {
				SubToggle("DispenseGroup", L["OPTIONS_DISPENSE_GROUP"], L["OPTIONS_DISPENSE_GROUP_DESC"]),
			}),
			rowDispenseRaid = SubRow(6, DispenseOff, {
				SubToggle("DispenseRaid", L["OPTIONS_DISPENSE_RAID"], L["OPTIONS_DISPENSE_RAID_DESC"]),
			}),
			rowHoldForMasterLoot = SubRow(7, DispenseOff, {
				SubToggle("HoldForMasterLoot", L["OPTIONS_HOLD_MASTER_LOOT"], L["OPTIONS_HOLD_MASTER_LOOT_DESC"]),
			}),
			--[[
				Hidden with Dispense, and nothing may act from behind a hidden control, which
				is why CanRestack reads the master toggle as well as this one.

				No onSet: switching this on must not kick a pass. The whole point of the
				feature's shape is that bags are only ever touched just after a trade closes,
				and tidying them the instant a checkbox is ticked is exactly the surprise
				that behavior exists to avoid.
			]]
			rowRestackBags = SubRow(8, DispenseOff, {
				SubToggle("RestackBags", L["OPTIONS_RESTACK"], L["OPTIONS_RESTACK_DESC"]),
			}),
			rowConjureButtons = SubRow(9, DispenseOff, {
				SubToggle(
					"ConjureButtons",
					L["OPTIONS_CONJURE_BUTTONS"],
					L["OPTIONS_CONJURE_BUTTONS_DESC"],
					ns.RefreshConjureButtons
				),
			}),
			-- Last of the sub-options: the others change what the add-on does, this one only changes what it says.
			rowMissingStackWarnings = SubRow(10, DispenseOff, {
				SubToggle(
					"MissingStackWarnings",
					L["OPTIONS_MISSING_STACK_WARNINGS"],
					L["OPTIONS_MISSING_STACK_WARNINGS_DESC"]
				),
			}),
			rowMissingStackExample = SubRow(11, DispenseOff, {
				ns.OptionsExample(MissingStackExample, nil, nil, SUB_EXAMPLE_WIDTH),
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
			exampleCombat = ns.OptionsExample(CombatExample, 56),
		},
	}
end
