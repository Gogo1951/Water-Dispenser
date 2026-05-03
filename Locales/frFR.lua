local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "frFR")
if not L then return end

L["CHAT_LOADED"] = "Activé. Utilisez %s pour accéder aux paramètres ou désactiver ce message. Vous aimez Water Dispenser ? Parlez-en à vos amis ! (="
L["CHAT_NO_TRADE"] = "Aucune fenêtre d'échange active."
L["CHAT_COMBAT_PAUSED"] = "Remplissage automatique mis en pause pendant le combat."
L["CHAT_COMBAT_RESUMED"] = "Combat terminé. Reprise de l'échange."
L["CHAT_MISSING_STACK"] = "Piles manquantes :"
L["CHAT_ITEM_SAVED"] = "Sauvegardé :"
L["CHAT_ITEM_REMOVED"] = "Supprimé :"

L["BTN_CLEAR"] = "Vider l'échange"
L["BTN_FILL"] = "Remplir l'échange"
L["BTN_CONFIG"] = "Options"
L["BTN_ACCEPT"] = "Accepter l'échange"

L["OPTIONS_TITLE"] = "Water Dispenser"
L["OPTIONS_DESC"] = "Remplit automatiquement la fenêtre d'échange avec des piles d'eau, de nourriture, de pierres de soins ou de tout consommable configuré, selon la classe, le niveau et le groupe du partenaire."

L["OPTIONS_GENERAL_HEADER"] = "Paramètres Généraux"
L["OPTIONS_WELCOME_MESSAGE"] = "Activer le message de bienvenue"
L["OPTIONS_WELCOME_MESSAGE_DESC"] = "Affiche un court message de bienvenue dans le chat quand Water Dispenser se charge."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "Avertissements de piles manquantes"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] = "Affiche un message si un objet configuré n'a pas assez de piles dans vos sacs pour remplir l'échange."
L["OPTIONS_ITEMS"] = "Règles de distribution"
L["OPTIONS_ADD_ITEM"] = "Ajouter un objet"
L["OPTIONS_SUPPORT"] = "Aide & Retours"

L["OPTIONS_AUTOFILL_HEADER"] = "Remplissage Automatique"
L["OPTIONS_AUTOFILL_DESC"] = "Remplit la fenêtre d'échange automatiquement dès son ouverture. Chaque portée est gérée séparément."
L["OPTIONS_AUTOFILL_SOLO"] = "Remplir pour les inconnus"
L["OPTIONS_AUTOFILL_SOLO_DESC"] = "Remplit automatiquement l'échange avec un joueur hors de votre groupe ou raid."
L["OPTIONS_AUTOFILL_GROUP"] = "Remplir pour les membres du groupe"
L["OPTIONS_AUTOFILL_GROUP_DESC"] = "Remplit automatiquement l'échange avec un membre de votre groupe."
L["OPTIONS_AUTOFILL_RAID"] = "Remplir pour les membres du raid"
L["OPTIONS_AUTOFILL_RAID_DESC"] = "Remplit automatiquement l'échange avec un membre de votre raid."

L["OPTIONS_COMBAT_HEADER"] = "Combat"
L["OPTIONS_COMBAT_DESC"] = "Le remplissage est toujours mis en pause en combat pour éviter les erreurs d'interface. Un rappel est affiché. L'échange reprend de lui-même à la fin du combat si la fenêtre est toujours ouverte."

L["OPTIONS_LOCKED_HEADER"] = "Coffrets de Voleur"
L["OPTIONS_LOCKED_DESC"] = "Lors d'un échange avec un voleur, place le premier objet verrouillé trouvé dans vos sacs dans l'emplacement inférieur de l'échange pour qu'il puisse le crocheter."
L["OPTIONS_LOCKED"] = "Offrir les objets verrouillés aux voleurs"

L["OPTIONS_RESET_HEADER"] = "Réinitialiser"
L["OPTIONS_RESET_DESC"] = "Remet tous les paramètres de Water Dispenser pour ce personnage par défaut, y compris votre liste d'objets personnalisée."
L["OPTIONS_RESET_BUTTON"] = "Réinitialiser toutes les options"
L["OPTIONS_RESET_CONFIRM"] = "Êtes-vous sûr de vouloir réinitialiser toutes les options de Water Dispenser pour ce personnage ?"

L["OPTIONS_COMMANDS_HEADER"] = "/Commandes"
L["OPTIONS_COMMANDS_DESC"] = "Commandes textuelles pour Water Dispenser. Le panneau d'options couvre tout, celles-ci sont pour les habitués du clavier."
L["OPTIONS_COMMAND_WD"] = "/wd"
L["OPTIONS_COMMAND_WD_DESC"] = "Ouvre l'interface des options de Water Dispenser."
L["OPTIONS_COMMAND_WD_FILL"] = "/wd fill"
L["OPTIONS_COMMAND_WD_FILL_DESC"] = "Remplit la fenêtre d'échange maintenant, même si le remplissage automatique est désactivé."
L["OPTIONS_COMMAND_WD_CLEAR"] = "/wd clear"
L["OPTIONS_COMMAND_WD_CLEAR_DESC"] = "Vide tous les emplacements de la fenêtre d'échange."
L["OPTIONS_COMMAND_WD_AUTO"] = "/wd auto solo||group||raid on||off"
L["OPTIONS_COMMAND_WD_AUTO_DESC"] = "Active/désactive le remplissage pour la portée donnée. Omettez on/off pour inverser."
L["OPTIONS_COMMAND_WDA"] = "/wda"
L["OPTIONS_COMMAND_WDA_DESC"] = "Envoie le message d'annonce sur le canal correspondant à l'état actuel de votre groupe."

L["CHAT_RESET"] = "Toutes les options ont été réinitialisées par défaut."

L["OPTIONS_ITEMS_DESC"] = "Configurez combien de piles de chaque objet distribuer. Note : Classic Era et TBC Anniversary ne supportent pas la division automatique des piles."
L["OPTIONS_ITEMS_EMPTY"] = "Aucun objet configuré. Ouvrez l'onglet \"Ajouter un objet\" pour ajouter des consommables de vos sacs."

L["OPTIONS_ITEM_SETTINGS"] = "Paramètres de l'objet"
L["OPTIONS_ITEM_USE_NOT_FULL"] = "Remplir avec des piles incomplètes"
L["OPTIONS_ITEM_USE_NOT_FULL_DESC"] = "Quand une pile complète n'est pas disponible, remplit l'échange avec une pile plus petite en votre possession."

L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Prendre en compte le niveau requis"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] = "Ignore cet objet quand le partenaire d'échange n'a pas le niveau requis pour l'utiliser."

L["OPTIONS_ITEM_KEEP_AT_LEAST"] = "Garder au moins"
L["OPTIONS_ITEM_KEEP_AT_LEAST_DESC"] = "Conserve toujours au moins cette quantité dans vos sacs. Tout ce qui dépasse ce montant est considéré comme disponible à la distribution."

L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "Inclure la quantité restante dans la macro"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] = "Quand la macro liste cet objet, précise la quantité qu'il vous reste. À désactiver si vous voulez juste annoncer l'objet (typique pour les pierres de soins)."

L["OPTIONS_ITEM_PLAYER_CLASSES"] = "Distribuer uniquement en jouant cette classe"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] = "Remplit l'échange et inclut cet objet dans l'annonce uniquement si la classe de votre personnage est sélectionnée ci-dessous."

L["OPTIONS_ITEM_REMOVE"] = "Supprimer l'objet"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "Retirer cet objet de la configuration d'échange ?"

L["OPTIONS_SCOPE_SOLO"] = "Inconnus"
L["OPTIONS_SCOPE_GROUP"] = "Membres du groupe"
L["OPTIONS_SCOPE_RAID"] = "Membres du raid"

L["OPTIONS_ADD_DESC"] = "Sélectionnez un consommable échangeable dans vos sacs pour l'ajouter à la configuration. Les objets déjà configurés ou liés ne s'affichent pas."
L["OPTIONS_ADD_SELECT"] = "Objets disponibles"
L["OPTIONS_ADD_BUTTON"] = "Ajouter à la configuration"
L["OPTIONS_ADD_EMPTY"] = "Aucun consommable éligible trouvé dans vos sacs."

L["SUPPORT_DESC"] = "Signalez des problèmes, demandez des fonctionnalités ou venez dire bonjour sur Discord."
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"

L["OPTIONS_ANNOUNCEMENTS"] = "Annonces"
L["OPTIONS_ANNOUNCEMENTS_DESC"] = "Water Dispenser peut créer une macro annonçant ce que vous avez à distribuer. La macro choisit le canal idéal (/dire, /groupe, /raid) et utilise les quantités réelles de vos sacs."

L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Activer la macro d'annonce"
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] = "Maintient une macro nommée \"- Dispenser\" à jour avec votre liste de distribution. La désactiver supprime la macro."

L["OPTIONS_ANNOUNCEMENTS_PREVIEW_HEADER"] = "Aperçu en direct"
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DESC"] = "Voici ce que la macro dira si vous cliquez dessus maintenant."
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] = "Rien à annoncer. Configurez des objets, remplissez vos sacs ou abaissez la valeur de \"Garder au moins\"."

L["ANNOUNCEMENTS_INTRO"] = "J'ai"
L["ANNOUNCEMENTS_OUTRO"] = ". Lancez l'échange !"
L["ANNOUNCEMENTS_AND"] = "et"

L["CHAT_MACRO_CREATED"] = "La macro d'annonce \"- Dispenser\" est prête. Ouvrez le menu Macro (/m) et glissez-la sur votre barre d'action."
L["CHAT_MACRO_DELETED"] = "Macro d'annonce \"- Dispenser\" supprimée."
L["CHAT_MACRO_FULL"] = "Impossible de créer la macro : tous les emplacements de macro du personnage sont utilisés."
L["CHAT_NOTHING_TO_ANNOUNCE"] = "Rien à annoncer pour le moment."

L["ITEM_MAGE_WATER"] = "Toute Eau Invoquée"
L["ITEM_MAGE_FOOD"] = "Toute Nourriture Invoquée"
L["ITEM_WARLOCK_HEALTHSTONE"] = "Toute Pierre de Soins"