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

--[[
	All player-facing chat prints live here, regardless of which feature emits them.
	%s is the add-on version; the menu path is the game client's own labels.
]]
L["CHAT_LOADED"] =
	"版本 %s。設定（包含關閉此訊息的選項）可以在 選項 > 插件 > Water Dispenser 中找到。喜歡這個插件嗎？分享給你的朋友吧！(="
L["CHAT_NO_TRADE"] = "沒有已開啟的交易視窗。"
L["CHAT_COMBAT_BLOCKED"] = "魔獸世界會在戰鬥中阻止自動交易。"
L["CHAT_OPTIONS_IN_COMBAT"] = "基於安全考量，戰鬥中無法開啟選項介面。"
-- The item and its count are appended after the colon by the code.
L["CHAT_MISSING_STACK"] = "缺少："
--[[
	%s is the item's name, %d the Maximum per Session it has hit.
	"Maximum per Session" must match OPTIONS_ITEM_SESSION_CAP.
]]
L["CHAT_SESSION_CAP_REACHED"] =
	"%s 未加入：本次登入他已經拿到了 %d 個。請調整每次登入上限，或重新載入以重置。"
-- %s is the item's name, %d the amount that could not be split off.
L["CHAT_SPLIT_REFUSED"] =
	"%s 未加入：此客戶端無法從一疊中拆出 %d 個，而直接給出整疊會送出遠超你設定的數量。請把此物品的數量設為一整疊才能交易。"
-- %s is the player's class name. "Dispensed Items" must match TAB_DISPENSED_ITEMS.
L["CHAT_NONE_ACTIVE_FOR_CLASS"] =
	"當你使用 %s 遊玩時，沒有設定任何要分發的物品。請打開 選項 > 分發物品 啟用適用於此職業的物品。"
-- "- Dispenser" is the macro's literal name and is never translated.
L["CHAT_MACRO_DELETED"] = '喊話巨集 "- Dispenser" 已刪除。'
L["CHAT_MACRO_FULL"] = "無法建立巨集：角色專屬巨集數量已達上限。"

--------------------------------------------------------------------------------
-- Player Tooltips
--------------------------------------------------------------------------------

L["TOOLTIP_OPEN_TRADE"] = "點我交易！"
-- %d/%d is the warlock's Improved Healthstone rank out of its maximum.
L["TOOLTIP_HEALTHSTONE"] = "治療石（等級 %d/%d）"

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BUTTON_CLEAR"] = "清空交易視窗"
L["BUTTON_FILL"] = "填充交易視窗"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

-- The tooltip's feature row reuses TAB_DISPENSE for its name; these are its state and click words.
L["UI_ENABLED"] = "已啟用"
L["UI_DISABLED"] = "已停用"
L["UI_LEFT_CLICK"] = "左鍵點擊"
L["UI_TOGGLE"] = "切換"
L["MINIMAP_OPTIONS"] = "Water Dispenser 選項"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + 中鍵點擊"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"輕鬆分發消耗品。自動用水、食物和治療石填充交易視窗。你還可以加入任何想給出的物品，例如沙漏之沙或各類抗性藥水，分發給你的團隊。"

L["OPTIONS_WELCOME_MESSAGE"] = "啟用歡迎訊息"
L["OPTIONS_WELCOME_MESSAGE_DESC"] = "當 Water Dispenser 載入時，在聊天框輸出一行問候語。"
L["OPTIONS_MINIMAP"] = "啟用小地圖按鈕"
L["OPTIONS_MINIMAP_DESC"] = "顯示 Water Dispenser 小地圖按鈕。"
L["OPTIONS_MISSING_STACK_WARNINGS"] = "庫存不足時啟用警告"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] =
	"當背包中已設定物品的數量不足以給出你設定的數量時，在聊天框中輸出提示。"
-- The label says what it does; the tooltip only covers why it is needed and when it stands down.
L["OPTIONS_RESTACK"] = "自動合併背包中的零散堆疊"
L["OPTIONS_RESTACK_DESC"] =
	"製造的水和食物每次施放都會落在新的背包格中，遊戲從不會把它們合回去，不過在戰鬥中、交易視窗開啟時或你的游標上拿著東西時都不會執行。"

L["OPTIONS_COMMANDS_HEADER"] = "/指令"
L["OPTIONS_COMMAND"] = "/wd"
L["OPTIONS_COMMAND_DESCRIPTION"] = "開啟本插件的選項介面。"

-- Names the panel, its section header, and the mini-map tooltip's feature row.
L["TAB_DISPENSE"] = "分發"
L["OPTIONS_DISPENSE_DESC"] = "開啟交易時自動填充交易視窗。"
L["OPTIONS_DISPENSE_MASTER"] = "啟用分發"
L["OPTIONS_DISPENSE_MASTER_DESC"] = "根據你的設定自動填充交易視窗。"
L["OPTIONS_DISPENSE_SOLO"] = "對陌生人啟用"
L["OPTIONS_DISPENSE_SOLO_DESC"] = "當與不在隊伍或團隊中的玩家交易時，自動填充交易視窗。"
L["OPTIONS_DISPENSE_GROUP"] = "對隊伍啟用"
L["OPTIONS_DISPENSE_GROUP_DESC"] = "當與隊伍成員交易時，自動填充交易視窗。"
L["OPTIONS_DISPENSE_RAID"] = "對團隊啟用"
L["OPTIONS_DISPENSE_RAID_DESC"] = "當與團隊成員交易時，自動填充交易視窗。"

L["TAB_INVENTORY_TOOLTIPS"] = "庫存提示"
L["OPTIONS_TOOLTIPS_DESC"] = "在使用 Water Dispenser 的隊友的玩家提示資訊中顯示可分發的庫存。"
L["OPTIONS_SHOW_INVENTORY"] = "在玩家提示中顯示庫存"
L["OPTIONS_SHOW_INVENTORY_DESC"] =
	"在玩家提示資訊中加入一個 Water Dispenser 區塊，列出他們設定為分發的內容以及攜帶的數量，而無論是否組隊，你自己的庫存都會永遠顯示。"
L["OPTIONS_SHARE_INVENTORY"] = "分享我的庫存"
L["OPTIONS_SHARE_INVENTORY_DESC"] =
	"告知你的隊伍和團隊你攜帶了什麼，這樣別人把滑鼠移到你身上時就能看到你的庫存，同時不會向聊天頻道發送任何內容，隊伍之外的人也不會知道，而且關閉後你依然可以查看別人的庫存。"

L["OPTIONS_COMBAT_HEADER"] = "戰鬥"
L["OPTIONS_COMBAT_DESC"] = "魔獸世界禁止插件在戰鬥中將物品放入交易視窗。"
L["OPTIONS_COMBAT_NOTIFY"] = "分發被阻止時啟用提示"
L["OPTIONS_COMBAT_NOTIFY_DESC"] =
	"當戰鬥導致交易無法填充時，在聊天框中輸出提示，而關閉後 Water Dispenser 不會再說明交易為何仍是空的。"

--------------------------------------------------------------------------------
-- Options — Dispensed Items
--------------------------------------------------------------------------------

L["TAB_DISPENSED_ITEMS"] = "分發物品"
L["OPTIONS_ITEMS_DESC"] =
	"設定每種物品分發多少。數量按單個物品計算，所以 20 個水就是 20 個水，1 個藥水就是 1 個藥水。必要時會把一疊拆分到精確數量。"
-- "Add an Item" must match OPTIONS_ADD_ITEM.
L["OPTIONS_ITEMS_EMPTY"] = '未設定物品。請在清單中選擇 "新增物品"，從背包中加入消耗品。'

L["OPTIONS_ITEM_DISTRIBUTION"] = "分發數量"
L["OPTIONS_ITEM_DISTRIBUTION_DESC"] =
	"按對方是陌生人、你的隊伍成員還是團隊成員，選擇每個職業各拿多少。按單個物品計算，而非按疊。填 0 表示他們永遠拿不到這個物品。"
L["OPTIONS_ITEM_EVERYONE"] = "所有人"
L["OPTIONS_ITEM_EVERYONE_DESC"] =
	"按下 Enter 即可一次為所有職業設定這個數量，當下方各職業的數值不一致時會顯示為空白。"
-- The accept button inside every number box in this panel.
L["OPTIONS_ITEM_APPLY"] = "套用"
-- %d is the highest amount this item accepts, which is 1 for anything unique.
L["OPTIONS_ITEM_COUNT_TOO_HIGH"] = "超過了此物品可分發的數量。最多為 %d。"
L["OPTIONS_ITEM_COUNT_INVALID"] = "請輸入物品數量，或輸入 0 表示永不分發。"
L["OPTIONS_ITEM_SETTINGS"] = "物品設定"
-- "In Group" and "In Raid" in the tooltip must match the two dropdown entries below.
L["OPTIONS_ITEM_DISTRIBUTE"] = "分發範圍"
L["OPTIONS_ITEM_DISTRIBUTE_DESC"] =
	"設定此物品在什麼情況下才會送出，超出所選範圍時它既不會被交易，也不會被喊話，更不會顯示在你的提示中，其中隊伍中同時涵蓋隊伍和團隊，團隊中則僅限團隊。"
-- Dropdown entries. The stored values are "Always", "Group", and "Raid"; these are only their labels.
L["OPTIONS_ITEM_DISTRIBUTE_ALWAYS"] = "永遠"
L["OPTIONS_ITEM_DISTRIBUTE_GROUP"] = "隊伍中"
L["OPTIONS_ITEM_DISTRIBUTE_RAID"] = "團隊中"
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "考慮使用等級需求"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] = "當交易對象未達到該物品的使用等級時，跳過該物品。"
L["OPTIONS_ITEM_RESERVE"] = "啟用保留數量"
L["OPTIONS_ITEM_RESERVE_DESC"] =
	"永遠在背包中至少保留這麼多，而分發和喊話巨集會把超出這個數量的部分視為可以送出的。"
L["OPTIONS_ITEM_SESSION_CAP"] = "啟用每次登入上限"
L["OPTIONS_ITEM_SESSION_CAP_DESC"] =
	"當某人從你這裡拿到這麼多之後就不再給他這個物品，跨所有交易累計，直到你登出或重新載入為止，而修改此物品的任何數量都會讓所有人的計數重新開始。"
-- The label carries the meaning on its own; the tooltip only says why you'd switch it off.
L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "在玩家提示和喊話巨集中顯示數量"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] =
	"關閉後只顯示物品名稱而不帶數量，這對治療石這類你只會隨身帶一個的物品讀起來更自然。"
L["OPTIONS_ITEM_PLAYER_CLASSES"] = "僅在使用這些職業時分發"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] =
	"僅當你的角色職業在下方被選取時，才填充交易、把此物品寫進喊話巨集，並顯示在你的玩家提示中。"
L["OPTIONS_ITEM_REMOVE"] = "移除物品"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "是否從交易設定中移除此物品？"

L["OPTIONS_SCOPE_SOLO"] = "陌生人"
L["OPTIONS_SCOPE_GROUP"] = "隊伍"
L["OPTIONS_SCOPE_RAID"] = "團隊"

L["OPTIONS_ADD_ITEM"] = "新增物品"
L["OPTIONS_ADD_DESC"] =
	"從背包中選擇任何可交易物品加入交易設定。已設定或已靈魂綁定的物品不會出現在這裡。"
L["OPTIONS_ADD_SELECT"] = "可用物品"
L["OPTIONS_ADD_BUTTON"] = "加入設定"
L["OPTIONS_ADD_EMPTY"] = "背包中沒有找到可交易的物品。"

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["TAB_ANNOUNCEMENTS"] = "喊話"
L["OPTIONS_ANNOUNCEMENTS_DESC"] =
	"Water Dispenser 可以建立一個巨集，通報你還有什麼可以分發。該巨集會自動選擇頻道（未組隊時說話，隊伍中為隊伍，團隊中為團隊），並直接使用背包中的最新數量。"
L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "啟用喊話巨集"
-- "- Dispenser" is the macro's literal name and is never translated.
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] =
	'維護一個名為 "- Dispenser" 的角色專屬巨集，使其與你目前的分發清單保持同步，並在你關閉此選項時刪除該巨集。'
-- "Enable Reserves" must match OPTIONS_ITEM_RESERVE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] =
	"沒有可喊話的內容。設定物品，補充背包，或在啟用保留數量中調低保留值。"

-- Macro message template (%s is the item list) and the connector before the last list entry.
L["ANNOUNCEMENTS_BODY"] = "我有 %s。點我交易！"
L["ANNOUNCEMENTS_AND"] = "和"

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["OPTIONS_SUPPORT"] = "意見與支援"
-- Precedes the version number on the General panel's last line.
L["VERSION"] = "版本"
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"
L["SUPPORT_WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Built-in Collections
--------------------------------------------------------------------------------

L["ITEM_MAGE_WATER"] = "製造的水"
L["ITEM_MAGE_FOOD"] = "製造的食物"
L["ITEM_WARLOCK_HEALTHSTONE"] = "治療石"
