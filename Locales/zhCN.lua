local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "zhCN")
if not L then return end

L["CHAT_LOADED"] = "已启用。输入 %s 以访问设置，或关闭此信息。喜欢 Water Dispenser 吗？分享给你的朋友吧！(="
L["CHAT_NO_TRADE"] = "没有打开的交易窗口。"
L["CHAT_COMBAT_PAUSED"] = "战斗中已暂停自动填充。"
L["CHAT_COMBAT_RESUMED"] = "战斗结束。恢复交易填充。"
L["CHAT_MISSING_STACK"] = "缺失的堆叠数："
L["CHAT_ITEM_SAVED"] = "已保存："
L["CHAT_ITEM_REMOVED"] = "已移除："

L["BTN_CLEAR"] = "清空交易"
L["BTN_FILL"] = "填充交易"
L["BTN_CONFIG"] = "选项"
L["BTN_ACCEPT"] = "接受交易"

L["OPTIONS_TITLE"] = "Water Dispenser"
L["OPTIONS_DESC"] = "根据交易对象的职业、等级和队伍状态，自动用设定好的水、食物、治疗石或其他消耗品来填充交易窗口。"

L["OPTIONS_GENERAL_HEADER"] = "常规设置"
L["OPTIONS_WELCOME_MESSAGE"] = "启用欢迎信息"
L["OPTIONS_WELCOME_MESSAGE_DESC"] = "当 Water Dispenser 加载时，在聊天框显示一行简单的问候语。"
L["OPTIONS_MISSING_STACK_WARNINGS"] = "显示堆叠不足警告"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] = "当背包中配置的物品不足以填满交易窗口时，在聊天框中输出提示。"
L["OPTIONS_ITEMS"] = "分发规则"
L["OPTIONS_ADD_ITEM"] = "添加物品"
L["OPTIONS_SUPPORT"] = "反馈与支持"

L["OPTIONS_AUTOFILL_HEADER"] = "自动填充"
L["OPTIONS_AUTOFILL_DESC"] = "在打开交易窗口时自动填充。每种范围均可独立切换。"
L["OPTIONS_AUTOFILL_SOLO"] = "为陌生人填充"
L["OPTIONS_AUTOFILL_SOLO_DESC"] = "当与不在队伍或团队中的玩家交易时，自动填充交易窗口。"
L["OPTIONS_AUTOFILL_GROUP"] = "为小队成员填充"
L["OPTIONS_AUTOFILL_GROUP_DESC"] = "当与小队成员交易时，自动填充交易窗口。"
L["OPTIONS_AUTOFILL_RAID"] = "为团队成员填充"
L["OPTIONS_AUTOFILL_RAID_DESC"] = "当与团队成员交易时，自动填充交易窗口。"

L["OPTIONS_COMBAT_HEADER"] = "战斗"
L["OPTIONS_COMBAT_DESC"] = "为了防止出现界面错误，进入战斗时自动填充功能将始终暂停，并在聊天框发送提醒。脱离战斗后，如果交易窗口依然处于开启状态，交易将自动恢复。"

L["OPTIONS_LOCKED_HEADER"] = "潜行者宝箱"
L["OPTIONS_LOCKED_DESC"] = "当与潜行者交易时，将背包中找到的第一个上锁物品放入交易界面底部的“不可交易”栏位，以便他们进行开锁。"
L["OPTIONS_LOCKED"] = "提供上锁物品给潜行者"

L["OPTIONS_RESET_HEADER"] = "重置"
L["OPTIONS_RESET_DESC"] = "将当前角色的所有 Water Dispenser 设置恢复为默认值，包括你的自定义物品列表。"
L["OPTIONS_RESET_BUTTON"] = "重置所有选项"
L["OPTIONS_RESET_CONFIRM"] = "你确定要将当前角色的所有 Water Dispenser 设置恢复为默认值吗？"

L["OPTIONS_COMMANDS_HEADER"] = "/命令行"
L["OPTIONS_COMMANDS_DESC"] = "Water Dispenser 的文本命令。选项面板涵盖了你需要的所有功能；这些命令专为习惯使用键盘操作的玩家提供。"
L["OPTIONS_COMMAND_WD"] = "/wd"
L["OPTIONS_COMMAND_WD_DESC"] = "打开 Water Dispenser 选项界面。"
L["OPTIONS_COMMAND_WD_FILL"] = "/wd fill"
L["OPTIONS_COMMAND_WD_FILL_DESC"] = "立即填充交易窗口，即使当前交易对象的自动填充已关闭。"
L["OPTIONS_COMMAND_WD_CLEAR"] = "/wd clear"
L["OPTIONS_COMMAND_WD_CLEAR_DESC"] = "清空交易窗口中的所有栏位。"
L["OPTIONS_COMMAND_WD_AUTO"] = "/wd auto solo||group||raid on||off"
L["OPTIONS_COMMAND_WD_AUTO_DESC"] = "切换指定范围的自动填充功能。省略 on/off 则进行状态反转。"
L["OPTIONS_COMMAND_WDA"] = "/wda"
L["OPTIONS_COMMAND_WDA_DESC"] = "根据你当前的队伍状态，向正确的频道发送喊话消息。"

L["CHAT_RESET"] = "所有选项已重置为默认值。"

L["OPTIONS_ITEMS_DESC"] = "配置要分发每种物品的堆叠数量。注意：永久 60 级和 TBC 纪念服不支持自动拆分堆叠。抱歉！"
L["OPTIONS_ITEMS_EMPTY"] = "未配置物品。请打开“添加物品”标签页，从背包中添加消耗品。"

L["OPTIONS_ITEM_SETTINGS"] = "物品设置"
L["OPTIONS_ITEM_USE_NOT_FULL"] = "使用不完整的堆叠填充"
L["OPTIONS_ITEM_USE_NOT_FULL_DESC"] = "当无法凑齐完整堆叠时，使用背包里现有的零散数量进行填充。"

L["OPTIONS_ITEM_FACTOR_LEVEL"] = "考虑使用等级要求"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] = "当交易对象未达到该物品的使用等级时，跳过该物品。"

L["OPTIONS_ITEM_KEEP_AT_LEAST"] = "最少保留数量"
L["OPTIONS_ITEM_KEEP_AT_LEAST_DESC"] = "包里始终至少保留这些数量。只有超过此数量的部分才会被视为可赠送的物品。"

L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "在喊话宏中包含剩余数量"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] = "当宏列出此物品时，包含你还剩下多少。如果你只想说你有该物品而不提数量（如治疗石），请关闭此选项。"

L["OPTIONS_ITEM_PLAYER_CLASSES"] = "仅在游玩指定职业时分发"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] = "仅当你的角色是以下所选职业时，才会填充该物品并将其加入喊话中。"

L["OPTIONS_ITEM_REMOVE"] = "移除物品"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "是否从交易配置中移除此物品？"

L["OPTIONS_SCOPE_SOLO"] = "陌生人"
L["OPTIONS_SCOPE_GROUP"] = "小队成员"
L["OPTIONS_SCOPE_RAID"] = "团队成员"

L["OPTIONS_ADD_DESC"] = "从背包中选择一个可交易的消耗品添加到配置中。已配置或已绑定的物品不会出现在此处。"
L["OPTIONS_ADD_SELECT"] = "可用物品"
L["OPTIONS_ADD_BUTTON"] = "添加到配置"
L["OPTIONS_ADD_EMPTY"] = "背包中未找到符合条件的消耗品。"

L["SUPPORT_DESC"] = "在 Discord 上报告问题、请求功能或来打个招呼吧。"
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"

L["OPTIONS_ANNOUNCEMENTS"] = "喊话"
L["OPTIONS_ANNOUNCEMENTS_DESC"] = "Water Dispenser 可以创建一个宏，喊出你可以提供的物品。宏会自动选择合适的频道（/说、/小队、/团队），并使用背包中的最新数量。"

L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "启用喊话宏"
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] = "维护一个名为“- Dispenser”的角色专属宏，其中包含最新的分发列表。禁用此选项将删除该宏。"

L["OPTIONS_ANNOUNCEMENTS_PREVIEW_HEADER"] = "实时预览"
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DESC"] = "如果你现在点击宏，它将发送以下内容。"
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] = "没有可喊话的内容。配置物品，补充背包，或降低“最少保留数量”的值。"

L["ANNOUNCEMENTS_INTRO"] = "我有"
L["ANNOUNCEMENTS_OUTRO"] = "。点我交易！"
L["ANNOUNCEMENTS_AND"] = "和"

L["CHAT_MACRO_CREATED"] = "喊话宏“- Dispenser”已准备就绪。打开宏界面（/m），将其拖放到动作条上即可使用。"
L["CHAT_MACRO_DELETED"] = "喊话宏“- Dispenser”已删除。"
L["CHAT_MACRO_FULL"] = "无法创建宏：角色专属宏数量已达上限。"
L["CHAT_NOTHING_TO_ANNOUNCE"] = "现在没有可喊话的内容。"

L["ITEM_MAGE_WATER"] = "任何魔法制造的水"
L["ITEM_MAGE_FOOD"] = "任何魔法制造的食物"
L["ITEM_WARLOCK_HEALTHSTONE"] = "任何治疗石"