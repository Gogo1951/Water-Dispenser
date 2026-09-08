local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor

local Desc, Spacer = ns.OptionsDesc, ns.OptionsSpacer

--------------------------------------------------------------------------------
-- DB Accessors
--------------------------------------------------------------------------------

-- Lazy-fetched so a profile switch between opens can't leave a stale reference.
local function GetAnnouncements()
	if not ns.db then
		return nil
	end
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
	ns.RefreshGiveaways()
end

--------------------------------------------------------------------------------
-- Live Preview
--------------------------------------------------------------------------------

-- Current macro message colored for the preview pane, or a muted notice naming why there is nothing to announce.
local function GetPreviewText()
	--[[
		Dispense off is its own notice: the generic empty one tells the player to
		restock bags that are fine, when the cause is one toggle on another panel.
	]]
	if not (ns.db and ns.db.profile.Dispense) then
		return GetColor("MUTED") .. L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DISPENSE_OFF"] .. "|r"
	end
	if ns.BuildAnnouncementMessage then
		local message = ns.BuildAnnouncementMessage()
		if message then
			return GetColor("TEXT") .. message .. "|r"
		end
	end
	return GetColor("MUTED") .. L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] .. "|r"
end

--------------------------------------------------------------------------------
-- Options Table
--------------------------------------------------------------------------------

function ns.BuildAnnouncementsOptions()
	return {
		type = "group",
		name = L["TAB_ANNOUNCEMENTS"],
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
			--[[
				The announcement as it will read, unlabeled: it is plainly the macro, and
				the section text above already says what it is. Built without the channel
				prefix and before any truncation, so a long list previews in full.
			]]
			spacePreview0 = Spacer(20),
			previewBody = {
				type = "description",
				fontSize = "medium",
				order = 21,
				name = function()
					return GetPreviewText()
				end,
			},
		},
	}
end
