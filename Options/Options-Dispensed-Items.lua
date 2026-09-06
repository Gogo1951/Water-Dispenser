local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor
local CLASS_COLORS = ns.CLASS_COLORS

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local Header = ns.OptionsHeader
local Desc = ns.OptionsDesc
local Spacer = ns.OptionsSpacer

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local selectedItemToAdd

--------------------------------------------------------------------------------
-- Class Ordering (alphabetical by localized name)
--------------------------------------------------------------------------------

-- Classes sorted alphabetically by localized name so the grid rows read naturally top-to-bottom.
local function GetSortedClasses()
	local list = {}
	for _, class in ipairs(ns.CLASSES) do
		table.insert(list, class)
	end
	table.sort(list, function(a, b)
		return ns.GetClassName(a) < ns.GetClassName(b)
	end)
	return list
end

--------------------------------------------------------------------------------
-- Item Key Encoding
--------------------------------------------------------------------------------

--[[
	AceConfig arg keys must be strings. Built-in keys already are; user items are
	keyed by numeric ID in the DB, so prefix them "item_" and strip it back off.
]]

local function EncodeItemKey(dbKey)
	if type(dbKey) == "number" then
		return "item_" .. tostring(dbKey)
	end
	return dbKey
end

local function DecodeItemKey(argKey)
	local numericId = type(argKey) == "string" and argKey:match("^item_(%d+)$")
	if numericId then
		return tonumber(numericId)
	end
	return argKey
end

--------------------------------------------------------------------------------
-- Display Helpers
--------------------------------------------------------------------------------

local function ItemDisplayName(itemId, itemConfig)
	local icon = ns.GetItemConfigIcon(itemId, itemConfig)
	local name = ns.GetItemConfigName(itemId, itemConfig)
	if not name then
		local itemName, _, _, _, _, _, _, _, _, itemIcon = ns.GetItemInfo(itemId)
		name = itemName or tostring(itemId)
		icon = icon or itemIcon
	end
	local iconTag = icon and ("|T" .. icon .. ":16|t ") or ""
	return iconTag .. name
end

local function ClassLabel(class)
	local color = CLASS_COLORS[class] or "FFFFFF"
	return "|cff" .. color .. ns.GetClassName(class) .. "|r"
end

-- Fresh table with every class token set to true: a new item dispenses on every class until told otherwise.
local function AllClassesEnabled()
	local classes = {}
	for _, class in ipairs(ns.CLASSES) do
		classes[class] = true
	end
	return classes
end

-- Fresh per-class count table, all zero. One per scope, never shared, or all three scopes would write to one table.
local function ZeroCounts()
	local counts = {}
	for _, class in ipairs(ns.CLASSES) do
		counts[class] = 0
	end
	return counts
end

--------------------------------------------------------------------------------
-- Item Config Accessors
--------------------------------------------------------------------------------

--[[
	Args nest as [itemKey] -> [scopeKey] -> [classField]. In the info path,
	info[1] is the item key, info[2] the scope ("solo"/"group"/"raid"), and
	info[#info] the class token.
]]
local function GetItemConfig(info)
	local itemKey = DecodeItemKey(info[1])
	return ns.db.profile.Items[itemKey]
end

--[[
	Any change to how much of an item goes out clears what has already been credited
	for it this session, so the new number is measured from now. Leaving the old
	credit in place makes a raised limit look ignored until the next reload.
]]
local function AmountChanged(itemKey)
	if itemKey ~= nil and ns.ResetSessionLedger then
		ns.ResetSessionLedger(itemKey)
	end
	ns.RefreshGiveaways()
end

local distributeValues, distributeSorting
local function DistributeChoices()
	if not distributeValues then
		distributeValues, distributeSorting = {}, {}
		for index, mode in ipairs(ns.DISTRIBUTE_MODES) do
			distributeValues[mode] = L["OPTIONS_ITEM_DISTRIBUTE_" .. mode:upper()]
			distributeSorting[index] = mode
		end
	end
	return distributeValues, distributeSorting
end

local function GetDistribute(info)
	local config = GetItemConfig(info)
	-- No stored value is no gate: the item is handed out whenever anything else allows it.
	return (config and config.Distribute) or "Always"
end

local function SetDistribute(info, value)
	local config = GetItemConfig(info)
	if config then
		config.Distribute = value
	end
	-- The macro and the group's tooltips both hide a gated item, so both need telling.
	ns.RefreshGiveaways()
end

local function GetFactorLevel(info)
	local config = GetItemConfig(info)
	return config and config.FactorLevel or false
end

local function SetFactorLevel(info, value)
	local config = GetItemConfig(info)
	if config then
		config.FactorLevel = value and true or false
	end
end

local function GetIncludeQuantity(info)
	return ns.GetItemIncludeQuantity(GetItemConfig(info))
end

local function SetIncludeQuantity(info, value)
	local config = GetItemConfig(info)
	if config then
		config.IncludeQuantity = value and true or false
	end
	-- Live-update the announcement macro so the change shows without a bag event.
	ns.RefreshGiveaways()
end

-- Player-class filter accessors; info[#info] is the class token.
local function GetPlayerClass(info)
	local config = GetItemConfig(info)
	if not config or not config.PlayerClasses then
		return false
	end
	return config.PlayerClasses[info[#info]] == true
end

local function SetPlayerClass(info, value)
	local config = GetItemConfig(info)
	if not config then
		return
	end
	config.PlayerClasses = config.PlayerClasses or {}
	--[[
		Store explicit false, never nil: AceDB re-supplies a missing key from the
		built-in default (e.g. MageWater's MAGE = true), so an unchecked class must
		be a concrete false or it would reappear on the next login.
	]]
	config.PlayerClasses[info[#info]] = value and true or false
	ns.RefreshGiveaways()
end

--------------------------------------------------------------------------------
-- Scope Table
--------------------------------------------------------------------------------

--[[
	The three scopes read as a table: a class per row, a scope per column. AceConfig
	has no grid, so the columns are held by giving every cell a fixed width and
	pinning each row in its own unnamed inline group. Laid out flat the cells would
	pack onto whatever space is left on the line and the columns would drift apart.

	Widths total less than ns.OPTIONS_ROW_WIDTH on purpose: a row sitting exactly on
	the wrap boundary tips its last cell onto a line of its own.
]]
local TABLE_CLASS_WIDTH = 0.75
local TABLE_SCOPE_WIDTH = 0.55

-- Column order, left to right. Key is the scope's saved-variable field.
local SCOPE_COLUMNS = {
	{ Key = "Solo", LabelKey = "OPTIONS_SCOPE_SOLO" },
	{ Key = "Group", LabelKey = "OPTIONS_SCOPE_GROUP" },
	{ Key = "Raid", LabelKey = "OPTIONS_SCOPE_RAID" },
}

local function TableRow(order, cells)
	local args = {}
	for index, cell in ipairs(cells) do
		cell.order = index
		args["cell" .. index] = cell
	end

	return {
		type = "group",
		name = "",
		inline = true,
		order = order,
		args = args,
	}
end

--[[
	One cell. The item, scope and class are closed over rather than read back out of
	the info path: inside the row's inline group the path ends at the group's own arg
	key, so it no longer carries either of them.
]]
local function CountCell(itemKey, scopeKey, class, maxCount)
	return {
		type = "input",
		name = "",
		dialogControl = ns.NUMBER_BOX_WIDGET_TYPE,
		width = TABLE_SCOPE_WIDTH,
		validate = function(_, value)
			return ns.OptionsValidateCount(value, maxCount)
		end,
		get = function()
			local config = ns.db.profile.Items[itemKey]
			return tostring((config and config[scopeKey] and config[scopeKey][class]) or 0)
		end,
		set = function(_, value)
			local config = ns.db.profile.Items[itemKey]
			if not config then
				return
			end
			config[scopeKey] = config[scopeKey] or {}
			config[scopeKey][class] = ns.OptionsParseCount(value, maxCount) or 0
			AmountChanged(itemKey)
		end,
	}
end

--[[
	The reserve and the session cap are the same shape: a toggle that arms the
	feature and the amount it applies. One builder for both, so the two rows cannot
	drift apart, and the amount survives being switched off and comes back as the
	player left it.

	The number box is greyed rather than hidden when its toggle is off: hiding it
	would reflow every row below it each time a toggle is clicked.
]]
local AMOUNT_TOGGLE_WIDTH = 1.8
local AMOUNT_VALUE_WIDTH = 0.6

local function AmountRow(order, enabledField, amountField, nameKey, descKey)
	local function IsArmed(info)
		local config = GetItemConfig(info)
		return (config and config[enabledField]) and true or false
	end

	local function Refresh(info)
		--[[
			Live-update the announcement macro so the change shows without a bag event,
			and forget credited giving when the limit it is measured against moves.
		]]
		if amountField == "SessionCap" then
			AmountChanged(DecodeItemKey(info[1]))
		else
			ns.RefreshGiveaways()
		end
	end

	return TableRow(order, {
		{
			type = "toggle",
			name = L[nameKey],
			desc = L[descKey],
			width = AMOUNT_TOGGLE_WIDTH,
			get = IsArmed,
			set = function(info, value)
				local config = GetItemConfig(info)
				if config then
					config[enabledField] = value and true or false
					if value then
						-- Arming a reset profile would otherwise show a 0 it never saved.
						config[amountField] = ns.OptionsParseCount(config[amountField]) or 1
					end
				end
				Refresh(info)
			end,
		},
		{
			type = "input",
			name = "",
			desc = L[descKey],
			dialogControl = ns.NUMBER_BOX_WIDGET_TYPE,
			width = AMOUNT_VALUE_WIDTH,
			disabled = function(info)
				return not IsArmed(info)
			end,
			validate = function(_, value)
				return ns.OptionsValidateCount(value)
			end,
			get = function(info)
				local config = GetItemConfig(info)
				return tostring(ns.OptionsParseCount(config and config[amountField]) or 0)
			end,
			set = function(info, value)
				local config = GetItemConfig(info)
				if config then
					config[amountField] = ns.OptionsParseCount(value) or 0
				end
				Refresh(info)
			end,
		},
	})
end

--[[
	The table's args, for the item group's own page. maxCount caps every box
	(1 for unique items, uncapped otherwise).

	The grid reads as numbers with no units until something says what they are, so
	it opens with its own header and a sentence naming both axes, matching the Item
	Settings header further down the page.
]]
--[[
	The Everyone row writes straight through to every class, never staging values for
	a button to pick up later. AceConfigDialog commits an input on OnEnterPressed and
	nothing else, so text the player typed but did not Enter is invisible to us: a
	button gathering the three boxes on click would see only whichever ones happened
	to be committed, filling one column and silently leaving the other two. Each box
	does its own work in its own set, and the only button involved is the one inside
	the box, which is what commits it.
]]

-- The value every class shares in this column, or nil when they differ.
local function CommonScopeValue(config, scopeKey)
	local counts = config and config[scopeKey]
	if not counts then
		return nil
	end
	local shared
	for _, class in ipairs(ns.CLASSES) do
		local value = counts[class] or 0
		if shared == nil then
			shared = value
		elseif shared ~= value then
			return nil
		end
	end
	return shared
end

local function ApplyToEveryClass(itemKey, scopeKey, count)
	local config = ns.db.profile.Items[itemKey]
	if not config or not count then
		return false
	end
	config[scopeKey] = config[scopeKey] or {}
	for _, class in ipairs(ns.CLASSES) do
		config[scopeKey][class] = count
	end
	AmountChanged(itemKey)
	return true
end

local function RefreshItemPanel()
	ns.RefreshGiveaways()
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.DispensedItems)
end

--[[
	One Everyone box. Shows what the column already agrees on, blank when the
	classes differ, and on commit sets all nine of them.
]]
local function EveryoneCell(itemKey, scopeKey, maxCount)
	return {
		type = "input",
		name = "",
		desc = L["OPTIONS_ITEM_EVERYONE_DESC"],
		dialogControl = ns.NUMBER_BOX_WIDGET_TYPE,
		width = TABLE_SCOPE_WIDTH,
		validate = function(_, value)
			return ns.OptionsValidateCount(value, maxCount)
		end,
		get = function()
			local shared = CommonScopeValue(ns.db.profile.Items[itemKey], scopeKey)
			return shared and tostring(shared) or ""
		end,
		set = function(_, value)
			if ApplyToEveryClass(itemKey, scopeKey, ns.OptionsParseCount(value, maxCount)) then
				RefreshItemPanel()
			end
		end,
	}
end

local function BuildScopeTable(itemKey, maxCount)
	local args = {
		headerDistribution = Header(L["OPTIONS_ITEM_DISTRIBUTION"], 1),
		spaceDistribution0 = Spacer(2),
		descDistribution = Desc(L["OPTIONS_ITEM_DISTRIBUTION_DESC"], 3),
		spaceDistribution1 = Spacer(4),
	}

	-- Column headings sit over a blank cell the width of the class column.
	local heading = { ns.OptionsRowLabel(" ", nil, TABLE_CLASS_WIDTH) }
	for _, column in ipairs(SCOPE_COLUMNS) do
		heading[#heading + 1] =
			ns.OptionsRowLabel(GetColor("TITLE") .. L[column.LabelKey] .. "|r", nil, TABLE_SCOPE_WIDTH)
	end
	args.headings = TableRow(5, heading)

	--[[
		Everyone sits directly under the headings, above the classes it writes to, and
		its boxes line up with the grid's columns. No apply button of its own: each box
		carries AceGUI's own one, which is the thing that commits it.
	]]
	local everyone =
		{ ns.OptionsRowLabel(GetColor("TITLE") .. L["OPTIONS_ITEM_EVERYONE"] .. "|r", nil, TABLE_CLASS_WIDTH) }
	for _, column in ipairs(SCOPE_COLUMNS) do
		everyone[#everyone + 1] = EveryoneCell(itemKey, column.Key, maxCount)
	end
	args.rowEveryone = TableRow(6, everyone)
	-- Sets Everyone apart from the classes it writes to, rather than reading as the first of them.
	args.spaceEveryone = Spacer(7)

	for index, class in ipairs(GetSortedClasses()) do
		local cells = { ns.OptionsRowLabel(ClassLabel(class), nil, TABLE_CLASS_WIDTH) }
		for _, column in ipairs(SCOPE_COLUMNS) do
			cells[#cells + 1] = CountCell(itemKey, column.Key, class, maxCount)
		end
		args["row" .. class] = TableRow(index + 7, cells)
	end

	--[[
		The personal reserve decides what actually leaves your bags, so it belongs with
		the counts above rather than under Item Settings, which is where the item is
		described rather than dispensed.
	]]
	args.spaceAmounts = Spacer(17)
	args.rowSessionCap =
		AmountRow(18, "SessionCapEnabled", "SessionCap", "OPTIONS_ITEM_SESSION_CAP", "OPTIONS_ITEM_SESSION_CAP_DESC")
	args.spaceReserve = Spacer(19)
	args.rowReserve =
		AmountRow(20, "KeepAtLeastEnabled", "KeepAtLeast", "OPTIONS_ITEM_RESERVE", "OPTIONS_ITEM_RESERVE_DESC")

	return args
end

--------------------------------------------------------------------------------
-- Per-Item Settings
--------------------------------------------------------------------------------

--[[
	What is left once the dispensing rules move up with the table: how the item is
	described and who dispenses it. Written straight onto the item's own page rather
	than into a child node, so no item draws an expand toggle and the sidebar stays
	a flat list.

	Orders start above the table's rows. The info path still opens with the item's
	arg key, so the shared GetItemConfig accessors are unaffected by the move.
]]
local function AddItemSettings(args, itemKey, itemConfig)
	--[[
		Built-in collections always dispense the best rank the partner can use, so the
		level toggle only applies to single-rank user-added items.
	]]
	local isBuiltIn = ns.COLLECTION_META[itemKey] ~= nil

	args.spaceSettings0 = Spacer(30)
	args.headerSettings = Header(L["OPTIONS_ITEM_SETTINGS"], 31)
	args.spaceSettings1 = Spacer(32)

	--[[
		First, because it decides whether any of the rest applies: an item gated to
		raids is not dispensed, announced or shown on a tooltip outside one, whatever
		its per-class amounts say.
	]]
	local distributeChoices, distributeOrder = DistributeChoices()
	--[[
		A caption beside a dropdown on one line, spending the shared grid's own two
		widths rather than a pair of its own, so this dropdown starts in the same
		column as every other dropdown in the add-on and the row ends where every
		other row ends.
	]]
	args.rowDistribute = TableRow(33, {
		ns.OptionsRowLabel(GetColor("TITLE") .. L["OPTIONS_ITEM_DISTRIBUTE"] .. "|r", nil, ns.OPTIONS_LABEL_WIDTH),
		{
			type = "select",
			name = "",
			desc = L["OPTIONS_ITEM_DISTRIBUTE_DESC"],
			width = ns.OPTIONS_CONTROL_WIDTH,
			values = distributeChoices,
			sorting = distributeOrder,
			get = GetDistribute,
			set = SetDistribute,
		},
	})
	args.spaceDistribute = Spacer(34)

	args.FactorLevel = {
		type = "toggle",
		width = "full",
		name = L["OPTIONS_ITEM_FACTOR_LEVEL"],
		desc = L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"],
		order = 35,
		hidden = isBuiltIn,
		get = GetFactorLevel,
		set = SetFactorLevel,
	}

	--[[
		Hides with the toggle above it. ns.OptionsSpacer takes no `hidden`, so a gated
		spacer is inlined: left showing on a built-in collection it would be the only
		thing between the header and the next toggle.
	]]
	args.spaceFactorLevel = { type = "description", name = " ", order = 36, hidden = isBuiltIn }

	args.IncludeQuantity = {
		type = "toggle",
		width = "full",
		name = L["OPTIONS_ITEM_INCLUDE_QUANTITY"],
		desc = L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"],
		order = 37,
		get = GetIncludeQuantity,
		set = SetIncludeQuantity,
	}

	args.spaceClasses0 = Spacer(38)
	args.descClasses = Desc(L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"], 39)
	args.spaceClasses1 = Spacer(40)

	local classArgs = {}
	for index, class in ipairs(GetSortedClasses()) do
		classArgs[class] = {
			type = "toggle",
			name = ClassLabel(class),
			order = index,
			get = GetPlayerClass,
			set = SetPlayerClass,
		}
	end
	args.playerClasses = {
		type = "group",
		name = L["OPTIONS_ITEM_PLAYER_CLASSES"],
		inline = true,
		order = 41,
		args = classArgs,
	}

	-- Built-in collections can't be removed (NoRemove), so they carry no button.
	if not itemConfig.NoRemove then
		args.spaceRemove = Spacer(42)
		args.remove = {
			type = "execute",
			name = L["OPTIONS_ITEM_REMOVE"],
			order = 43,
			confirm = true,
			confirmText = L["OPTIONS_ITEM_REMOVE_CONFIRM"],
			func = function()
				-- No print: the item vanishing from the sidebar is the confirmation.
				ns.db.profile.Items[itemKey] = nil
				ns.RebuildDispensedItemsOptions()
				ns.RefreshGiveaways()
			end,
		}
	end
end

--------------------------------------------------------------------------------
-- Item Panel Builder
--------------------------------------------------------------------------------

--[[
	Each item is one flat page in the sidebar: its scope table, then its settings.
	A tree node's own non-group args are fed into the content pane, and nothing is
	nested underneath, so an item draws no expand toggle.
]]
local function BuildItemPanel(itemKey, itemConfig, order)
	-- Unique items (healthstones) trade 0 or 1, so their boxes cap at 1.
	local meta = ns.COLLECTION_META[itemKey]
	local maxCount = (meta and meta.Unique) and 1 or nil

	local args = BuildScopeTable(itemKey, maxCount)
	AddItemSettings(args, itemKey, itemConfig)

	return {
		type = "group",
		name = ItemDisplayName(itemKey, itemConfig),
		order = order,
		args = args,
	}
end

--------------------------------------------------------------------------------
-- Add Item Panel
--------------------------------------------------------------------------------

local function BuildAddableValues()
	local values = {}
	for _, entry in ipairs(ns.GetAvailableItemsToAdd()) do
		local icon = entry.Icon and ("|T" .. entry.Icon .. ":16|t ") or ""
		values[tostring(entry.Id)] = icon .. entry.Name
	end
	return values
end

--[[
	The order the picker lists in. A select carrying no `sorting` reaches AceGUI
	unordered, and AceGUI orders the keys itself, reading a numeric-looking key as
	a number -- so item-ID keys list the dropdown by item ID, which is no order at
	all to someone hunting for a name. ns.GetAvailableItemsToAdd already sorts by
	name, so listing its walk order is the alphabetical order.
]]
local function BuildAddableSorting()
	local sorting = {}
	for _, entry in ipairs(ns.GetAvailableItemsToAdd()) do
		sorting[#sorting + 1] = tostring(entry.Id)
	end
	return sorting
end

local function HasAddableItems()
	return next(BuildAddableValues()) ~= nil
end

local function NoAddableItems()
	return not HasAddableItems()
end

local function BuildAddItemPanel(order)
	-- The picker is hidden when nothing qualifies, showing the empty notice instead. Spacers are inlined here because Spacer() has no `hidden`.
	return {
		type = "group",
		name = L["OPTIONS_ADD_ITEM"],
		order = order,
		args = {
			desc = Desc(L["OPTIONS_ADD_DESC"], 1),
			spaceSelect = { type = "description", name = " ", order = 2, hidden = NoAddableItems },
			selectItemLabel = ns.OptionsRowLabel(L["OPTIONS_ADD_SELECT"], 3, nil, NoAddableItems),
			selectItem = {
				type = "select",
				style = "dropdown",
				name = "",
				width = ns.OPTIONS_CONTROL_WIDTH,
				order = 4,
				values = BuildAddableValues,
				sorting = BuildAddableSorting,
				hidden = NoAddableItems,
				get = function()
					return selectedItemToAdd
				end,
				set = function(_, value)
					selectedItemToAdd = value
				end,
			},
			spaceAdd = { type = "description", name = " ", order = 5, hidden = NoAddableItems },
			addButton = {
				type = "execute",
				name = L["OPTIONS_ADD_BUTTON"],
				order = 6,
				hidden = NoAddableItems,
				disabled = function()
					return not selectedItemToAdd
				end,
				func = function()
					local id = tonumber(selectedItemToAdd)
					if not id then
						return
					end

					local itemName, _, _, _, _, _, _, _, _, itemIcon = ns.GetItemInfo(id)
					ns.db.profile.Items[id] = {
						Name = itemName or ("Item " .. id),
						Icon = itemIcon,
						Distribute = "Always",
						FactorLevel = false,
						KeepAtLeastEnabled = false,
						KeepAtLeast = 1,
						SessionCapEnabled = false,
						SessionCap = 2,
						IncludeQuantity = true,
						PlayerClasses = AllClassesEnabled(),
						Solo = ZeroCounts(),
						Group = ZeroCounts(),
						Raid = ZeroCounts(),
					}
					-- No print: the item appearing in the sidebar is the confirmation, as with remove.
					selectedItemToAdd = nil
					ns.RebuildDispensedItemsOptions()
					ns.RefreshGiveaways()
				end,
			},
			spaceEmpty = { type = "description", name = " ", order = 7, hidden = HasAddableItems },
			emptyNotice = {
				type = "description",
				fontSize = "medium",
				order = 8,
				name = GetColor("BODY") .. L["OPTIONS_ADD_EMPTY"] .. "|r",
				hidden = HasAddableItems,
			},
		},
	}
end

--------------------------------------------------------------------------------
-- Root Items Options Table
--------------------------------------------------------------------------------

local function BuildItemList()
	local list = {}

	-- Built-in collections first, in stable display order.
	for _, key in ipairs(ns.BUILTIN_ORDER) do
		if ns.db.profile.Items[key] then
			table.insert(list, {
				ArgKey = EncodeItemKey(key),
				DBKey = key,
				Config = ns.db.profile.Items[key],
				IsBuiltin = true,
			})
		end
	end

	-- Then user-added items, sorted by name.
	local custom = {}
	for key, config in pairs(ns.db.profile.Items) do
		if not ns.COLLECTION_META[key] then
			table.insert(custom, {
				ArgKey = EncodeItemKey(key),
				DBKey = key,
				Config = config,
			})
		end
	end
	table.sort(custom, function(a, b)
		return (ns.GetItemConfigName(a.DBKey, a.Config) or "") < (ns.GetItemConfigName(b.DBKey, b.Config) or "")
	end)
	for _, entry in ipairs(custom) do
		table.insert(list, entry)
	end

	return list
end

--[[
	A blank row between items in the sidebar. AceGUI stacks tree lines at a fixed
	height with no spacing property and clamps each line's text to one row, so an
	entry of its own is the only way to put air between them. `disabled` greys the
	line and turns its mouse off, so it can never be hovered, clicked or selected,
	and with no args it draws no expand toggle.
]]
local function TreeSpacer(order)
	return {
		type = "group",
		name = " ",
		order = order,
		disabled = true,
		args = {},
	}
end

function ns.BuildDispensedItemsOptions()
	local args = {
		intro = Desc(L["OPTIONS_ITEMS_DESC"], 1),
		introSpacer = Spacer(2),
	}

	local list = BuildItemList()

	if #list == 0 then
		args.emptyNotice = Desc(GetColor("BODY") .. L["OPTIONS_ITEMS_EMPTY"] .. "|r", 3)
	end

	local order = 10
	for index, entry in ipairs(list) do
		if index > 1 then
			args["spacer" .. index] = TreeSpacer(order)
			order = order + 1
		end
		args[entry.ArgKey] = BuildItemPanel(entry.DBKey, entry.Config, order)
		order = order + 1
	end

	args.spacerAddItem = TreeSpacer(order)
	args.addItem = BuildAddItemPanel(order + 1)

	return {
		type = "group",
		name = L["TAB_DISPENSED_ITEMS"],
		childGroups = "tree",
		args = args,
	}
end

--------------------------------------------------------------------------------
-- Rebuild Hook
--------------------------------------------------------------------------------

--[[
	Re-register the (rebuilt) item tree and repaint it in place. Called after an
	item is added or removed and on a profile switch. The registry name is the
	stable ns.OPTIONS_REGISTRY constant, so no stored appName is needed.
]]
function ns.RebuildDispensedItemsOptions()
	local appName = ns.OPTIONS_REGISTRY.DispensedItems
	AceConfig:RegisterOptionsTable(appName, ns.BuildDispensedItemsOptions())
	AceConfigRegistry:NotifyChange(appName)
end
