local _, ns = ...

local L = ns.L

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local REGISTRY = ns.OPTIONS_REGISTRY

--------------------------------------------------------------------------------
-- OpenOptions Helper
--------------------------------------------------------------------------------

function ns.OpenOptions()
    if Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(L["OPTIONS_TITLE"])
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(L["OPTIONS_TITLE"])
        InterfaceOptionsFrame_OpenToCategory(L["OPTIONS_TITLE"])
    end
end

--------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------

-- /wd (and /waterdispenser) opens the options panel. No subcommands.
local function SlashHandler()
    if ns.OpenOptions then
        ns.OpenOptions()
    end
end

SLASH_WATERDISPENSER1 = "/wd"
SLASH_WATERDISPENSER2 = "/waterdispenser"
SlashCmdList["WATERDISPENSER"] = SlashHandler

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function ns.InitOptions()
    AceConfig:RegisterOptionsTable(REGISTRY.General, ns.BuildGeneralOptions())
    AceConfigDialog:AddToBlizOptions(REGISTRY.General, L["OPTIONS_TITLE"])

    if ns.InitOptionsDistributionRules then
        ns.InitOptionsDistributionRules(REGISTRY.DistributionRules, L["OPTIONS_TITLE"])
    end

    if ns.InitOptionsAnnouncements then
        ns.InitOptionsAnnouncements(REGISTRY.Announcements, L["OPTIONS_TITLE"])
    end

    -- Registered last so the Diagnostic Tools panel sits at the bottom.
    if ns.InitOptionsDiagnostics then
        ns.InitOptionsDiagnostics(REGISTRY.Diagnostics, L["OPTIONS_TITLE"])
    end
end
