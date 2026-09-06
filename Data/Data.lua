local ADDON_NAME, ns = ...

ns.LOCALE_NAME = "WaterDispenser"
ns.L = LibStub("AceLocale-3.0"):GetLocale(ns.LOCALE_NAME)

--------------------------------------------------------------------------------
-- AceConfig Registry Names
--------------------------------------------------------------------------------

-- Registry IDs derived from the add-on name so they never drift.
ns.OPTIONS_REGISTRY = {
	General = ADDON_NAME,
	Dispenser = ADDON_NAME .. "_Dispenser",
	DispensedItems = ADDON_NAME .. "_DispensedItems",
	Announcements = ADDON_NAME .. "_Announcements",
	GroupSpares = ADDON_NAME .. "_GroupSpares",
	Profiles = ADDON_NAME .. "_Profiles",
	Diagnostics = ADDON_NAME .. "_Diagnostics",
}

--------------------------------------------------------------------------------
-- Options Layout Grid
--------------------------------------------------------------------------------

--[[
	A label plus its control always total OPTIONS_ROW_WIDTH, so every row ends
	where every other row ends, and that total has to stay inside the panel: a pair
	that overflows does not clip, it wraps the control onto its own line and
	strands the label above it.

	3.4 is the shared grid across the add-ons. At the old 2.6 the Feedback &
	Support rows could not show a full address, the CurseForge link truncating
	mid-slug, because the URL box only ever gets the row less the short service
	label beside it.
]]
ns.OPTIONS_ROW_WIDTH = 3.4
ns.OPTIONS_LABEL_WIDTH = 2.1
ns.OPTIONS_CONTROL_WIDTH = ns.OPTIONS_ROW_WIDTH - ns.OPTIONS_LABEL_WIDTH
ns.OPTIONS_REMOVE_ICON_WIDTH = 0.25 -- the item lists' remove column, sized to its icon
ns.OPTIONS_SUB_INDENT_WIDTH = 0.115 -- the blank cell a sub-option row leads with

--------------------------------------------------------------------------------
-- Distribution Gate
--------------------------------------------------------------------------------

--[[
	When an item may be handed out at all, on top of the per-class amounts. Stored
	verbatim in the profile, so these strings are part of the saved format; the
	dropdown's labels are separate locale keys. Order is the order they list in.
]]
ns.DISTRIBUTE_MODES = { "Always", "Group", "Raid" }

--------------------------------------------------------------------------------
-- Message Length
--------------------------------------------------------------------------------

-- Bytes, not characters: the chat and macro-body ceilings both count bytes.
ns.CHAT_MESSAGE_MAX_LENGTH = 255

--------------------------------------------------------------------------------
-- Target Marker
--------------------------------------------------------------------------------

--[[
	{rt1} Star, {rt2} Circle, {rt3} Diamond, {rt4} Triangle,
	{rt5} Moon, {rt6} Square, {rt7} Cross, {rt8} Skull
]]
ns.TARGET_MARKER = "{rt6}" -- Square

--------------------------------------------------------------------------------
-- Colors
--------------------------------------------------------------------------------

-- Raw hex palette. ns.GetColor (Features/Utilities.lua) turns these into escape codes.
ns.PALETTE = {
	TITLE = "FFD100", -- Gold: Titles, Headers, Section Names
	INFO = "00BBFF", -- Blue: Interactions, Toggles, Links, Keybinds, Slash Commands
	BODY = "FFFFFF", -- White: Descriptions, Options Body Text
	HELP = "CCCCCC", -- Silver: Pro Tips, Helper Text
	TEXT = "FFFFFF", -- White: Messages, Values, Item Names
	ON = "33CC33", -- Green: On
	OFF = "CC3333", -- Red: Off
	SEPARATOR = "AAAAAA", -- Gray: Separators, Dividers
	MUTED = "808080", -- Dark Gray: Meta-data, Version Numbers
}

ns.CLASS_COLORS = {
	DEATHKNIGHT = "C41E3A",
	DRUID = "FF7C0A",
	HUNTER = "AAD372",
	MAGE = "3FC7EB",
	PALADIN = "F48CBA",
	PRIEST = "FFFFFF",
	ROGUE = "FFF468",
	SHAMAN = "0070DD",
	WARLOCK = "8788EE",
	WARRIOR = "C69B6D",
}

--------------------------------------------------------------------------------
-- Item Quality Colors
--------------------------------------------------------------------------------

-- Indexed by the quality GetItemInfo returns. Poor through Heirloom.
ns.ITEM_QUALITY_COLORS = {
	[0] = "9D9D9D",
	[1] = "FFFFFF",
	[2] = "1EFF00",
	[3] = "0070DD",
	[4] = "A335EE",
	[5] = "FF8000",
	[6] = "E6CC80",
	[7] = "00CCFF",
}

--------------------------------------------------------------------------------
-- URLs
--------------------------------------------------------------------------------

ns.URLS = {
	CURSEFORGE = "https://www.curseforge.com/wow/addons/water-dispenser-revisited",
	GITHUB = "https://github.com/Gogo1951/Water-Dispenser",
	DISCORD = "https://discord.gg/eh8hKq992Q",
	WAGO = "https://addons.wago.io/addons/water-dispenser",
}

--------------------------------------------------------------------------------
-- Classes
--------------------------------------------------------------------------------

-- Ordered class list. No Death Knight: targets Classic Era and TBC.
ns.CLASSES = {
	"DRUID",
	"HUNTER",
	"MAGE",
	"PALADIN",
	"PRIEST",
	"ROGUE",
	"SHAMAN",
	"WARLOCK",
	"WARRIOR",
}

--------------------------------------------------------------------------------
-- Icon Coordinates for Inline Textures
--------------------------------------------------------------------------------

--[[
	Inline icon escape tail: |T<path>:w:h:xOff:yOff:srcW:srcH:left:right:top:bottom|t
	0 height matches the line; the 4..60 of 64 quad trims Blizzard's icon border.
]]
ns.ICON_COORDS = ":0:0:0:0:64:64:4:60:4:60"
