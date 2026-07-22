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
L["CHAT_LOADED"] =
	"Version %s. Die Einstellungen (inklusive der Option, diese Nachricht zu deaktivieren) sind unter Optionen > AddOns > Water Dispenser zu finden. Gefällt dir Water Dispenser? Empfiehl es weiter! (="
L["CHAT_NO_TRADE"] = "Kein aktives Handelsfenster."
L["CHAT_COMBAT_PAUSED"] = "Ausgabe im Kampf pausiert."
L["CHAT_COMBAT_RESUMED"] = "Kampf beendet. Setze Ausgabe fort."
L["CHAT_MISSING_STACK"] = "Fehlt:"
L["CHAT_NONE_ACTIVE_FOR_CLASS"] =
	"Es sind keine Gegenstände zur Ausgabe eingestellt, während du einen %s spielst. Öffne Optionen > Verteilungsregeln, um Gegenstände für diese Klasse zu aktivieren."
L["CHAT_ITEM_SAVED"] = "Gespeichert:"
L["CHAT_ITEM_REMOVED"] = "Entfernt:"
L["CHAT_MACRO_CREATED"] =
	'Ankündigungs-Makro "- Dispenser" ist bereit. Öffne das Makro-Menü (Spielmenü > Makros, oder /m) und ziehe es auf deine Aktionsleiste.'
L["CHAT_MACRO_DELETED"] = 'Ankündigungs-Makro "- Dispenser" gelöscht.'
L["CHAT_MACRO_FULL"] = "Makro konnte nicht erstellt werden: Alle Charakter-Makroplätze sind belegt."

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BUTTON_CLEAR"] = "Handelsfenster leeren"
L["BUTTON_FILL"] = "Handelsfenster füllen"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["MINIMAP_DISPENSE"] = "Ausgeben"
L["UI_ENABLED"] = "Aktiviert"
L["UI_DISABLED"] = "Deaktiviert"
L["UI_LEFT_CLICK"] = "Linksklick"
L["UI_TOGGLE"] = "Umschalten"
L["MINIMAP_OPTIONS"] = "Water Dispenser-Optionen"
L["MINIMAP_OPTIONS_KEYBIND"] = "Umschalt + Mittelklick"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_DESC"] =
	"Füllt das Handelsfenster automatisch mit Stapeln von Wasser, Essen, Gesundheitssteinen oder jedem konfigurierten Verbrauchsgegenstand, basierend auf der Klasse, dem Level und der Gruppenzugehörigkeit des Handelspartners."

L["OPTIONS_WELCOME_MESSAGE"] = "Willkommensnachricht aktivieren"
L["OPTIONS_WELCOME_MESSAGE_DESC"] = "Gibt eine kurze Begrüßung im Chat aus, wenn Water Dispenser geladen wird."
L["OPTIONS_MINIMAP"] = "Minikarten-Schaltfläche aktivieren"
L["OPTIONS_MINIMAP_DESC"] = "Zeigt die Water Dispenser-Minikarten-Schaltfläche an."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "Warnungen für fehlende Stapel aktivieren"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] =
	"Gibt eine Chatnachricht aus, wenn von einem konfigurierten Gegenstand nicht genug Stapel in den Taschen vorhanden sind, um den Handel zu füllen."

L["OPTIONS_COMMANDS"] = "/Befehle"
L["OPTIONS_COMMANDS_WD"] = "Öffnet die Water Dispenser-Optionen."

L["OPTIONS_DISPENSE_HEADER"] = "Ausgeben"
L["OPTIONS_DISPENSE_DESC"] =
	"Füllt das Handelsfenster automatisch, sobald ein Handel geöffnet wird. Schalte jede Option unten einzeln um."
L["OPTIONS_DISPENSE_MASTER"] = "Ausgabe aktivieren"
L["OPTIONS_DISPENSE_MASTER_DESC"] = "Füllt das Handelsfenster automatisch basierend auf deinen Einstellungen."
L["OPTIONS_DISPENSE_SOLO"] = "Für Fremde auffüllen"
L["OPTIONS_DISPENSE_SOLO_DESC"] =
	"Füllt das Handelsfenster automatisch, wenn mit jemandem gehandelt wird, der nicht in deiner Gruppe oder deinem Schlachtzug ist."
L["OPTIONS_DISPENSE_GROUP"] = "Für Gruppenmitglieder auffüllen"
L["OPTIONS_DISPENSE_GROUP_DESC"] =
	"Füllt das Handelsfenster automatisch, wenn mit einem Gruppenmitglied gehandelt wird."
L["OPTIONS_DISPENSE_RAID"] = "Für Schlachtzugsmitglieder auffüllen"
L["OPTIONS_DISPENSE_RAID_DESC"] =
	"Füllt das Handelsfenster automatisch, wenn mit einem Schlachtzugsmitglied gehandelt wird."

L["OPTIONS_COMBAT_HEADER"] = "Kampf"
L["OPTIONS_COMBAT_DESC"] =
	"Die Ausgabe wird im Kampf immer pausiert, um Interface-Fehler zu vermeiden. Eine Chatnachricht erinnert dich daran. Der Handel wird nach dem Kampf automatisch fortgesetzt, sofern das Fenster noch offen ist."

--------------------------------------------------------------------------------
-- Options — Distribution Rules
--------------------------------------------------------------------------------

L["OPTIONS_ITEMS"] = "Verteilungsregeln"
L["OPTIONS_ITEMS_DESC"] =
	"Konfiguriere, wie viele Stapel jedes Gegenstands ausgegeben werden sollen. Hinweis: Classic Era und TBC Anniversary unterstützen kein automatisches Stapelteilen. Tut mir leid!"
L["OPTIONS_ITEMS_EMPTY"] =
	'Keine Gegenstände konfiguriert. Öffne den Tab "Gegenstand hinzufügen", um Verbrauchsgegenstände aus deinen Taschen hinzuzufügen.'

L["OPTIONS_ITEM_SETTINGS"] = "Gegenstandseinstellungen"
L["OPTIONS_ITEM_USE_NOT_FULL"] = "Mit unvollständigen Stapeln auffüllen"
L["OPTIONS_ITEM_USE_NOT_FULL_DESC"] =
	"Wenn kein voller Stapel verfügbar ist, fülle den Handel mit einem kleineren Stapel aus deinen Taschen auf."
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Stufenanforderungen berücksichtigen"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] =
	"Überspringe diesen Gegenstand, wenn der Handelspartner unter der benötigten Stufe ist."
L["OPTIONS_ITEM_KEEP_AT_LEAST"] = "Mindestens behalten"
L["OPTIONS_ITEM_KEEP_AT_LEAST_DESC"] =
	"Behalte immer mindestens diese Menge in deinen Taschen. Die Ausgabe und das Ankündigungs-Makro behandeln alles darüber hinaus als verschenkbar."
L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "Verbleibende Menge im Makro anzeigen"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] =
	"Wenn das Ankündigungs-Makro diesen Gegenstand auflistet, zeige an, wie viele du noch hast. Deaktiviere dies, wenn du nur den Gegenstand nennen willst (typisch für Gesundheitssteine)."
L["OPTIONS_ITEM_PLAYER_CLASSES"] = "Nur ausgeben, wenn diese Klassen gespielt werden"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] =
	"Diesen Gegenstand nur auffüllen und ankündigen, wenn die Klasse deines Charakters unten ausgewählt ist."
L["OPTIONS_ITEM_REMOVE"] = "Gegenstand entfernen"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "Diesen Gegenstand aus der Handelskonfiguration entfernen?"

L["OPTIONS_SCOPE_SOLO"] = "Fremde"
L["OPTIONS_SCOPE_GROUP"] = "Gruppenmitglieder"
L["OPTIONS_SCOPE_RAID"] = "Schlachtzugsmitglieder"

L["OPTIONS_ADD_ITEM"] = "Gegenstand hinzufügen"
L["OPTIONS_ADD_DESC"] =
	"Wähle einen handelbaren Verbrauchsgegenstand aus deinen Taschen, um ihn zur Konfiguration hinzuzufügen. Bereits konfigurierte oder seelengebundene Gegenstände erscheinen hier nicht."
L["OPTIONS_ADD_SELECT"] = "Verfügbare Gegenstände"
L["OPTIONS_ADD_BUTTON"] = "Zur Konfiguration hinzufügen"
L["OPTIONS_ADD_EMPTY"] = "Keine passenden Verbrauchsgegenstände in deinen Taschen gefunden."

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["OPTIONS_ANNOUNCEMENTS"] = "Ankündigungen"
L["OPTIONS_ANNOUNCEMENTS_DESC"] =
	"Water Dispenser kann ein Makro erstellen, das ansagt, was du noch übrig hast. Das Makro wählt automatisch den richtigen Kanal (Sagen ohne Gruppe, Gruppe in einer Gruppe, Schlachtzug in einem Schlachtzug) und nutzt aktuelle Zahlen aus deinen Taschen."
L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Ankündigungs-Makro aktivieren"
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] =
	'Hält ein charakterspezifisches Makro namens "- Dispenser" mit deiner Liste aktuell. Das Deaktivieren löscht das Makro.'
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_HEADER"] = "Live-Vorschau"
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DESC"] = "Das wird das Makro sagen, wenn du es jetzt klickst."
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] =
	'Nichts anzukündigen. Konfiguriere Gegenstände, fülle deine Taschen auf oder senke den "Mindestens behalten" Wert.'

-- Macro message template (%s is the item list) and the connector before the last list entry.
L["ANNOUNCEMENTS_BODY"] = "Ich habe %s. Handel öffnen!"
L["ANNOUNCEMENTS_AND"] = "und"

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["OPTIONS_SUPPORT"] = "Feedback & Unterstützung"
L["SUPPORT_DESC"] = "Melde Fehler, wünsche dir neue Funktionen oder sag Hallo im Discord."
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
