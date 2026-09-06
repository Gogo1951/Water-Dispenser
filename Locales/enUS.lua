local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "enUS", true)
if not L then
	return
end

--------------------------------------------------------------------------------
-- Add-on Identity
--------------------------------------------------------------------------------

L["ADDON_TITLE"] = "Water Dispenser"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

--[[
	All player-facing chat prints live here, regardless of which feature emits them.
	%s is the add-on version; the menu path is the game client's own labels.
]]
L["CHAT_LOADED"] =
	"Version %s. Settings (including the option to disable this message) can be found under Options > AddOns > Water Dispenser. Enjoying the add-on? Tell a friend about it! (="
L["CHAT_NO_TRADE"] = "No active trade window."
L["CHAT_COMBAT_BLOCKED"] = "WoW blocks automated trades during combat."
L["CHAT_OPTIONS_IN_COMBAT"] = "As a safety precaution, the Options Interface cannot be opened during combat."
-- The item and its count are appended after the colon by the code.
L["CHAT_MISSING_STACK"] = "Missing:"
--[[
	%s is the item's name, %d the Maximum per Session it has hit.
	"Maximum per Session" must match OPTIONS_ITEM_SESSION_CAP.
]]
L["CHAT_SESSION_CAP_REACHED"] =
	"%s not added: they've had their %d this session. Change Maximum per Session, or reload to reset."
-- %s is the item's name, %d the amount that could not be split off.
L["CHAT_SPLIT_REFUSED"] =
	"%s not added: this client would not split %d off a stack, and handing over a whole stack instead would give away far more than you asked for. Set this item's amount to a whole stack to trade it."
-- %s is the player's class name. "Dispensed Items" must match TAB_DISPENSED_ITEMS.
L["CHAT_NONE_ACTIVE_FOR_CLASS"] =
	"No items are set to dispense while you're playing a %s. Open Options > Dispensed Items to enable items for this class."
-- "- Dispenser" is the macro's literal name and is never translated.
L["CHAT_MACRO_DELETED"] = 'Announcement macro "- Dispenser" deleted.'
L["CHAT_MACRO_FULL"] = "Could not create the macro: all character macro slots are in use."

--------------------------------------------------------------------------------
-- Player Tooltips
--------------------------------------------------------------------------------

L["TOOLTIP_OPEN_TRADE"] = "Open Trade!"
-- %d/%d is the warlock's Improved Healthstone rank out of its maximum.
L["TOOLTIP_HEALTHSTONE"] = "Healthstone (Rank %d/%d)"

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BUTTON_CLEAR"] = "Clear Trade Window"
L["BUTTON_FILL"] = "Fill Trade Window"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

-- The tooltip's feature row reuses TAB_DISPENSE for its name; these are its state and click words.
L["UI_ENABLED"] = "Enabled"
L["UI_DISABLED"] = "Disabled"
L["UI_LEFT_CLICK"] = "Left-Click"
L["UI_TOGGLE"] = "Toggle"
L["MINIMAP_OPTIONS"] = "Water Dispenser Options"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + Middle-Click"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Effortless consumable distribution. Auto-fill the trade window with water, food, and healthstones. Add any item you want, like Hourglass Sand or Resistance Potions, to be given out to your raid."

L["OPTIONS_WELCOME_MESSAGE"] = "Enable Welcome Message"
L["OPTIONS_WELCOME_MESSAGE_DESC"] = "Prints a one-line greeting in your chat frame when Water Dispenser loads."
L["OPTIONS_MINIMAP"] = "Enable Mini-map Button"
L["OPTIONS_MINIMAP_DESC"] = "Shows the Water Dispenser mini-map button."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "Enable Warnings When You Run Short"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] =
	"Prints a note in your chat frame when you don't have enough of a configured item in your bags to give the amount you set."
-- The label says what it does; the tooltip only covers why it is needed and when it stands down.
L["OPTIONS_RESTACK"] = "Automatically Combine Partial Stacks in Bags"
L["OPTIONS_RESTACK_DESC"] =
	"Conjured water and food land in a new bag slot every cast and the game never puts them back together, though this never runs in combat, while a trade is open, or while you are holding something on your cursor."

L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/wd"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Opens the Options Interface for this add-on."

-- Names the panel, its section header, and the mini-map tooltip's feature row.
L["TAB_DISPENSE"] = "Dispense"
L["OPTIONS_DISPENSE_DESC"] = "Automatically fill the trade window when a trade opens."
L["OPTIONS_DISPENSE_MASTER"] = "Enable Dispense"
L["OPTIONS_DISPENSE_MASTER_DESC"] = "Automatically fills the trade window based on your settings."
L["OPTIONS_DISPENSE_SOLO"] = "Enable for Strangers"
L["OPTIONS_DISPENSE_SOLO_DESC"] =
	"Fills the trade window automatically when trading with someone who is not in your party or raid."
L["OPTIONS_DISPENSE_GROUP"] = "Enable for Party"
L["OPTIONS_DISPENSE_GROUP_DESC"] = "Fills the trade window automatically when trading with a party member."
L["OPTIONS_DISPENSE_RAID"] = "Enable for Raid"
L["OPTIONS_DISPENSE_RAID_DESC"] = "Fills the trade window automatically when trading with a raid member."

L["TAB_INVENTORY_TOOLTIPS"] = "Inventory Tooltips"
L["OPTIONS_TOOLTIPS_DESC"] = "Shows giveaway inventory on player tooltips for group members running Water Dispenser."
L["OPTIONS_SHOW_INVENTORY"] = "Show Inventory in Player Tooltips"
L["OPTIONS_SHOW_INVENTORY_DESC"] =
	"Adds a Water Dispenser block to player tooltips listing what they have set up to give out and how many they are carrying, with your own always showing whether you are grouped or not."
L["OPTIONS_SHARE_INVENTORY"] = "Share My Inventory"
L["OPTIONS_SHARE_INVENTORY_DESC"] =
	"Tells your party and raid what you are carrying so your inventory appears when they hover you, never posting to chat or telling anyone outside your group, and turning it off still lets you read theirs."

L["OPTIONS_COMBAT_HEADER"] = "Combat"
L["OPTIONS_COMBAT_DESC"] = "WoW blocks add-ons from moving items into a trade during combat."
L["OPTIONS_COMBAT_NOTIFY"] = "Enable Notifications When Dispensing Is Blocked"
L["OPTIONS_COMBAT_NOTIFY_DESC"] =
	"Prints a note in your chat frame when combat stops a trade from filling, and with it off Water Dispenser stays quiet about why the trade stayed empty."

--------------------------------------------------------------------------------
-- Options — Dispensed Items
--------------------------------------------------------------------------------

L["TAB_DISPENSED_ITEMS"] = "Dispensed Items"
L["OPTIONS_ITEMS_DESC"] =
	"Configure how many of each item to dispense. Amounts are counted in individual items, so 20 water means 20 water, and 1 potion means 1 potion. A stack is split down to the exact amount if it has to be."
-- "Add an Item" must match OPTIONS_ADD_ITEM.
L["OPTIONS_ITEMS_EMPTY"] = 'No items configured. Select "Add an Item" in the list to add consumables from your bags.'

L["OPTIONS_ITEM_DISTRIBUTION"] = "Distribution"
L["OPTIONS_ITEM_DISTRIBUTION_DESC"] =
	"Pick how many each class gets when you trade them, depending on whether they're a stranger, in your party, or in your raid. Counted in individual items, not stacks. Zero means they never get this item."
L["OPTIONS_ITEM_EVERYONE"] = "Everyone"
L["OPTIONS_ITEM_EVERYONE_DESC"] =
	"Sets this amount for every class at once when you press Enter, and shows blank when the classes below don't all agree."
-- The accept button inside every number box in this panel.
L["OPTIONS_ITEM_APPLY"] = "Apply"
-- %d is the highest amount this item accepts, which is 1 for anything unique.
L["OPTIONS_ITEM_COUNT_TOO_HIGH"] = "That's more than this item can dispense. The most it takes is %d."
L["OPTIONS_ITEM_COUNT_INVALID"] = "Enter a number of items, or 0 to never dispense this."
L["OPTIONS_ITEM_SETTINGS"] = "Item Settings"
-- "In Group" and "In Raid" in the tooltip must match the two dropdown entries below.
L["OPTIONS_ITEM_DISTRIBUTE"] = "Distribute"
L["OPTIONS_ITEM_DISTRIBUTE_DESC"] =
	"Sets when this item is handed out at all, never traded, announced, or shown on your tooltip outside the group you pick, with In Group covering a party or a raid and In Raid covering raids only."
-- Dropdown entries. The stored values are "Always", "Group", and "Raid"; these are only their labels.
L["OPTIONS_ITEM_DISTRIBUTE_ALWAYS"] = "Always"
L["OPTIONS_ITEM_DISTRIBUTE_GROUP"] = "In Group"
L["OPTIONS_ITEM_DISTRIBUTE_RAID"] = "In Raid"
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Factor in Usage Level Requirements"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] = "Skips this item when the trade partner is below the item's required level."
L["OPTIONS_ITEM_RESERVE"] = "Enable Reserves"
L["OPTIONS_ITEM_RESERVE_DESC"] =
	"Keeps at least this many in your bags, with dispensing and the announcement macro treating anything beyond that number as available to give away."
L["OPTIONS_ITEM_SESSION_CAP"] = "Enable Maximum per Session"
L["OPTIONS_ITEM_SESSION_CAP_DESC"] =
	"Stops giving this item to someone once they have had this many from you across every trade until you log out or reload, and changing any of this item's amounts starts everyone's count over."
-- The label carries the meaning on its own; the tooltip only says why you'd switch it off.
L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "Include Quantity in Player Tooltip & Announcement Macro"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] =
	"Off names the item with no number beside it, which reads better for something you only ever carry one of, like a healthstone."
L["OPTIONS_ITEM_PLAYER_CLASSES"] = "Only Dispense When Playing These Classes"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] =
	"Fills trades, lists this item in the announcement macro, and shows it on your player tooltip only when your character's class is selected below."
L["OPTIONS_ITEM_REMOVE"] = "Remove Item"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "Remove this item from the trade configuration?"

L["OPTIONS_SCOPE_SOLO"] = "Strangers"
L["OPTIONS_SCOPE_GROUP"] = "Party"
L["OPTIONS_SCOPE_RAID"] = "Raid"

L["OPTIONS_ADD_ITEM"] = "Add an Item"
L["OPTIONS_ADD_DESC"] =
	"Select any tradable item from your bags to add to the trade configuration. Items that are already configured or soulbound will not appear."
L["OPTIONS_ADD_SELECT"] = "Available Items"
L["OPTIONS_ADD_BUTTON"] = "Add to Configuration"
L["OPTIONS_ADD_EMPTY"] = "No tradable items found in your bags."

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["TAB_ANNOUNCEMENTS"] = "Announcements"
L["OPTIONS_ANNOUNCEMENTS_DESC"] =
	"Water Dispenser can build a macro that announces what you have left to give out. The macro picks the right channel automatically (Say when ungrouped, Party in a group, Raid in a raid) and uses the latest counts straight from your bags."
L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Enable Announcement Macro"
-- "- Dispenser" is the macro's literal name and is never translated.
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] =
	'Keeps a character-specific macro named "- Dispenser" up to date with your current giveaway list, and deletes the macro when you turn this off.'
-- "Enable Reserves" must match OPTIONS_ITEM_RESERVE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] =
	"Nothing to announce. Configure items, restock your bags, or lower a reserve under Enable Reserves."

-- Macro message template (%s is the item list) and the connector before the last list entry.
L["ANNOUNCEMENTS_BODY"] = "I have %s. Open trade!"
L["ANNOUNCEMENTS_AND"] = "and"

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["OPTIONS_SUPPORT"] = "Feedback & Support"
-- Precedes the version number on the General panel's last line.
L["VERSION"] = "Version"
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"
L["SUPPORT_WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Built-in Collections
--------------------------------------------------------------------------------

L["ITEM_MAGE_WATER"] = "Conjured Water"
L["ITEM_MAGE_FOOD"] = "Conjured Food"
L["ITEM_WARLOCK_HEALTHSTONE"] = "Healthstone"
