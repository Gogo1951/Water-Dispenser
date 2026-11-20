local _, ns = ...

local L = ns.L

local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

--------------------------------------------------------------------------------
-- Show or Hide
--------------------------------------------------------------------------------

--[[
	The one place the button is shown or hidden. Refresh takes hide off the table
	it's handed and re-points position and lock with it, so after a profile switch
	or reset the button follows the new profile's table. The Enable Mini-map
	Button switch and ns:ApplyProfile both call this.
]]
function ns:ApplyMinimapButton()
	if not (ns.db and LDBIcon and LDBIcon:IsRegistered(ns.LOCALE_NAME)) then
		return
	end
	LDBIcon:Refresh(ns.LOCALE_NAME, ns.db.profile.minimap)
end

--------------------------------------------------------------------------------
-- LDB Data Object
--------------------------------------------------------------------------------

--[[
	Hovering opens the menu (Features/Minimap-Menu.lua), which closes itself once
	the cursor leaves, so OnLeave has nothing to do. A click runs the menu row
	that names it: Left-Click flips Dispense, Shift + Middle-Click opens options.
]]
local ldbObject
if LDB then
	ldbObject = LDB:NewDataObject(ns.LOCALE_NAME, {
		type = "launcher",
		label = L["ADDON_TITLE"],
		icon = 132805,
		OnClick = function(self, button)
			ns.Menu:HandleClick(self, button)
		end,
		OnEnter = function(self)
			ns.Menu:Show(self, "hover")
		end,
		OnLeave = function() end,
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
	--[[
		Fitted by hand, not SetButtonIcon: its ResetButtonIcon calls icon:UpdateCoord(),
		which errors when another add-on has replaced the button's icon.
	]]
	local button = LDBIcon:GetMinimapButton(ns.LOCALE_NAME)
	if (ns.FLAVOR == "Camelot" or ns.FLAVOR == "Mainline") and button and button.icon then
		button.icon:SetSize(20, 20)
		button.icon:ClearAllPoints()
		button.icon:SetPoint("CENTER", 1, -0.35)
		local mask = button:CreateMaskTexture()
		mask:SetTexture(130924, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE") -- Interface\CharacterFrame\TempPortraitAlphaMask
		mask:SetAllPoints(button.icon)
		button.icon:AddMaskTexture(mask)
	end
end
