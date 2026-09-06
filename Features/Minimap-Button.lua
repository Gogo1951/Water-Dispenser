local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor

local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

--------------------------------------------------------------------------------
-- Tooltip
--------------------------------------------------------------------------------

local function ShowTooltip(anchor)
	GameTooltip:SetOwner(anchor, "ANCHOR_BOTTOMLEFT")
	GameTooltip:ClearLines()

	GameTooltip:AddDoubleLine(GetColor("TITLE") .. L["ADDON_TITLE"] .. "|r", GetColor("MUTED") .. ns.Version .. "|r")
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(" ")

	local on = ns.db and ns.db.profile.Dispense
	local state = on and (GetColor("ON") .. L["UI_ENABLED"] .. "|r") or (GetColor("OFF") .. L["UI_DISABLED"] .. "|r")
	-- The feature row names the feature with the same string its options section header uses.
	GameTooltip:AddDoubleLine(GetColor("TITLE") .. L["TAB_DISPENSE"] .. "|r", state)
	GameTooltip:AddLine(GetColor("BODY") .. L["OPTIONS_DISPENSE_MASTER_DESC"] .. "|r", 1, 1, 1, true)
	GameTooltip:AddDoubleLine(
		GetColor("INFO") .. L["UI_LEFT_CLICK"] .. "|r",
		GetColor("INFO") .. L["UI_TOGGLE"] .. "|r"
	)
	GameTooltip:AddLine(" ")

	-- Options block: always the last thing in the tooltip, no hint line below it.
	GameTooltip:AddLine(GetColor("TITLE") .. L["MINIMAP_OPTIONS"] .. "|r")
	GameTooltip:AddLine(GetColor("INFO") .. L["MINIMAP_OPTIONS_KEYBIND"] .. "|r")
	GameTooltip:Show()
end

--------------------------------------------------------------------------------
-- Visibility Toggle
--------------------------------------------------------------------------------

--[[
	Show or hide the mini-map button. No argument flips; a boolean sets directly.
	State persists in ns.db.profile.minimap.hide, the field LibDBIcon reads.
]]
function ns.ToggleMinimapButton(value)
	local minimap = ns.db.profile.minimap
	local show
	if value == nil then
		show = minimap.hide
	else
		show = value
	end
	minimap.hide = not show

	if not LDBIcon then
		return
	end
	if show then
		LDBIcon:Show(ns.LOCALE_NAME)
	else
		LDBIcon:Hide(ns.LOCALE_NAME)
	end
end

--------------------------------------------------------------------------------
-- LDB Data Object
--------------------------------------------------------------------------------

local ldbObject
if LDB then
	ldbObject = LDB:NewDataObject(ns.LOCALE_NAME, {
		type = "launcher",
		label = L["ADDON_TITLE"],
		icon = 132805,
		OnClick = function(self, button)
			-- Shift + Middle-Click always opens the options panel; checked first, before any feature interaction.
			if button == "MiddleButton" and IsShiftKeyDown() then
				ns:OpenOptionsPanel()
				return
			end
			if button == "LeftButton" and ns.db then
				ns.SetDispense(not ns.db.profile.Dispense)
				-- Re-render in place so the Enabled/Disabled line updates live, but only while this button still owns the tooltip.
				if GameTooltip:GetOwner() == self then
					ShowTooltip(self)
				end
			end
		end,
		OnEnter = function(self)
			ShowTooltip(self)
		end,
		OnLeave = function()
			GameTooltip:Hide()
		end,
	})
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function ns.InitMinimap()
	if not (LDB and LDBIcon and ldbObject) then
		return
	end
	LDBIcon:Register(ns.LOCALE_NAME, ldbObject, ns.db.profile.minimap)
end
