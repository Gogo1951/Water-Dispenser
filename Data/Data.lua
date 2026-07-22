local ADDON_NAME, ns = ...

ns.LOCALE_NAME = "WaterDispenser"
ns.L = LibStub("AceLocale-3.0"):GetLocale(ns.LOCALE_NAME)

--------------------------------------------------------------------------------
-- AceConfig Registry Names
--------------------------------------------------------------------------------

-- Registry IDs derived from the addon name so they never drift.
ns.OPTIONS_REGISTRY = {
	General = ADDON_NAME,
	DistributionRules = ADDON_NAME .. "_DistributionRules",
	Announcements = ADDON_NAME .. "_Announcements",
	Profiles = ADDON_NAME .. "_Profiles",
	Diagnostics = ADDON_NAME .. "_Diagnostics",
}

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
