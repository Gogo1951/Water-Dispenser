local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor

local Header, Desc, Spacer = ns.OptionsHeader, ns.OptionsDesc, ns.OptionsSpacer

--------------------------------------------------------------------------------
-- DB Accessors
--------------------------------------------------------------------------------

-- Lazy-fetched so a profile switch between opens can't leave a stale reference.
local function GetAnnouncements()
	if not ns.db then
		return nil
	end
	ns.db.profile.Announcements = ns.db.profile.Announcements or {}
	return ns.db.profile.Announcements
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
	-- Macro is auto-managed: enabling creates it, disabling deletes it.
	if ns.RefreshAnnouncementMacro then
		ns.RefreshAnnouncementMacro()
	end
end

--------------------------------------------------------------------------------
-- Live Preview
--------------------------------------------------------------------------------

-- Current macro message colored for the preview pane, or a muted "nothing to announce" notice when empty.
local function GetPreviewText()
	if ns.BuildAnnouncementMessage then
		local message = ns.BuildAnnouncementMessage()
		if message then
			return GetColor("TEXT") .. message .. "|r"
		end
	end
	return GetColor("MUTED") .. (L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] or "") .. "|r"
end

--------------------------------------------------------------------------------
-- Options Table
--------------------------------------------------------------------------------

function ns.BuildAnnouncementsOptions()
	return {
		type = "group",
		name = L["ADDON_TITLE"] .. " > " .. L["OPTIONS_ANNOUNCEMENTS"],
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
				set = SetEnabled,
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
				end,
			},
		},
	}
end
