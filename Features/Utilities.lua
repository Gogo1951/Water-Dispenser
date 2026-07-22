local _, ns = ...

local L = ns.L

--------------------------------------------------------------------------------
-- API Compatibility
--------------------------------------------------------------------------------

-- Consumable item class, resolved once. LE_ITEM_CLASS_CONSUMABLE is nil on Era 1.15.8 / TBC 2.5.5, so Enum.ItemClass is primary.
ns.CONSUMABLE_ITEM_CLASS = (Enum and Enum.ItemClass and Enum.ItemClass.Consumable) or LE_ITEM_CLASS_CONSUMABLE or 0

-- IsSpellKnown misses some trained ranks on Classic Era; IsPlayerSpell is the fallback, either true counts as known.
function ns.IsSpellLearned(spellId)
	if IsSpellKnown and IsSpellKnown(spellId) then
		return true
	end
	if IsPlayerSpell and IsPlayerSpell(spellId) then
		return true
	end
	return false
end

-- Resolved once. GetItemInfo keeps its legacy global fallback, which still works on both Era and TBC.
ns.GetItemInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo

-- No legacy fallback: the bag-API globals are gone on both target clients (Era 1.15.8, TBC 2.5.5), so call C_Container directly.
ns.GetContainerNumSlots = C_Container and C_Container.GetContainerNumSlots
ns.PickupContainerItem = C_Container and C_Container.PickupContainerItem
ns.GetContainerItemInfo = C_Container and C_Container.GetContainerItemInfo

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
	ITEM_LEVEL drive best-tier selection and partner-level filtering.
]]
ns.ITEM_TO_COLLECTION = {}
ns.SPELL_TO_COLLECTION = {}
ns.ITEM_RANK = {}
ns.ITEM_LEVEL = {}
for key, c in pairs(ns.COLLECTIONS) do
	for itemId, meta in pairs(c.Items) do
		ns.ITEM_TO_COLLECTION[itemId] = key
		ns.ITEM_RANK[itemId] = meta[1]
		ns.ITEM_LEVEL[itemId] = meta[2]
	end
	for spellId in pairs(c.Spells) do
		ns.SPELL_TO_COLLECTION[spellId] = key
	end
end

--------------------------------------------------------------------------------
-- Class Name Helpers
--------------------------------------------------------------------------------

function ns.GetClassName(class)
	local names = LOCALIZED_CLASS_NAMES_MALE
	return (names and names[class]) or class
end

-- Fresh table with every class token set to true (the default for new items).
function ns.AllClassesEnabled()
	local t = {}
	for _, class in ipairs(ns.CLASSES) do
		t[class] = true
	end
	return t
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
-- Table Utilities
--------------------------------------------------------------------------------

local function DeepCopy(value)
	if type(value) ~= "table" then
		return value
	end
	local out = {}
	for k, v in pairs(value) do
		out[k] = DeepCopy(v)
	end
	return out
end
ns.DeepCopy = DeepCopy

--------------------------------------------------------------------------------
-- Legacy Saved-Variable Migrations
--------------------------------------------------------------------------------

--[[
	MIGRATION (remove after 2026-10-12): legacy two-scope -> AceDB seed. These
	steps upgrade a pre-AceDB WaterDispenserCharDB to the current schema so its
	values fold into the AceDB profile on first login. This block, plus
	ns.RunLegacyMigrations and its caller in Core.lua, is deleted when the window
	closes.
]]

--[[
	v4 (item counts) -> v5 (stack counts): divide each class count by the item's
	max stack size (item counts can't work -- Classic Era's SplitContainerItem
	won't pick up partial stacks from an addon). Stack size falls back to 20 when
	the cache is cold.
]]
local function MigrateToStacks(db)
	if (db.Version or 0) >= 5 then
		return
	end
	if (db.Version or 0) < 4 then
		-- v3 configs already stored stack counts; just bump the version.
		db.Version = 5
		return
	end

	local function StackSizeFor(dbKey)
		if dbKey == "WarlockHealthstone" then
			return 1
		end
		if dbKey == "MageWater" or dbKey == "MageFood" then
			return 20
		end
		if type(dbKey) == "number" then
			local _, _, _, _, _, _, _, maxStack = ns.GetItemInfo(dbKey)
			return maxStack or 20
		end
		return 20
	end

	for dbKey, itemConfig in pairs(db.Items or {}) do
		local stackSize = StackSizeFor(dbKey)
		if stackSize > 1 then
			for _, scope in ipairs({ "Solo", "Group", "Raid" }) do
				local scopeTable = itemConfig[scope]
				if type(scopeTable) == "table" then
					for class, count in pairs(scopeTable) do
						if type(count) == "number" and count > 0 then
							scopeTable[class] = math.floor(count / stackSize + 0.5)
						end
					end
				end
			end
		end
		itemConfig.UseNotFullStack = itemConfig.UseNotFullStack or false
	end

	db.Version = 5
end

-- v5 -> v6: add per-item FactorLevel (off) and KeepAtLeast (0) to existing items.
local function MigrateAddPerItemRules(db)
	if (db.Version or 0) >= 6 then
		return
	end
	for _, itemConfig in pairs(db.Items or {}) do
		if itemConfig.FactorLevel == nil then
			itemConfig.FactorLevel = false
		end
		if itemConfig.KeepAtLeast == nil then
			itemConfig.KeepAtLeast = 0
		end
	end
	db.Version = 6
end

-- v6 -> v7: add per-item IncludeQuantity, true for all but healthstones (which read better without a count).
local function MigrateAddIncludeQuantity(db)
	if (db.Version or 0) >= 7 then
		return
	end
	for key, itemConfig in pairs(db.Items or {}) do
		if itemConfig.IncludeQuantity == nil then
			itemConfig.IncludeQuantity = (key ~= "WarlockHealthstone")
		end
	end
	db.Version = 7
end

-- v7 -> v8: add PlayerClasses (all classes) to user-added items; built-ins get theirs from ns.DATABASE_DEFAULTS.
local function MigrateAddPlayerClasses(db)
	if (db.Version or 0) >= 8 then
		return
	end
	for key, itemConfig in pairs(db.Items or {}) do
		if itemConfig.PlayerClasses == nil and not ns.COLLECTION_META[key] then
			itemConfig.PlayerClasses = ns.AllClassesEnabled()
		end
	end
	db.Version = 8
end

-- v8 -> v9: enable UseNotFullStack for MageWater and MageFood (small stacks at low rank).
local function MigrateConjuredPartialStacks(db)
	if (db.Version or 0) >= 9 then
		return
	end
	for _, key in ipairs({ "MageWater", "MageFood" }) do
		local itemConfig = db.Items and db.Items[key]
		if itemConfig then
			itemConfig.UseNotFullStack = true
		end
	end
	db.Version = 9
end

-- v9 -> v10: rename the AutoFill* toggles to Dispense*, carrying each character's choice across.
local function MigrateRenameDispenseFields(db)
	if (db.Version or 0) >= 10 then
		return
	end
	local renames = {
		AutoFill = "Dispense",
		AutoFillSolo = "DispenseSolo",
		AutoFillGroup = "DispenseGroup",
		AutoFillRaid = "DispenseRaid",
	}
	for oldKey, newKey in pairs(renames) do
		if db[newKey] == nil and db[oldKey] ~= nil then
			db[newKey] = db[oldKey]
		end
		db[oldKey] = nil
	end
	db.Version = 10
end

-- v10 -> v11: conjured water/food dispense as full stacks only now (the restack merges partials), so clear the v9 partial-stack flag.
local function MigrateConjuredFullStacksOnly(db)
	if (db.Version or 0) >= 11 then
		return
	end
	for _, key in ipairs({ "MageWater", "MageFood" }) do
		local itemConfig = db.Items and db.Items[key]
		if itemConfig then
			itemConfig.UseNotFullStack = false
		end
	end
	db.Version = 11
end

-- MIGRATION (remove after 2026-10-12): runs the v4 -> v11 chain on a legacy WaterDispenserCharDB so Core can fold the result into the profile.
function ns.RunLegacyMigrations(db)
	MigrateToStacks(db)
	MigrateAddPerItemRules(db)
	MigrateAddIncludeQuantity(db)
	MigrateAddPlayerClasses(db)
	MigrateConjuredPartialStacks(db)
	MigrateRenameDispenseFields(db)
	MigrateConjuredFullStacksOnly(db)
end

--------------------------------------------------------------------------------
-- Collection Metadata Refresh
--------------------------------------------------------------------------------

--[[
	Point each built-in collection's Name/Icon/NoRemove at code, not stored data,
	so a renamed or re-iconed collection follows the add-on. Run after the database
	exists and on every profile switch. Reading ns.db.profile.Items[key]
	materializes the built-in default when a profile doesn't yet carry it.
]]
function ns.RefreshCollectionMeta()
	if not ns.db then
		return
	end
	local items = ns.db.profile.Items
	for key, meta in pairs(ns.COLLECTION_META) do
		local item = items[key]
		if item then
			item.Name = L[meta.NameKey]
			item.Icon = meta.Icon
			item.NoRemove = true
		end
	end
end
