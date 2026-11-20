local _, ns = ...

local L = ns.L
local Kit = ns.MenuKit

--------------------------------------------------------------------------------
-- Text
--------------------------------------------------------------------------------

Kit.SetText({
	on = L["MENU_ON"],
	off = L["MENU_OFF"],
	toggle = L["MENU_TOGGLE"],
	more = L["MENU_MORE"],
	moreFeatures = L["MENU_MORE_FEATURES"],
	featuresOn = L["MENU_FEATURE_COUNT_ON"],
	featuresOff = L["MENU_FEATURE_COUNT_OFF"],
	loading = L["ITEM_LOADING"],
	shortName = L["ADDON_SHORT_NAME"],
	clicks = {
		LeftButton = L["MENU_CLICK_LEFT"],
		ShiftMiddleButton = L["MENU_CLICK_SHIFT_MIDDLE"],
	},
})

--------------------------------------------------------------------------------
-- Dispense
--------------------------------------------------------------------------------

local function FeatureBySetting(setting)
	for _, feature in ipairs(ns.FEATURES or {}) do
		if feature.setting == setting then
			return feature
		end
	end
end

local function FlipDispense()
	ns.SetDispense(not ns.db.profile.Dispense)
end

--[[
	The master switch's block: its state, what it does, and the Toggle row, which
	names the button's Left-Click because that click flips it too.
]]
local function AddDispense(entries)
	local feature = FeatureBySetting("Dispense")
	local state, stateColor = Kit.OnOff(ns.db.profile.Dispense)
	Kit.FeatureBlock(entries, {
		title = L[feature.name],
		state = state,
		stateColor = stateColor,
		description = L["OPTIONS_DISPENSE_MASTER_DESC"],
		toggle = {
			name = L[feature.caption],
			desc = L[feature.desc],
			flip = FlipDispense,
			click = feature.click,
		},
	})
end

--------------------------------------------------------------------------------
-- Dispense Report
--------------------------------------------------------------------------------

--[[
	What the player is carrying to give: the same entries as the announcement
	macro, counted without the reserve, so a mage holding less water than they
	keep still sees it listed. The count shows only on an item set to include it.
	Left out while Dispense is off or nothing is carried, which the snapshot
	already returns as empty.
]]
local function AddDispenseReport(entries)
	local carried = ns.BuildAnnouncementSnapshot(true)
	if #carried == 0 then
		return
	end
	local rows = {}
	for _, entry in ipairs(carried) do
		local link = type(entry.Link) == "string" and entry.Link:find("item:", 1, true) and entry.Link or nil
		rows[#rows + 1] = {
			kind = "item",
			link = link,
			left = not link and (entry.Name or "?") or nil,
			right = entry.IncludeQuantity and tostring(entry.Count) or nil,
		}
	end
	entries[#entries + 1] = { kind = "status", left = L["MINIMAP_DISPENSE_REPORT"] }
	Kit.List(entries, rows, Kit.LIST_MAX)
end

--------------------------------------------------------------------------------
-- Menu
--------------------------------------------------------------------------------

local function BuildMainEntries()
	local entries = {
		{ kind = "header", left = L["ADDON_TITLE"], right = ns.Version },
	}
	AddDispense(entries)
	AddDispenseReport(entries)
	Kit.MoreFeatures(entries)
	Kit.OptionsRow(entries, L["MENU_OPTIONS"])
	return entries
end

ns.Menu = Kit.CreateMenu({
	name = ns.LOCALE_NAME .. "Menu",
	build = BuildMainEntries,
	afterChange = ns.RefreshSettings,
})
