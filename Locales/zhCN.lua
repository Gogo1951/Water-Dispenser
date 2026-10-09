local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "zhCN")
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
L["ITEM_LOADING"] = "正在加载 ID：%d"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

--[[
	All player-facing chat prints live here, regardless of which feature emits them.
	In CHAT_LOADED, %s is the add-on version and the menu path is the game client's
	own labels.
]]
L["CHAT_LOADED"] =
	"版本 %s。设置（包含关闭此信息的选项）可以在 选项 > 插件 > Water Dispenser 中找到。喜欢这个插件吗？分享给你的朋友吧！(="
L["CHAT_NO_TRADE"] = "没有已打开的交易窗口。"
L["CHAT_COMBAT_BLOCKED"] = "魔兽世界会在战斗中阻止自动交易。"
L["CHAT_OPTIONS_IN_COMBAT"] = "出于安全考虑，战斗中无法打开选项界面。"
-- The item and its count are appended after the colon by the code.
L["CHAT_MISSING_STACK"] = "缺少："
--[[
	%s is the item's name, then the trade partner's name; %d is the Maximum per
	Player they have reached.
]]
L["CHAT_PLAYER_CAP_REACHED"] =
	"%s 未添加：%s 已从你这里获得 %d 个。登出或重载界面后计数会重新开始。"
-- %s is the item's name; the first %d is the amount that could not be split off, the second the item's full stack size.
L["CHAT_SPLIT_NEEDS_FULL_STACK"] =
	"%s 未添加：游戏无法从一堆中拆出 %d 个。请将数量设为一整堆（%d）以交出该物品。"
-- %s is the player's class name. "Dispensed Items" must match TAB_DISPENSED_ITEMS.
L["CHAT_NONE_ACTIVE_FOR_CLASS"] =
	"当你使用 %s 游玩时，没有设置任何要分发的物品。请打开 选项 > 插件 > Water Dispenser > 分发物品 启用适用于此职业的物品。"
-- "- Dispenser" is the macro's literal name and is never translated.
L["CHAT_MACRO_DELETED"] = '喊话宏 "- Dispenser" 已删除。'
L["CHAT_MACRO_FULL"] = "无法创建喊话宏：角色专属宏数量已达上限。"

--------------------------------------------------------------------------------
-- Player Tooltips
--------------------------------------------------------------------------------

L["TOOLTIP_OPEN_TRADE"] = "点我交易！"
-- %s is the Improved Healthstone talent's name from the client, then the warlock's rank out of its maximum.
L["TOOLTIP_HEALTHSTONE_TALENT"] = "%s %d/%d"

--------------------------------------------------------------------------------
-- Bag Item Tooltips
--------------------------------------------------------------------------------

-- Shown on a carried bag item the player has set up to give away.
L["TOOLTIP_WILL_DISPENSE"] = "会在交易中送出。"

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BUTTON_CLEAR"] = "清空交易窗口"
L["BUTTON_FILL"] = "填充交易窗口"

--[[
	The silver status line under the trade panel's buttons. "Fill Trade Window" must
	match BUTTON_FILL. ADDED's %s is the window's contents, each FORMAT_ITEM_COUNT,
	joined like the announcement's list. In the rest, %s is an item or collection
	name unless noted.
]]
L["TRADE_STATUS_ADDED"] = "已添加 %s。"
-- %d is how many short.
L["TRADE_STATUS_SHORT"] = "缺少 %d 个 %s：背包中数量不足。"
L["TRADE_STATUS_SHORT_RESERVE"] = "缺少 %d 个 %s：其余部分由保留数量保留。"
L["TRADE_STATUS_DISPENSE_OFF"] = "自动填充已关闭。填充交易窗口仍会添加你通常的数量。"
L["TRADE_STATUS_OFF_STRANGERS"] =
	"对陌生人的自动填充已关闭。填充交易窗口仍会添加你通常的数量。"
L["TRADE_STATUS_OFF_PARTY"] =
	"对小队成员的自动填充已关闭。填充交易窗口仍会添加你通常的数量。"
L["TRADE_STATUS_OFF_RAID"] =
	"对团队成员的自动填充已关闭。填充交易窗口仍会添加你通常的数量。"
L["TRADE_STATUS_MASTER_LOOT"] =
	"你负责分配战利品时暂不填充。填充交易窗口仍会添加你通常的数量。"
-- The first %s is the partner's class name.
L["TRADE_STATUS_ZERO"] = "对 %s 设为 0：%s。"
L["TRADE_STATUS_INSTANCE_ONLY"] = "%s 只在副本中分发。"
L["TRADE_STATUS_GUILD_ONLY"] = "%s 只给你的公会成员。"
-- The partner's name, then the rank they can't use yet and its level.
L["TRADE_STATUS_LEVEL"] = "%s 无法使用你的 %s，需达到 %d 级。"
-- The partner's name first.
L["TRADE_STATUS_TOO_LOW"] = "%s 的等级太低，无法使用 %s。"
-- The partner's name first.
L["TRADE_STATUS_CAPPED"] = "%s 已拿满你给每位玩家的 %s 上限。"
L["TRADE_STATUS_NONE_HELD"] = "你没有可送出的 %s。"
L["TRADE_STATUS_CLEARED"] = "已清空。"
--[[
	A conjure button's tooltip, under the spell's name. MAKES: the item it makes,
	then the trade partner's name and level. LOWEST, when no rank fits the partner:
	the item only.
]]
L["TRADE_CONJURE_MAKES"] = "制造 %s，%s（%d 级）能使用的最高等级。"
L["TRADE_CONJURE_MAKES_LOWEST"] = "制造 %s，你已知的最低等级。"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

--[[
	The tooltip's feature row reuses TAB_DISPENSE for its name and
	OPTIONS_DISPENSE_MASTER_DESC for its description; these are its state and click words.
]]
L["UI_ENABLED"] = "已启用"
L["UI_DISABLED"] = "已禁用"
L["UI_LEFT_CLICK"] = "左键点击"
L["UI_TOGGLE"] = "切换"
L["MINIMAP_OPTIONS"] = "Water Dispenser 选项"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + 中键点击"
-- Heads the tooltip section listing what the player can give right now.
L["MINIMAP_DISPENSE_REPORT"] = "分发报告"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"轻松分发消耗品。自动用制造的水、食物和治疗石填充交易窗口，为每位玩家提供合适的等级和数量。添加任意物品，从沙漏之沙到抗性药水，几秒钟就能分发一整个团队的份量。"

L["OPTIONS_WELCOME_MESSAGE"] = "启用欢迎信息"
L["OPTIONS_WELCOME_MESSAGE_DESC"] = "当 Water Dispenser 加载时，在聊天框输出一行问候语。"
L["OPTIONS_MINIMAP"] = "启用小地图按钮"
L["OPTIONS_MINIMAP_DESC"] = "显示 Water Dispenser 小地图按钮。"

L["OPTIONS_FEATURES_HEADER"] = "功能"

L["OPTIONS_COMMANDS_HEADER"] = "/命令"
L["OPTIONS_COMMAND"] = "/wd"
L["OPTIONS_COMMAND_DESCRIPTION"] = "打开本插件的选项界面。"

--------------------------------------------------------------------------------
-- Options — Dispense
--------------------------------------------------------------------------------

-- Names the panel and the mini-map tooltip's feature row.
L["TAB_DISPENSE"] = "分发"
L["OPTIONS_DISPENSE_MASTER"] = "启用分发"
-- Also the panel's intro line and the mini-map tooltip's feature description.
L["OPTIONS_DISPENSE_MASTER_DESC"] = "打开交易时根据你的设置自动填充交易窗口。"
L["OPTIONS_DISPENSE_SOLO"] = "对陌生人启用"
L["OPTIONS_DISPENSE_SOLO_DESC"] = "当与不在队伍或团队中的玩家交易时，自动填充交易窗口。"
L["OPTIONS_DISPENSE_GROUP"] = "对小队启用"
L["OPTIONS_DISPENSE_GROUP_DESC"] = "当与小队成员交易时，自动填充交易窗口。"
L["OPTIONS_DISPENSE_RAID"] = "对团队启用"
L["OPTIONS_DISPENSE_RAID_DESC"] = "当与团队成员交易时，自动填充交易窗口。"
-- The label says what it does; the tooltip only covers why it is needed and when it stands down.
L["OPTIONS_RESTACK"] = "交易结束后合并零散堆叠"
L["OPTIONS_RESTACK_DESC"] =
	"制造的水和食物每次施放都会落在新的背包格中，游戏从不会把它们合回去，因此 Water Dispenser 会在交易窗口关闭后立即合并一次，而在其他任何时候、战斗中或你的光标上拿着东西时都绝不会这样做。"
L["OPTIONS_HOLD_MASTER_LOOT"] = "负责分配战利品时暂停"
-- "Fill Trade Window" must match BUTTON_FILL.
L["OPTIONS_HOLD_MASTER_LOOT_DESC"] =
	"当你在副本中负责分配战利品时，交易窗口保持为空，因为这些交易是用来分发战利品的。填充交易窗口仍会添加你通常的数量。"
L["OPTIONS_CONJURE_BUTTONS"] = "在交易旁显示制造按钮"
-- "Fill Trade Window" must match BUTTON_FILL.
L["OPTIONS_CONJURE_BUTTONS_DESC"] =
	"在填充交易窗口下方添加按钮，用于制造你的交易对象在其等级可以使用的水、食物或治疗石，制造出的物品会直接放入当前交易。"
L["OPTIONS_MISSING_STACK_WARNINGS"] = "库存不足时启用警告"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] =
	"当背包中已配置物品的数量不足以给出你设定的数量时，在聊天框中输出提示。"

-- Leads the silver line under a setting that shows the exact chat line it prints.
L["OPTIONS_EXAMPLE"] = "示例："

L["OPTIONS_COMBAT_HEADER"] = "战斗"
L["OPTIONS_COMBAT_DESC"] = "魔兽世界禁止插件在战斗中将物品放入交易窗口。"
L["OPTIONS_COMBAT_NOTIFY"] = "分发被阻止时启用提示"
L["OPTIONS_COMBAT_NOTIFY_DESC"] = "当战斗导致交易无法填充时，在聊天框中输出提示。"

--------------------------------------------------------------------------------
-- Options — Inventory Tooltips
--------------------------------------------------------------------------------

L["TAB_INVENTORY_TOOLTIPS"] = "库存提示"
L["OPTIONS_TOOLTIPS_DESC"] =
	"在玩家提示信息中显示使用 Water Dispenser 的队友设置为分发的内容，并在你自己的背包中标记你要分发的物品。"
L["OPTIONS_SHOW_INVENTORY"] = "在玩家提示中显示库存"
L["OPTIONS_SHOW_INVENTORY_DESC"] =
	"在玩家提示信息中添加一个 Water Dispenser 区块，列出他们设置为分发的内容以及可以送出的数量，而无论是否组队，你自己的库存都会始终显示。"
L["OPTIONS_BAG_TOOLTIPS"] = "为分发物品显示背包提示"
L["OPTIONS_BAG_TOOLTIPS_DESC"] =
	"当背包中的某个物品被设置为分发时，在它的提示信息中添加一行 Water Dispenser 说明，让你一眼就能看出插件会送出什么。"
L["OPTIONS_SHARE_INVENTORY"] = "分享我的库存"
L["OPTIONS_SHARE_INVENTORY_DESC"] =
	"告诉你的小队或团队你有哪些可以送出的物品，让他们将鼠标悬停在你身上时可以看到。从不在聊天中发布，也不会传给队伍以外的任何人。关闭后你仍能看到他们的。"

--------------------------------------------------------------------------------
-- Options — Dispensed Items
--------------------------------------------------------------------------------

L["TAB_DISPENSED_ITEMS"] = "分发物品"
L["OPTIONS_ITEMS_DESC"] =
	"设置每种物品分发多少。数量按单个物品计算，所以 20 个水就是 20 个水，1 个药水就是 1 个药水。必要时会把一堆拆分到精确数量。"
-- "Add an Item" must match OPTIONS_ADD_ITEM.
L["OPTIONS_ITEMS_EMPTY"] =
	'未配置物品。请在列表中选择 "添加物品"，从背包中添加任何可交易的物品。'

--[[
	The silver line opening an item's page while nothing of it would go out. In
	OTHER_CLASS, %s is the player's class twice, then OPTIONS_ITEM_PLAYER_CLASSES;
	in ALL_ZERO, %s is OPTIONS_ITEM_EVERYONE.
]]
L["OPTIONS_ITEM_STATUS_OTHER_CLASS"] = "使用 %s 游玩时不会分发。请勾选 %s（位于 %s 下）。"
L["OPTIONS_ITEM_STATUS_ALL_ZERO"] =
	"尚未分发任何物品：所有数量都是 0。在 %s 中输入一个数字即可开始。"

L["OPTIONS_ITEM_AMOUNTS"] = "数量"
L["OPTIONS_ITEM_AMOUNTS_DESC"] =
	"按对方是陌生人、你的小队成员还是团队成员，选择每个职业各拿多少。按单个物品计算，而非按堆。填 0 表示他们永远拿不到这个物品。"
L["OPTIONS_ITEM_EVERYONE"] = "所有人"
-- "Apply" must match OPTIONS_ITEM_APPLY.
L["OPTIONS_ITEM_EVERYONE_DESC"] =
	"按下回车或点击应用即可一次性为所有职业设定这个数量，当下方各职业的数值不一致时会显示为空白。"
-- The accept button inside every number box in this panel.
L["OPTIONS_ITEM_APPLY"] = "应用"
-- %d is the highest amount this item accepts, which is 1 for anything unique.
L["OPTIONS_ITEM_COUNT_TOO_HIGH"] = "这超出了你能给出的该物品数量。最多为 %d。"
L["OPTIONS_ITEM_COUNT_INVALID"] = "请输入物品数量。"
L["OPTIONS_ITEM_SETTINGS"] = "物品设置"
L["OPTIONS_ITEM_DISTRIBUTE"] = "分发范围"
-- "In Instance" must match OPTIONS_ITEM_DISTRIBUTE_INSTANCE.
L["OPTIONS_ITEM_DISTRIBUTE_DESC"] =
	"设置在哪里分发此物品。副本中涵盖地下城、团队副本、战场和竞技场。在其他任何地方，此物品都不会被交易、喊话或显示在你的提示中。"
--[[
	Dropdown entries, looked up as OPTIONS_ITEM_DISTRIBUTE_ plus the stored value in
	capitals ("Always", "Instance"), so no code names these keys in full.
]]
L["OPTIONS_ITEM_DISTRIBUTE_ALWAYS"] = "始终"
L["OPTIONS_ITEM_DISTRIBUTE_INSTANCE"] = "副本中"
L["OPTIONS_ITEM_GUILDIES_ONLY"] = "仅限公会成员"
L["OPTIONS_ITEM_GUILDIES_ONLY_DESC"] = "当你的交易对象不在你的公会中时，跳过该物品。"
-- Panel line under the toggle, not a tooltip: it names the guild, which no fixed string can. %s is the player's guild.
L["OPTIONS_ITEM_GUILDIES_ONLY_HELP"] = "只给 <%s> 的成员。"
L["OPTIONS_ITEM_GUILDIES_ONLY_NO_GUILD"] =
	"你没有加入任何公会，所以这样设置不会把该物品给任何人。"
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "考虑物品的等级需求"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] = "当你的交易对象未达到该物品的需求等级时，跳过该物品。"
L["OPTIONS_ITEM_RESERVE"] = "启用保留数量"
L["OPTIONS_ITEM_RESERVE_DESC"] =
	"始终在背包中至少保留这么多，而分发、你的玩家提示和喊话宏会把超出这个数量的部分视为可以送出的。"
L["OPTIONS_ITEM_PLAYER_CAP"] = "启用每位玩家上限"
L["OPTIONS_ITEM_PLAYER_CAP_DESC"] =
	"当某人已从你这里获得这么多后，停止向其送出此物品。登出、重载界面或更改此物品的数量后，计数会重新开始。"
-- The label carries the meaning on its own; the tooltip only says why you'd switch it off.
L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "在玩家提示和喊话宏中显示数量"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] =
	"关闭后只显示物品名称而不带数量，这对治疗石这类你只会随身带一个的物品读起来更自然。"
L["OPTIONS_ITEM_PLAYER_CLASSES"] = "仅在使用这些职业时分发"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] =
	"仅当你的角色职业在下方被选中时，才填充交易、把此物品写进喊话宏，并显示在你的玩家提示中。"
L["OPTIONS_ITEM_REMOVE"] = "移除物品"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "是否从你的分发物品中移除此物品？"

L["OPTIONS_SCOPE_SOLO"] = "陌生人"
L["OPTIONS_SCOPE_GROUP"] = "小队"
L["OPTIONS_SCOPE_RAID"] = "团队"

L["OPTIONS_ADD_ITEM"] = "添加物品"
L["OPTIONS_ADD_DESC"] =
	"从背包中选择任意可交易物品加入你的分发物品。已配置或已灵魂绑定的物品不会出现在这里。"
L["OPTIONS_ADD_SELECT"] = "可用物品"
L["OPTIONS_ADD_BUTTON"] = "添加到分发物品"
L["OPTIONS_ADD_EMPTY"] = "背包中没有找到可交易的物品。"

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["TAB_ANNOUNCEMENTS"] = "喊话"
L["OPTIONS_ANNOUNCEMENTS_DESC"] =
	"Water Dispenser 可以创建一个宏，通报你还有什么可以分发。该宏会自动选择频道（未组队时说话，队伍中为小队，团队中为团队，副本或战场队伍中为副本），并直接使用背包中的最新数量。"
L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "启用喊话宏"
-- "- Dispenser" is the macro's literal name and is never translated.
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] =
	'维护一个名为 "- Dispenser" 的角色专属宏，使其与你当前的分发物品保持同步，并在你关闭此选项时删除该宏。'
-- "Enable Reserves" must match OPTIONS_ITEM_RESERVE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] =
	"没有可喊话的内容。配置物品，补充背包，或在启用保留数量中调低保留值。"
-- "Enable Dispense" must match OPTIONS_DISPENSE_MASTER, "Dispense" must match TAB_DISPENSE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DISPENSE_OFF"] =
	"分发标签页中的启用分发处于关闭状态时，没有可喊话的内容。"

-- Macro message template (%s is the item list) and the connector before the last list entry.
L["ANNOUNCEMENTS_BODY"] = "我有 %s。点我交易！"
L["ANNOUNCEMENTS_AND"] = "和"

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["OPTIONS_SUPPORT"] = "反馈与支持"
-- The General panel's last line. %s is the version.
L["OPTIONS_VERSION"] = "版本 %s"
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"
L["SUPPORT_WAGO"] = "Wago"
