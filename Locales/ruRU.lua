local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "ruRU")
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
L["ITEM_LOADING"] = "Загрузка ID: %d"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

--[[
	All player-facing chat prints live here, regardless of which feature emits them.
	In CHAT_LOADED, %s is the add-on version and the menu path is the game client's
	own labels.
]]
L["CHAT_LOADED"] =
	"Версия %s. Настройки (включая отключение этого сообщения) находятся в Настройки > Модификации > Water Dispenser. Нравится аддон? Расскажите друзьям! (="
L["CHAT_NO_TRADE"] = "Нет активного окна обмена."
L["CHAT_COMBAT_BLOCKED"] = "WoW блокирует автоматический обмен во время боя."
L["CHAT_OPTIONS_IN_COMBAT"] =
	"В целях безопасности окно настроек нельзя открыть во время боя."
-- The item and its count are appended after the colon by the code.
L["CHAT_MISSING_STACK"] = "Не хватает:"
--[[
	%s is the item's name, then the trade partner's name; %d is the Maximum per
	Player they have reached.
]]
L["CHAT_PLAYER_CAP_REACHED"] =
	"%s не добавлено: игрок %s уже получил от вас %d. Счет начинается заново, когда вы выходите из игры или перезагружаете интерфейс."
-- %s is the item's name; the first %d is the amount that could not be split off, the second the item's full stack size.
L["CHAT_SPLIT_NEEDS_FULL_STACK"] =
	"%s не добавлено: игра не смогла отделить %d от стопки. Укажите количество, равное полной стопке (%d), чтобы передать предмет."
-- %s is the player's class name. "Dispensed Items" must match TAB_DISPENSED_ITEMS.
L["CHAT_NONE_ACTIVE_FOR_CLASS"] =
	"Нет предметов для раздачи, пока вы играете за класс %s. Откройте Настройки > Модификации > Water Dispenser > Раздаваемые предметы, чтобы включить предметы для этого класса."
-- "- Dispenser" is the macro's literal name and is never translated.
L["CHAT_MACRO_DELETED"] = 'Макрос анонса "- Dispenser" удален.'
L["CHAT_MACRO_FULL"] =
	"Не удалось создать макрос анонса: все персональные слоты для макросов заняты."

--------------------------------------------------------------------------------
-- Player Tooltips
--------------------------------------------------------------------------------

L["TOOLTIP_OPEN_TRADE"] = "Кидайте обмен!"
-- %s is the Improved Healthstone talent's name from the client, then the warlock's rank out of its maximum.
L["TOOLTIP_HEALTHSTONE_TALENT"] = "%s %d/%d"

--------------------------------------------------------------------------------
-- Bag Item Tooltips
--------------------------------------------------------------------------------

-- Shown on a carried bag item the player has set up to give away.
L["TOOLTIP_WILL_DISPENSE"] = "Раздается при обмене."

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BUTTON_CLEAR"] = "Очистить окно обмена"
L["BUTTON_FILL"] = "Заполнить окно обмена"

--[[
	The silver status line under the trade panel's buttons. "Fill Trade Window" must
	match BUTTON_FILL. ADDED's %s is the window's contents, each FORMAT_ITEM_COUNT,
	joined like the announcement's list. In the rest, %s is an item or collection
	name unless noted.
]]
L["TRADE_STATUS_ADDED"] = "Добавлено: %s."
-- %d is how many short.
L["TRADE_STATUS_SHORT"] = "Не хватает %d шт. (%s): в сумках недостаточно."
L["TRADE_STATUS_SHORT_RESERVE"] =
	"Не хватает %d шт. (%s): остальное держит ваш резерв."
L["TRADE_STATUS_DISPENSE_OFF"] =
	"Автозаполнение отключено. Заполнить окно обмена по-прежнему добавляет ваши обычные количества."
L["TRADE_STATUS_OFF_STRANGERS"] =
	"Автозаполнение отключено для незнакомцев. Заполнить окно обмена по-прежнему добавляет ваши обычные количества."
L["TRADE_STATUS_OFF_PARTY"] =
	"Автозаполнение отключено для участников группы. Заполнить окно обмена по-прежнему добавляет ваши обычные количества."
L["TRADE_STATUS_OFF_RAID"] =
	"Автозаполнение отключено для участников рейда. Заполнить окно обмена по-прежнему добавляет ваши обычные количества."
L["TRADE_STATUS_MASTER_LOOT"] =
	"Отложено, пока вы ответственный за добычу. Заполнить окно обмена по-прежнему добавляет ваши обычные количества."
-- The first %s is the partner's class name.
L["TRADE_STATUS_ZERO"] = "Для класса %s задано 0: %s."
L["TRADE_STATUS_INSTANCE_ONLY"] = "%s выдается только в подземельях."
L["TRADE_STATUS_GUILD_ONLY"] = "%s выдается только вашей гильдии."
-- The partner's name, then the rank they can't use yet and its level.
L["TRADE_STATUS_LEVEL"] = "%s не может использовать %s до %d-го уровня."
-- The partner's name first.
L["TRADE_STATUS_TOO_LOW"] = "%s: слишком низкий уровень для %s."
-- The partner's name first.
L["TRADE_STATUS_CAPPED"] = "%s: достигнут ваш максимум на игрока для %s."
L["TRADE_STATUS_NONE_HELD"] = "Нечего раздать: %s."
L["TRADE_STATUS_CLEARED"] = "Очищено."
--[[
	A conjure button's tooltip, under the spell's name. MAKES: the item it makes,
	then the trade partner's name and level. LOWEST, when no rank fits the partner:
	the item only.
]]
L["TRADE_CONJURE_MAKES"] =
	"Создает %s, лучшее, что может использовать %s (уровень %d)."
L["TRADE_CONJURE_MAKES_LOWEST"] = "Создает %s, самый низкий известный вам ранг."

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

--[[
	The tooltip's feature row reuses TAB_DISPENSE for its name and
	OPTIONS_DISPENSE_MASTER_DESC for its description; these are its state and click words.
]]
L["UI_ENABLED"] = "Включено"
L["UI_DISABLED"] = "Отключено"
L["UI_LEFT_CLICK"] = "ЛКМ"
L["UI_TOGGLE"] = "Переключить"
L["MINIMAP_OPTIONS"] = "Настройки Water Dispenser"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + СКМ"
-- Heads the tooltip section listing what the player can give right now.
L["MINIMAP_DISPENSE_REPORT"] = "Отчет о раздаче"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Раздача расходников без усилий. Автоматически заполняет окна обмена сотворенной водой, едой и камнями здоровья нужного ранга и в нужном количестве для каждого игрока. Добавьте любой предмет, от песка из песочных часов до зелий сопротивления, и снабдите весь рейд за считанные секунды."

L["OPTIONS_WELCOME_MESSAGE"] = "Включить приветственное сообщение"
L["OPTIONS_WELCOME_MESSAGE_DESC"] =
	"Выводит однострочное приветствие в чат при загрузке Water Dispenser."
L["OPTIONS_MINIMAP"] = "Включить кнопку у миникарты"
L["OPTIONS_MINIMAP_DESC"] = "Показывает кнопку Water Dispenser у миникарты."

L["OPTIONS_FEATURES_HEADER"] = "Возможности"

L["OPTIONS_COMMANDS_HEADER"] = "/Команды"
L["OPTIONS_COMMAND"] = "/wd"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Открывает окно настроек этого аддона."

--------------------------------------------------------------------------------
-- Options — Dispense
--------------------------------------------------------------------------------

-- Names the panel and the mini-map tooltip's feature row.
L["TAB_DISPENSE"] = "Раздача"
L["OPTIONS_DISPENSE_MASTER"] = "Включить раздачу"
-- Also the panel's intro line and the mini-map tooltip's feature description.
L["OPTIONS_DISPENSE_MASTER_DESC"] =
	"Автоматически заполняет окно обмена при его открытии на основе ваших настроек."
L["OPTIONS_DISPENSE_SOLO"] = "Включить для незнакомцев"
L["OPTIONS_DISPENSE_SOLO_DESC"] =
	"Автоматически заполняет окно обмена при обмене с игроком не из вашей группы или рейда."
L["OPTIONS_DISPENSE_GROUP"] = "Включить для группы"
L["OPTIONS_DISPENSE_GROUP_DESC"] =
	"Автоматически заполняет окно обмена при обмене с членом вашей группы."
L["OPTIONS_DISPENSE_RAID"] = "Включить для рейда"
L["OPTIONS_DISPENSE_RAID_DESC"] =
	"Автоматически заполняет окно обмена при обмене с членом вашего рейда."
-- The label says what it does; the tooltip only covers why it is needed and when it stands down.
L["OPTIONS_RESTACK"] = "Объединять неполные стопки после обмена"
L["OPTIONS_RESTACK_DESC"] =
	"Сотворенные вода и еда каждый раз попадают в новую ячейку сумки, и игра никогда не складывает их обратно, поэтому Water Dispenser объединяет их один раз, сразу после закрытия окна обмена, и никогда в другое время, в бою или пока вы держите что-то на курсоре."
L["OPTIONS_HOLD_MASTER_LOOT"] = "Не заполнять, пока вы ответственный за добычу"
-- "Fill Trade Window" must match BUTTON_FILL.
L["OPTIONS_HOLD_MASTER_LOOT_DESC"] =
	"Оставляет окно обмена пустым, пока вы ответственный за добычу в подземелье, ведь такие обмены нужны для раздачи добычи. Заполнить окно обмена по-прежнему добавляет ваши обычные количества."
L["OPTIONS_CONJURE_BUTTONS"] = "Показывать кнопки сотворения рядом с обменом"
-- "Fill Trade Window" must match BUTTON_FILL.
L["OPTIONS_CONJURE_BUTTONS_DESC"] =
	"Добавляет под кнопкой Заполнить окно обмена кнопки, которые сотворяют воду, еду или камень здоровья, подходящие по уровню вашему партнеру по обмену, и созданное сразу попадает в открытый обмен."
L["OPTIONS_MISSING_STACK_WARNINGS"] =
	"Включить предупреждения, когда запасы на исходе"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] =
	"Выводит заметку в чат, когда в сумках не хватает настроенного предмета, чтобы выдать заданное количество."

-- Leads the silver line under a setting that shows the exact chat line it prints.
L["OPTIONS_EXAMPLE"] = "Пример:"

L["OPTIONS_COMBAT_HEADER"] = "Бой"
L["OPTIONS_COMBAT_DESC"] =
	"WoW запрещает аддонам перемещать предметы в окно обмена во время боя."
L["OPTIONS_COMBAT_NOTIFY"] =
	"Включить уведомления, когда раздача заблокирована"
L["OPTIONS_COMBAT_NOTIFY_DESC"] =
	"Выводит заметку в чат, когда бой мешает заполнить обмен."

--------------------------------------------------------------------------------
-- Options — Inventory Tooltips
--------------------------------------------------------------------------------

L["TAB_INVENTORY_TOOLTIPS"] = "Подсказки с запасами"
L["OPTIONS_TOOLTIPS_DESC"] =
	"Показывает в подсказках игроков, что участники вашей группы с установленным Water Dispenser настроили для раздачи, и отмечает в ваших собственных сумках предметы, которые раздаете вы."
L["OPTIONS_SHOW_INVENTORY"] =
	"Показывать запасы во всплывающих подсказках игроков"
L["OPTIONS_SHOW_INVENTORY_DESC"] =
	"Добавляет блок Water Dispenser в подсказки игроков со списком того, что они настроили для раздачи, и сколько они готовы отдать, причем ваш собственный список показывается всегда, в группе или нет."
L["OPTIONS_BAG_TOOLTIPS"] =
	"Показывать подсказки в сумках для раздаваемых предметов"
L["OPTIONS_BAG_TOOLTIPS_DESC"] =
	"Добавляет строку Water Dispenser в подсказку предмета в сумке, когда этот предмет настроен для раздачи, чтобы вы сразу видели, что аддон отдаст."
L["OPTIONS_SHARE_INVENTORY"] = "Делиться своими запасами"
L["OPTIONS_SHARE_INVENTORY_DESC"] =
	"Сообщает вашей группе или рейду, что вы можете раздать, чтобы это было видно при наведении на вас. Никогда не пишет в чат и не доходит ни до кого вне вашей группы. Если отключить, вы по-прежнему видите их запасы."

--------------------------------------------------------------------------------
-- Options — Dispensed Items
--------------------------------------------------------------------------------

L["TAB_DISPENSED_ITEMS"] = "Раздаваемые предметы"
L["OPTIONS_ITEMS_DESC"] =
	"Настройте, сколько каждого предмета раздавать. Количество считается в отдельных предметах, поэтому 20 воды означают 20 воды, а 1 зелье означает 1 зелье. При необходимости стопка делится до точного количества."
-- "Add an Item" must match OPTIONS_ADD_ITEM.
L["OPTIONS_ITEMS_EMPTY"] =
	'Нет настроенных предметов. Выберите "Добавить предмет" в списке, чтобы добавить любой передаваемый предмет из ваших сумок.'

--[[
	The silver line opening an item's page while nothing of it would go out. In
	OTHER_CLASS, %s is the player's class twice, then OPTIONS_ITEM_PLAYER_CLASSES;
	in ALL_ZERO, %s is OPTIONS_ITEM_EVERYONE.
]]
L["OPTIONS_ITEM_STATUS_OTHER_CLASS"] =
	"Не раздается, пока вы играете за класс %s. Отметьте %s в разделе %s."
L["OPTIONS_ITEM_STATUS_ALL_ZERO"] =
	"Пока ничего не раздается: все количества равны 0. Введите число в поле %s, чтобы начать."

L["OPTIONS_ITEM_AMOUNTS"] = "Количество"
L["OPTIONS_ITEM_AMOUNTS_DESC"] =
	"Выберите, сколько получает каждый класс при обмене, в зависимости от того, незнакомец это, участник вашей группы или рейда. Считается в отдельных предметах, а не в стопках. Ноль означает, что этот предмет им никогда не достанется."
L["OPTIONS_ITEM_EVERYONE"] = "Все"
-- "Apply" must match OPTIONS_ITEM_APPLY.
L["OPTIONS_ITEM_EVERYONE_DESC"] =
	"Задает это количество сразу для всех классов, когда вы нажимаете Enter или кнопку Применить, и остается пустым, когда классы ниже не совпадают."
-- The accept button inside every number box in this panel.
L["OPTIONS_ITEM_APPLY"] = "Применить"
-- %d is the highest amount this item accepts, which is 1 for anything unique.
L["OPTIONS_ITEM_COUNT_TOO_HIGH"] =
	"Это больше, чем вы можете дать этого предмета. Максимум: %d."
L["OPTIONS_ITEM_COUNT_INVALID"] = "Введите количество предметов."
L["OPTIONS_ITEM_SETTINGS"] = "Настройки предмета"
L["OPTIONS_ITEM_DISTRIBUTE"] = "Выдавать"
-- "In Instance" must match OPTIONS_ITEM_DISTRIBUTE_INSTANCE.
L["OPTIONS_ITEM_DISTRIBUTE_DESC"] =
	"Определяет, где раздается этот предмет. В подземельях охватывает подземелья, рейды, поля боя и арены. В любом другом месте предмет никогда не передается, не анонсируется и не показывается в вашей подсказке."
--[[
	Dropdown entries, looked up as OPTIONS_ITEM_DISTRIBUTE_ plus the stored value in
	capitals ("Always", "Instance"), so no code names these keys in full.
]]
L["OPTIONS_ITEM_DISTRIBUTE_ALWAYS"] = "Всегда"
L["OPTIONS_ITEM_DISTRIBUTE_INSTANCE"] = "В подземельях"
L["OPTIONS_ITEM_GUILDIES_ONLY"] = "Только согильдийцам"
L["OPTIONS_ITEM_GUILDIES_ONLY_DESC"] =
	"Пропускает этот предмет, если ваш партнер по обмену не состоит в вашей гильдии."
-- Panel line under the toggle, not a tooltip: it names the guild, which no fixed string can. %s is the player's guild.
L["OPTIONS_ITEM_GUILDIES_ONLY_HELP"] = "Отдавать только участникам <%s>."
L["OPTIONS_ITEM_GUILDIES_ONLY_NO_GUILD"] =
	"Вы не состоите в гильдии, поэтому так этот предмет не достанется никому."
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Учитывать требуемый уровень предмета"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] =
	"Пропускает этот предмет, если уровень вашего партнера по обмену ниже требуемого для предмета."
L["OPTIONS_ITEM_RESERVE"] = "Включить резерв"
L["OPTIONS_ITEM_RESERVE_DESC"] =
	"Всегда оставляет в сумках хотя бы столько, а раздача, ваша подсказка игрока и макрос анонса считают все сверх этого числа доступным для передачи."
L["OPTIONS_ITEM_PLAYER_CAP"] = "Включить максимум на игрока"
L["OPTIONS_ITEM_PLAYER_CAP_DESC"] =
	"Перестает давать этот предмет игроку, как только он получил от вас столько. Счет начинается заново, когда вы выходите из игры, перезагружаете интерфейс или меняете количества этого предмета."
-- The label carries the meaning on its own; the tooltip only says why you'd switch it off.
L["OPTIONS_ITEM_INCLUDE_QUANTITY"] =
	"Показывать количество в подсказке игрока и макросе анонса"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] =
	"В отключенном виде предмет называется без числа рядом, что лучше читается для того, чего у вас всегда только один, вроде камня здоровья."
L["OPTIONS_ITEM_PLAYER_CLASSES"] = "Раздавать, только играя этими классами"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] =
	"Заполняет обмен, добавляет этот предмет в макрос анонса и показывает его в вашей подсказке игрока только тогда, когда класс вашего персонажа выбран ниже."
L["OPTIONS_ITEM_REMOVE"] = "Удалить предмет"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] =
	"Убрать этот предмет из ваших раздаваемых предметов?"

L["OPTIONS_SCOPE_SOLO"] = "Незнакомцы"
L["OPTIONS_SCOPE_GROUP"] = "Группа"
L["OPTIONS_SCOPE_RAID"] = "Рейд"

L["OPTIONS_ADD_ITEM"] = "Добавить предмет"
L["OPTIONS_ADD_DESC"] =
	"Выберите любой передаваемый предмет из ваших сумок, чтобы добавить его к вашим раздаваемым предметам. Уже настроенные или персональные предметы не отображаются."
L["OPTIONS_ADD_SELECT"] = "Доступные предметы"
L["OPTIONS_ADD_BUTTON"] = "Добавить к раздаваемым предметам"
L["OPTIONS_ADD_EMPTY"] = "В ваших сумках не найдено передаваемых предметов."

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["TAB_ANNOUNCEMENTS"] = "Анонсы"
L["OPTIONS_ANNOUNCEMENTS_DESC"] =
	"Water Dispenser может создать макрос, объявляющий, что у вас осталось для раздачи. Макрос сам выбирает нужный канал (Сказать вне группы, Группа в группе, Рейд в рейде, Подземелье в группе подземелья или на поле боя) и берет самые свежие количества прямо из ваших сумок."
L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Включить макрос анонса"
-- "- Dispenser" is the macro's literal name and is never translated.
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] =
	'Поддерживает персональный макрос "- Dispenser" в актуальном состоянии в соответствии с вашими текущими раздаваемыми предметами и удаляет макрос, когда вы это отключаете.'
-- "Enable Reserves" must match OPTIONS_ITEM_RESERVE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] =
	"Нечего анонсировать. Настройте предметы, пополните сумки или уменьшите резерв в разделе Включить резерв."
-- "Enable Dispense" must match OPTIONS_DISPENSE_MASTER, "Dispense" must match TAB_DISPENSE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DISPENSE_OFF"] =
	"Нечего анонсировать, пока Включить раздачу отключено на вкладке Раздача."

-- Macro message template (%s is the item list) and the connector before the last list entry.
L["ANNOUNCEMENTS_BODY"] = "У меня есть %s. Кидайте обмен!"
L["ANNOUNCEMENTS_AND"] = "и"

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["OPTIONS_SUPPORT"] = "Отзывы и поддержка"
-- The General panel's last line. %s is the version.
L["OPTIONS_VERSION"] = "Версия %s"
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"
L["SUPPORT_WAGO"] = "Wago"
