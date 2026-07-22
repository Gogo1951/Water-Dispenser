local _, ns = ...

--------------------------------------------------------------------------------
-- Diagnostic Tools
--------------------------------------------------------------------------------

--[[
	Environment probing and state capture for bug reports. Read-only, built only
	on a button press, except the Taint Log button, which sets a CVar.
]]

local L = ns.L

--------------------------------------------------------------------------------
-- Runtime State
--------------------------------------------------------------------------------

-- Runtime-only state, not a SavedVariable.
ns.diagnostics = ns.diagnostics or { enabled = false, logging = false, log = nil }

--------------------------------------------------------------------------------
-- Strings
--------------------------------------------------------------------------------

-- Developer-facing strings, deliberately not localized. Kept here, never in Locales/.
ns.DiagnosticsStrings = {
	TAB = "Diagnostic Tools",
	WARNING = "These tools help diagnose problems and are meant for developers. They won't change how the add-on works, but their output includes technical details about your client and installed add-ons. Leave this off unless you're troubleshooting with someone.",
	ENABLE = "Enable Diagnostic Tools",
	EVENT_LOG_TITLE = "Event Log",
	EVENT_LOG_START = "Start Event Log",
	EVENT_LOG_STOP = "Stop Event Log",
	EVENT_LOG_SHOW = "Show Captured Events",
	EVENT_LOG_HINT = "Captures the events the add-on registered for, with arguments, in the order they fired. Review the output before sharing it in a bug report.",
	EVENTS_TITLE = "Event Registration",
	EVENTS_BUTTON = "Test Event Registration",
	API_TITLE = "API Endpoints",
	API_BUTTON = "Test WoW API Endpoints",
	CONTEXT_TITLE = "Trade & Inventory Context",
	CONTEXT_BUTTON = "Probe Trade Context",
	ADDONS_TITLE = "Other Add-ons",
	ADDONS_BUTTON = "List Installed Add-ons",
	SAVED_TITLE = "Saved Variables",
	SAVED_BUTTON = "Dump Saved Variables",
	LIBS_TITLE = "Library Versions",
	LIBS_BUTTON = "List Library Versions",
	TAINT_TITLE = "Taint Log",
	TAINT_STATE = "Taint logging is currently set to level %d (0 = off, 2 = verbose).",
	TAINT_ON = "Turn On Taint Log",
	TAINT_OFF = "Turn Off Taint Log",
	TAINT_HINT = "Writes to Logs\\taint.log. The setting persists until turned off; reload your UI to capture taint from login onward.",
	TOOLS_TITLE = "External Tools",
	TOOLS_ERRORS = "Lua errors: install BugSack and !BugGrabber, or enable %s to surface them.",
	TOOLS_ETRACE = "Live event tracing: use %s.",
}

--------------------------------------------------------------------------------
-- Enable Gate
--------------------------------------------------------------------------------

function ns:SetDiagnosticsEnabled(value)
	ns.diagnostics.enabled = value and true or false
	if not ns.diagnostics.enabled then
		ns:StopEventLog()
	end
end

--------------------------------------------------------------------------------
-- Report Header
--------------------------------------------------------------------------------

local function GetClientHeader()
	local version, build, _, tocVersion = GetBuildInfo()
	return string.format(
		"%s %s // Client %s // Build %s // TOC %s // Locale %s // Project %s",
		L["ADDON_TITLE"],
		ns.Version,
		version,
		build,
		tocVersion,
		GetLocale(),
		tostring(WOW_PROJECT_ID)
	)
end

--------------------------------------------------------------------------------
-- Event Log
--------------------------------------------------------------------------------

local EVENT_LOG_SIZE = 500
local EVENT_LOG_MAX_ARGS = 8

-- Per-argument byte cap. 255 holds a full item link while still bounding a runaway argument.
local EVENT_LOG_MAX_ARG_LENGTH = 255

-- Noisy events the logger skips. BAG_UPDATE fires per slot change; BAG_UPDATE_DELAYED (once per settle) is kept.
ns.DIAGNOSTIC_EVENT_EXCLUDE = {
	BAG_UPDATE = true,
}

function ns:StartEventLog()
	ns.diagnostics.log = {}
	ns.diagnostics.logging = true
end

function ns:StopEventLog()
	ns.diagnostics.logging = false
	ns.diagnostics.log = nil
end

--[[
	Logs one event. Snapshots args to strings immediately (never retains frames
	or tables) and caps arg count and length. Pipes are escaped after the cut so
	args render verbatim and a cut can't leave a dangling pipe.
]]
function ns:LogEvent(event, ...)
	if ns.DIAGNOSTIC_EVENT_EXCLUDE[event] then
		return
	end
	local parts = {}
	for index = 1, select("#", ...) do
		if index > EVENT_LOG_MAX_ARGS then
			break
		end
		local raw = string.sub(tostring((select(index, ...))), 1, EVENT_LOG_MAX_ARG_LENGTH)
		parts[index] = (raw:gsub("|", "||"))
	end
	local log = ns.diagnostics.log
	log[#log + 1] = string.format("%.3f %s(%s)", GetTime(), event, table.concat(parts, ", "))
	if #log > EVENT_LOG_SIZE then
		table.remove(log, 1)
	end
end

function ns:BuildEventLogReport()
	local lines = { GetClientHeader(), "" }
	local log = ns.diagnostics.log
	if not log or #log == 0 then
		lines[#lines + 1] = "(no events captured)"
	else
		for _, entry in ipairs(log) do
			lines[#lines + 1] = entry
		end
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Event Registration
--------------------------------------------------------------------------------

--[[
	For every event in ns.EVENT_NAMES, reports IsEventValid and whether
	RegisterEvent succeeds. The probe frame registers then immediately
	unregisters each one with no handler, so nothing is processed.
]]

local probeFrame

local function GetProbeFrame()
	if not probeFrame then
		probeFrame = CreateFrame("Frame")
	end
	return probeFrame
end

function ns:RunEventChecks()
	local lines = { GetClientHeader(), "" }
	local hasIsEventValid = type(C_EventUtils) == "table" and type(C_EventUtils.IsEventValid) == "function"
	local probe = GetProbeFrame()
	local failures = 0
	for _, event in ipairs(ns.EVENT_NAMES or {}) do
		local valid = "n/a"
		if hasIsEventValid then
			valid = C_EventUtils.IsEventValid(event) and "valid" or "INVALID"
		end
		local ok = pcall(probe.RegisterEvent, probe, event)
		if ok then
			probe:UnregisterEvent(event)
		else
			failures = failures + 1
		end
		lines[#lines + 1] = string.format("[%s] %s (IsEventValid: %s)", ok and "PASS" or "FAIL", event, valid)
	end
	lines[#lines + 1] = ""
	if failures == 0 then
		lines[#lines + 1] = "All events register on this client."
	else
		lines[#lines + 1] = string.format("%d event(s) failed to register.", failures)
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- API Endpoints
--------------------------------------------------------------------------------

--[[
	Existence/shape checks for every API the add-on calls or guards. Modern and
	legacy fallbacks are listed separately so the report shows what each client has.
]]
ns.DIAGNOSTIC_API_CHECKS = {
	-- { label, testFunction }
	{
		"Enum.ItemClass.Consumable",
		function()
			return type(Enum) == "table" and type(Enum.ItemClass) == "table" and Enum.ItemClass.Consumable ~= nil
		end,
	},
	{
		"LE_ITEM_CLASS_CONSUMABLE (legacy)",
		function()
			return LE_ITEM_CLASS_CONSUMABLE ~= nil
		end,
	},
	{
		"C_Container.GetContainerNumSlots",
		function()
			return type(C_Container) == "table" and type(C_Container.GetContainerNumSlots) == "function"
		end,
	},
	{
		"C_Container.GetContainerItemInfo",
		function()
			return type(C_Container) == "table" and type(C_Container.GetContainerItemInfo) == "function"
		end,
	},
	{
		"C_Container.PickupContainerItem",
		function()
			return type(C_Container) == "table" and type(C_Container.PickupContainerItem) == "function"
		end,
	},
	{
		"C_Item.RequestLoadItemDataByID",
		function()
			return type(C_Item) == "table" and type(C_Item.RequestLoadItemDataByID) == "function"
		end,
	},
	{
		"C_Item.GetItemInfo",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemInfo) == "function"
		end,
	},
	{
		"GetItemInfo (legacy)",
		function()
			return type(GetItemInfo) == "function"
		end,
	},
	{
		"TradeFrame_GetAvailableSlot",
		function()
			return type(TradeFrame_GetAvailableSlot) == "function"
		end,
	},
	{
		"ClickTradeButton",
		function()
			return type(ClickTradeButton) == "function"
		end,
	},
	{
		"MAX_TRADABLE_ITEMS",
		function()
			return MAX_TRADABLE_ITEMS ~= nil
		end,
	},
	{
		"GetTradePlayerItemLink",
		function()
			return type(GetTradePlayerItemLink) == "function"
		end,
	},
	{
		"GetTradePlayerItemInfo",
		function()
			return type(GetTradePlayerItemInfo) == "function"
		end,
	},
	{
		"IsSpellKnown",
		function()
			return type(IsSpellKnown) == "function"
		end,
	},
	{
		"IsPlayerSpell",
		function()
			return type(IsPlayerSpell) == "function"
		end,
	},
	{
		"GetMacroIndexByName",
		function()
			return type(GetMacroIndexByName) == "function"
		end,
	},
	{
		"CreateMacro",
		function()
			return type(CreateMacro) == "function"
		end,
	},
	{
		"EditMacro",
		function()
			return type(EditMacro) == "function"
		end,
	},
	{
		"DeleteMacro",
		function()
			return type(DeleteMacro) == "function"
		end,
	},
	{
		"C_Timer.NewTimer",
		function()
			return type(C_Timer) == "table" and type(C_Timer.NewTimer) == "function"
		end,
	},
	{
		"C_AddOns.GetAddOnMetadata",
		function()
			return type(C_AddOns) == "table" and type(C_AddOns.GetAddOnMetadata) == "function"
		end,
	},
	{
		"GetAddOnMetadata (legacy)",
		function()
			return type(GetAddOnMetadata) == "function"
		end,
	},
	{
		"C_EventUtils.IsEventValid",
		function()
			return type(C_EventUtils) == "table" and type(C_EventUtils.IsEventValid) == "function"
		end,
	},
	{
		"GetCVar",
		function()
			return type(GetCVar) == "function"
		end,
	},
	{
		"SetCVar",
		function()
			return type(SetCVar) == "function"
		end,
	},
}

function ns:RunApiChecks()
	local lines = { GetClientHeader(), "" }
	for _, check in ipairs(ns.DIAGNOSTIC_API_CHECKS) do
		local ok, result = pcall(check[2])
		lines[#lines + 1] = ((ok and result) and "[PASS] " or "[FAIL] ") .. check[1]
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Trade & Inventory Context
--------------------------------------------------------------------------------

--[[
	Probes the state behind a "nothing fills" report: player class, trade partner
	class/level, resolved scope, and per-item active/count. Read-only.
]]

-- { spellId, label } — representative gated spells, existence checks only.
ns.DIAGNOSTIC_SPELLS = {
	{ 5504, "Conjure Water (Rank 1)" },
	{ 27090, "Conjure Water (Rank 9)" },
	{ 587, "Conjure Food (Rank 1)" },
	{ 33717, "Conjure Food (Rank 8)" },
	{ 6201, "Create Healthstone (Rank 1)" },
	{ 47878, "Create Healthstone (Rank 8)" },
}

local function CurrentScope(trade)
	if trade and trade.Party then
		return IsInRaid() and "Raid" or "Group"
	end
	return "Solo"
end

function ns:BuildContextReport()
	local lines = { GetClientHeader(), "" }

	local className, classToken = UnitClass("player")
	lines[#lines + 1] = string.format(
		"Player: %s (%s), level %s",
		tostring(className),
		tostring(classToken),
		tostring(UnitLevel("player"))
	)

	local trade = ns.State and ns.State.Trade
	if trade and trade.Active then
		lines[#lines + 1] = string.format(
			"Trade (captured): class=%s level=%s grouped=%s",
			tostring(trade.Class),
			tostring(trade.Level),
			tostring(trade.Party)
		)
		local npcClassLocalized, npcClassToken = UnitClass("NPC")
		lines[#lines + 1] = string.format(
			'Trade (live): UnitClass("NPC")=%s/%s UnitLevel("NPC")=%s',
			tostring(npcClassLocalized),
			tostring(npcClassToken),
			tostring(UnitLevel("NPC"))
		)
	else
		lines[#lines + 1] = "Trade: no active trade window"
	end

	local scope = CurrentScope(trade)
	local activePartner = trade and trade.Active and trade.Class or nil
	if activePartner then
		lines[#lines + 1] =
			string.format("Resolved scope: %s (active trade partner class: %s)", scope, tostring(activePartner))
	else
		lines[#lines + 1] = string.format("Resolved scope: %s (no active trade; counts shown per partner class)", scope)
	end
	lines[#lines + 1] = ""

	--[[
		Auto-fill (Dispense) toggles + the resolved-scope decision; the most common
		"nothing auto-filled" cause is the master or the matching scope toggle being off.
	]]
	local db = ns.db and ns.db.profile
	if db then
		lines[#lines + 1] = string.format(
			"Auto-fill (Dispense): master=%s, Solo=%s, Group=%s, Raid=%s",
			tostring(db.Dispense),
			tostring(db.DispenseSolo),
			tostring(db.DispenseGroup),
			tostring(db.DispenseRaid)
		)
		lines[#lines + 1] = string.format(
			"Would auto-fill for resolved scope %s: %s",
			scope,
			tostring((db.Dispense and db["Dispense" .. scope]) and true or false)
		)
	else
		lines[#lines + 1] = "Auto-fill (Dispense): (DB not initialized)"
	end
	lines[#lines + 1] = ""

	lines[#lines + 1] = "Configured items (counts = stacks given to a partner of each class):"
	if ns.db and ns.db.profile.Items then
		local keys = {}
		for key in pairs(ns.db.profile.Items) do
			keys[#keys + 1] = key
		end
		table.sort(keys, function(a, b)
			return tostring(a) < tostring(b)
		end)
		for _, key in ipairs(keys) do
			local itemConfig = ns.db.profile.Items[key]
			local active = ns.IsItemActiveForPlayer(itemConfig)
			local scopeTable = itemConfig[scope] or {}
			local parts = {}
			for _, class in ipairs(ns.CLASSES) do
				parts[#parts + 1] = class .. "=" .. tostring(scopeTable[class] or 0)
			end
			lines[#lines + 1] = string.format(
				"  %s: activeForPlayer=%s, %s counts: %s",
				tostring(itemConfig.Name or key),
				tostring(active),
				scope,
				table.concat(parts, " ")
			)
		end
	else
		lines[#lines + 1] = "  (DB not initialized)"
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] = "Spells (verdict via ns.IsSpellLearned; raw checks in parentheses):"
	local hasIsSpellKnown = type(IsSpellKnown) == "function"
	local hasIsPlayerSpell = type(IsPlayerSpell) == "function"
	for _, spell in ipairs(ns.DIAGNOSTIC_SPELLS) do
		local id, label = spell[1], spell[2]
		local verdict = ns.IsSpellLearned(id) and "known" or "unknown"
		local rawKnown = hasIsSpellKnown and tostring(IsSpellKnown(id)) or "n/a"
		local rawPlayer = hasIsPlayerSpell and tostring(IsPlayerSpell(id)) or "n/a"
		lines[#lines + 1] =
			string.format("  [%s] %s (%d) (IsSpellKnown=%s, IsPlayerSpell=%s)", verdict, label, id, rawKnown, rawPlayer)
	end

	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Other Add-ons
--------------------------------------------------------------------------------

function ns:BuildAddOnReport()
	local lines = { GetClientHeader(), "" }
	local getInfo = (C_AddOns and C_AddOns.GetAddOnInfo) or GetAddOnInfo
	local getMeta = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
	local count = (C_AddOns and C_AddOns.GetNumAddOns and C_AddOns.GetNumAddOns()) or GetNumAddOns()
	for index = 1, count do
		local name, _, _, loadable = getInfo(index)
		local version = getMeta(index, "Version") or "?"
		lines[#lines + 1] = string.format("%s v%s [%s]", name, version, loadable and "loadable" or "disabled")
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Saved Variables
--------------------------------------------------------------------------------

local function DumpTable(value, indent, depth, lines)
	if depth > 8 then
		lines[#lines + 1] = indent .. "<max depth>"
		return
	end
	local keys = {}
	for key in pairs(value) do
		keys[#keys + 1] = key
	end
	-- Summarize oversized tables by length so a large custom item list can't blow up the dump.
	if #keys > 20 then
		lines[#lines + 1] = indent .. "<" .. #keys .. " entries>"
		return
	end
	table.sort(keys, function(a, b)
		return tostring(a) < tostring(b)
	end)
	for _, key in ipairs(keys) do
		local entry = value[key]
		if type(entry) == "table" then
			lines[#lines + 1] = indent .. tostring(key) .. " = {"
			DumpTable(entry, indent .. "    ", depth + 1, lines)
			lines[#lines + 1] = indent .. "}"
		else
			lines[#lines + 1] = indent .. tostring(key) .. " = " .. tostring(entry)
		end
	end
end

function ns:BuildSavedVariablesReport()
	local lines = { GetClientHeader(), "" }

	lines[#lines + 1] = "WaterDispenserDB = {"
	DumpTable(WaterDispenserDB or {}, "    ", 1, lines)
	lines[#lines + 1] = "}"

	--[[
		MIGRATION (remove after 2026-10-12): the legacy per-character table is only
		present until the seed window closes; drop this block with the migration.
	]]
	if type(WaterDispenserCharDB) == "table" then
		lines[#lines + 1] = ""
		lines[#lines + 1] = "WaterDispenserCharDB (legacy) = {"
		DumpTable(WaterDispenserCharDB, "    ", 1, lines)
		lines[#lines + 1] = "}"
	end

	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Library Versions
--------------------------------------------------------------------------------

function ns:BuildLibraryReport()
	local lines = { GetClientHeader(), "" }
	local names = {}
	for name in LibStub:IterateLibraries() do
		names[#names + 1] = name
	end
	table.sort(names)
	for _, name in ipairs(names) do
		lines[#lines + 1] = string.format("%s (minor %s)", name, tostring(LibStub.minors[name]))
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Taint Log
--------------------------------------------------------------------------------

-- The taintLog CVar logs UI taint to Logs\taint.log (2 = verbose, 0 = off); the only state the diagnostics panel writes.

function ns:GetTaintLogState()
	return tonumber(GetCVar("taintLog")) or 0
end

function ns:SetTaintLog(enabled)
	SetCVar("taintLog", enabled and 2 or 0)
end
