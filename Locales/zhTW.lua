local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "zhTW")
if not L then return end

L["CHAT_LOADED"] = "已啟用。輸入 %s 來開啟設定，或關閉此訊息。喜歡 Water Dispenser 嗎？分享給你的朋友吧！(="
L["CHAT_NO_TRADE"] = "沒有開啟的交易視窗。"
L["CHAT_COMBAT_PAUSED"] = "戰鬥中已暫停自動填入。"
L["CHAT_COMBAT_RESUMED"] = "戰鬥結束。恢復交易填入。"
L["CHAT_MISSING_STACK"] = "缺失的堆疊數："
L["CHAT_ITEM_SAVED"] = "已儲存："
L["CHAT_ITEM_REMOVED"] = "已移除："

L["BTN_CLEAR"] = "清除交易"
L["BTN_FILL"] = "填入交易"
L["BTN_CONFIG"] = "選項"
L["BTN_ACCEPT"] = "接受交易"

L["OPTIONS_TITLE"] = "Water Dispenser"
L["OPTIONS_DESC"] = "根據交易對象的職業、等級和隊伍狀態，自動用設定好的水、食物、治療石或其他消耗品來填滿交易視窗。"

L["OPTIONS_GENERAL_HEADER"] = "一般設定"
L["OPTIONS_WELCOME_MESSAGE"] = "啟用歡迎訊息"
L["OPTIONS_WELCOME_MESSAGE_DESC"] = "當 Water Dispenser 載入時，在聊天框顯示一行簡單的問候語。"
L["OPTIONS_MISSING_STACK_WARNINGS"] = "顯示堆疊不足警告"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] = "當背包中設定的物品不足以填滿交易視窗時，在聊天視窗中輸出提示。"
L["OPTIONS_ITEMS"] = "分發規則"
L["OPTIONS_ADD_ITEM"] = "新增物品"
L["OPTIONS_SUPPORT"] = "反饋與支援"

L["OPTIONS_AUTOFILL_HEADER"] = "自動填入"
L["OPTIONS_AUTOFILL_DESC"] = "在開啟交易視窗時自動填入。每種範圍皆可獨立切換。"
L["OPTIONS_AUTOFILL_SOLO"] = "為陌生人填入"
L["OPTIONS_AUTOFILL_SOLO_DESC"] = "當與不在隊伍或團隊中的玩家交易時，自動填入交易視窗。"
L["OPTIONS_AUTOFILL_GROUP"] = "為隊伍成員填入"
L["OPTIONS_AUTOFILL_GROUP_DESC"] = "當與隊伍成員交易時，自動填入交易視窗。"
L["OPTIONS_AUTOFILL_RAID"] = "為團隊成員填入"
L["OPTIONS_AUTOFILL_RAID_DESC"] = "當與團隊成員交易时，自動填入交易視窗。"

L["OPTIONS_COMBAT_HEADER"] = "戰鬥"
L["OPTIONS_COMBAT_DESC"] = "為了防止出現介面錯誤，進入戰鬥時自動填入功能將始終暫停，並在聊天框發送提醒。脫離戰鬥後，如果交易視窗依然處於開啟狀態，交易將自動恢復。"

L["OPTIONS_LOCKED_HEADER"] = "盜賊保險箱"
L["OPTIONS_LOCKED_DESC"] = "當與盜賊交易時，將背包中找到的第一個上鎖物品放入交易介面底部的「不可交易」欄位，以便他們進行開鎖。"
L["OPTIONS_LOCKED"] = "提供上鎖物品給盜賊"

L["OPTIONS_RESET_HEADER"] = "重置"
L["OPTIONS_RESET_DESC"] = "將目前角色的所有 Water Dispenser 設定恢復為預設值，包括你的自訂物品清單。"
L["OPTIONS_RESET_BUTTON"] = "重置所有選項"
L["OPTIONS_RESET_CONFIRM"] = "你確定要將目前角色的所有 Water Dispenser 設定恢復為預設值嗎？"

L["OPTIONS_COMMANDS_HEADER"] = "/指令"
L["OPTIONS_COMMANDS_DESC"] = "Water Dispenser 的文字指令。選項面板涵蓋了你需要的所有功能；這些指令專為習慣使用鍵盤操作的玩家提供。"
L["OPTIONS_COMMAND_WD"] = "/wd"
L["OPTIONS_COMMAND_WD_DESC"] = "開啟 Water Dispenser 選項介面。"
L["OPTIONS_COMMAND_WD_FILL"] = "/wd fill"
L["OPTIONS_COMMAND_WD_FILL_DESC"] = "立即填滿交易視窗，即使目前交易對象的自動填入已關閉。"
L["OPTIONS_COMMAND_WD_CLEAR"] = "/wd clear"
L["OPTIONS_COMMAND_WD_CLEAR_DESC"] = "清空交易視窗中的所有欄位。"
L["OPTIONS_COMMAND_WD_AUTO"] = "/wd auto solo||group||raid on||off"
L["OPTIONS_COMMAND_WD_AUTO_DESC"] = "切換指定範圍的自動填入功能。省略 on/off 則進行狀態反轉。"
L["OPTIONS_COMMAND_WDA"] = "/wda"
L["OPTIONS_COMMAND_WDA_DESC"] = "根據你目前的隊伍狀態，向正確的頻道發送廣播訊息。"

L["CHAT_RESET"] = "所有選項已重置為預設值。"

L["OPTIONS_ITEMS_DESC"] = "設定要分發每種物品的堆疊數量。注意：經典版和 TBC 紀念服不支援自動拆分堆疊。抱歉！"
L["OPTIONS_ITEMS_EMPTY"] = "未設定物品。請開啟「新增物品」分頁，從背包中新增消耗品。"

L["OPTIONS_ITEM_SETTINGS"] = "物品設定"
L["OPTIONS_ITEM_USE_NOT_FULL"] = "使用不完整的堆疊填入"
L["OPTIONS_ITEM_USE_NOT_FULL_DESC"] = "當無法湊齊完整堆疊時，使用背包裡現有的零散數量進行填入。"

L["OPTIONS_ITEM_FACTOR_LEVEL"] = "考量使用等級要求"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] = "當交易對象未達到該物品的使用等級時，跳過該物品。"

L["OPTIONS_ITEM_KEEP_AT_LEAST"] = "最少保留數量"
L["OPTIONS_ITEM_KEEP_AT_LEAST_DESC"] = "包包裡始終至少保留這些數量。只有超過此數量的部分才會被視為可贈送的物品。"

L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "在廣播巨集中包含剩餘數量"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] = "當巨集列出此物品時，包含你還剩下多少。如果你只想說你有該物品而不提數量（例如治療石），請關閉此選項。"

L["OPTIONS_ITEM_PLAYER_CLASSES"] = "僅在遊玩指定職業時分發"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] = "僅當你的角色是以下所選職業時，才會填入該物品並將其加入廣播中。"

L["OPTIONS_ITEM_REMOVE"] = "移除物品"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "是否從交易設定中移除此物品？"

L["OPTIONS_SCOPE_SOLO"] = "陌生人"
L["OPTIONS_SCOPE_GROUP"] = "隊伍成員"
L["OPTIONS_SCOPE_RAID"] = "團隊成員"

L["OPTIONS_ADD_DESC"] = "從背包中選擇一個可交易的消耗品新增到設定中。已設定或已綁定的物品不會出現在此處。"
L["OPTIONS_ADD_SELECT"] = "可用物品"
L["OPTIONS_ADD_BUTTON"] = "新增到設定"
L["OPTIONS_ADD_EMPTY"] = "背包中未找到符合條件的消耗品。"

L["SUPPORT_DESC"] = "在 Discord 上報告問題、請求功能或來打個招呼吧。"
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"

L["OPTIONS_ANNOUNCEMENTS"] = "廣播"
L["OPTIONS_ANNOUNCEMENTS_DESC"] = "Water Dispenser 可以建立一個巨集，喊出你可以提供的物品。巨集會自動選擇合適的頻道（/說、/隊伍、/團隊），並使用背包中的最新數量。"

L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "啟用廣播巨集"
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] = "維護一個名為「- Dispenser」的角色專屬巨集，其中包含最新的分發清單。停用此選項將刪除該巨集。"

L["OPTIONS_ANNOUNCEMENTS_PREVIEW_HEADER"] = "即時預覽"
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DESC"] = "如果你現在點擊巨集，它將發送以下內容。"
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] = "沒有可廣播的內容。設定物品，補充背包，或降低「最少保留數量」的值。"

L["ANNOUNCEMENTS_INTRO"] = "我有"
L["ANNOUNCEMENTS_OUTRO"] = "。點我交易！"
L["ANNOUNCEMENTS_AND"] = "和"

L["CHAT_MACRO_CREATED"] = "廣播巨集「- Dispenser」已準備就緒。開啟巨集介面（/m），將其拖曳到快捷列上即可使用。"
L["CHAT_MACRO_DELETED"] = "廣播巨集「- Dispenser」已刪除。"
L["CHAT_MACRO_FULL"] = "無法建立巨集：角色專屬巨集數量已達上限。"
L["CHAT_NOTHING_TO_ANNOUNCE"] = "現在沒有可廣播的內容。"

L["ITEM_MAGE_WATER"] = "任何魔法製造的水"
L["ITEM_MAGE_FOOD"] = "任何魔法製造的食物"
L["ITEM_WARLOCK_HEALTHSTONE"] = "任何治療石"