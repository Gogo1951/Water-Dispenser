std = "lua51"
max_line_length = false -- StyLua owns formatting
ignore = { "212/self", "611", "612", "613", "614", "621" } -- implicit self (house ns: methods) + whitespace
exclude_files = { "Includes/" } -- vendored, never linted

-- The WoW API surface this add-on reads and never writes.
read_globals = {
	"BACKPACK_CONTAINER",
	"C_AddOns",
	"C_ChatInfo",
	"C_Container",
	"C_EventUtils",
	"C_Item",
	"C_Spell",
	"C_Timer",
	"ClearCursor",
	"ClickTradeButton",
	"CreateFrame",
	"CreateMacro",
	"CursorHasItem",
	"DeleteMacro",
	"EditMacro",
	"Enum",
	"GameTooltip",
	"hooksecurefunc",
	"GetBuildInfo",
	"GetCursorInfo",
	"GetCVar",
	"GetGuildInfo",
	"GetItemInfo",
	"GetItemInfoInstant",
	"GetLocale",
	"GetRealmName",
	"GetMacroIndexByName",
	"GetSpellInfo",
	"GetTime",
	"GetTradePlayerItemInfo",
	"GetTradePlayerItemLink",
	"InCombatLockdown",
	"IsInGroup",
	"IsInInstance",
	"IsInRaid",
	"IsPlayerSpell",
	"IsShiftKeyDown",
	"IsSpellKnown",
	"LE_PARTY_CATEGORY_INSTANCE",
	"LOCALIZED_CLASS_NAMES_MALE",
	"LibStub",
	"MAX_TRADABLE_ITEMS",
	"NUM_BAG_SLOTS",
	"SetCVar",
	"Settings",
	--[[
		Blizzard's table, so it is read-only apart from the one key the add-on
		registers its slash command under. Declared as a field rather than by listing
		the table under globals, which would sanction writing over the whole thing.
	]]
	SlashCmdList = { fields = { WATERDISPENSER = { read_only = false } } },
	"TooltipDataProcessor",
	"TradeFrame",
	"TradeFrame_GetAvailableSlot",
	"UIParent",
	"UnitClass",
	"UnitInParty",
	"UnitInRaid",
	"UnitLevel",
	"UnitName",
	"UnitIsInMyGuild",
	"UnitIsPlayer",
	"UnitIsUnit",
	"wipe",
	"WOW_PROJECT_ID",
	"format",
}

-- The closed set of globals the add-on owns: its saved variables and its slash command.
globals = {
	"SLASH_WATERDISPENSER1",
	"WaterDispenserDB",
}
