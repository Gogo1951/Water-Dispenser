local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "itIT")
if not L then return end

--------------------------------------------------------------------------------
-- Add-on Identity
--------------------------------------------------------------------------------

L["ADDON_TITLE"] = "Water Dispenser"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- All player-facing chat prints live here, regardless of which feature emits them.
L["CHAT_LOADED"] = "Versione %s. Le impostazioni (inclusa l'opzione per disattivare questo messaggio) si trovano in Opzioni > AddOns > Water Dispenser. Ti piace Water Dispenser? Dillo a un amico! (="
L["CHAT_NO_TRADE"] = "Nessuna finestra di scambio attiva."
L["CHAT_COMBAT_PAUSED"] = "Riempimento automatico in pausa in combattimento."
L["CHAT_COMBAT_RESUMED"] = "Combattimento terminato. Ripresa del riempimento."
L["CHAT_MISSING_STACK"] = "Pile mancanti:"
L["CHAT_NONE_ACTIVE_FOR_CLASS"] = "Nessun oggetto è impostato per essere distribuito mentre giochi come %s. Apri Opzioni > Regole di Distribuzione per abilitare gli oggetti per questa classe."
L["CHAT_ITEM_SAVED"] = "Salvato:"
L["CHAT_ITEM_REMOVED"] = "Rimosso:"
L["CHAT_RESET"] = "Tutte le opzioni sono state ripristinate ai valori predefiniti."
L["CHAT_MACRO_CREATED"] = "La macro di annuncio \"- Dispenser\" è pronta. Apri l'interfaccia Macro (Menu di gioco > Macro, o /m) e trascinala sulla tua barra delle azioni."
L["CHAT_MACRO_DELETED"] = "Macro di annuncio \"- Dispenser\" eliminata."
L["CHAT_MACRO_FULL"] = "Impossibile creare la macro: tutti gli slot macro del personaggio sono in uso."

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BTN_CLEAR"] = "Pulisci Scambio Window"
L["BTN_FILL"] = "Riempi Scambio Window"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["MINIMAP_DISPENSE"] = "Distribuisci"
L["MINIMAP_DISPENSE_DESC"] = "Riempie automaticamente la finestra di scambio in base alle tue impostazioni."
L["UI_ENABLED"] = "Abilitato"
L["UI_DISABLED"] = "Disabilitato"
L["UI_LEFT_CLICK"] = "Tasto sinistro"
L["UI_TOGGLE"] = "Attiva/Disattiva"
L["MINIMAP_HINT"] = "Ulteriori impostazioni si trovano in Opzioni > AddOns > Water Dispenser."

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_TITLE"] = "Water Dispenser"
L["OPTIONS_DESC"] = "Riempie automaticamente la finestra di scambio con pile d'acqua, cibo, pietre della salute o qualsiasi consumabile configurato, in base alla classe, al livello e al gruppo del compagno di scambio."

L["OPTIONS_WELCOME_MESSAGE"] = "Abilita Messaggio di Benvenuto"
L["OPTIONS_WELCOME_MESSAGE_DESC"] = "Mostra un saluto in chat quando Water Dispenser si carica."
L["OPTIONS_MINIMAP"] = "Abilita Pulsante Minimappa"
L["OPTIONS_MINIMAP_DESC"] = "Mostra il pulsante della minimappa di Water Dispenser."
L["OPTIONS_CONJURE_BUTTONS"] = "Abilita pulsanti di scambio per Maghi e Stregoni"
L["OPTIONS_CONJURE_BUTTONS_DESC"] = "Mostra i pulsanti Evoca Acqua, Evoca Cibo ed Evoca Pietra della Salute in base al livello accanto alla finestra di scambio."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "Mostra Avvisi di Pile Mancanti"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] = "Mostra un messaggio in chat quando un oggetto configurato non ha abbastanza pile nelle tue borse per riempire lo scambio."

L["OPTIONS_COMMANDS"] = "/Comandi"
L["OPTIONS_COMMANDS_WD"] = "Apre il pannello delle opzioni di Water Dispenser."

L["OPTIONS_DISPENSE_HEADER"] = "Distribuisci"
L["OPTIONS_DISPENSE_DESC"] = "Riempie automaticamente la finestra di scambio all'apertura. Ogni ambito è attivato indipendentemente."
L["OPTIONS_DISPENSE_MASTER"] = "Abilita Distribuzione"
L["OPTIONS_DISPENSE_MASTER_DESC"] = "Riempie automaticamente la finestra di scambio in base alle tue impostazioni."
L["OPTIONS_DISPENSE_SOLO"] = "Abilita per gli Sconosciuti"
L["OPTIONS_DISPENSE_SOLO_DESC"] = "Riempie automaticamente la finestra quando scambi con qualcuno che non è nel tuo gruppo o incursione."
L["OPTIONS_DISPENSE_GROUP"] = "Abilita per i Membri del Gruppo"
L["OPTIONS_DISPENSE_GROUP_DESC"] = "Riempie automaticamente la finestra quando scambi con un membro del gruppo."
L["OPTIONS_DISPENSE_RAID"] = "Abilita per i Membri dell'Incursione"
L["OPTIONS_DISPENSE_RAID_DESC"] = "Riempie automaticamente la finestra quando scambi con un membro dell'incursione."

L["OPTIONS_COMBAT_HEADER"] = "Combattimento"
L["OPTIONS_COMBAT_DESC"] = "Il riempimento automatico è sempre in pausa durante il combattimento per evitare errori dell'interfaccia. Riceverai un promemoria in chat. Gli scambi riprendono automaticamente a fine combattimento se la finestra è ancora aperta."

L["OPTIONS_RESET_HEADER"] = "Ripristina"
L["OPTIONS_RESET_DESC"] = "Ripristina tutte le impostazioni di Water Dispenser su questo personaggio ai valori predefiniti, inclusa la tua lista oggetti personalizzata."
L["OPTIONS_RESET_BUTTON"] = "Ripristina tutte le Opzioni di Water Dispenser"
L["OPTIONS_RESET_CONFIRM"] = "Sei sicuro di voler ripristinare tutte le impostazioni su questo personaggio?"

--------------------------------------------------------------------------------
-- Options — Distribution Rules
--------------------------------------------------------------------------------

L["OPTIONS_ITEMS"] = "Regole di Distribuzione"
L["OPTIONS_ITEMS_DESC"] = "Configura quante pile di ogni oggetto distribuire. Nota: Classic Era e TBC Anniversary non supportano la divisione automatica delle pile. Siamo spiacenti!"
L["OPTIONS_ITEMS_EMPTY"] = "Nessun oggetto configurato. Apri la scheda \"Aggiungi Oggetto\" per aggiungere consumabili dalle tue borse."

L["OPTIONS_ITEM_SETTINGS"] = "Impostazioni Oggetto"
L["OPTIONS_ITEM_USE_NOT_FULL"] = "Riempi con Pile Parziali"
L["OPTIONS_ITEM_USE_NOT_FULL_DESC"] = "Quando una pila intera non è disponibile, riempie lo scambio con una pila più piccola a tua disposizione."
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Considera i Requisiti di Livello"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] = "Salta questo oggetto se il compagno di scambio ha un livello inferiore a quello richiesto."
L["OPTIONS_ITEM_KEEP_AT_LEAST"] = "Mantieni almeno"
L["OPTIONS_ITEM_KEEP_AT_LEAST_DESC"] = "Tieni sempre almeno questa quantità nelle borse. Qualsiasi cosa oltre questo numero sarà disponibile per lo scambio."
L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "Includi Quantità Rimanente nella Macro"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] = "Quando la macro di annuncio elenca questo oggetto, includi quanti ne hai ancora. Disattiva se preferisci solo dire di averlo (tipico per le pietre della salute)."
L["OPTIONS_ITEM_PLAYER_CLASSES"] = "Distribuisci solo giocando queste classi"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] = "Riempie gli scambi e include questo oggetto nell'annuncio solo se la classe del tuo personaggio è selezionata qui sotto."
L["OPTIONS_ITEM_REMOVE"] = "Rimuovi Oggetto"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "Rimuovere questo oggetto dalla configurazione di scambio?"

L["OPTIONS_SCOPE_SOLO"] = "Sconosciuti"
L["OPTIONS_SCOPE_GROUP"] = "Membri del Gruppo"
L["OPTIONS_SCOPE_RAID"] = "Membri dell'Incursione"

L["OPTIONS_ADD_ITEM"] = "Aggiungi Oggetto"
L["OPTIONS_ADD_DESC"] = "Seleziona un consumabile scambiabile dalle tue borse per aggiungerlo alla configurazione. Gli oggetti già configurati o vincolati non appariranno."
L["OPTIONS_ADD_SELECT"] = "Oggetti disponibili"
L["OPTIONS_ADD_BUTTON"] = "Aggiungi alla configurazione"
L["OPTIONS_ADD_EMPTY"] = "Nessun consumabile idoneo trovato nelle tue borse."

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["OPTIONS_ANNOUNCEMENTS"] = "Annunci"
L["OPTIONS_ANNOUNCEMENTS_DESC"] = "Water Dispenser può creare una macro che annuncia cosa hai da offrire. La macro sceglie automaticamente il canale corretto (/dici, /gruppo, /incursione) usando le quantità aggiornate delle tue borse."
L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Abilita Macro di Annuncio"
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] = "Mantiene aggiornata una macro specifica del personaggio chiamata \"- Dispenser\". Disattivandola, la macro verrà eliminata."
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_HEADER"] = "Anteprima in Tempo Reale"
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DESC"] = "Questo è ciò che dirà la macro se la clicchi in questo momento."
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] = "Niente da annunciare. Configura oggetti, riempi le borse o abbassa il valore \"Mantieni almeno\"."

-- Message-body fragments the macro stitches together.
L["ANNOUNCEMENTS_INTRO"] = "Ho"
L["ANNOUNCEMENTS_OUTRO"] = ". Apri lo scambio!"
L["ANNOUNCEMENTS_AND"] = "e"

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["OPTIONS_SUPPORT"] = "Supporto e Feedback"
L["SUPPORT_DESC"] = "Segnala problemi, richiedi nuove funzioni o saluta su Discord."
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"

--------------------------------------------------------------------------------
-- Built-in Collections
--------------------------------------------------------------------------------

L["ITEM_MAGE_WATER"] = "Qualsiasi Acqua Evocata"
L["ITEM_MAGE_FOOD"] = "Qualsiasi Cibo Evocato"
L["ITEM_WARLOCK_HEALTHSTONE"] = "Qualsiasi Pietra della Salute"
