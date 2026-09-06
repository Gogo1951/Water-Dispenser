local _, ns = ...

local L = ns.L

local Desc = ns.OptionsDesc
local Spacer = ns.OptionsSpacer
local SubRow = ns.OptionsSubRow
local SubToggle = ns.OptionsSubToggle
local GetDB = ns.OptionsGetDB
local SetDB = ns.OptionsSetDB

--------------------------------------------------------------------------------
-- Tooltip Sharing
--------------------------------------------------------------------------------

-- Sharing is only a question once the tooltips themselves are switched on.
local function TooltipsOff()
	return not (ns.db and ns.db.profile.ShowInventoryTooltips)
end

function ns.BuildGroupSparesOptions()
	return {
		type = "group",
		name = L["TAB_INVENTORY_TOOLTIPS"],
		args = {
			intro = Desc(L["OPTIONS_TOOLTIPS_DESC"], 1),
			spaceIntro = Spacer(2),
			ShowInventoryTooltips = {
				type = "toggle",
				width = "full",
				name = L["OPTIONS_SHOW_INVENTORY"],
				desc = L["OPTIONS_SHOW_INVENTORY_DESC"],
				order = 3,
				get = GetDB,
				set = function(info, value)
					SetDB(info, value)
					-- This gates sharing too, so the group needs telling either way.
					ns.RefreshGiveaways()
				end,
			},
			rowShareInventory = SubRow(4, TooltipsOff, {
				SubToggle("ShareInventory", L["OPTIONS_SHARE_INVENTORY"], L["OPTIONS_SHARE_INVENTORY_DESC"], function()
					ns.RefreshGiveaways()
				end),
			}),
		},
	}
end
