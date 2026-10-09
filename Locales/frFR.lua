local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "frFR")
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
L["ITEM_LOADING"] = "Chargement de l'ID : %d"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

--[[
	All player-facing chat prints live here, regardless of which feature emits them.
	In CHAT_LOADED, %s is the add-on version and the menu path is the game client's
	own labels.
]]
L["CHAT_LOADED"] =
	"Version %s. Les paramètres (y compris l'option pour désactiver ce message) se trouvent dans Options > AddOns > Water Dispenser. Vous aimez cet add-on ? Parlez-en à vos amis ! (="
L["CHAT_NO_TRADE"] = "Aucune fenêtre d'échange active."
L["CHAT_COMBAT_BLOCKED"] = "WoW bloque les échanges automatisés pendant le combat."
L["CHAT_OPTIONS_IN_COMBAT"] =
	"Par mesure de sécurité, l'interface des options ne peut pas être ouverte pendant le combat."
-- The item and its count are appended after the colon by the code.
L["CHAT_MISSING_STACK"] = "Manquant :"
--[[
	%s is the item's name, then the trade partner's name; %d is the Maximum per
	Player they have reached.
]]
L["CHAT_PLAYER_CAP_REACHED"] =
	"%s non ajouté : %s a déjà reçu %d de votre part. Les compteurs repartent à zéro quand vous vous déconnectez ou rechargez."
-- %s is the item's name; the first %d is the amount that could not be split off, the second the item's full stack size.
L["CHAT_SPLIT_NEEDS_FULL_STACK"] =
	"%s non ajouté : le jeu a refusé de séparer %d d'une pile. Réglez la quantité sur une pile complète (%d) pour le donner."
-- %s is the player's class name. "Dispensed Items" must match TAB_DISPENSED_ITEMS.
L["CHAT_NONE_ACTIVE_FOR_CLASS"] =
	"Aucun objet n'est configuré pour être distribué pendant que vous jouez un %s. Ouvrez Options > AddOns > Water Dispenser > Objets distribués pour activer des objets pour cette classe."
-- "- Dispenser" is the macro's literal name and is never translated.
L["CHAT_MACRO_DELETED"] = 'Macro d\'annonce "- Dispenser" supprimée.'
L["CHAT_MACRO_FULL"] =
	"Impossible de créer la macro d'annonce : tous les emplacements de macro du personnage sont utilisés."

--------------------------------------------------------------------------------
-- Player Tooltips
--------------------------------------------------------------------------------

L["TOOLTIP_OPEN_TRADE"] = "Lancez l'échange !"
-- %s is the Improved Healthstone talent's name from the client, then the warlock's rank out of its maximum.
L["TOOLTIP_HEALTHSTONE_TALENT"] = "%s %d/%d"

--------------------------------------------------------------------------------
-- Bag Item Tooltips
--------------------------------------------------------------------------------

-- Shown on a carried bag item the player has set up to give away.
L["TOOLTIP_WILL_DISPENSE"] = "Distribué lors des échanges."

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BUTTON_CLEAR"] = "Vider la fenêtre d'échange"
L["BUTTON_FILL"] = "Remplir la fenêtre d'échange"

--[[
	The silver status line under the trade panel's buttons. "Fill Trade Window" must
	match BUTTON_FILL. ADDED's %s is the window's contents, each FORMAT_ITEM_COUNT,
	joined like the announcement's list. In the rest, %s is an item or collection
	name unless noted.
]]
L["TRADE_STATUS_ADDED"] = "Ajouté : %s."
-- %d is how many short.
L["TRADE_STATUS_SHORT"] = "Il manque %d %s : pas assez dans vos sacs."
L["TRADE_STATUS_SHORT_RESERVE"] = "Il manque %d %s : votre réserve garde le reste."
L["TRADE_STATUS_DISPENSE_OFF"] =
	"Le remplissage automatique est désactivé. Remplir la fenêtre d'échange ajoute toujours vos quantités habituelles."
L["TRADE_STATUS_OFF_STRANGERS"] =
	"Le remplissage automatique est désactivé pour les inconnus. Remplir la fenêtre d'échange ajoute toujours vos quantités habituelles."
L["TRADE_STATUS_OFF_PARTY"] =
	"Le remplissage automatique est désactivé pour les membres du groupe. Remplir la fenêtre d'échange ajoute toujours vos quantités habituelles."
L["TRADE_STATUS_OFF_RAID"] =
	"Le remplissage automatique est désactivé pour les membres du raid. Remplir la fenêtre d'échange ajoute toujours vos quantités habituelles."
L["TRADE_STATUS_MASTER_LOOT"] =
	"Retenu tant que vous êtes maître du butin. Remplir la fenêtre d'échange ajoute toujours vos quantités habituelles."
-- The first %s is the partner's class name.
L["TRADE_STATUS_ZERO"] = "Réglé sur 0 pour %s : %s."
L["TRADE_STATUS_INSTANCE_ONLY"] = "%s n'est distribué qu'en instance."
L["TRADE_STATUS_GUILD_ONLY"] = "%s ne va qu'à votre guilde."
-- The partner's name, then the rank they can't use yet and its level.
L["TRADE_STATUS_LEVEL"] = "%s ne peut pas utiliser votre %s avant le niveau %d."
-- The partner's name first.
L["TRADE_STATUS_TOO_LOW"] = "%s a un niveau trop bas pour %s."
-- The partner's name first.
L["TRADE_STATUS_CAPPED"] = "%s a atteint votre maximum par joueur pour %s."
L["TRADE_STATUS_NONE_HELD"] = "%s : vous n'en avez aucun à donner."
L["TRADE_STATUS_CLEARED"] = "Vidé."
--[[
	A conjure button's tooltip, under the spell's name. MAKES: the item it makes,
	then the trade partner's name and level. LOWEST, when no rank fits the partner:
	the item only.
]]
L["TRADE_CONJURE_MAKES"] = "Crée %s, le meilleur que %s (niveau %d) peut utiliser."
L["TRADE_CONJURE_MAKES_LOWEST"] = "Crée %s, le rang le plus bas que vous connaissez."

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

--[[
	The tooltip's feature row reuses TAB_DISPENSE for its name and
	OPTIONS_DISPENSE_MASTER_DESC for its description; these are its state and click words.
]]
L["UI_ENABLED"] = "Activé"
L["UI_DISABLED"] = "Désactivé"
L["UI_LEFT_CLICK"] = "Clic gauche"
L["UI_TOGGLE"] = "Basculer"
L["MINIMAP_OPTIONS"] = "Options de Water Dispenser"
L["MINIMAP_OPTIONS_KEYBIND"] = "Maj + Clic central"
-- Heads the tooltip section listing what the player can give right now.
L["MINIMAP_DISPENSE_REPORT"] = "Rapport de distribution"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Distribution de consommables sans effort. Remplit automatiquement les fenêtres d'échange avec de l'eau, de la nourriture et des pierres de soins invoquées, au bon rang et en bonne quantité pour chaque joueur. Ajoutez n'importe quel objet, du Sable de sablier aux potions de résistance, et approvisionnez tout un raid en quelques secondes."

L["OPTIONS_WELCOME_MESSAGE"] = "Activer le message de bienvenue"
L["OPTIONS_WELCOME_MESSAGE_DESC"] =
	"Affiche un message de bienvenue d'une ligne dans votre fenêtre de discussion au chargement de Water Dispenser."
L["OPTIONS_MINIMAP"] = "Activer le bouton de la minicarte"
L["OPTIONS_MINIMAP_DESC"] = "Affiche le bouton Water Dispenser sur la minicarte."

L["OPTIONS_FEATURES_HEADER"] = "Fonctionnalités"

L["OPTIONS_COMMANDS_HEADER"] = "/Commandes"
L["OPTIONS_COMMAND"] = "/wd"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Ouvre l'interface des options de cet add-on."

--------------------------------------------------------------------------------
-- Options — Dispense
--------------------------------------------------------------------------------

-- Names the panel and the mini-map tooltip's feature row.
L["TAB_DISPENSE"] = "Distribuer"
L["OPTIONS_DISPENSE_MASTER"] = "Activer la distribution"
-- Also the panel's intro line and the mini-map tooltip's feature description.
L["OPTIONS_DISPENSE_MASTER_DESC"] =
	"Remplit automatiquement la fenêtre d'échange à son ouverture, selon vos paramètres."
L["OPTIONS_DISPENSE_SOLO"] = "Activer pour les inconnus"
L["OPTIONS_DISPENSE_SOLO_DESC"] =
	"Remplit automatiquement la fenêtre d'échange lors d'un échange avec quelqu'un qui n'est ni dans votre groupe ni dans votre raid."
L["OPTIONS_DISPENSE_GROUP"] = "Activer pour le groupe"
L["OPTIONS_DISPENSE_GROUP_DESC"] =
	"Remplit automatiquement la fenêtre d'échange lors d'un échange avec un membre du groupe."
L["OPTIONS_DISPENSE_RAID"] = "Activer pour le raid"
L["OPTIONS_DISPENSE_RAID_DESC"] =
	"Remplit automatiquement la fenêtre d'échange lors d'un échange avec un membre du raid."
-- The label says what it does; the tooltip only covers why it is needed and when it stands down.
L["OPTIONS_RESTACK"] = "Regrouper les piles partielles après un échange"
L["OPTIONS_RESTACK_DESC"] =
	"L'eau et la nourriture invoquées se posent dans un nouvel emplacement de sac à chaque incantation et le jeu ne les regroupe jamais, alors Water Dispenser les réunit une fois, juste après la fermeture d'une fenêtre d'échange, et jamais à un autre moment, ni en combat, ni tant que vous tenez quelque chose sur votre curseur."
L["OPTIONS_HOLD_MASTER_LOOT"] = "Retenir tant que vous êtes maître du butin"
-- "Fill Trade Window" must match BUTTON_FILL.
L["OPTIONS_HOLD_MASTER_LOOT_DESC"] =
	"Laisse la fenêtre d'échange vide tant que vous êtes maître du butin en instance, puisque ces échanges servent à distribuer le butin. Remplir la fenêtre d'échange ajoute toujours vos quantités habituelles."
L["OPTIONS_CONJURE_BUTTONS"] = "Afficher les boutons d'invocation à côté des échanges"
-- "Fill Trade Window" must match BUTTON_FILL.
L["OPTIONS_CONJURE_BUTTONS_DESC"] =
	"Ajoute sous Remplir la fenêtre d'échange des boutons qui invoquent de l'eau, de la nourriture ou une pierre de soins que votre partenaire d'échange peut utiliser à son niveau, et ce que vous créez va directement dans l'échange ouvert."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "Activer les avertissements quand vous êtes à court"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] =
	"Affiche une note dans votre fenêtre de discussion quand vous n'avez pas assez d'un objet configuré dans vos sacs pour donner la quantité définie."

-- Leads the silver line under a setting that shows the exact chat line it prints.
L["OPTIONS_EXAMPLE"] = "Exemple :"

L["OPTIONS_COMBAT_HEADER"] = "Combat"
L["OPTIONS_COMBAT_DESC"] = "WoW empêche les add-ons de déplacer des objets dans un échange pendant le combat."
L["OPTIONS_COMBAT_NOTIFY"] = "Activer les notifications quand la distribution est bloquée"
L["OPTIONS_COMBAT_NOTIFY_DESC"] =
	"Affiche une note dans votre fenêtre de discussion quand le combat empêche un échange de se remplir."

--------------------------------------------------------------------------------
-- Options — Inventory Tooltips
--------------------------------------------------------------------------------

L["TAB_INVENTORY_TOOLTIPS"] = "Infobulles d'inventaire"
L["OPTIONS_TOOLTIPS_DESC"] =
	"Affiche dans les infobulles de joueur ce que les membres du groupe qui utilisent Water Dispenser ont configuré à distribuer, et signale dans vos propres sacs les objets que vous distribuez."
L["OPTIONS_SHOW_INVENTORY"] = "Afficher l'inventaire dans les infobulles de joueur"
L["OPTIONS_SHOW_INVENTORY_DESC"] =
	"Ajoute un bloc Water Dispenser aux infobulles de joueur listant ce qu'ils ont configuré à distribuer et combien ils peuvent en donner, le vôtre s'affichant toujours, en groupe ou non."
L["OPTIONS_BAG_TOOLTIPS"] = "Afficher les infobulles de sac pour les objets distribués"
L["OPTIONS_BAG_TOOLTIPS_DESC"] =
	"Ajoute une ligne Water Dispenser à l'infobulle d'un objet de vos sacs quand cet objet est configuré pour être distribué, afin de voir d'un coup d'œil ce que l'add-on remettra."
L["OPTIONS_SHARE_INVENTORY"] = "Partager mon inventaire"
L["OPTIONS_SHARE_INVENTORY_DESC"] =
	"Indique à votre groupe ou raid ce que vous avez à donner, pour que cela s'affiche quand ils vous survolent. Ne publie jamais rien dans la discussion et n'atteint personne en dehors de votre groupe. Le désactiver vous laisse toujours voir les leurs."

--------------------------------------------------------------------------------
-- Options — Dispensed Items
--------------------------------------------------------------------------------

L["TAB_DISPENSED_ITEMS"] = "Objets distribués"
L["OPTIONS_ITEMS_DESC"] =
	"Configurez combien distribuer de chaque objet. Les quantités se comptent en objets individuels, donc 20 eaux signifient 20 eaux, et 1 potion signifie 1 potion. Une pile est découpée à la quantité exacte s'il le faut."
-- "Add an Item" must match OPTIONS_ADD_ITEM.
L["OPTIONS_ITEMS_EMPTY"] =
	'Aucun objet configuré. Sélectionnez "Ajouter un objet" dans la liste pour ajouter n\'importe quel objet échangeable de vos sacs.'

--[[
	The silver line opening an item's page while nothing of it would go out. In
	OTHER_CLASS, %s is the player's class twice, then OPTIONS_ITEM_PLAYER_CLASSES;
	in ALL_ZERO, %s is OPTIONS_ITEM_EVERYONE.
]]
L["OPTIONS_ITEM_STATUS_OTHER_CLASS"] = "Non distribué pendant que vous jouez un %s. Cochez %s sous %s."
L["OPTIONS_ITEM_STATUS_ALL_ZERO"] =
	"Rien ne part encore : toutes les quantités sont à 0. Saisissez un nombre dans %s pour commencer."

L["OPTIONS_ITEM_AMOUNTS"] = "Quantités"
L["OPTIONS_ITEM_AMOUNTS_DESC"] =
	"Choisissez combien chaque classe reçoit lors d'un échange, selon qu'elle est inconnue, dans votre groupe ou dans votre raid. Comptés en objets individuels, pas en piles. Zéro signifie qu'elle ne recevra jamais cet objet."
L["OPTIONS_ITEM_EVERYONE"] = "Tous"
-- "Apply" must match OPTIONS_ITEM_APPLY.
L["OPTIONS_ITEM_EVERYONE_DESC"] =
	"Définit cette quantité pour toutes les classes d'un coup quand vous appuyez sur Entrée ou cliquez sur Appliquer, et reste vide quand les classes ci-dessous ne sont pas toutes d'accord."
-- The accept button inside every number box in this panel.
L["OPTIONS_ITEM_APPLY"] = "Appliquer"
-- %d is the highest amount this item accepts, which is 1 for anything unique.
L["OPTIONS_ITEM_COUNT_TOO_HIGH"] = "C'est plus que ce que vous pouvez donner de cet objet. Le maximum est %d."
L["OPTIONS_ITEM_COUNT_INVALID"] = "Saisissez un nombre d'objets."
L["OPTIONS_ITEM_SETTINGS"] = "Paramètres de l'objet"
L["OPTIONS_ITEM_DISTRIBUTE"] = "Attribuer"
-- "In Instance" must match OPTIONS_ITEM_DISTRIBUTE_INSTANCE.
L["OPTIONS_ITEM_DISTRIBUTE_DESC"] =
	"Définit où cet objet est distribué. En instance couvre les donjons, les raids, les champs de bataille et les arènes. Partout ailleurs, l'objet n'est jamais échangé, annoncé ni affiché dans votre infobulle."
--[[
	Dropdown entries, looked up as OPTIONS_ITEM_DISTRIBUTE_ plus the stored value in
	capitals ("Always", "Instance"), so no code names these keys in full.
]]
L["OPTIONS_ITEM_DISTRIBUTE_ALWAYS"] = "Toujours"
L["OPTIONS_ITEM_DISTRIBUTE_INSTANCE"] = "En instance"
L["OPTIONS_ITEM_GUILDIES_ONLY"] = "Guilde uniquement"
L["OPTIONS_ITEM_GUILDIES_ONLY_DESC"] = "Ignore cet objet quand votre partenaire d'échange n'est pas dans votre guilde."
-- Panel line under the toggle, not a tooltip: it names the guild, which no fixed string can. %s is the player's guild.
L["OPTIONS_ITEM_GUILDIES_ONLY_HELP"] = "Donner uniquement aux membres de <%s>."
L["OPTIONS_ITEM_GUILDIES_ONLY_NO_GUILD"] = "Vous n'êtes dans aucune guilde, donc ceci ne donne l'objet à personne."
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Prendre en compte le niveau requis de l'objet"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] =
	"Ignore cet objet quand votre partenaire d'échange est en dessous du niveau requis par l'objet."
L["OPTIONS_ITEM_RESERVE"] = "Activer les réserves"
L["OPTIONS_ITEM_RESERVE_DESC"] =
	"Garde toujours au moins cette quantité dans vos sacs, la distribution, votre infobulle de joueur et la macro d'annonce considérant tout ce qui dépasse ce nombre comme disponible à donner."
L["OPTIONS_ITEM_PLAYER_CAP"] = "Activer le maximum par joueur"
L["OPTIONS_ITEM_PLAYER_CAP_DESC"] =
	"Arrête de donner cet objet à quelqu'un une fois qu'il en a reçu autant de votre part. Les compteurs repartent à zéro quand vous vous déconnectez, rechargez ou modifiez les quantités de cet objet."
-- The label carries the meaning on its own; the tooltip only says why you'd switch it off.
L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "Inclure la quantité dans l'infobulle de joueur et la macro d'annonce"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] =
	"Désactivé nomme l'objet sans nombre à côté, ce qui se lit mieux pour un objet dont vous ne portez jamais qu'un exemplaire, comme une pierre de soins."
L["OPTIONS_ITEM_PLAYER_CLASSES"] = "Distribuer uniquement en jouant ces classes"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] =
	"Remplit les échanges, inscrit cet objet dans la macro d'annonce et l'affiche dans votre infobulle de joueur uniquement si la classe de votre personnage est sélectionnée ci-dessous."
L["OPTIONS_ITEM_REMOVE"] = "Supprimer l'objet"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "Retirer cet objet de vos objets distribués ?"

L["OPTIONS_SCOPE_SOLO"] = "Inconnus"
L["OPTIONS_SCOPE_GROUP"] = "Groupe"
L["OPTIONS_SCOPE_RAID"] = "Raid"

L["OPTIONS_ADD_ITEM"] = "Ajouter un objet"
L["OPTIONS_ADD_DESC"] =
	"Sélectionnez n'importe quel objet échangeable dans vos sacs pour l'ajouter à vos objets distribués. Les objets déjà configurés ou liés ne s'affichent pas."
L["OPTIONS_ADD_SELECT"] = "Objets disponibles"
L["OPTIONS_ADD_BUTTON"] = "Ajouter aux objets distribués"
L["OPTIONS_ADD_EMPTY"] = "Aucun objet échangeable trouvé dans vos sacs."

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["TAB_ANNOUNCEMENTS"] = "Annonces"
L["OPTIONS_ANNOUNCEMENTS_DESC"] =
	"Water Dispenser peut créer une macro qui annonce ce qu'il vous reste à distribuer. La macro choisit le bon canal automatiquement (Dire hors groupe, Groupe en groupe, Raid en raid, Instance dans un groupe de donjon ou de champ de bataille) et utilise les quantités les plus récentes de vos sacs."
L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Activer la macro d'annonce"
-- "- Dispenser" is the macro's literal name and is never translated.
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] =
	'Maintient à jour une macro propre au personnage nommée "- Dispenser" avec vos objets distribués actuels, et supprime la macro quand vous la désactivez.'
-- "Enable Reserves" must match OPTIONS_ITEM_RESERVE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] =
	"Rien à annoncer. Configurez des objets, remplissez vos sacs ou abaissez une réserve dans Activer les réserves."
-- "Enable Dispense" must match OPTIONS_DISPENSE_MASTER, "Dispense" must match TAB_DISPENSE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DISPENSE_OFF"] =
	"Rien à annoncer tant qu'Activer la distribution est désactivé, dans l'onglet Distribuer."

-- Macro message template (%s is the item list) and the connector before the last list entry.
L["ANNOUNCEMENTS_BODY"] = "J'ai %s. Lancez l'échange !"
L["ANNOUNCEMENTS_AND"] = "et"

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["OPTIONS_SUPPORT"] = "Commentaires et assistance"
-- The General panel's last line. %s is the version.
L["OPTIONS_VERSION"] = "Version %s"
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"
L["SUPPORT_WAGO"] = "Wago"
