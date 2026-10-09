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
		-- The partner's class as the client names it, gendered for them, for display.
		ClassName = nil,
		Level = nil,
		Party = false,
		-- Whether the partner shares the player's guild, for items gated to guildies.
		Guild = false,
		-- Captured at TRADE_SHOW: UnitName("NPC") is gone by the time the trade closes.
		Partner = nil,
		--[[
			Feed the trade panel's status line. Note is a trade-wide reason (auto-fill
			off, the window just cleared); HoldReasons and ShortNotes are the last fill
			pass's per-item hold-backs, keyed by config key; Status is the line shown.
		]]
		Note = nil,
		HoldReasons = {},
		ShortNotes = {},
		Status = nil,
	},
	MissingStack = false,
}

--------------------------------------------------------------------------------
-- Version
--------------------------------------------------------------------------------

local function GetVersion()
	-- No legacy fallback: GetAddOnMetadata is gone on every supported client.
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

-- MIGRATION (remove after 2026-11-07): user-added items stored their Name and Icon; both are now read from the client.
local function DropStoredItemNames()
	for key, itemConfig in pairs(ns.db.profile.Items) do
		if type(key) == "number" and type(itemConfig) == "table" then
			itemConfig.Name = nil
			itemConfig.Icon = nil
		end
	end
end

-- Creates the AceDB database and wires the refresh that follows a profile switch.
local function SetupDatabase()
	ns.db = LibStub("AceDB-3.0"):New(ns.SAVED_VARIABLES_NAME, ns.DATABASE_DEFAULTS, true)

	DropStoredItemNames() -- MIGRATION (remove after 2026-11-07)
	ns.RefreshCollectionMeta()

	-- Re-applies everything the profile drives on any profile switch, copy or reset.
	for _, msg in ipairs({ "OnProfileChanged", "OnProfileReset", "OnProfileCopied" }) do
		ns.db.RegisterCallback(ns, msg, "ApplyProfile")
	end
end

function ns:ApplyProfile()
	DropStoredItemNames() -- MIGRATION (remove after 2026-11-07)
	ns.RefreshCollectionMeta()
	if ns.RebuildDispensedItemsOptions then
		ns.RebuildDispensedItemsOptions()
	end
	ns.RefreshGiveaways()
	-- The conjure buttons are shown and hidden imperatively, so they would keep the old profile's switches mid-trade.
	ns.RefreshConjureButtons()

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
	if ns.InitDispensedItemsOptions then
		ns.InitDispensedItemsOptions()
	end
	if ns.InitDispenser then
		ns.InitDispenser()
	end
	-- After InitDispenser: its TRADE_SHOW handler attaches the panel the buttons anchor to.
	if ns.InitConjureButtons then
		ns.InitConjureButtons()
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
	-- After InitDispenser: both claim TRADE_CLOSED, and the restack pass reads the Active flag the dispenser's handler clears.
	if ns.InitRestacker then
		ns.InitRestacker()
	end
	--[[
		Tooltip hooks last, and a frame later still. PLAYER_LOGIN means every add-on is
		loaded; the extra tick lets their own login setup finish, so our secure hook
		wraps the outermost layer they installed and our line is added after theirs.
	]]
	if ns.SetupItemTooltips then
		C_Timer.After(0, ns.SetupItemTooltips)
	end
	if ns.db.profile.showWelcome then
		ns.PrintMessage(format(L["CHAT_LOADED"], ns.Version))
	end
end)
