local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader

--------------------------------------------------------------------------------
-- Event Log
--------------------------------------------------------------------------------

local EVENT_LOG_SIZE = 500
local EVENT_LOG_MAX_ARGS = 8
local EVENT_LOG_MAX_ARG_LENGTH = 255

--[[
	Events ns:LogEvent drops before recording. The dispatcher only ever hands
	LogEvent the events the add-on registers (Core's ns.EVENT_NAMES), so a
	generic offender belongs here only once it is registered. A firehose that is
	sometimes signal and carries no id goes here, and the handler that acts on it
	writes its signal firings back through ns:LogEventNow.
]]
ns.DIAGNOSTIC_EVENT_EXCLUDE = ns.DIAGNOSTIC_EVENT_EXCLUDE or {}

--[[
	Events that carry a message id, and the argument position it arrives in, for
	ns:SuppressUncorrelatedMessage to classify per firing rather than drop
	wholesale. The ids the add-on acts on come from ns.DIAGNOSTIC_CORRELATED_IDS
	in Diagnostics/Manifests.lua: one function per event, answering through the
	same lookup the live handler uses, so the allowlist can never drift from it.
]]
ns.MESSAGE_ID_FILTERED_EVENTS = ns.MESSAGE_ID_FILTERED_EVENTS or {}

--[[
	One argument as log text. A value Forever hides in combat is written as
	<secret> and never stringified. Pipes are escaped (| -> ||) AFTER the length
	cut so each argument shows verbatim in the report editbox instead of rendering
	as a clickable item swatch, and so the cut can never leave a dangling pipe
	that would eat the following ", " separator.
]]
local function ArgumentText(value)
	if ns.IsSecretValue(value) then
		return "<secret>"
	end
	local raw = string.sub(tostring(value), 1, EVENT_LOG_MAX_ARG_LENGTH)
	return (raw:gsub("|", "||"))
end

--[[
	Per-firing filter for the events above. A firing whose id the add-on does
	not correlate folds into a per-id counter (first-seen text plus a count)
	rendered as one block at the end of the report, so firehose traffic can't
	evict the entries the log exists to carry. A firing carrying no id in the
	filtered position, or a secret one, is unclassifiable, and unclassifiable is
	signal: it logs verbatim.

	Returns true when the firing was counted and must not reach the buffer.
]]
function ns:SuppressUncorrelatedMessage(event, ...)
	local idPosition = ns.MESSAGE_ID_FILTERED_EVENTS[event]
	if not idPosition then
		return false
	end
	local messageID = select(idPosition, ...)
	if ns.IsSecretValue(messageID) then
		return false
	end
	local idType = type(messageID)
	if idType ~= "number" and idType ~= "string" then
		return false
	end
	local correlated = ns.DIAGNOSTIC_CORRELATED_IDS and ns.DIAGNOSTIC_CORRELATED_IDS[event]
	if correlated and correlated(messageID) then
		return false
	end
	local suppressed = ns.diagnostics.suppressed
	if not suppressed then
		return true
	end
	local key = event .. "(" .. tostring(messageID) .. ")"
	local entry = suppressed[key]
	if entry then
		entry.count = entry.count + 1
		return true
	end
	local text = ""
	if select("#", ...) > idPosition then
		text = ArgumentText((select(idPosition + 1, ...)))
	end
	suppressed[key] = { event = event, id = ArgumentText(messageID), text = text, count = 1 }
	return true
end

function ns:StartEventLog()
	ns.diagnostics.log = {}
	ns.diagnostics.suppressed = {}
	ns.diagnostics.logging = true
end

function ns:StopEventLog()
	ns.diagnostics.logging = false
end

--[[
	Appends one entry. Snapshots arguments to strings immediately -- never retain
	references, since some events carry frames or tables that would leak memory
	or go stale -- and caps the argument count and each argument's byte length so
	a single entry can't run away.
]]
local function AppendLogEntry(event, ...)
	local log = ns.diagnostics.log
	if not log then
		return
	end
	local parts = {}
	for index = 1, select("#", ...) do
		if index > EVENT_LOG_MAX_ARGS then
			break
		end
		parts[index] = ArgumentText((select(index, ...)))
	end
	log[#log + 1] = string.format("%.3f %s(%s)", GetTime(), event, table.concat(parts, ", "))
	if #log > EVENT_LOG_SIZE then
		table.remove(log, 1)
	end
end

-- Called by Core's central dispatcher for every event while logging is active.
function ns:LogEvent(event, ...)
	if ns.DIAGNOSTIC_EVENT_EXCLUDE[event] then
		return
	end
	if ns:SuppressUncorrelatedMessage(event, ...) then
		return
	end
	AppendLogEntry(event, ...)
end

--[[
	Logs past the exclude list and the filter, for a handler writing back the
	firings of an excluded event it acted on, or a step of its own the events
	alone can't show. Callers check ns.diagnostics.logging first.
]]
function ns:LogEventNow(event, ...)
	AppendLogEntry(event, ...)
end

--[[
	Renders the suppressed-traffic counters as one compact block, biggest
	offender first. This is also how a tester discovers a message id the add-on
	should be correlating but isn't.
]]
local function AppendSuppressedSummary(lines)
	local suppressed = ns.diagnostics.suppressed
	if not suppressed then
		return
	end
	local rows = {}
	for key, entry in pairs(suppressed) do
		rows[#rows + 1] = { key = key, entry = entry }
	end
	if #rows == 0 then
		return
	end
	table.sort(rows, function(a, b)
		if a.entry.count ~= b.entry.count then
			return a.entry.count > b.entry.count
		end
		return a.key < b.key
	end)
	lines[#lines + 1] = ""
	lines[#lines + 1] = "Suppressed uncorrelated traffic:"
	for _, row in ipairs(rows) do
		lines[#lines + 1] =
			string.format("%s(%s, %s) x%d", row.entry.event, row.entry.id, row.entry.text, row.entry.count)
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
	AppendSuppressedSummary(lines)
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Taint Log
--------------------------------------------------------------------------------

--[[
	The taintLog CVar controls UI taint logging to Logs\taint.log. Level 2 logs
	both blocked actions and accesses to tainted globals; 0 is off. This is the
	only state the diagnostics panel ever writes.
]]

function ns:GetTaintLogState()
	return tonumber(GetCVar("taintLog")) or 0
end

function ns:SetTaintLog(enabled)
	SetCVar("taintLog", enabled and 2 or 0)
end
