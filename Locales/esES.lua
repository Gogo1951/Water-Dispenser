local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "esES") or LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "esMX")
if not L then return end

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------
L["CHAT_LOADED"] = "Activado. Usa %s para acceder a los ajustes, incluyendo desactivar este mensaje. ¿Te gusta Water Dispenser? ¡Cuéntaselo a un amigo! (="
L["CHAT_NO_TRADE"] = "No hay ninguna ventana de comercio activa."
L["CHAT_COMBAT_PAUSED"] = "Autocompletado pausado en combate."
L["CHAT_COMBAT_RESUMED"] = "Combate terminado. Reanudando autocompletado de comercio."
L["CHAT_MISSING_STACK"] = "Montones faltantes:"
L["CHAT_ITEM_SAVED"] = "Guardado:"
L["CHAT_ITEM_REMOVED"] = "Eliminado:"

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------
L["BTN_CLEAR"] = "Limpiar"
L["BTN_FILL"] = "Llenar"
L["BTN_CONFIG"] = "Opciones"
L["BTN_ACCEPT"] = "Aceptar comercio"

--------------------------------------------------------------------------------
-- Options — Top Level
--------------------------------------------------------------------------------
L["OPTIONS_TITLE"] = "Water Dispenser"
L["OPTIONS_DESC"] = "Llena automáticamente la ventana de comercio con montones de agua, comida, piedras de salud o cualquier consumible configurado, según la clase, nivel y grupo del compañero de comercio."

L["OPTIONS_GENERAL_HEADER"] = "Ajustes generales"
L["OPTIONS_WELCOME_MESSAGE"] = "Activar mensaje de bienvenida"
L["OPTIONS_WELCOME_MESSAGE_DESC"] = "Muestra un saludo en el chat cuando Water Dispenser se carga."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "Mostrar advertencias de montones faltantes"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] = "Muestra un mensaje de chat cuando un objeto configurado no tiene suficientes montones en tus bolsas para llenar el comercio."
L["OPTIONS_ITEMS"] = "Reglas de distribución"
L["OPTIONS_ADD_ITEM"] = "Añadir objeto"
L["OPTIONS_SUPPORT"] = "Soporte y Comentarios"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------
L["OPTIONS_AUTOFILL_HEADER"] = "Autocompletado"
L["OPTIONS_AUTOFILL_DESC"] = "Llena la ventana de comercio automáticamente al abrirse. Cada ámbito se alterna de forma independiente."
L["OPTIONS_AUTOFILL_SOLO"] = "Llenar para desconocidos"
L["OPTIONS_AUTOFILL_SOLO_DESC"] = "Llena la ventana de comercio automáticamente al comerciar con alguien que no está en tu grupo o banda."
L["OPTIONS_AUTOFILL_GROUP"] = "Llenar para miembros del grupo"
L["OPTIONS_AUTOFILL_GROUP_DESC"] = "Llena la ventana de comercio automáticamente al comerciar con un miembro del grupo."
L["OPTIONS_AUTOFILL_RAID"] = "Llenar para miembros de banda"
L["OPTIONS_AUTOFILL_RAID_DESC"] = "Llena la ventana de comercio automáticamente al comerciar con un miembro de la banda."

L["OPTIONS_COMBAT_HEADER"] = "Combate"
L["OPTIONS_COMBAT_DESC"] = "El autocompletado siempre se pausa en combate para evitar errores de interfaz. Se mostrará un recordatorio en el chat. Los comercios se reanudarán automáticamente una vez termine el combate si la ventana sigue abierta."

L["OPTIONS_LOCKED_HEADER"] = "Cajas fuertes de pícaro"
L["OPTIONS_LOCKED_DESC"] = "Al comerciar con un pícaro, coloca el primer objeto bloqueado de tus bolsas en la ranura inferior para que lo puedan forzar."
L["OPTIONS_LOCKED"] = "Ofrecer objetos bloqueados a los pícaros"

L["OPTIONS_RESET_HEADER"] = "Restablecer"
L["OPTIONS_RESET_DESC"] = "Borra todos los ajustes de Water Dispenser en este personaje y los devuelve a sus valores predeterminados, incluyendo tu lista personalizada de objetos."
L["OPTIONS_RESET_BUTTON"] = "Restablecer todas las opciones"
L["OPTIONS_RESET_CONFIRM"] = "¿Seguro que quieres restablecer todos los ajustes en este personaje a sus valores predeterminados?"

L["OPTIONS_COMMANDS_HEADER"] = "/Comandos"
L["OPTIONS_COMMANDS_DESC"] = "Comandos de Water Dispenser. El panel de opciones cubre todo lo que necesitas; estos son para quienes prefieren el teclado."
L["OPTIONS_COMMAND_WD"] = "/wd"
L["OPTIONS_COMMAND_WD_DESC"] = "Abre el panel de opciones de Water Dispenser."
L["OPTIONS_COMMAND_WD_FILL"] = "/wd fill"
L["OPTIONS_COMMAND_WD_FILL_DESC"] = "Llena la ventana de comercio ahora, incluso si el autocompletado está desactivado."
L["OPTIONS_COMMAND_WD_CLEAR"] = "/wd clear"
L["OPTIONS_COMMAND_WD_CLEAR_DESC"] = "Limpia todas las ranuras en la ventana de comercio."
L["OPTIONS_COMMAND_WD_AUTO"] = "/wd auto solo||group||raid on||off"
L["OPTIONS_COMMAND_WD_AUTO_DESC"] = "Alterna el autocompletado para el ámbito dado. Omite on/off para cambiarlo."
L["OPTIONS_COMMAND_WDA"] = "/wda"
L["OPTIONS_COMMAND_WDA_DESC"] = "Envía el mensaje de anuncio al canal que coincida con tu estado de grupo actual."

L["CHAT_RESET"] = "Todas las opciones han sido restablecidas."

--------------------------------------------------------------------------------
-- Options — Items
--------------------------------------------------------------------------------
L["OPTIONS_ITEMS_DESC"] = "Configura cuántos montones de cada objeto dispensar. Nota: Classic Era y TBC Anniversary no soportan la división automatizada de montones."
L["OPTIONS_ITEMS_EMPTY"] = "No hay objetos configurados. Abre la pestaña \"Añadir objeto\" para añadir consumibles de tus bolsas."

L["OPTIONS_ITEM_SETTINGS"] = "Ajustes del objeto"
L["OPTIONS_ITEM_USE_NOT_FULL"] = "Llenar con montones parciales"
L["OPTIONS_ITEM_USE_NOT_FULL_DESC"] = "Cuando no haya un montón completo disponible, llena el comercio con cualquier montón más pequeño que tengas a mano."

L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Tener en cuenta requisitos de nivel"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] = "Omite este objeto cuando el compañero de comercio esté por debajo del nivel requerido del objeto."

L["OPTIONS_ITEM_KEEP_AT_LEAST"] = "Mantener al menos"
L["OPTIONS_ITEM_KEEP_AT_LEAST_DESC"] = "Mantén siempre al menos esta cantidad en tus bolsas. Lo que supere este número se considerará disponible para regalar."

L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "Incluir cantidad restante en la macro"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] = "Incluye la cantidad restante al anunciar este objeto. Desactívalo si prefieres solo decir que lo tienes sin el recuento."

L["OPTIONS_ITEM_PLAYER_CLASSES"] = "Solo dispensar al jugar con esta(s) clase(s)"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] = "Solo llena comercios y añade este objeto al anuncio cuando la clase de tu personaje esté seleccionada abajo."

L["OPTIONS_ITEM_REMOVE"] = "Eliminar objeto"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "¿Eliminar este objeto de la configuración de comercio?"

L["OPTIONS_SCOPE_SOLO"] = "Desconocidos"
L["OPTIONS_SCOPE_GROUP"] = "Miembros del grupo"
L["OPTIONS_SCOPE_RAID"] = "Miembros de banda"

L["OPTIONS_ADD_DESC"] = "Selecciona un consumible comerciable de tus bolsas para añadir a la configuración. Los objetos ya configurados o ligados al alma no aparecerán."
L["OPTIONS_ADD_SELECT"] = "Objetos disponibles"
L["OPTIONS_ADD_BUTTON"] = "Añadir a la configuración"
L["OPTIONS_ADD_EMPTY"] = "No se encontraron consumibles elegibles en tus bolsas."

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------
L["SUPPORT_DESC"] = "Informa de problemas, pide características o saluda en Discord."
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------
L["OPTIONS_ANNOUNCEMENTS"] = "Anuncios"
L["OPTIONS_ANNOUNCEMENTS_DESC"] = "Water Dispenser puede crear una macro que anuncie lo que tienes para repartir. La macro elige el canal correcto automáticamente (/decir, /grupo, /banda) y usa el recuento actual de tus bolsas."

L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Activar macro de anuncio"
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] = "Mantiene actualizada una macro específica del personaje llamada \"- Dispenser\". Desactivarla elimina la macro."

L["OPTIONS_ANNOUNCEMENTS_PREVIEW_HEADER"] = "Vista previa"
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DESC"] = "Esto es lo que dirá la macro si la pulsas ahora mismo."
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] = "Nada que anunciar. Configura objetos, repón tus bolsas o baja el valor de \"Mantener al menos\"."

L["ANNOUNCEMENTS_INTRO"] = "Tengo"
L["ANNOUNCEMENTS_OUTRO"] = ". ¡Abre comercio!"
L["ANNOUNCEMENTS_AND"] = "y"

L["CHAT_MACRO_CREATED"] = "Macro de anuncio \"- Dispenser\" lista. Abre la IU de Macros (/m) y arrástrala a tu barra de acción."
L["CHAT_MACRO_DELETED"] = "Macro de anuncio \"- Dispenser\" eliminada."
L["CHAT_MACRO_FULL"] = "No se pudo crear la macro: todas las ranuras están en uso."
L["CHAT_NOTHING_TO_ANNOUNCE"] = "No hay nada que anunciar ahora mismo."

--------------------------------------------------------------------------------
-- Built-in Collections
--------------------------------------------------------------------------------
L["ITEM_MAGE_WATER"] = "Cualquier agua conjurada"
L["ITEM_MAGE_FOOD"] = "Cualquier comida conjurada"
L["ITEM_WARLOCK_HEALTHSTONE"] = "Cualquier piedra de salud"