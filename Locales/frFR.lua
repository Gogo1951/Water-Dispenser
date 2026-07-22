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

-- All player-facing chat prints live here, regardless of which feature emits them.
L["CHAT_LOADED"] =
	"Version %s. Les paramètres (y compris l'option pour désactiver ce message) se trouvent dans Options > AddOns > Water Dispenser. Vous aimez Water Dispenser ? Parlez-en à vos amis ! (="
L["CHAT_NO_TRADE"] = "Aucune fenêtre d'échange active."
L["CHAT_COMBAT_PAUSED"] = "Distribution mise en pause pendant le combat."
L["CHAT_COMBAT_RESUMED"] = "Combat terminé. Reprise de la distribution."
L["CHAT_MISSING_STACK"] = "Manquant :"
L["CHAT_NONE_ACTIVE_FOR_CLASS"] =
	"Aucun objet n'est configuré pour être distribué pendant que vous jouez un %s. Ouvrez Options > Règles de distribution pour activer des objets pour cette classe."
L["CHAT_ITEM_SAVED"] = "Sauvegardé :"
L["CHAT_ITEM_REMOVED"] = "Supprimé :"
L["CHAT_MACRO_CREATED"] =
	"La macro d'annonce \"- Dispenser\" est prête. Ouvrez l'interface des macros (Menu de jeu > Macros, ou /m) et glissez-la sur votre barre d'action."
L["CHAT_MACRO_DELETED"] = 'Macro d\'annonce "- Dispenser" supprimée.'
L["CHAT_MACRO_FULL"] = "Impossible de créer la macro : tous les emplacements de macro du personnage sont utilisés."

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BUTTON_CLEAR"] = "Vider la fenêtre d'échange"
L["BUTTON_FILL"] = "Remplir la fenêtre d'échange"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["MINIMAP_DISPENSE"] = "Distribuer"
L["UI_ENABLED"] = "Activé"
L["UI_DISABLED"] = "Désactivé"
L["UI_LEFT_CLICK"] = "Clic gauche"
L["UI_TOGGLE"] = "Basculer"
L["MINIMAP_OPTIONS"] = "Options de Water Dispenser"
L["MINIMAP_OPTIONS_KEYBIND"] = "Maj + Clic central"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_DESC"] =
	"Remplit automatiquement la fenêtre d'échange avec des piles d'eau, de nourriture, de pierres de soins ou de tout consommable configuré, selon la classe, le niveau et le groupe du partenaire."

L["OPTIONS_WELCOME_MESSAGE"] = "Activer le message de bienvenue"
L["OPTIONS_WELCOME_MESSAGE_DESC"] =
	"Affiche un court message de bienvenue dans le chat quand Water Dispenser se charge."
L["OPTIONS_MINIMAP"] = "Activer le bouton de la minicarte"
L["OPTIONS_MINIMAP_DESC"] = "Affiche le bouton Water Dispenser sur la minicarte."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "Activer les avertissements de piles manquantes"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] =
	"Affiche un message si un objet configuré n'a pas assez de piles dans vos sacs pour remplir l'échange."

L["OPTIONS_COMMANDS"] = "/Commandes"
L["OPTIONS_COMMANDS_WD"] = "Ouvre le panneau d'options de Water Dispenser."

L["OPTIONS_DISPENSE_HEADER"] = "Distribuer"
L["OPTIONS_DISPENSE_DESC"] =
	"Remplit automatiquement la fenêtre d'échange à son ouverture. Activez chaque option ci-dessous indépendamment."
L["OPTIONS_DISPENSE_MASTER"] = "Activer la distribution"
L["OPTIONS_DISPENSE_MASTER_DESC"] = "Remplit automatiquement la fenêtre d'échange selon vos paramètres."
L["OPTIONS_DISPENSE_SOLO"] = "Activer pour les inconnus"
L["OPTIONS_DISPENSE_SOLO_DESC"] = "Remplit automatiquement l'échange avec un joueur hors de votre groupe ou raid."
L["OPTIONS_DISPENSE_GROUP"] = "Activer pour les membres du groupe"
L["OPTIONS_DISPENSE_GROUP_DESC"] = "Remplit automatiquement l'échange avec un membre de votre groupe."
L["OPTIONS_DISPENSE_RAID"] = "Activer pour les membres du raid"
L["OPTIONS_DISPENSE_RAID_DESC"] = "Remplit automatiquement l'échange avec un membre de votre raid."

L["OPTIONS_COMBAT_HEADER"] = "Combat"
L["OPTIONS_COMBAT_DESC"] =
	"La distribution est toujours mise en pause pendant le combat afin d'éviter les erreurs d'interface. Un message dans le chat vous le rappelle. Les échanges reprennent automatiquement à la fin du combat si la fenêtre est encore ouverte."

--------------------------------------------------------------------------------
-- Options — Distribution Rules
--------------------------------------------------------------------------------

L["OPTIONS_ITEMS"] = "Règles de distribution"
L["OPTIONS_ITEMS_DESC"] =
	"Configurez combien de piles de chaque objet distribuer. Note : Classic Era et TBC Anniversary ne supportent pas la division automatique des piles. Désolé !"
L["OPTIONS_ITEMS_EMPTY"] =
	'Aucun objet configuré. Ouvrez l\'onglet "Ajouter un objet" pour ajouter des consommables de vos sacs.'

L["OPTIONS_ITEM_SETTINGS"] = "Paramètres de l'objet"
L["OPTIONS_ITEM_USE_NOT_FULL"] = "Remplir avec des piles incomplètes"
L["OPTIONS_ITEM_USE_NOT_FULL_DESC"] =
	"Quand une pile complète n'est pas disponible, remplit l'échange avec une pile plus petite en votre possession."
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Prendre en compte le niveau requis"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] =
	"Ignore cet objet quand le partenaire d'échange n'a pas le niveau requis pour l'utiliser."
L["OPTIONS_ITEM_KEEP_AT_LEAST"] = "Garder au moins"
L["OPTIONS_ITEM_KEEP_AT_LEAST_DESC"] =
	"Gardez toujours au moins cette quantité dans vos sacs. La distribution et la macro d'annonce considèrent tout ce qui dépasse ce nombre comme disponible à donner."
L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "Inclure la quantité restante dans la macro"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] =
	"Quand la macro liste cet objet, précise la quantité qu'il vous reste. À désactiver si vous voulez juste annoncer l'objet (typique pour les pierres de soins)."
L["OPTIONS_ITEM_PLAYER_CLASSES"] = "Distribuer uniquement en jouant ces classes"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] =
	"Remplit l'échange et inclut cet objet dans l'annonce uniquement si la classe de votre personnage est sélectionnée ci-dessous."
L["OPTIONS_ITEM_REMOVE"] = "Supprimer l'objet"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "Retirer cet objet de la configuration d'échange ?"

L["OPTIONS_SCOPE_SOLO"] = "Inconnus"
L["OPTIONS_SCOPE_GROUP"] = "Membres du groupe"
L["OPTIONS_SCOPE_RAID"] = "Membres du raid"

L["OPTIONS_ADD_ITEM"] = "Ajouter un objet"
L["OPTIONS_ADD_DESC"] =
	"Sélectionnez un consommable échangeable dans vos sacs pour l'ajouter à la configuration. Les objets déjà configurés ou liés ne s'affichent pas."
L["OPTIONS_ADD_SELECT"] = "Objets disponibles"
L["OPTIONS_ADD_BUTTON"] = "Ajouter à la configuration"
L["OPTIONS_ADD_EMPTY"] = "Aucun consommable éligible trouvé dans vos sacs."

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["OPTIONS_ANNOUNCEMENTS"] = "Annonces"
L["OPTIONS_ANNOUNCEMENTS_DESC"] =
	"Water Dispenser peut créer une macro qui annonce ce qu'il vous reste à distribuer. La macro choisit le bon canal automatiquement (Dire hors groupe, Groupe en groupe, Raid en raid) et utilise les quantités actuelles de vos sacs."
L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Activer la macro d'annonce"
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] =
	'Maintient une macro nommée "- Dispenser" à jour avec votre liste de distribution. La désactiver supprime la macro.'
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_HEADER"] = "Aperçu en direct"
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DESC"] = "Voici ce que la macro dira si vous cliquez dessus maintenant."
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] =
	'Rien à annoncer. Configurez des objets, remplissez vos sacs ou abaissez la valeur de "Garder au moins".'

-- Macro message template (%s is the item list) and the connector before the last list entry.
L["ANNOUNCEMENTS_BODY"] = "J'ai %s. Lancez l'échange !"
L["ANNOUNCEMENTS_AND"] = "et"

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["OPTIONS_SUPPORT"] = "Aide & Retours"
L["SUPPORT_DESC"] = "Signalez des problèmes, demandez des fonctionnalités ou venez dire bonjour sur Discord."
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"
L["SUPPORT_WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Built-in Collections
--------------------------------------------------------------------------------

L["ITEM_MAGE_WATER"] = "Eau invoquée"
L["ITEM_MAGE_FOOD"] = "Nourriture invoquée"
L["ITEM_WARLOCK_HEALTHSTONE"] = "Pierres de soins"
