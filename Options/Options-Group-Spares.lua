local _, ns = ...

local L = ns.L

local Desc = ns.OptionsDesc
local Spacer = ns.OptionsSpacer
local SubRow = ns.OptionsSubRow
local SubToggle = ns.OptionsSubToggle

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
			-- The front page and the mini-map menu carry the same switch (ns.FEATURES).
			ShowInventoryTooltips = ns.OptionsFeatureSwitch("ShowInventoryTooltips", 3),
			-- Its own control rather than a sub-option of the player tooltips above, so it needs the gap to read as separate.
			spaceBagTooltips = Spacer(5),
			ShowBagTooltips = ns.OptionsFeatureSwitch("ShowBagTooltips", 6),
			rowShareInventory = SubRow(4, TooltipsOff, {
				SubToggle("ShareInventory", L["OPTIONS_SHARE_INVENTORY"], L["OPTIONS_SHARE_INVENTORY_DESC"], function()
					ns.RefreshGiveaways()
				end),
			}),
		},
	}
end
