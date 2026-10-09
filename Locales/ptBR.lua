local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "ptBR")
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
L["ITEM_LOADING"] = "Carregando ID: %d"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

--[[
	All player-facing chat prints live here, regardless of which feature emits them.
	In CHAT_LOADED, %s is the add-on version and the menu path is the game client's
	own labels.
]]
L["CHAT_LOADED"] =
	"Versão %s. As configurações (incluindo a opção de desativar esta mensagem) podem ser encontradas em Opções > AddOns > Water Dispenser. Está gostando do add-on? Conte a um amigo! (="
L["CHAT_NO_TRADE"] = "Nenhuma janela de troca ativa."
L["CHAT_COMBAT_BLOCKED"] = "O WoW bloqueia trocas automatizadas durante o combate."
L["CHAT_OPTIONS_IN_COMBAT"] = "Por precaução, a interface de opções não pode ser aberta durante o combate."
-- The item and its count are appended after the colon by the code.
L["CHAT_MISSING_STACK"] = "Faltando:"
--[[
	%s is the item's name, then the trade partner's name; %d is the Maximum per
	Player they have reached.
]]
L["CHAT_PLAYER_CAP_REACHED"] =
	"%s não adicionado: %s já recebeu %d de você. As contagens recomeçam quando você sai do jogo ou recarrega."
-- %s is the item's name; the first %d is the amount that could not be split off, the second the item's full stack size.
L["CHAT_SPLIT_NEEDS_FULL_STACK"] =
	"%s não adicionado: o jogo não quis separar %d de uma pilha. Defina a quantidade como uma pilha completa (%d) para entregá-lo."
-- %s is the player's class name. "Dispensed Items" must match TAB_DISPENSED_ITEMS.
L["CHAT_NONE_ACTIVE_FOR_CLASS"] =
	"Nenhum item está configurado para distribuição enquanto você joga de %s. Abra Opções > AddOns > Water Dispenser > Itens Distribuídos para ativar itens para esta classe."
-- "- Dispenser" is the macro's literal name and is never translated.
L["CHAT_MACRO_DELETED"] = 'Macro de anúncio "- Dispenser" deletada.'
L["CHAT_MACRO_FULL"] =
	"Não foi possível criar a macro de anúncio: todos os espaços de macro do personagem estão em uso."

--------------------------------------------------------------------------------
-- Player Tooltips
--------------------------------------------------------------------------------

L["TOOLTIP_OPEN_TRADE"] = "Abra troca!"
-- %s is the Improved Healthstone talent's name from the client, then the warlock's rank out of its maximum.
L["TOOLTIP_HEALTHSTONE_TALENT"] = "%s %d/%d"

--------------------------------------------------------------------------------
-- Bag Item Tooltips
--------------------------------------------------------------------------------

-- Shown on a carried bag item the player has set up to give away.
L["TOOLTIP_WILL_DISPENSE"] = "Entregue nas trocas."

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BUTTON_CLEAR"] = "Limpar Janela de Troca"
L["BUTTON_FILL"] = "Preencher Janela de Troca"

--[[
	The silver status line under the trade panel's buttons. "Fill Trade Window" must
	match BUTTON_FILL. ADDED's %s is the window's contents, each FORMAT_ITEM_COUNT,
	joined like the announcement's list. In the rest, %s is an item or collection
	name unless noted.
]]
L["TRADE_STATUS_ADDED"] = "Adicionado: %s."
-- %d is how many short.
L["TRADE_STATUS_SHORT"] = "Faltam %d %s: não há o suficiente nas suas bolsas."
L["TRADE_STATUS_SHORT_RESERVE"] = "Faltam %d %s: sua reserva guarda o resto."
L["TRADE_STATUS_DISPENSE_OFF"] =
	"O preenchimento automático está desligado. Preencher Janela de Troca ainda adiciona suas quantidades de sempre."
L["TRADE_STATUS_OFF_STRANGERS"] =
	"O preenchimento automático está desligado para desconhecidos. Preencher Janela de Troca ainda adiciona suas quantidades de sempre."
L["TRADE_STATUS_OFF_PARTY"] =
	"O preenchimento automático está desligado para membros do grupo. Preencher Janela de Troca ainda adiciona suas quantidades de sempre."
L["TRADE_STATUS_OFF_RAID"] =
	"O preenchimento automático está desligado para membros da raide. Preencher Janela de Troca ainda adiciona suas quantidades de sempre."
L["TRADE_STATUS_MASTER_LOOT"] =
	"Retido enquanto você é o mestre saqueador. Preencher Janela de Troca ainda adiciona suas quantidades de sempre."
-- The first %s is the partner's class name.
L["TRADE_STATUS_ZERO"] = "Definido como 0 para %s: %s."
L["TRADE_STATUS_INSTANCE_ONLY"] = "%s só é entregue em instâncias."
L["TRADE_STATUS_GUILD_ONLY"] = "%s só vai para a sua guilda."
-- The partner's name, then the rank they can't use yet and its level.
L["TRADE_STATUS_LEVEL"] = "%s não pode usar %s até o nível %d."
-- The partner's name first.
L["TRADE_STATUS_TOO_LOW"] = "%s tem nível baixo demais para %s."
-- The partner's name first.
L["TRADE_STATUS_CAPPED"] = "%s já atingiu o seu máximo por jogador de %s."
L["TRADE_STATUS_NONE_HELD"] = "Você não tem %s para dar."
L["TRADE_STATUS_CLEARED"] = "Limpo."
--[[
	A conjure button's tooltip, under the spell's name. MAKES: the item it makes,
	then the trade partner's name and level. LOWEST, when no rank fits the partner:
	the item only.
]]
L["TRADE_CONJURE_MAKES"] = "Cria %s, o melhor que %s (nível %d) pode usar."
L["TRADE_CONJURE_MAKES_LOWEST"] = "Cria %s, o grau mais baixo que você conhece."

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

--[[
	The tooltip's feature row reuses TAB_DISPENSE for its name and
	OPTIONS_DISPENSE_MASTER_DESC for its description; these are its state and click words.
]]
L["UI_ENABLED"] = "Ativado"
L["UI_DISABLED"] = "Desativado"
L["UI_LEFT_CLICK"] = "Botão Esquerdo"
L["UI_TOGGLE"] = "Alternar"
L["MINIMAP_OPTIONS"] = "Opções do Water Dispenser"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + Clique do Meio"
-- Heads the tooltip section listing what the player can give right now.
L["MINIMAP_DISPENSE_REPORT"] = "Relatório de Distribuição"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Distribuição de consumíveis sem esforço. Preenche automaticamente as janelas de troca com água, comida e pedras de vida conjuradas, no grau e na quantidade certos para cada jogador. Adicione qualquer item, de Areia de Ampulheta a Poções de Resistência, e abasteça uma raide inteira em segundos."

L["OPTIONS_WELCOME_MESSAGE"] = "Ativar Mensagem de Boas-vindas"
L["OPTIONS_WELCOME_MESSAGE_DESC"] =
	"Mostra uma saudação de uma linha na sua janela de chat quando o Water Dispenser é carregado."
L["OPTIONS_MINIMAP"] = "Ativar Botão do Minimapa"
L["OPTIONS_MINIMAP_DESC"] = "Mostra o botão do minimapa do Water Dispenser."

L["OPTIONS_FEATURES_HEADER"] = "Recursos"

L["OPTIONS_COMMANDS_HEADER"] = "/Comandos"
L["OPTIONS_COMMAND"] = "/wd"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Abre a interface de opções deste add-on."

--------------------------------------------------------------------------------
-- Options — Dispense
--------------------------------------------------------------------------------

-- Names the panel and the mini-map tooltip's feature row.
L["TAB_DISPENSE"] = "Distribuir"
L["OPTIONS_DISPENSE_MASTER"] = "Ativar Distribuição"
-- Also the panel's intro line and the mini-map tooltip's feature description.
L["OPTIONS_DISPENSE_MASTER_DESC"] =
	"Preenche automaticamente a janela de troca quando uma troca é aberta, com base nas suas configurações."
L["OPTIONS_DISPENSE_SOLO"] = "Ativar para Desconhecidos"
L["OPTIONS_DISPENSE_SOLO_DESC"] =
	"Preenche a janela de troca automaticamente ao negociar com alguém que não está no seu grupo nem na sua raide."
L["OPTIONS_DISPENSE_GROUP"] = "Ativar para Grupo"
L["OPTIONS_DISPENSE_GROUP_DESC"] = "Preenche a janela de troca automaticamente ao negociar com um membro do grupo."
L["OPTIONS_DISPENSE_RAID"] = "Ativar para Raide"
L["OPTIONS_DISPENSE_RAID_DESC"] = "Preenche a janela de troca automaticamente ao negociar com um membro da raide."
-- The label says what it does; the tooltip only covers why it is needed and when it stands down.
L["OPTIONS_RESTACK"] = "Juntar Pilhas Parciais Depois de uma Troca"
L["OPTIONS_RESTACK_DESC"] =
	"Água e comida conjuradas caem em um novo espaço da bolsa a cada conjuração e o jogo nunca as junta de volta, então o Water Dispenser as junta uma vez, logo depois que uma janela de troca é fechada, e nunca em nenhum outro momento, nem em combate, nem enquanto você segura algo no cursor."
L["OPTIONS_HOLD_MASTER_LOOT"] = "Segurar Enquanto Você For o Mestre Saqueador"
-- "Fill Trade Window" must match BUTTON_FILL.
L["OPTIONS_HOLD_MASTER_LOOT_DESC"] =
	"Deixa a janela de troca vazia enquanto você é o mestre saqueador em uma instância, já que essas trocas servem para distribuir o saque. Preencher Janela de Troca ainda adiciona suas quantidades de sempre."
L["OPTIONS_CONJURE_BUTTONS"] = "Mostrar Botões de Conjuração ao Lado das Trocas"
-- "Fill Trade Window" must match BUTTON_FILL.
L["OPTIONS_CONJURE_BUTTONS_DESC"] =
	"Adiciona botões abaixo de Preencher Janela de Troca que conjuram água, comida ou uma pedra de vida que seu parceiro de troca pode usar no nível dele, e o que você cria vai direto para a troca aberta."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "Ativar Avisos Quando Faltar Estoque"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] =
	"Mostra um aviso na sua janela de chat quando você não tem o suficiente de um item configurado nas bolsas para dar a quantidade definida."

-- Leads the silver line under a setting that shows the exact chat line it prints.
L["OPTIONS_EXAMPLE"] = "Exemplo:"

L["OPTIONS_COMBAT_HEADER"] = "Combate"
L["OPTIONS_COMBAT_DESC"] = "O WoW impede que add-ons movam itens para uma troca durante o combate."
L["OPTIONS_COMBAT_NOTIFY"] = "Ativar Notificações Quando a Distribuição Estiver Bloqueada"
L["OPTIONS_COMBAT_NOTIFY_DESC"] =
	"Mostra um aviso na sua janela de chat quando o combate impede que uma troca seja preenchida."

--------------------------------------------------------------------------------
-- Options — Inventory Tooltips
--------------------------------------------------------------------------------

L["TAB_INVENTORY_TOOLTIPS"] = "Dicas de Inventário"
L["OPTIONS_TOOLTIPS_DESC"] =
	"Mostra nas dicas de jogador o que os membros do grupo que usam o Water Dispenser configuraram para doar, e marca nas suas próprias bolsas os itens que você doa."
L["OPTIONS_SHOW_INVENTORY"] = "Mostrar Inventário nas Dicas de Jogador"
L["OPTIONS_SHOW_INVENTORY_DESC"] =
	"Adiciona um bloco do Water Dispenser às dicas de jogador listando o que eles configuraram para doar e quantos têm para doar, com o seu sempre aparecendo, em grupo ou não."
L["OPTIONS_BAG_TOOLTIPS"] = "Mostrar Dicas de Bolsa para os Itens Distribuídos"
L["OPTIONS_BAG_TOOLTIPS_DESC"] =
	"Adiciona uma linha do Water Dispenser à dica de um item da bolsa quando esse item está configurado para ser doado, para você saber de relance o que o add-on vai entregar."
L["OPTIONS_SHARE_INVENTORY"] = "Compartilhar Meu Inventário"
L["OPTIONS_SHARE_INVENTORY_DESC"] =
	"Informa ao seu grupo ou raide o que você tem para doar, para que apareça quando passarem o mouse sobre você. Nunca publica no chat nem chega a ninguém fora do seu grupo. Desligado, você continua vendo o dos outros."

--------------------------------------------------------------------------------
-- Options — Dispensed Items
--------------------------------------------------------------------------------

L["TAB_DISPENSED_ITEMS"] = "Itens Distribuídos"
L["OPTIONS_ITEMS_DESC"] =
	"Configure quantos de cada item distribuir. As quantidades são contadas em itens individuais, então 20 águas significam 20 águas, e 1 poção significa 1 poção. Uma pilha é dividida até a quantidade exata se for preciso."
-- "Add an Item" must match OPTIONS_ADD_ITEM.
L["OPTIONS_ITEMS_EMPTY"] =
	'Nenhum item configurado. Selecione "Adicionar Item" na lista para inserir qualquer item negociável das suas bolsas.'

--[[
	The silver line opening an item's page while nothing of it would go out. In
	OTHER_CLASS, %s is the player's class twice, then OPTIONS_ITEM_PLAYER_CLASSES;
	in ALL_ZERO, %s is OPTIONS_ITEM_EVERYONE.
]]
L["OPTIONS_ITEM_STATUS_OTHER_CLASS"] = "Não é entregue enquanto você joga de %s. Marque %s em %s."
L["OPTIONS_ITEM_STATUS_ALL_ZERO"] =
	"Nada sai ainda: todas as quantidades estão em 0. Digite um número em %s para começar."

L["OPTIONS_ITEM_AMOUNTS"] = "Quantidades"
L["OPTIONS_ITEM_AMOUNTS_DESC"] =
	"Escolha quantos cada classe recebe ao negociar com ela, conforme seja um desconhecido, esteja no seu grupo ou na sua raide. Contados em itens individuais, não em pilhas. Zero significa que nunca receberá este item."
L["OPTIONS_ITEM_EVERYONE"] = "Todos"
-- "Apply" must match OPTIONS_ITEM_APPLY.
L["OPTIONS_ITEM_EVERYONE_DESC"] =
	"Define esta quantidade para todas as classes de uma vez quando você pressiona Enter ou clica em Aplicar, e fica em branco quando as classes abaixo não coincidem."
-- The accept button inside every number box in this panel.
L["OPTIONS_ITEM_APPLY"] = "Aplicar"
-- %d is the highest amount this item accepts, which is 1 for anything unique.
L["OPTIONS_ITEM_COUNT_TOO_HIGH"] = "Isso é mais do que você pode dar deste item. O máximo é %d."
L["OPTIONS_ITEM_COUNT_INVALID"] = "Digite um número de itens."
L["OPTIONS_ITEM_SETTINGS"] = "Configurações do Item"
L["OPTIONS_ITEM_DISTRIBUTE"] = "Entregar"
-- "In Instance" must match OPTIONS_ITEM_DISTRIBUTE_INSTANCE.
L["OPTIONS_ITEM_DISTRIBUTE_DESC"] =
	"Define onde este item é entregue. Em Instância abrange masmorras, raides, campos de batalha e arenas. Em qualquer outro lugar, o item nunca é trocado, anunciado nem mostrado na sua dica."
--[[
	Dropdown entries, looked up as OPTIONS_ITEM_DISTRIBUTE_ plus the stored value in
	capitals ("Always", "Instance"), so no code names these keys in full.
]]
L["OPTIONS_ITEM_DISTRIBUTE_ALWAYS"] = "Sempre"
L["OPTIONS_ITEM_DISTRIBUTE_INSTANCE"] = "Em Instância"
L["OPTIONS_ITEM_GUILDIES_ONLY"] = "Somente Guilda"
L["OPTIONS_ITEM_GUILDIES_ONLY_DESC"] = "Ignora este item quando o seu parceiro de troca não está na sua guilda."
-- Panel line under the toggle, not a tooltip: it names the guild, which no fixed string can. %s is the player's guild.
L["OPTIONS_ITEM_GUILDIES_ONLY_HELP"] = "Dar somente a membros de <%s>."
L["OPTIONS_ITEM_GUILDIES_ONLY_NO_GUILD"] = "Você não está em nenhuma guilda, então isto não dá o item a ninguém."
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Considerar o Nível Exigido pelo Item"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] =
	"Ignora este item quando o seu parceiro de troca está abaixo do nível exigido pelo item."
L["OPTIONS_ITEM_RESERVE"] = "Ativar Reservas"
L["OPTIONS_ITEM_RESERVE_DESC"] =
	"Mantém sempre pelo menos esta quantidade nas suas bolsas, com a distribuição, a sua dica de jogador e a macro de anúncio tratando tudo além desse número como disponível para doar."
L["OPTIONS_ITEM_PLAYER_CAP"] = "Ativar Máximo por Jogador"
L["OPTIONS_ITEM_PLAYER_CAP_DESC"] =
	"Para de dar este item a alguém quando essa pessoa já recebeu esta quantidade de você. As contagens recomeçam quando você sai do jogo, recarrega ou altera as quantidades deste item."
-- The label carries the meaning on its own; the tooltip only says why you'd switch it off.
L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "Incluir Quantidade na Dica de Jogador e na Macro de Anúncio"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] =
	"Desativado nomeia o item sem número ao lado, o que fica melhor para algo de que você só carrega um, como uma pedra de vida."
L["OPTIONS_ITEM_PLAYER_CLASSES"] = "Apenas Distribuir ao Jogar com Estas Classes"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] =
	"Preenche as trocas, lista este item na macro de anúncio e o mostra na sua dica de jogador somente quando a classe do seu personagem estiver selecionada abaixo."
L["OPTIONS_ITEM_REMOVE"] = "Remover Item"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "Remover este item dos seus itens distribuídos?"

L["OPTIONS_SCOPE_SOLO"] = "Desconhecidos"
L["OPTIONS_SCOPE_GROUP"] = "Grupo"
L["OPTIONS_SCOPE_RAID"] = "Raide"

L["OPTIONS_ADD_ITEM"] = "Adicionar Item"
L["OPTIONS_ADD_DESC"] =
	"Selecione qualquer item negociável das suas bolsas para adicionar aos seus itens distribuídos. Itens já configurados ou vinculados à alma não aparecerão."
L["OPTIONS_ADD_SELECT"] = "Itens Disponíveis"
L["OPTIONS_ADD_BUTTON"] = "Adicionar aos Itens Distribuídos"
L["OPTIONS_ADD_EMPTY"] = "Nenhum item negociável encontrado nas suas bolsas."

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["TAB_ANNOUNCEMENTS"] = "Anúncios"
L["OPTIONS_ANNOUNCEMENTS_DESC"] =
	"O Water Dispenser pode criar uma macro que anuncia o que você ainda tem para distribuir. A macro escolhe o canal automaticamente (Dizer sem grupo, Grupo em um grupo, Raide em uma raide, Instância em um grupo de masmorra ou campo de batalha) e usa as quantidades mais recentes direto das suas bolsas."
L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Ativar Macro de Anúncio"
-- "- Dispenser" is the macro's literal name and is never translated.
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] =
	'Mantém uma macro específica do personagem chamada "- Dispenser" sempre atualizada com os seus itens distribuídos atuais, e exclui a macro quando você desativa isto.'
-- "Enable Reserves" must match OPTIONS_ITEM_RESERVE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] =
	"Nada a anunciar. Configure os itens, reabasteça as bolsas ou baixe uma reserva em Ativar Reservas."
-- "Enable Dispense" must match OPTIONS_DISPENSE_MASTER, "Dispense" must match TAB_DISPENSE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DISPENSE_OFF"] =
	"Nada a anunciar enquanto Ativar Distribuição estiver desligado, na aba Distribuir."

-- Macro message template (%s is the item list) and the connector before the last list entry.
L["ANNOUNCEMENTS_BODY"] = "Eu tenho %s. Abra troca!"
L["ANNOUNCEMENTS_AND"] = "e"

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["OPTIONS_SUPPORT"] = "Comentários e Suporte"
-- The General panel's last line. %s is the version.
L["OPTIONS_VERSION"] = "Versão %s"
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"
L["SUPPORT_WAGO"] = "Wago"
