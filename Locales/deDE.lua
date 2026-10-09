local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "deDE")
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
L["ITEM_LOADING"] = "Wird geladen: ID %d"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

--[[
	All player-facing chat prints live here, regardless of which feature emits them.
	In CHAT_LOADED, %s is the add-on version and the menu path is the game client's
	own labels.
]]
L["CHAT_LOADED"] =
	"Version %s. Die Einstellungen (inklusive der Option, diese Nachricht zu deaktivieren) sind unter Optionen > AddOns > Water Dispenser zu finden. Gefällt dir das Add-on? Empfiehl es weiter! (="
L["CHAT_NO_TRADE"] = "Kein aktives Handelsfenster."
L["CHAT_COMBAT_BLOCKED"] = "WoW blockiert automatische Handelsvorgänge im Kampf."
L["CHAT_OPTIONS_IN_COMBAT"] =
	"Aus Sicherheitsgründen kann das Optionsfenster während des Kampfes nicht geöffnet werden."
-- The item and its count are appended after the colon by the code.
L["CHAT_MISSING_STACK"] = "Fehlt:"
--[[
	%s is the item's name, then the trade partner's name; %d is the Maximum per
	Player they have reached.
]]
L["CHAT_PLAYER_CAP_REACHED"] =
	"%s nicht hinzugefügt: %s hat von dir bereits %d bekommen. Die Zählung beginnt neu, wenn du dich ausloggst oder neu lädst."
-- %s is the item's name; the first %d is the amount that could not be split off, the second the item's full stack size.
L["CHAT_SPLIT_NEEDS_FULL_STACK"] =
	"%s nicht hinzugefügt: Das Spiel wollte %d nicht von einem Stapel abteilen. Setze die Menge auf einen vollen Stapel (%d), um ihn zu übergeben."
-- %s is the player's class name. "Dispensed Items" must match TAB_DISPENSED_ITEMS.
L["CHAT_NONE_ACTIVE_FOR_CLASS"] =
	"Es sind keine Gegenstände zur Ausgabe eingestellt, während du einen %s spielst. Öffne Optionen > AddOns > Water Dispenser > Ausgegebene Gegenstände, um Gegenstände für diese Klasse zu aktivieren."
-- "- Dispenser" is the macro's literal name and is never translated.
L["CHAT_MACRO_DELETED"] = 'Ankündigungs-Makro "- Dispenser" gelöscht.'
L["CHAT_MACRO_FULL"] = "Das Ankündigungs-Makro konnte nicht erstellt werden: Alle Charakter-Makroplätze sind belegt."

--------------------------------------------------------------------------------
-- Player Tooltips
--------------------------------------------------------------------------------

L["TOOLTIP_OPEN_TRADE"] = "Handel öffnen!"
-- %s is the Improved Healthstone talent's name from the client, then the warlock's rank out of its maximum.
L["TOOLTIP_HEALTHSTONE_TALENT"] = "%s %d/%d"

--------------------------------------------------------------------------------
-- Bag Item Tooltips
--------------------------------------------------------------------------------

-- Shown on a carried bag item the player has set up to give away.
L["TOOLTIP_WILL_DISPENSE"] = "Wird beim Handeln ausgegeben."

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BUTTON_CLEAR"] = "Handelsfenster leeren"
L["BUTTON_FILL"] = "Handelsfenster füllen"

--[[
	The silver status line under the trade panel's buttons. "Fill Trade Window" must
	match BUTTON_FILL. ADDED's %s is the window's contents, each FORMAT_ITEM_COUNT,
	joined like the announcement's list. In the rest, %s is an item or collection
	name unless noted.
]]
L["TRADE_STATUS_ADDED"] = "%s hinzugefügt."
-- %d is how many short.
L["TRADE_STATUS_SHORT"] = "%d %s zu wenig: nicht genug in deinen Taschen."
L["TRADE_STATUS_SHORT_RESERVE"] = "%d %s zu wenig: Deine Reserve behält den Rest."
L["TRADE_STATUS_DISPENSE_OFF"] =
	"Automatisches Füllen ist aus. Handelsfenster füllen fügt weiterhin deine üblichen Mengen hinzu."
L["TRADE_STATUS_OFF_STRANGERS"] =
	"Automatisches Füllen ist für Fremde aus. Handelsfenster füllen fügt weiterhin deine üblichen Mengen hinzu."
L["TRADE_STATUS_OFF_PARTY"] =
	"Automatisches Füllen ist für Gruppenmitglieder aus. Handelsfenster füllen fügt weiterhin deine üblichen Mengen hinzu."
L["TRADE_STATUS_OFF_RAID"] =
	"Automatisches Füllen ist für Schlachtzugsmitglieder aus. Handelsfenster füllen fügt weiterhin deine üblichen Mengen hinzu."
L["TRADE_STATUS_MASTER_LOOT"] =
	"Zurückgehalten, solange du Plündermeister bist. Handelsfenster füllen fügt weiterhin deine üblichen Mengen hinzu."
-- The first %s is the partner's class name.
L["TRADE_STATUS_ZERO"] = "Für %s auf 0 gesetzt: %s."
L["TRADE_STATUS_INSTANCE_ONLY"] = "%s wird nur in Instanzen ausgegeben."
L["TRADE_STATUS_GUILD_ONLY"] = "%s geht nur an deine Gilde."
-- The partner's name, then the rank they can't use yet and its level.
L["TRADE_STATUS_LEVEL"] = "%s kann %s erst ab Stufe %d benutzen."
-- The partner's name first.
L["TRADE_STATUS_TOO_LOW"] = "%s hat eine zu niedrige Stufe für %s."
-- The partner's name first.
L["TRADE_STATUS_CAPPED"] = "%s hat dein Maximum pro Spieler an %s erreicht."
L["TRADE_STATUS_NONE_HELD"] = "Du hast keinen Vorrat an %s zum Abgeben."
L["TRADE_STATUS_CLEARED"] = "Geleert."
--[[
	A conjure button's tooltip, under the spell's name. MAKES: the item it makes,
	then the trade partner's name and level. LOWEST, when no rank fits the partner:
	the item only.
]]
L["TRADE_CONJURE_MAKES"] = "Erzeugt %s, das Beste, was %s (Stufe %d) benutzen kann."
L["TRADE_CONJURE_MAKES_LOWEST"] = "Erzeugt %s, den niedrigsten Rang, den du kennst."

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

--[[
	The tooltip's feature row reuses TAB_DISPENSE for its name and
	OPTIONS_DISPENSE_MASTER_DESC for its description; these are its state and click words.
]]
L["UI_ENABLED"] = "Aktiviert"
L["UI_DISABLED"] = "Deaktiviert"
L["UI_LEFT_CLICK"] = "Linksklick"
L["UI_TOGGLE"] = "Umschalten"
L["MINIMAP_OPTIONS"] = "Water Dispenser-Optionen"
L["MINIMAP_OPTIONS_KEYBIND"] = "Umschalt + Mittelklick"
-- Heads the tooltip section listing what the player can give right now.
L["MINIMAP_DISPENSE_REPORT"] = "Ausgabebericht"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Mühelos Verbrauchsgüter verteilen. Füllt Handelsfenster automatisch mit herbeigezaubertem Wasser, Essen und Gesundheitssteinen im richtigen Rang und in der richtigen Menge für jeden Spieler. Füge beliebige Gegenstände hinzu, von Sanduhrsand bis zu Widerstandstränken, und versorge einen ganzen Schlachtzug in Sekunden."

L["OPTIONS_WELCOME_MESSAGE"] = "Willkommensnachricht aktivieren"
L["OPTIONS_WELCOME_MESSAGE_DESC"] =
	"Gibt beim Laden von Water Dispenser eine einzeilige Begrüßung in deinem Chatfenster aus."
L["OPTIONS_MINIMAP"] = "Minikarten-Schaltfläche aktivieren"
L["OPTIONS_MINIMAP_DESC"] = "Zeigt die Water Dispenser-Minikarten-Schaltfläche an."

L["OPTIONS_FEATURES_HEADER"] = "Funktionen"

L["OPTIONS_COMMANDS_HEADER"] = "/Befehle"
L["OPTIONS_COMMAND"] = "/wd"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Öffnet das Optionsfenster dieses Add-ons."

--------------------------------------------------------------------------------
-- Options — Dispense
--------------------------------------------------------------------------------

-- Names the panel and the mini-map tooltip's feature row.
L["TAB_DISPENSE"] = "Ausgabe"
L["OPTIONS_DISPENSE_MASTER"] = "Ausgabe aktivieren"
-- Also the panel's intro line and the mini-map tooltip's feature description.
L["OPTIONS_DISPENSE_MASTER_DESC"] =
	"Füllt das Handelsfenster automatisch nach deinen Einstellungen, sobald ein Handel geöffnet wird."
L["OPTIONS_DISPENSE_SOLO"] = "Für Fremde aktivieren"
L["OPTIONS_DISPENSE_SOLO_DESC"] =
	"Füllt das Handelsfenster automatisch, wenn du mit jemandem handelst, der nicht in deiner Gruppe oder deinem Schlachtzug ist."
L["OPTIONS_DISPENSE_GROUP"] = "Für Gruppe aktivieren"
L["OPTIONS_DISPENSE_GROUP_DESC"] = "Füllt das Handelsfenster automatisch, wenn du mit einem Gruppenmitglied handelst."
L["OPTIONS_DISPENSE_RAID"] = "Für Schlachtzug aktivieren"
L["OPTIONS_DISPENSE_RAID_DESC"] =
	"Füllt das Handelsfenster automatisch, wenn du mit einem Schlachtzugsmitglied handelst."
-- The label says what it does; the tooltip only covers why it is needed and when it stands down.
L["OPTIONS_RESTACK"] = "Teilstapel nach einem Handel zusammenlegen"
L["OPTIONS_RESTACK_DESC"] =
	"Herbeigezaubertes Wasser und Essen landen bei jedem Zauber in einem neuen Taschenplatz und das Spiel legt sie nie wieder zusammen, also führt Water Dispenser sie einmal zusammen, direkt nachdem sich ein Handelsfenster geschlossen hat, und nie zu einem anderen Zeitpunkt, im Kampf oder während du etwas auf dem Mauszeiger hältst."
L["OPTIONS_HOLD_MASTER_LOOT"] = "Zurückhalten, solange du Plündermeister bist"
-- "Fill Trade Window" must match BUTTON_FILL.
L["OPTIONS_HOLD_MASTER_LOOT_DESC"] =
	"Lässt das Handelsfenster leer, solange du in einer Instanz Plündermeister bist, da diese Handel dem Verteilen von Beute dienen. Handelsfenster füllen fügt weiterhin deine üblichen Mengen hinzu."
L["OPTIONS_CONJURE_BUTTONS"] = "Herbeizauberungs-Schaltflächen neben dem Handel anzeigen"
-- "Fill Trade Window" must match BUTTON_FILL.
L["OPTIONS_CONJURE_BUTTONS_DESC"] =
	"Fügt unter Handelsfenster füllen Schaltflächen hinzu, die Wasser, Essen oder einen Gesundheitsstein herbeizaubern, den dein Handelspartner auf seiner Stufe benutzen kann, und was du herstellst, landet direkt im offenen Handel."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "Warnungen aktivieren, wenn dir etwas ausgeht"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] =
	"Gibt einen Hinweis in deinem Chatfenster aus, wenn du nicht genug von einem eingerichteten Gegenstand in deinen Taschen hast, um die eingestellte Menge zu geben."

-- Leads the silver line under a setting that shows the exact chat line it prints.
L["OPTIONS_EXAMPLE"] = "Beispiel:"

L["OPTIONS_COMBAT_HEADER"] = "Kampf"
L["OPTIONS_COMBAT_DESC"] = "WoW hindert Add-ons daran, im Kampf Gegenstände in einen Handel zu legen."
L["OPTIONS_COMBAT_NOTIFY"] = "Benachrichtigungen aktivieren, wenn die Ausgabe blockiert ist"
L["OPTIONS_COMBAT_NOTIFY_DESC"] =
	"Gibt einen Hinweis in deinem Chatfenster aus, wenn der Kampf das Füllen eines Handels verhindert."

--------------------------------------------------------------------------------
-- Options — Inventory Tooltips
--------------------------------------------------------------------------------

L["TAB_INVENTORY_TOOLTIPS"] = "Inventar-Tooltips"
L["OPTIONS_TOOLTIPS_DESC"] =
	"Zeigt in Spieler-Tooltips, was Gruppenmitglieder, die Water Dispenser verwenden, zum Verschenken eingerichtet haben, und markiert die Gegenstände, die du selbst verschenkst, in deinen eigenen Taschen."
L["OPTIONS_SHOW_INVENTORY"] = "Inventar in Spieler-Tooltips anzeigen"
L["OPTIONS_SHOW_INVENTORY_DESC"] =
	"Fügt Spieler-Tooltips einen Water Dispenser-Block hinzu, der auflistet, was sie zum Verschenken eingerichtet haben und wie viele sie davon abgeben können, wobei dein eigener immer angezeigt wird, ob in einer Gruppe oder nicht."
L["OPTIONS_BAG_TOOLTIPS"] = "Taschen-Tooltips für ausgegebene Gegenstände anzeigen"
L["OPTIONS_BAG_TOOLTIPS_DESC"] =
	"Fügt dem Tooltip eines Taschengegenstands eine Water Dispenser-Zeile hinzu, wenn dieser Gegenstand zum Verschenken eingestellt ist, damit du auf einen Blick siehst, was das Add-on herausgeben wird."
L["OPTIONS_SHARE_INVENTORY"] = "Mein Inventar teilen"
L["OPTIONS_SHARE_INVENTORY_DESC"] =
	"Teilt deiner Gruppe oder deinem Schlachtzug mit, was du abzugeben hast, damit es erscheint, wenn sie mit der Maus über dich fahren. Schreibt nie in den Chat und erreicht niemanden außerhalb deiner Gruppe. Ausgeschaltet siehst du ihres weiterhin."

--------------------------------------------------------------------------------
-- Options — Dispensed Items
--------------------------------------------------------------------------------

L["TAB_DISPENSED_ITEMS"] = "Ausgegebene Gegenstände"
L["OPTIONS_ITEMS_DESC"] =
	"Lege fest, wie viele von jedem Gegenstand ausgegeben werden. Mengen zählen einzelne Gegenstände, 20 Wasser bedeutet also 20 Wasser, und 1 Trank bedeutet 1 Trank. Ein Stapel wird bei Bedarf auf die genaue Menge aufgeteilt."
-- "Add an Item" must match OPTIONS_ADD_ITEM.
L["OPTIONS_ITEMS_EMPTY"] =
	'Keine Gegenstände konfiguriert. Wähle "Gegenstand hinzufügen" in der Liste, um beliebige handelbare Gegenstände aus deinen Taschen hinzuzufügen.'

--[[
	The silver line opening an item's page while nothing of it would go out. In
	OTHER_CLASS, %s is the player's class twice, then OPTIONS_ITEM_PLAYER_CLASSES;
	in ALL_ZERO, %s is OPTIONS_ITEM_EVERYONE.
]]
L["OPTIONS_ITEM_STATUS_OTHER_CLASS"] = "Wird nicht ausgegeben, während du einen %s spielst. Hake %s unter %s an."
L["OPTIONS_ITEM_STATUS_ALL_ZERO"] = "Noch geht nichts raus: Jede Menge ist 0. Gib bei %s eine Zahl ein, um zu beginnen."

L["OPTIONS_ITEM_AMOUNTS"] = "Mengen"
L["OPTIONS_ITEM_AMOUNTS_DESC"] =
	"Wähle, wie viele jede Klasse beim Handel erhält, je nachdem, ob sie fremd, in deiner Gruppe oder in deinem Schlachtzug ist. Gezählt werden einzelne Gegenstände, keine Stapel. Null bedeutet, dass sie diesen Gegenstand nie erhalten."
L["OPTIONS_ITEM_EVERYONE"] = "Alle"
-- "Apply" must match OPTIONS_ITEM_APPLY.
L["OPTIONS_ITEM_EVERYONE_DESC"] =
	"Setzt diese Menge für alle Klassen auf einmal, wenn du die Eingabetaste drückst oder auf Übernehmen klickst, und bleibt leer, wenn die Klassen unten nicht alle übereinstimmen."
-- The accept button inside every number box in this panel.
L["OPTIONS_ITEM_APPLY"] = "Übernehmen"
-- %d is the highest amount this item accepts, which is 1 for anything unique.
L["OPTIONS_ITEM_COUNT_TOO_HIGH"] = "Das ist mehr, als du von diesem Gegenstand geben kannst. Das Maximum ist %d."
L["OPTIONS_ITEM_COUNT_INVALID"] = "Gib eine Anzahl von Gegenständen ein."
L["OPTIONS_ITEM_SETTINGS"] = "Gegenstandseinstellungen"
L["OPTIONS_ITEM_DISTRIBUTE"] = "Verteilen"
-- "In Instance" must match OPTIONS_ITEM_DISTRIBUTE_INSTANCE.
L["OPTIONS_ITEM_DISTRIBUTE_DESC"] =
	"Legt fest, wo dieser Gegenstand ausgegeben wird. In Instanzen umfasst Dungeons, Schlachtzüge, Schlachtfelder und Arenen. Überall sonst wird der Gegenstand nie gehandelt, angekündigt oder in deinem Tooltip gezeigt."
--[[
	Dropdown entries, looked up as OPTIONS_ITEM_DISTRIBUTE_ plus the stored value in
	capitals ("Always", "Instance"), so no code names these keys in full.
]]
L["OPTIONS_ITEM_DISTRIBUTE_ALWAYS"] = "Immer"
L["OPTIONS_ITEM_DISTRIBUTE_INSTANCE"] = "In Instanzen"
L["OPTIONS_ITEM_GUILDIES_ONLY"] = "Nur Gildenmitglieder"
L["OPTIONS_ITEM_GUILDIES_ONLY_DESC"] =
	"Überspringt diesen Gegenstand, wenn dein Handelspartner nicht in deiner Gilde ist."
-- Panel line under the toggle, not a tooltip: it names the guild, which no fixed string can. %s is the player's guild.
L["OPTIONS_ITEM_GUILDIES_ONLY_HELP"] = "Nur an Mitglieder von <%s> geben."
L["OPTIONS_ITEM_GUILDIES_ONLY_NO_GUILD"] = "Du bist in keiner Gilde, also gibt dies den Gegenstand an niemanden aus."
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Stufenanforderung des Gegenstands berücksichtigen"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] =
	"Überspringt diesen Gegenstand, wenn dein Handelspartner unter der benötigten Stufe des Gegenstands liegt."
L["OPTIONS_ITEM_RESERVE"] = "Reserven aktivieren"
L["OPTIONS_ITEM_RESERVE_DESC"] =
	"Behält immer mindestens diese Menge in deinen Taschen, wobei die Ausgabe, dein Spieler-Tooltip und das Ankündigungs-Makro alles darüber hinaus als verschenkbar behandeln."
L["OPTIONS_ITEM_PLAYER_CAP"] = "Maximum pro Spieler aktivieren"
L["OPTIONS_ITEM_PLAYER_CAP_DESC"] =
	"Gibt diesen Gegenstand nicht mehr an jemanden aus, sobald er so viele von dir bekommen hat. Die Zählung beginnt neu, wenn du dich ausloggst, neu lädst oder die Mengen dieses Gegenstands änderst."
-- The label carries the meaning on its own; the tooltip only says why you'd switch it off.
L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "Menge im Spieler-Tooltip und Ankündigungs-Makro anzeigen"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] =
	"Ausgeschaltet wird der Gegenstand ohne Zahl daneben genannt, was sich bei etwas besser liest, von dem du immer nur eines trägst, wie einem Gesundheitsstein."
L["OPTIONS_ITEM_PLAYER_CLASSES"] = "Nur ausgeben, wenn diese Klassen gespielt werden"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] =
	"Füllt Handel, nimmt diesen Gegenstand in das Ankündigungs-Makro auf und zeigt ihn in deinem Spieler-Tooltip nur dann, wenn die Klasse deines Charakters unten ausgewählt ist."
L["OPTIONS_ITEM_REMOVE"] = "Gegenstand entfernen"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "Diesen Gegenstand aus deinen ausgegebenen Gegenständen entfernen?"

L["OPTIONS_SCOPE_SOLO"] = "Fremde"
L["OPTIONS_SCOPE_GROUP"] = "Gruppe"
L["OPTIONS_SCOPE_RAID"] = "Schlachtzug"

L["OPTIONS_ADD_ITEM"] = "Gegenstand hinzufügen"
L["OPTIONS_ADD_DESC"] =
	"Wähle einen beliebigen handelbaren Gegenstand aus deinen Taschen, um ihn zu deinen ausgegebenen Gegenständen hinzuzufügen. Bereits konfigurierte oder seelengebundene Gegenstände erscheinen nicht."
L["OPTIONS_ADD_SELECT"] = "Verfügbare Gegenstände"
L["OPTIONS_ADD_BUTTON"] = "Zu ausgegebenen Gegenständen hinzufügen"
L["OPTIONS_ADD_EMPTY"] = "Keine handelbaren Gegenstände in deinen Taschen gefunden."

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["TAB_ANNOUNCEMENTS"] = "Ankündigungen"
L["OPTIONS_ANNOUNCEMENTS_DESC"] =
	"Water Dispenser kann ein Makro erstellen, das ansagt, was du noch zu verschenken hast. Das Makro wählt automatisch den richtigen Kanal (Sagen ohne Gruppe, Gruppe in einer Gruppe, Schlachtzug in einem Schlachtzug, Instanz in einer Instanz- oder Schlachtfeldgruppe) und nutzt die aktuellen Zahlen direkt aus deinen Taschen."
L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Ankündigungs-Makro aktivieren"
-- "- Dispenser" is the macro's literal name and is never translated.
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] =
	'Hält ein charakterspezifisches Makro namens "- Dispenser" mit deinen aktuellen ausgegebenen Gegenständen auf dem neuesten Stand und löscht das Makro, wenn du dies deaktivierst.'
-- "Enable Reserves" must match OPTIONS_ITEM_RESERVE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] =
	"Nichts anzukündigen. Konfiguriere Gegenstände, fülle deine Taschen auf oder senke eine Reserve unter Reserven aktivieren."
-- "Enable Dispense" must match OPTIONS_DISPENSE_MASTER, "Dispense" must match TAB_DISPENSE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DISPENSE_OFF"] =
	"Nichts anzukündigen, solange Ausgabe aktivieren im Reiter Ausgabe ausgeschaltet ist."

-- Macro message template (%s is the item list) and the connector before the last list entry.
L["ANNOUNCEMENTS_BODY"] = "Ich habe %s. Handel öffnen!"
L["ANNOUNCEMENTS_AND"] = "und"

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["OPTIONS_SUPPORT"] = "Feedback & Unterstützung"
-- The General panel's last line. %s is the version.
L["OPTIONS_VERSION"] = "Version %s"
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"
L["SUPPORT_WAGO"] = "Wago"
