local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "zhCN")
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
-- %s is the add-on version; the menu path is the game client's own labels.
L["CHAT_LOADED"] =
	"版本 %s。设置（包含关闭此信息的选项）可以在 选项 > 插件 > Water Dispenser 中找到。喜欢这个插件吗？分享给你的朋友吧！(="
L["CHAT_NO_TRADE"] = "没有已打开的交易窗口。"
L["CHAT_COMBAT_BLOCKED"] = "魔兽世界会在战斗中阻止自动交易。"
L["CHAT_OPTIONS_IN_COMBAT"] = "出于安全考虑，战斗中无法打开选项界面。"
-- The item and its count are appended after the colon by the code.
L["CHAT_MISSING_STACK"] = "缺少："
-- %s is the item's name, %d the Maximum per Session it has hit.
-- "Maximum per Session" must match OPTIONS_ITEM_SESSION_CAP.
L["CHAT_SESSION_CAP_REACHED"] =
	"%s 未加入：本次登录他已经拿到了 %d 个。请调整每次登录上限，或重新加载以重置。"
-- %s is the item's name, %d the amount that could not be split off.
L["CHAT_SPLIT_REFUSED"] =
	"%s 未加入：此客户端无法从一堆中拆出 %d 个，而直接给出整堆会送出远超你设定的数量。请把此物品的数量设为一整堆才能交易。"
-- %s is the player's class name. "Dispensed Items" must match TAB_DISPENSED_ITEMS.
L["CHAT_NONE_ACTIVE_FOR_CLASS"] =
	"当你使用 %s 游玩时，没有设置任何要分发的物品。请打开 选项 > 分发物品 启用适用于此职业的物品。"
-- The item's name is appended after the colon by the code.
L["CHAT_ITEM_SAVED"] = "已保存："
-- "- Dispenser" is the macro's literal name and is never translated.
L["CHAT_MACRO_DELETED"] = '喊话宏 "- Dispenser" 已删除。'
L["CHAT_MACRO_FULL"] = "无法创建宏：角色专属宏数量已达上限。"

--------------------------------------------------------------------------------
-- Player Tooltips
--------------------------------------------------------------------------------

L["TOOLTIP_OPEN_TRADE"] = "点我交易！"
-- %d/%d is the warlock's Improved Healthstone rank out of its maximum.
L["TOOLTIP_HEALTHSTONE"] = "治疗石（等级 %d/%d）"

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BUTTON_CLEAR"] = "清空交易窗口"
L["BUTTON_FILL"] = "填充交易窗口"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

-- The tooltip's feature row reuses OPTIONS_DISPENSE_HEADER for its name; these are its state and click words.
L["UI_ENABLED"] = "已启用"
L["UI_DISABLED"] = "已禁用"
L["UI_LEFT_CLICK"] = "左键点击"
L["UI_TOGGLE"] = "切换"
L["MINIMAP_OPTIONS"] = "Water Dispenser 选项"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + 中键点击"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"根据交易对象的职业、等级和队伍关系，按你设定的数量自动用水、食物、治疗石或任何你配置的消耗品填充交易窗口。"

L["OPTIONS_WELCOME_MESSAGE"] = "启用欢迎信息"
L["OPTIONS_WELCOME_MESSAGE_DESC"] = "当 Water Dispenser 加载时，在聊天框输出一行问候语。"
L["OPTIONS_MINIMAP"] = "启用小地图按钮"
L["OPTIONS_MINIMAP_DESC"] = "显示 Water Dispenser 小地图按钮。"
L["OPTIONS_MISSING_STACK_WARNINGS"] = "库存不足时启用警告"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] =
	"当背包中已配置物品的数量不足以给出你设定的数量时，在聊天框中输出提示。"
-- The label says what it does; the tooltip only covers why it is needed and when it stands down.
L["OPTIONS_RESTACK"] = "自动合并背包中的零散堆叠"
L["OPTIONS_RESTACK_DESC"] =
	"制造的水和食物每次施放都会落在新的背包格中，游戏从不会把它们合回去，不过在战斗中、交易窗口打开时或你的光标上拿着东西时都不会执行。"

L["OPTIONS_COMMANDS_HEADER"] = "/命令"
L["OPTIONS_COMMAND"] = "/wd"
L["OPTIONS_COMMAND_DESCRIPTION"] = "打开本插件的选项界面。"

L["OPTIONS_DISPENSE_HEADER"] = "分发"
L["OPTIONS_DISPENSE_DESC"] = "打开交易时自动填充交易窗口。下方每个选项均可单独开关。"
L["OPTIONS_DISPENSE_MASTER"] = "启用分发"
L["OPTIONS_DISPENSE_MASTER_DESC"] = "根据你的设置自动填充交易窗口。"
L["OPTIONS_DISPENSE_SOLO"] = "对陌生人启用"
L["OPTIONS_DISPENSE_SOLO_DESC"] = "当与不在队伍或团队中的玩家交易时，自动填充交易窗口。"
L["OPTIONS_DISPENSE_GROUP"] = "对小队启用"
L["OPTIONS_DISPENSE_GROUP_DESC"] = "当与小队成员交易时，自动填充交易窗口。"
L["OPTIONS_DISPENSE_RAID"] = "对团队启用"
L["OPTIONS_DISPENSE_RAID_DESC"] = "当与团队成员交易时，自动填充交易窗口。"

L["OPTIONS_TOOLTIPS_HEADER"] = "玩家提示中的库存"
L["OPTIONS_TOOLTIPS_DESC"] = "在使用 Water Dispenser 的队友的提示信息中显示可分发的库存。"
L["OPTIONS_SHOW_INVENTORY"] = "在玩家提示中显示库存"
L["OPTIONS_SHOW_INVENTORY_DESC"] =
	"在玩家提示信息中添加一个 Water Dispenser 区块，列出他们设置为分发的内容以及携带的数量，而无论是否组队，你自己的库存都会始终显示。"
L["OPTIONS_SHARE_INVENTORY"] = "分享我的库存"
L["OPTIONS_SHARE_INVENTORY_DESC"] =
	"告知你的小队和团队你携带了什么，这样别人指向你时就能看到你的库存，同时不会向聊天频道发送任何内容，队伍之外的人也不会知道，而且关闭后你依然可以查看别人的库存。"

L["OPTIONS_COMBAT_HEADER"] = "战斗"
L["OPTIONS_COMBAT_DESC"] = "魔兽世界禁止插件在战斗中将物品放入交易窗口。"
L["OPTIONS_COMBAT_NOTIFY"] = "分发被阻止时启用提示"
L["OPTIONS_COMBAT_NOTIFY_DESC"] =
	"当战斗导致交易无法填充时，在聊天框中输出提示，而关闭后 Water Dispenser 将保持沉默，不会说明交易为何仍是空的。"

--------------------------------------------------------------------------------
-- Options — Dispensed Items
--------------------------------------------------------------------------------

L["TAB_DISPENSED_ITEMS"] = "分发物品"
L["OPTIONS_ITEMS_DESC"] =
	"设置每种物品分发多少。数量按单个物品计算，所以 20 个水就是 20 个水，1 个药水就是 1 个药水。必要时会把一堆拆分到精确数量。"
-- "Add an Item" must match OPTIONS_ADD_ITEM.
L["OPTIONS_ITEMS_EMPTY"] = '未配置物品。请在列表中选择 "添加物品"，从背包中添加消耗品。'

L["OPTIONS_ITEM_DISTRIBUTION"] = "分发数量"
L["OPTIONS_ITEM_DISTRIBUTION_DESC"] =
	"按对方是陌生人、你的小队成员还是团队成员，选择每个职业各拿多少。按单个物品计算，而非按堆。填 0 表示他们永远拿不到这个物品。"
L["OPTIONS_ITEM_EVERYONE"] = "所有人"
L["OPTIONS_ITEM_EVERYONE_DESC"] =
	"按下回车即可一次性为所有职业设定这个数量，当下方各职业的数值不一致时会显示为空白。"
-- The accept button inside every number box in this panel.
L["OPTIONS_ITEM_APPLY"] = "应用"
-- %d is the highest amount this item accepts, which is 1 for anything unique.
L["OPTIONS_ITEM_COUNT_TOO_HIGH"] = "超过了此物品可分发的数量。最多为 %d。"
L["OPTIONS_ITEM_COUNT_INVALID"] = "请输入物品数量，或输入 0 表示永不分发。"
L["OPTIONS_ITEM_SETTINGS"] = "物品设置"
-- "In Group" and "In Raid" in the tooltip must match the two dropdown entries below.
L["OPTIONS_ITEM_DISTRIBUTE"] = "分发范围"
L["OPTIONS_ITEM_DISTRIBUTE_DESC"] =
	"设定此物品在什么情况下才会送出，超出所选范围时它既不会被交易，也不会被喊话，更不会显示在你的提示中，其中队伍中同时涵盖小队和团队，团队中则仅限团队。"
-- Dropdown entries. The stored values are "Always", "Group", and "Raid"; these are only their labels.
L["OPTIONS_ITEM_DISTRIBUTE_ALWAYS"] = "始终"
L["OPTIONS_ITEM_DISTRIBUTE_GROUP"] = "队伍中"
L["OPTIONS_ITEM_DISTRIBUTE_RAID"] = "团队中"
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "考虑使用等级要求"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] = "当交易对象未达到该物品的使用等级时，跳过该物品。"
L["OPTIONS_ITEM_RESERVE"] = "启用保留数量"
L["OPTIONS_ITEM_RESERVE_DESC"] =
	"始终在背包中至少保留这么多，而分发和喊话宏会把超出这个数量的部分视为可以送出的。"
L["OPTIONS_ITEM_SESSION_CAP"] = "启用每次登录上限"
L["OPTIONS_ITEM_SESSION_CAP_DESC"] =
	"当某人从你这里拿到这么多之后就不再给他这个物品，跨所有交易累计，直到你登出或重新加载为止，而修改此物品的任何数量都会让所有人的计数重新开始。"
-- The label carries the meaning on its own; the tooltip only says why you'd switch it off.
L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "在玩家提示和喊话宏中显示数量"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] =
	"关闭后只显示物品名称而不带数量，这对治疗石这类你只会随身带一个的物品读起来更自然。"
L["OPTIONS_ITEM_PLAYER_CLASSES"] = "仅在使用这些职业时分发"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] =
	"仅当你的角色职业在下方被选中时，才填充交易并将此物品加入喊话。"
L["OPTIONS_ITEM_REMOVE"] = "移除物品"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "是否从交易配置中移除此物品？"

L["OPTIONS_SCOPE_SOLO"] = "陌生人"
L["OPTIONS_SCOPE_GROUP"] = "小队"
L["OPTIONS_SCOPE_RAID"] = "团队"

L["OPTIONS_ADD_ITEM"] = "添加物品"
L["OPTIONS_ADD_DESC"] =
	"从背包中选择任意可交易物品加入交易配置。已配置或已灵魂绑定的物品不会出现在这里。"
L["OPTIONS_ADD_SELECT"] = "可用物品"
L["OPTIONS_ADD_BUTTON"] = "添加到配置"
L["OPTIONS_ADD_EMPTY"] = "背包中没有找到可交易的物品。"

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["TAB_ANNOUNCEMENTS"] = "喊话"
L["OPTIONS_ANNOUNCEMENTS_DESC"] =
	"Water Dispenser 可以创建一个宏，通报你还有什么可以分发。该宏会自动选择频道（未组队时说话，队伍中为小队，团队中为团队），并直接使用背包中的最新数量。"
L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "启用喊话宏"
-- "- Dispenser" is the macro's literal name and is never translated.
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] =
	'维护一个名为 "- Dispenser" 的角色专属宏，使其与你当前的分发清单保持同步，并在你关闭此选项时删除该宏。'
-- "Enable Reserves" must match OPTIONS_ITEM_RESERVE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] =
	"没有可喊话的内容。配置物品，补充背包，或在启用保留数量中调低保留值。"

-- Macro message template (%s is the item list) and the connector before the last list entry.
L["ANNOUNCEMENTS_BODY"] = "我有 %s。点我交易！"
L["ANNOUNCEMENTS_AND"] = "和"

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["OPTIONS_SUPPORT"] = "反馈与支持"
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"
L["SUPPORT_WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Built-in Collections
--------------------------------------------------------------------------------

L["ITEM_MAGE_WATER"] = "制造的水"
L["ITEM_MAGE_FOOD"] = "制造的食物"
L["ITEM_WARLOCK_HEALTHSTONE"] = "治疗石"
