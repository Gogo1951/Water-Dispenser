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

	The combat gate is the first thing the function does, in front of the whole
	routing chain: Blizzard's Settings panel is protected in combat, and without
	the gate the player gets an ADDON_ACTION_BLOCKED error naming the add-on. It
	refuses and returns rather than queueing, and it prints every time, because a
	silent refusal reads as a broken command.
]]
function ns:OpenOptionsPanel()
	if ns.IsInCombat() then
		ns.PrintMessage(L["CHAT_OPTIONS_IN_COMBAT"])
		return
	end

	if not ns.optionsFrames then
		return
	end

	if Settings and Settings.OpenToCategory and ns.optionsFrames.categoryID then
		Settings.OpenToCategory(ns.optionsFrames.categoryID)
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
	database). Child order is fixed: General (root) -> Dispense -> Dispensed Items
	-> Announcements -> Inventory Tooltips -> Profiles (second-to-last) -> Diagnostic
	Tools (last). Every child's third AddToBlizOptions argument is the parent's
	display name so they all nest under Water Dispenser.
]]
function ns.RegisterOptionsPanels()
	local parent = L["ADDON_TITLE"]

	AceConfig:RegisterOptionsTable(REGISTRY.General, ns.BuildGeneralOptions())
	local mainPanel, mainCategoryID = AceConfigDialog:AddToBlizOptions(REGISTRY.General, parent)
	ns.optionsFrames = { main = mainPanel, categoryID = mainCategoryID }

	AceConfig:RegisterOptionsTable(REGISTRY.Dispenser, ns.BuildDispenserOptions())
	AceConfigDialog:AddToBlizOptions(REGISTRY.Dispenser, L["TAB_DISPENSE"], parent)

	AceConfig:RegisterOptionsTable(REGISTRY.DispensedItems, ns.BuildDispensedItemsOptions())
	AceConfigDialog:AddToBlizOptions(REGISTRY.DispensedItems, L["TAB_DISPENSED_ITEMS"], parent)

	AceConfig:RegisterOptionsTable(REGISTRY.Announcements, ns.BuildAnnouncementsOptions())
	AceConfigDialog:AddToBlizOptions(REGISTRY.Announcements, L["TAB_ANNOUNCEMENTS"], parent)

	AceConfig:RegisterOptionsTable(REGISTRY.GroupSpares, ns.BuildGroupSparesOptions())
	AceConfigDialog:AddToBlizOptions(REGISTRY.GroupSpares, L["TAB_INVENTORY_TOOLTIPS"], parent)

	local profilesOptions = ns.BuildProfilesOptions()
	AceConfig:RegisterOptionsTable(REGISTRY.Profiles, profilesOptions)
	AceConfigDialog:AddToBlizOptions(REGISTRY.Profiles, profilesOptions.name, parent)

	AceConfig:RegisterOptionsTable(REGISTRY.Diagnostics, ns.BuildDiagnosticsOptions())
	AceConfigDialog:AddToBlizOptions(REGISTRY.Diagnostics, ns.DiagnosticsStrings.TAB, parent)
end
