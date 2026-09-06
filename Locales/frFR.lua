local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "frFR")
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

--[[
	All player-facing chat prints live here, regardless of which feature emits them.
	%s is the add-on version; the menu path is the game client's own labels.
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
	%s is the item's name, %d the Maximum per Session it has hit.
	"Maximum per Session" must match OPTIONS_ITEM_SESSION_CAP.
]]
L["CHAT_SESSION_CAP_REACHED"] =
	"%s non ajouté : il a déjà reçu ses %d cette session. Modifiez Maximum par session, ou rechargez pour réinitialiser."
-- %s is the item's name, %d the amount that could not be split off.
L["CHAT_SPLIT_REFUSED"] =
	"%s non ajouté : ce client a refusé de séparer %d d'une pile, et donner une pile entière à la place donnerait bien plus que ce que vous demandiez. Réglez la quantité de cet objet sur une pile entière pour l'échanger."
-- %s is the player's class name. "Dispensed Items" must match TAB_DISPENSED_ITEMS.
L["CHAT_NONE_ACTIVE_FOR_CLASS"] =
	"Aucun objet n'est configuré pour être distribué pendant que vous jouez un %s. Ouvrez Options > Objets distribués pour activer des objets pour cette classe."
-- "- Dispenser" is the macro's literal name and is never translated.
L["CHAT_MACRO_DELETED"] = 'Macro d\'annonce "- Dispenser" supprimée.'
L["CHAT_MACRO_FULL"] = "Impossible de créer la macro : tous les emplacements de macro du personnage sont utilisés."

--------------------------------------------------------------------------------
-- Player Tooltips
--------------------------------------------------------------------------------

L["TOOLTIP_OPEN_TRADE"] = "Lancez l'échange !"
-- %d/%d is the warlock's Improved Healthstone rank out of its maximum.
L["TOOLTIP_HEALTHSTONE"] = "Pierre de soins (Rang %d/%d)"

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BUTTON_CLEAR"] = "Vider la fenêtre d'échange"
L["BUTTON_FILL"] = "Remplir la fenêtre d'échange"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

-- The tooltip's feature row reuses TAB_DISPENSE for its name; these are its state and click words.
L["UI_ENABLED"] = "Activé"
L["UI_DISABLED"] = "Désactivé"
L["UI_LEFT_CLICK"] = "Clic gauche"
L["UI_TOGGLE"] = "Basculer"
L["MINIMAP_OPTIONS"] = "Options de Water Dispenser"
L["MINIMAP_OPTIONS_KEYBIND"] = "Maj + Clic central"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"La distribution de consommables sans effort. Remplit automatiquement la fenêtre d'échange avec de l'eau, de la nourriture et des pierres de soins. Ajoutez n'importe quel objet, comme du Sable de sablier ou des potions de résistance, pour le distribuer à votre raid."

L["OPTIONS_WELCOME_MESSAGE"] = "Activer le message de bienvenue"
L["OPTIONS_WELCOME_MESSAGE_DESC"] =
	"Affiche un message de bienvenue d'une ligne dans votre fenêtre de discussion au chargement de Water Dispenser."
L["OPTIONS_MINIMAP"] = "Activer le bouton de la minicarte"
L["OPTIONS_MINIMAP_DESC"] = "Affiche le bouton Water Dispenser sur la minicarte."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "Activer les avertissements quand vous êtes à court"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] =
	"Affiche une note dans votre fenêtre de discussion quand vous n'avez pas assez d'un objet configuré dans vos sacs pour donner la quantité définie."
-- The label says what it does; the tooltip only covers why it is needed and when it stands down.
L["OPTIONS_RESTACK"] = "Regrouper automatiquement les piles partielles dans les sacs"
L["OPTIONS_RESTACK_DESC"] =
	"L'eau et la nourriture invoquées se posent dans un nouvel emplacement de sac à chaque incantation et le jeu ne les regroupe jamais, bien que cela ne se déclenche jamais en combat, pendant un échange ouvert, ni tant que vous tenez quelque chose sur votre curseur."

L["OPTIONS_COMMANDS_HEADER"] = "/Commandes"
L["OPTIONS_COMMAND"] = "/wd"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Ouvre l'interface des options de cet add-on."

-- Names the panel, its section header, and the mini-map tooltip's feature row.
L["TAB_DISPENSE"] = "Distribuer"
L["OPTIONS_DISPENSE_DESC"] = "Remplit automatiquement la fenêtre d'échange à son ouverture."
L["OPTIONS_DISPENSE_MASTER"] = "Activer la distribution"
L["OPTIONS_DISPENSE_MASTER_DESC"] = "Remplit automatiquement la fenêtre d'échange selon vos paramètres."
L["OPTIONS_DISPENSE_SOLO"] = "Activer pour les inconnus"
L["OPTIONS_DISPENSE_SOLO_DESC"] =
	"Remplit automatiquement la fenêtre d'échange lors d'un échange avec quelqu'un qui n'est ni dans votre groupe ni dans votre raid."
L["OPTIONS_DISPENSE_GROUP"] = "Activer pour le groupe"
L["OPTIONS_DISPENSE_GROUP_DESC"] =
	"Remplit automatiquement la fenêtre d'échange lors d'un échange avec un membre du groupe."
L["OPTIONS_DISPENSE_RAID"] = "Activer pour le raid"
L["OPTIONS_DISPENSE_RAID_DESC"] =
	"Remplit automatiquement la fenêtre d'échange lors d'un échange avec un membre du raid."

L["TAB_INVENTORY_TOOLTIPS"] = "Infobulles d'inventaire"
L["OPTIONS_TOOLTIPS_DESC"] =
	"Affiche l'inventaire à distribuer dans les infobulles de joueur des membres du groupe qui utilisent Water Dispenser."
L["OPTIONS_SHOW_INVENTORY"] = "Afficher l'inventaire dans les infobulles de joueur"
L["OPTIONS_SHOW_INVENTORY_DESC"] =
	"Ajoute un bloc Water Dispenser aux infobulles de joueur listant ce qu'ils ont configuré à distribuer et combien ils en portent, le vôtre s'affichant toujours, en groupe ou non."
L["OPTIONS_SHARE_INVENTORY"] = "Partager mon inventaire"
L["OPTIONS_SHARE_INVENTORY_DESC"] =
	"Indique à votre groupe et à votre raid ce que vous portez afin que votre inventaire apparaisse quand ils vous survolent, sans rien publier dans la discussion ni informer quiconque en dehors de votre groupe, et le désactiver vous laisse toujours consulter le leur."

L["OPTIONS_COMBAT_HEADER"] = "Combat"
L["OPTIONS_COMBAT_DESC"] = "WoW empêche les add-ons de déplacer des objets dans un échange pendant le combat."
L["OPTIONS_COMBAT_NOTIFY"] = "Activer les notifications quand la distribution est bloquée"
L["OPTIONS_COMBAT_NOTIFY_DESC"] =
	"Affiche une note dans votre fenêtre de discussion quand le combat empêche un échange de se remplir, et une fois désactivé Water Dispenser ne dit plus pourquoi l'échange est resté vide."

--------------------------------------------------------------------------------
-- Options — Dispensed Items
--------------------------------------------------------------------------------

L["TAB_DISPENSED_ITEMS"] = "Objets distribués"
L["OPTIONS_ITEMS_DESC"] =
	"Configurez combien distribuer de chaque objet. Les quantités se comptent en objets individuels, donc 20 eaux signifient 20 eaux, et 1 potion signifie 1 potion. Une pile est découpée à la quantité exacte s'il le faut."
-- "Add an Item" must match OPTIONS_ADD_ITEM.
L["OPTIONS_ITEMS_EMPTY"] =
	'Aucun objet configuré. Sélectionnez "Ajouter un objet" dans la liste pour ajouter des consommables de vos sacs.'

L["OPTIONS_ITEM_DISTRIBUTION"] = "Distribution"
L["OPTIONS_ITEM_DISTRIBUTION_DESC"] =
	"Choisissez combien chaque classe reçoit lors d'un échange, selon qu'elle est inconnue, dans votre groupe ou dans votre raid. Comptés en objets individuels, pas en piles. Zéro signifie qu'elle ne recevra jamais cet objet."
L["OPTIONS_ITEM_EVERYONE"] = "Tous"
L["OPTIONS_ITEM_EVERYONE_DESC"] =
	"Définit cette quantité pour toutes les classes d'un coup quand vous appuyez sur Entrée, et reste vide quand les classes ci-dessous ne sont pas toutes d'accord."
-- The accept button inside every number box in this panel.
L["OPTIONS_ITEM_APPLY"] = "Appliquer"
-- %d is the highest amount this item accepts, which is 1 for anything unique.
L["OPTIONS_ITEM_COUNT_TOO_HIGH"] = "C'est plus que ce que cet objet peut distribuer. Le maximum est %d."
L["OPTIONS_ITEM_COUNT_INVALID"] = "Saisissez un nombre d'objets, ou 0 pour ne jamais distribuer celui-ci."
L["OPTIONS_ITEM_SETTINGS"] = "Paramètres de l'objet"
-- "In Group" and "In Raid" in the tooltip must match the two dropdown entries below.
L["OPTIONS_ITEM_DISTRIBUTE"] = "Attribuer"
L["OPTIONS_ITEM_DISTRIBUTE_DESC"] =
	"Définit quand cet objet est remis, car en dehors du groupe choisi il n'est jamais échangé, ni annoncé, ni affiché dans votre infobulle, En groupe couvrant un groupe ou un raid et En raid couvrant les raids uniquement."
-- Dropdown entries. The stored values are "Always", "Group", and "Raid"; these are only their labels.
L["OPTIONS_ITEM_DISTRIBUTE_ALWAYS"] = "Toujours"
L["OPTIONS_ITEM_DISTRIBUTE_GROUP"] = "En groupe"
L["OPTIONS_ITEM_DISTRIBUTE_RAID"] = "En raid"
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Prendre en compte le niveau requis"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] =
	"Ignore cet objet quand le partenaire d'échange est en dessous du niveau requis par l'objet."
L["OPTIONS_ITEM_RESERVE"] = "Activer les réserves"
L["OPTIONS_ITEM_RESERVE_DESC"] =
	"Garde toujours au moins cette quantité dans vos sacs, la distribution et la macro d'annonce considérant tout ce qui dépasse ce nombre comme disponible à donner."
L["OPTIONS_ITEM_SESSION_CAP"] = "Activer le maximum par session"
L["OPTIONS_ITEM_SESSION_CAP_DESC"] =
	"Cesse de donner cet objet à quelqu'un une fois qu'il en a reçu autant de votre part, compté sur tous les échanges jusqu'à votre déconnexion ou un rechargement, et modifier une quantité de cet objet remet le compte de tout le monde à zéro."
-- The label carries the meaning on its own; the tooltip only says why you'd switch it off.
L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "Inclure la quantité dans l'infobulle de joueur et la macro d'annonce"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] =
	"Désactivé nomme l'objet sans nombre à côté, ce qui se lit mieux pour un objet dont vous ne portez jamais qu'un exemplaire, comme une pierre de soins."
L["OPTIONS_ITEM_PLAYER_CLASSES"] = "Distribuer uniquement en jouant ces classes"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] =
	"Remplit les échanges, inscrit cet objet dans la macro d'annonce et l'affiche dans votre infobulle de joueur uniquement si la classe de votre personnage est sélectionnée ci-dessous."
L["OPTIONS_ITEM_REMOVE"] = "Supprimer l'objet"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "Retirer cet objet de la configuration d'échange ?"

L["OPTIONS_SCOPE_SOLO"] = "Inconnus"
L["OPTIONS_SCOPE_GROUP"] = "Groupe"
L["OPTIONS_SCOPE_RAID"] = "Raid"

L["OPTIONS_ADD_ITEM"] = "Ajouter un objet"
L["OPTIONS_ADD_DESC"] =
	"Sélectionnez n'importe quel objet échangeable dans vos sacs pour l'ajouter à la configuration d'échange. Les objets déjà configurés ou liés ne s'affichent pas."
L["OPTIONS_ADD_SELECT"] = "Objets disponibles"
L["OPTIONS_ADD_BUTTON"] = "Ajouter à la configuration"
L["OPTIONS_ADD_EMPTY"] = "Aucun objet échangeable trouvé dans vos sacs."

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["TAB_ANNOUNCEMENTS"] = "Annonces"
L["OPTIONS_ANNOUNCEMENTS_DESC"] =
	"Water Dispenser peut créer une macro qui annonce ce qu'il vous reste à distribuer. La macro choisit le bon canal automatiquement (Dire hors groupe, Groupe en groupe, Raid en raid) et utilise les quantités les plus récentes de vos sacs."
L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Activer la macro d'annonce"
-- "- Dispenser" is the macro's literal name and is never translated.
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] =
	'Maintient à jour une macro propre au personnage nommée "- Dispenser" avec votre liste de distribution actuelle, et supprime la macro quand vous la désactivez.'
-- "Enable Reserves" must match OPTIONS_ITEM_RESERVE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] =
	"Rien à annoncer. Configurez des objets, remplissez vos sacs ou abaissez une réserve dans Activer les réserves."

-- Macro message template (%s is the item list) and the connector before the last list entry.
L["ANNOUNCEMENTS_BODY"] = "J'ai %s. Lancez l'échange !"
L["ANNOUNCEMENTS_AND"] = "et"

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["OPTIONS_SUPPORT"] = "Commentaires et assistance"
-- Precedes the version number on the General panel's last line.
L["VERSION"] = "Version"
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"
L["SUPPORT_WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Built-in Collections
--------------------------------------------------------------------------------

L["ITEM_MAGE_WATER"] = "Eau invoquée"
L["ITEM_MAGE_FOOD"] = "Nourriture invoquée"
L["ITEM_WARLOCK_HEALTHSTONE"] = "Pierre de soins"
