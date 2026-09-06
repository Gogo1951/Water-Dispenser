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

--[[
	All player-facing chat prints live here, regardless of which feature emits them.
	%s is the add-on version; the menu path is the game client's own labels.
]]
L["CHAT_LOADED"] =
	"Versão %s. As configurações (incluindo a opção de desativar esta mensagem) podem ser encontradas em Opções > AddOns > Water Dispenser. Está gostando do add-on? Conte a um amigo! (="
L["CHAT_NO_TRADE"] = "Nenhuma janela de troca ativa."
L["CHAT_COMBAT_BLOCKED"] = "O WoW bloqueia trocas automatizadas durante o combate."
L["CHAT_OPTIONS_IN_COMBAT"] = "Por precaução, a interface de opções não pode ser aberta durante o combate."
-- The item and its count are appended after the colon by the code.
L["CHAT_MISSING_STACK"] = "Faltando:"
--[[
	%s is the item's name, %d the Maximum per Session it has hit.
	"Maximum per Session" must match OPTIONS_ITEM_SESSION_CAP.
]]
L["CHAT_SESSION_CAP_REACHED"] =
	"%s não adicionado: ele já recebeu os %d desta sessão. Altere Máximo por Sessão, ou recarregue para zerar."
-- %s is the item's name, %d the amount that could not be split off.
L["CHAT_SPLIT_REFUSED"] =
	"%s não adicionado: este cliente não quis separar %d de uma pilha, e entregar uma pilha inteira daria muito mais do que você pediu. Defina a quantidade deste item como uma pilha inteira para negociá-lo."
-- %s is the player's class name. "Dispensed Items" must match TAB_DISPENSED_ITEMS.
L["CHAT_NONE_ACTIVE_FOR_CLASS"] =
	"Nenhum item está configurado para distribuição enquanto você joga de %s. Abra Opções > Itens Distribuídos para ativar itens para esta classe."
-- "- Dispenser" is the macro's literal name and is never translated.
L["CHAT_MACRO_DELETED"] = 'Macro de anúncio "- Dispenser" deletada.'
L["CHAT_MACRO_FULL"] = "Não foi possível criar a macro: todos os espaços de macro do personagem estão em uso."

--------------------------------------------------------------------------------
-- Player Tooltips
--------------------------------------------------------------------------------

L["TOOLTIP_OPEN_TRADE"] = "Abra troca!"
-- %d/%d is the warlock's Improved Healthstone rank out of its maximum.
L["TOOLTIP_HEALTHSTONE"] = "Pedra de vida (Grau %d/%d)"

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BUTTON_CLEAR"] = "Limpar Janela de Troca"
L["BUTTON_FILL"] = "Preencher Janela de Troca"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

-- The tooltip's feature row reuses TAB_DISPENSE for its name; these are its state and click words.
L["UI_ENABLED"] = "Ativado"
L["UI_DISABLED"] = "Desativado"
L["UI_LEFT_CLICK"] = "Botão Esquerdo"
L["UI_TOGGLE"] = "Alternar"
L["MINIMAP_OPTIONS"] = "Opções do Water Dispenser"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + Clique do Meio"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Distribuição de consumíveis sem esforço. Preenche automaticamente a janela de troca com água, comida e pedras de vida. Adicione qualquer item que quiser, como Areia de ampulheta ou poções de resistência, para distribuir à sua raide."

L["OPTIONS_WELCOME_MESSAGE"] = "Ativar Mensagem de Boas-vindas"
L["OPTIONS_WELCOME_MESSAGE_DESC"] =
	"Mostra uma saudação de uma linha na sua janela de chat quando o Water Dispenser é carregado."
L["OPTIONS_MINIMAP"] = "Ativar Botão do Minimapa"
L["OPTIONS_MINIMAP_DESC"] = "Mostra o botão do minimapa do Water Dispenser."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "Ativar Avisos Quando Faltar Estoque"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] =
	"Mostra um aviso na sua janela de chat quando você não tem o suficiente de um item configurado nas bolsas para dar a quantidade definida."
-- The label says what it does; the tooltip only covers why it is needed and when it stands down.
L["OPTIONS_RESTACK"] = "Juntar Automaticamente Pilhas Parciais nas Bolsas"
L["OPTIONS_RESTACK_DESC"] =
	"Água e comida conjuradas caem em um novo espaço da bolsa a cada conjuração e o jogo nunca as junta de volta, embora isto nunca seja executado em combate, com uma troca aberta ou enquanto você segura algo no cursor."

L["OPTIONS_COMMANDS_HEADER"] = "/Comandos"
L["OPTIONS_COMMAND"] = "/wd"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Abre a interface de opções deste add-on."

-- Names the panel, its section header, and the mini-map tooltip's feature row.
L["TAB_DISPENSE"] = "Distribuir"
L["OPTIONS_DISPENSE_DESC"] = "Preenche automaticamente a janela de troca quando uma troca é aberta."
L["OPTIONS_DISPENSE_MASTER"] = "Ativar Distribuição"
L["OPTIONS_DISPENSE_MASTER_DESC"] = "Preenche automaticamente a janela de troca com base nas suas configurações."
L["OPTIONS_DISPENSE_SOLO"] = "Ativar para Desconhecidos"
L["OPTIONS_DISPENSE_SOLO_DESC"] =
	"Preenche a janela de troca automaticamente ao negociar com alguém que não está no seu grupo nem na sua raide."
L["OPTIONS_DISPENSE_GROUP"] = "Ativar para Grupo"
L["OPTIONS_DISPENSE_GROUP_DESC"] = "Preenche a janela de troca automaticamente ao negociar com um membro do grupo."
L["OPTIONS_DISPENSE_RAID"] = "Ativar para Raide"
L["OPTIONS_DISPENSE_RAID_DESC"] = "Preenche a janela de troca automaticamente ao negociar com um membro da raide."

L["TAB_INVENTORY_TOOLTIPS"] = "Dicas de Inventário"
L["OPTIONS_TOOLTIPS_DESC"] =
	"Mostra o inventário disponível para doação nas dicas de jogador dos membros do grupo que usam o Water Dispenser."
L["OPTIONS_SHOW_INVENTORY"] = "Mostrar Inventário nas Dicas de Jogador"
L["OPTIONS_SHOW_INVENTORY_DESC"] =
	"Adiciona um bloco do Water Dispenser às dicas de jogador listando o que eles configuraram para doar e quantos estão carregando, com o seu sempre aparecendo, em grupo ou não."
L["OPTIONS_SHARE_INVENTORY"] = "Compartilhar Meu Inventário"
L["OPTIONS_SHARE_INVENTORY_DESC"] =
	"Informa ao seu grupo e à sua raide o que você está carregando para que o seu inventário apareça quando passarem o mouse sobre você, sem publicar nada no chat nem avisar ninguém fora do seu grupo, e desativar isto ainda deixa você ver o dos outros."

L["OPTIONS_COMBAT_HEADER"] = "Combate"
L["OPTIONS_COMBAT_DESC"] = "O WoW impede que add-ons movam itens para uma troca durante o combate."
L["OPTIONS_COMBAT_NOTIFY"] = "Ativar Notificações Quando a Distribuição Estiver Bloqueada"
L["OPTIONS_COMBAT_NOTIFY_DESC"] =
	"Mostra um aviso na sua janela de chat quando o combate impede o preenchimento de uma troca, e com isto desativado o Water Dispenser fica calado sobre por que a troca continuou vazia."

--------------------------------------------------------------------------------
-- Options — Dispensed Items
--------------------------------------------------------------------------------

L["TAB_DISPENSED_ITEMS"] = "Itens Distribuídos"
L["OPTIONS_ITEMS_DESC"] =
	"Configure quantos de cada item distribuir. As quantidades são contadas em itens individuais, então 20 águas significam 20 águas, e 1 poção significa 1 poção. Uma pilha é dividida até a quantidade exata se for preciso."
-- "Add an Item" must match OPTIONS_ADD_ITEM.
L["OPTIONS_ITEMS_EMPTY"] =
	'Nenhum item configurado. Selecione "Adicionar Item" na lista para inserir consumíveis das suas bolsas.'

L["OPTIONS_ITEM_DISTRIBUTION"] = "Distribuição"
L["OPTIONS_ITEM_DISTRIBUTION_DESC"] =
	"Escolha quantos cada classe recebe ao negociar com ela, conforme seja um desconhecido, esteja no seu grupo ou na sua raide. Contados em itens individuais, não em pilhas. Zero significa que nunca receberá este item."
L["OPTIONS_ITEM_EVERYONE"] = "Todos"
L["OPTIONS_ITEM_EVERYONE_DESC"] =
	"Define esta quantidade para todas as classes de uma vez quando você pressiona Enter, e fica em branco quando as classes abaixo não coincidem."
-- The accept button inside every number box in this panel.
L["OPTIONS_ITEM_APPLY"] = "Aplicar"
-- %d is the highest amount this item accepts, which is 1 for anything unique.
L["OPTIONS_ITEM_COUNT_TOO_HIGH"] = "Isso é mais do que este item pode distribuir. O máximo é %d."
L["OPTIONS_ITEM_COUNT_INVALID"] = "Digite um número de itens, ou 0 para nunca distribuir este."
L["OPTIONS_ITEM_SETTINGS"] = "Configurações do Item"
-- "In Group" and "In Raid" in the tooltip must match the two dropdown entries below.
L["OPTIONS_ITEM_DISTRIBUTE"] = "Entregar"
L["OPTIONS_ITEM_DISTRIBUTE_DESC"] =
	"Define quando este item é entregue, já que fora do grupo escolhido ele nunca é negociado, anunciado ou mostrado na sua dica, com Em Grupo cobrindo um grupo ou uma raide e Em Raide apenas raides."
-- Dropdown entries. The stored values are "Always", "Group", and "Raid"; these are only their labels.
L["OPTIONS_ITEM_DISTRIBUTE_ALWAYS"] = "Sempre"
L["OPTIONS_ITEM_DISTRIBUTE_GROUP"] = "Em Grupo"
L["OPTIONS_ITEM_DISTRIBUTE_RAID"] = "Em Raide"
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Considerar Requisitos de Nível"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] =
	"Ignora este item quando o parceiro de troca está abaixo do nível exigido pelo item."
L["OPTIONS_ITEM_RESERVE"] = "Ativar Reservas"
L["OPTIONS_ITEM_RESERVE_DESC"] =
	"Mantém sempre pelo menos esta quantidade nas suas bolsas, com a distribuição e a macro de anúncio tratando tudo além desse número como disponível para doar."
L["OPTIONS_ITEM_SESSION_CAP"] = "Ativar Máximo por Sessão"
L["OPTIONS_ITEM_SESSION_CAP_DESC"] =
	"Para de dar este item a alguém assim que ele tiver recebido esta quantidade de você, contando todas as trocas até você sair ou recarregar, e mudar qualquer quantidade deste item zera a contagem de todos."
-- The label carries the meaning on its own; the tooltip only says why you'd switch it off.
L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "Incluir Quantidade na Dica de Jogador e na Macro de Anúncio"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] =
	"Desativado nomeia o item sem número ao lado, o que fica melhor para algo de que você só carrega um, como uma pedra de vida."
L["OPTIONS_ITEM_PLAYER_CLASSES"] = "Apenas Distribuir ao Jogar com Estas Classes"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] =
	"Preenche as trocas, lista este item na macro de anúncio e o mostra na sua dica de jogador somente quando a classe do seu personagem estiver selecionada abaixo."
L["OPTIONS_ITEM_REMOVE"] = "Remover Item"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "Remover este item da configuração de troca?"

L["OPTIONS_SCOPE_SOLO"] = "Desconhecidos"
L["OPTIONS_SCOPE_GROUP"] = "Grupo"
L["OPTIONS_SCOPE_RAID"] = "Raide"

L["OPTIONS_ADD_ITEM"] = "Adicionar Item"
L["OPTIONS_ADD_DESC"] =
	"Selecione qualquer item negociável das suas bolsas para adicionar à configuração de troca. Itens já configurados ou vinculados à alma não aparecerão."
L["OPTIONS_ADD_SELECT"] = "Itens Disponíveis"
L["OPTIONS_ADD_BUTTON"] = "Adicionar à Configuração"
L["OPTIONS_ADD_EMPTY"] = "Nenhum item negociável encontrado nas suas bolsas."

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["TAB_ANNOUNCEMENTS"] = "Anúncios"
L["OPTIONS_ANNOUNCEMENTS_DESC"] =
	"O Water Dispenser pode criar uma macro que anuncia o que você ainda tem para distribuir. A macro escolhe o canal automaticamente (Dizer sem grupo, Grupo em um grupo, Raide em uma raide) e usa as quantidades mais recentes direto das suas bolsas."
L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Ativar Macro de Anúncio"
-- "- Dispenser" is the macro's literal name and is never translated.
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] =
	'Mantém uma macro específica do personagem chamada "- Dispenser" sempre atualizada com a sua lista de doações atual, e exclui a macro quando você desativa isto.'
-- "Enable Reserves" must match OPTIONS_ITEM_RESERVE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] =
	"Nada a anunciar. Configure os itens, reabasteça as bolsas ou baixe uma reserva em Ativar Reservas."

-- Macro message template (%s is the item list) and the connector before the last list entry.
L["ANNOUNCEMENTS_BODY"] = "Eu tenho %s. Abra troca!"
L["ANNOUNCEMENTS_AND"] = "e"

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["OPTIONS_SUPPORT"] = "Comentários e Suporte"
-- Precedes the version number on the General panel's last line.
L["VERSION"] = "Versão"
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"
L["SUPPORT_WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Built-in Collections
--------------------------------------------------------------------------------

L["ITEM_MAGE_WATER"] = "Água conjurada"
L["ITEM_MAGE_FOOD"] = "Comida conjurada"
L["ITEM_WARLOCK_HEALTHSTONE"] = "Pedra de vida"
