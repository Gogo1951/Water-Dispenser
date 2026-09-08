local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "itIT")
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

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

--[[
	All player-facing chat prints live here, regardless of which feature emits them.
	In CHAT_LOADED, %s is the add-on version and the menu path is the game client's
	own labels.
]]
L["CHAT_LOADED"] =
	"Versione %s. Le impostazioni (inclusa l'opzione per disattivare questo messaggio) si trovano in Opzioni > AddOns > Water Dispenser. Ti piace questo add-on? Dillo a un amico! (="
L["CHAT_NO_TRADE"] = "Nessuna finestra di scambio attiva."
L["CHAT_COMBAT_BLOCKED"] = "WoW blocca gli scambi automatici durante il combattimento."
L["CHAT_OPTIONS_IN_COMBAT"] =
	"Per precauzione, l'interfaccia delle opzioni non può essere aperta durante il combattimento."
-- The item and its count are appended after the colon by the code.
L["CHAT_MISSING_STACK"] = "Mancante:"
--[[
	%s is the item's name, %d the Maximum per Session it has hit.
	"Maximum per Session" is the label of OPTIONS_ITEM_SESSION_CAP, minus its "Enable".
]]
L["CHAT_SESSION_CAP_REACHED"] =
	"%s non aggiunto: ne ha già ricevuti %d in questa sessione. Cambia Massimo per Sessione, o ricarica per azzerare."
-- %s is the item's name, %d the amount that could not be split off.
L["CHAT_SPLIT_REFUSED"] =
	"%s non aggiunto: questo client non ha voluto separare %d da una pila, e consegnare una pila intera darebbe molto più di quanto hai chiesto. Imposta la quantità di questo oggetto su una pila intera per scambiarlo."
-- %s is the player's class name. "Dispensed Items" must match TAB_DISPENSED_ITEMS.
L["CHAT_NONE_ACTIVE_FOR_CLASS"] =
	"Nessun oggetto è impostato per essere distribuito mentre giochi come %s. Apri Opzioni > AddOns > Water Dispenser > Oggetti Distribuiti per abilitare gli oggetti per questa classe."
-- "- Dispenser" is the macro's literal name and is never translated.
L["CHAT_MACRO_DELETED"] = 'Macro di annuncio "- Dispenser" eliminata.'
L["CHAT_MACRO_FULL"] = "Impossibile creare la macro: tutti gli slot macro del personaggio sono in uso."

--------------------------------------------------------------------------------
-- Player Tooltips
--------------------------------------------------------------------------------

L["TOOLTIP_OPEN_TRADE"] = "Apri lo scambio!"
-- %d/%d is the warlock's Improved Healthstone rank out of its maximum.
L["TOOLTIP_HEALTHSTONE"] = "Pietra della salute (Grado %d/%d)"

--------------------------------------------------------------------------------
-- Bag Item Tooltips
--------------------------------------------------------------------------------

-- Shown on a carried bag item the player has set up to give away.
L["TOOLTIP_WILL_DISPENSE"] = "Questo oggetto verrà distribuito."
-- The same line for an item that stacks, which is also tidied back together once a trade ends.
L["TOOLTIP_WILL_DISPENSE_STACKED"] =
	"Questo oggetto verrà distribuito. Le sue pile parziali vengono riunite alla chiusura di uno scambio."

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BUTTON_CLEAR"] = "Pulisci finestra di scambio"
L["BUTTON_FILL"] = "Riempi finestra di scambio"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

-- The tooltip's feature row reuses TAB_DISPENSE for its name; these are its state and click words.
L["UI_ENABLED"] = "Abilitato"
L["UI_DISABLED"] = "Disabilitato"
L["UI_LEFT_CLICK"] = "Tasto sinistro"
L["UI_TOGGLE"] = "Attiva/Disattiva"
L["MINIMAP_OPTIONS"] = "Opzioni di Water Dispenser"
L["MINIMAP_OPTIONS_KEYBIND"] = "Maiusc + Clic centrale"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Distribuzione di consumabili senza fatica. Riempie automaticamente la finestra di scambio con acqua, cibo e pietre della salute. Aggiungi qualsiasi oggetto tu voglia, come Sabbia di clessidra o pozioni di resistenza, da distribuire alla tua incursione."

L["OPTIONS_WELCOME_MESSAGE"] = "Abilita Messaggio di Benvenuto"
L["OPTIONS_WELCOME_MESSAGE_DESC"] =
	"Mostra un saluto di una riga nella tua finestra di chat quando Water Dispenser viene caricato."
L["OPTIONS_MINIMAP"] = "Abilita Pulsante Minimappa"
L["OPTIONS_MINIMAP_DESC"] = "Mostra il pulsante della minimappa di Water Dispenser."

L["OPTIONS_COMMANDS_HEADER"] = "/Comandi"
L["OPTIONS_COMMAND"] = "/wd"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Apre l'interfaccia delle opzioni di questo add-on."

--------------------------------------------------------------------------------
-- Options — Dispense
--------------------------------------------------------------------------------

-- Names the panel, its section header, and the mini-map tooltip's feature row.
L["TAB_DISPENSE"] = "Distribuisci"
L["OPTIONS_DISPENSE_DESC"] = "Riempie automaticamente la finestra di scambio quando si apre uno scambio."
L["OPTIONS_DISPENSE_MASTER"] = "Abilita Distribuzione"
L["OPTIONS_DISPENSE_MASTER_DESC"] = "Riempie automaticamente la finestra di scambio in base alle tue impostazioni."
L["OPTIONS_DISPENSE_SOLO"] = "Abilita per gli Sconosciuti"
L["OPTIONS_DISPENSE_SOLO_DESC"] =
	"Riempie automaticamente la finestra di scambio quando scambi con qualcuno che non è nel tuo gruppo o nella tua incursione."
L["OPTIONS_DISPENSE_GROUP"] = "Abilita per il Gruppo"
L["OPTIONS_DISPENSE_GROUP_DESC"] =
	"Riempie automaticamente la finestra di scambio quando scambi con un membro del gruppo."
L["OPTIONS_DISPENSE_RAID"] = "Abilita per l'Incursione"
L["OPTIONS_DISPENSE_RAID_DESC"] =
	"Riempie automaticamente la finestra di scambio quando scambi con un membro dell'incursione."
-- The label says what it does; the tooltip only covers why it is needed and when it stands down.
L["OPTIONS_RESTACK"] = "Unisci le Pile Parziali Dopo uno Scambio"
L["OPTIONS_RESTACK_DESC"] =
	"Acqua e cibo evocati finiscono in un nuovo slot della borsa a ogni evocazione e il gioco non li riunisce mai, così Water Dispenser li unisce una volta, subito dopo la chiusura di una finestra di scambio. Non riorganizza mai le tue borse in nessun altro momento, né in combattimento né mentre tieni qualcosa sul cursore."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "Abilita Avvisi Quando Rimani a Corto"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] =
	"Mostra una nota nella tua finestra di chat quando non hai abbastanza di un oggetto configurato nelle borse per dare la quantità impostata."

L["OPTIONS_COMBAT_HEADER"] = "Combattimento"
L["OPTIONS_COMBAT_DESC"] = "WoW impedisce agli add-on di spostare oggetti in uno scambio durante il combattimento."
L["OPTIONS_COMBAT_NOTIFY"] = "Abilita Notifiche Quando la Distribuzione è Bloccata"
L["OPTIONS_COMBAT_NOTIFY_DESC"] =
	"Mostra una nota nella tua finestra di chat quando il combattimento impedisce il riempimento di uno scambio, e con questa disattivata Water Dispenser tace sul perché lo scambio è rimasto vuoto."

--------------------------------------------------------------------------------
-- Options — Inventory Tooltips
--------------------------------------------------------------------------------

L["TAB_INVENTORY_TOOLTIPS"] = "Suggerimenti Inventario"
L["OPTIONS_TOOLTIPS_DESC"] =
	"Mostra nei suggerimenti giocatore dei membri del gruppo che usano Water Dispenser ciò che hanno impostato per la distribuzione, e segnala quegli oggetti nelle tue borse."
L["OPTIONS_SHOW_INVENTORY"] = "Mostra Inventario nei Suggerimenti Giocatore"
L["OPTIONS_SHOW_INVENTORY_DESC"] =
	"Aggiunge un blocco Water Dispenser ai suggerimenti dei giocatori elencando ciò che hanno impostato per la distribuzione e quanti ne possono dare, mentre il tuo viene sempre mostrato, in gruppo o meno."
L["OPTIONS_BAG_TOOLTIPS"] = "Mostra i Suggerimenti nelle Borse per gli Oggetti Distribuiti"
L["OPTIONS_BAG_TOOLTIPS_DESC"] =
	"Aggiunge una riga Water Dispenser al suggerimento di un oggetto nelle borse quando quell'oggetto è impostato per essere distribuito, così vedi a colpo d'occhio cosa consegnerà l'add-on."
L["OPTIONS_SHARE_INVENTORY"] = "Condividi il Mio Inventario"
L["OPTIONS_SHARE_INVENTORY_DESC"] =
	"Comunica al tuo gruppo e alla tua incursione cosa hai da dare, così il tuo inventario appare quando ti passano sopra con il mouse, senza pubblicare nulla in chat né informare nessuno fuori dal tuo gruppo, e disattivandola puoi comunque leggere quello degli altri."

--------------------------------------------------------------------------------
-- Options — Dispensed Items
--------------------------------------------------------------------------------

L["TAB_DISPENSED_ITEMS"] = "Oggetti Distribuiti"
L["OPTIONS_ITEMS_DESC"] =
	"Configura quanti oggetti distribuire di ciascun tipo. Le quantità si contano in singoli oggetti, quindi 20 acque sono 20 acque, e 1 pozione è 1 pozione. Una pila viene divisa fino alla quantità esatta se serve."
-- "Add an Item" must match OPTIONS_ADD_ITEM.
L["OPTIONS_ITEMS_EMPTY"] =
	'Nessun oggetto configurato. Seleziona "Aggiungi Oggetto" nell\'elenco per aggiungere qualsiasi oggetto scambiabile dalle tue borse.'

L["OPTIONS_ITEM_AMOUNTS"] = "Quantità"
L["OPTIONS_ITEM_AMOUNTS_DESC"] =
	"Scegli quanti ne riceve ogni classe quando ci scambi, a seconda che sia sconosciuta, nel tuo gruppo o nella tua incursione. Contati in singoli oggetti, non in pile. Zero significa che non riceverà mai questo oggetto."
L["OPTIONS_ITEM_EVERYONE"] = "Tutti"
L["OPTIONS_ITEM_EVERYONE_DESC"] =
	"Imposta questa quantità per tutte le classi in una volta quando premi Invio, e resta vuoto quando le classi qui sotto non concordano."
-- The accept button inside every number box in this panel.
L["OPTIONS_ITEM_APPLY"] = "Applica"
-- %d is the highest amount this item accepts, which is 1 for anything unique.
L["OPTIONS_ITEM_COUNT_TOO_HIGH"] = "È più di quanto questo oggetto possa distribuire. Il massimo è %d."
L["OPTIONS_ITEM_COUNT_INVALID"] = "Inserisci un numero di oggetti, o 0 per non distribuire mai questo."
L["OPTIONS_ITEM_SETTINGS"] = "Impostazioni Oggetto"
L["OPTIONS_ITEM_DISTRIBUTE"] = "Assegna"
-- "In Instance" must match the dropdown entry below.
L["OPTIONS_ITEM_DISTRIBUTE_DESC"] =
	"Definisce dove questo oggetto viene distribuito: ovunque altrove non viene mai scambiato, annunciato o mostrato nel tuo suggerimento. In Istanza copre spedizioni, incursioni, campi di battaglia e arene. Per trattenere un oggetto da un gruppo o da un'incursione, imposta invece a 0 le quantità di quella colonna."
-- Dropdown entries. The stored values are "Always" and "Instance"; these are only their labels.
L["OPTIONS_ITEM_DISTRIBUTE_ALWAYS"] = "Sempre"
L["OPTIONS_ITEM_DISTRIBUTE_INSTANCE"] = "In Istanza"
L["OPTIONS_ITEM_GUILDIES_ONLY"] = "Solo Gilda"
L["OPTIONS_ITEM_GUILDIES_ONLY_DESC"] =
	"Salta questo oggetto quando la persona con cui stai scambiando non è nella tua gilda."
-- Panel line under the toggle, not a tooltip: it names the guild, which no fixed string can. %s is the player's guild.
L["OPTIONS_ITEM_GUILDIES_ONLY_HELP"] = "Dai solo ai membri di <%s>."
L["OPTIONS_ITEM_GUILDIES_ONLY_NO_GUILD"] = "Non sei in nessuna gilda, quindi questo non dà l'oggetto a nessuno."
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Considera il Livello Richiesto dall'Oggetto"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] =
	"Salta questo oggetto quando il compagno di scambio è sotto il livello richiesto dall'oggetto."
L["OPTIONS_ITEM_RESERVE"] = "Abilita Riserve"
L["OPTIONS_ITEM_RESERVE_DESC"] =
	"Tiene sempre almeno questa quantità nelle tue borse, mentre la distribuzione, il tuo suggerimento giocatore e la macro di annuncio considerano tutto ciò che supera quel numero come disponibile da regalare."
L["OPTIONS_ITEM_SESSION_CAP"] = "Abilita Massimo per Sessione"
L["OPTIONS_ITEM_SESSION_CAP_DESC"] =
	"Smette di dare questo oggetto a qualcuno una volta che ne ha ricevuti così tanti da te, contati su tutti gli scambi finché non esci o ricarichi, e cambiare una qualsiasi quantità di questo oggetto azzera il conteggio di tutti."
-- The label carries the meaning on its own; the tooltip only says why you'd switch it off.
L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "Includi Quantità nel Suggerimento Giocatore e nella Macro di Annuncio"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] =
	"Disattivata nomina l'oggetto senza numero accanto, cosa che si legge meglio per qualcosa di cui porti sempre un solo esemplare, come una pietra della salute."
L["OPTIONS_ITEM_PLAYER_CLASSES"] = "Distribuisci Solo Giocando Queste Classi"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] =
	"Riempie gli scambi, inserisce questo oggetto nella macro di annuncio e lo mostra nel tuo suggerimento giocatore solo se la classe del tuo personaggio è selezionata qui sotto."
L["OPTIONS_ITEM_REMOVE"] = "Rimuovi Oggetto"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "Rimuovere questo oggetto dai tuoi oggetti distribuiti?"

L["OPTIONS_SCOPE_SOLO"] = "Sconosciuti"
L["OPTIONS_SCOPE_GROUP"] = "Gruppo"
L["OPTIONS_SCOPE_RAID"] = "Incursione"

L["OPTIONS_ADD_ITEM"] = "Aggiungi Oggetto"
L["OPTIONS_ADD_DESC"] =
	"Seleziona un qualsiasi oggetto scambiabile dalle tue borse per aggiungerlo ai tuoi oggetti distribuiti. Gli oggetti già configurati o vincolati non appariranno."
L["OPTIONS_ADD_SELECT"] = "Oggetti Disponibili"
L["OPTIONS_ADD_BUTTON"] = "Aggiungi agli Oggetti Distribuiti"
L["OPTIONS_ADD_EMPTY"] = "Nessun oggetto scambiabile trovato nelle tue borse."

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["TAB_ANNOUNCEMENTS"] = "Annunci"
L["OPTIONS_ANNOUNCEMENTS_DESC"] =
	"Water Dispenser può creare una macro che annuncia ciò che ti resta da distribuire. La macro sceglie il canale automaticamente (Dire senza gruppo, Gruppo in un gruppo, Incursione in un'incursione, Istanza in un gruppo di spedizione o campo di battaglia) e usa le quantità più recenti dalle tue borse."
L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Abilita Macro di Annuncio"
-- "- Dispenser" is the macro's literal name and is never translated.
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] =
	'Mantiene aggiornata una macro specifica del personaggio chiamata "- Dispenser" con i tuoi oggetti distribuiti attuali, ed elimina la macro quando la disattivi.'
-- "Enable Reserves" must match OPTIONS_ITEM_RESERVE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] =
	"Niente da annunciare. Configura oggetti, riempi le borse o abbassa una riserva in Abilita Riserve."
-- "Enable Dispense" must match OPTIONS_DISPENSE_MASTER, "Dispense" must match TAB_DISPENSE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DISPENSE_OFF"] =
	"Niente da annunciare finché Abilita Distribuzione è disattivata, nella scheda Distribuisci."

-- Macro message template (%s is the item list) and the connector before the last list entry.
L["ANNOUNCEMENTS_BODY"] = "Ho %s. Apri lo scambio!"
L["ANNOUNCEMENTS_AND"] = "e"

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["OPTIONS_SUPPORT"] = "Feedback e Supporto"
-- Precedes the version number on the General panel's last line.
L["VERSION"] = "Versione"
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"
L["SUPPORT_WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Built-in Collections
--------------------------------------------------------------------------------

L["ITEM_MAGE_WATER"] = "Acqua evocata"
L["ITEM_MAGE_FOOD"] = "Cibo evocato"
L["ITEM_WARLOCK_HEALTHSTONE"] = "Pietra della salute"
