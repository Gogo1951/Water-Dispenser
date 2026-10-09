local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor

local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

--------------------------------------------------------------------------------
-- Tooltip
--------------------------------------------------------------------------------

--[[
	The Dispense Report section: what the player is carrying to give, the same
	entries as the announcement macro but counted without the reserve, so a mage
	holding less water than they keep still sees it listed. Each row is the item's
	icon and quality-colored name, with its bag count on the right. The whole
	section is left out when nothing is carried, Dispense off included.
]]
local function AddDispenseReport()
	if not (ns.db and ns.db.profile.Dispense) then
		return
	end
	local entries = ns.BuildAnnouncementSnapshot(true)
	if #entries == 0 then
		return
	end
	GameTooltip:AddLine(GetColor("TITLE") .. L["MINIMAP_DISPENSE_REPORT"] .. "|r")
	for _, entry in ipairs(entries) do
		local _, _, quality = C_Item.GetItemInfo(entry.Link)
		local color = ns.ITEM_QUALITY_COLORS[quality or 1] or ns.ITEM_QUALITY_COLORS[1]
		local _, _, _, _, icon = C_Item.GetItemInfoInstant(entry.Link)
		local iconTag = icon and ("|T" .. icon .. ns.ICON_COORDS .. "|t ") or ""
		GameTooltip:AddDoubleLine(
			iconTag .. "|cff" .. color .. (entry.Name or "?") .. "|r",
			entry.IncludeQuantity and (GetColor("TEXT") .. entry.Count .. "|r") or ""
		)
	end
	GameTooltip:AddLine(" ")
end

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

	AddDispenseReport()

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
	State persists in ns.db.profile.minimap.hide, the field LibDBIcon reads, and
	Refresh is what applies it: it takes hide off the table it is handed and
	re-points position and lock with it, so this and the profile switch in
	Features/Core.lua reach LibDBIcon through the one call.
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
	LDBIcon:Refresh(ns.LOCALE_NAME, minimap)
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
	if ns.FLAVOR == "Camelot" or ns.FLAVOR == "Mainline" then
		LDBIcon:SetButtonIcon(ns.LOCALE_NAME, nil, 20, "CENTER", 1, -0.35)
		local button = LDBIcon:GetMinimapButton(ns.LOCALE_NAME)
		local mask = button:CreateMaskTexture()
		mask:SetTexture(130924, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE") -- Interface\CharacterFrame\TempPortraitAlphaMask
		mask:SetAllPoints(button.icon)
		button.icon:AddMaskTexture(mask)
	end
end
