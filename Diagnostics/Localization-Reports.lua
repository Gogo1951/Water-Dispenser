local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader
local CountKeys = ns.CountDiagnosticKeys
local D = ns.DiagnosticsStrings

--------------------------------------------------------------------------------
-- Locale Context
--------------------------------------------------------------------------------

function ns:BuildLocaleContextReport()
	local lines = { GetClientHeader(), "" }
	lines[#lines + 1] = string.format("GetLocale: %s", tostring(GetLocale()))
	lines[#lines + 1] = string.format("textLocale CVar: %s", tostring(GetCVar("textLocale")))
	lines[#lines + 1] = string.format("audioLocale CVar: %s", tostring(GetCVar("audioLocale")))
	lines[#lines + 1] = string.format("Locale keys (ns.L): %d", CountKeys(ns.L))
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Game Names
--------------------------------------------------------------------------------

--[[
    One line per ns.DIAGNOSTIC_NAME_LOOKUPS row: the name this client returns
    through the row's own lookup, or NIL. A row with a request function names
    something that loads late, so the report asks for it and polls with
    Validate Data's cadence before settling it as NIL. Every timer carries the
    run's generation, so Stop retires the chain.
]]
local NAME_POLL_SECONDS = 0.5
local NAME_REASK_POLLS = 3
local NAME_MAX_IDLE_POLLS = 12

local nameRun = { generation = 0 }

-- The row's name, or nil and the message when its lookup throws.
local function ReadName(row)
	local ok, name = pcall(row.lookup)
	if not ok then
		return nil, tostring(name)
	end
	if name == nil or tostring(name) == "" then
		return nil, nil
	end
	return tostring(name), nil
end

-- Line breaks shown as a literal \n, and pipes escaped so links paste as text.
local function ShownText(text)
	local shown = text:gsub("\r?\n", "\\n")
	shown = shown:gsub("|", "||")
	return shown
end

local function PendingRows()
	local pending = {}
	for _, row in ipairs(ns.DIAGNOSTIC_NAME_LOOKUPS) do
		if row.request and not ReadName(row) then
			pending[#pending + 1] = row
		end
	end
	return pending
end

local function RequestRows(rows)
	for _, row in ipairs(rows) do
		pcall(row.request)
	end
end

local function FinishNames(run)
	local lines = { GetClientHeader(), "" }
	local missing = 0
	for _, row in ipairs(ns.DIAGNOSTIC_NAME_LOOKUPS) do
		local name, problem = ReadName(row)
		if not name then
			missing = missing + 1
		end
		lines[#lines + 1] = string.format(
			"[%s] %s (%s %s): %s",
			name and "OK" or "NIL",
			row.constant,
			row.kind,
			tostring(row.id),
			ShownText(name or problem or "")
		)
	end
	local onFinish = run.onFinish
	run.onFinish = nil
	if onFinish then
		onFinish(
			table.concat(lines, "\n"),
			missing == 0 and D.NAMES_ALL_FOUND or string.format(D.NAMES_SOME_NIL, missing)
		)
	end
end

local function ScheduleNames(run, delay, step)
	local generation = run.generation
	C_Timer.After(delay, function()
		if run.generation ~= generation then
			return
		end
		local ok, problem = pcall(step, run)
		if not ok then
			local onFinish = run.onFinish
			run.onFinish = nil
			run.generation = run.generation + 1
			if onFinish then
				onFinish(nil, nil, tostring(problem))
			end
		end
	end)
end

local function PollNames(run)
	local pending = PendingRows()
	if #pending == 0 then
		FinishNames(run)
		return
	end
	if #pending < run.pendingCount then
		run.pendingCount = #pending
		run.idlePolls = 0
	else
		run.idlePolls = run.idlePolls + 1
	end
	if run.idlePolls >= NAME_MAX_IDLE_POLLS then
		FinishNames(run)
		return
	end
	if run.idlePolls > 0 and run.idlePolls % NAME_REASK_POLLS == 0 then
		RequestRows(pending)
	end
	ScheduleNames(run, NAME_POLL_SECONDS, PollNames)
end

--[[
    onFinish(text, note) receives the finished report and its status note, or
    onFinish(nil, nil, problem) when a step threw. A stopped run never calls it.
]]
function ns:StartNameLookupReport(onFinish)
	nameRun.generation = nameRun.generation + 1
	nameRun.onFinish = onFinish
	nameRun.idlePolls = 0
	local pending = PendingRows()
	nameRun.pendingCount = #pending
	if #pending == 0 then
		ScheduleNames(nameRun, 0, FinishNames)
		return
	end
	RequestRows(pending)
	ScheduleNames(nameRun, NAME_POLL_SECONDS, PollNames)
end

function ns:StopNameLookupReport()
	nameRun.generation = nameRun.generation + 1
	nameRun.onFinish = nil
end

--------------------------------------------------------------------------------
-- Message Length
--------------------------------------------------------------------------------

--[[
	The announcement macro's longest body in this language: each collection's
	longest-named item, every user item, the longest channel slash, through the
	add-on's own builders (ns.BuildAnnouncementPart, ns.BuildAnnouncementMacroBody).
	The count is four digits, since it is what the player carries less the
	reserve and a stack of arrows runs past 1,000. Builds strings only: nothing
	is sent and no macro is written. An item the client hasn't loaded is left out
	and listed; running Game Names first loads the built-in ones.
]]
local WORST_CASE_COUNT = 9999

local function LongestLink(itemIds)
	local bestLink, unloaded = nil, {}
	for _, itemId in ipairs(itemIds) do
		local _, link = C_Item.GetItemInfo(itemId)
		if link then
			if not bestLink or #link > #bestLink then
				bestLink = link
			end
		else
			unloaded[#unloaded + 1] = itemId
			pcall(C_Item.RequestLoadItemDataByID, itemId)
		end
	end
	return bestLink, unloaded
end

function ns:BuildMessageLengthReport()
	local lines = { GetClientHeader(), "" }
	local items = ns.db and ns.db.profile.Items or {}
	local parts, unloaded = {}, {}

	local function AddPart(label, itemIds, itemConfig)
		local link, missing = LongestLink(itemIds)
		for _, itemId in ipairs(missing) do
			unloaded[#unloaded + 1] = itemId
		end
		if link then
			local part = ns.BuildAnnouncementPart(link, WORST_CASE_COUNT, ns.GetItemIncludeQuantity(itemConfig))
			parts[#parts + 1] = part
			lines[#lines + 1] = string.format("  %s: %d bytes, %s", label, #part, (part:gsub("|", "||")))
		end
	end

	lines[#lines + 1] = "Longest part per item:"
	for _, key in ipairs(ns.BUILTIN_ORDER) do
		local collection = ns.COLLECTIONS[key]
		local itemIds = {}
		for itemId in pairs(collection and collection.Items or {}) do
			itemIds[#itemIds + 1] = itemId
		end
		table.sort(itemIds)
		AddPart(key, itemIds, items[key])
	end
	local userIds = {}
	for key in pairs(items) do
		if type(key) == "number" then
			userIds[#userIds + 1] = key
		end
	end
	table.sort(userIds)
	for _, itemId in ipairs(userIds) do
		AddPart(tostring(itemId), { itemId }, items[itemId])
	end

	lines[#lines + 1] = ""
	local slash = ns.GetAnnouncementState().LongestChannelSlash
	if #parts == 0 then
		lines[#lines + 1] = "Macro: no items loaded to build with."
	else
		local body, kept, fullLength = ns.BuildAnnouncementMacroBody(parts, slash)
		lines[#lines + 1] = string.format(
			"Macro through %q with %d item(s): %d of %d bytes untruncated%s",
			slash,
			#parts,
			fullLength,
			ns.CHAT_MESSAGE_MAX_LENGTH,
			fullLength > ns.CHAT_MESSAGE_MAX_LENGTH and "  OVER" or ""
		)
		if kept < #parts then
			lines[#lines + 1] =
				string.format("  truncated at a part boundary: keeps %d of %d item(s), %d bytes", kept, #parts, #body)
		end
		lines[#lines + 1] = "  body: " .. (body:gsub("|", "||"))
	end
	if #unloaded > 0 then
		table.sort(unloaded)
		lines[#lines + 1] = ""
		lines[#lines + 1] = "Not loaded yet, left out (run Game Names, then this again): "
			.. table.concat(unloaded, ", ")
	end
	return table.concat(lines, "\n")
end
