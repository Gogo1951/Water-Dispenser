local _, ns = ...

local L = ns.L

--------------------------------------------------------------------------------
-- API Compatibility
--------------------------------------------------------------------------------

-- Resolved once. GetItemInfo keeps its legacy global fallback, which still works on both Era and TBC.
ns.GetItemInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo

-- No legacy fallback: the bag-API globals are gone on both target clients (Era 1.15.8, TBC 2.5.5), so call C_Container directly.
ns.GetContainerNumSlots = C_Container and C_Container.GetContainerNumSlots
ns.PickupContainerItem = C_Container and C_Container.PickupContainerItem
ns.GetContainerItemInfo = C_Container and C_Container.GetContainerItemInfo
--[[
	Nothing verifies that the split honored the count, because nothing can. That is
	why the portion goes into a bag slot rather than straight into a trade slot: a
	client that hands back the whole stack has only moved a stack between bag slots,
	and FillTrade's whole-slot rule places nothing larger than what is still owed.
]]
ns.SplitContainerItem = C_Container and C_Container.SplitContainerItem

--------------------------------------------------------------------------------
-- Combat Guard
--------------------------------------------------------------------------------

function ns.IsInCombat()
	return InCombatLockdown()
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

--------------------------------------------------------------------------------
-- Item Presentation
--------------------------------------------------------------------------------

--[[
	A built-in collection's name and icon come from code every time they are read,
	never from the saved config: the player's file has no business carrying a
	translated string, and a renamed or re-iconed collection has to follow the
	add-on rather than whatever was stamped in at some past login. User-added items
	have no code entry, so theirs are the stored ones.
]]
function ns.GetItemConfigName(key, itemConfig)
	local meta = ns.COLLECTION_META[key]
	if meta then
		return L[meta.NameKey]
	end
	return itemConfig and itemConfig.Name
end

function ns.GetItemConfigIcon(key, itemConfig)
	local meta = ns.COLLECTION_META[key]
	if meta then
		return meta.Icon
	end
	return itemConfig and itemConfig.Icon
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
