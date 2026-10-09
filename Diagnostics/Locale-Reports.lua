local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader
local CountKeys = ns.CountDiagnosticKeys

--------------------------------------------------------------------------------
-- Locale Context
--------------------------------------------------------------------------------

function ns:BuildLocaleContextReport()
	local lines = { GetClientHeader(), "" }
	lines[#lines + 1] = "Game locale: " .. tostring(GetLocale())
	lines[#lines + 1] = "textLocale CVar: " .. tostring(GetCVar("textLocale"))
	lines[#lines + 1] = "audioLocale CVar: " .. tostring(GetCVar("audioLocale"))
	lines[#lines + 1] = "Strings the add-on defines: " .. CountKeys(ns.L)
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Game Names
--------------------------------------------------------------------------------

--[[
	One row per name lookup in ns.DIAGNOSTIC_NAME_LOOKUPS, plus the player's own
	Dispensed Items, each printed with the name this client gives it. An item
	can answer nil until the client loads it, so unloaded items are requested
	and polled, asked again every few idle polls, and after a bounded run of
	polls with no progress they settle as NIL rather than holding the report
	open. Run on a non-English client, this checks every name the add-on shows
	in that language at once.
]]
local NAMES_POLL_SECONDS = 0.5
local NAMES_REASK_POLLS = 3
local NAMES_MAX_IDLE_POLLS = 12

local STATUS_OK = "OK"
local STATUS_NIL = "NIL"
local STATUS_FALLBACK = "FALLBACK"
local STATUS_ERROR = "ERROR"

local namesGeneration = 0

local function NameRows()
	local rows = {}
	for _, lookup in ipairs(ns.DIAGNOSTIC_NAME_LOOKUPS or {}) do
		rows[#rows + 1] = { constant = lookup.constant, kind = lookup.kind, id = lookup.id, lookup = lookup.lookup }
	end
	local items = ns.db and ns.db.profile.Items or {}
	local userIds = {}
	for key in pairs(items) do
		if type(key) == "number" then
			userIds[#userIds + 1] = key
		end
	end
	table.sort(userIds)
	for _, itemId in ipairs(userIds) do
		rows[#rows + 1] = {
			constant = "Items (Dispensed Items)",
			kind = "item",
			id = itemId,
			lookup = function(id)
				if not C_Item.GetItemInfo(id) then
					return nil
				end
				return ns.GetItemConfigName(id)
			end,
		}
	end
	return rows
end

-- The row's name, or nil and the message when the lookup throws.
local function ReadName(row)
	local ok, name = pcall(row.lookup, row.id)
	if not ok then
		return nil, tostring(name)
	end
	if type(name) ~= "string" or name == "" then
		return nil, nil
	end
	return name, nil
end

local function RequestRow(row)
	if row.kind == "item" then
		pcall(C_Item.RequestLoadItemDataByID, row.id)
	end
end

local function FinishNames(rows, onFinish)
	local lines = { GetClientHeader(), "", table.concat({ "STATUS", "CONSTANT", "KIND", "ID", "NAME" }, "\t") }
	local counts = {}
	for _, row in ipairs(rows) do
		local name, problem = ReadName(row)
		local status = STATUS_OK
		if problem then
			status, name = STATUS_ERROR, problem
		elseif not name then
			status = STATUS_NIL
		elseif row.kind == "class" and name == row.id then
			status = STATUS_FALLBACK
		end
		counts[status] = (counts[status] or 0) + 1
		lines[#lines + 1] = table.concat({
			status,
			row.constant,
			row.kind,
			tostring(row.id),
			((tostring(name or "")):gsub("[\t\r\n]", " "):gsub("|", "||")),
		}, "\t")
	end
	local note = {}
	for _, status in ipairs({ STATUS_OK, STATUS_NIL, STATUS_FALLBACK, STATUS_ERROR }) do
		if counts[status] then
			note[#note + 1] = counts[status] .. " " .. status
		end
	end
	onFinish(table.concat(lines, "\n"), table.concat(note, ", "))
end

--[[
	onFinish(text, note) receives the finished report. A run that is stopped or
	replaced never calls it: every poll checks the generation it started under.
]]
function ns:StartGameNamesReport(onFinish)
	namesGeneration = namesGeneration + 1
	local generation = namesGeneration
	local rows = NameRows()
	for _, row in ipairs(rows) do
		if not ReadName(row) then
			RequestRow(row)
		end
	end

	local idlePolls, lastWaiting = 0, nil
	local function Poll()
		if generation ~= namesGeneration then
			return
		end
		local waiting = {}
		for _, row in ipairs(rows) do
			local name, problem = ReadName(row)
			if row.kind == "item" and not name and not problem then
				waiting[#waiting + 1] = row
			end
		end
		if #waiting == 0 or idlePolls >= NAMES_MAX_IDLE_POLLS then
			FinishNames(rows, onFinish)
			return
		end
		idlePolls = (lastWaiting and #waiting >= lastWaiting) and idlePolls + 1 or 0
		lastWaiting = #waiting
		if idlePolls > 0 and idlePolls % NAMES_REASK_POLLS == 0 then
			for _, row in ipairs(waiting) do
				RequestRow(row)
			end
		end
		C_Timer.After(NAMES_POLL_SECONDS, Poll)
	end
	C_Timer.After(0, Poll)
end

function ns:StopGameNamesReport()
	namesGeneration = namesGeneration + 1
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
