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

    GameTooltip:AddDoubleLine(
        GetColor("TITLE") .. L["ADDON_TITLE"] .. "|r",
        GetColor("MUTED") .. ns.Version .. "|r"
    )
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(" ")

    local on = ns.DB and ns.DB.Dispense
    local state = on and (GetColor("ON") .. L["UI_ENABLED"] .. "|r")
        or (GetColor("OFF") .. L["UI_DISABLED"] .. "|r")
    GameTooltip:AddDoubleLine(GetColor("TITLE") .. L["MINIMAP_DISPENSE"] .. "|r", state)
    GameTooltip:AddLine(GetColor("BODY") .. L["MINIMAP_DISPENSE_DESC"] .. "|r", 1, 1, 1, true)
    GameTooltip:AddDoubleLine(GetColor("INFO") .. L["UI_LEFT_CLICK"] .. "|r", GetColor("INFO") .. L["UI_TOGGLE"] .. "|r")
    GameTooltip:AddLine(" ")

    GameTooltip:AddLine(GetColor("BODY") .. L["MINIMAP_HINT"] .. "|r", 1, 1, 1, true)
    GameTooltip:Show()
end

--------------------------------------------------------------------------------
-- Visibility Toggle
--------------------------------------------------------------------------------

-- Show or hide the minimap button. No argument flips; a boolean sets directly.
-- State persists in WaterDispenserDB.minimap.hide, the field LibDBIcon reads.
function ns.ToggleMinimapButton(value)
    WaterDispenserDB.minimap = WaterDispenserDB.minimap or {}
    local show
    if value == nil then
        show = WaterDispenserDB.minimap.hide
    else
        show = value
    end
    WaterDispenserDB.minimap.hide = not show

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
    ldbObject =
        LDB:NewDataObject(
        ns.LOCALE_NAME,
        {
            type = "launcher",
            label = L["ADDON_TITLE"],
            icon = 132805,
            OnClick = function(self, button)
                if button == "LeftButton" and ns.DB then
                    ns.DB.Dispense = not ns.DB.Dispense
                    -- Re-render so the Enabled/Disabled line updates live.
                    ShowTooltip(self)
                end
            end,
            OnEnter = function(self)
                ShowTooltip(self)
            end,
            OnLeave = function()
                GameTooltip:Hide()
            end
        }
    )
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function ns.InitMinimap()
    if not (LDB and LDBIcon and ldbObject) then
        return
    end
    WaterDispenserDB.minimap = WaterDispenserDB.minimap or {}
    LDBIcon:Register(ns.LOCALE_NAME, ldbObject, WaterDispenserDB.minimap)
end
