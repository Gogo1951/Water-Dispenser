local ADDON_NAME, ns = ...

local L = ns.L

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

-- Shared runtime state, read and written across modules.
ns.State = {
	Trade = {
		Active = false,
		Class = nil,
		Level = nil,
		Party = false,
	},
	MissingStack = false,
}

--------------------------------------------------------------------------------
-- Version
--------------------------------------------------------------------------------

local function GetVersion()
	local getMeta = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
	local version = getMeta and getMeta(ADDON_NAME, "Version")
	if not version or version:find("@") then
		return "Dev"
	end
	return version
end

ns.Version = GetVersion()

--------------------------------------------------------------------------------
-- Event Dispatcher
--------------------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
local eventHandlers = {}

-- Registered events, deduped in first-seen order; the Diagnostics probe reads this so its list can't drift.
ns.EVENT_NAMES = {}
local seenEvents = {}

function ns.RegisterEvent(event, handler)
	if not seenEvents[event] then
		seenEvents[event] = true
		ns.EVENT_NAMES[#ns.EVENT_NAMES + 1] = event
	end
	if not eventHandlers[event] then
		-- pcall-guarded: RegisterEvent errors on a name invalid for this client, so skip it cleanly.
		local ok = pcall(eventFrame.RegisterEvent, eventFrame, event)
		if not ok then
			return
		end
		eventHandlers[event] = {}
	end
	table.insert(eventHandlers[event], handler)
end

eventFrame:SetScript("OnEvent", function(_, event, ...)
	-- Diagnostics tap, gated on the boolean first so the dispatcher costs nothing while logging is off.
	if ns.diagnostics and ns.diagnostics.logging then
		ns:LogEvent(event, ...)
	end
	local handlers = eventHandlers[event]
	if not handlers then
		return
	end
	for _, handler in ipairs(handlers) do
		handler(event, ...)
	end
end)

--------------------------------------------------------------------------------
-- Addon Lifecycle
--------------------------------------------------------------------------------

--[[
	Creates the AceDB database and seeds it on first login after the two-table
	upgrade ("first login seeds Default"): this character's legacy settings fold
	into the shared Default profile; later characters discard theirs and inherit it.
]]
local function SetupDatabase()
	-- Capture the pre-AceDB tables before AceDB adopts WaterDispenserDB.
	local legacyAccount = WaterDispenserDB
	local legacyChar = WaterDispenserCharDB
	local hasLegacyChar = type(legacyChar) == "table" and next(legacyChar) ~= nil

	-- MIGRATION (remove after 2026-10-12): read legacy root keys under the type guard so a fresh install leaves each nil.
	local legacyWelcome, legacyMinimap
	if type(legacyAccount) == "table" then
		legacyWelcome = legacyAccount.WelcomeMessage
		if type(legacyAccount.minimap) == "table" then
			legacyMinimap = legacyAccount.minimap
		end
	end

	ns.db = LibStub("AceDB-3.0"):New("WaterDispenserDB", ns.DATABASE_DEFAULTS, true)
	local profile = ns.db.profile
	local global = ns.db.global

	-- MIGRATION (remove after 2026-10-12): fold the legacy minimap into global, then clear the stray root keys (idempotent).
	if legacyMinimap then
		for key, value in pairs(legacyMinimap) do
			global.minimap[key] = value
		end
	end
	WaterDispenserDB.minimap = nil
	WaterDispenserDB.WelcomeMessage = nil

	-- MIGRATION (remove after 2026-10-12): first login seeds Default from this character's legacy table; the account-wide flag makes it one-time.
	if not global.legacySeedDone then
		global.legacySeedDone = true
		if legacyWelcome ~= nil then
			profile.showWelcome = legacyWelcome
		end
		if hasLegacyChar then
			ns.RunLegacyMigrations(legacyChar)
			for _, key in ipairs({ "MissingStackWarnings", "Dispense", "DispenseSolo", "DispenseGroup", "DispenseRaid" }) do
				if legacyChar[key] ~= nil then
					profile[key] = legacyChar[key]
				end
			end
			if type(legacyChar.Announcements) == "table" and legacyChar.Announcements.Enabled ~= nil then
				profile.Announcements.Enabled = legacyChar.Announcements.Enabled
			end
			if type(legacyChar.Items) == "table" then
				for key, value in pairs(legacyChar.Items) do
					profile.Items[key] = ns.DeepCopy(value)
				end
			end
		end
	end

	-- MIGRATION (remove after 2026-10-12): discard every character's legacy table; Default is the source of truth now.
	WaterDispenserCharDB = nil

	ns.RefreshCollectionMeta()

	-- Re-sync metadata, item panels, and the macro on any profile switch/copy/reset.
	ns.db.RegisterCallback(ns, "OnProfileChanged", "OnProfileRefresh")
	ns.db.RegisterCallback(ns, "OnProfileCopied", "OnProfileRefresh")
	ns.db.RegisterCallback(ns, "OnProfileReset", "OnProfileRefresh")
end

function ns:OnProfileRefresh()
	ns.RefreshCollectionMeta()
	if ns.RebuildDistributionRulesOptions then
		ns.RebuildDistributionRulesOptions()
	end
	if ns.RefreshAnnouncementMacro then
		ns.RefreshAnnouncementMacro()
	end
end

-- PLAYER_LOGIN: saved variables are loaded and caches are warm enough for a first-pass scan.
ns.RegisterEvent("PLAYER_LOGIN", function()
	SetupDatabase()
	if ns.RegisterOptionsPanels then
		ns.RegisterOptionsPanels()
	end
	if ns.InitDispenser then
		ns.InitDispenser()
	end
	if ns.InitAnnouncements then
		ns.InitAnnouncements()
	end
	if ns.InitMinimap then
		ns.InitMinimap()
	end
	if ns.db.profile.showWelcome then
		ns.PrintMessage(format(L["CHAT_LOADED"], ns.Version))
	end
end)
