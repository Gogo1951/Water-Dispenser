local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor

--[[
    Messaging deviation (intentional): Water Dispenser never calls
    SendChatMessage. Instead of the Style Guide's ns:Announce /
    ns:BuildAnnounceMessage / ns:GetGroupChatChannel send path, this file keeps a
    player-clicked "- Dispenser" macro up to date; the player presses it to
    broadcast their giveaway list. The add-on initiates no chat by design, so
    those send helpers are intentionally absent; do not add them back.

    ns.PrintMessage stays here: player-only prints are this file's job per the
    guide.
]]

--------------------------------------------------------------------------------
-- Chat Output
--------------------------------------------------------------------------------

-- Prints a branded line to the player's chat: title // message [detail].
function ns.PrintMessage(msg, detail)
    local line =
        GetColor("INFO") .. L["ADDON_TITLE"] .. "|r " .. GetColor("SEPARATOR") .. "//|r " .. GetColor("TEXT") .. tostring(msg) .. "|r"
    if detail then
        line = line .. " " .. GetColor("MUTED") .. tostring(detail) .. "|r"
    end
    print(line)
end

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

-- Per-character macro. Leading "- " sorts it to the top of the macro list;
-- kept under 16 chars because WoW truncates longer names.
local MACRO_NAME = "- Dispenser"

-- Drink icon, matching the addon branding.
local MACRO_ICON = "INV_Drink_18"

-- Blizzard's macro body limit; we truncate before it so updates never fail.
local MACRO_BODY_LIMIT = 255

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

--------------------------------------------------------------------------------
-- Channel Resolution
--------------------------------------------------------------------------------

-- Channel slash for the macro body: /raid in a raid, /p in a party, /s solo.
local function ChannelSlash()
    if IsInRaid() then
        return "/raid "
    end
    if IsInGroup() then
        return "/p "
    end
    return "/s "
end

--------------------------------------------------------------------------------
-- Message Builder
--------------------------------------------------------------------------------

-- Joins a list of strings with comma separators and a localized "and"
-- before the last item: "A", "A and B", "A, B, and C".
local function JoinList(parts)
    local n = #parts
    if n == 0 then
        return ""
    end
    if n == 1 then
        return parts[1]
    end
    local andWord = L["ANNOUNCEMENTS_AND"] or "and"
    if n == 2 then
        return parts[1] .. " " .. andWord .. " " .. parts[2]
    end
    local last = parts[n]
    local head = table.concat(parts, ", ", 1, n - 1)
    return head .. ", " .. andWord .. " " .. last
end

-- Announcement body text (no channel slash), using real item hyperlinks so
-- listeners can hover or shift-click. Returns nil if there's nothing to give.
function ns.BuildAnnouncementMessage()
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
            table.insert(parts, label .. " x " .. entry.Count)
        else
            -- "Include quantity" off: name the item without a count.
            table.insert(parts, label)
        end
    end

    local intro = L["ANNOUNCEMENTS_INTRO"]
    local outro = L["ANNOUNCEMENTS_OUTRO"]

    -- Outro carries its own leading punctuation (". Open trade!") so the join
    -- adds no space before it and translators pick their own sentence-ender.
    -- Marker and brand are assembled here rather than repeated per locale.
    local prefix = ns.TARGET_MARKER .. " " .. L["ADDON_TITLE"] .. " //"
    local list = JoinList(parts)
    return prefix .. " " .. intro .. " " .. list .. outro
end

--------------------------------------------------------------------------------
-- Macro Body
--------------------------------------------------------------------------------

-- Returns the full macro body: channel slash + announcement message.
-- Truncates with an ellipsis if it would exceed the 255-char limit.
local function BuildMacroBody()
    local message = ns.BuildAnnouncementMessage()
    local channel = ChannelSlash()

    if not message then
        -- Empty inventory: silent body so firing the macro does nothing.
        return ""
    end

    local body = channel .. message
    if #body > MACRO_BODY_LIMIT then
        -- Truncate at the last comma that fits so we never slice through a
        -- bracketed item name; hard-cut if there's no comma in range.
        local safe = MACRO_BODY_LIMIT - 4
        local prefix = body:sub(1, safe)
        local lastComma = prefix:match(".*()(,)")
        if lastComma then
            body = prefix:sub(1, lastComma - 1) .. " ..."
        else
            body = prefix .. "..."
        end
    end
    return body
end

--------------------------------------------------------------------------------
-- Macro Slot Management
--------------------------------------------------------------------------------

-- Returns the macro slot index (1-based) or 0 if the macro doesn't exist.
function ns.GetAnnouncementMacroIndex()
    return GetMacroIndexByName(MACRO_NAME) or 0
end

-- True if the per-character "- Dispenser" macro currently exists.
function ns.HasAnnouncementMacro()
    return ns.GetAnnouncementMacroIndex() ~= 0
end

-- Brings the per-character macro in line with ns.DB.Announcements.Enabled:
-- creates on first enable, edits on bag changes, deletes when disabled. Chat
-- output only on create / delete / slots-full; routine refreshes stay silent.
local function SyncMacroState()
    if not ns.DB or not ns.DB.Announcements then
        return
    end

    local enabled = ns.DB.Announcements.Enabled
    local exists = ns.HasAnnouncementMacro()

    if enabled then
        local body = BuildMacroBody()
        if exists then
            local index = ns.GetAnnouncementMacroIndex()
            EditMacro(index, MACRO_NAME, MACRO_ICON, body)
            macroFullWarned = false
        else
            -- 1 = per-character macro slot, so each alt gets its own body.
            local newIndex = CreateMacro(MACRO_NAME, MACRO_ICON, body, 1)
            if not newIndex or newIndex == 0 then
                if not macroFullWarned then
                    macroFullWarned = true
                    ns.PrintMessage(L["CHAT_MACRO_FULL"])
                end
                return
            end
            macroFullWarned = false
            ns.PrintMessage(L["CHAT_MACRO_CREATED"])
        end
    elseif exists then
        local index = ns.GetAnnouncementMacroIndex()
        DeleteMacro(index)
        ns.PrintMessage(L["CHAT_MACRO_DELETED"])
    end
end

--------------------------------------------------------------------------------
-- Auto-Update Plumbing
--------------------------------------------------------------------------------

-- Schedules a debounced sync. Multiple triggers inside the debounce window
-- collapse to a single SyncMacroState call.
local function ScheduleUpdate()
    if updateTimer then
        return
    end
    if not C_Timer or not C_Timer.NewTimer then
        -- Fallback for ancient clients: sync immediately.
        if ns.IsInCombat() then
            pendingCombatUpdate = true
        else
            SyncMacroState()
        end
        return
    end

    updateTimer =
        C_Timer.NewTimer(
        UPDATE_DEBOUNCE,
        function()
            updateTimer = nil
            if ns.IsInCombat() then
                pendingCombatUpdate = true
                return
            end
            SyncMacroState()
        end
    )
end

-- Public so the options panel can refresh the macro after a settings change.
ns.RefreshAnnouncementMacro = ScheduleUpdate

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function ns.InitAnnouncements()
    -- Bag changes. BAG_UPDATE_DELAYED fires once after a batch settles.
    ns.RegisterEvent(
        "BAG_UPDATE_DELAYED",
        function()
            ScheduleUpdate()
        end
    )

    -- Group state change: the channel slash prefix may need rewriting.
    ns.RegisterEvent(
        "GROUP_ROSTER_UPDATE",
        function()
            ScheduleUpdate()
        end
    )

    -- Initial sync once in the world, when item names are cached.
    ns.RegisterEvent(
        "PLAYER_ENTERING_WORLD",
        function()
            ScheduleUpdate()
        end
    )

    -- Combat-end retry for any update deferred during combat.
    ns.RegisterEvent(
        "PLAYER_REGEN_ENABLED",
        function()
            if pendingCombatUpdate then
                pendingCombatUpdate = false
                ScheduleUpdate()
            end
        end
    )
end