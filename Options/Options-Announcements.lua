local _, ns = ...

local L = ns.L
local COLORS = ns.COLORS

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local Header, Desc, Spacer = ns.OptionsHelpers.Header, ns.OptionsHelpers.Desc, ns.OptionsHelpers.Spacer

--------------------------------------------------------------------------------
-- DB Accessors
--------------------------------------------------------------------------------

-- Lazy-fetched so we don't capture a stale ns.DB reference if the user
-- ResetToDefaults() between option-panel opens.
local function GetAnnouncements()
    if not ns.DB then
        return nil
    end
    ns.DB.Announcements = ns.DB.Announcements or {}
    return ns.DB.Announcements
end

local function GetEnabled()
    local a = GetAnnouncements()
    return a and a.Enabled and true or false
end

local function SetEnabled(_, value)
    local a = GetAnnouncements()
    if not a then
        return
    end
    a.Enabled = value and true or false
    -- The macro is auto-managed: enabling creates and starts auto-updating
    -- it; disabling deletes it. SyncMacroState (via ScheduleUpdate) handles
    -- the actual transition.
    if ns.RefreshAnnouncementMacro then
        ns.RefreshAnnouncementMacro()
    end
end

--------------------------------------------------------------------------------
-- Live Preview
--------------------------------------------------------------------------------

-- Returns the current macro body as a single colored string for the
-- preview pane. Falls back to the "nothing to announce" notice (in muted
-- color) when there is nothing to say.
local function GetPreviewText()
    if ns.BuildAnnouncementMessage then
        local message = ns.BuildAnnouncementMessage()
        if message then
            return COLORS.TEXT .. message .. "|r"
        end
    end
    return COLORS.MUTED .. (L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] or "") .. "|r"
end

--------------------------------------------------------------------------------
-- Options Table
--------------------------------------------------------------------------------

local function BuildAnnouncementsOptions()
    return {
        type = "group",
        name = L["OPTIONS_TITLE"] .. " > " .. L["OPTIONS_ANNOUNCEMENTS"],
        args = {
            -- Intro
            intro = Desc(L["OPTIONS_ANNOUNCEMENTS_DESC"], 1),
            spaceIntro = Spacer(2),
            -- Enable toggle
            enable = {
                type = "toggle",
                width = "full",
                name = L["OPTIONS_ANNOUNCEMENTS_ENABLE"],
                desc = L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"],
                order = 3,
                get = GetEnabled,
                set = SetEnabled
            },
            -- Live Preview
            spacePreview0 = Spacer(20),
            headerPreview = Header(L["OPTIONS_ANNOUNCEMENTS_PREVIEW_HEADER"], 21),
            spacePreview1 = Spacer(22),
            descPreview = Desc(L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DESC"], 23),
            spacePreview2 = Spacer(24),
            previewBody = {
                type = "description",
                fontSize = "medium",
                order = 25,
                name = function()
                    return GetPreviewText()
                end
            }
        }
    }
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function ns.InitOptionsAnnouncements(appName, parentDisplayName)
    AceConfig:RegisterOptionsTable(appName, BuildAnnouncementsOptions())
    AceConfigDialog:AddToBlizOptions(appName, L["OPTIONS_ANNOUNCEMENTS"], parentDisplayName)
end
