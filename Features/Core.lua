local ADDON_NAME, ns = ...

local L = ns.L

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

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
		-- Captured at TRADE_SHOW: UnitName("NPC") is gone by the time the trade closes.
		Partner = nil,
	},
	MissingStack = false,
}

--------------------------------------------------------------------------------
-- Version
--------------------------------------------------------------------------------

local function GetVersion()
	-- No legacy fallback: GetAddOnMetadata is gone on both target clients.
	local version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version")
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

-- Trailing unit tokens filter the event to those units; the first registration of an event fixes its filter, since RegisterUnitEvent binds per frame-and-event and every module shares this frame.
function ns.RegisterEvent(event, handler, ...)
	if not seenEvents[event] then
		seenEvents[event] = true
		ns.EVENT_NAMES[#ns.EVENT_NAMES + 1] = event
	end
	if not eventHandlers[event] then
		-- pcall-guarded: RegisterEvent errors on a name invalid for this client, so skip it cleanly.
		local ok
		if select("#", ...) > 0 then
			ok = pcall(eventFrame.RegisterUnitEvent, eventFrame, event, ...)
		else
			ok = pcall(eventFrame.RegisterEvent, eventFrame, event)
		end
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

-- Creates the AceDB database and wires the refresh that follows a profile switch.
local function SetupDatabase()
	ns.db = LibStub("AceDB-3.0"):New("WaterDispenserDB", ns.DATABASE_DEFAULTS, true)

	ns.RefreshCollectionMeta()

	-- Re-sync metadata, item panels, and the macro on any profile switch/copy/reset.
	ns.db.RegisterCallback(ns, "OnProfileChanged", "OnProfileRefresh")
	ns.db.RegisterCallback(ns, "OnProfileCopied", "OnProfileRefresh")
	ns.db.RegisterCallback(ns, "OnProfileReset", "OnProfileRefresh")
end

function ns:OnProfileRefresh()
	ns.RefreshCollectionMeta()
	if ns.RebuildDispensedItemsOptions then
		ns.RebuildDispensedItemsOptions()
	end
	ns.RefreshGiveaways()

	-- Every panel reads the profile, so all of them repaint; an open one would otherwise show the old profile's values.
	for _, registryName in pairs(ns.OPTIONS_REGISTRY) do
		AceConfigRegistry:NotifyChange(registryName)
	end

	--[[
		The button's table moved with the profile, so re-point LibDBIcon at the new
		one; without this it keeps writing to the old profile's table until a reload.
	]]
	local LDBIcon = LibStub("LibDBIcon-1.0")
	if LDBIcon:IsRegistered(ns.LOCALE_NAME) then
		LDBIcon:Refresh(ns.LOCALE_NAME, ns.db.profile.minimap)
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
	if ns.InitGroupSpares then
		ns.InitGroupSpares()
	end
	if ns.InitMinimap then
		ns.InitMinimap()
	end
	-- After InitDispenser: both claim TRADE_CLOSED, and the restacker's pass reads the Active flag the dispenser's handler clears.
	if ns.InitRestacker then
		ns.InitRestacker()
	end
	if ns.db.profile.showWelcome then
		ns.PrintMessage(format(L["CHAT_LOADED"], ns.Version))
	end
end)
