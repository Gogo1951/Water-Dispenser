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
	VALIDATE_TITLE = "Validate Data: %s",
	VALIDATE_BUTTON = "Validate %s",
	VALIDATE_PROGRESS = "Validated %d / %d ...",
	VALIDATE_HINT = "Exports every ID this data file ships with whatever the client knows about it, tab-separated so it pastes straight into a spreadsheet. The rows worth reading are the ones flagged NOT ON CLIENT.",
	VALIDATE_SUMMARY = "%d of %d IDs are not on this client.",
	VALIDATE_SUMMARY_CLEAN = "All %d IDs resolved on this client.",
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
	if ns.diagnostics.enabled then
		return
	end

	ns:StopEventLog()
	--[[
		Off means off: switching the panel off releases the event buffer and every
		report built while it was on, so nothing the tools allocated outlives them.
		Everything except the two state flags is a capture or a report, so clearing
		by exception cannot miss a field a new section adds.
	]]
	for key in pairs(ns.diagnostics) do
		if key ~= "enabled" and key ~= "logging" then
			ns.diagnostics[key] = nil
		end
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

--[[
	Noisy events the logger skips. BAG_UPDATE fires per slot change;
	BAG_UPDATE_DELAYED (once per settle) is kept. An excluded event's signal
	firings are written back through ns:LogEventNow by the handler that acts on them.
]]
ns.DIAGNOSTIC_EVENT_EXCLUDE = {
	BAG_UPDATE = true,
}

function ns:StartEventLog()
	ns.diagnostics.log = {}
	ns.diagnostics.logging = true
end

--[[
	Stopping keeps what was captured, so start, reproduce, stop, show returns a real
	report rather than an empty one. Only two things clear it: starting a new
	capture, and switching Diagnostic Tools off, which releases the buffer along
	with every built report.
]]
function ns:StopEventLog()
	ns.diagnostics.logging = false
end

--[[
	Appends one entry. Snapshots args to strings immediately (never retains frames
	or tables) and caps arg count and length. Pipes are escaped after the cut so
	args render verbatim and a cut can't leave a dangling pipe.
]]
local function AppendLogEntry(event, ...)
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

-- The dispatcher's tap: everything except the firehoses above.
function ns:LogEvent(event, ...)
	if ns.DIAGNOSTIC_EVENT_EXCLUDE[event] then
		return
	end
	AppendLogEntry(event, ...)
end

--[[
	Logs regardless of the exclude list, for a handler that wants the firings of an
	excluded event it actually acted on. Without it a bag-driven refill leaves no
	trace at all, and the log can't answer why the trade did or didn't top up.
]]
function ns:LogEventNow(event, ...)
	AppendLogEntry(event, ...)
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
		-- Portioning rests on these: without a split that honors its count, the fill can only hand over whole bag slots.
		"C_Container.SplitContainerItem",
		function()
			return type(C_Container) == "table" and type(C_Container.SplitContainerItem) == "function"
		end,
	},
	{
		"SplitContainerItem (legacy)",
		function()
			return type(SplitContainerItem) == "function"
		end,
	},
	{
		"GetCursorInfo",
		function()
			return type(GetCursorInfo) == "function"
		end,
	},
	{
		"CursorHasItem",
		function()
			return type(CursorHasItem) == "function"
		end,
	},
	{
		"ClearCursor",
		function()
			return type(ClearCursor) == "function"
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
		"C_Item.DoesItemExistByID",
		function()
			return type(C_Item) == "table" and type(C_Item.DoesItemExistByID) == "function"
		end,
	},
	{
		"C_Item.GetItemInfoInstant",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemInfoInstant) == "function"
		end,
	},
	{
		"GetItemInfoInstant (legacy)",
		function()
			return type(GetItemInfoInstant) == "function"
		end,
	},
	{
		"C_Spell.GetSpellInfo",
		function()
			return type(C_Spell) == "table" and type(C_Spell.GetSpellInfo) == "function"
		end,
	},
	{
		"C_Spell.GetSpellSubtext",
		function()
			return type(C_Spell) == "table" and type(C_Spell.GetSpellSubtext) == "function"
		end,
	},
	{
		"GetSpellInfo (legacy)",
		function()
			return type(GetSpellInfo) == "function"
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
		"C_ChatInfo.RegisterAddonMessagePrefix",
		function()
			return type(C_ChatInfo) == "table" and type(C_ChatInfo.RegisterAddonMessagePrefix) == "function"
		end,
	},
	{
		"C_ChatInfo.SendAddonMessage",
		function()
			return type(C_ChatInfo) == "table" and type(C_ChatInfo.SendAddonMessage) == "function"
		end,
	},
	{
		"GameTooltip:GetUnit",
		function()
			return type(GameTooltip) == "table" and type(GameTooltip.GetUnit) == "function"
		end,
	},
	{
		"Settings.OpenToCategory",
		function()
			return type(Settings) == "table" and type(Settings.OpenToCategory) == "function"
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
		"C_AddOns.GetAddOnInfo",
		function()
			return type(C_AddOns) == "table" and type(C_AddOns.GetAddOnInfo) == "function"
		end,
	},
	{
		"GetAddOnInfo (legacy)",
		function()
			return type(GetAddOnInfo) == "function"
		end,
	},
	{
		"C_AddOns.GetNumAddOns",
		function()
			return type(C_AddOns) == "table" and type(C_AddOns.GetNumAddOns) == "function"
		end,
	},
	{
		"GetNumAddOns (legacy)",
		function()
			return type(GetNumAddOns) == "function"
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

-- IsSpellKnown misses some trained ranks on Classic Era; IsPlayerSpell is the fallback, either true counts as known.
local function IsSpellLearned(spellId)
	if IsSpellKnown and IsSpellKnown(spellId) then
		return true
	end
	if IsPlayerSpell and IsPlayerSpell(spellId) then
		return true
	end
	return false
end

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
		lines[#lines + 1] = string.format("Combine partial stacks (RestackBags): %s", tostring(db.RestackBags))
	else
		lines[#lines + 1] = "Auto-fill (Dispense): (DB not initialized)"
	end
	lines[#lines + 1] = ""

	lines[#lines + 1] = "Configured items (counts = individual items given to a partner of each class):"
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
			--[[
				The reserve is reported alongside the counts because it is the gate that
				silently stops a fill the counts say should happen: it holds back anything
				that would dip the bags below it, so the dump would otherwise show a
				perfectly healthy config for a trade that hands over nothing.
			]]
			lines[#lines + 1] = string.format(
				"  %s: activeForPlayer=%s, distribute=%s (allowed now: %s), reserve=%d, sessionCap=%s, %s counts: %s",
				tostring(ns.GetItemConfigName(key, itemConfig) or key),
				tostring(active),
				tostring(itemConfig.Distribute or "Always"),
				tostring(ns.IsItemDistributableNow(itemConfig)),
				ns.GetItemReserve(itemConfig),
				tostring(ns.GetItemSessionCap(itemConfig) or "off"),
				scope,
				table.concat(parts, " ")
			)
		end
	else
		lines[#lines + 1] = "  (DB not initialized)"
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] = "Spells (verdict via IsSpellLearned; raw checks in parentheses):"
	local hasIsSpellKnown = type(IsSpellKnown) == "function"
	local hasIsPlayerSpell = type(IsPlayerSpell) == "function"
	for _, spell in ipairs(ns.DIAGNOSTIC_SPELLS) do
		local id, label = spell[1], spell[2]
		local verdict = IsSpellLearned(id) and "known" or "unknown"
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
	--[[
		GetAddOnMetadata's legacy global is gone on Era 1.15.9 (the API probe reports
		it absent), so this namespace is called directly. Its two siblings are probed
		rather than assumed: they moved in the same patch, but that is not the same as
		having watched them fail.
	]]
	local getInfo = C_AddOns.GetAddOnInfo or GetAddOnInfo
	local getMeta = C_AddOns.GetAddOnMetadata
	local count = (C_AddOns.GetNumAddOns or GetNumAddOns)()
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

	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Validate Data
--------------------------------------------------------------------------------

--[[
	One entry per static data file the add-on ships. Tables name each static table
	in it, the kind of ID its keys hold, and the label the SOURCE column carries.
	The panel builds one section per entry, so a new data file adds a row here
	rather than a new builder, and the validator can't drift from what ships.

	IdFrom = "value" reads the ID out of the value instead of the key, for a plain
	array of IDs rather than an [id] = data map.
]]
ns.DIAGNOSTIC_DATA_SOURCES = {
	{
		Label = "Data/Collections.lua",
		Tables = {
			{ Source = "MageWater.Items", Kind = "item", Table = ns.COLLECTIONS.MageWater.Items },
			{ Source = "MageFood.Items", Kind = "item", Table = ns.COLLECTIONS.MageFood.Items },
			{ Source = "WarlockHealthstone.Items", Kind = "item", Table = ns.COLLECTIONS.WarlockHealthstone.Items },
			{ Source = "MageWater.Spells", Kind = "spell", Table = ns.COLLECTIONS.MageWater.Spells },
			{ Source = "MageFood.Spells", Kind = "spell", Table = ns.COLLECTIONS.MageFood.Spells },
			{ Source = "WarlockHealthstone.Spells", Kind = "spell", Table = ns.COLLECTIONS.WarlockHealthstone.Spells },
			{
				Source = "HEALTHSTONE_TALENT_SPELLS",
				Kind = "spell",
				Table = ns.HEALTHSTONE_TALENT_SPELLS,
				IdFrom = "value",
			},
		},
	},
}

local VALIDATE_BATCH_SIZE = 100

-- Ticks an item ID may stay uncached before it is flagged rather than waited on.
local VALIDATE_MAX_RETRIES = 20

local STATUS_OK = "OK"
local STATUS_MISSING = "NOT ON CLIENT"

--[[
	One TSV cell. Tabs and newlines would break the grid, and pipes are escaped so
	an item link pastes as copyable text rather than rendering as a link.
]]
local function Cell(value)
	local text = (value == nil) and "" or tostring(value)
	text = text:gsub("[\t\r\n]", " ")
	return (text:gsub("|", "||"))
end

local function Row(...)
	local cells = {}
	for index = 1, select("#", ...) do
		cells[index] = Cell((select(index, ...)))
	end
	return table.concat(cells, "\t")
end

local function BoolCell(fn, id)
	if type(fn) ~= "function" then
		return "n/a"
	end
	return tostring(fn(id) and true or false)
end

local SPELL_COLUMNS = Row(
	"STATUS",
	"SOURCE",
	"ID",
	"NAME",
	"RANK",
	"ICON",
	"CAST_TIME",
	"MIN_RANGE",
	"MAX_RANGE",
	"IS_PLAYER_SPELL",
	"IS_SPELL_KNOWN"
)

local ITEM_COLUMNS = Row(
	"STATUS",
	"SOURCE",
	"ID",
	"NAME",
	"LINK",
	"QUALITY",
	"ITEM_LEVEL",
	"MIN_LEVEL",
	"TYPE",
	"SUBTYPE",
	"STACK_COUNT",
	"EQUIP_LOC",
	"TEXTURE",
	"SELL_PRICE",
	"CLASS_ID",
	"SUBCLASS_ID",
	"BIND_TYPE",
	"EXPANSION_ID",
	"SET_ID",
	"CRAFTING_REAGENT",
	"INSTANT_TYPE",
	"INSTANT_SUBTYPE",
	"INSTANT_EQUIP_LOC",
	"INSTANT_ICON",
	"INSTANT_CLASS_ID",
	"INSTANT_SUBCLASS_ID"
)

-- Modern namespace when the client has it, legacy global otherwise; existence is checked, then exactly one is called.
local function SpellFields(spellId)
	if C_Spell and C_Spell.GetSpellInfo then
		local info = C_Spell.GetSpellInfo(spellId)
		if not info then
			return nil
		end
		local subtext = C_Spell.GetSpellSubtext and C_Spell.GetSpellSubtext(spellId)
		return info.name, subtext, info.iconID, info.castTime, info.minRange, info.maxRange
	end
	if GetSpellInfo then
		return GetSpellInfo(spellId)
	end
	return nil
end

local function SpellRow(source, spellId)
	local name, rank, icon, castTime, minRange, maxRange = SpellFields(spellId)
	if not name then
		return Row(STATUS_MISSING, source, spellId), true
	end
	return Row(
		STATUS_OK,
		source,
		spellId,
		name,
		rank,
		icon,
		castTime,
		minRange,
		maxRange,
		BoolCell(IsPlayerSpell, spellId),
		BoolCell(IsSpellKnown, spellId)
	),
		false
end

--[[
	Returns "missing" or "ok" with the row, or "pending" with no row while the
	client is still loading the item. A cold GetItemInfo returns nil for an item
	that exists, so pending is retried rather than flagged.
]]
local function ItemRow(source, itemId)
	if C_Item and C_Item.DoesItemExistByID and not C_Item.DoesItemExistByID(itemId) then
		return "missing", Row(STATUS_MISSING, source, itemId)
	end

	local name, link, quality, itemLevel, minLevel, itemType, subType, stackCount, equipLoc, texture, sellPrice, classID, subclassID, bindType, expacID, setID, isReagent =
		ns.GetItemInfo(itemId)
	if not name then
		return "pending"
	end

	local getInstant = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant
	local instantType, instantSubType, instantEquipLoc, instantIcon, instantClassID, instantSubclassID
	if getInstant then
		local _
		_, instantType, instantSubType, instantEquipLoc, instantIcon, instantClassID, instantSubclassID =
			getInstant(itemId)
	end

	return "ok",
		Row(
			STATUS_OK,
			source,
			itemId,
			name,
			link,
			quality,
			itemLevel,
			minLevel,
			itemType,
			subType,
			stackCount,
			equipLoc,
			texture,
			sellPrice,
			classID,
			subclassID,
			bindType,
			expacID,
			setID,
			isReagent,
			instantType,
			instantSubType,
			instantEquipLoc,
			instantIcon,
			instantClassID,
			instantSubclassID
		)
end

--[[
	Exports every ID in one data source as TSV, flagging what this client doesn't
	know. Item data loads asynchronously, so the walk runs in batched ticks with a
	progress line in the output rather than stalling inside one frame; an ID that
	never loads is flagged after VALIDATE_MAX_RETRIES rather than waited on forever.
]]
function ns:RunValidateData(sourceIndex)
	local source = ns.DIAGNOSTIC_DATA_SOURCES[sourceIndex]
	if not source then
		return
	end

	local field = "validateReport" .. sourceIndex
	local queue = {}
	for _, entry in ipairs(source.Tables) do
		for key, value in pairs(entry.Table) do
			local id = (entry.IdFrom == "value") and value or key
			queue[#queue + 1] = { Source = entry.Source, Kind = entry.Kind, Id = id }
		end
	end
	table.sort(queue, function(a, b)
		if a.Source ~= b.Source then
			return a.Source < b.Source
		end
		return a.Id < b.Id
	end)

	local total = #queue
	if C_Item and C_Item.RequestLoadItemDataByID then
		for _, entry in ipairs(queue) do
			if entry.Kind == "item" then
				C_Item.RequestLoadItemDataByID(entry.Id)
			end
		end
	end

	local itemRows, spellRows = {}, {}
	local index, flagged = 1, 0

	local function RefreshPanel()
		if ns.RefreshDiagnosticsPanel then
			ns.RefreshDiagnosticsPanel()
		end
	end

	local function Finish()
		local lines = { GetClientHeader(), "" }
		if #spellRows > 0 then
			lines[#lines + 1] = SPELL_COLUMNS
			for _, row in ipairs(spellRows) do
				lines[#lines + 1] = row
			end
			lines[#lines + 1] = ""
		end
		if #itemRows > 0 then
			lines[#lines + 1] = ITEM_COLUMNS
			for _, row in ipairs(itemRows) do
				lines[#lines + 1] = row
			end
			lines[#lines + 1] = ""
		end
		if flagged > 0 then
			lines[#lines + 1] = string.format(ns.DiagnosticsStrings.VALIDATE_SUMMARY, flagged, total)
		else
			lines[#lines + 1] = string.format(ns.DiagnosticsStrings.VALIDATE_SUMMARY_CLEAN, total)
		end
		ns.diagnostics[field] = table.concat(lines, "\n")
		RefreshPanel()
	end

	local function Step()
		local processed = 0
		local deferred = {}
		while index <= #queue and processed < VALIDATE_BATCH_SIZE do
			local entry = queue[index]
			index = index + 1
			processed = processed + 1

			if entry.Kind == "spell" then
				local row, missing = SpellRow(entry.Source, entry.Id)
				spellRows[#spellRows + 1] = row
				if missing then
					flagged = flagged + 1
				end
			else
				local status, row = ItemRow(entry.Source, entry.Id)
				if status == "pending" then
					entry.Retries = (entry.Retries or 0) + 1
					if entry.Retries <= VALIDATE_MAX_RETRIES then
						deferred[#deferred + 1] = entry
					else
						itemRows[#itemRows + 1] = Row(STATUS_MISSING, entry.Source, entry.Id)
						flagged = flagged + 1
					end
				else
					itemRows[#itemRows + 1] = row
					if status == "missing" then
						flagged = flagged + 1
					end
				end
			end
		end

		--[[
			Requeued for the NEXT tick, never re-polled inside this one: the cache cannot
			answer differently in the same frame, so an in-batch retry would burn the whole
			allowance without giving the client a chance to load.
		]]
		for _, entry in ipairs(deferred) do
			queue[#queue + 1] = entry
		end

		if index > #queue then
			Finish()
			return
		end

		ns.diagnostics[field] = string.format(ns.DiagnosticsStrings.VALIDATE_PROGRESS, #itemRows + #spellRows, total)
		RefreshPanel()
		C_Timer.After(0, Step)
	end

	Step()
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
