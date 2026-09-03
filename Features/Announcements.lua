local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor

--[[
	Water Dispenser never calls SendChatMessage: the player fires the "- Dispenser"
	macro, so this file has no send path, only ns.PrintMessage.
]]

--------------------------------------------------------------------------------
-- Chat Output
--------------------------------------------------------------------------------

--[[
	The add-on's one branded line: |cff[INFO]Add-on Name|r |cff[SEPARATOR]//|r
	|cff[TEXT]Message|r. Features/Group-Spares.lua heads its tooltip block with the
	same line, so the two can never brand the add-on differently, and a locale body
	stays the body alone.
]]
function ns.BuildBrandedLine(message)
	return GetColor("INFO")
		.. L["ADDON_TITLE"]
		.. "|r "
		.. GetColor("SEPARATOR")
		.. "//"
		.. "|r "
		.. GetColor("TEXT")
		.. tostring(message)
		.. "|r"
end

-- Prints a branded line to the player's chat frame: title // message [detail].
function ns.PrintMessage(message, detail)
	local line = ns.BuildBrandedLine(message)
	if detail then
		line = line .. " " .. GetColor("MUTED") .. tostring(detail) .. "|r"
	end
	print(line)
end

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

-- Leading "- " sorts it to the top of the macro list; under 16 chars because WoW truncates longer names.
local MACRO_NAME = "- Dispenser"

-- Drink icon, matching the add-on branding.
local MACRO_ICON = "INV_Drink_18"

-- Blizzard's macro body limit; we truncate before it so updates never fail.
local MACRO_BODY_LIMIT = ns.CHAT_MESSAGE_MAX_LENGTH

-- Debounce window: coalesces bursts of BAG_UPDATE_DELAYED into one update.
local UPDATE_DEBOUNCE = 0.25

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

-- A macro update was deferred by combat; replayed on PLAYER_REGEN_ENABLED.
local pendingCombatUpdate = false

-- Active debounce timer handle, if any.
local updateTimer

-- Latches the "macro slots full" warning to once until a slot frees up.
local macroFullWarned = false

-- Body last written to the macro. Bags settle far more often than the giveaway
-- list actually changes, so an unchanged body skips the write entirely.
local lastMacroBody = nil

--------------------------------------------------------------------------------
-- Channel Resolution
--------------------------------------------------------------------------------

--[[
	The add-on's one group-channel resolver, shared with Features/Group-Spares.lua so
	a chat body and an addon message can never disagree about where the player is.
	Instance chat comes first: a battleground raid is an instance group, and RAID
	there routes to a home raid the player is not in.
]]
function ns.GetGroupChatChannel()
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		return "INSTANCE_CHAT"
	end
	if IsInRaid() then
		return "RAID"
	end
	if IsInGroup() then
		return "PARTY"
	end
	return nil
end

-- The macro body's leading channel slash; ungrouped falls through to /s.
local CHANNEL_SLASH = {
	INSTANCE_CHAT = "/i ",
	RAID = "/raid ",
	PARTY = "/p ",
}

local function ChannelSlash()
	return CHANNEL_SLASH[ns.GetGroupChatChannel()] or "/s "
end

--------------------------------------------------------------------------------
-- Message Builder
--------------------------------------------------------------------------------

-- Joins parts with commas and a localized "and" before the last: "A", "A and B", "A, B, and C".
local function JoinList(parts)
	local n = #parts
	if n == 0 then
		return ""
	end
	if n == 1 then
		return parts[1]
	end
	local andWord = L["ANNOUNCEMENTS_AND"]
	if n == 2 then
		return parts[1] .. " " .. andWord .. " " .. parts[2]
	end
	local last = parts[n]
	local head = table.concat(parts, ", ", 1, n - 1)
	return head .. ", " .. andWord .. " " .. last
end

-- Decorated item parts (hyperlink + optional count) for the current snapshot, one per giveable item; nil if nothing to give.
local function BuildAnnouncementParts()
	if not ns.BuildAnnouncementSnapshot then
		return nil
	end

	local entries = ns.BuildAnnouncementSnapshot()
	if not entries or #entries == 0 then
		return nil
	end

	local parts = {}
	for _, entry in ipairs(entries) do
		local label = entry.Link or ("[" .. (entry.Name or "?") .. "]")
		if entry.IncludeQuantity then
			parts[#parts + 1] = label .. " x " .. entry.Count
		else
			-- "Include quantity" off: name the item without a count.
			parts[#parts + 1] = label
		end
	end
	return parts
end

-- Shared lead for the full message and macro body: "{marker} {title} // " (assembled here, not per locale).
local function AnnouncementPrefix()
	return ns.TARGET_MARKER .. " " .. L["ADDON_TITLE"] .. " // "
end

--[[
	Splits the localized body template around its %s into the text before the item
	list and the text after it. Kept as two pieces rather than one string.format so
	the macro builder can lay the lead down once and truncate at part boundaries.
	A template without %s degrades to lead-only, never an error.
]]
local function BodyTemplateParts()
	local template = L["ANNOUNCEMENTS_BODY"]
	local head, tail = template:match("^(.-)%%s(.*)$")
	if not head then
		return template, ""
	end
	return head, tail
end

--[[
	Full announcement body (no channel slash, no truncation) for the live preview:
	prefix, then the template wrapped around the list joined with a localized "and".
	Nil if nothing to give.
]]
function ns.BuildAnnouncementMessage()
	local parts = BuildAnnouncementParts()
	if not parts then
		return nil
	end
	local head, tail = BodyTemplateParts()
	return AnnouncementPrefix() .. head .. JoinList(parts) .. tail
end

--------------------------------------------------------------------------------
-- Macro Body
--------------------------------------------------------------------------------

-- Byte reserve for the truncation suffix, so a trimmed body still fits the limit.
local TRUNCATION_SUFFIX = " ..."

--[[
	Full macro body: channel slash + announcement message. When the full message
	fits the 255-byte SendChatMessage limit it is sent as-is; otherwise it is
	rebuilt from the parts list -- lead laid down once, whole item parts appended
	with ", " joiners while the running byte total stays within the limit minus the
	" ..." reserve -- and closed with " ...", dropping the template's trailing text.
	Truncation happens only at part boundaries: never inside an item link
	(SendChatMessage rejects a broken link), and never via a comma search, since
	item names can contain commas.
]]
local function BuildMacroBody()
	local parts = BuildAnnouncementParts()
	if not parts then
		-- Empty inventory: silent body so firing the macro does nothing.
		return ""
	end

	local channel = ChannelSlash()
	local head, tail = BodyTemplateParts()
	local lead = channel .. AnnouncementPrefix() .. head
	local full = lead .. JoinList(parts) .. tail
	if #full <= MACRO_BODY_LIMIT then
		return full
	end

	local budget = MACRO_BODY_LIMIT - #TRUNCATION_SUFFIX
	local body = lead
	local appended = 0
	for _, part in ipairs(parts) do
		local piece = (appended == 0) and part or (", " .. part)
		if #body + #piece > budget then
			break
		end
		body = body .. piece
		appended = appended + 1
	end
	return body .. TRUNCATION_SUFFIX
end

--------------------------------------------------------------------------------
-- Macro Slot Management
--------------------------------------------------------------------------------

-- Returns the macro slot index (1-based) or 0 if the macro doesn't exist.
local function GetAnnouncementMacroIndex()
	return GetMacroIndexByName(MACRO_NAME) or 0
end

-- True if the per-character "- Dispenser" macro currently exists.
local function HasAnnouncementMacro()
	return GetAnnouncementMacroIndex() ~= 0
end

--[[
	Reconciles the per-character macro to ns.db.profile.Announcements.Enabled:
	create on first enable, edit on bag changes, delete when disabled. Chat output
	only on delete and slots-full; creation and routine refreshes stay silent.
]]
local function SyncMacroState()
	if not ns.db or not ns.db.profile.Announcements then
		return
	end

	local enabled = ns.db.profile.Announcements.Enabled
	local exists = HasAnnouncementMacro()

	if enabled then
		local body = BuildMacroBody()
		if exists then
			if body ~= lastMacroBody then
				EditMacro(GetAnnouncementMacroIndex(), MACRO_NAME, MACRO_ICON, body)
				lastMacroBody = body
			end
			macroFullWarned = false
		else
			-- 1 = per-character macro slot, so each alt gets its own body.
			local newIndex = CreateMacro(MACRO_NAME, MACRO_ICON, body, 1)
			if not newIndex or newIndex == 0 then
				lastMacroBody = nil
				if not macroFullWarned then
					macroFullWarned = true
					ns.PrintMessage(L["CHAT_MACRO_FULL"])
				end
				return
			end
			lastMacroBody = body
			macroFullWarned = false
		end
	elseif exists then
		DeleteMacro(GetAnnouncementMacroIndex())
		lastMacroBody = nil
		ns.PrintMessage(L["CHAT_MACRO_DELETED"])
	end
end

--------------------------------------------------------------------------------
-- Auto-Update Plumbing
--------------------------------------------------------------------------------

-- Debounced sync; triggers inside the window collapse to a single SyncMacroState call.
local function ScheduleUpdate()
	if updateTimer then
		return
	end
	updateTimer = C_Timer.NewTimer(UPDATE_DEBOUNCE, function()
		updateTimer = nil
		if ns.IsInCombat() then
			pendingCombatUpdate = true
			return
		end
		SyncMacroState()
	end)
end

-- Public so the options panel can refresh the macro after a settings change.
ns.RefreshAnnouncementMacro = ScheduleUpdate

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function ns.InitAnnouncements()
	-- Bag changes. BAG_UPDATE_DELAYED fires once after a batch settles.
	ns.RegisterEvent("BAG_UPDATE_DELAYED", function()
		ScheduleUpdate()
	end)

	-- Group state change: the channel slash prefix may need rewriting.
	ns.RegisterEvent("GROUP_ROSTER_UPDATE", function()
		ScheduleUpdate()
	end)

	-- Initial sync once in the world, when item names are cached.
	ns.RegisterEvent("PLAYER_ENTERING_WORLD", function()
		ScheduleUpdate()
	end)

	-- Combat-end retry for any update deferred during combat.
	ns.RegisterEvent("PLAYER_REGEN_ENABLED", function()
		if pendingCombatUpdate then
			pendingCombatUpdate = false
			ScheduleUpdate()
		end
	end)
end
