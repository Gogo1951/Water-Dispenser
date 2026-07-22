local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "ptBR")
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
	"Versão %s. As configurações (incluindo a opção de desativar esta mensagem) podem ser encontradas em Opções > AddOns > Water Dispenser. Está gostando do Water Dispenser? Conte a um amigo! (="
L["CHAT_NO_TRADE"] = "Nenhuma janela de troca ativa."
L["CHAT_COMBAT_PAUSED"] = "Distribuição pausada durante o combate."
L["CHAT_COMBAT_RESUMED"] = "Combate finalizado. Retomando a distribuição."
L["CHAT_MISSING_STACK"] = "Faltando:"
L["CHAT_NONE_ACTIVE_FOR_CLASS"] =
	"Nenhum item está configurado para distribuição enquanto você joga de %s. Abra Opções > Regras de Distribuição para ativar itens para esta classe."
L["CHAT_ITEM_SAVED"] = "Salvo:"
L["CHAT_ITEM_REMOVED"] = "Removido:"
L["CHAT_MACRO_CREATED"] =
	'A macro de anúncio "- Dispenser" está pronta. Abra a Interface de Macros (Menu do Jogo > Macros, ou /m) e arraste-a para a barra de ação.'
L["CHAT_MACRO_DELETED"] = 'Macro de anúncio "- Dispenser" deletada.'
L["CHAT_MACRO_FULL"] = "Não foi possível criar a macro: todos os espaços de macro do personagem estão em uso."

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BUTTON_CLEAR"] = "Limpar Janela de Troca"
L["BUTTON_FILL"] = "Preencher Janela de Troca"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["MINIMAP_DISPENSE"] = "Distribuir"
L["UI_ENABLED"] = "Ativado"
L["UI_DISABLED"] = "Desativado"
L["UI_LEFT_CLICK"] = "Botão Esquerdo"
L["UI_TOGGLE"] = "Alternar"
L["MINIMAP_OPTIONS"] = "Opções do Water Dispenser"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + Clique do Meio"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_DESC"] =
	"Preenche automaticamente a janela de troca com pilhas de água, comida, pedras de vida ou qualquer consumível configurado, com base na classe, nível e grupo do parceiro de troca."

L["OPTIONS_WELCOME_MESSAGE"] = "Ativar Mensagem de Boas-vindas"
L["OPTIONS_WELCOME_MESSAGE_DESC"] = "Mostra uma saudação rápida no chat quando o Water Dispenser é carregado."
L["OPTIONS_MINIMAP"] = "Ativar Botão do Minimapa"
L["OPTIONS_MINIMAP_DESC"] = "Mostra o botão do minimapa do Water Dispenser."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "Ativar Avisos de Pilhas Faltando"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] =
	"Mostra uma mensagem no chat quando um item configurado não possui pilhas suficientes nas suas bolsas para preencher a troca."

L["OPTIONS_COMMANDS"] = "/Comandos"
L["OPTIONS_COMMANDS_WD"] = "Abre o painel de opções do Water Dispenser."

L["OPTIONS_DISPENSE_HEADER"] = "Distribuir"
L["OPTIONS_DISPENSE_DESC"] =
	"Preenche automaticamente a janela de troca quando uma troca é aberta. Alterne cada opção abaixo de forma independente."
L["OPTIONS_DISPENSE_MASTER"] = "Ativar Distribuição"
L["OPTIONS_DISPENSE_MASTER_DESC"] = "Preenche automaticamente a janela de troca com base nas suas configurações."
L["OPTIONS_DISPENSE_SOLO"] = "Preencher para Desconhecidos"
L["OPTIONS_DISPENSE_SOLO_DESC"] = "Preenche a troca automaticamente ao negociar com alguém fora do seu grupo ou raide."
L["OPTIONS_DISPENSE_GROUP"] = "Preencher para Membros do Grupo"
L["OPTIONS_DISPENSE_GROUP_DESC"] = "Preenche a troca automaticamente ao negociar com um membro do seu grupo."
L["OPTIONS_DISPENSE_RAID"] = "Preencher para Membros da Raide"
L["OPTIONS_DISPENSE_RAID_DESC"] = "Preenche a troca automaticamente ao negociar com um membro da sua raide."

L["OPTIONS_COMBAT_HEADER"] = "Combate"
L["OPTIONS_COMBAT_DESC"] =
	"A distribuição é sempre pausada durante o combate para evitar erros de interface. Uma mensagem no chat te lembra quando isso acontece. As trocas são retomadas automaticamente ao fim do combate se a janela ainda estiver aberta."

--------------------------------------------------------------------------------
-- Options — Distribution Rules
--------------------------------------------------------------------------------

L["OPTIONS_ITEMS"] = "Regras de Distribuição"
L["OPTIONS_ITEMS_DESC"] =
	"Configure quantas pilhas de cada item devem ser distribuídas. Nota: Classic Era e TBC Anniversary não suportam a divisão automática de pilhas. Desculpe!"
L["OPTIONS_ITEMS_EMPTY"] =
	'Nenhum item configurado. Abra a aba "Adicionar Item" para inserir consumíveis das suas bolsas.'

L["OPTIONS_ITEM_SETTINGS"] = "Configurações do Item"
L["OPTIONS_ITEM_USE_NOT_FULL"] = "Usar Pilhas Incompletas"
L["OPTIONS_ITEM_USE_NOT_FULL_DESC"] =
	"Quando não houver uma pilha cheia, preenche a troca com a menor pilha disponível que você tem."
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Considerar Requisitos de Nível"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] =
	"Ignora este item caso o parceiro de troca esteja abaixo do nível necessário para usá-lo."
L["OPTIONS_ITEM_KEEP_AT_LEAST"] = "Manter no mínimo"
L["OPTIONS_ITEM_KEEP_AT_LEAST_DESC"] =
	"Mantenha sempre pelo menos esta quantidade nas suas bolsas. A distribuição e a macro de anúncio tratam tudo além deste número como disponível para doar."
L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "Incluir Quantidade Restante na Macro"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] =
	"Quando a macro anunciar este item, mostrará quantos você ainda tem. Desative caso prefira apenas dizer que tem o item (comum para Pedras de Vida)."
L["OPTIONS_ITEM_PLAYER_CLASSES"] = "Apenas Distribuir ao Jogar com Estas Classes"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] =
	"Preenche as trocas e inclui no anúncio somente se a classe do seu personagem estiver selecionada abaixo."
L["OPTIONS_ITEM_REMOVE"] = "Remover Item"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "Remover este item da configuração de troca?"

L["OPTIONS_SCOPE_SOLO"] = "Desconhecidos"
L["OPTIONS_SCOPE_GROUP"] = "Membros do Grupo"
L["OPTIONS_SCOPE_RAID"] = "Membros da Raide"

L["OPTIONS_ADD_ITEM"] = "Adicionar Item"
L["OPTIONS_ADD_DESC"] =
	"Selecione um consumível negociável das suas bolsas para a configuração. Itens já configurados ou vinculados não aparecerão."
L["OPTIONS_ADD_SELECT"] = "Itens disponíveis"
L["OPTIONS_ADD_BUTTON"] = "Adicionar à configuração"
L["OPTIONS_ADD_EMPTY"] = "Nenhum consumível elegível encontrado em suas bolsas."

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["OPTIONS_ANNOUNCEMENTS"] = "Anúncios"
L["OPTIONS_ANNOUNCEMENTS_DESC"] =
	"O Water Dispenser pode criar uma macro que anuncia o que você ainda tem para distribuir. A macro escolhe o canal automaticamente (Dizer sem grupo, Grupo em um grupo, Raide em uma raide) e usa as quantidades atuais das suas bolsas."
L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Ativar Macro de Anúncio"
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] =
	'Mantém uma macro específica do personagem chamada "- Dispenser" sempre atualizada. Desativar exclui a macro.'
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_HEADER"] = "Prévia ao Vivo"
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DESC"] = "Isto é o que a macro dirá se você a pressionar agora."
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] =
	'Nada a anunciar. Configure os itens, reabasteça as bolsas ou baixe o valor de "Manter no mínimo".'

-- Macro message template (%s is the item list) and the connector before the last list entry.
L["ANNOUNCEMENTS_BODY"] = "Eu tenho %s. Abra troca!"
L["ANNOUNCEMENTS_AND"] = "e"

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["OPTIONS_SUPPORT"] = "Feedback & Suporte"
L["SUPPORT_DESC"] = "Relate problemas, sugira recursos ou venha dizer um olá no Discord."
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"
L["SUPPORT_WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Built-in Collections
--------------------------------------------------------------------------------

L["ITEM_MAGE_WATER"] = "Água conjurada"
L["ITEM_MAGE_FOOD"] = "Comida conjurada"
L["ITEM_WARLOCK_HEALTHSTONE"] = "Pedras de vida"
