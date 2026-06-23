local addonName, ns = ...

local L = ns.L

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

-- Shared runtime state, read and written across modules.
ns.State = {
    Trade = {
        Active = false,
        Class = nil,
        Level = nil,
        Party = false
    },
    MissingStack = false
}

--------------------------------------------------------------------------------
-- Version
--------------------------------------------------------------------------------

local function GetVersion()
    local getMeta = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
    local version = getMeta and getMeta(addonName, "Version")
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

-- Every event passed to RegisterEvent, deduped in first-seen order. The
-- Diagnostics registration probe reads this so its list can't drift.
ns.EVENT_NAMES = {}
local seenEvents = {}

function ns.RegisterEvent(event, handler)
    if not seenEvents[event] then
        seenEvents[event] = true
        ns.EVENT_NAMES[#ns.EVENT_NAMES + 1] = event
    end
    if not eventHandlers[event] then
        -- pcall guards events that aren't valid on every client/version:
        -- RegisterEvent errors on an unknown event name, so skip it cleanly.
        local ok = pcall(eventFrame.RegisterEvent, eventFrame, event)
        if not ok then
            return
        end
        eventHandlers[event] = {}
    end
    table.insert(eventHandlers[event], handler)
end

eventFrame:SetScript(
    "OnEvent",
    function(_, event, ...)
        -- Diagnostics tap. Gated on the boolean first so the dispatcher does
        -- no work while logging is off (the default).
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
    end
)

--------------------------------------------------------------------------------
-- Addon Lifecycle
--------------------------------------------------------------------------------

-- PLAYER_LOGIN is the safe init point: saved variables are loaded and caches
-- are warm enough for a first-pass scan.
ns.RegisterEvent(
    "PLAYER_LOGIN",
    function()
        ns.InitDB()
        if ns.InitDispenser then
            ns.InitDispenser()
        end
        if ns.InitOptions then
            ns.InitOptions()
        end
        if ns.InitAnnouncements then
            ns.InitAnnouncements()
        end
        if ns.InitMinimap then
            ns.InitMinimap()
        end
        if WaterDispenserDB.WelcomeMessage then
            ns.PrintMessage(format(L["CHAT_LOADED"], ns.Version))
        end
    end
)