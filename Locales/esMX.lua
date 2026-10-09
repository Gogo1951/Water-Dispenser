local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "esMX")
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
L["ITEM_LOADING"] = "Cargando ID: %d"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

--[[
	All player-facing chat prints live here, regardless of which feature emits them.
	In CHAT_LOADED, %s is the add-on version and the menu path is the game client's
	own labels.
]]
L["CHAT_LOADED"] =
	"Versión %s. Los ajustes (incluyendo la opción de desactivar este mensaje) se encuentran en Opciones > Accesorios > Water Dispenser. ¿Te gusta el accesorio? ¡Cuéntaselo a un amigo! (="
L["CHAT_NO_TRADE"] = "No hay ninguna ventana de comercio activa."
L["CHAT_COMBAT_BLOCKED"] = "WoW bloquea los intercambios automatizados durante el combate."
L["CHAT_OPTIONS_IN_COMBAT"] = "Como medida de seguridad, la interfaz de opciones no puede abrirse durante el combate."
-- The item and its count are appended after the colon by the code.
L["CHAT_MISSING_STACK"] = "Falta:"
--[[
	%s is the item's name, then the trade partner's name; %d is the Maximum per
	Player they have reached.
]]
L["CHAT_PLAYER_CAP_REACHED"] =
	"%s no añadido: %s ya ha recibido %d de ti. Los recuentos se reinician al cerrar sesión o recargar."
-- %s is the item's name; the first %d is the amount that could not be split off, the second the item's full stack size.
L["CHAT_SPLIT_NEEDS_FULL_STACK"] =
	"%s no añadido: el juego no quiso separar %d de una pila. Fija la cantidad en una pila completa (%d) para entregarlo."
-- %s is the player's class name. "Dispensed Items" must match TAB_DISPENSED_ITEMS.
L["CHAT_NONE_ACTIVE_FOR_CLASS"] =
	"No hay objetos configurados para dispensar mientras juegas con un %s. Abre Opciones > Accesorios > Water Dispenser > Objetos dispensados para habilitar objetos para esta clase."
-- "- Dispenser" is the macro's literal name and is never translated.
L["CHAT_MACRO_DELETED"] = 'Macro de anuncio "- Dispenser" eliminada.'
L["CHAT_MACRO_FULL"] = "No se pudo crear la macro de anuncio: todas las ranuras de macro del personaje están en uso."

--------------------------------------------------------------------------------
-- Player Tooltips
--------------------------------------------------------------------------------

L["TOOLTIP_OPEN_TRADE"] = "¡Abre comercio!"
-- %s is the Improved Healthstone talent's name from the client, then the warlock's rank out of its maximum.
L["TOOLTIP_HEALTHSTONE_TALENT"] = "%s %d/%d"

--------------------------------------------------------------------------------
-- Bag Item Tooltips
--------------------------------------------------------------------------------

-- Shown on a carried bag item the player has set up to give away.
L["TOOLTIP_WILL_DISPENSE"] = "Se reparte en los comercios."

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BUTTON_CLEAR"] = "Limpiar ventana de comercio"
L["BUTTON_FILL"] = "Llenar ventana de comercio"

--[[
	The silver status line under the trade panel's buttons. "Fill Trade Window" must
	match BUTTON_FILL. ADDED's %s is the window's contents, each FORMAT_ITEM_COUNT,
	joined like the announcement's list. In the rest, %s is an item or collection
	name unless noted.
]]
L["TRADE_STATUS_ADDED"] = "Añadido: %s."
-- %d is how many short.
L["TRADE_STATUS_SHORT"] = "Faltan %d %s: no hay suficientes en tus bolsas."
L["TRADE_STATUS_SHORT_RESERVE"] = "Faltan %d %s: tu reserva guarda el resto."
L["TRADE_STATUS_DISPENSE_OFF"] =
	"El llenado automático está desactivado. Llenar ventana de comercio sigue añadiendo tus cantidades habituales."
L["TRADE_STATUS_OFF_STRANGERS"] =
	"El llenado automático está desactivado para desconocidos. Llenar ventana de comercio sigue añadiendo tus cantidades habituales."
L["TRADE_STATUS_OFF_PARTY"] =
	"El llenado automático está desactivado para miembros del grupo. Llenar ventana de comercio sigue añadiendo tus cantidades habituales."
L["TRADE_STATUS_OFF_RAID"] =
	"El llenado automático está desactivado para miembros de la banda. Llenar ventana de comercio sigue añadiendo tus cantidades habituales."
L["TRADE_STATUS_MASTER_LOOT"] =
	"Retenido mientras eres maestro despojador. Llenar ventana de comercio sigue añadiendo tus cantidades habituales."
-- The first %s is the partner's class name.
L["TRADE_STATUS_ZERO"] = "Fijado en 0 para %s: %s."
L["TRADE_STATUS_INSTANCE_ONLY"] = "%s solo se reparte en instancias."
L["TRADE_STATUS_GUILD_ONLY"] = "%s solo va para tu hermandad."
-- The partner's name, then the rank they can't use yet and its level.
L["TRADE_STATUS_LEVEL"] = "%s no puede usar tu %s hasta el nivel %d."
-- The partner's name first.
L["TRADE_STATUS_TOO_LOW"] = "%s tiene un nivel demasiado bajo para %s."
-- The partner's name first.
L["TRADE_STATUS_CAPPED"] = "%s ya ha alcanzado tu máximo por jugador de %s."
L["TRADE_STATUS_NONE_HELD"] = "No tienes %s para dar."
L["TRADE_STATUS_CLEARED"] = "Vaciado."
--[[
	A conjure button's tooltip, under the spell's name. MAKES: the item it makes,
	then the trade partner's name and level. LOWEST, when no rank fits the partner:
	the item only.
]]
L["TRADE_CONJURE_MAKES"] = "Crea %s, lo mejor que %s (nivel %d) puede usar."
L["TRADE_CONJURE_MAKES_LOWEST"] = "Crea %s, el rango más bajo que conoces."

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

--[[
	The tooltip's feature row reuses TAB_DISPENSE for its name and
	OPTIONS_DISPENSE_MASTER_DESC for its description; these are its state and click words.
]]
L["UI_ENABLED"] = "Activado"
L["UI_DISABLED"] = "Desactivado"
L["UI_LEFT_CLICK"] = "Clic izquierdo"
L["UI_TOGGLE"] = "Alternar"
L["MINIMAP_OPTIONS"] = "Opciones de Water Dispenser"
L["MINIMAP_OPTIONS_KEYBIND"] = "Mayús + Clic central"
-- Heads the tooltip section listing what the player can give right now.
L["MINIMAP_DISPENSE_REPORT"] = "Informe de reparto"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Reparto de consumibles sin esfuerzo. Llena automáticamente las ventanas de comercio con agua, comida y piedras de salud conjuradas, del rango y la cantidad adecuados para cada jugador. Añade cualquier objeto, desde Arena de reloj de arena hasta pociones de resistencia, y abastece a toda una banda en segundos."

L["OPTIONS_WELCOME_MESSAGE"] = "Activar mensaje de bienvenida"
L["OPTIONS_WELCOME_MESSAGE_DESC"] =
	"Muestra un saludo de una línea en tu ventana de chat cuando Water Dispenser se carga."
L["OPTIONS_MINIMAP"] = "Activar botón del minimapa"
L["OPTIONS_MINIMAP_DESC"] = "Muestra el botón de Water Dispenser en el minimapa."

L["OPTIONS_FEATURES_HEADER"] = "Funciones"

L["OPTIONS_COMMANDS_HEADER"] = "/Comandos"
L["OPTIONS_COMMAND"] = "/wd"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Abre la interfaz de opciones de este accesorio."

--------------------------------------------------------------------------------
-- Options — Dispense
--------------------------------------------------------------------------------

-- Names the panel and the mini-map tooltip's feature row.
L["TAB_DISPENSE"] = "Dispensar"
L["OPTIONS_DISPENSE_MASTER"] = "Activar dispensado"
-- Also the panel's intro line and the mini-map tooltip's feature description.
L["OPTIONS_DISPENSE_MASTER_DESC"] =
	"Llena automáticamente la ventana de comercio al abrirse un intercambio, según tus ajustes."
L["OPTIONS_DISPENSE_SOLO"] = "Activar para desconocidos"
L["OPTIONS_DISPENSE_SOLO_DESC"] =
	"Llena la ventana de comercio automáticamente al comerciar con alguien que no está en tu grupo ni en tu banda."
L["OPTIONS_DISPENSE_GROUP"] = "Activar para grupo"
L["OPTIONS_DISPENSE_GROUP_DESC"] =
	"Llena la ventana de comercio automáticamente al comerciar con un miembro del grupo."
L["OPTIONS_DISPENSE_RAID"] = "Activar para banda"
L["OPTIONS_DISPENSE_RAID_DESC"] =
	"Llena la ventana de comercio automáticamente al comerciar con un miembro de la banda."
-- The label says what it does; the tooltip only covers why it is needed and when it stands down.
L["OPTIONS_RESTACK"] = "Combinar pilas parciales tras un comercio"
L["OPTIONS_RESTACK_DESC"] =
	"El agua y la comida conjuradas caen en una ranura nueva de la bolsa con cada lanzamiento y el juego nunca las vuelve a juntar, así que Water Dispenser las combina una vez, justo después de que se cierre una ventana de comercio, y nunca en ningún otro momento, ni en combate ni mientras llevas algo en el cursor."
L["OPTIONS_HOLD_MASTER_LOOT"] = "Retener mientras eres maestro despojador"
-- "Fill Trade Window" must match BUTTON_FILL.
L["OPTIONS_HOLD_MASTER_LOOT_DESC"] =
	"Deja vacía la ventana de comercio mientras eres maestro despojador en una instancia, ya que esos comercios sirven para repartir botín. Llenar ventana de comercio sigue añadiendo tus cantidades habituales."
L["OPTIONS_CONJURE_BUTTONS"] = "Mostrar botones de conjuración junto a los comercios"
-- "Fill Trade Window" must match BUTTON_FILL.
L["OPTIONS_CONJURE_BUTTONS_DESC"] =
	"Añade botones bajo Llenar ventana de comercio que conjuran agua, comida o una piedra de salud que tu compañero de comercio puede usar a su nivel, y lo que creas va directo al comercio abierto."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "Activar avisos cuando te quedes corto"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] =
	"Muestra un aviso en tu ventana de chat cuando no tienes suficiente de un objeto configurado en tus bolsas para dar la cantidad que fijaste."

-- Leads the silver line under a setting that shows the exact chat line it prints.
L["OPTIONS_EXAMPLE"] = "Ejemplo:"

L["OPTIONS_COMBAT_HEADER"] = "Combate"
L["OPTIONS_COMBAT_DESC"] = "WoW impide que los accesorios muevan objetos a un comercio durante el combate."
L["OPTIONS_COMBAT_NOTIFY"] = "Activar notificaciones cuando el dispensado esté bloqueado"
L["OPTIONS_COMBAT_NOTIFY_DESC"] =
	"Muestra un aviso en tu ventana de chat cuando el combate impide que se llene un comercio."

--------------------------------------------------------------------------------
-- Options — Inventory Tooltips
--------------------------------------------------------------------------------

L["TAB_INVENTORY_TOOLTIPS"] = "Descripciones de inventario"
L["OPTIONS_TOOLTIPS_DESC"] =
	"Muestra en las descripciones de jugador lo que los miembros del grupo que usan Water Dispenser tienen configurado para repartir, y marca en tus propias bolsas los objetos que tú repartes."
L["OPTIONS_SHOW_INVENTORY"] = "Mostrar inventario en las descripciones de jugador"
L["OPTIONS_SHOW_INVENTORY_DESC"] =
	"Añade un bloque de Water Dispenser a las descripciones de jugador con lo que tienen configurado para repartir y cuántos pueden dar, mostrándose el tuyo siempre, estés en grupo o no."
L["OPTIONS_BAG_TOOLTIPS"] = "Mostrar descripciones de bolsa para los objetos dispensados"
L["OPTIONS_BAG_TOOLTIPS_DESC"] =
	"Añade una línea de Water Dispenser a la descripción de un objeto de tus bolsas cuando ese objeto está configurado para repartirse, para que veas de un vistazo qué entregará el accesorio."
L["OPTIONS_SHARE_INVENTORY"] = "Compartir mi inventario"
L["OPTIONS_SHARE_INVENTORY_DESC"] =
	"Indica a tu grupo o banda lo que tienes para regalar, para que aparezca cuando pasen el ratón sobre ti. Nunca publica en el chat ni llega a nadie fuera de tu grupo. Al desactivarlo sigues viendo lo de los demás."

--------------------------------------------------------------------------------
-- Options — Dispensed Items
--------------------------------------------------------------------------------

L["TAB_DISPENSED_ITEMS"] = "Objetos dispensados"
L["OPTIONS_ITEMS_DESC"] =
	"Configura cuántos de cada objeto dispensar. Las cantidades se cuentan en objetos individuales, así que 20 aguas son 20 aguas, y 1 poción es 1 poción. Una pila se divide hasta la cantidad exacta si hace falta."
-- "Add an Item" must match OPTIONS_ADD_ITEM.
L["OPTIONS_ITEMS_EMPTY"] =
	'No hay objetos configurados. Selecciona "Añadir objeto" en la lista para añadir cualquier objeto comerciable de tus bolsas.'

--[[
	The silver line opening an item's page while nothing of it would go out. In
	OTHER_CLASS, %s is the player's class twice, then OPTIONS_ITEM_PLAYER_CLASSES;
	in ALL_ZERO, %s is OPTIONS_ITEM_EVERYONE.
]]
L["OPTIONS_ITEM_STATUS_OTHER_CLASS"] = "No se reparte mientras juegas con un %s. Marca %s en %s."
L["OPTIONS_ITEM_STATUS_ALL_ZERO"] =
	"Todavía no sale nada: todas las cantidades están en 0. Escribe un número en %s para empezar."

L["OPTIONS_ITEM_AMOUNTS"] = "Cantidades"
L["OPTIONS_ITEM_AMOUNTS_DESC"] =
	"Elige cuántos recibe cada clase al comerciar con ella, según si es un desconocido, está en tu grupo o en tu banda. Se cuentan objetos individuales, no pilas. Cero significa que nunca recibirán este objeto."
L["OPTIONS_ITEM_EVERYONE"] = "Todos"
-- "Apply" must match OPTIONS_ITEM_APPLY.
L["OPTIONS_ITEM_EVERYONE_DESC"] =
	"Fija esta cantidad para todas las clases a la vez cuando pulsas Intro o haces clic en Aplicar, y aparece en blanco cuando las clases de abajo no coinciden."
-- The accept button inside every number box in this panel.
L["OPTIONS_ITEM_APPLY"] = "Aplicar"
-- %d is the highest amount this item accepts, which is 1 for anything unique.
L["OPTIONS_ITEM_COUNT_TOO_HIGH"] = "Eso es más de lo que puedes dar de este objeto. El máximo es %d."
L["OPTIONS_ITEM_COUNT_INVALID"] = "Introduce un número de objetos."
L["OPTIONS_ITEM_SETTINGS"] = "Ajustes del objeto"
L["OPTIONS_ITEM_DISTRIBUTE"] = "Repartir"
-- "In Instance" must match OPTIONS_ITEM_DISTRIBUTE_INSTANCE.
L["OPTIONS_ITEM_DISTRIBUTE_DESC"] =
	"Establece dónde se reparte este objeto. En instancia abarca mazmorras, bandas, campos de batalla y arenas. En cualquier otro lugar, el objeto nunca se comercia, se anuncia ni se muestra en tu descripción."
--[[
	Dropdown entries, looked up as OPTIONS_ITEM_DISTRIBUTE_ plus the stored value in
	capitals ("Always", "Instance"), so no code names these keys in full.
]]
L["OPTIONS_ITEM_DISTRIBUTE_ALWAYS"] = "Siempre"
L["OPTIONS_ITEM_DISTRIBUTE_INSTANCE"] = "En instancia"
L["OPTIONS_ITEM_GUILDIES_ONLY"] = "Solo hermandad"
L["OPTIONS_ITEM_GUILDIES_ONLY_DESC"] = "Omite este objeto cuando tu compañero de comercio no está en tu hermandad."
-- Panel line under the toggle, not a tooltip: it names the guild, which no fixed string can. %s is the player's guild.
L["OPTIONS_ITEM_GUILDIES_ONLY_HELP"] = "Dar solo a miembros de <%s>."
L["OPTIONS_ITEM_GUILDIES_ONLY_NO_GUILD"] = "No estás en ninguna hermandad, así que esto no da el objeto a nadie."
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Tener en cuenta el nivel requerido del objeto"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] =
	"Omite este objeto cuando tu compañero de comercio está por debajo del nivel requerido del objeto."
L["OPTIONS_ITEM_RESERVE"] = "Activar reservas"
L["OPTIONS_ITEM_RESERVE_DESC"] =
	"Guarda siempre al menos esta cantidad en tus bolsas, y el dispensado, tu descripción de jugador y la macro de anuncio tratan todo lo que exceda ese número como disponible para regalar."
L["OPTIONS_ITEM_PLAYER_CAP"] = "Activar máximo por jugador"
L["OPTIONS_ITEM_PLAYER_CAP_DESC"] =
	"Deja de dar este objeto a alguien cuando ya ha recibido esta cantidad de ti. Los recuentos se reinician al cerrar sesión, recargar o cambiar las cantidades de este objeto."
-- The label carries the meaning on its own; the tooltip only says why you'd switch it off.
L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "Incluir cantidad en la descripción de jugador y la macro de anuncio"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] =
	"Desactivado nombra el objeto sin número al lado, lo que queda mejor para algo de lo que solo llevas uno, como una piedra de salud."
L["OPTIONS_ITEM_PLAYER_CLASSES"] = "Dispensar solo al jugar con estas clases"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] =
	"Llena comercios, añade este objeto a la macro de anuncio y lo muestra en tu descripción de jugador solo cuando la clase de tu personaje esté seleccionada abajo."
L["OPTIONS_ITEM_REMOVE"] = "Eliminar objeto"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "¿Eliminar este objeto de tus objetos dispensados?"

L["OPTIONS_SCOPE_SOLO"] = "Desconocidos"
L["OPTIONS_SCOPE_GROUP"] = "Grupo"
L["OPTIONS_SCOPE_RAID"] = "Banda"

L["OPTIONS_ADD_ITEM"] = "Añadir objeto"
L["OPTIONS_ADD_DESC"] =
	"Selecciona cualquier objeto comerciable de tus bolsas para añadirlo a tus objetos dispensados. Los objetos ya configurados o ligados al alma no aparecerán."
L["OPTIONS_ADD_SELECT"] = "Objetos disponibles"
L["OPTIONS_ADD_BUTTON"] = "Añadir a objetos dispensados"
L["OPTIONS_ADD_EMPTY"] = "No se encontraron objetos comerciables en tus bolsas."

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["TAB_ANNOUNCEMENTS"] = "Anuncios"
L["OPTIONS_ANNOUNCEMENTS_DESC"] =
	"Water Dispenser puede crear una macro que anuncia lo que te queda por repartir. La macro elige el canal automáticamente (Decir sin grupo, Grupo en un grupo, Banda en una banda, Instancia en un grupo de mazmorra o campo de batalla) y usa las cantidades más recientes de tus bolsas."
L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Activar macro de anuncio"
-- "- Dispenser" is the macro's literal name and is never translated.
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] =
	'Mantiene actualizada una macro específica del personaje llamada "- Dispenser" con tus objetos dispensados actuales, y elimina la macro cuando lo desactivas.'
-- "Enable Reserves" must match OPTIONS_ITEM_RESERVE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] =
	"Nada que anunciar. Configura objetos, repón tus bolsas o baja una reserva en Activar reservas."
-- "Enable Dispense" must match OPTIONS_DISPENSE_MASTER, "Dispense" must match TAB_DISPENSE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DISPENSE_OFF"] =
	"Nada que anunciar mientras Activar dispensado esté desactivado, en la pestaña Dispensar."

-- Macro message template (%s is the item list) and the connector before the last list entry.
L["ANNOUNCEMENTS_BODY"] = "Tengo %s. ¡Abre comercio!"
L["ANNOUNCEMENTS_AND"] = "y"

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["OPTIONS_SUPPORT"] = "Comentarios y soporte"
-- The General panel's last line. %s is the version.
L["OPTIONS_VERSION"] = "Versión %s"
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"
L["SUPPORT_WAGO"] = "Wago"
