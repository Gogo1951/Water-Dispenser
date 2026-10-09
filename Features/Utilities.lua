local _, ns = ...

local L = ns.L

--------------------------------------------------------------------------------
-- Combat Guard
--------------------------------------------------------------------------------

function ns.IsInCombat()
	return InCombatLockdown()
end

--[[
	Forever's Retail engine hides some values from add-ons in combat, and comparing,
	indexing or string-building with one throws. Era and TBC ship issecretvalue too,
	but only Forever is known to hand an add-on a hidden value.
]]
local isSecretValue = issecretvalue

function ns.IsSecretValue(value)
	return isSecretValue ~= nil and isSecretValue(value) == true
end

--------------------------------------------------------------------------------
-- Item Stats
--------------------------------------------------------------------------------

--[[
	An item's stat table from its link. WoW Forever ships C_Item.GetItemStats;
	Classic Era and TBC Anniversary have only the legacy global GetItemStats,
	which returns the same table. Resolved once at load, modern first; both are
	rows in the Diagnostic Tools API report.
]]
ns.GetItemStats = C_Item.GetItemStats or GetItemStats

--------------------------------------------------------------------------------
-- Tooltip Text
--------------------------------------------------------------------------------

--[[
	An item's or spell's tooltip as plain lines, a right-hand column kept after
	" >> ". kind is "item" or "spell". C_TooltipInfo hands the lines over as
	data where the client ships its GetItemByID and GetSpellByID getters (WoW
	Forever); elsewhere they are read off a hidden tooltip that is never shown
	(Classic Era and TBC Anniversary). Color escapes are stripped so each line
	reads as its words. Resolved once at load. A read can throw on an odd id, so
	callers protect it.
]]
local SCAN_TOOLTIP_NAME = "WaterDispenserScanTooltip"
local TOOLTIP_DATA_GETTERS = C_TooltipInfo
	and C_TooltipInfo.GetItemByID
	and C_TooltipInfo.GetSpellByID
	and { item = C_TooltipInfo.GetItemByID, spell = C_TooltipInfo.GetSpellByID }
local scanTooltip

local function PlainText(text)
	if type(text) ~= "string" then
		return nil
	end
	return (text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|cn[^:]*:", ""):gsub("|r", ""))
end

local function JoinTooltipLine(left, right)
	left = PlainText(left) or ""
	right = PlainText(right)
	if right and right ~= "" then
		return left .. " >> " .. right
	end
	return left
end

local function ReadTooltipData(kind, id)
	local lines = {}
	local data = TOOLTIP_DATA_GETTERS[kind](id)
	for _, line in ipairs(data and data.lines or {}) do
		lines[#lines + 1] = JoinTooltipLine(line.leftText, line.rightText)
	end
	return lines
end

local function ReadScanTooltip(kind, id)
	if not scanTooltip then
		scanTooltip = CreateFrame("GameTooltip", SCAN_TOOLTIP_NAME, nil, "GameTooltipTemplate")
	end
	scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	scanTooltip:ClearLines()
	scanTooltip:SetHyperlink(kind .. ":" .. id)
	local lines = {}
	for index = 1, scanTooltip:NumLines() do
		local left = _G[SCAN_TOOLTIP_NAME .. "TextLeft" .. index]
		local right = _G[SCAN_TOOLTIP_NAME .. "TextRight" .. index]
		lines[#lines + 1] = JoinTooltipLine(left and left:GetText(), right and right:IsShown() and right:GetText())
	end
	scanTooltip:Hide()
	return lines
end

ns.GetTooltipLines = TOOLTIP_DATA_GETTERS and ReadTooltipData or ReadScanTooltip

--------------------------------------------------------------------------------
-- Formatting
--------------------------------------------------------------------------------

function ns:FormatCommaNumber(number)
	return (tostring(number):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

--------------------------------------------------------------------------------
-- Colors
--------------------------------------------------------------------------------

-- Escape codes derived from ns.PALETTE. GetColor returns the prefix; callers append "|r" themselves.
local COLOR_PREFIX = "|cff"
local COLORS = {}
for key, hex in pairs(ns.PALETTE) do
	COLORS[key] = COLOR_PREFIX .. hex
end

function ns.GetColor(key)
	return COLORS[key] or COLORS.TEXT
end

--------------------------------------------------------------------------------
-- Collection Lookups
--------------------------------------------------------------------------------

--[[
	Reverse-lookups from ns.COLLECTIONS (loaded first). ITEM_TO_COLLECTION tags a
	bag item to its collection even without the conjure spell; ITEM_RANK and
	ITEM_LEVEL drive best-tier selection and partner-level filtering;
	SPELL_TO_ITEMS names the items one conjure spell can produce (its rank's
	horizontal variants included), so a cast knows which bag slots to watch.
]]
ns.ITEM_TO_COLLECTION = {}
ns.SPELL_TO_COLLECTION = {}
ns.SPELL_TO_ITEMS = {}
ns.ITEM_RANK = {}
ns.ITEM_LEVEL = {}
for key, collection in pairs(ns.COLLECTIONS) do
	for itemId, meta in pairs(collection.Items) do
		ns.ITEM_TO_COLLECTION[itemId] = key
		ns.ITEM_RANK[itemId] = meta[1]
		ns.ITEM_LEVEL[itemId] = meta[2]
	end
	for spellId, rank in pairs(collection.Spells) do
		ns.SPELL_TO_COLLECTION[spellId] = key
		local items = {}
		for itemId, meta in pairs(collection.Items) do
			if meta[1] == rank then
				items[#items + 1] = itemId
			end
		end
		ns.SPELL_TO_ITEMS[spellId] = items
	end
end

-- The item whose client name labels each collection: its rank-1 item, the lowest ID when several share the rank.
ns.COLLECTION_NAME_ITEM_ID = {}
for key, collection in pairs(ns.COLLECTIONS) do
	local nameItemId
	for itemId, meta in pairs(collection.Items) do
		if meta[1] == 1 and (not nameItemId or itemId < nameItemId) then
			nameItemId = itemId
		end
	end
	ns.COLLECTION_NAME_ITEM_ID[key] = nameItemId
end

--------------------------------------------------------------------------------
-- Item Amounts
--------------------------------------------------------------------------------

--[[
	Both amounts are stored next to the toggle that arms them, so the stored number
	survives being switched off and comes back as the player left it. Read them only
	through ns.GetItemReserve and ns.GetItemSessionCap, or a disabled reserve starts
	guarding the bag again.
]]
function ns.GetItemReserve(itemConfig)
	if not (itemConfig and itemConfig.KeepAtLeastEnabled) then
		return 0
	end
	return tonumber(itemConfig.KeepAtLeast) or 0
end

--[[
	Whether an item's count rides along with its name on the tooltip and in the
	macro. Only an explicit false switches it off: an item configured before the
	setting existed carries no value, and a missing value reads as on.
]]
function ns.GetItemIncludeQuantity(itemConfig)
	return not itemConfig or itemConfig.IncludeQuantity ~= false
end

-- The per-person session limit in force, or nil when the item has none.
function ns.GetItemSessionCap(itemConfig)
	if not (itemConfig and itemConfig.SessionCapEnabled) then
		return nil
	end
	local cap = tonumber(itemConfig.SessionCap)
	if not cap or cap < 1 then
		return nil
	end
	return cap
end

--------------------------------------------------------------------------------
-- Giveaway Refresh
--------------------------------------------------------------------------------

--[[
	Anything that changes what the player has to give away invalidates two things at
	once: the announcement macro's body, and what the group has been told for their
	tooltips. They refresh together through here so a new call site cannot remember
	one and forget the other.
]]
function ns.RefreshGiveaways()
	if ns.RefreshAnnouncementMacro then
		ns.RefreshAnnouncementMacro()
	end
	if ns.RefreshGroupSpares then
		ns.RefreshGroupSpares()
	end
end

--------------------------------------------------------------------------------
-- Spells
--------------------------------------------------------------------------------

-- IsSpellKnown misses some trained ranks on Classic Era, so IsPlayerSpell backs it up; either true counts as known.
function ns.IsSpellLearned(spellId)
	return (IsSpellKnown(spellId) or IsPlayerSpell(spellId)) and true or false
end

--------------------------------------------------------------------------------
-- Class Name Helpers
--------------------------------------------------------------------------------

function ns.GetClassName(class)
	local names = LOCALIZED_CLASS_NAMES_MALE
	return (names and names[class]) or class
end

--[[
	The stored Distribute value, folded to one the add-on still understands. A
	profile written before Group and Raid were dropped still carries them, and a
	value with no meaning here counts as no gate rather than a gate that never
	opens: for a rule about withholding items, erring toward giving is the safe
	direction, and it matches the item that has no stored value at all.
]]
function ns.NormalizeDistribute(value)
	for _, mode in ipairs(ns.DISTRIBUTE_MODES) do
		if value == mode then
			return value
		end
	end
	return "Always"
end

--[[
	Whether an item may go out at all right now, judged on where the *player* is
	rather than on the trade partner.

	  Always    never gates, and is what an item with no value stored falls back to.
	  Instance  a dungeon, raid, battleground or arena, and nowhere else.

	This is only ever about place. Who is owed how much is the per-class Party and
	Raid columns' business, and they say it better: an item nobody should get in a
	party is a column of zeros. What the columns cannot express is the difference
	between a group standing in a city and the same group inside a dungeon, which
	is the whole of what Instance adds.

	The same answer gates the fill, the player tooltip and the announcement macro,
	so an item that cannot be given right now is never advertised either.
]]
function ns.IsItemDistributableNow(itemConfig)
	local mode = ns.NormalizeDistribute(itemConfig and itemConfig.Distribute)
	if mode == "Instance" then
		return IsInInstance() and true or false
	end
	return true
end

--[[
	Whether the partner in front of the player passes the item's guild gate. Kept
	apart from IsItemDistributableNow because the two ask different questions: that
	one is about the player and settles whether the item is offered or announced at
	all, this one is about whoever opened the trade and can only ever empty one
	trade window.

	inMyGuild is read off the unit once at TRADE_SHOW rather than here, so this
	stays a plain rule with no unit call in it -- and being guildless is a real
	answer, not a missing one: it means nobody qualifies, which the option's helper
	line says out loud rather than leaving the player with a window that fills with
	nothing and no reason why.
]]
function ns.IsItemAllowedForPartner(itemConfig, inMyGuild)
	if not (itemConfig and itemConfig.GuildiesOnly) then
		return true
	end
	return inMyGuild and true or false
end

--[[
	The config key an item ID answers to: its collection key for a built-in, the ID
	itself for a user-added item, nil when the player has not configured it at all.
]]
function ns.GetItemConfigKey(itemId)
	local key = ns.ITEM_TO_COLLECTION[itemId]
	if not key and ns.db and ns.db.profile.Items[itemId] ~= nil then
		key = itemId
	end
	return key
end

-- True if the item's PlayerClasses includes the player's class; missing PlayerClasses counts as all classes.
function ns.IsItemActiveForPlayer(itemConfig)
	if not itemConfig or not itemConfig.PlayerClasses then
		return true
	end
	local _, playerClass = UnitClass("player")
	return itemConfig.PlayerClasses[playerClass] == true
end

--[[
	True while the player is master looter, the person a dungeon or raid's boss loot
	is traded out from. All three clients ship C_PartyInfo.GetLootMethod, with the
	looter's party slot (0 is the player) or raid slot.
]]
function ns.IsPlayerMasterLooter()
	local method, partyIndex, raidIndex = C_PartyInfo.GetLootMethod()
	if method ~= Enum.LootMethod.Masterlooter then
		return false
	end
	if raidIndex then
		return UnitIsUnit("raid" .. raidIndex, "player")
	end
	return partyIndex == 0
end

-- True if any configured item is switched on for the player's class, which is what earns the trade panel a place.
function ns.HasItemsForPlayer()
	if not ns.db then
		return false
	end
	for _, itemConfig in pairs(ns.db.profile.Items) do
		if ns.IsItemActiveForPlayer(itemConfig) then
			return true
		end
	end
	return false
end

--------------------------------------------------------------------------------
-- Lists
--------------------------------------------------------------------------------

-- Joins parts with commas and a localized "and" before the last: "A", "A and B", "A, B, and C".
function ns.JoinList(parts)
	local n = #parts
	if n == 0 then
		return ""
	end
	if n == 1 then
		return parts[1]
	end
	local andWord = L["ANNOUNCEMENTS_AND"]
	if n == 2 then
		return parts[1] .. " " .. andWord .. " " .. parts[2]
	end
	local last = parts[n]
	local head = table.concat(parts, ", ", 1, n - 1)
	return head .. ", " .. andWord .. " " .. last
end

--------------------------------------------------------------------------------
-- Item Presentation
--------------------------------------------------------------------------------

--[[
	An entry's name and icon are read fresh every time, never from the saved
	config, so they follow the client's language and the game's own renames. Both
	names come from the client by item ID: a built-in collection's from its
	ns.COLLECTION_NAME_ITEM_ID item, a user-added item's from its own. A built-in's
	icon comes from code.

	The item whose name labels the entry, or nil when the key is neither. The
	options panel watches these IDs to repaint once a placeholder's item loads.
]]
function ns.GetItemConfigNameItemId(key)
	if type(key) == "number" then
		return key
	end
	return ns.COLLECTION_NAME_ITEM_ID[key]
end

-- The client's name, or the Loading placeholder while the item is uncached; never a stored or translated name.
function ns.GetItemConfigName(key)
	local itemId = ns.GetItemConfigNameItemId(key)
	if not itemId then
		return nil
	end
	local name = C_Item.GetItemInfo(itemId)
	if name then
		return name
	end
	C_Item.RequestLoadItemDataByID(itemId)
	return format(L["ITEM_LOADING"], itemId)
end

function ns.GetItemConfigIcon(key)
	local meta = ns.COLLECTION_META[key]
	if meta then
		return meta.Icon
	end
	if type(key) ~= "number" then
		return nil
	end
	local _, _, _, _, icon = C_Item.GetItemInfoInstant(key)
	return icon
end

--------------------------------------------------------------------------------
-- Collection Metadata Refresh
--------------------------------------------------------------------------------

--[[
	Built-in collections can never be removed, so the flag is re-stamped after the
	database exists and on every profile switch. Reading ns.db.profile.Items[key]
	materializes the built-in default when a profile doesn't yet carry it, which is
	what puts the three collections in front of FillTrade's pairs() walk.
]]
function ns.RefreshCollectionMeta()
	if not ns.db then
		return
	end
	local items = ns.db.profile.Items
	for key in pairs(ns.COLLECTION_META) do
		local item = items[key]
		if item then
			item.NoRemove = true
		end
	end
end
