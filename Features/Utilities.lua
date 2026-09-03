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
	Two ways to ask for a split, because on Classic Era 1.15.9 the C_Container one
	has been seen handing back the whole stack instead of the count it was given.
	Some legacy container globals do survive on that client -- the diagnostics probe
	reports which -- so the older entry point is kept as a second attempt.

	Nothing verifies that either call honored the count, because nothing can. Trying
	both is safe for a different reason: the legacy call is made only when the first
	attempt left the cursor empty, so the two can never both land, and the portion
	goes into a bag rather than a trade slot -- a client that hands back the whole
	stack has only moved a stack between bag slots, and FillTrade's whole-slot rule
	places nothing larger than what is still owed.
]]
ns.SplitContainerItem = C_Container and C_Container.SplitContainerItem
ns.SplitContainerItemLegacy = type(SplitContainerItem) == "function" and SplitContainerItem or nil

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
	Whether an item may go out at all right now, judged on the group the *player* is
	in rather than on the trade partner.

	  Always  never gates, and is what an item with no value stored falls back to.
	  Group   any group, party or raid -- grouped at all.
	  Raid    a raid and nothing else, for things only worth handing out there.

	Group deliberately includes raids: a raid is a group, and an item worth sharing
	with a party is worth sharing with twenty people. Raid is the narrow one.

	The same answer gates the fill, the player tooltip and the announcement macro,
	so an item that cannot be given right now is never advertised either.
]]
function ns.IsItemDistributableNow(itemConfig)
	local mode = itemConfig and itemConfig.Distribute
	if mode == "Raid" then
		return IsInRaid() and true or false
	end
	if mode == "Group" then
		return IsInGroup() and true or false
	end
	return true
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
