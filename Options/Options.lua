local _, ns = ...

local L = ns.L

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local REGISTRY = ns.OPTIONS_REGISTRY

--------------------------------------------------------------------------------
-- Open Options Panel
--------------------------------------------------------------------------------

--[[
	Opens the add-on's Blizzard options category. Modern clients need the resolved
	category ID -- opening by display name silently no-ops -- so look the category
	up first; older clients fall back to the twice-called legacy opener.
]]
function ns:OpenOptionsPanel()
	if Settings and Settings.GetCategory then
		local category = Settings.GetCategory(L["ADDON_TITLE"])
		if category then
			Settings.OpenToCategory(category.ID)
			return
		end
	end
	if InterfaceOptionsFrame_OpenToCategory then
		InterfaceOptionsFrame_OpenToCategory(L["ADDON_TITLE"])
		InterfaceOptionsFrame_OpenToCategory(L["ADDON_TITLE"])
	end
end

--------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------

-- /wd opens the options panel. No subcommands.
local function SlashHandler()
	ns:OpenOptionsPanel()
end

SLASH_WATERDISPENSER1 = "/wd"
SlashCmdList["WATERDISPENSER"] = SlashHandler

--------------------------------------------------------------------------------
-- Registration
--------------------------------------------------------------------------------

--[[
	Registration only; panel content lives in each panel file's builder. Called
	from Features/Core.lua once ns.db exists (the Profiles builder needs the
	database). Child order is fixed: General (root) -> Distribution Rules ->
	Announcements -> Profiles (second-to-last) -> Diagnostic Tools (last). Every
	child's third AddToBlizOptions argument is the parent's display name so they
	all nest under Water Dispenser.
]]
function ns.RegisterOptionsPanels()
	local parent = L["ADDON_TITLE"]

	AceConfig:RegisterOptionsTable(REGISTRY.General, ns.BuildGeneralOptions())
	AceConfigDialog:AddToBlizOptions(REGISTRY.General, parent)

	AceConfig:RegisterOptionsTable(REGISTRY.DistributionRules, ns.BuildDistributionRulesOptions())
	AceConfigDialog:AddToBlizOptions(REGISTRY.DistributionRules, L["OPTIONS_ITEMS"], parent)

	AceConfig:RegisterOptionsTable(REGISTRY.Announcements, ns.BuildAnnouncementsOptions())
	AceConfigDialog:AddToBlizOptions(REGISTRY.Announcements, L["OPTIONS_ANNOUNCEMENTS"], parent)

	local profilesOptions = ns.BuildProfilesOptions()
	AceConfig:RegisterOptionsTable(REGISTRY.Profiles, profilesOptions)
	AceConfigDialog:AddToBlizOptions(REGISTRY.Profiles, profilesOptions.name, parent)

	AceConfig:RegisterOptionsTable(REGISTRY.Diagnostics, ns.BuildDiagnosticsOptions())
	AceConfigDialog:AddToBlizOptions(REGISTRY.Diagnostics, ns.DiagnosticsStrings.TAB, parent)
end
