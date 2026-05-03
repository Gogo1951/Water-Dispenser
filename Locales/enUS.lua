local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "enUS", true)
if not L then return end

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] = "Enabled. Use %s to access settings, including turning off this message. Enjoying Water Dispenser? Tell a friend! (="
L["CHAT_NO_TRADE"] = "No active trade window."
L["CHAT_COMBAT_PAUSED"] = "Auto-fill paused while in combat."
L["CHAT_COMBAT_RESUMED"] = "Combat ended. Resuming trade fill."
L["CHAT_MISSING_STACK"] = "Missing stacks:"
L["CHAT_ITEM_SAVED"] = "Saved:"
L["CHAT_ITEM_REMOVED"] = "Removed:"

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BTN_CLEAR"] = "Clear Trade"
L["BTN_FILL"] = "Fill Trade"
L["BTN_CONFIG"] = "Options"
L["BTN_ACCEPT"] = "Accept Trade"

--------------------------------------------------------------------------------
-- Options — Top Level
--------------------------------------------------------------------------------

L["OPTIONS_TITLE"] = "Water Dispenser"
L["OPTIONS_DESC"] = "Automatically fills the trade window with stacks of water, food, healthstones, or any consumable you configure, based on the trade partner's class, level, and group membership."

L["OPTIONS_GENERAL_HEADER"] = "General Settings"
L["OPTIONS_WELCOME_MESSAGE"] = "Enable Welcome Message"
L["OPTIONS_WELCOME_MESSAGE_DESC"] = "Print a one-line greeting in chat when Water Dispenser loads."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "Show Missing-Stack Warnings"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] = "Print a chat message when a configured item doesn't have enough stacks in your bags to fill the trade."
L["OPTIONS_ITEMS"] = "Distribution Rules"
L["OPTIONS_ADD_ITEM"] = "Add Item"
L["OPTIONS_SUPPORT"] = "Feedback & Support"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_AUTOFILL_HEADER"] = "Automatic Fill"
L["OPTIONS_AUTOFILL_DESC"] = "Fill the trade window automatically when a trade opens. Each scope is toggled independently."
L["OPTIONS_AUTOFILL_SOLO"] = "Fill for Strangers"
L["OPTIONS_AUTOFILL_SOLO_DESC"] = "Fills the trade window automatically when trading with someone who is not in your party or raid."
L["OPTIONS_AUTOFILL_GROUP"] = "Fill for Party Members"
L["OPTIONS_AUTOFILL_GROUP_DESC"] = "Fills the trade window automatically when trading with a party member."
L["OPTIONS_AUTOFILL_RAID"] = "Fill for Raid Members"
L["OPTIONS_AUTOFILL_RAID_DESC"] = "Fills the trade window automatically when trading with a raid member."

L["OPTIONS_COMBAT_HEADER"] = "Combat"
L["OPTIONS_COMBAT_DESC"] = "Auto-fill is always paused while in combat to prevent interface errors. A reminder chat message is printed when this happens. Trades resume automatically once combat ends if the trade window is still open."

L["OPTIONS_LOCKED_HEADER"] = "Rogue Lockboxes"
L["OPTIONS_LOCKED_DESC"] = "When trading with a rogue, places the first locked item found in your bags into the \"will not be traded\" slot so they can pick it."
L["OPTIONS_LOCKED"] = "Offer Locked Items to Rogues"

L["OPTIONS_RESET_HEADER"] = "Reset"
L["OPTIONS_RESET_DESC"] = "Wipes every Water Dispenser setting on this character back to defaults, including your custom item list."
L["OPTIONS_RESET_BUTTON"] = "Reset all Water Dispenser Options"
L["OPTIONS_RESET_CONFIRM"] = "Are you sure you want to reset every Water Dispenser setting on this character to its default value?"

L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMANDS_DESC"] = "Slash commands for Water Dispenser. The options panel covers everything you need; these are here for the keyboard-first folks."
L["OPTIONS_COMMAND_WD"] = "/wd"
L["OPTIONS_COMMAND_WD_DESC"] = "Opens the Water Dispenser options interface."
L["OPTIONS_COMMAND_WD_FILL"] = "/wd fill"
L["OPTIONS_COMMAND_WD_FILL_DESC"] = "Fills the trade window now, even if auto-fill is off for this trade partner."
L["OPTIONS_COMMAND_WD_CLEAR"] = "/wd clear"
L["OPTIONS_COMMAND_WD_CLEAR_DESC"] = "Clears every slot in the trade window."
L["OPTIONS_COMMAND_WD_AUTO"] = "/wd auto solo||group||raid on||off"
L["OPTIONS_COMMAND_WD_AUTO_DESC"] = "Toggles automatic fill for the given scope. Omit on/off to flip it."
L["OPTIONS_COMMAND_WDA"] = "/wda"
L["OPTIONS_COMMAND_WDA_DESC"] = "Sends the announcement message to whichever channel matches your current group state."

L["CHAT_RESET"] = "All options have been reset to defaults."

--------------------------------------------------------------------------------
-- Options — Items
--------------------------------------------------------------------------------

L["OPTIONS_ITEMS_DESC"] = "Configure how many stacks of each item to dispense. Note: Classic Era and TBC Anniversary do not support automated stack splitting. Sorry!"
L["OPTIONS_ITEMS_EMPTY"] = "No items configured. Open the \"Add Item\" tab to add consumables from your bags."

L["OPTIONS_ITEM_SETTINGS"] = "Item Settings"
L["OPTIONS_ITEM_USE_NOT_FULL"] = "Fill with Partial Stacks"
L["OPTIONS_ITEM_USE_NOT_FULL_DESC"] = "When a full stack is not available, fill the trade with whatever smaller stack you have on hand."

L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Factor in Usage Level Requirements"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] = "Skip this item when the trade partner is below the item's required level."

L["OPTIONS_ITEM_KEEP_AT_LEAST"] = "Keep at least"
L["OPTIONS_ITEM_KEEP_AT_LEAST_DESC"] = "Always keep at least this many in your bags. The trade fill and the announcement macro will treat anything beyond this number as available to give away."

L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "Include Quantity Remaining in Announcement Macro"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] = "When the announcement macro lists this item, include how many you have left. Turn off if you'd rather just say you have it without the count (typical for healthstones)."

L["OPTIONS_ITEM_PLAYER_CLASSES"] = "Only Dispense when Playing These Class(es)"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] = "Only fill trades and include this item in the announcement when your character's class is selected below."

L["OPTIONS_ITEM_REMOVE"] = "Remove Item"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "Remove this item from the trade configuration?"

L["OPTIONS_SCOPE_SOLO"] = "Strangers"
L["OPTIONS_SCOPE_GROUP"] = "Party Members"
L["OPTIONS_SCOPE_RAID"] = "Raid Members"

L["OPTIONS_ADD_DESC"] = "Select a tradable consumable from your bags to add to the trade configuration. Items already configured or that are soulbound will not appear."
L["OPTIONS_ADD_SELECT"] = "Available items"
L["OPTIONS_ADD_BUTTON"] = "Add to configuration"
L["OPTIONS_ADD_EMPTY"] = "No eligible consumables found in your bags."

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["SUPPORT_DESC"] = "Report issues, request features, or say hello on Discord."
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["OPTIONS_ANNOUNCEMENTS"] = "Announcements"
L["OPTIONS_ANNOUNCEMENTS_DESC"] = "Water Dispenser can build a macro that announces what you have left to give out. The macro picks the right channel automatically (/say when ungrouped, /party in a group, /raid in a raid) and uses the latest counts straight from your bags."

L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Enable Announcement Macro"
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] = "Keeps a character-specific macro named \"- Dispenser\" up to date with your current giveaway list. Disabling deletes the macro."

L["OPTIONS_ANNOUNCEMENTS_PREVIEW_HEADER"] = "Live Preview"
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DESC"] = "This is what the macro will say if you click it right now."
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] = "Nothing to announce. Configure items, restock your bags, or lower a \"Keep at least\" value."

L["ANNOUNCEMENTS_INTRO"] = "I have"
L["ANNOUNCEMENTS_OUTRO"] = ". Open trade!"
L["ANNOUNCEMENTS_AND"] = "and"

L["CHAT_MACRO_CREATED"] = "Announcement macro \"- Dispenser\" is ready. Open the Macro UI (Game Menu > Macros, or /m) and drag it onto your action bar."
L["CHAT_MACRO_DELETED"] = "Announcement macro \"- Dispenser\" deleted."
L["CHAT_MACRO_FULL"] = "Could not create the macro: all character macro slots are in use."
L["CHAT_NOTHING_TO_ANNOUNCE"] = "Nothing to announce right now."

--------------------------------------------------------------------------------
-- Built-in Collections
--------------------------------------------------------------------------------

L["ITEM_MAGE_WATER"] = "Any Conjured Water"
L["ITEM_MAGE_FOOD"] = "Any Conjured Food"
L["ITEM_WARLOCK_HEALTHSTONE"] = "Any Healthstone"