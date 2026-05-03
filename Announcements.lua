local _, ns = ...

local L = ns.L

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

-- Macro name. Per-character so each alt has a body sized to its own bags.
-- Kept as a constant rather than localized so /macro searches are stable.
-- Leading "- " sorts the macro to the top of the alphabetical macro list,
-- making it quick to find when dragging onto an action bar. Kept short
-- because WoW's macro UI silently truncates names past 16 characters.
local MACRO_NAME = "- Dispenser"

-- Texture name resolved by Blizzard's icon DB. Drink icon to match the
-- addon's water-pitcher branding.
local MACRO_ICON = "INV_Drink_18"

-- Macro body hard limit imposed by Blizzard. We truncate before this so the
-- update never silently fails.
local MACRO_BODY_LIMIT = 255

-- Debounce window for auto-update triggers. BAG_UPDATE_DELAYED can still
-- fire several times in a row when many slot changes happen at once
-- (looting a chest, mass mailbox pickup), so we coalesce.
local UPDATE_DEBOUNCE = 0.25

-- Fixed chrome that wraps every announcement: the {rt6} raid target marker,
-- the addon name, and the // separator. Kept out of the locale strings so
-- translators only have to handle the actual sentence ("I have ..." /
-- "Open trade!") without re-embedding the marker, branding, or punctuation
-- — and so adjusting any of those three doesn't churn every locale file.
local MESSAGE_PREFIX = "{rt6} Water Dispenser //"

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

-- Set true if a macro update was deferred due to combat. The combat-end
-- event handler picks this up and runs the update once it's safe.
local pendingCombatUpdate = false

-- Outstanding C_Timer.NewTimer handle for the debounce window.
local updateTimer

-- Latched so we don't spam the "macro slots full" warning on every bag
-- update while the player still hasn't freed a slot.
local macroFullWarned = false

--------------------------------------------------------------------------------
-- Channel Resolution
--------------------------------------------------------------------------------

-- Channel slash for the literal macro body. The macro body itself does the
-- routing — when you click it WoW sends the message to whichever chat
-- channel matches the slash. The addon rewrites this when group state
-- changes.
local function ChannelSlash()
    if IsInRaid() then
        return "/raid "
    end
    if IsInGroup() then
        return "/p "
    end
    return "/s "
end

-- SendChatMessage channel token, used when /wda is invoked outside of the
-- macro. SAY/PARTY/RAID matches the slash mapping above.
local function ChannelToken()
    if IsInRaid() then
        return "RAID"
    end
    if IsInGroup() then
        return "PARTY"
    end
    return "SAY"
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

-- Returns the announcement body text (no channel slash). Real item
-- hyperlinks are used so listeners can shift-click or hover for the full
-- tooltip; the smart-comma truncation in BuildMacroBody keeps the result
-- inside the 255-char macro budget by dropping later items.
--
-- Returns nil if the player has nothing left to give out.
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
            -- Per-item "Include quantity remaining" toggle is off — just
            -- name the item. Listeners care that you have one to spare,
            -- not the exact count. This is the default for healthstones
            -- but any item can be set this way.
            table.insert(parts, label)
        end
    end

    local intro = L["ANNOUNCEMENTS_INTRO"]
    local outro = L["ANNOUNCEMENTS_OUTRO"]

    -- Outro carries its own leading punctuation (". Open trade!" in enUS) so
    -- the join doesn't insert a space between the last item and the period.
    -- This also lets translators choose the right sentence-ender for their
    -- locale (period, full stop, ideographic stop, etc.).
    local list = JoinList(parts)
    return MESSAGE_PREFIX .. " " .. intro .. " " .. list .. outro
end

--------------------------------------------------------------------------------
-- /wda — Send Announcement Now
--------------------------------------------------------------------------------

-- Hooked from Core.lua's /wda slash command. Sends the announcement to the
-- right channel without going through the macro at all. This path is
-- useful for users who want to bind the announcement to a button outside
-- the standard macro UI.
function ns.Announce()
    local message = ns.BuildAnnouncementMessage()
    if not message then
        ns.PrintMessage(L["CHAT_NOTHING_TO_ANNOUNCE"])
        return
    end
    SendChatMessage(message, ChannelToken())
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
        -- Empty inventory placeholder. Keeps the macro present and clickable
        -- but visually informs the player that there's nothing to announce
        -- yet — no garbled output if they fire it accidentally.
        return channel .. MESSAGE_PREFIX .. " " .. (L["CHAT_NOTHING_TO_ANNOUNCE"] or "")
    end

    local body = channel .. message
    if #body > MACRO_BODY_LIMIT then
        -- Truncate at the last comma that fits so we don't slice through a
        -- bracketed item name and produce orphaned brackets like
        -- "[Crystal Wa...". Falls back to a hard cut if there's no comma in
        -- the safe range.
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

-- Public for the Options preview pane.
ns.BuildMacroBody = BuildMacroBody

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

-- Internal: brings the per-character macro into the state requested by
-- ns.DB.Announcements.Enabled. Creates it on first enable, edits it on
-- subsequent bag changes, deletes it when disabled. Combat-deferred via
-- ScheduleUpdate so this only runs when SetAttribute is safe.
--
-- Chat output rules:
--   * CHAT_MACRO_CREATED on first create (per session)
--   * CHAT_MACRO_DELETED on auto-delete (e.g. user toggled off)
--   * CHAT_MACRO_FULL once per "slots full" run; suppressed on retries
--   * Silent on routine bag-change refreshes
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
            -- 1 = per-character macro slot. Per-char so each alt has a
            -- body that matches that alt's bags and class.
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

-- Public so Options-Announcements.lua can poke a refresh after the user
-- edits the prefix / intro / outro fields.
ns.RefreshAnnouncementMacro = ScheduleUpdate

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function ns.InitAnnouncements()
    -- Bag changes — pickup, drop, conjure, vendor, mail. BAG_UPDATE_DELAYED
    -- is preferred over BAG_UPDATE because it fires once after a batch of
    -- slot changes settles instead of per-slot.
    ns.RegisterEvent(
        "BAG_UPDATE_DELAYED",
        function()
            ScheduleUpdate()
        end
    )

    -- Group state changes — switching from solo to party to raid changes
    -- the channel slash prefix, so we must rewrite the macro body.
    ns.RegisterEvent(
        "GROUP_ROSTER_UPDATE",
        function()
            ScheduleUpdate()
        end
    )

    -- Initial sync once the player is fully in the world. Item names are
    -- not always cached yet at ADDON_LOADED; PEW gives GetItemInfo time to
    -- warm up.
    ns.RegisterEvent(
        "PLAYER_ENTERING_WORLD",
        function()
            ScheduleUpdate()
        end
    )

    -- Combat-end retry: replay any update we deferred during combat. The
    -- macro APIs aren't strictly protected, but combat is a noisy time to
    -- be touching the macro UI and we'd rather not race with anything.
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