local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "ruRU")
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
	"Версия %s. Настройки (включая отключение этого сообщения) находятся в Настройки > Модификации > Water Dispenser. Нравится аддон? Расскажите друзьям! (="
L["CHAT_NO_TRADE"] = "Нет активного окна обмена."
L["CHAT_COMBAT_BLOCKED"] = "WoW блокирует автоматический обмен во время боя."
L["CHAT_OPTIONS_IN_COMBAT"] =
	"В целях безопасности окно настроек нельзя открыть во время боя."
-- The item and its count are appended after the colon by the code.
L["CHAT_MISSING_STACK"] = "Не хватает:"
-- %s is the item's name, %d the Maximum per Session it has hit.
-- "Maximum per Session" must match OPTIONS_ITEM_SESSION_CAP.
L["CHAT_SESSION_CAP_REACHED"] =
	"%s не добавлено: этот игрок уже получил свои %d за сессию. Измените Максимум за сессию или перезагрузите интерфейс для сброса."
-- %s is the item's name, %d the amount that could not be split off.
L["CHAT_SPLIT_REFUSED"] =
	"%s не добавлено: клиент отказался отделить %d от стопки, а передать вместо этого целую стопку значило бы отдать намного больше, чем вы просили. Задайте для этого предмета количество, равное целой стопке, чтобы обменять его."
-- %s is the player's class name. "Dispensed Items" must match TAB_DISPENSED_ITEMS.
L["CHAT_NONE_ACTIVE_FOR_CLASS"] =
	"Нет предметов для раздачи, пока вы играете за класс %s. Откройте Настройки > Раздаваемые предметы, чтобы включить предметы для этого класса."
-- The item's name is appended after the colon by the code.
L["CHAT_ITEM_SAVED"] = "Сохранено:"
-- "- Dispenser" is the macro's literal name and is never translated.
L["CHAT_MACRO_DELETED"] = 'Макрос анонса "- Dispenser" удален.'
L["CHAT_MACRO_FULL"] =
	"Не удалось создать макрос: все персональные слоты для макросов заняты."

--------------------------------------------------------------------------------
-- Player Tooltips
--------------------------------------------------------------------------------

L["TOOLTIP_OPEN_TRADE"] = "Кидайте обмен!"
-- %d/%d is the warlock's Improved Healthstone rank out of its maximum.
L["TOOLTIP_HEALTHSTONE"] = "Камень здоровья (ранг %d/%d)"

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BUTTON_CLEAR"] = "Очистить окно обмена"
L["BUTTON_FILL"] = "Заполнить окно обмена"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

-- The tooltip's feature row reuses OPTIONS_DISPENSE_HEADER for its name; these are its state and click words.
L["UI_ENABLED"] = "Включено"
L["UI_DISABLED"] = "Отключено"
L["UI_LEFT_CLICK"] = "ЛКМ"
L["UI_TOGGLE"] = "Переключить"
L["MINIMAP_OPTIONS"] = "Настройки Water Dispenser"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + СКМ"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Автоматически заполняет окно обмена водой, едой, камнями здоровья или любым расходуемым предметом, который вы настроите, в количестве, выбранном для класса, уровня и группы партнера по обмену."

L["OPTIONS_WELCOME_MESSAGE"] = "Включить приветственное сообщение"
L["OPTIONS_WELCOME_MESSAGE_DESC"] =
	"Выводит однострочное приветствие в чат при загрузке Water Dispenser."
L["OPTIONS_MINIMAP"] = "Включить кнопку у миникарты"
L["OPTIONS_MINIMAP_DESC"] = "Показывает кнопку Water Dispenser у миникарты."
L["OPTIONS_MISSING_STACK_WARNINGS"] =
	"Включить предупреждения, когда запасы на исходе"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] =
	"Выводит заметку в чат, когда в сумках не хватает настроенного предмета, чтобы выдать заданное количество."
-- The label says what it does; the tooltip only covers why it is needed and when it stands down.
L["OPTIONS_RESTACK"] = "Автоматически объединять неполные стопки в сумках"
L["OPTIONS_RESTACK_DESC"] =
	"Сотворенные вода и еда каждый раз попадают в новую ячейку сумки, и игра никогда не складывает их обратно, хотя это никогда не срабатывает в бою, при открытом обмене или пока вы держите что-то на курсоре."

L["OPTIONS_COMMANDS_HEADER"] = "/Команды"
L["OPTIONS_COMMAND"] = "/wd"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Открывает окно настроек этого аддона."

L["OPTIONS_DISPENSE_HEADER"] = "Раздача"
L["OPTIONS_DISPENSE_DESC"] =
	"Автоматически заполняет окно обмена при его открытии. Переключайте каждую настройку ниже независимо."
L["OPTIONS_DISPENSE_MASTER"] = "Включить раздачу"
L["OPTIONS_DISPENSE_MASTER_DESC"] =
	"Автоматически заполняет окно обмена на основе ваших настроек."
L["OPTIONS_DISPENSE_SOLO"] = "Включить для незнакомцев"
L["OPTIONS_DISPENSE_SOLO_DESC"] =
	"Автоматически заполняет окно обмена при обмене с игроком не из вашей группы или рейда."
L["OPTIONS_DISPENSE_GROUP"] = "Включить для группы"
L["OPTIONS_DISPENSE_GROUP_DESC"] =
	"Автоматически заполняет окно обмена при обмене с членом вашей группы."
L["OPTIONS_DISPENSE_RAID"] = "Включить для рейда"
L["OPTIONS_DISPENSE_RAID_DESC"] =
	"Автоматически заполняет окно обмена при обмене с членом вашего рейда."

L["OPTIONS_TOOLTIPS_HEADER"] = "Запасы во всплывающих подсказках игроков"
L["OPTIONS_TOOLTIPS_DESC"] =
	"Показывает запасы для раздачи в подсказках членов группы, у которых установлен Water Dispenser."
L["OPTIONS_SHOW_INVENTORY"] =
	"Показывать запасы во всплывающих подсказках игроков"
L["OPTIONS_SHOW_INVENTORY_DESC"] =
	"Добавляет блок Water Dispenser в подсказки игроков со списком того, что они настроили для раздачи, и их количеством, причем ваш собственный список показывается всегда, в группе или нет."
L["OPTIONS_SHARE_INVENTORY"] = "Делиться своими запасами"
L["OPTIONS_SHARE_INVENTORY_DESC"] =
	"Сообщает вашей группе и рейду, что у вас с собой, чтобы ваши запасы появлялись при наведении на вас, ничего не отправляя в чат и не сообщая никому за пределами вашей группы, а если отключить, чужие списки все равно останутся доступны."

L["OPTIONS_COMBAT_HEADER"] = "Бой"
L["OPTIONS_COMBAT_DESC"] =
	"WoW запрещает аддонам перемещать предметы в окно обмена во время боя."
L["OPTIONS_COMBAT_NOTIFY"] =
	"Включить уведомления, когда раздача заблокирована"
L["OPTIONS_COMBAT_NOTIFY_DESC"] =
	"Выводит заметку в чат, когда бой мешает заполнить обмен, а в отключенном виде Water Dispenser молчит, ничем не объясняя, почему обмен остался пустым."

--------------------------------------------------------------------------------
-- Options — Dispensed Items
--------------------------------------------------------------------------------

L["TAB_DISPENSED_ITEMS"] = "Раздаваемые предметы"
L["OPTIONS_ITEMS_DESC"] =
	"Настройте, сколько каждого предмета раздавать. Количество считается в отдельных предметах, поэтому 20 воды означают 20 воды, а 1 зелье означает 1 зелье. При необходимости стопка делится до точного количества."
-- "Add an Item" must match OPTIONS_ADD_ITEM.
L["OPTIONS_ITEMS_EMPTY"] =
	'Нет настроенных предметов. Выберите "Добавить предмет" в списке, чтобы добавить расходуемые предметы из ваших сумок.'

L["OPTIONS_ITEM_DISTRIBUTION"] = "Распределение"
L["OPTIONS_ITEM_DISTRIBUTION_DESC"] =
	"Выберите, сколько получает каждый класс при обмене, в зависимости от того, незнакомец это, участник вашей группы или рейда. Считается в отдельных предметах, а не в стопках. Ноль означает, что этот предмет им никогда не достанется."
L["OPTIONS_ITEM_EVERYONE"] = "Все"
L["OPTIONS_ITEM_EVERYONE_DESC"] =
	"Задает это количество сразу для всех классов, когда вы нажимаете Enter, и остается пустым, когда классы ниже не совпадают."
-- The accept button inside every number box in this panel.
L["OPTIONS_ITEM_APPLY"] = "Применить"
-- %d is the highest amount this item accepts, which is 1 for anything unique.
L["OPTIONS_ITEM_COUNT_TOO_HIGH"] =
	"Это больше, чем этот предмет может раздать. Максимум: %d."
L["OPTIONS_ITEM_COUNT_INVALID"] =
	"Введите количество предметов или 0, чтобы никогда не раздавать этот предмет."
L["OPTIONS_ITEM_SETTINGS"] = "Настройки предмета"
-- "In Group" and "In Raid" in the tooltip must match the two dropdown entries below.
L["OPTIONS_ITEM_DISTRIBUTE"] = "Выдавать"
L["OPTIONS_ITEM_DISTRIBUTE_DESC"] =
	"Задает, когда этот предмет вообще выдается, ведь за пределами выбранной группы он никогда не передается, не анонсируется и не показывается в вашей подсказке, причем В группе охватывает группу или рейд, а В рейде только рейды."
-- Dropdown entries. The stored values are "Always", "Group", and "Raid"; these are only their labels.
L["OPTIONS_ITEM_DISTRIBUTE_ALWAYS"] = "Всегда"
L["OPTIONS_ITEM_DISTRIBUTE_GROUP"] = "В группе"
L["OPTIONS_ITEM_DISTRIBUTE_RAID"] = "В рейде"
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Учитывать требования к уровню"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] =
	"Пропускает этот предмет, если уровень партнера по обмену ниже требуемого для предмета."
L["OPTIONS_ITEM_RESERVE"] = "Включить резерв"
L["OPTIONS_ITEM_RESERVE_DESC"] =
	"Всегда оставляет в сумках хотя бы столько, а раздача и макрос анонса считают все сверх этого числа доступным для передачи."
L["OPTIONS_ITEM_SESSION_CAP"] = "Включить максимум за сессию"
L["OPTIONS_ITEM_SESSION_CAP_DESC"] =
	"Перестает выдавать этот предмет игроку, как только он получил от вас столько, считая по всем обменам до выхода из игры или перезагрузки интерфейса, а изменение любого количества этого предмета обнуляет счет для всех."
-- The label carries the meaning on its own; the tooltip only says why you'd switch it off.
L["OPTIONS_ITEM_INCLUDE_QUANTITY"] =
	"Показывать количество в подсказке игрока и макросе анонса"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] =
	"В отключенном виде предмет называется без числа рядом, что лучше читается для того, чего у вас всегда только один, вроде камня здоровья."
L["OPTIONS_ITEM_PLAYER_CLASSES"] = "Раздавать, только играя этими классами"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] =
	"Заполнять обмен и включать этот предмет в анонс только тогда, когда класс вашего персонажа выбран ниже."
L["OPTIONS_ITEM_REMOVE"] = "Удалить предмет"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "Удалить этот предмет из настроек обмена?"

L["OPTIONS_SCOPE_SOLO"] = "Незнакомцы"
L["OPTIONS_SCOPE_GROUP"] = "Группа"
L["OPTIONS_SCOPE_RAID"] = "Рейд"

L["OPTIONS_ADD_ITEM"] = "Добавить предмет"
L["OPTIONS_ADD_DESC"] =
	"Выберите любой передаваемый предмет из ваших сумок, чтобы добавить его в настройки обмена. Уже настроенные или персональные предметы не отображаются."
L["OPTIONS_ADD_SELECT"] = "Доступные предметы"
L["OPTIONS_ADD_BUTTON"] = "Добавить в настройки"
L["OPTIONS_ADD_EMPTY"] = "В ваших сумках не найдено передаваемых предметов."

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["TAB_ANNOUNCEMENTS"] = "Анонсы"
L["OPTIONS_ANNOUNCEMENTS_DESC"] =
	"Water Dispenser может создать макрос, объявляющий, что у вас осталось для раздачи. Макрос сам выбирает нужный канал (Сказать вне группы, Группа в группе, Рейд в рейде) и берет самые свежие количества прямо из ваших сумок."
L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Включить макрос анонса"
-- "- Dispenser" is the macro's literal name and is never translated.
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] =
	'Поддерживает персональный макрос "- Dispenser" в актуальном состоянии в соответствии с вашим текущим списком раздачи и удаляет макрос, когда вы это отключаете.'
-- "Enable Reserves" must match OPTIONS_ITEM_RESERVE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] =
	"Нечего анонсировать. Настройте предметы, пополните сумки или уменьшите резерв в разделе Включить резерв."

-- Macro message template (%s is the item list) and the connector before the last list entry.
L["ANNOUNCEMENTS_BODY"] = "У меня есть %s. Кидайте обмен!"
L["ANNOUNCEMENTS_AND"] = "и"

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["OPTIONS_SUPPORT"] = "Отзывы и поддержка"
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"
L["SUPPORT_WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Built-in Collections
--------------------------------------------------------------------------------

L["ITEM_MAGE_WATER"] = "Сотворенная вода"
L["ITEM_MAGE_FOOD"] = "Сотворенная еда"
L["ITEM_WARLOCK_HEALTHSTONE"] = "Камни здоровья"
