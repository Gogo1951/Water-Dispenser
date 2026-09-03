local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor

local Header, Desc, Spacer = ns.OptionsHeader, ns.OptionsDesc, ns.OptionsSpacer
local SubRow, SubToggle = ns.OptionsSubRow, ns.OptionsSubToggle
local GetDB, SetDB = ns.OptionsGetDB, ns.OptionsSetDB

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

-- Current macro message colored for the preview pane, or a muted "nothing to announce" notice when empty.
local function GetPreviewText()
	if ns.BuildAnnouncementMessage then
		local message = ns.BuildAnnouncementMessage()
		if message then
			return GetColor("TEXT") .. message .. "|r"
		end
	end
	return GetColor("MUTED") .. L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] .. "|r"
end

--------------------------------------------------------------------------------
-- Tooltip Sharing
--------------------------------------------------------------------------------

-- Sharing is only a question once the tooltips themselves are switched on.
local function TooltipsOff()
	return not (ns.db and ns.db.profile.ShowInventoryTooltips)
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
			-- The macro's current body, unlabeled: it is plainly the macro, and the
			-- section text above already says what it is.
			spacePreview0 = Spacer(20),
			previewBody = {
				type = "description",
				fontSize = "medium",
				order = 21,
				name = function()
					return GetPreviewText()
				end,
			},
			-- Inventory in Player Tooltips
			spaceTooltips0 = Spacer(30),
			headerTooltips = Header(L["OPTIONS_TOOLTIPS_HEADER"], 31),
			spaceTooltips1 = Spacer(32),
			descTooltips = Desc(L["OPTIONS_TOOLTIPS_DESC"], 33),
			spaceTooltips2 = Spacer(34),
			ShowInventoryTooltips = {
				type = "toggle",
				width = "full",
				name = L["OPTIONS_SHOW_INVENTORY"],
				desc = L["OPTIONS_SHOW_INVENTORY_DESC"],
				order = 35,
				get = GetDB,
				set = function(info, value)
					SetDB(info, value)
					-- This gates sharing too, so the group needs telling either way.
					ns.RefreshGiveaways()
				end,
			},
			rowShareInventory = SubRow(36, TooltipsOff, {
				SubToggle("ShareInventory", L["OPTIONS_SHARE_INVENTORY"], L["OPTIONS_SHARE_INVENTORY_DESC"], function()
					ns.RefreshGiveaways()
				end),
			}),
		},
	}
end
