local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "deDE")
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
	"Version %s. Die Einstellungen (inklusive der Option, diese Nachricht zu deaktivieren) sind unter Optionen > AddOns > Water Dispenser zu finden. Gefällt dir das Add-on? Empfiehl es weiter! (="
L["CHAT_NO_TRADE"] = "Kein aktives Handelsfenster."
L["CHAT_COMBAT_BLOCKED"] = "WoW blockiert automatische Handelsvorgänge im Kampf."
L["CHAT_OPTIONS_IN_COMBAT"] =
	"Aus Sicherheitsgründen kann das Optionsfenster während des Kampfes nicht geöffnet werden."
-- The item and its count are appended after the colon by the code.
L["CHAT_MISSING_STACK"] = "Fehlt:"
-- %s is the item's name, %d the Maximum per Session it has hit.
-- "Maximum per Session" must match OPTIONS_ITEM_SESSION_CAP.
L["CHAT_SESSION_CAP_REACHED"] =
	"%s nicht hinzugefügt: Sie haben ihre %d in dieser Sitzung bereits erhalten. Ändere Maximum pro Sitzung oder lade neu, um zurückzusetzen."
-- %s is the item's name, %d the amount that could not be split off.
L["CHAT_SPLIT_REFUSED"] =
	"%s nicht hinzugefügt: Dieser Client wollte %d nicht von einem Stapel abteilen, und stattdessen einen ganzen Stapel zu übergeben würde weit mehr verschenken, als du wolltest. Setze die Menge dieses Gegenstands auf einen ganzen Stapel, um ihn zu handeln."
-- %s is the player's class name. "Dispensed Items" must match TAB_DISPENSED_ITEMS.
L["CHAT_NONE_ACTIVE_FOR_CLASS"] =
	"Es sind keine Gegenstände zur Ausgabe eingestellt, während du einen %s spielst. Öffne Optionen > Ausgegebene Gegenstände, um Gegenstände für diese Klasse zu aktivieren."
-- The item's name is appended after the colon by the code.
L["CHAT_ITEM_SAVED"] = "Gespeichert:"
-- "- Dispenser" is the macro's literal name and is never translated.
L["CHAT_MACRO_DELETED"] = 'Ankündigungs-Makro "- Dispenser" gelöscht.'
L["CHAT_MACRO_FULL"] = "Makro konnte nicht erstellt werden: Alle Charakter-Makroplätze sind belegt."

--------------------------------------------------------------------------------
-- Player Tooltips
--------------------------------------------------------------------------------

L["TOOLTIP_OPEN_TRADE"] = "Handel öffnen!"
-- %d/%d is the warlock's Improved Healthstone rank out of its maximum.
L["TOOLTIP_HEALTHSTONE"] = "Gesundheitsstein (Rang %d/%d)"

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BUTTON_CLEAR"] = "Handelsfenster leeren"
L["BUTTON_FILL"] = "Handelsfenster füllen"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

-- The tooltip's feature row reuses OPTIONS_DISPENSE_HEADER for its name; these are its state and click words.
L["UI_ENABLED"] = "Aktiviert"
L["UI_DISABLED"] = "Deaktiviert"
L["UI_LEFT_CLICK"] = "Linksklick"
L["UI_TOGGLE"] = "Umschalten"
L["MINIMAP_OPTIONS"] = "Water Dispenser-Optionen"
L["MINIMAP_OPTIONS_KEYBIND"] = "Umschalt + Mittelklick"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Füllt das Handelsfenster automatisch mit Wasser, Essen, Gesundheitssteinen oder jedem Verbrauchsgegenstand, den du einrichtest, in der Menge, die du für Klasse, Stufe und Gruppenzugehörigkeit des Handelspartners festgelegt hast."

L["OPTIONS_WELCOME_MESSAGE"] = "Willkommensnachricht aktivieren"
L["OPTIONS_WELCOME_MESSAGE_DESC"] =
	"Gibt beim Laden von Water Dispenser eine einzeilige Begrüßung in deinem Chatfenster aus."
L["OPTIONS_MINIMAP"] = "Minikarten-Schaltfläche aktivieren"
L["OPTIONS_MINIMAP_DESC"] = "Zeigt die Water Dispenser-Minikarten-Schaltfläche an."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "Warnungen aktivieren, wenn dir etwas ausgeht"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] =
	"Gibt einen Hinweis in deinem Chatfenster aus, wenn du nicht genug von einem eingerichteten Gegenstand in deinen Taschen hast, um die eingestellte Menge zu geben."
-- The label says what it does; the tooltip only covers why it is needed and when it stands down.
L["OPTIONS_RESTACK"] = "Teilstapel in den Taschen automatisch zusammenlegen"
L["OPTIONS_RESTACK_DESC"] =
	"Herbeigezaubertes Wasser und Essen landen bei jedem Zauber in einem neuen Taschenplatz und das Spiel legt sie nie wieder zusammen, wobei dies jedoch nie im Kampf, bei geöffnetem Handel oder während du etwas auf dem Mauszeiger hältst läuft."

L["OPTIONS_COMMANDS_HEADER"] = "/Befehle"
L["OPTIONS_COMMAND"] = "/wd"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Öffnet das Optionsfenster dieses Add-ons."

L["OPTIONS_DISPENSE_HEADER"] = "Ausgeben"
L["OPTIONS_DISPENSE_DESC"] =
	"Füllt das Handelsfenster automatisch, sobald ein Handel geöffnet wird. Schalte jede Option unten einzeln um."
L["OPTIONS_DISPENSE_MASTER"] = "Ausgabe aktivieren"
L["OPTIONS_DISPENSE_MASTER_DESC"] = "Füllt das Handelsfenster automatisch basierend auf deinen Einstellungen."
L["OPTIONS_DISPENSE_SOLO"] = "Für Fremde aktivieren"
L["OPTIONS_DISPENSE_SOLO_DESC"] =
	"Füllt das Handelsfenster automatisch, wenn du mit jemandem handelst, der nicht in deiner Gruppe oder deinem Schlachtzug ist."
L["OPTIONS_DISPENSE_GROUP"] = "Für Gruppe aktivieren"
L["OPTIONS_DISPENSE_GROUP_DESC"] = "Füllt das Handelsfenster automatisch, wenn du mit einem Gruppenmitglied handelst."
L["OPTIONS_DISPENSE_RAID"] = "Für Schlachtzug aktivieren"
L["OPTIONS_DISPENSE_RAID_DESC"] =
	"Füllt das Handelsfenster automatisch, wenn du mit einem Schlachtzugsmitglied handelst."

L["OPTIONS_TOOLTIPS_HEADER"] = "Inventar in Spieler-Tooltips"
L["OPTIONS_TOOLTIPS_DESC"] =
	"Zeigt das Verschenk-Inventar in den Tooltips von Gruppenmitgliedern, die Water Dispenser verwenden."
L["OPTIONS_SHOW_INVENTORY"] = "Inventar in Spieler-Tooltips anzeigen"
L["OPTIONS_SHOW_INVENTORY_DESC"] =
	"Fügt Spieler-Tooltips einen Water Dispenser-Block hinzu, der auflistet, was sie zum Verschenken eingerichtet haben und wie viele sie davon tragen, wobei dein eigener immer angezeigt wird, ob in einer Gruppe oder nicht."
L["OPTIONS_SHARE_INVENTORY"] = "Mein Inventar teilen"
L["OPTIONS_SHARE_INVENTORY_DESC"] =
	"Teilt deiner Gruppe und deinem Schlachtzug mit, was du bei dir trägst, sodass dein Inventar erscheint, wenn sie dich anvisieren, schreibt dabei nichts in den Chat und informiert niemanden außerhalb deiner Gruppe, und deaktiviert kannst du die Inventare anderer weiterhin lesen."

L["OPTIONS_COMBAT_HEADER"] = "Kampf"
L["OPTIONS_COMBAT_DESC"] = "WoW hindert Add-ons daran, im Kampf Gegenstände in einen Handel zu legen."
L["OPTIONS_COMBAT_NOTIFY"] = "Benachrichtigungen aktivieren, wenn die Ausgabe blockiert ist"
L["OPTIONS_COMBAT_NOTIFY_DESC"] =
	"Gibt einen Hinweis in deinem Chatfenster aus, wenn der Kampf das Füllen eines Handels verhindert, und deaktiviert bleibt Water Dispenser still, ohne zu erklären, warum der Handel leer geblieben ist."

--------------------------------------------------------------------------------
-- Options — Dispensed Items
--------------------------------------------------------------------------------

L["TAB_DISPENSED_ITEMS"] = "Ausgegebene Gegenstände"
L["OPTIONS_ITEMS_DESC"] =
	"Lege fest, wie viele von jedem Gegenstand ausgegeben werden. Mengen zählen einzelne Gegenstände, 20 Wasser bedeutet also 20 Wasser, und 1 Trank bedeutet 1 Trank. Ein Stapel wird bei Bedarf auf die genaue Menge aufgeteilt."
-- "Add an Item" must match OPTIONS_ADD_ITEM.
L["OPTIONS_ITEMS_EMPTY"] =
	'Keine Gegenstände konfiguriert. Wähle "Gegenstand hinzufügen" in der Liste, um Verbrauchsgegenstände aus deinen Taschen hinzuzufügen.'

L["OPTIONS_ITEM_DISTRIBUTION"] = "Verteilung"
L["OPTIONS_ITEM_DISTRIBUTION_DESC"] =
	"Wähle, wie viele jede Klasse beim Handel erhält, je nachdem, ob sie fremd, in deiner Gruppe oder in deinem Schlachtzug ist. Gezählt werden einzelne Gegenstände, keine Stapel. Null bedeutet, dass sie diesen Gegenstand nie erhalten."
L["OPTIONS_ITEM_EVERYONE"] = "Alle"
L["OPTIONS_ITEM_EVERYONE_DESC"] =
	"Setzt diese Menge mit einem Druck auf die Eingabetaste für alle Klassen auf einmal und bleibt leer, wenn die Klassen unten nicht alle übereinstimmen."
-- The accept button inside every number box in this panel.
L["OPTIONS_ITEM_APPLY"] = "Übernehmen"
-- %d is the highest amount this item accepts, which is 1 for anything unique.
L["OPTIONS_ITEM_COUNT_TOO_HIGH"] = "Das ist mehr, als dieser Gegenstand ausgeben kann. Das Maximum ist %d."
L["OPTIONS_ITEM_COUNT_INVALID"] = "Gib eine Anzahl von Gegenständen ein oder 0, um diesen nie auszugeben."
L["OPTIONS_ITEM_SETTINGS"] = "Gegenstandseinstellungen"
-- "In Group" and "In Raid" in the tooltip must match the two dropdown entries below.
L["OPTIONS_ITEM_DISTRIBUTE"] = "Verteilen"
L["OPTIONS_ITEM_DISTRIBUTE_DESC"] =
	"Legt fest, wann dieser Gegenstand überhaupt herausgegeben wird, außerhalb der gewählten Gruppe nie gehandelt, angekündigt oder in deinem Tooltip gezeigt, wobei In Gruppe eine Gruppe oder einen Schlachtzug abdeckt und In Schlachtzug nur Schlachtzüge."
-- Dropdown entries. The stored values are "Always", "Group", and "Raid"; these are only their labels.
L["OPTIONS_ITEM_DISTRIBUTE_ALWAYS"] = "Immer"
L["OPTIONS_ITEM_DISTRIBUTE_GROUP"] = "In Gruppe"
L["OPTIONS_ITEM_DISTRIBUTE_RAID"] = "In Schlachtzug"
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Stufenanforderungen berücksichtigen"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] =
	"Überspringt diesen Gegenstand, wenn der Handelspartner unter der benötigten Stufe des Gegenstands liegt."
L["OPTIONS_ITEM_RESERVE"] = "Reserven aktivieren"
L["OPTIONS_ITEM_RESERVE_DESC"] =
	"Behält immer mindestens diese Menge in deinen Taschen, wobei die Ausgabe und das Ankündigungs-Makro alles darüber hinaus als verschenkbar behandeln."
L["OPTIONS_ITEM_SESSION_CAP"] = "Maximum pro Sitzung aktivieren"
L["OPTIONS_ITEM_SESSION_CAP_DESC"] =
	"Gibt diesen Gegenstand nicht mehr an jemanden aus, sobald er so viele von dir erhalten hat, gezählt über alle Handel hinweg, bis du dich ausloggst oder neu lädst, und das Ändern einer Menge dieses Gegenstands setzt die Zählung für alle zurück."
-- The label carries the meaning on its own; the tooltip only says why you'd switch it off.
L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "Menge im Spieler-Tooltip und Ankündigungs-Makro anzeigen"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] =
	"Aus benennt den Gegenstand ohne Zahl daneben, was sich bei etwas besser liest, von dem du immer nur eines trägst, wie einem Gesundheitsstein."
L["OPTIONS_ITEM_PLAYER_CLASSES"] = "Nur ausgeben, wenn diese Klassen gespielt werden"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] =
	"Füllt Handel nur dann und nimmt diesen Gegenstand nur dann in die Ankündigung auf, wenn die Klasse deines Charakters unten ausgewählt ist."
L["OPTIONS_ITEM_REMOVE"] = "Gegenstand entfernen"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "Diesen Gegenstand aus der Handelskonfiguration entfernen?"

L["OPTIONS_SCOPE_SOLO"] = "Fremde"
L["OPTIONS_SCOPE_GROUP"] = "Gruppe"
L["OPTIONS_SCOPE_RAID"] = "Schlachtzug"

L["OPTIONS_ADD_ITEM"] = "Gegenstand hinzufügen"
L["OPTIONS_ADD_DESC"] =
	"Wähle einen beliebigen handelbaren Gegenstand aus deinen Taschen, um ihn zur Handelskonfiguration hinzuzufügen. Bereits konfigurierte oder seelengebundene Gegenstände erscheinen nicht."
L["OPTIONS_ADD_SELECT"] = "Verfügbare Gegenstände"
L["OPTIONS_ADD_BUTTON"] = "Zur Konfiguration hinzufügen"
L["OPTIONS_ADD_EMPTY"] = "Keine handelbaren Gegenstände in deinen Taschen gefunden."

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["TAB_ANNOUNCEMENTS"] = "Ankündigungen"
L["OPTIONS_ANNOUNCEMENTS_DESC"] =
	"Water Dispenser kann ein Makro erstellen, das ansagt, was du noch zu verschenken hast. Das Makro wählt automatisch den richtigen Kanal (Sagen ohne Gruppe, Gruppe in einer Gruppe, Schlachtzug in einem Schlachtzug) und nutzt die aktuellen Zahlen direkt aus deinen Taschen."
L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Ankündigungs-Makro aktivieren"
-- "- Dispenser" is the macro's literal name and is never translated.
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] =
	'Hält ein charakterspezifisches Makro namens "- Dispenser" mit deiner aktuellen Verschenkliste auf dem neuesten Stand und löscht das Makro, wenn du dies deaktivierst.'
-- "Enable Reserves" must match OPTIONS_ITEM_RESERVE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] =
	"Nichts anzukündigen. Konfiguriere Gegenstände, fülle deine Taschen auf oder senke eine Reserve unter Reserven aktivieren."

-- Macro message template (%s is the item list) and the connector before the last list entry.
L["ANNOUNCEMENTS_BODY"] = "Ich habe %s. Handel öffnen!"
L["ANNOUNCEMENTS_AND"] = "und"

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["OPTIONS_SUPPORT"] = "Feedback & Unterstützung"
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"
L["SUPPORT_WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Built-in Collections
--------------------------------------------------------------------------------

L["ITEM_MAGE_WATER"] = "Herbeigezaubertes Wasser"
L["ITEM_MAGE_FOOD"] = "Herbeigezaubertes Essen"
L["ITEM_WARLOCK_HEALTHSTONE"] = "Gesundheitssteine"
