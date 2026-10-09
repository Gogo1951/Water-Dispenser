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
-- Stands in for an item's name until the client has loaded it. %d is the item ID.
L["ITEM_LOADING"] = "Caricamento ID: %d"

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
	%s is the item's name, then the trade partner's name; %d is the Maximum per
	Player they have reached.
]]
L["CHAT_PLAYER_CAP_REACHED"] =
	"%s non aggiunto: %s ha già ricevuto %d da te. I conteggi ripartono quando esci dal gioco o ricarichi."
-- %s is the item's name; the first %d is the amount that could not be split off, the second the item's full stack size.
L["CHAT_SPLIT_NEEDS_FULL_STACK"] =
	"%s non aggiunto: il gioco non ha voluto separare %d da una pila. Imposta la quantità su una pila intera (%d) per consegnarlo."
-- %s is the player's class name. "Dispensed Items" must match TAB_DISPENSED_ITEMS.
L["CHAT_NONE_ACTIVE_FOR_CLASS"] =
	"Nessun oggetto è impostato per essere distribuito mentre giochi come %s. Apri Opzioni > AddOns > Water Dispenser > Oggetti Distribuiti per abilitare gli oggetti per questa classe."
-- "- Dispenser" is the macro's literal name and is never translated.
L["CHAT_MACRO_DELETED"] = 'Macro di annuncio "- Dispenser" eliminata.'
L["CHAT_MACRO_FULL"] = "Impossibile creare la macro di annuncio: tutti gli slot macro del personaggio sono in uso."

--------------------------------------------------------------------------------
-- Player Tooltips
--------------------------------------------------------------------------------

L["TOOLTIP_OPEN_TRADE"] = "Apri lo scambio!"
-- %s is the Improved Healthstone talent's name from the client, then the warlock's rank out of its maximum.
L["TOOLTIP_HEALTHSTONE_TALENT"] = "%s %d/%d"

--------------------------------------------------------------------------------
-- Bag Item Tooltips
--------------------------------------------------------------------------------

-- Shown on a carried bag item the player has set up to give away.
L["TOOLTIP_WILL_DISPENSE"] = "Distribuito negli scambi."

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BUTTON_CLEAR"] = "Pulisci finestra di scambio"
L["BUTTON_FILL"] = "Riempi finestra di scambio"

--[[
	The silver status line under the trade panel's buttons. "Fill Trade Window" must
	match BUTTON_FILL. ADDED's %s is the window's contents, each FORMAT_ITEM_COUNT,
	joined like the announcement's list. In the rest, %s is an item or collection
	name unless noted.
]]
L["TRADE_STATUS_ADDED"] = "Aggiunto: %s."
-- %d is how many short.
L["TRADE_STATUS_SHORT"] = "Mancano %d %s: non abbastanza nelle tue borse."
L["TRADE_STATUS_SHORT_RESERVE"] = "Mancano %d %s: la tua riserva tiene il resto."
L["TRADE_STATUS_DISPENSE_OFF"] =
	"Il riempimento automatico è disattivato. Riempi finestra di scambio aggiunge comunque le tue quantità abituali."
L["TRADE_STATUS_OFF_STRANGERS"] =
	"Il riempimento automatico è disattivato per gli sconosciuti. Riempi finestra di scambio aggiunge comunque le tue quantità abituali."
L["TRADE_STATUS_OFF_PARTY"] =
	"Il riempimento automatico è disattivato per i membri del gruppo. Riempi finestra di scambio aggiunge comunque le tue quantità abituali."
L["TRADE_STATUS_OFF_RAID"] =
	"Il riempimento automatico è disattivato per i membri dell'incursione. Riempi finestra di scambio aggiunge comunque le tue quantità abituali."
L["TRADE_STATUS_MASTER_LOOT"] =
	"Trattenuto mentre sei responsabile del bottino. Riempi finestra di scambio aggiunge comunque le tue quantità abituali."
-- The first %s is the partner's class name.
L["TRADE_STATUS_ZERO"] = "Impostato a 0 per %s: %s."
L["TRADE_STATUS_INSTANCE_ONLY"] = "%s viene distribuito solo nelle istanze."
L["TRADE_STATUS_GUILD_ONLY"] = "%s va solo alla tua gilda."
-- The partner's name, then the rank they can't use yet and its level.
L["TRADE_STATUS_LEVEL"] = "%s non può usare %s fino al livello %d."
-- The partner's name first.
L["TRADE_STATUS_TOO_LOW"] = "%s ha un livello troppo basso per %s."
-- The partner's name first.
L["TRADE_STATUS_CAPPED"] = "%s ha raggiunto il tuo massimo per giocatore di %s."
L["TRADE_STATUS_NONE_HELD"] = "Non hai %s da dare."
L["TRADE_STATUS_CLEARED"] = "Svuotato."
--[[
	A conjure button's tooltip, under the spell's name. MAKES: the item it makes,
	then the trade partner's name and level. LOWEST, when no rank fits the partner:
	the item only.
]]
L["TRADE_CONJURE_MAKES"] = "Crea %s, il migliore che %s (livello %d) può usare."
L["TRADE_CONJURE_MAKES_LOWEST"] = "Crea %s, il grado più basso che conosci."

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

--[[
	The tooltip's feature row reuses TAB_DISPENSE for its name and
	OPTIONS_DISPENSE_MASTER_DESC for its description; these are its state and click words.
]]
L["UI_ENABLED"] = "Abilitato"
L["UI_DISABLED"] = "Disabilitato"
L["UI_LEFT_CLICK"] = "Tasto sinistro"
L["UI_TOGGLE"] = "Attiva/Disattiva"
L["MINIMAP_OPTIONS"] = "Opzioni di Water Dispenser"
L["MINIMAP_OPTIONS_KEYBIND"] = "Maiusc + Clic centrale"
-- Heads the tooltip section listing what the player can give right now.
L["MINIMAP_DISPENSE_REPORT"] = "Resoconto Distribuzione"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Distribuzione di consumabili senza sforzo. Riempie automaticamente le finestre di scambio con acqua, cibo e pietre della salute evocati, del grado e della quantità giusti per ogni giocatore. Aggiungi qualsiasi oggetto, dalla Sabbia di Clessidra alle pozioni di resistenza, e rifornisci un'intera incursione in pochi secondi."

L["OPTIONS_WELCOME_MESSAGE"] = "Abilita Messaggio di Benvenuto"
L["OPTIONS_WELCOME_MESSAGE_DESC"] =
	"Mostra un saluto di una riga nella tua finestra di chat quando Water Dispenser viene caricato."
L["OPTIONS_MINIMAP"] = "Abilita Pulsante Minimappa"
L["OPTIONS_MINIMAP_DESC"] = "Mostra il pulsante della minimappa di Water Dispenser."

L["OPTIONS_FEATURES_HEADER"] = "Funzionalità"

L["OPTIONS_COMMANDS_HEADER"] = "/Comandi"
L["OPTIONS_COMMAND"] = "/wd"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Apre l'interfaccia delle opzioni di questo add-on."

--------------------------------------------------------------------------------
-- Options — Dispense
--------------------------------------------------------------------------------

-- Names the panel and the mini-map tooltip's feature row.
L["TAB_DISPENSE"] = "Distribuisci"
L["OPTIONS_DISPENSE_MASTER"] = "Abilita Distribuzione"
-- Also the panel's intro line and the mini-map tooltip's feature description.
L["OPTIONS_DISPENSE_MASTER_DESC"] =
	"Riempie automaticamente la finestra di scambio quando si apre uno scambio, in base alle tue impostazioni."
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
	"Acqua e cibo evocati finiscono in un nuovo slot della borsa a ogni evocazione e il gioco non li riunisce mai, così Water Dispenser li unisce una volta, subito dopo la chiusura di una finestra di scambio, e mai in nessun altro momento, né in combattimento né mentre tieni qualcosa sul cursore."
L["OPTIONS_HOLD_MASTER_LOOT"] = "Trattieni Mentre Sei Responsabile del Bottino"
-- "Fill Trade Window" must match BUTTON_FILL.
L["OPTIONS_HOLD_MASTER_LOOT_DESC"] =
	"Lascia vuota la finestra di scambio mentre sei responsabile del bottino in un'istanza, dato che quegli scambi servono a distribuire il bottino. Riempi finestra di scambio aggiunge comunque le tue quantità abituali."
L["OPTIONS_CONJURE_BUTTONS"] = "Mostra Pulsanti di Evocazione Accanto agli Scambi"
-- "Fill Trade Window" must match BUTTON_FILL.
L["OPTIONS_CONJURE_BUTTONS_DESC"] =
	"Aggiunge sotto Riempi finestra di scambio dei pulsanti che evocano acqua, cibo o una pietra della salute che il tuo compagno di scambio può usare al suo livello, e ciò che crei finisce direttamente nello scambio aperto."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "Abilita Avvisi Quando Rimani a Corto"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] =
	"Mostra una nota nella tua finestra di chat quando non hai abbastanza di un oggetto configurato nelle borse per dare la quantità impostata."

-- Leads the silver line under a setting that shows the exact chat line it prints.
L["OPTIONS_EXAMPLE"] = "Esempio:"

L["OPTIONS_COMBAT_HEADER"] = "Combattimento"
L["OPTIONS_COMBAT_DESC"] = "WoW impedisce agli add-on di spostare oggetti in uno scambio durante il combattimento."
L["OPTIONS_COMBAT_NOTIFY"] = "Abilita Notifiche Quando la Distribuzione è Bloccata"
L["OPTIONS_COMBAT_NOTIFY_DESC"] =
	"Mostra una nota nella tua finestra di chat quando il combattimento impedisce di riempire uno scambio."

--------------------------------------------------------------------------------
-- Options — Inventory Tooltips
--------------------------------------------------------------------------------

L["TAB_INVENTORY_TOOLTIPS"] = "Suggerimenti Inventario"
L["OPTIONS_TOOLTIPS_DESC"] =
	"Mostra nei suggerimenti giocatore ciò che i membri del gruppo che usano Water Dispenser hanno impostato per la distribuzione, e segnala nelle tue borse gli oggetti che distribuisci tu."
L["OPTIONS_SHOW_INVENTORY"] = "Mostra Inventario nei Suggerimenti Giocatore"
L["OPTIONS_SHOW_INVENTORY_DESC"] =
	"Aggiunge un blocco Water Dispenser ai suggerimenti dei giocatori elencando ciò che hanno impostato per la distribuzione e quanti ne possono dare, mentre il tuo viene sempre mostrato, in gruppo o meno."
L["OPTIONS_BAG_TOOLTIPS"] = "Mostra i Suggerimenti nelle Borse per gli Oggetti Distribuiti"
L["OPTIONS_BAG_TOOLTIPS_DESC"] =
	"Aggiunge una riga Water Dispenser al suggerimento di un oggetto nelle borse quando quell'oggetto è impostato per essere distribuito, così vedi a colpo d'occhio cosa consegnerà l'add-on."
L["OPTIONS_SHARE_INVENTORY"] = "Condividi il Mio Inventario"
L["OPTIONS_SHARE_INVENTORY_DESC"] =
	"Comunica al tuo gruppo o alla tua incursione cosa hai da regalare, così appare quando passano il cursore su di te. Non scrive mai in chat e non raggiunge nessuno fuori dal tuo gruppo. Disattivandolo puoi comunque vedere i loro."

--------------------------------------------------------------------------------
-- Options — Dispensed Items
--------------------------------------------------------------------------------

L["TAB_DISPENSED_ITEMS"] = "Oggetti Distribuiti"
L["OPTIONS_ITEMS_DESC"] =
	"Configura quanti oggetti distribuire di ciascun tipo. Le quantità si contano in singoli oggetti, quindi 20 acque sono 20 acque, e 1 pozione è 1 pozione. Una pila viene divisa fino alla quantità esatta se serve."
-- "Add an Item" must match OPTIONS_ADD_ITEM.
L["OPTIONS_ITEMS_EMPTY"] =
	'Nessun oggetto configurato. Seleziona "Aggiungi Oggetto" nell\'elenco per aggiungere qualsiasi oggetto scambiabile dalle tue borse.'

--[[
	The silver line opening an item's page while nothing of it would go out. In
	OTHER_CLASS, %s is the player's class twice, then OPTIONS_ITEM_PLAYER_CLASSES;
	in ALL_ZERO, %s is OPTIONS_ITEM_EVERYONE.
]]
L["OPTIONS_ITEM_STATUS_OTHER_CLASS"] = "Non distribuito mentre giochi come %s. Spunta %s in %s."
L["OPTIONS_ITEM_STATUS_ALL_ZERO"] =
	"Ancora non esce nulla: ogni quantità è 0. Inserisci un numero in %s per iniziare."

L["OPTIONS_ITEM_AMOUNTS"] = "Quantità"
L["OPTIONS_ITEM_AMOUNTS_DESC"] =
	"Scegli quanti ne riceve ogni classe quando ci scambi, a seconda che sia sconosciuta, nel tuo gruppo o nella tua incursione. Contati in singoli oggetti, non in pile. Zero significa che non riceverà mai questo oggetto."
L["OPTIONS_ITEM_EVERYONE"] = "Tutti"
-- "Apply" must match OPTIONS_ITEM_APPLY.
L["OPTIONS_ITEM_EVERYONE_DESC"] =
	"Imposta questa quantità per tutte le classi in una volta quando premi Invio o fai clic su Applica, e resta vuoto quando le classi qui sotto non concordano."
-- The accept button inside every number box in this panel.
L["OPTIONS_ITEM_APPLY"] = "Applica"
-- %d is the highest amount this item accepts, which is 1 for anything unique.
L["OPTIONS_ITEM_COUNT_TOO_HIGH"] = "È più di quanto puoi dare di questo oggetto. Il massimo è %d."
L["OPTIONS_ITEM_COUNT_INVALID"] = "Inserisci un numero di oggetti."
L["OPTIONS_ITEM_SETTINGS"] = "Impostazioni Oggetto"
L["OPTIONS_ITEM_DISTRIBUTE"] = "Assegna"
-- "In Instance" must match OPTIONS_ITEM_DISTRIBUTE_INSTANCE.
L["OPTIONS_ITEM_DISTRIBUTE_DESC"] =
	"Stabilisce dove viene distribuito questo oggetto. In Istanza comprende spedizioni, incursioni, campi di battaglia e arene. Altrove, l'oggetto non viene mai scambiato, annunciato o mostrato nel tuo suggerimento."
--[[
	Dropdown entries, looked up as OPTIONS_ITEM_DISTRIBUTE_ plus the stored value in
	capitals ("Always", "Instance"), so no code names these keys in full.
]]
L["OPTIONS_ITEM_DISTRIBUTE_ALWAYS"] = "Sempre"
L["OPTIONS_ITEM_DISTRIBUTE_INSTANCE"] = "In Istanza"
L["OPTIONS_ITEM_GUILDIES_ONLY"] = "Solo Gilda"
L["OPTIONS_ITEM_GUILDIES_ONLY_DESC"] = "Salta questo oggetto quando il tuo compagno di scambio non è nella tua gilda."
-- Panel line under the toggle, not a tooltip: it names the guild, which no fixed string can. %s is the player's guild.
L["OPTIONS_ITEM_GUILDIES_ONLY_HELP"] = "Dai solo ai membri di <%s>."
L["OPTIONS_ITEM_GUILDIES_ONLY_NO_GUILD"] = "Non sei in nessuna gilda, quindi questo non dà l'oggetto a nessuno."
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Considera il Livello Richiesto dall'Oggetto"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] =
	"Salta questo oggetto quando il tuo compagno di scambio è sotto il livello richiesto dall'oggetto."
L["OPTIONS_ITEM_RESERVE"] = "Abilita Riserve"
L["OPTIONS_ITEM_RESERVE_DESC"] =
	"Tiene sempre almeno questa quantità nelle tue borse, mentre la distribuzione, il tuo suggerimento giocatore e la macro di annuncio considerano tutto ciò che supera quel numero come disponibile da regalare."
L["OPTIONS_ITEM_PLAYER_CAP"] = "Abilita Massimo per Giocatore"
L["OPTIONS_ITEM_PLAYER_CAP_DESC"] =
	"Smette di dare questo oggetto a qualcuno quando ne ha ricevuti questo numero da te. I conteggi ripartono quando esci dal gioco, ricarichi o cambi le quantità di questo oggetto."
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
-- The General panel's last line. %s is the version.
L["OPTIONS_VERSION"] = "Versione %s"
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"
L["SUPPORT_WAGO"] = "Wago"
