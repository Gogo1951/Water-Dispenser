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
    LogEvent the events Water Dispenser registers (Core's ns.EVENT_NAMES), and
    BAG_UPDATE is the one sustained firehose among them: it fires per slot
    change, where BAG_UPDATE_DELAYED (once per settle) is kept. The fill writes
    back the BAG_UPDATE firings it acts on, and its own PLACE, SHAPE, FILL and
    SPLIT steps, through ns:LogEventNow.
]]
ns.DIAGNOSTIC_EVENT_EXCLUDE = {
	BAG_UPDATE = true,
}

--[[
    Events that carry a message id, and the argument position it arrives in,
    for ns:SuppressUncorrelatedMessage to classify per firing rather than drop
    wholesale. CHAT_MSG_ADDON carries every add-on's traffic in the group, and
    in a raid the boss mods and meters alone would push everything else out of
    the buffer; its id is the prefix. GET_ITEM_INFO_RECEIVED fires once per item
    the client loads while the Dispensed Items panel waits on a name, hundreds
    of times if Validate Data or a bag add-on runs meanwhile.
]]
ns.MESSAGE_ID_FILTERED_EVENTS = {
	CHAT_MSG_ADDON = 1,
	GET_ITEM_INFO_RECEIVED = 1,
}

--[[
    The ids the live handlers act on, through the same lookups they use: the
    allowlist, never a list of noise.
]]
local CORRELATED_IDS = {
	CHAT_MSG_ADDON = function(prefix)
		return prefix == ns.ADDON_MESSAGE_PREFIX
	end,
	GET_ITEM_INFO_RECEIVED = function(itemId)
		return ns.IsItemNamePending ~= nil and ns.IsItemNamePending(itemId)
	end,
}

--[[
    One argument as log text. A value Forever hides in combat is written as
    <secret> and never stringified, since string-building with one throws.
    Pipes are escaped (| -> ||) AFTER the length cut so each argument shows
    verbatim in the report editbox instead of rendering as a clickable item
    swatch, and so the cut can never leave a dangling pipe that would eat the
    following ", " separator.
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
    filtered position, or a secret one, is unclassifiable, and unclassifiable
    is signal: it logs verbatim. Counters are keyed by event and id, since the
    prefix is a string and an item id a number.

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
	local correlated = CORRELATED_IDS[event]
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
    One entry in the buffer, for ns:LogEvent and ns:LogEventNow below.
    Snapshots arguments to strings immediately -- never retain references, since
    some events carry frames or tables that would leak memory or go stale. Caps
    the arg count and per-argument byte length (ArgumentText above) so a single
    entry can't run away.
]]
local function AppendEntry(event, ...)
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
	AppendEntry(event, ...)
end

--[[
    The way back in for an excluded firehose that is sometimes signal: the
    handler that decides a firing mattered calls this with the event and its
    arguments, and it is recorded as the dispatcher would have, past the
    exclude list. Feature code calls it, so it carries the dispatcher's own
    single boolean check before any work.
]]
function ns:LogEventNow(event, ...)
	if not ns.diagnostics.logging then
		return
	end
	AppendEntry(event, ...)
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
