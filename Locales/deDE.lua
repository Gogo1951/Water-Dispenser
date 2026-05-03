local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "deDE")
if not L then return end

L["CHAT_LOADED"] = "Aktiviert. Nutze %s, um die Einstellungen zu öffnen, inklusive der Option, diese Nachricht zu deaktivieren. Gefällt dir Water Dispenser? Empfiehl es weiter! (="
L["CHAT_NO_TRADE"] = "Kein aktives Handelsfenster."
L["CHAT_COMBAT_PAUSED"] = "Automatisches Auffüllen im Kampf pausiert."
L["CHAT_COMBAT_RESUMED"] = "Kampf beendet. Setze Handelsauffüllung fort."
L["CHAT_MISSING_STACK"] = "Fehlende Stapel:"
L["CHAT_ITEM_SAVED"] = "Gespeichert:"
L["CHAT_ITEM_REMOVED"] = "Entfernt:"

L["BTN_CLEAR"] = "Handel leeren"
L["BTN_FILL"] = "Handel auffüllen"
L["BTN_CONFIG"] = "Optionen"
L["BTN_ACCEPT"] = "Handel akzeptieren"

L["OPTIONS_TITLE"] = "Water Dispenser"
L["OPTIONS_DESC"] = "Füllt das Handelsfenster automatisch mit Stapeln von Wasser, Essen, Gesundheitssteinen oder jedem konfigurierten Verbrauchsgegenstand, basierend auf der Klasse, dem Level und der Gruppenzugehörigkeit des Handelspartners."

L["OPTIONS_GENERAL_HEADER"] = "Allgemeine Einstellungen"
L["OPTIONS_WELCOME_MESSAGE"] = "Willkommensnachricht aktivieren"
L["OPTIONS_WELCOME_MESSAGE_DESC"] = "Gibt eine kurze Begrüßung im Chat aus, wenn Water Dispenser geladen wird."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "Warnungen für fehlende Stapel anzeigen"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] = "Gibt eine Chatnachricht aus, wenn von einem konfigurierten Gegenstand nicht genug Stapel in den Taschen vorhanden sind, um den Handel zu füllen."
L["OPTIONS_ITEMS"] = "Verteilungsregeln"
L["OPTIONS_ADD_ITEM"] = "Gegenstand hinzufügen"
L["OPTIONS_SUPPORT"] = "Feedback & Support"

L["OPTIONS_AUTOFILL_HEADER"] = "Automatisches Auffüllen"
L["OPTIONS_AUTOFILL_DESC"] = "Füllt das Handelsfenster automatisch, wenn ein Handel gestartet wird. Jeder Bereich wird unabhängig voneinander umgeschaltet."
L["OPTIONS_AUTOFILL_SOLO"] = "Für Fremde auffüllen"
L["OPTIONS_AUTOFILL_SOLO_DESC"] = "Füllt das Handelsfenster automatisch, wenn mit jemandem gehandelt wird, der nicht in deiner Gruppe oder deinem Schlachtzug ist."
L["OPTIONS_AUTOFILL_GROUP"] = "Für Gruppenmitglieder auffüllen"
L["OPTIONS_AUTOFILL_GROUP_DESC"] = "Füllt das Handelsfenster automatisch, wenn mit einem Gruppenmitglied gehandelt wird."
L["OPTIONS_AUTOFILL_RAID"] = "Für Schlachtzugsmitglieder auffüllen"
L["OPTIONS_AUTOFILL_RAID_DESC"] = "Füllt das Handelsfenster automatisch, wenn mit einem Schlachtzugsmitglied gehandelt wird."

L["OPTIONS_COMBAT_HEADER"] = "Kampf"
L["OPTIONS_COMBAT_DESC"] = "Automatisches Auffüllen wird im Kampf immer pausiert, um Interface-Fehler zu vermeiden. Eine Chatnachricht erinnert daran. Der Handel wird nach dem Kampf automatisch fortgesetzt, sofern das Fenster noch offen ist."

L["OPTIONS_LOCKED_HEADER"] = "Schurken-Schließkassetten"
L["OPTIONS_LOCKED_DESC"] = "Beim Handeln mit einem Schurken wird der erste verschlossene Gegenstand aus deinen Taschen in den unteren Platz gelegt, damit er geknackt werden kann."
L["OPTIONS_LOCKED"] = "Schurken verschlossene Gegenstände anbieten"

L["OPTIONS_RESET_HEADER"] = "Zurücksetzen"
L["OPTIONS_RESET_DESC"] = "Setzt jede Water Dispenser-Einstellung auf diesem Charakter auf die Standardwerte zurück, einschließlich deiner benutzerdefinierten Gegenstandsliste."
L["OPTIONS_RESET_BUTTON"] = "Alle Optionen zurücksetzen"
L["OPTIONS_RESET_CONFIRM"] = "Bist du sicher, dass du jede Water Dispenser-Einstellung für diesen Charakter auf die Standardwerte zurücksetzen möchtest?"

L["OPTIONS_COMMANDS_HEADER"] = "/Befehle"
L["OPTIONS_COMMANDS_DESC"] = "Chatbefehle für Water Dispenser. Das Optionen-Panel deckt alles ab; diese Befehle sind für Nutzer, die die Tastatur bevorzugen."
L["OPTIONS_COMMAND_WD"] = "/wd"
L["OPTIONS_COMMAND_WD_DESC"] = "Öffnet die Water Dispenser-Optionen."
L["OPTIONS_COMMAND_WD_FILL"] = "/wd fill"
L["OPTIONS_COMMAND_WD_FILL_DESC"] = "Füllt das Handelsfenster sofort auf, auch wenn das automatische Auffüllen deaktiviert ist."
L["OPTIONS_COMMAND_WD_CLEAR"] = "/wd clear"
L["OPTIONS_COMMAND_WD_CLEAR_DESC"] = "Leert jeden Platz im Handelsfenster."
L["OPTIONS_COMMAND_WD_AUTO"] = "/wd auto solo||group||raid on||off"
L["OPTIONS_COMMAND_WD_AUTO_DESC"] = "Schaltet das automatische Auffüllen für den angegebenen Bereich um. Lasse on/off weg, um den aktuellen Status zu wechseln."
L["OPTIONS_COMMAND_WDA"] = "/wda"
L["OPTIONS_COMMAND_WDA_DESC"] = "Sendet die Ankündigungsnachricht an den Chatkanal, der deinem aktuellen Gruppenstatus entspricht."

L["CHAT_RESET"] = "Alle Optionen wurden auf Standardwerte zurückgesetzt."

L["OPTIONS_ITEMS_DESC"] = "Konfiguriere, wie viele Stapel jedes Gegenstands ausgegeben werden sollen. Hinweis: Classic Era und TBC Anniversary unterstützen kein automatisches Stapelteilen."
L["OPTIONS_ITEMS_EMPTY"] = "Keine Gegenstände konfiguriert. Öffne den Tab \"Gegenstand hinzufügen\", um Verbrauchsgegenstände aus deinen Taschen hinzuzufügen."

L["OPTIONS_ITEM_SETTINGS"] = "Gegenstandseinstellungen"
L["OPTIONS_ITEM_USE_NOT_FULL"] = "Mit unvollständigen Stapeln auffüllen"
L["OPTIONS_ITEM_USE_NOT_FULL_DESC"] = "Wenn kein voller Stapel verfügbar ist, fülle den Handel mit einem kleineren Stapel aus deinen Taschen auf."

L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Stufenanforderungen berücksichtigen"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] = "Überspringe diesen Gegenstand, wenn der Handelspartner unter der benötigten Stufe ist."

L["OPTIONS_ITEM_KEEP_AT_LEAST"] = "Mindestens behalten"
L["OPTIONS_ITEM_KEEP_AT_LEAST_DESC"] = "Behalte immer mindestens diese Menge in deinen Taschen. Alles darüber hinaus gilt als zum Verschenken verfügbar."

L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "Verbleibende Menge im Makro anzeigen"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] = "Wenn das Ankündigungs-Makro diesen Gegenstand auflistet, zeige an, wie viele du noch hast. Deaktiviere dies, wenn du nur den Gegenstand nennen willst (typisch für Gesundheitssteine)."

L["OPTIONS_ITEM_PLAYER_CLASSES"] = "Nur verteilen, wenn diese Klasse(n) gespielt wird/werden"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] = "Diesen Gegenstand nur auffüllen und ankündigen, wenn die Klasse deines Charakters unten ausgewählt ist."

L["OPTIONS_ITEM_REMOVE"] = "Gegenstand entfernen"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "Diesen Gegenstand aus der Handelskonfiguration entfernen?"

L["OPTIONS_SCOPE_SOLO"] = "Fremde"
L["OPTIONS_SCOPE_GROUP"] = "Gruppenmitglieder"
L["OPTIONS_SCOPE_RAID"] = "Schlachtzugsmitglieder"

L["OPTIONS_ADD_DESC"] = "Wähle einen handelbaren Verbrauchsgegenstand aus deinen Taschen, um ihn zur Konfiguration hinzuzufügen. Bereits konfigurierte oder seelengebundene Gegenstände erscheinen hier nicht."
L["OPTIONS_ADD_SELECT"] = "Verfügbare Gegenstände"
L["OPTIONS_ADD_BUTTON"] = "Zur Konfiguration hinzufügen"
L["OPTIONS_ADD_EMPTY"] = "Keine passenden Verbrauchsgegenstände in deinen Taschen gefunden."

L["SUPPORT_DESC"] = "Melde Fehler, wünsche dir neue Funktionen oder sag Hallo im Discord."
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"

L["OPTIONS_ANNOUNCEMENTS"] = "Ankündigungen"
L["OPTIONS_ANNOUNCEMENTS_DESC"] = "Water Dispenser kann ein Makro erstellen, das ansagt, was du noch übrig hast. Das Makro wählt automatisch den richtigen Kanal (/sagen, /gruppe, /schlachtzug) und nutzt aktuelle Zahlen aus deinen Taschen."

L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Ankündigungs-Makro aktivieren"
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] = "Hält ein charakterspezifisches Makro namens \"- Dispenser\" mit deiner Liste aktuell. Das Deaktivieren löscht das Makro."

L["OPTIONS_ANNOUNCEMENTS_PREVIEW_HEADER"] = "Live-Vorschau"
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DESC"] = "Das wird das Makro sagen, wenn du es jetzt klickst."
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] = "Nichts anzukündigen. Konfiguriere Gegenstände, fülle deine Taschen auf oder senke den \"Mindestens behalten\" Wert."

L["ANNOUNCEMENTS_INTRO"] = "Ich habe"
L["ANNOUNCEMENTS_OUTRO"] = ". Handel öffnen!"
L["ANNOUNCEMENTS_AND"] = "und"

L["CHAT_MACRO_CREATED"] = "Ankündigungs-Makro \"- Dispenser\" ist bereit. Öffne das Makro-Menü (/m) und ziehe es auf deine Aktionsleiste."
L["CHAT_MACRO_DELETED"] = "Ankündigungs-Makro \"- Dispenser\" gelöscht."
L["CHAT_MACRO_FULL"] = "Makro konnte nicht erstellt werden: Alle Charakter-Makroplätze sind belegt."
L["CHAT_NOTHING_TO_ANNOUNCE"] = "Momentan gibt es nichts anzukündigen."

L["ITEM_MAGE_WATER"] = "Jegliches herbeigezauberte Wasser"
L["ITEM_MAGE_FOOD"] = "Jegliches herbeigezauberte Essen"
L["ITEM_WARLOCK_HEALTHSTONE"] = "Jeglicher Gesundheitsstein"