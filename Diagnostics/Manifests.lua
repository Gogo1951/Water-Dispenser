local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader

--------------------------------------------------------------------------------
-- API Endpoints
--------------------------------------------------------------------------------

--[[
	Existence and shape checks only: read-only, no side effects, no protected
	calls. One row per API Water Dispenser calls or guards, wherever it lives,
	plus the readers the shared Diagnostics framework itself calls.

	The tooltip hooks take the modern path wherever TooltipDataProcessor exists
	and the fallback path elsewhere, so one half of each pair failing is the
	report working: the pair is what tells a bug report which branch that client
	took. The Inventory Tooltips report names the path each hook took.
]]
ns.DIAGNOSTIC_API_CHECKS = {
	-- { label, testFunction }
	{
		"C_Container.GetContainerNumSlots",
		function()
			return type(C_Container) == "table" and type(C_Container.GetContainerNumSlots) == "function"
		end,
	},
	{
		"C_Container.GetContainerItemInfo",
		function()
			return type(C_Container) == "table" and type(C_Container.GetContainerItemInfo) == "function"
		end,
	},
	{
		"C_Container.PickupContainerItem",
		function()
			return type(C_Container) == "table" and type(C_Container.PickupContainerItem) == "function"
		end,
	},
	{
		-- Portioning rests on these: without a split that honors its count, the fill can only hand over whole bag slots.
		"C_Container.SplitContainerItem",
		function()
			return type(C_Container) == "table" and type(C_Container.SplitContainerItem) == "function"
		end,
	},
	{
		"GetCursorInfo",
		function()
			return type(GetCursorInfo) == "function"
		end,
	},
	{
		"CursorHasItem",
		function()
			return type(CursorHasItem) == "function"
		end,
	},
	{
		"ClearCursor",
		function()
			return type(ClearCursor) == "function"
		end,
	},
	{
		"C_Item.RequestLoadItemDataByID",
		function()
			return type(C_Item) == "table" and type(C_Item.RequestLoadItemDataByID) == "function"
		end,
	},
	{
		"C_Item.GetItemInfo",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemInfo) == "function"
		end,
	},
	{
		"C_Item.DoesItemExistByID",
		function()
			return type(C_Item) == "table" and type(C_Item.DoesItemExistByID) == "function"
		end,
	},
	{
		"C_Item.GetItemInfoInstant",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemInfoInstant) == "function"
		end,
	},
	{
		"C_Spell.GetSpellInfo",
		function()
			return type(C_Spell) == "table" and type(C_Spell.GetSpellInfo) == "function"
		end,
	},
	{
		"C_Item.GetItemCount",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemCount) == "function"
		end,
	},
	{
		"C_PartyInfo.GetLootMethod",
		function()
			return type(C_PartyInfo) == "table" and type(C_PartyInfo.GetLootMethod) == "function"
		end,
	},
	{
		"C_Spell.GetSpellName",
		function()
			return type(C_Spell) == "table" and type(C_Spell.GetSpellName) == "function"
		end,
	},
	{
		"C_Spell.GetSpellSubtext",
		function()
			return type(C_Spell) == "table" and type(C_Spell.GetSpellSubtext) == "function"
		end,
	},
	{
		"TradeFrame_GetAvailableSlot",
		function()
			return type(TradeFrame_GetAvailableSlot) == "function"
		end,
	},
	{
		"ClickTradeButton",
		function()
			return type(ClickTradeButton) == "function"
		end,
	},
	{
		"MAX_TRADABLE_ITEMS",
		function()
			return MAX_TRADABLE_ITEMS ~= nil
		end,
	},
	{
		"GetTradePlayerItemLink",
		function()
			return type(GetTradePlayerItemLink) == "function"
		end,
	},
	{
		"GetTradePlayerItemInfo",
		function()
			return type(GetTradePlayerItemInfo) == "function"
		end,
	},
	{
		"UnitIsInMyGuild",
		function()
			return type(UnitIsInMyGuild) == "function"
		end,
	},
	{
		"IsSpellKnown",
		function()
			return type(IsSpellKnown) == "function"
		end,
	},
	{
		"IsPlayerSpell",
		function()
			return type(IsPlayerSpell) == "function"
		end,
	},
	{
		"GetMacroIndexByName",
		function()
			return type(GetMacroIndexByName) == "function"
		end,
	},
	{
		"CreateMacro",
		function()
			return type(CreateMacro) == "function"
		end,
	},
	{
		"EditMacro",
		function()
			return type(EditMacro) == "function"
		end,
	},
	{
		"DeleteMacro",
		function()
			return type(DeleteMacro) == "function"
		end,
	},
	{
		"C_ChatInfo.RegisterAddonMessagePrefix",
		function()
			return type(C_ChatInfo) == "table" and type(C_ChatInfo.RegisterAddonMessagePrefix) == "function"
		end,
	},
	{
		"C_ChatInfo.SendAddonMessage",
		function()
			return type(C_ChatInfo) == "table" and type(C_ChatInfo.SendAddonMessage) == "function"
		end,
	},
	{
		"TooltipDataProcessor.AddTooltipPostCall (modern tooltip path)",
		function()
			return type(TooltipDataProcessor) == "table" and type(TooltipDataProcessor.AddTooltipPostCall) == "function"
		end,
	},
	{
		"GameTooltip:SetBagItem (fallback bag tooltip path)",
		function()
			return type(GameTooltip) == "table" and type(GameTooltip.SetBagItem) == "function"
		end,
	},
	{
		"GameTooltip OnTooltipSetUnit script (fallback unit tooltip path)",
		function()
			return GameTooltip:HasScript("OnTooltipSetUnit") and true or false
		end,
	},
	{
		"Enum.TooltipDataType.Unit / .Item (modern tooltip path)",
		function()
			return type(Enum) == "table"
				and type(Enum.TooltipDataType) == "table"
				and Enum.TooltipDataType.Unit ~= nil
				and Enum.TooltipDataType.Item ~= nil
		end,
	},
	{
		"hooksecurefunc",
		function()
			return type(hooksecurefunc) == "function"
		end,
	},
	{
		"GameTooltip:GetUnit",
		function()
			return type(GameTooltip) == "table" and type(GameTooltip.GetUnit) == "function"
		end,
	},
	{
		"Settings.OpenToCategory",
		function()
			return type(Settings) == "table" and type(Settings.OpenToCategory) == "function"
		end,
	},
	{
		"C_Timer.NewTimer",
		function()
			return type(C_Timer) == "table" and type(C_Timer.NewTimer) == "function"
		end,
	},
	{
		"C_Timer.After",
		function()
			return type(C_Timer) == "table" and type(C_Timer.After) == "function"
		end,
	},
	{
		"C_AddOns.GetAddOnMetadata",
		function()
			return type(C_AddOns) == "table" and type(C_AddOns.GetAddOnMetadata) == "function"
		end,
	},
	{
		"C_AddOns.GetAddOnInfo",
		function()
			return type(C_AddOns) == "table" and type(C_AddOns.GetAddOnInfo) == "function"
		end,
	},
	{
		"C_AddOns.GetNumAddOns",
		function()
			return type(C_AddOns) == "table" and type(C_AddOns.GetNumAddOns) == "function"
		end,
	},
	{
		"issecretvalue",
		function()
			return type(issecretvalue) == "function"
		end,
	},
	{
		"C_EventUtils.IsEventValid",
		function()
			return type(C_EventUtils) == "table" and type(C_EventUtils.IsEventValid) == "function"
		end,
	},
	{
		"GetCVar",
		function()
			return type(GetCVar) == "function"
		end,
	},
	{
		"SetCVar",
		function()
			return type(SetCVar) == "function"
		end,
	},
	-- The master-loot hold indexes this on every trade opened inside an instance.
	{
		"Enum.LootMethod.Masterlooter",
		function()
			return type(Enum) == "table" and type(Enum.LootMethod) == "table" and Enum.LootMethod.Masterlooter ~= nil
		end,
	},
	-- The trade panel anchors to it on every TRADE_SHOW.
	{
		"TradeFrame",
		function()
			return type(TradeFrame) == "table"
		end,
	},
	-- Groupmate tooltips match a sender to a groupmate through it.
	{
		"GetNormalizedRealmName",
		function()
			return type(GetNormalizedRealmName) == "function"
		end,
	},
	-- Guarded in ns.GetClassName; the Dispensed Items grid sorts and labels classes by it.
	{
		"LOCALIZED_CLASS_NAMES_MALE",
		function()
			return type(LOCALIZED_CLASS_NAMES_MALE) == "table"
		end,
	},
	-- Every bag walk runs from BACKPACK_CONTAINER to ns.LAST_BAG_INDEX, which falls back to 4 without NUM_BAG_SLOTS.
	{
		"BACKPACK_CONTAINER",
		function()
			return type(BACKPACK_CONTAINER) == "number"
		end,
	},
	{
		"NUM_BAG_SLOTS",
		function()
			return type(NUM_BAG_SLOTS) == "number"
		end,
	},
	-- Data/Flavor.lua reads both on Classic Era to pick the Season of Discovery data folder.
	{
		"C_Seasons.GetActiveSeason",
		function()
			return type(C_Seasons) == "table" and type(C_Seasons.GetActiveSeason) == "function"
		end,
	},
	{
		"Enum.SeasonID.SeasonOfDiscovery",
		function()
			return type(Enum) == "table" and type(Enum.SeasonID) == "table" and Enum.SeasonID.SeasonOfDiscovery ~= nil
		end,
	},
	-- The Inventory Tooltips and Announcement Macro reports read these.
	{
		"C_ChatInfo.IsAddonMessagePrefixRegistered",
		function()
			return type(C_ChatInfo) == "table" and type(C_ChatInfo.IsAddonMessagePrefixRegistered) == "function"
		end,
	},
	{
		"GetMacroInfo",
		function()
			return type(GetMacroInfo) == "function"
		end,
	},
	{
		"GetNumMacros",
		function()
			return type(GetNumMacros) == "function"
		end,
	},
	{
		"MAX_CHARACTER_MACROS",
		function()
			return type(MAX_CHARACTER_MACROS) == "number"
		end,
	},
	--[[
		Validate Data's extra reads and its tooltip pair. One a client lacks leaves
		its columns blank; the tooltip text needs either both C_TooltipInfo getters
		or the hidden scan tooltip, picked by ns.GetTooltipLines.
	]]
	{
		"C_Item.GetItemSpell",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemSpell) == "function"
		end,
	},
	{
		"C_Item.GetDetailedItemLevelInfo",
		function()
			return type(C_Item) == "table" and type(C_Item.GetDetailedItemLevelInfo) == "function"
		end,
	},
	{
		"C_Item.GetItemStats",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemStats) == "function"
		end,
	},
	{
		"GetItemStats (legacy)",
		function()
			return type(GetItemStats) == "function"
		end,
	},
	{
		"C_Item.GetItemClassInfo",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemClassInfo) == "function"
		end,
	},
	{
		"C_Item.GetItemSubClassInfo",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemSubClassInfo) == "function"
		end,
	},
	{
		"C_Spell.GetSpellDescription",
		function()
			return type(C_Spell) == "table" and type(C_Spell.GetSpellDescription) == "function"
		end,
	},
	{
		"C_Spell.DoesSpellExist",
		function()
			return type(C_Spell) == "table" and type(C_Spell.DoesSpellExist) == "function"
		end,
	},
	{
		"C_Spell.RequestLoadSpellData",
		function()
			return type(C_Spell) == "table" and type(C_Spell.RequestLoadSpellData) == "function"
		end,
	},
	{
		"C_TooltipInfo.GetItemByID",
		function()
			return type(C_TooltipInfo) == "table" and type(C_TooltipInfo.GetItemByID) == "function"
		end,
	},
	{
		"C_TooltipInfo.GetSpellByID",
		function()
			return type(C_TooltipInfo) == "table" and type(C_TooltipInfo.GetSpellByID) == "function"
		end,
	},
	{
		"Hidden scan tooltip (legacy)",
		function()
			return type(CreateFrame) == "function"
				and type(GameTooltip) == "table"
				and type(GameTooltip.SetHyperlink) == "function"
				and type(GameTooltip.NumLines) == "function"
		end,
	},
}

--------------------------------------------------------------------------------
-- Event Log Filters
--------------------------------------------------------------------------------

-- The add-on's own example reports, appended to the shared Event Log intro.
ns.DiagnosticsStrings.EVENT_LOG_EXAMPLES =
	"Best for 'the trade window didn't fill' or 'the macro didn't update' reports."

-- Shown under the Event Log intro, because CHAT_MSG_ADDON is registered.
ns.DiagnosticsStrings.EVENT_LOG_PRIVACY =
	"This log records Water Dispenser's add-on messages, which carry your groupmates' names and what they have to give. Review it before you paste it anywhere."

--[[
	BAG_UPDATE fires per slot change; BAG_UPDATE_DELAYED (once per settle) is
	kept. The fill writes back the BAG_UPDATE firings it acts on, and its own
	PLACE, SHAPE, FILL and SPLIT steps, through ns:LogEventNow.
]]
ns.DIAGNOSTIC_EVENT_EXCLUDE = {
	BAG_UPDATE = true,
}

--[[
	CHAT_MSG_ADDON carries every add-on's traffic in the group, and in a raid the
	boss mods and meters alone would push everything else out of the buffer.
	GET_ITEM_INFO_RECEIVED fires once per item the client loads, hundreds of
	times while Validate Data or a bag add-on runs. Both carry their id first.
]]
ns.MESSAGE_ID_FILTERED_EVENTS = {
	CHAT_MSG_ADDON = 1,
	GET_ITEM_INFO_RECEIVED = 1,
}

-- The ids the live handlers act on, through the same lookups they use: the allowlist, never a list of noise.
ns.DIAGNOSTIC_CORRELATED_IDS = {
	CHAT_MSG_ADDON = function(prefix)
		return prefix == ns.ADDON_MESSAGE_PREFIX
	end,
	GET_ITEM_INFO_RECEIVED = function(itemId)
		return ns.IsItemNamePending ~= nil and ns.IsItemNamePending(itemId)
	end,
}

--------------------------------------------------------------------------------
-- Report Helpers
--------------------------------------------------------------------------------

-- Plain text for a report line: pipes escaped so a link pastes as text rather than a clickable swatch.
local function Plain(value)
	return (tostring(value):gsub("|", "||"))
end

local function YesNo(value)
	return value and "yes" or "no"
end

-- The configured item keys in the order the fill reports them: built-ins first, then user items by key.
local function ConfiguredKeys()
	local keys = {}
	local items = ns.db and ns.db.profile.Items
	if not items then
		return keys
	end
	for _, key in ipairs(ns.BUILTIN_ORDER) do
		if items[key] then
			keys[#keys + 1] = key
		end
	end
	local custom = {}
	for key in pairs(items) do
		if not ns.COLLECTION_META[key] then
			custom[#custom + 1] = key
		end
	end
	table.sort(custom, function(a, b)
		return tostring(a) < tostring(b)
	end)
	for _, key in ipairs(custom) do
		keys[#keys + 1] = key
	end
	return keys
end

--[[
	Every carried slot holding a collection item or a configured user item, read
	straight from the bags. Never through ns.ScanInventory or a snapshot builder:
	those replace the cache the fill compares against, so the next bag update
	would read no change and skip its refill.
]]
local function ReadTrackedBags()
	local items, order = {}, {}
	local configured = ns.db and ns.db.profile.Items or {}
	for bag = BACKPACK_CONTAINER, ns.LAST_BAG_INDEX do
		local slots = C_Container.GetContainerNumSlots(bag) or 0
		for slot = 1, slots do
			local info = C_Container.GetContainerItemInfo(bag, slot)
			local itemId = info and info.itemID
			if itemId and (ns.ITEM_TO_COLLECTION[itemId] or configured[itemId] ~= nil) then
				local item = items[itemId]
				if not item then
					local name, _, _, _, minLevel, _, _, maxStack = C_Item.GetItemInfo(itemId)
					item = {
						Id = itemId,
						Name = name,
						Collection = ns.ITEM_TO_COLLECTION[itemId],
						Rank = ns.ITEM_RANK[itemId],
						Level = ns.ITEM_LEVEL[itemId] or minLevel,
						MaxStack = maxStack,
						Slots = {},
					}
					items[itemId] = item
					order[#order + 1] = itemId
				end
				item.Slots[#item.Slots + 1] = {
					Bag = bag,
					Slot = slot,
					Count = info.stackCount or 0,
					Locked = info.isLocked and true or false,
					Bound = info.isBound and true or false,
				}
			end
		end
	end
	table.sort(order)
	return items, order
end

--------------------------------------------------------------------------------
-- Trade & Fill
--------------------------------------------------------------------------------

local function PickScope(trade)
	if trade.Active and trade.Party then
		return IsInRaid() and "Raid" or "Group"
	end
	return "Solo"
end

local function AppendPlayer(lines)
	local _, classToken = UnitClass("player")
	lines[#lines + 1] = string.format("Player: %s level %s", tostring(classToken), tostring(UnitLevel("player")))
	lines[#lines + 1] = "In combat: " .. YesNo(InCombatLockdown())
	local cursorType, cursorId = GetCursorInfo()
	lines[#lines + 1] = "Cursor: "
		.. (cursorType and string.format("%s %s", tostring(cursorType), tostring(cursorId)) or "(empty)")
	local inInstance, instanceType = IsInInstance()
	lines[#lines + 1] = string.format("In instance: %s (%s)", YesNo(inInstance), tostring(instanceType))
	lines[#lines + 1] = string.format(
		"Group: %s, chat channel %s",
		IsInRaid() and "raid" or (IsInGroup() and "party" or "none"),
		tostring(ns.GetGroupChatChannel())
	)
end

local function AppendSettings(lines, trade)
	local db = ns.db and ns.db.profile
	if not db then
		lines[#lines + 1] = "Settings: (database not initialized)"
		return
	end
	lines[#lines + 1] = string.format(
		"Settings: Dispense=%s DispenseSolo=%s DispenseGroup=%s DispenseRaid=%s",
		tostring(db.Dispense),
		tostring(db.DispenseSolo),
		tostring(db.DispenseGroup),
		tostring(db.DispenseRaid)
	)
	lines[#lines + 1] = string.format(
		"Settings: HoldForMasterLoot=%s MissingStackWarnings=%s CombatNotifications=%s",
		tostring(db.HoldForMasterLoot),
		tostring(db.MissingStackWarnings),
		tostring(db.CombatNotifications)
	)

	local okMethod, method, partyIndex, raidIndex = pcall(C_PartyInfo.GetLootMethod)
	if okMethod then
		lines[#lines + 1] = string.format(
			"Loot method: %s (party index %s, raid index %s)",
			tostring(method),
			tostring(partyIndex),
			tostring(raidIndex)
		)
	else
		lines[#lines + 1] = "Loot method: ERROR " .. Plain(method)
	end
	local okLooter, isLooter = pcall(ns.IsPlayerMasterLooter)
	lines[#lines + 1] = "Master looter: " .. (okLooter and YesNo(isLooter) or ("ERROR " .. Plain(isLooter)))
	local inInstance, instanceType = IsInInstance()
	local holds = db.HoldForMasterLoot
		and inInstance
		and (instanceType == "raid" or instanceType == "party")
		and okLooter
		and isLooter
	lines[#lines + 1] = "Master-loot hold would stop the automatic fill now: " .. YesNo(holds)

	local scope = PickScope(trade)
	lines[#lines + 1] = string.format(
		"Automatic fill for scope %s: %s",
		scope,
		YesNo(db.Dispense and db["Dispense" .. scope] and not holds)
	)
	lines[#lines + 1] = "An item is on for this class (the trade panel shows): " .. YesNo(ns.HasItemsForPlayer())
	lines[#lines + 1] = "Trade panel shown: " .. YesNo(ns.TradeUI and ns.TradeUI:IsShown())
end

local function AppendTrade(lines, trade)
	if not trade.Active then
		lines[#lines + 1] = "Trade: no active trade window"
		return
	end
	lines[#lines + 1] = string.format(
		"Trade (captured): partner=%s class=%s (%s) level=%s grouped=%s guildmate=%s",
		Plain(trade.Partner),
		tostring(trade.Class),
		Plain(trade.ClassName),
		tostring(trade.Level),
		tostring(trade.Party and true or false),
		tostring(trade.Guild)
	)
	local liveLevel = UnitLevel("NPC")
	local _, liveClass = UnitClass("NPC")
	lines[#lines + 1] = string.format(
		"Trade (live): class=%s level=%s guildmate=%s",
		tostring(liveClass),
		tostring(liveLevel),
		tostring(UnitIsInMyGuild("NPC"))
	)
	if not liveLevel or liveLevel <= 0 then
		lines[#lines + 1] = "  Partner level unknown: the fill uses your level + 10"
	end
	lines[#lines + 1] = "Scope: " .. PickScope(trade)
	lines[#lines + 1] = "Status line: " .. Plain(trade.Status)
	for _, field in ipairs({ "HoldReasons", "ShortNotes" }) do
		local keys = {}
		for key in pairs(trade[field] or {}) do
			keys[#keys + 1] = key
		end
		table.sort(keys, function(a, b)
			return tostring(a) < tostring(b)
		end)
		for _, key in ipairs(keys) do
			lines[#lines + 1] = string.format("  %s %s: %s", field, tostring(key), Plain(trade[field][key]))
		end
	end
	lines[#lines + 1] = "Refill waiting on a bag change (MissingStack): " .. tostring(ns.State.MissingStack)
	lines[#lines + 1] = "Window (your side):"
	local any = false
	for slot = 1, MAX_TRADABLE_ITEMS do
		local link = GetTradePlayerItemLink(slot)
		local _, _, count = GetTradePlayerItemInfo(slot)
		if link then
			any = true
			lines[#lines + 1] = string.format("  slot %d: %s x%s", slot, Plain(link), tostring(count))
		end
	end
	if not any then
		lines[#lines + 1] = "  (empty)"
	end
end

local function AppendFillState(lines)
	local state = ns.GetFillState()
	lines[#lines + 1] = string.format("Fill moves this trade: %d of %d", state.MovesThisTrade, state.MaxMovesPerTrade)
	local keys = {}
	for key in pairs(state.MovesPerItem) do
		keys[#keys + 1] = key
	end
	for key in pairs(state.SettlingSeconds) do
		if not state.MovesPerItem[key] then
			keys[#keys + 1] = key
		end
	end
	table.sort(keys, function(a, b)
		return tostring(a) < tostring(b)
	end)
	for _, key in ipairs(keys) do
		local settling = state.SettlingSeconds[key]
		lines[#lines + 1] = string.format(
			"  %s: moves %d of %d, last shape %s%s",
			tostring(key),
			state.MovesPerItem[key] or 0,
			state.MaxMovesPerItem,
			tostring(state.LastShape[key] or "none"),
			settling and string.format(", settling %.1fs", settling) or ""
		)
	end
	local placed = {}
	for itemId in pairs(state.Placed) do
		placed[#placed + 1] = itemId
	end
	table.sort(placed)
	for _, itemId in ipairs(placed) do
		local entry = state.Placed[itemId]
		lines[#lines + 1] = string.format("  placed item %d: %d slot(s), %d item(s)", itemId, entry.Slots, entry.Items)
	end
	lines[#lines + 1] = "Conjure waiting to be placed: "
		.. (#state.ConjureWatch > 0 and table.concat(state.ConjureWatch, ", ") or "none")
end

local function AppendItems(lines, trade)
	local items = ns.db and ns.db.profile.Items
	if not items then
		return
	end
	local scope = PickScope(trade)
	lines[#lines + 1] = "Configured items:"
	for _, key in ipairs(ConfiguredKeys()) do
		local itemConfig = items[key]
		lines[#lines + 1] = string.format(
			"  %s: active=%s distribute=%s (allowed now: %s) guildiesOnly=%s factorLevel=%s reserve=%d sessionCap=%s",
			Plain(ns.GetItemConfigName(key) or key),
			YesNo(ns.IsItemActiveForPlayer(itemConfig)),
			ns.NormalizeDistribute(itemConfig.Distribute),
			YesNo(ns.IsItemDistributableNow(itemConfig)),
			YesNo(itemConfig.GuildiesOnly),
			YesNo(itemConfig.FactorLevel),
			ns.GetItemReserve(itemConfig),
			tostring(ns.GetItemSessionCap(itemConfig) or "off")
		)
		local counts = {}
		for _, class in ipairs(ns.CLASSES) do
			counts[#counts + 1] = class .. "=" .. tostring((itemConfig[scope] or {})[class] or 0)
		end
		lines[#lines + 1] = string.format("    %s counts: %s", scope, table.concat(counts, " "))
		if trade.Active then
			lines[#lines + 1] = string.format(
				"    for this partner: allowed=%s, count for %s=%s",
				YesNo(ns.IsItemAllowedForPartner(itemConfig, trade.Guild)),
				tostring(trade.Class),
				tostring((itemConfig[scope] or {})[trade.Class] or 0)
			)
			local cap = ns.GetItemSessionCap(itemConfig)
			if cap and trade.Partner then
				local given = ns.GivenThisSession(key, trade.Partner)
				lines[#lines + 1] =
					string.format("    given this session: %d of %d, %d left", given, cap, math.max(0, cap - given))
			end
		end
	end
end

local function AppendBags(lines, trade)
	lines[#lines + 1] =
		string.format("Bags: carried 0 to %s (NUM_BAG_SLOTS=%s)", tostring(ns.LAST_BAG_INDEX), tostring(NUM_BAG_SLOTS))
	local items, order = ReadTrackedBags()
	if #order == 0 then
		lines[#lines + 1] = "  (no collection or configured items carried)"
	end
	for _, itemId in ipairs(order) do
		local item = items[itemId]
		local slots = {}
		for _, entry in ipairs(item.Slots) do
			slots[#slots + 1] = string.format(
				"%d:%d x%d%s%s",
				entry.Bag,
				entry.Slot,
				entry.Count,
				entry.Locked and " locked" or "",
				entry.Bound and " bound" or ""
			)
		end
		lines[#lines + 1] = string.format(
			"  %d %s: collection=%s rank=%s useLevel=%s maxStack=%s",
			itemId,
			Plain(item.Name or "(not loaded)"),
			tostring(item.Collection or "-"),
			tostring(item.Rank or "-"),
			tostring(item.Level),
			tostring(item.MaxStack or "(uncached)")
		)
		lines[#lines + 1] = "    " .. table.concat(slots, ", ")
	end

	--[[
		The fill's rank choice, from the bags above: ranks usable at the level limit,
		best first, or the lowest-level rank held when none is (UsableRankEntries).
	]]
	local levelLimit = trade.Active and trade.Level or ((UnitLevel("player") or 0) + 10)
	lines[#lines + 1] = string.format("Ranks for level %d%s:", levelLimit, trade.Active and "" or " (your level + 10)")
	for _, key in ipairs(ns.BUILTIN_ORDER) do
		local held, usable = {}, {}
		local best, lowest
		for _, itemId in ipairs(order) do
			local item = items[itemId]
			if item.Collection == key then
				held[#held + 1] = item
				if not best or (item.Rank or 0) > (best.Rank or 0) then
					best = item
				end
				if not lowest or (item.Level or 0) < (lowest.Level or 0) then
					lowest = item
				end
				if (item.Level or 0) <= levelLimit then
					usable[#usable + 1] = item
				end
			end
		end
		table.sort(usable, function(a, b)
			return (a.Rank or 0) > (b.Rank or 0)
		end)
		local start = usable[1] or lowest
		local usableIds = {}
		for _, item in ipairs(usable) do
			usableIds[#usableIds + 1] = tostring(item.Id)
		end
		lines[#lines + 1] = string.format(
			"  %s: held %d rank(s), best %s, usable %s, fill starts from %s",
			key,
			#held,
			best and tostring(best.Id) or "none",
			#usableIds > 0 and table.concat(usableIds, ", ") or "none",
			start and (tostring(start.Id) .. (usable[1] and "" or " (lowest held, none usable)")) or "nothing held"
		)
	end
end

--[[
	The state behind "I opened a trade and nothing went in": every gate the
	automatic fill reads, the partner, the fill's own brakes, each item's
	settings and what the bags actually hold. Reads only.
]]
function ns:BuildTradeFillReport()
	local lines = { GetClientHeader(), "" }
	local trade = ns.State.Trade
	AppendPlayer(lines)
	lines[#lines + 1] = ""
	AppendSettings(lines, trade)
	lines[#lines + 1] = ""
	AppendTrade(lines, trade)
	lines[#lines + 1] = ""
	AppendFillState(lines)
	lines[#lines + 1] = ""
	AppendItems(lines, trade)
	lines[#lines + 1] = ""
	AppendBags(lines, trade)
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Conjure & Restack
--------------------------------------------------------------------------------

--[[
	Manifests name spell tables by their dotted path on ns
	("COLLECTIONS.MageWater.Spells") rather than holding them, so a table this
	client's data folder never built resolves to nil and is reported instead of
	erroring.
]]
local function ResolveTable(path)
	local value = ns
	for key in path:gmatch("[^.]+") do
		if type(value) ~= "table" then
			return nil
		end
		value = value[key]
	end
	return type(value) == "table" and value or nil
end

--[[
	The spell tables the add-on reads, named by their path on ns so no spell ID
	lives in this file: each built-in collection's Spells ([spellId] = rank), then
	the Improved Healthstone talent, an array ranked by position (IdFrom = "value").
]]
ns.DIAGNOSTIC_SPELLS = {}
for _, key in ipairs(ns.BUILTIN_ORDER) do
	ns.DIAGNOSTIC_SPELLS[#ns.DIAGNOSTIC_SPELLS + 1] = { Label = key, Path = "COLLECTIONS." .. key .. ".Spells" }
end
ns.DIAGNOSTIC_SPELLS[#ns.DIAGNOSTIC_SPELLS + 1] =
	{ Label = "Improved Healthstone", Path = "HEALTHSTONE_TALENT_SPELLS", IdFrom = "value" }

-- Every rank in each spell table, lowest first, by the add-on's own test for "known".
local function AppendSpells(lines)
	lines[#lines + 1] = "Spells (known = ns.IsSpellLearned, the add-on's own test):"
	for _, entry in ipairs(ns.DIAGNOSTIC_SPELLS) do
		local spells = ResolveTable(entry.Path)
		if not spells then
			lines[#lines + 1] = string.format("  %s: TABLE MISSING (%s)", entry.Label, entry.Path)
		else
			local rows = {}
			for key, value in pairs(spells) do
				if entry.IdFrom == "value" then
					rows[#rows + 1] = { Id = value, Rank = key }
				else
					rows[#rows + 1] = { Id = key, Rank = value }
				end
			end
			table.sort(rows, function(a, b)
				return a.Rank < b.Rank
			end)
			for _, row in ipairs(rows) do
				local items = ns.SPELL_TO_ITEMS[row.Id]
				local level = items and items[1] and ns.ITEM_LEVEL[items[1]]
				lines[#lines + 1] = string.format(
					"  %s rank %d: %d %s, known=%s%s",
					entry.Label,
					row.Rank,
					row.Id,
					Plain(C_Spell.GetSpellName(row.Id) or "(name not loaded, button hidden)"),
					YesNo(ns.IsSpellLearned(row.Id)),
					level and (", makes level " .. level) or ""
				)
			end
		end
	end
end

local function AppendConjureButtons(lines, trade)
	local db = ns.db and ns.db.profile or {}
	local buttons = ns.GetConjureButtonsState()
	lines[#lines + 1] = string.format(
		"Conjure buttons: ConjureButtons=%s Dispense=%s inCombat=%s tradeOpen=%s tradePanelShown=%s",
		tostring(db.ConjureButtons),
		tostring(db.Dispense),
		YesNo(InCombatLockdown()),
		YesNo(trade.Active),
		YesNo(ns.TradeUI and ns.TradeUI:IsShown())
	)
	lines[#lines + 1] = string.format(
		"  holder created=%s shown=%s, hide waiting for combat to end=%s",
		YesNo(buttons.HolderExists),
		YesNo(buttons.HolderShown),
		YesNo(buttons.PendingHide)
	)
	local level = trade.Active and trade.Level or UnitLevel("player")
	lines[#lines + 1] =
		string.format("  rank each would cast for level %s%s:", tostring(level), trade.Active and "" or " (yours)")
	for _, key in ipairs(ns.BUILTIN_ORDER) do
		local row, fallback = ns.GetConjureSpell(key, level or 0)
		local shown = ns.conjureChoices[key]
		lines[#lines + 1] = string.format(
			"    %s: %s%s%s",
			key,
			row and tostring(row.SpellId) or "none known",
			fallback and " (lowest known, no rank fits)" or "",
			trade.Active and (shown and ", button shown" or ", no button") or ""
		)
		if ns.COLLECTION_META[key] and ns.COLLECTION_META[key].Unique then
			local carried = {}
			for itemId in pairs(ns.COLLECTIONS[key] and ns.COLLECTIONS[key].Items or {}) do
				local count = C_Item.GetItemCount(itemId)
				if count > 0 then
					carried[#carried + 1] = string.format("%d x%d", itemId, count)
				end
			end
			table.sort(carried)
			lines[#lines + 1] = "      carried (a carried tier is skipped): "
				.. (#carried > 0 and table.concat(carried, ", ") or "none")
		end
	end
end

local function AppendRestack(lines, trade)
	local db = ns.db and ns.db.profile or {}
	local inCombat = InCombatLockdown()
	local cursor = GetCursorInfo()
	local restack = ns.GetRestackState()
	lines[#lines + 1] = string.format(
		"Restack after a trade: RestackBags=%s Dispense=%s inCombat=%s tradeOpen=%s cursorHolding=%s",
		tostring(db.RestackBags),
		tostring(db.Dispense),
		YesNo(inCombat),
		YesNo(trade.Active),
		YesNo(cursor)
	)
	lines[#lines + 1] = string.format(
		"  would run now=%s, chain pending=%s, passes left=%s",
		YesNo(db.RestackBags and db.Dispense and not inCombat and not trade.Active and not cursor),
		YesNo(restack.TimerPending),
		tostring(restack.PassesLeft)
	)

	local partials = ns.CollectRestackPartials()
	local ids = {}
	for itemId in pairs(partials) do
		ids[#ids + 1] = itemId
	end
	table.sort(ids)
	lines[#lines + 1] = "  partial stacks it would merge:"
	if #ids == 0 then
		lines[#lines + 1] = "    none"
	end
	for _, itemId in ipairs(ids) do
		local slots = {}
		for _, entry in ipairs(partials[itemId]) do
			slots[#slots + 1] = string.format("%d:%d x%d", entry.Bag, entry.Slot, entry.Count)
		end
		local _, _, _, _, _, _, _, maxStack = C_Item.GetItemInfo(itemId)
		lines[#lines + 1] =
			string.format("    %d (stack %s): %s", itemId, tostring(maxStack), table.concat(slots, ", "))
	end

	-- What CollectPartials leaves out, so a stack that stayed loose says why.
	local items, order = ReadTrackedBags()
	local skipped = {}
	for _, itemId in ipairs(order) do
		local item = items[itemId]
		for _, entry in ipairs(item.Slots) do
			if entry.Locked then
				skipped[#skipped + 1] = string.format("%d at %d:%d (locked)", itemId, entry.Bag, entry.Slot)
			elseif not item.MaxStack then
				skipped[#skipped + 1] = string.format("%d at %d:%d (max stack uncached)", itemId, entry.Bag, entry.Slot)
			end
		end
	end
	lines[#lines + 1] = "  skipped: " .. (#skipped > 0 and table.concat(skipped, "; ") or "none")
end

--[[
	The state behind "the conjure buttons never show" and "my water never got
	combined": every gate on each, the rank each button would cast, every spell
	rank known, and the partial stacks a restack would and wouldn't touch.
]]
function ns:BuildConjureRestackReport()
	local lines = { GetClientHeader(), "" }
	local trade = ns.State.Trade
	AppendConjureButtons(lines, trade)
	lines[#lines + 1] = ""
	AppendSpells(lines)
	lines[#lines + 1] = ""
	AppendRestack(lines, trade)
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Announcement Macro
--------------------------------------------------------------------------------

--[[
	The state behind "the - Dispenser macro is empty, missing or out of date":
	the switch, the macro as it stands, the character's macro slots, and what the
	add-on would write now. Building that body scans the bags, so it is skipped
	while a trade is open, where the fill is comparing against that scan.
]]
function ns:BuildAnnouncementReport()
	local lines = { GetClientHeader(), "" }
	local db = ns.db and ns.db.profile or {}
	local state = ns.GetAnnouncementState()
	lines[#lines + 1] = string.format(
		"Settings: Announcements.Enabled=%s Dispense=%s (off leaves the body empty)",
		tostring(db.Announcements and db.Announcements.Enabled),
		tostring(db.Dispense)
	)
	lines[#lines + 1] = "In combat (updates wait for combat to end): " .. YesNo(InCombatLockdown())
	lines[#lines + 1] = string.format(
		"Channel: %s, so the body starts %q",
		tostring(ns.GetGroupChatChannel() or "none"),
		state.ChannelSlash
	)
	lines[#lines + 1] = "Raid marker: "
		.. (ns.FLAVOR == "Camelot" and "dropped (WoW Forever blocks it in chat)" or ns.TARGET_MARKER)
	lines[#lines + 1] = string.format(
		"Update: pending=%s heldForCombat=%s slotsFullWarningGiven=%s",
		YesNo(state.UpdatePending),
		YesNo(state.PendingCombatUpdate),
		YesNo(state.MacroFullWarned)
	)

	local _, perCharacter = GetNumMacros()
	lines[#lines + 1] =
		string.format("Character macros: %s of %s", tostring(perCharacter), tostring(MAX_CHARACTER_MACROS))

	lines[#lines + 1] = ""
	if state.Index and state.Index > 0 then
		local _, _, body = GetMacroInfo(state.Index)
		body = body or ""
		lines[#lines + 1] = string.format("Macro %q: slot %d", state.MacroName, state.Index)
		lines[#lines + 1] = string.format("  body (%d of %d bytes): %s", #body, ns.CHAT_MESSAGE_MAX_LENGTH, Plain(body))
		if state.LastMacroBody == nil then
			lines[#lines + 1] = "  matches the last body written: (nothing written this session)"
		else
			lines[#lines + 1] = "  matches the last body written: " .. YesNo(body == state.LastMacroBody)
		end
	else
		lines[#lines + 1] = string.format("Macro %q: does not exist", state.MacroName)
	end

	lines[#lines + 1] = ""
	if ns.State.Trade.Active then
		lines[#lines + 1] = "Would write: (skipped while a trade is open)"
	else
		local message = ns.BuildAnnouncementMessage()
		if message then
			lines[#lines + 1] = string.format(
				"Would write (%d bytes with the channel slash, limit %d): %s",
				#state.ChannelSlash + #message,
				ns.CHAT_MESSAGE_MAX_LENGTH,
				Plain(state.ChannelSlash .. message)
			)
		else
			lines[#lines + 1] = "Would write: an empty body (nothing to give)"
		end
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Inventory Tooltips
--------------------------------------------------------------------------------

local function ItemCounts(offer)
	local ids = {}
	for itemId in pairs(offer.Items) do
		ids[#ids + 1] = itemId
	end
	table.sort(ids)
	local parts = {}
	for _, itemId in ipairs(ids) do
		local item = offer.Items[itemId]
		parts[#parts + 1] = string.format(
			"%d %s x%d%s",
			itemId,
			Plain(C_Item.GetItemInfo(itemId) or "(not loaded, row skipped)"),
			item.Count,
			item.ShowQuantity and "" or " (quantity hidden)"
		)
	end
	return #parts > 0 and table.concat(parts, "; ") or "nothing"
end

--[[
	The state behind "a tooltip isn't listing what I or a groupmate has to give":
	both tooltip switches, the hooks, the add-on channel, and every name the
	channel has heard beside every name on the roster. A sender with no roster
	match is the silent failure: their list arrived under a spelling the tooltip
	never looks up. Lists groupmates' names, as README-Notes records.
]]
function ns:BuildInventoryTooltipsReport()
	local lines = { GetClientHeader(), "" }
	local db = ns.db and ns.db.profile or {}
	lines[#lines + 1] = string.format(
		"Settings: ShowInventoryTooltips=%s ShareInventory=%s ShowBagTooltips=%s Dispense=%s",
		tostring(db.ShowInventoryTooltips),
		tostring(db.ShareInventory),
		tostring(db.ShowBagTooltips),
		tostring(db.Dispense)
	)
	lines[#lines + 1] = "In combat (tooltip blocks are skipped): " .. YesNo(InCombatLockdown())
	lines[#lines + 1] = string.format(
		"Hooks: unit tooltip %s, bag tooltip %s, carried bags 0 to %s",
		ns.unitTooltipPath or "not hooked",
		ns.bagTooltipPath or "not hooked",
		tostring(ns.LAST_BAG_INDEX)
	)

	local registered = "n/a"
	if C_ChatInfo and C_ChatInfo.IsAddonMessagePrefixRegistered then
		registered = YesNo(C_ChatInfo.IsAddonMessagePrefixRegistered(ns.ADDON_MESSAGE_PREFIX))
	end
	lines[#lines + 1] = string.format(
		"Channel: %s, prefix %s registered: %s",
		tostring(ns.GetGroupChatChannel() or "none (not grouped)"),
		ns.ADDON_MESSAGE_PREFIX,
		registered
	)

	local state = ns.GetGroupSparesState()
	lines[#lines + 1] = string.format(
		"Broadcast: pending=%s heldForCombat=%s rosterChangeHeldForCombat=%s",
		YesNo(state.BroadcastPending),
		YesNo(state.HeldForCombat),
		YesNo(state.RosterChangedInCombat)
	)
	lines[#lines + 1] = string.format(
		"Last sent on %s: %s",
		tostring(state.LastChannel or "-"),
		state.LastBroadcast and Plain(state.LastBroadcast:gsub("\n", " / ")) or "(nothing sent this session)"
	)

	local healthstoneRank = ns.HealthstoneTalentRank()
	local talentSpell = ns.HEALTHSTONE_TALENT_SPELLS and ns.HEALTHSTONE_TALENT_SPELLS[1]
	lines[#lines + 1] = string.format(
		"Improved Healthstone: rank sent %s, talent name %s",
		tostring(healthstoneRank or "n/a (not a warlock)"),
		Plain(talentSpell and C_Spell.GetSpellName(talentSpell) or "(not loaded, talent row skipped)")
	)

	lines[#lines + 1] = ""
	lines[#lines + 1] = "Your key: " .. Plain(state.OwnKey or "(unreadable)")
	local onRoster = {}
	lines[#lines + 1] = "Roster:"
	if #state.Roster == 0 then
		lines[#lines + 1] = "  (not grouped)"
	end
	for _, key in ipairs(state.Roster) do
		onRoster[key] = true
		if key ~= state.OwnKey then
			lines[#lines + 1] = string.format("  %s: heard %s", Plain(key), YesNo(state.Received[key]))
		end
	end

	local senders = {}
	for sender in pairs(state.Received) do
		senders[#senders + 1] = sender
	end
	table.sort(senders)
	lines[#lines + 1] = "Heard from:"
	if #senders == 0 then
		lines[#lines + 1] = "  (nobody)"
	end
	for _, sender in ipairs(senders) do
		local offer = state.Received[sender]
		lines[#lines + 1] = string.format(
			"  %s%s: %s%s",
			Plain(sender),
			onRoster[sender] and "" or " (no roster match)",
			ItemCounts(offer),
			offer.Talent and string.format(", healthstone talent %d", offer.Talent) or ""
		)
	end
	if #state.Partial > 0 then
		lines[#lines + 1] = "Still arriving: " .. Plain(table.concat(state.Partial, ", "))
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Display Context
--------------------------------------------------------------------------------

--[[
	The mini-map button Display Context reads: registered with LibDBIcon under
	the brand name, its placement kept in the profile (Simple model).
]]
ns.DIAGNOSTIC_MINIMAP = {
	name = ns.LOCALE_NAME,
	settings = function()
		return ns.db and ns.db.profile.minimap
	end,
	savedPath = function()
		return { "profiles", ns.db and ns.db:GetCurrentProfile() or "?", "minimap" }
	end,
}

--------------------------------------------------------------------------------
-- Name Lookups
--------------------------------------------------------------------------------

--[[
	Every game record the add-on names by ID, for the Localization tab's Game
	Names report: { constant, kind, id, lookup }. lookup is the exact call the
	add-on's features make and returns the client's name, or nil while the
	client has none. Built from the data, so a new collection or rank is checked
	with nothing added here; the player's own Dispensed Items are added at run
	time by the report.
]]
local function LookupItemName(itemId)
	return (C_Item.GetItemInfo(itemId))
end

local function LookupSpellName(spellId)
	return C_Spell.GetSpellName(spellId)
end

local function SortedKeys(values)
	local keys = {}
	for key in pairs(values or {}) do
		keys[#keys + 1] = key
	end
	table.sort(keys)
	return keys
end

ns.DIAGNOSTIC_NAME_LOOKUPS = {}

local function AddLookup(constant, kind, id, lookup)
	ns.DIAGNOSTIC_NAME_LOOKUPS[#ns.DIAGNOSTIC_NAME_LOOKUPS + 1] =
		{ constant = constant, kind = kind, id = id, lookup = lookup }
end

for _, key in ipairs(ns.BUILTIN_ORDER) do
	local nameItemId = ns.COLLECTION_NAME_ITEM_ID[key]
	if nameItemId then
		-- The collection's label goes through ns.GetItemConfigName, whose Loading placeholder is not a name.
		AddLookup("COLLECTION_NAME_ITEM_ID." .. key, "item", nameItemId, function(itemId)
			if not C_Item.GetItemInfo(itemId) then
				return nil
			end
			return ns.GetItemConfigName(key)
		end)
	end
	local collection = ns.COLLECTIONS[key]
	if collection then
		for _, itemId in ipairs(SortedKeys(collection.Items)) do
			AddLookup("COLLECTIONS." .. key .. ".Items", "item", itemId, LookupItemName)
		end
		for _, spellId in ipairs(SortedKeys(collection.Spells)) do
			AddLookup("COLLECTIONS." .. key .. ".Spells", "spell", spellId, LookupSpellName)
		end
	end
end
-- Only the first talent rank is ever named: it labels the healthstone row in a warlock's tooltip.
if ns.HEALTHSTONE_TALENT_SPELLS and ns.HEALTHSTONE_TALENT_SPELLS[1] then
	AddLookup("HEALTHSTONE_TALENT_SPELLS[1]", "spell", ns.HEALTHSTONE_TALENT_SPELLS[1], LookupSpellName)
end
for _, class in ipairs(ns.CLASSES) do
	AddLookup("CLASSES", "class", class, ns.GetClassName)
end

--------------------------------------------------------------------------------
-- Validate Data Sources
--------------------------------------------------------------------------------

--[[
	One entry per data file, and one report row per entry on the Data tab. Each
	entry's label is the table-name part of its file name, so ns.DataSourceFileName
	can name the file this client's folder built. Each source names the static
	table on ns and its kind. Ids are reached through rowId(key, row) over the
	table's pairs, or through collect(tbl) for a table not keyed by the id it
	holds, which returns { id, key, row } entries. dataColumns carries the shipped
	row's own values as { header, getter(key, row) }, so the export sets what the
	file says beside what the client says.

	COLLECTIONS nests one Items and one Spells table per built-in collection, so
	both of its sources walk the nesting and carry the collection key along.
]]
local function CollectionCollector(field)
	return function(collections)
		local entries = {}
		for key, collection in pairs(collections) do
			if type(collection) == "table" and type(collection[field]) == "table" then
				for id, row in pairs(collection[field]) do
					entries[#entries + 1] = { id = id, key = key, row = row }
				end
			end
		end
		return entries
	end
end

local function KeyValue(key)
	return key
end

local function RowValue(_, row)
	return row
end

local function RowField(position)
	return function(_, row)
		return type(row) == "table" and row[position] or nil
	end
end

ns.DIAGNOSTIC_DATA_SOURCES = {
	-- { label, sources = { { table, kind, rowId or collect, dataColumns } } }
	{
		label = "Collections",
		sources = {
			{
				table = "COLLECTIONS",
				kind = "item",
				collect = CollectionCollector("Items"),
				dataColumns = {
					{ "DATA_COLLECTION", KeyValue },
					{ "DATA_RANK", RowField(1) },
					{ "DATA_USE_LEVEL", RowField(2) },
					{ "DATA_HEAL", RowField(3) },
				},
			},
			{
				table = "COLLECTIONS",
				kind = "spell",
				collect = CollectionCollector("Spells"),
				dataColumns = {
					{ "DATA_COLLECTION", KeyValue },
					{ "DATA_RANK", RowValue },
				},
			},
			{
				table = "HEALTHSTONE_TALENT_SPELLS",
				kind = "spell",
				rowId = RowValue,
				dataColumns = { { "DATA_TALENT_RANK", KeyValue } },
			},
		},
	},
}
