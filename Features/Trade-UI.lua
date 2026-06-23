local _, ns = ...

local L = ns.L

--------------------------------------------------------------------------------
-- Trade UI Frame
--------------------------------------------------------------------------------

-- Plain UIPanelButton anchored beneath another region.
local function MakeButton(parent, anchorTo, anchorPos, yOffset)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetPoint("TOPLEFT", anchorTo, anchorPos or "BOTTOMLEFT", 0, yOffset or 0)
    button:SetSize(160, 22)
    return button
end

-- A small panel beside the trade window holding Clear and Fill. It stays
-- parented to UIParent and only anchors to the trade frame (matching its strata
-- so it sits clickable beside it). The buttons are insecure, so the panel can be
-- shown and hidden freely with no combat restrictions.
local function CreateTradeUI()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(180, 60)
    frame:EnableMouse(false)
    frame:Hide()

    local btnClear = MakeButton(frame, frame, "TOPLEFT", 0)
    btnClear:SetText(L["BTN_CLEAR"])
    btnClear:SetScript(
        "OnClick",
        function()
            ns.ClearTrade()
        end
    )

    local btnFill = MakeButton(frame, btnClear, "BOTTOMLEFT", -2)
    btnFill:SetText(L["BTN_FILL"])
    btnFill:SetScript(
        "OnClick",
        function()
            ns.FillTrade(true)
        end
    )

    function frame:Attach(parent)
        frame:SetFrameStrata(parent:GetFrameStrata())
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", parent, "TOPRIGHT", 2, 0)
        frame:Show()
    end

    function frame:Detach()
        frame:Hide()
    end

    return frame
end
ns.CreateTradeUI = CreateTradeUI
