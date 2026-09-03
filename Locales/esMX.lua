local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "esMX")
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
	"Versión %s. Los ajustes (incluyendo la opción de desactivar este mensaje) se encuentran en Opciones > Accesorios > Water Dispenser. ¿Te gusta el accesorio? ¡Cuéntaselo a un amigo! (="
L["CHAT_NO_TRADE"] = "No hay ninguna ventana de comercio activa."
L["CHAT_COMBAT_BLOCKED"] = "WoW bloquea los intercambios automatizados durante el combate."
L["CHAT_OPTIONS_IN_COMBAT"] = "Como medida de seguridad, la interfaz de opciones no puede abrirse durante el combate."
-- The item and its count are appended after the colon by the code.
L["CHAT_MISSING_STACK"] = "Falta:"
-- %s is the item's name, %d the Maximum per Session it has hit.
-- "Maximum per Session" must match OPTIONS_ITEM_SESSION_CAP.
L["CHAT_SESSION_CAP_REACHED"] =
	"%s no añadido: ya ha recibido sus %d en esta sesión. Cambia Máximo por sesión, o recarga para reiniciar."
-- %s is the item's name, %d the amount that could not be split off.
L["CHAT_SPLIT_REFUSED"] =
	"%s no añadido: este cliente no ha querido separar %d de una pila, y entregar una pila entera en su lugar daría mucho más de lo que pediste. Ajusta la cantidad de este objeto a una pila entera para comerciarlo."
-- %s is the player's class name. "Dispensed Items" must match TAB_DISPENSED_ITEMS.
L["CHAT_NONE_ACTIVE_FOR_CLASS"] =
	"No hay objetos configurados para dispensar mientras juegas con un %s. Abre Opciones > Objetos dispensados para habilitar objetos para esta clase."
-- The item's name is appended after the colon by the code.
L["CHAT_ITEM_SAVED"] = "Guardado:"
-- "- Dispenser" is the macro's literal name and is never translated.
L["CHAT_MACRO_DELETED"] = 'Macro de anuncio "- Dispenser" eliminada.'
L["CHAT_MACRO_FULL"] = "No se pudo crear la macro: todas las ranuras de macro del personaje están en uso."

--------------------------------------------------------------------------------
-- Player Tooltips
--------------------------------------------------------------------------------

L["TOOLTIP_OPEN_TRADE"] = "¡Abre comercio!"
-- %d/%d is the warlock's Improved Healthstone rank out of its maximum.
L["TOOLTIP_HEALTHSTONE"] = "Piedra de salud (Rango %d/%d)"

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BUTTON_CLEAR"] = "Limpiar ventana de comercio"
L["BUTTON_FILL"] = "Llenar ventana de comercio"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

-- The tooltip's feature row reuses OPTIONS_DISPENSE_HEADER for its name; these are its state and click words.
L["UI_ENABLED"] = "Activado"
L["UI_DISABLED"] = "Desactivado"
L["UI_LEFT_CLICK"] = "Clic izquierdo"
L["UI_TOGGLE"] = "Alternar"
L["MINIMAP_OPTIONS"] = "Opciones de Water Dispenser"
L["MINIMAP_OPTIONS_KEYBIND"] = "Mayús + Clic central"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Llena automáticamente la ventana de comercio con agua, comida, piedras de salud o cualquier consumible que configures, en la cantidad que elegiste para la clase, el nivel y la pertenencia al grupo del compañero de comercio."

L["OPTIONS_WELCOME_MESSAGE"] = "Activar mensaje de bienvenida"
L["OPTIONS_WELCOME_MESSAGE_DESC"] =
	"Muestra un saludo de una línea en tu ventana de chat cuando Water Dispenser se carga."
L["OPTIONS_MINIMAP"] = "Activar botón del minimapa"
L["OPTIONS_MINIMAP_DESC"] = "Muestra el botón de Water Dispenser en el minimapa."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "Activar avisos cuando te quedes corto"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] =
	"Muestra un aviso en tu ventana de chat cuando no tienes suficiente de un objeto configurado en tus bolsas para dar la cantidad que fijaste."
-- The label says what it does; the tooltip only covers why it is needed and when it stands down.
L["OPTIONS_RESTACK"] = "Combinar automáticamente las pilas parciales en las bolsas"
L["OPTIONS_RESTACK_DESC"] =
	"El agua y la comida conjuradas caen en una ranura nueva de la bolsa con cada lanzamiento y el juego nunca las vuelve a juntar, aunque esto nunca se ejecuta en combate, con un comercio abierto ni mientras llevas algo en el cursor."

L["OPTIONS_COMMANDS_HEADER"] = "/Comandos"
L["OPTIONS_COMMAND"] = "/wd"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Abre la interfaz de opciones de este accesorio."

L["OPTIONS_DISPENSE_HEADER"] = "Dispensar"
L["OPTIONS_DISPENSE_DESC"] =
	"Llena automáticamente la ventana de comercio al abrirse un intercambio. Activa o desactiva cada opción de abajo por separado."
L["OPTIONS_DISPENSE_MASTER"] = "Activar dispensado"
L["OPTIONS_DISPENSE_MASTER_DESC"] = "Llena automáticamente la ventana de comercio según tus ajustes."
L["OPTIONS_DISPENSE_SOLO"] = "Activar para desconocidos"
L["OPTIONS_DISPENSE_SOLO_DESC"] =
	"Llena la ventana de comercio automáticamente al comerciar con alguien que no está en tu grupo ni en tu banda."
L["OPTIONS_DISPENSE_GROUP"] = "Activar para grupo"
L["OPTIONS_DISPENSE_GROUP_DESC"] =
	"Llena la ventana de comercio automáticamente al comerciar con un miembro del grupo."
L["OPTIONS_DISPENSE_RAID"] = "Activar para banda"
L["OPTIONS_DISPENSE_RAID_DESC"] =
	"Llena la ventana de comercio automáticamente al comerciar con un miembro de la banda."

L["OPTIONS_TOOLTIPS_HEADER"] = "Inventario en las descripciones de jugador"
L["OPTIONS_TOOLTIPS_DESC"] =
	"Muestra el inventario para regalar en las descripciones de los miembros del grupo que usan Water Dispenser."
L["OPTIONS_SHOW_INVENTORY"] = "Mostrar inventario en las descripciones de jugador"
L["OPTIONS_SHOW_INVENTORY_DESC"] =
	"Añade un bloque de Water Dispenser a las descripciones de jugador con lo que tienen configurado para repartir y cuántos llevan encima, mostrándose el tuyo siempre, estés en grupo o no."
L["OPTIONS_SHARE_INVENTORY"] = "Compartir mi inventario"
L["OPTIONS_SHARE_INVENTORY_DESC"] =
	"Comunica a tu grupo y a tu banda lo que llevas encima para que tu inventario aparezca cuando te apunten, sin publicar nada en el chat ni avisar a nadie fuera de tu grupo, y desactivarlo te deja seguir viendo el de los demás."

L["OPTIONS_COMBAT_HEADER"] = "Combate"
L["OPTIONS_COMBAT_DESC"] = "WoW impide que los accesorios muevan objetos a un comercio durante el combate."
L["OPTIONS_COMBAT_NOTIFY"] = "Activar notificaciones cuando el dispensado esté bloqueado"
L["OPTIONS_COMBAT_NOTIFY_DESC"] =
	"Muestra un aviso en tu ventana de chat cuando el combate impide llenar un comercio, y desactivado Water Dispenser se queda en silencio, sin explicar por qué el comercio siguió vacío."

--------------------------------------------------------------------------------
-- Options — Dispensed Items
--------------------------------------------------------------------------------

L["TAB_DISPENSED_ITEMS"] = "Objetos dispensados"
L["OPTIONS_ITEMS_DESC"] =
	"Configura cuántos de cada objeto dispensar. Las cantidades se cuentan en objetos individuales, así que 20 aguas son 20 aguas, y 1 poción es 1 poción. Una pila se divide hasta la cantidad exacta si hace falta."
-- "Add an Item" must match OPTIONS_ADD_ITEM.
L["OPTIONS_ITEMS_EMPTY"] =
	'No hay objetos configurados. Selecciona "Añadir objeto" en la lista para añadir consumibles de tus bolsas.'

L["OPTIONS_ITEM_DISTRIBUTION"] = "Distribución"
L["OPTIONS_ITEM_DISTRIBUTION_DESC"] =
	"Elige cuántos recibe cada clase al comerciar con ella, según si es un desconocido, está en tu grupo o en tu banda. Se cuentan objetos individuales, no pilas. Cero significa que nunca recibirán este objeto."
L["OPTIONS_ITEM_EVERYONE"] = "Todos"
L["OPTIONS_ITEM_EVERYONE_DESC"] =
	"Fija esta cantidad para todas las clases a la vez cuando pulsas Intro, y aparece en blanco cuando las clases de abajo no coinciden."
-- The accept button inside every number box in this panel.
L["OPTIONS_ITEM_APPLY"] = "Aplicar"
-- %d is the highest amount this item accepts, which is 1 for anything unique.
L["OPTIONS_ITEM_COUNT_TOO_HIGH"] = "Eso es más de lo que este objeto puede dispensar. El máximo es %d."
L["OPTIONS_ITEM_COUNT_INVALID"] = "Introduce un número de objetos, o 0 para no dispensar este nunca."
L["OPTIONS_ITEM_SETTINGS"] = "Ajustes del objeto"
-- "In Group" and "In Raid" in the tooltip must match the two dropdown entries below.
L["OPTIONS_ITEM_DISTRIBUTE"] = "Repartir"
L["OPTIONS_ITEM_DISTRIBUTE_DESC"] =
	"Fija cuándo se entrega este objeto siquiera, ya que fuera del grupo que elijas nunca se comercia, ni se anuncia, ni se muestra en tu descripción, con En grupo cubriendo un grupo o una banda y En banda solo bandas."
-- Dropdown entries. The stored values are "Always", "Group", and "Raid"; these are only their labels.
L["OPTIONS_ITEM_DISTRIBUTE_ALWAYS"] = "Siempre"
L["OPTIONS_ITEM_DISTRIBUTE_GROUP"] = "En grupo"
L["OPTIONS_ITEM_DISTRIBUTE_RAID"] = "En banda"
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Tener en cuenta los requisitos de nivel"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] =
	"Omite este objeto cuando el compañero de comercio esté por debajo del nivel requerido del objeto."
L["OPTIONS_ITEM_RESERVE"] = "Activar reservas"
L["OPTIONS_ITEM_RESERVE_DESC"] =
	"Guarda siempre al menos esta cantidad en tus bolsas, y el dispensado y la macro de anuncio tratan todo lo que exceda ese número como disponible para regalar."
L["OPTIONS_ITEM_SESSION_CAP"] = "Activar máximo por sesión"
L["OPTIONS_ITEM_SESSION_CAP_DESC"] =
	"Deja de dar este objeto a alguien una vez que ha recibido esta cantidad de ti, contando todos los comercios hasta que cierres sesión o recargues, y cambiar cualquier cantidad de este objeto reinicia la cuenta de todos."
-- The label carries the meaning on its own; the tooltip only says why you'd switch it off.
L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "Incluir cantidad en la descripción de jugador y la macro de anuncio"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] =
	"Desactivado nombra el objeto sin número al lado, lo que queda mejor para algo de lo que solo llevas uno, como una piedra de salud."
L["OPTIONS_ITEM_PLAYER_CLASSES"] = "Dispensar solo al jugar con estas clases"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] =
	"Solo llena comercios y añade este objeto al anuncio cuando la clase de tu personaje esté seleccionada abajo."
L["OPTIONS_ITEM_REMOVE"] = "Eliminar objeto"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "¿Eliminar este objeto de la configuración de comercio?"

L["OPTIONS_SCOPE_SOLO"] = "Desconocidos"
L["OPTIONS_SCOPE_GROUP"] = "Grupo"
L["OPTIONS_SCOPE_RAID"] = "Banda"

L["OPTIONS_ADD_ITEM"] = "Añadir objeto"
L["OPTIONS_ADD_DESC"] =
	"Selecciona cualquier objeto comerciable de tus bolsas para añadirlo a la configuración de comercio. Los objetos ya configurados o ligados al alma no aparecerán."
L["OPTIONS_ADD_SELECT"] = "Objetos disponibles"
L["OPTIONS_ADD_BUTTON"] = "Añadir a la configuración"
L["OPTIONS_ADD_EMPTY"] = "No se encontraron objetos comerciables en tus bolsas."

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["TAB_ANNOUNCEMENTS"] = "Anuncios"
L["OPTIONS_ANNOUNCEMENTS_DESC"] =
	"Water Dispenser puede crear una macro que anuncia lo que te queda por repartir. La macro elige el canal automáticamente (Decir sin grupo, Grupo en un grupo, Banda en una banda) y usa las cantidades más recientes de tus bolsas."
L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Activar macro de anuncio"
-- "- Dispenser" is the macro's literal name and is never translated.
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] =
	'Mantiene actualizada una macro específica del personaje llamada "- Dispenser" con tu lista de reparto actual, y elimina la macro cuando lo desactivas.'
-- "Enable Reserves" must match OPTIONS_ITEM_RESERVE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] =
	"Nada que anunciar. Configura objetos, repón tus bolsas o baja una reserva en Activar reservas."

-- Macro message template (%s is the item list) and the connector before the last list entry.
L["ANNOUNCEMENTS_BODY"] = "Tengo %s. ¡Abre comercio!"
L["ANNOUNCEMENTS_AND"] = "y"

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["OPTIONS_SUPPORT"] = "Comentarios y soporte"
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
