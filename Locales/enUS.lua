local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "enUS", true)
if not L then
	return
end

--------------------------------------------------------------------------------
-- Add-on Identity
--------------------------------------------------------------------------------

L["ADDON_TITLE"] = "Water Dispenser"

--------------------------------------------------------------------------------
-- Shared Formats
--------------------------------------------------------------------------------

-- %s is the item's name or link, %d how many of it. Used by the chat prints and the announcement macro.
L["FORMAT_ITEM_COUNT"] = "%s x%d"
-- Stands in for an item's name until the client has loaded it. %d is the item ID.
L["ITEM_LOADING"] = "Loading ID: %d"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

--[[
	All player-facing chat prints live here, regardless of which feature emits them.
	In CHAT_LOADED, %s is the add-on version and the menu path is the game client's
	own labels.
]]
L["CHAT_LOADED"] =
	"Version %s. Settings (including the option to disable this message) can be found under Options > AddOns > Water Dispenser. Enjoying the add-on? Tell a friend about it! (="
L["CHAT_NO_TRADE"] = "No active trade window."
L["CHAT_COMBAT_BLOCKED"] = "WoW blocks automated trades during combat."
L["CHAT_OPTIONS_IN_COMBAT"] = "As a safety precaution, the Options Interface cannot be opened during combat."
-- The item and its count are appended after the colon by the code.
L["CHAT_MISSING_STACK"] = "Missing:"
--[[
	%s is the item's name, then the trade partner's name; %d is the Maximum per
	Player they have reached.
]]
L["CHAT_PLAYER_CAP_REACHED"] =
	"%s not added: %s has already had %d from you. Counts start over when you log out or reload."
-- %s is the item's name; the first %d is the amount that could not be split off, the second the item's full stack size.
L["CHAT_SPLIT_NEEDS_FULL_STACK"] =
	"%s not added: the game wouldn't split %d off a stack. Set the amount to a full stack (%d) to hand it over."
-- %s is the player's class name. "Dispensed Items" must match TAB_DISPENSED_ITEMS.
L["CHAT_NONE_ACTIVE_FOR_CLASS"] =
	"No items are set to dispense while you're playing a %s. Open Options > AddOns > Water Dispenser > Dispensed Items to enable items for this class."
-- "- Dispenser" is the macro's literal name and is never translated.
L["CHAT_MACRO_DELETED"] = 'Announcement macro "- Dispenser" deleted.'
L["CHAT_MACRO_FULL"] = "Could not create the announcement macro: all character macro slots are in use."

--------------------------------------------------------------------------------
-- Player Tooltips
--------------------------------------------------------------------------------

L["TOOLTIP_OPEN_TRADE"] = "Open trade!"
-- %s is the Improved Healthstone talent's name from the client, then the warlock's rank out of its maximum.
L["TOOLTIP_HEALTHSTONE_TALENT"] = "%s %d/%d"

--------------------------------------------------------------------------------
-- Bag Item Tooltips
--------------------------------------------------------------------------------

-- Shown on a carried bag item the player has set up to give away.
L["TOOLTIP_WILL_DISPENSE"] = "Given out in trades."

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BUTTON_CLEAR"] = "Clear Trade Window"
L["BUTTON_FILL"] = "Fill Trade Window"

--[[
	The silver status line under the trade panel's buttons. "Fill Trade Window" must
	match BUTTON_FILL. ADDED's %s is the window's contents, each FORMAT_ITEM_COUNT,
	joined like the announcement's list. In the rest, %s is an item or collection
	name unless noted.
]]
L["TRADE_STATUS_ADDED"] = "Added %s."
-- %d is how many short.
L["TRADE_STATUS_SHORT"] = "Short %d %s: not enough in your bags."
L["TRADE_STATUS_SHORT_RESERVE"] = "Short %d %s: your reserve keeps the rest."
L["TRADE_STATUS_DISPENSE_OFF"] = "Auto-fill is off. Fill Trade Window still adds your usual amounts."
L["TRADE_STATUS_OFF_STRANGERS"] = "Auto-fill is off for strangers. Fill Trade Window still adds your usual amounts."
L["TRADE_STATUS_OFF_PARTY"] = "Auto-fill is off for party members. Fill Trade Window still adds your usual amounts."
L["TRADE_STATUS_OFF_RAID"] = "Auto-fill is off for raid members. Fill Trade Window still adds your usual amounts."
L["TRADE_STATUS_MASTER_LOOT"] = "Held back while you're master looter. Fill Trade Window still adds your usual amounts."
-- The first %s is the partner's class name.
L["TRADE_STATUS_ZERO"] = "Set to 0 for %s: %s."
L["TRADE_STATUS_INSTANCE_ONLY"] = "%s is only handed out in instances."
L["TRADE_STATUS_GUILD_ONLY"] = "%s only goes to your guild."
-- The partner's name, then the rank they can't use yet and its level.
L["TRADE_STATUS_LEVEL"] = "%s can't use your %s until level %d."
-- The partner's name first.
L["TRADE_STATUS_TOO_LOW"] = "%s is too low level for %s."
-- The partner's name first.
L["TRADE_STATUS_CAPPED"] = "%s has had all the %s you give one player."
L["TRADE_STATUS_NONE_HELD"] = "You have no %s to give."
L["TRADE_STATUS_CLEARED"] = "Cleared."
--[[
	A conjure button's tooltip, under the spell's name. MAKES: the item it makes,
	then the trade partner's name and level. LOWEST, when no rank fits the partner:
	the item only.
]]
L["TRADE_CONJURE_MAKES"] = "Makes %s, the best %s (level %d) can use."
L["TRADE_CONJURE_MAKES_LOWEST"] = "Makes %s, the lowest rank you know."

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

--[[
	The tooltip's feature row reuses TAB_DISPENSE for its name and
	OPTIONS_DISPENSE_MASTER_DESC for its description; these are its state and click words.
]]
L["UI_ENABLED"] = "Enabled"
L["UI_DISABLED"] = "Disabled"
L["UI_LEFT_CLICK"] = "Left-Click"
L["UI_TOGGLE"] = "Toggle"
L["MINIMAP_OPTIONS"] = "Water Dispenser Options"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + Middle-Click"
-- Heads the tooltip section listing what the player can give right now.
L["MINIMAP_DISPENSE_REPORT"] = "Dispense Report"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Effortless consumable distribution. Auto-fill trade windows with conjured water, food, and healthstones at the right rank and amount for each player. Add any item, from Hourglass Sand to Resistance Potions, and distribute a raid's worth in seconds."

L["OPTIONS_WELCOME_MESSAGE"] = "Enable Welcome Message"
L["OPTIONS_WELCOME_MESSAGE_DESC"] = "Prints a one-line greeting in your chat frame when Water Dispenser loads."
L["OPTIONS_MINIMAP"] = "Enable Mini-map Button"
L["OPTIONS_MINIMAP_DESC"] = "Shows the Water Dispenser mini-map button."

L["OPTIONS_FEATURES_HEADER"] = "Features"

L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/wd"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Opens the Options Interface for this add-on."

--------------------------------------------------------------------------------
-- Options — Dispense
--------------------------------------------------------------------------------

-- Names the panel and the mini-map tooltip's feature row.
L["TAB_DISPENSE"] = "Dispense"
L["OPTIONS_DISPENSE_MASTER"] = "Enable Dispense"
-- Also the panel's intro line and the mini-map tooltip's feature description.
L["OPTIONS_DISPENSE_MASTER_DESC"] = "Automatically fills the trade window when a trade opens, based on your settings."
L["OPTIONS_DISPENSE_SOLO"] = "Enable for Strangers"
L["OPTIONS_DISPENSE_SOLO_DESC"] =
	"Fills the trade window automatically when trading with someone who is not in your party or raid."
L["OPTIONS_DISPENSE_GROUP"] = "Enable for Party"
L["OPTIONS_DISPENSE_GROUP_DESC"] = "Fills the trade window automatically when trading with a party member."
L["OPTIONS_DISPENSE_RAID"] = "Enable for Raid"
L["OPTIONS_DISPENSE_RAID_DESC"] = "Fills the trade window automatically when trading with a raid member."
-- The label says what it does; the tooltip only covers why it is needed and when it stands down.
L["OPTIONS_RESTACK"] = "Combine Partial Stacks After a Trade"
L["OPTIONS_RESTACK_DESC"] =
	"Conjured water and food land in a new bag slot every cast and the game never puts them back together, so Water Dispenser merges them once, just after a trade window closes, and never at any other time, in combat, or while you are holding something on your cursor."
L["OPTIONS_HOLD_MASTER_LOOT"] = "Hold Off While You're Master Looter"
-- "Fill Trade Window" must match BUTTON_FILL.
L["OPTIONS_HOLD_MASTER_LOOT_DESC"] =
	"Leaves the trade window empty while you're master looter in an instance, since those trades are for handing out loot. Fill Trade Window still adds your usual amounts."
L["OPTIONS_CONJURE_BUTTONS"] = "Show Conjure Buttons Beside Trades"
-- "Fill Trade Window" must match BUTTON_FILL.
L["OPTIONS_CONJURE_BUTTONS_DESC"] =
	"Adds buttons under Fill Trade Window that conjure water, food, or a healthstone your trade partner can use at their level, and what you make goes straight into the open trade."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "Enable Warnings When You Run Short"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] =
	"Prints a note in your chat frame when you don't have enough of a configured item in your bags to give the amount you set."

-- Leads the silver line under a setting that shows the exact chat line it prints.
L["OPTIONS_EXAMPLE"] = "Example:"

L["OPTIONS_COMBAT_HEADER"] = "Combat"
L["OPTIONS_COMBAT_DESC"] = "WoW blocks add-ons from moving items into a trade during combat."
L["OPTIONS_COMBAT_NOTIFY"] = "Enable Notifications When Dispensing Is Blocked"
L["OPTIONS_COMBAT_NOTIFY_DESC"] = "Prints a note in your chat frame when combat stops a trade from filling."

--------------------------------------------------------------------------------
-- Options — Inventory Tooltips
--------------------------------------------------------------------------------

L["TAB_INVENTORY_TOOLTIPS"] = "Inventory Tooltips"
L["OPTIONS_TOOLTIPS_DESC"] =
	"Shows on player tooltips what group members running Water Dispenser have set up to give out, and marks the items you give out in your own bags."
L["OPTIONS_SHOW_INVENTORY"] = "Show Inventory in Player Tooltips"
L["OPTIONS_SHOW_INVENTORY_DESC"] =
	"Adds a Water Dispenser block to player tooltips listing what they have set up to give out and how many they have to give, with your own always showing whether you are grouped or not."
L["OPTIONS_BAG_TOOLTIPS"] = "Show Bag Tooltips for Dispensed Items"
L["OPTIONS_BAG_TOOLTIPS_DESC"] =
	"Adds a Water Dispenser line to a bag item's tooltip when that item is set to be given out, so you can tell at a glance what the add-on will hand over."
L["OPTIONS_SHARE_INVENTORY"] = "Share My Inventory"
L["OPTIONS_SHARE_INVENTORY_DESC"] =
	"Tells your party or raid what you have to give away, so it shows when they hover you. Never posts to chat or reaches anyone outside your group. Turning it off still lets you see theirs."

--------------------------------------------------------------------------------
-- Options — Dispensed Items
--------------------------------------------------------------------------------

L["TAB_DISPENSED_ITEMS"] = "Dispensed Items"
L["OPTIONS_ITEMS_DESC"] =
	"Configure how many of each item to dispense. Amounts are counted in individual items, so 20 water means 20 water, and 1 potion means 1 potion. A stack is split down to the exact amount if it has to be."
-- "Add an Item" must match OPTIONS_ADD_ITEM.
L["OPTIONS_ITEMS_EMPTY"] =
	'No items configured. Select "Add an Item" in the list to add anything tradable from your bags.'

--[[
	The silver line opening an item's page while nothing of it would go out. In
	OTHER_CLASS, %s is the player's class twice, then OPTIONS_ITEM_PLAYER_CLASSES;
	in ALL_ZERO, %s is OPTIONS_ITEM_EVERYONE.
]]
L["OPTIONS_ITEM_STATUS_OTHER_CLASS"] = "Not handed out while you're playing a %s. Tick %s under %s."
L["OPTIONS_ITEM_STATUS_ALL_ZERO"] = "Nothing goes out yet: every amount is 0. Type a number into %s to start."

L["OPTIONS_ITEM_AMOUNTS"] = "Amounts"
L["OPTIONS_ITEM_AMOUNTS_DESC"] =
	"Pick how many each class gets when you trade them, depending on whether they're a stranger, in your party, or in your raid. Counted in individual items, not stacks. Zero means they never get this item."
L["OPTIONS_ITEM_EVERYONE"] = "Everyone"
-- "Apply" must match OPTIONS_ITEM_APPLY.
L["OPTIONS_ITEM_EVERYONE_DESC"] =
	"Sets this amount for every class at once when you press Enter or click Apply, and shows blank when the classes below don't all agree."
-- The accept button inside every number box in this panel.
L["OPTIONS_ITEM_APPLY"] = "Apply"
-- %d is the highest amount this item accepts, which is 1 for anything unique.
L["OPTIONS_ITEM_COUNT_TOO_HIGH"] = "That's more than you can give of this item. The most is %d."
L["OPTIONS_ITEM_COUNT_INVALID"] = "Enter a number of items."
L["OPTIONS_ITEM_SETTINGS"] = "Item Settings"
L["OPTIONS_ITEM_DISTRIBUTE"] = "Distribute"
-- "In Instance" must match OPTIONS_ITEM_DISTRIBUTE_INSTANCE.
L["OPTIONS_ITEM_DISTRIBUTE_DESC"] =
	"Sets where this item is handed out. In Instance covers dungeons, raids, battlegrounds, and arenas. Anywhere else, the item is never traded, announced, or shown on your tooltip."
--[[
	Dropdown entries, looked up as OPTIONS_ITEM_DISTRIBUTE_ plus the stored value in
	capitals ("Always", "Instance"), so no code names these keys in full.
]]
L["OPTIONS_ITEM_DISTRIBUTE_ALWAYS"] = "Always"
L["OPTIONS_ITEM_DISTRIBUTE_INSTANCE"] = "In Instance"
L["OPTIONS_ITEM_GUILDIES_ONLY"] = "Guildies Only"
L["OPTIONS_ITEM_GUILDIES_ONLY_DESC"] = "Skips this item when your trade partner is not in your guild."
-- Panel line under the toggle, not a tooltip: it names the guild, which no fixed string can. %s is the player's guild.
L["OPTIONS_ITEM_GUILDIES_ONLY_HELP"] = "Only give to <%s> members."
L["OPTIONS_ITEM_GUILDIES_ONLY_NO_GUILD"] = "You are not in a guild, so this gives the item to no one."
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Factor in the Item's Required Level"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] = "Skips this item when your trade partner is below the item's required level."
L["OPTIONS_ITEM_RESERVE"] = "Enable Reserves"
L["OPTIONS_ITEM_RESERVE_DESC"] =
	"Keeps at least this many in your bags, with dispensing, your player tooltip, and the announcement macro treating anything beyond that number as available to give away."
L["OPTIONS_ITEM_PLAYER_CAP"] = "Enable Maximum per Player"
L["OPTIONS_ITEM_PLAYER_CAP_DESC"] =
	"Stops giving this item to someone once they've had this many from you. Counts start over when you log out or reload, or change this item's amounts."
-- The label carries the meaning on its own; the tooltip only says why you'd switch it off.
L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "Include Quantity in Player Tooltip & Announcement Macro"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] =
	"Off names the item with no number beside it, which reads better for something you only ever carry one of, like a healthstone."
L["OPTIONS_ITEM_PLAYER_CLASSES"] = "Only Dispense When Playing These Classes"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] =
	"Fills trades, lists this item in the announcement macro, and shows it on your player tooltip only when your character's class is selected below."
L["OPTIONS_ITEM_REMOVE"] = "Remove Item"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "Remove this item from your dispensed items?"

L["OPTIONS_SCOPE_SOLO"] = "Strangers"
L["OPTIONS_SCOPE_GROUP"] = "Party"
L["OPTIONS_SCOPE_RAID"] = "Raid"

L["OPTIONS_ADD_ITEM"] = "Add an Item"
L["OPTIONS_ADD_DESC"] =
	"Select any tradable item from your bags to add to your dispensed items. Items that are already configured or soulbound will not appear."
L["OPTIONS_ADD_SELECT"] = "Available Items"
L["OPTIONS_ADD_BUTTON"] = "Add to Dispensed Items"
L["OPTIONS_ADD_EMPTY"] = "No tradable items found in your bags."

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["TAB_ANNOUNCEMENTS"] = "Announcements"
L["OPTIONS_ANNOUNCEMENTS_DESC"] =
	"Water Dispenser can build a macro that announces what you have left to give out. The macro picks the right channel automatically (Say when ungrouped, Party in a party, Raid in a raid, Instance in a dungeon or battleground group) and uses the latest counts straight from your bags."
L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Enable Announcement Macro"
-- "- Dispenser" is the macro's literal name and is never translated.
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] =
	'Keeps a character-specific macro named "- Dispenser" up to date with your current dispensed items, and deletes the macro when you turn this off.'
-- "Enable Reserves" must match OPTIONS_ITEM_RESERVE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] =
	"Nothing to announce. Configure items, restock your bags, or lower a reserve under Enable Reserves."
-- "Enable Dispense" must match OPTIONS_DISPENSE_MASTER, "Dispense" must match TAB_DISPENSE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DISPENSE_OFF"] =
	"Nothing to announce while Enable Dispense is switched off, under the Dispense tab."

-- Macro message template (%s is the item list) and the connector before the last list entry.
L["ANNOUNCEMENTS_BODY"] = "I have %s. Open trade!"
L["ANNOUNCEMENTS_AND"] = "and"

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["OPTIONS_SUPPORT"] = "Feedback & Support"
-- The General panel's last line. %s is the version.
L["OPTIONS_VERSION"] = "Version %s"
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"
L["SUPPORT_WAGO"] = "Wago"
