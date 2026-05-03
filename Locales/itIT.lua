local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "itIT")
if not L then return end

L["CHAT_LOADED"] = "Attivato. Usa %s per accedere alle impostazioni o disattivare questo messaggio. Ti piace Water Dispenser? Dillo a un amico! (="
L["CHAT_NO_TRADE"] = "Nessuna finestra di scambio attiva."
L["CHAT_COMBAT_PAUSED"] = "Riempimento automatico in pausa in combattimento."
L["CHAT_COMBAT_RESUMED"] = "Combattimento terminato. Ripresa del riempimento."
L["CHAT_MISSING_STACK"] = "Pile mancanti:"
L["CHAT_ITEM_SAVED"] = "Salvato:"
L["CHAT_ITEM_REMOVED"] = "Rimosso:"

L["BTN_CLEAR"] = "Pulisci Scambio"
L["BTN_FILL"] = "Riempi Scambio"
L["BTN_CONFIG"] = "Opzioni"
L["BTN_ACCEPT"] = "Accetta Scambio"

L["OPTIONS_TITLE"] = "Water Dispenser"
L["OPTIONS_DESC"] = "Riempie automaticamente la finestra di scambio con pile d'acqua, cibo, pietre della salute o qualsiasi consumabile configurato, in base alla classe, al livello e al gruppo del compagno di scambio."

L["OPTIONS_GENERAL_HEADER"] = "Impostazioni Generali"
L["OPTIONS_WELCOME_MESSAGE"] = "Abilita Messaggio di Benvenuto"
L["OPTIONS_WELCOME_MESSAGE_DESC"] = "Mostra un saluto in chat quando Water Dispenser si carica."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "Mostra Avvisi di Pile Mancanti"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] = "Mostra un messaggio in chat quando un oggetto configurato non ha abbastanza pile nelle tue borse per riempire lo scambio."
L["OPTIONS_ITEMS"] = "Regole di Distribuzione"
L["OPTIONS_ADD_ITEM"] = "Aggiungi Oggetto"
L["OPTIONS_SUPPORT"] = "Supporto e Feedback"

L["OPTIONS_AUTOFILL_HEADER"] = "Riempimento Automatico"
L["OPTIONS_AUTOFILL_DESC"] = "Riempie la finestra di scambio automaticamente all'apertura. Ogni ambito è attivato indipendentemente."
L["OPTIONS_AUTOFILL_SOLO"] = "Riempi per gli Sconosciuti"
L["OPTIONS_AUTOFILL_SOLO_DESC"] = "Riempie automaticamente la finestra quando scambi con qualcuno che non è nel tuo gruppo o incursione."
L["OPTIONS_AUTOFILL_GROUP"] = "Riempi per i Membri del Gruppo"
L["OPTIONS_AUTOFILL_GROUP_DESC"] = "Riempie automaticamente la finestra quando scambi con un membro del gruppo."
L["OPTIONS_AUTOFILL_RAID"] = "Riempi per i Membri dell'Incursione"
L["OPTIONS_AUTOFILL_RAID_DESC"] = "Riempie automaticamente la finestra quando scambi con un membro dell'incursione."

L["OPTIONS_COMBAT_HEADER"] = "Combattimento"
L["OPTIONS_COMBAT_DESC"] = "Il riempimento automatico è sempre in pausa durante il combattimento per evitare errori dell'interfaccia. Riceverai un promemoria in chat. Gli scambi riprendono automaticamente a fine combattimento se la finestra è ancora aperta."

L["OPTIONS_LOCKED_HEADER"] = "Casseforti dei Ladri"
L["OPTIONS_LOCKED_DESC"] = "Quando scambi con un ladro, inserisce il primo oggetto chiuso a chiave delle tue borse nello slot non scambiabile, per farglielo scassinare."
L["OPTIONS_LOCKED"] = "Offri Oggetti Chiusi ai Ladri"

L["OPTIONS_RESET_HEADER"] = "Ripristina"
L["OPTIONS_RESET_DESC"] = "Ripristina tutte le impostazioni di Water Dispenser su questo personaggio ai valori predefiniti, inclusa la tua lista oggetti personalizzata."
L["OPTIONS_RESET_BUTTON"] = "Ripristina tutte le Opzioni"
L["OPTIONS_RESET_CONFIRM"] = "Sei sicuro di voler ripristinare tutte le impostazioni su questo personaggio?"

L["OPTIONS_COMMANDS_HEADER"] = "/Comandi"
L["OPTIONS_COMMANDS_DESC"] = "Comandi testuali per Water Dispenser. Il pannello opzioni copre tutto il necessario; questi comandi sono per gli amanti della tastiera."
L["OPTIONS_COMMAND_WD"] = "/wd"
L["OPTIONS_COMMAND_WD_DESC"] = "Apre le opzioni di Water Dispenser."
L["OPTIONS_COMMAND_WD_FILL"] = "/wd fill"
L["OPTIONS_COMMAND_WD_FILL_DESC"] = "Riempie la finestra di scambio ora, anche se il riempimento automatico è disattivato."
L["OPTIONS_COMMAND_WD_CLEAR"] = "/wd clear"
L["OPTIONS_COMMAND_WD_CLEAR_DESC"] = "Svuota ogni slot nella finestra di scambio."
L["OPTIONS_COMMAND_WD_AUTO"] = "/wd auto solo||group||raid on||off"
L["OPTIONS_COMMAND_WD_AUTO_DESC"] = "Attiva/disattiva il riempimento automatico per l'ambito specificato. Ometti on/off per invertirlo."
L["OPTIONS_COMMAND_WDA"] = "/wda"
L["OPTIONS_COMMAND_WDA_DESC"] = "Invia il messaggio di annuncio al canale che corrisponde al tuo stato di gruppo attuale."

L["CHAT_RESET"] = "Tutte le opzioni sono state ripristinate ai valori predefiniti."

L["OPTIONS_ITEMS_DESC"] = "Configura quante pile di ogni oggetto distribuire. Nota: Classic Era e TBC Anniversary non supportano la divisione automatica delle pile."
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

L["OPTIONS_ADD_DESC"] = "Seleziona un consumabile scambiabile dalle tue borse per aggiungerlo alla configurazione. Gli oggetti già configurati o vincolati non appariranno."
L["OPTIONS_ADD_SELECT"] = "Oggetti disponibili"
L["OPTIONS_ADD_BUTTON"] = "Aggiungi alla configurazione"
L["OPTIONS_ADD_EMPTY"] = "Nessun consumabile idoneo trovato nelle tue borse."

L["SUPPORT_DESC"] = "Segnala problemi, richiedi nuove funzioni o saluta su Discord."
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"

L["OPTIONS_ANNOUNCEMENTS"] = "Annunci"
L["OPTIONS_ANNOUNCEMENTS_DESC"] = "Water Dispenser può creare una macro che annuncia cosa hai da offrire. La macro sceglie automaticamente il canale corretto (/dici, /gruppo, /incursione) usando le quantità aggiornate delle tue borse."

L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Abilita Macro di Annuncio"
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] = "Mantiene aggiornata una macro specifica del personaggio chiamata \"- Dispenser\". Disattivandola, la macro verrà eliminata."

L["OPTIONS_ANNOUNCEMENTS_PREVIEW_HEADER"] = "Anteprima in Tempo Reale"
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DESC"] = "Questo è ciò che dirà la macro se la clicchi in questo momento."
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] = "Niente da annunciare. Configura oggetti, riempi le borse o abbassa il valore \"Mantieni almeno\"."

L["ANNOUNCEMENTS_INTRO"] = "Ho"
L["ANNOUNCEMENTS_OUTRO"] = ". Apri lo scambio!"
L["ANNOUNCEMENTS_AND"] = "e"

L["CHAT_MACRO_CREATED"] = "La macro di annuncio \"- Dispenser\" è pronta. Apri l'interfaccia Macro (/m) e trascinala sulla tua barra delle azioni."
L["CHAT_MACRO_DELETED"] = "Macro di annuncio \"- Dispenser\" eliminata."
L["CHAT_MACRO_FULL"] = "Impossibile creare la macro: tutti gli slot macro del personaggio sono in uso."
L["CHAT_NOTHING_TO_ANNOUNCE"] = "Niente da annunciare per il momento."

L["ITEM_MAGE_WATER"] = "Qualsiasi Acqua Evocata"
L["ITEM_MAGE_FOOD"] = "Qualsiasi Cibo Evocato"
L["ITEM_WARLOCK_HEALTHSTONE"] = "Qualsiasi Pietra della Salute"