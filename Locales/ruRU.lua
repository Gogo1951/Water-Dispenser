local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "ruRU")
if not L then return end

L["CHAT_LOADED"] = "Включен. Используйте %s для доступа к настройкам, включая отключение этого сообщения. Нравится Water Dispenser? Расскажите друзьям! (="
L["CHAT_NO_TRADE"] = "Нет активного окна обмена."
L["CHAT_COMBAT_PAUSED"] = "Автозаполнение приостановлено во время боя."
L["CHAT_COMBAT_RESUMED"] = "Бой завершен. Возобновление автозаполнения обмена."
L["CHAT_MISSING_STACK"] = "Недостающие стаки:"
L["CHAT_ITEM_SAVED"] = "Сохранено:"
L["CHAT_ITEM_REMOVED"] = "Удалено:"

L["BTN_CLEAR"] = "Очистить обмен"
L["BTN_FILL"] = "Заполнить обмен"
L["BTN_CONFIG"] = "Настройки"
L["BTN_ACCEPT"] = "Принять обмен"

L["OPTIONS_TITLE"] = "Water Dispenser"
L["OPTIONS_DESC"] = "Автоматически заполняет окно обмена стаками воды, еды, камнями здоровья или любыми настроенными расходуемыми предметами, в зависимости от класса, уровня и группы партнера по обмену."

L["OPTIONS_GENERAL_HEADER"] = "Общие настройки"
L["OPTIONS_WELCOME_MESSAGE"] = "Включить приветственное сообщение"
L["OPTIONS_WELCOME_MESSAGE_DESC"] = "Выводит короткое приветствие в чат при загрузке Water Dispenser."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "Предупреждения о нехватке стаков"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] = "Выводит сообщение в чат, если для настроенного предмета недостаточно стаков в ваших сумках для заполнения обмена."
L["OPTIONS_ITEMS"] = "Правила раздачи"
L["OPTIONS_ADD_ITEM"] = "Добавить предмет"
L["OPTIONS_SUPPORT"] = "Обратная связь"

L["OPTIONS_AUTOFILL_HEADER"] = "Автозаполнение"
L["OPTIONS_AUTOFILL_DESC"] = "Автоматически заполнять окно при начале обмена. Каждая область действия переключается независимо."
L["OPTIONS_AUTOFILL_SOLO"] = "Для незнакомцев"
L["OPTIONS_AUTOFILL_SOLO_DESC"] = "Автоматически заполняет окно при обмене с игроками не из вашей группы или рейда."
L["OPTIONS_AUTOFILL_GROUP"] = "Для членов группы"
L["OPTIONS_AUTOFILL_GROUP_DESC"] = "Автоматически заполняет окно при обмене с членом вашей группы."
L["OPTIONS_AUTOFILL_RAID"] = "Для членов рейда"
L["OPTIONS_AUTOFILL_RAID_DESC"] = "Автоматически заполняет окно при обмене с членом вашего рейда."

L["OPTIONS_COMBAT_HEADER"] = "Бой"
L["OPTIONS_COMBAT_DESC"] = "Автозаполнение всегда приостанавливается в бою во избежание ошибок интерфейса. В чат будет выведено напоминание. Обмен продолжится автоматически по окончании боя, если окно все еще открыто."

L["OPTIONS_LOCKED_HEADER"] = "Лари разбойника"
L["OPTIONS_LOCKED_DESC"] = "При обмене с разбойником помещает первый найденный закрытый предмет в слот \"не для обмена\", чтобы его можно было взломать."
L["OPTIONS_LOCKED"] = "Предлагать запертые предметы разбойникам"

L["OPTIONS_RESET_HEADER"] = "Сброс"
L["OPTIONS_RESET_DESC"] = "Сбрасывает все настройки Water Dispenser для этого персонажа к значениям по умолчанию, включая ваш список предметов."
L["OPTIONS_RESET_BUTTON"] = "Сбросить все настройки"
L["OPTIONS_RESET_CONFIRM"] = "Вы уверены, что хотите сбросить все настройки этого персонажа к значениям по умолчанию?"

L["OPTIONS_COMMANDS_HEADER"] = "/Команды"
L["OPTIONS_COMMANDS_DESC"] = "Текстовые команды Water Dispenser. В панели настроек есть все необходимое; эти команды для тех, кто предпочитает использовать клавиатуру."
L["OPTIONS_COMMAND_WD"] = "/wd"
L["OPTIONS_COMMAND_WD_DESC"] = "Открывает настройки Water Dispenser."
L["OPTIONS_COMMAND_WD_FILL"] = "/wd fill"
L["OPTIONS_COMMAND_WD_FILL_DESC"] = "Заполнить окно обмена сейчас, даже если автозаполнение отключено."
L["OPTIONS_COMMAND_WD_CLEAR"] = "/wd clear"
L["OPTIONS_COMMAND_WD_CLEAR_DESC"] = "Очистить все слоты в окне обмена."
L["OPTIONS_COMMAND_WD_AUTO"] = "/wd auto solo||group||raid on||off"
L["OPTIONS_COMMAND_WD_AUTO_DESC"] = "Переключает автозаполнение для указанной области. Не указывайте on/off для изменения текущего состояния."
L["OPTIONS_COMMAND_WDA"] = "/wda"
L["OPTIONS_COMMAND_WDA_DESC"] = "Отправляет сообщение-анонс в канал, соответствующий вашей текущей группе."

L["CHAT_RESET"] = "Все настройки сброшены по умолчанию."

L["OPTIONS_ITEMS_DESC"] = "Настройте количество стаков каждого предмета для раздачи. Примечание: Classic Era и TBC Anniversary не поддерживают автоматическое разделение стаков."
L["OPTIONS_ITEMS_EMPTY"] = "Нет настроенных предметов. Откройте вкладку \"Добавить предмет\", чтобы добавить расходуемые предметы из ваших сумок."

L["OPTIONS_ITEM_SETTINGS"] = "Настройки предмета"
L["OPTIONS_ITEM_USE_NOT_FULL"] = "Использовать неполные стаки"
L["OPTIONS_ITEM_USE_NOT_FULL_DESC"] = "Если нет полного стака, заполняет обмен меньшим количеством, которое есть у вас в сумках."

L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Учитывать требования к уровню"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] = "Пропускать этот предмет, если уровень партнера по обмену ниже требуемого."

L["OPTIONS_ITEM_KEEP_AT_LEAST"] = "Оставлять как минимум"
L["OPTIONS_ITEM_KEEP_AT_LEAST_DESC"] = "Всегда оставлять как минимум это количество в ваших сумках. Все, что превышает это число, будет считаться доступным для раздачи."

L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "Включать оставшееся количество в макрос"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] = "Указывать количество в анонсе макроса. Отключите, если хотите просто сказать о наличии (обычно для камней здоровья)."

L["OPTIONS_ITEM_PLAYER_CLASSES"] = "Раздавать только играя этими классами"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] = "Заполнять окно обмена и анонсировать этот предмет только в том случае, если класс вашего персонажа выбран ниже."

L["OPTIONS_ITEM_REMOVE"] = "Удалить предмет"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "Удалить этот предмет из настроек обмена?"

L["OPTIONS_SCOPE_SOLO"] = "Незнакомцы"
L["OPTIONS_SCOPE_GROUP"] = "Члены группы"
L["OPTIONS_SCOPE_RAID"] = "Члены рейда"

L["OPTIONS_ADD_DESC"] = "Выберите передаваемый расходуемый предмет из ваших сумок для добавления в настройки. Уже настроенные или персональные предметы не отображаются."
L["OPTIONS_ADD_SELECT"] = "Доступные предметы"
L["OPTIONS_ADD_BUTTON"] = "Добавить в настройки"
L["OPTIONS_ADD_EMPTY"] = "В ваших сумках не найдено подходящих расходуемых предметов."

L["SUPPORT_DESC"] = "Сообщайте об ошибках, просите о новых функциях или просто поздоровайтесь в Discord."
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"

L["OPTIONS_ANNOUNCEMENTS"] = "Анонсы"
L["OPTIONS_ANNOUNCEMENTS_DESC"] = "Water Dispenser может создать макрос для анонса того, что у вас есть для раздачи. Макрос автоматически выбирает канал (/сказать, /группа, /рейд) и использует актуальное количество из сумок."

L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Включить макрос анонса"
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] = "Поддерживает персональный макрос \"- Dispenser\" в актуальном состоянии. При отключении макрос удаляется."

L["OPTIONS_ANNOUNCEMENTS_PREVIEW_HEADER"] = "Предпросмотр"
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DESC"] = "Вот что скажет макрос, если вы нажмете его прямо сейчас."
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] = "Нечего анонсировать. Настройте предметы, пополните сумки или уменьшите значение \"Оставлять как минимум\"."

L["ANNOUNCEMENTS_INTRO"] = "У меня есть"
L["ANNOUNCEMENTS_OUTRO"] = ". Кидайте обмен!"
L["ANNOUNCEMENTS_AND"] = "и"

L["CHAT_MACRO_CREATED"] = "Макрос анонса \"- Dispenser\" готов. Откройте интерфейс макросов (/m) и перетащите его на панель команд."
L["CHAT_MACRO_DELETED"] = "Макрос анонса \"- Dispenser\" удален."
L["CHAT_MACRO_FULL"] = "Не удалось создать макрос: все персональные слоты для макросов заняты."
L["CHAT_NOTHING_TO_ANNOUNCE"] = "На данный момент нечего анонсировать."

L["ITEM_MAGE_WATER"] = "Любая сотворенная вода"
L["ITEM_MAGE_FOOD"] = "Любая сотворенная еда"
L["ITEM_WARLOCK_HEALTHSTONE"] = "Любой камень здоровья"