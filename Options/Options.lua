local _, ns = ...

local L = ns.L

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local REGISTRY = ns.OPTIONS_REGISTRY

--------------------------------------------------------------------------------
-- Open Options Panel
--------------------------------------------------------------------------------

--[[
	Opens the add-on's Blizzard options category from the handles captured at
	registration. Never resolve by display name: AddToBlizOptions aliases
	category.ID to the panel title only when C_SettingsUtil.OpenSettingsPanel is
	absent, so a name lookup returns nil on every client that has that API.
]]
function ns:OpenOptionsPanel()
	if not ns.optionsFrames then
		return
	end

	if Settings and Settings.OpenToCategory and ns.optionsFrames.categoryID then
		Settings.OpenToCategory(ns.optionsFrames.categoryID)
		return
	end

	if InterfaceOptionsFrame_OpenToCategory then
		InterfaceOptionsFrame_OpenToCategory(ns.optionsFrames.main)
		-- Called twice for Classic compatibility
		InterfaceOptionsFrame_OpenToCategory(ns.optionsFrames.main)
		return
	end

	AceConfigDialog:Open(REGISTRY.General)
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
	local mainPanel, mainCategoryID = AceConfigDialog:AddToBlizOptions(REGISTRY.General, parent)
	ns.optionsFrames = { main = mainPanel, categoryID = mainCategoryID }

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
