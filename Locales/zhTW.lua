local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "zhTW")
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

-- All player-facing chat prints live here, regardless of which feature emits them.
L["CHAT_LOADED"] =
	"版本 %s。設定（包含關閉此訊息的選項）可以在 選項 > 插件 > Water Dispenser 中找到。喜歡 Water Dispenser 嗎？分享給你的朋友吧！(="
L["CHAT_NO_TRADE"] = "沒有開啟的交易視窗。"
L["CHAT_COMBAT_PAUSED"] = "戰鬥中已暫停分發。"
L["CHAT_COMBAT_RESUMED"] = "戰鬥結束。恢復分發。"
L["CHAT_MISSING_STACK"] = "缺少："
L["CHAT_NONE_ACTIVE_FOR_CLASS"] =
	"當你使用 %s 遊玩時，沒有設定任何要分發的物品。請打開 選項 > 分發規則 啟用適用於此職業的物品。"
L["CHAT_ITEM_SAVED"] = "已儲存："
L["CHAT_ITEM_REMOVED"] = "已移除："
L["CHAT_MACRO_CREATED"] =
	"喊話巨集「- Dispenser」已準備就緒。打開巨集介面（遊戲選單 > 巨集，或輸入 /m），將其拖曳到快捷列上即可使用。"
L["CHAT_MACRO_DELETED"] = "喊話巨集「- Dispenser」已刪除。"
L["CHAT_MACRO_FULL"] = "無法建立巨集：角色專屬巨集數量已達上限。"

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BUTTON_CLEAR"] = "清空交易視窗"
L["BUTTON_FILL"] = "填充交易視窗"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["MINIMAP_DISPENSE"] = "分發"
L["UI_ENABLED"] = "已啟用"
L["UI_DISABLED"] = "已停用"
L["UI_LEFT_CLICK"] = "左鍵點擊"
L["UI_TOGGLE"] = "切換"
L["MINIMAP_OPTIONS"] = "Water Dispenser 選項"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + 中鍵點擊"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_DESC"] =
	"根據交易對象的職業、等級和隊伍狀態，自動用設定好的水、食物、治療石或其他消耗品來填充交易視窗。"

L["OPTIONS_WELCOME_MESSAGE"] = "啟用歡迎訊息"
L["OPTIONS_WELCOME_MESSAGE_DESC"] = "當 Water Dispenser 載入時，在聊天框顯示一行簡單的問候語。"
L["OPTIONS_MINIMAP"] = "啟用小地圖按鈕"
L["OPTIONS_MINIMAP_DESC"] = "顯示 Water Dispenser 小地圖按鈕。"
L["OPTIONS_MISSING_STACK_WARNINGS"] = "啟用堆疊不足警告"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] =
	"當背包中配置的物品不足以填滿交易視窗時，在聊天框中輸出提示。"

L["OPTIONS_COMMANDS"] = "/指令"
L["OPTIONS_COMMANDS_WD"] = "打開 Water Dispenser 選項介面。"

L["OPTIONS_DISPENSE_HEADER"] = "分發"
L["OPTIONS_DISPENSE_DESC"] = "交易開啟時自動填充交易視窗。下方每個選項均可單獨開關。"
L["OPTIONS_DISPENSE_MASTER"] = "啟用分發"
L["OPTIONS_DISPENSE_MASTER_DESC"] = "根據你的設定自動填充交易視窗。"
L["OPTIONS_DISPENSE_SOLO"] = "為陌生人填充"
L["OPTIONS_DISPENSE_SOLO_DESC"] = "當與不在隊伍或團隊中的玩家交易時，自動填充交易視窗。"
L["OPTIONS_DISPENSE_GROUP"] = "為隊伍成員填充"
L["OPTIONS_DISPENSE_GROUP_DESC"] = "當與隊伍成員交易時，自動填充交易視窗。"
L["OPTIONS_DISPENSE_RAID"] = "為團隊成員填充"
L["OPTIONS_DISPENSE_RAID_DESC"] = "當與團隊成員交易時，自動填充交易視窗。"

L["OPTIONS_COMBAT_HEADER"] = "戰鬥"
L["OPTIONS_COMBAT_DESC"] =
	"為避免介面錯誤，戰鬥中始終暫停分發。發生時會有聊天訊息提醒你。若交易視窗仍然開啟，戰鬥結束後會自動恢復。"

--------------------------------------------------------------------------------
-- Options — Distribution Rules
--------------------------------------------------------------------------------

L["OPTIONS_ITEMS"] = "分發規則"
L["OPTIONS_ITEMS_DESC"] =
	"配置要分發每種物品的堆疊數量。注意：經典版和 TBC 紀念版不支援自動拆分堆疊。抱歉！"
L["OPTIONS_ITEMS_EMPTY"] = "未配置物品。請打開「新增物品」分頁，從背包中加入消耗品。"

L["OPTIONS_ITEM_SETTINGS"] = "物品設定"
L["OPTIONS_ITEM_USE_NOT_FULL"] = "使用不完整的堆疊填充"
L["OPTIONS_ITEM_USE_NOT_FULL_DESC"] =
	"當無法湊齊完整堆疊時，使用背包裡現有的零散數量進行填充。"
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "考慮使用等級要求"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] = "當交易對象未達到該物品的使用等級時，跳過該物品。"
L["OPTIONS_ITEM_KEEP_AT_LEAST"] = "最少保留數量"
L["OPTIONS_ITEM_KEEP_AT_LEAST_DESC"] =
	"始終在背包中保留至少這麼多。分發和通報巨集會將超出該數量的部分視為可贈送。"
L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "在喊話巨集中包含剩餘數量"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] =
	"當巨集列出此物品時，包含你還剩下多少。如果你只想說你有該物品而不提數量（如治療石），請關閉此選項。"
L["OPTIONS_ITEM_PLAYER_CLASSES"] = "僅在遊玩指定職業時分發"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] =
	"僅當你的角色是以下所選職業時，才會填充該物品並將其加入喊話中。"
L["OPTIONS_ITEM_REMOVE"] = "移除物品"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "是否從交易配置中移除此物品？"

L["OPTIONS_SCOPE_SOLO"] = "陌生人"
L["OPTIONS_SCOPE_GROUP"] = "隊伍成員"
L["OPTIONS_SCOPE_RAID"] = "團隊成員"

L["OPTIONS_ADD_ITEM"] = "新增物品"
L["OPTIONS_ADD_DESC"] =
	"從背包中選擇一個可交易的消耗品加到配置中。已配置或已綁定的物品不會出現在此處。"
L["OPTIONS_ADD_SELECT"] = "可用物品"
L["OPTIONS_ADD_BUTTON"] = "加入配置"
L["OPTIONS_ADD_EMPTY"] = "背包中未找到符合條件的消耗品。"

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["OPTIONS_ANNOUNCEMENTS"] = "喊話"
L["OPTIONS_ANNOUNCEMENTS_DESC"] =
	"Water Dispenser 可以建立一個巨集，通報你還有什麼可以分發。該巨集會自動選擇頻道（未組隊時說話，隊伍中為小隊，團隊中為團隊），並使用背包中的最新數量。"
L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "啟用喊話巨集"
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] =
	"維護一個名為「- Dispenser」的角色專屬巨集，其中包含最新的分發清單。停用此選項將刪除該巨集。"
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_HEADER"] = "即時預覽"
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DESC"] = "如果你現在點擊巨集，它將發送以下內容。"
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] =
	"沒有可喊話的內容。配置物品，補充背包，或降低「最少保留數量」的值。"

-- Macro message template (%s is the item list) and the connector before the last list entry.
L["ANNOUNCEMENTS_BODY"] = "我有 %s。點我交易！"
L["ANNOUNCEMENTS_AND"] = "和"

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["OPTIONS_SUPPORT"] = "回饋與支援"
L["SUPPORT_DESC"] = "在 Discord 上報告問題、請求功能或來打個招呼吧。"
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"
L["SUPPORT_WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Built-in Collections
--------------------------------------------------------------------------------

L["ITEM_MAGE_WATER"] = "魔法製造的水"
L["ITEM_MAGE_FOOD"] = "魔法製造的食物"
L["ITEM_WARLOCK_HEALTHSTONE"] = "治療石"
