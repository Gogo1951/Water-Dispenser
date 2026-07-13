local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "esES")
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
	"Versión %s. Los ajustes (incluyendo la opción de desactivar este mensaje) se encuentran en Opciones > Accesorios > Water Dispenser. ¿Te gusta Water Dispenser? ¡Cuéntaselo a un amigo! (="
L["CHAT_NO_TRADE"] = "No hay ninguna ventana de comercio activa."
L["CHAT_COMBAT_PAUSED"] = "Autocompletado pausado en combate."
L["CHAT_COMBAT_RESUMED"] = "Combate terminado. Reanudando autocompletado de comercio."
L["CHAT_MISSING_STACK"] = "Montones faltantes:"
L["CHAT_NONE_ACTIVE_FOR_CLASS"] =
	"No hay objetos configurados para dispensar mientras juegas con un %s. Abre Opciones > Reglas de distribución para habilitar objetos para esta clase."
L["CHAT_ITEM_SAVED"] = "Guardado:"
L["CHAT_ITEM_REMOVED"] = "Eliminado:"
L["CHAT_MACRO_CREATED"] =
	'Macro de anuncio "- Dispenser" lista. Abre la IU de Macros (Menú de juego > Macros, o /m) y arrástrala a tu barra de acción.'
L["CHAT_MACRO_DELETED"] = 'Macro de anuncio "- Dispenser" eliminada.'
L["CHAT_MACRO_FULL"] = "No se pudo crear la macro: todas las ranuras de macro del personaje están en uso."

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BUTTON_CLEAR"] = "Limpiar ventana de comercio"
L["BUTTON_FILL"] = "Llenar ventana de comercio"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["MINIMAP_DISPENSE"] = "Dispensar"
L["UI_ENABLED"] = "Activado"
L["UI_DISABLED"] = "Desactivado"
L["UI_LEFT_CLICK"] = "Clic izquierdo"
L["UI_TOGGLE"] = "Alternar"
L["MINIMAP_OPTIONS"] = "Opciones de Water Dispenser"
L["MINIMAP_OPTIONS_KEYBIND"] = "Mayús + Clic central"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_DESC"] =
	"Llena automáticamente la ventana de comercio con montones de agua, comida, piedras de salud o cualquier consumible configurado, según la clase, nivel y grupo del compañero de comercio."

L["OPTIONS_WELCOME_MESSAGE"] = "Activar mensaje de bienvenida"
L["OPTIONS_WELCOME_MESSAGE_DESC"] = "Muestra un saludo en el chat cuando Water Dispenser se carga."
L["OPTIONS_MINIMAP"] = "Activar botón del minimapa"
L["OPTIONS_MINIMAP_DESC"] = "Muestra el botón de Water Dispenser en el minimapa."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "Activar advertencias de montones faltantes"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] =
	"Muestra un mensaje de chat cuando un objeto configurado no tiene suficientes montones en tus bolsas para llenar el comercio."

L["OPTIONS_COMMANDS"] = "/Comandos"
L["OPTIONS_COMMANDS_WD"] = "Abre el panel de opciones de Water Dispenser."

L["OPTIONS_DISPENSE_HEADER"] = "Dispensar"
L["OPTIONS_DISPENSE_DESC"] =
	"Llena la ventana de comercio automáticamente al abrirse. Cada opción de abajo se puede alternar de forma independiente."
L["OPTIONS_DISPENSE_MASTER"] = "Activar dispensador"
L["OPTIONS_DISPENSE_MASTER_DESC"] = "Llena automáticamente la ventana de comercio según tus ajustes."
L["OPTIONS_DISPENSE_SOLO"] = "Llenar para desconocidos"
L["OPTIONS_DISPENSE_SOLO_DESC"] =
	"Llena la ventana de comercio automáticamente al comerciar con alguien que no está en tu grupo o banda."
L["OPTIONS_DISPENSE_GROUP"] = "Llenar para miembros del grupo"
L["OPTIONS_DISPENSE_GROUP_DESC"] =
	"Llena la ventana de comercio automáticamente al comerciar con un miembro del grupo."
L["OPTIONS_DISPENSE_RAID"] = "Llenar para miembros de banda"
L["OPTIONS_DISPENSE_RAID_DESC"] =
	"Llena la ventana de comercio automáticamente al comerciar con un miembro de la banda."

L["OPTIONS_COMBAT_HEADER"] = "Combate"
L["OPTIONS_COMBAT_DESC"] =
	"El autocompletado siempre se pausa en combate para evitar errores de interfaz. Se mostrará un recordatorio en el chat. Los comercios se reanudarán automáticamente una vez termine el combate si la ventana sigue abierta."

--------------------------------------------------------------------------------
-- Options — Distribution Rules
--------------------------------------------------------------------------------

L["OPTIONS_ITEMS"] = "Reglas de distribución"
L["OPTIONS_ITEMS_DESC"] =
	"Configura cuántos montones de cada objeto dispensar. Nota: Classic Era y TBC Anniversary no soportan la división automatizada de montones. ¡Lo sentimos!"
L["OPTIONS_ITEMS_EMPTY"] =
	'No hay objetos configurados. Abre la pestaña "Añadir objeto" para añadir consumibles de tus bolsas.'

L["OPTIONS_ITEM_SETTINGS"] = "Ajustes del objeto"
L["OPTIONS_ITEM_USE_NOT_FULL"] = "Llenar con montones parciales"
L["OPTIONS_ITEM_USE_NOT_FULL_DESC"] =
	"Cuando no haya un montón completo disponible, llena el comercio con cualquier montón más pequeño que tengas a mano."
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Tener en cuenta requisitos de nivel"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] =
	"Omite este objeto cuando el compañero de comercio esté por debajo del nivel requerido del objeto."
L["OPTIONS_ITEM_KEEP_AT_LEAST"] = "Mantener al menos"
L["OPTIONS_ITEM_KEEP_AT_LEAST_DESC"] =
	"Mantén siempre al menos esta cantidad en tus bolsas. Lo que supere este número se considerará disponible para regalar."
L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "Incluir cantidad restante en la macro"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] =
	"Incluye la cantidad restante al anunciar este objeto. Desactívalo si prefieres solo decir que lo tienes sin el recuento (típico para piedras de salud)."
L["OPTIONS_ITEM_PLAYER_CLASSES"] = "Solo dispensar al jugar con estas clases"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] =
	"Solo llena comercios y añade este objeto al anuncio cuando la clase de tu personaje esté seleccionada abajo."
L["OPTIONS_ITEM_REMOVE"] = "Eliminar objeto"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "¿Eliminar este objeto de la configuración de comercio?"

L["OPTIONS_SCOPE_SOLO"] = "Desconocidos"
L["OPTIONS_SCOPE_GROUP"] = "Miembros del grupo"
L["OPTIONS_SCOPE_RAID"] = "Miembros de banda"

L["OPTIONS_ADD_ITEM"] = "Añadir objeto"
L["OPTIONS_ADD_DESC"] =
	"Selecciona un consumible comerciable de tus bolsas para añadir a la configuración. Los objetos ya configurados o ligados al alma no aparecerán."
L["OPTIONS_ADD_SELECT"] = "Objetos disponibles"
L["OPTIONS_ADD_BUTTON"] = "Añadir a la configuración"
L["OPTIONS_ADD_EMPTY"] = "No se encontraron consumibles elegibles en tus bolsas."

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["OPTIONS_ANNOUNCEMENTS"] = "Anuncios"
L["OPTIONS_ANNOUNCEMENTS_DESC"] =
	"Water Dispenser puede crear una macro que anuncie lo que tienes para repartir. La macro elige el canal correcto automáticamente (/decir, /grupo, /banda) y usa el recuento actual de tus bolsas."
L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Activar macro de anuncio"
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] =
	'Mantiene actualizada una macro específica del personaje llamada "- Dispenser". Desactivarla elimina la macro.'
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_HEADER"] = "Vista previa"
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DESC"] = "Esto es lo que dirá la macro si la pulsas ahora mismo."
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] =
	'Nada que anunciar. Configura objetos, repón tus bolsas o baja el valor de "Mantener al menos".'

-- Message-body fragments the macro stitches together.
L["ANNOUNCEMENTS_INTRO"] = "Tengo"
L["ANNOUNCEMENTS_OUTRO"] = ". ¡Abre comercio!"
L["ANNOUNCEMENTS_AND"] = "y"

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["OPTIONS_SUPPORT"] = "Soporte y Comentarios"
L["SUPPORT_DESC"] = "Informa de problemas, pide características o saluda en Discord."
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"
L["SUPPORT_WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Built-in Collections
--------------------------------------------------------------------------------

L["ITEM_MAGE_WATER"] = "Agua conjurada"
L["ITEM_MAGE_FOOD"] = "Comida conjurada"
L["ITEM_WARLOCK_HEALTHSTONE"] = "Piedras de salud"
