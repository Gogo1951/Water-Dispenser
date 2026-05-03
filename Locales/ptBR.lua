local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "ptBR")
if not L then return end

L["CHAT_LOADED"] = "Ativado. Use %s para acessar as configurações, inclusive para desativar esta mensagem. Está gostando do Water Dispenser? Conte a um amigo! (="
L["CHAT_NO_TRADE"] = "Nenhuma janela de troca ativa."
L["CHAT_COMBAT_PAUSED"] = "Preenchimento automático pausado durante o combate."
L["CHAT_COMBAT_RESUMED"] = "Combate finalizado. Retomando o preenchimento da troca."
L["CHAT_MISSING_STACK"] = "Pilhas faltando:"
L["CHAT_ITEM_SAVED"] = "Salvo:"
L["CHAT_ITEM_REMOVED"] = "Removido:"

L["BTN_CLEAR"] = "Limpar Troca"
L["BTN_FILL"] = "Preencher Troca"
L["BTN_CONFIG"] = "Opções"
L["BTN_ACCEPT"] = "Aceitar Troca"

L["OPTIONS_TITLE"] = "Water Dispenser"
L["OPTIONS_DESC"] = "Preenche automaticamente a janela de troca com pilhas de água, comida, pedras de vida ou qualquer consumível configurado, com base na classe, nível e grupo do parceiro de troca."

L["OPTIONS_GENERAL_HEADER"] = "Configurações Gerais"
L["OPTIONS_WELCOME_MESSAGE"] = "Ativar Mensagem de Boas-vindas"
L["OPTIONS_WELCOME_MESSAGE_DESC"] = "Mostra uma saudação rápida no chat quando o Water Dispenser é carregado."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "Avisos de Pilhas Faltando"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] = "Mostra uma mensagem no chat quando um item configurado não possui pilhas suficientes nas suas bolsas para preencher a troca."
L["OPTIONS_ITEMS"] = "Regras de Distribuição"
L["OPTIONS_ADD_ITEM"] = "Adicionar Item"
L["OPTIONS_SUPPORT"] = "Feedback & Suporte"

L["OPTIONS_AUTOFILL_HEADER"] = "Preenchimento Automático"
L["OPTIONS_AUTOFILL_DESC"] = "Preenche a janela automaticamente ao iniciar uma troca. Cada escopo é ativado/desativado de forma independente."
L["OPTIONS_AUTOFILL_SOLO"] = "Preencher para Desconhecidos"
L["OPTIONS_AUTOFILL_SOLO_DESC"] = "Preenche a troca automaticamente ao negociar com alguém fora do seu grupo ou raide."
L["OPTIONS_AUTOFILL_GROUP"] = "Preencher para Membros do Grupo"
L["OPTIONS_AUTOFILL_GROUP_DESC"] = "Preenche a troca automaticamente ao negociar com um membro do seu grupo."
L["OPTIONS_AUTOFILL_RAID"] = "Preencher para Membros da Raide"
L["OPTIONS_AUTOFILL_RAID_DESC"] = "Preenche a troca automaticamente ao negociar com um membro da sua raide."

L["OPTIONS_COMBAT_HEADER"] = "Combate"
L["OPTIONS_COMBAT_DESC"] = "O preenchimento automático sempre é pausado em combate para evitar erros de interface. Você verá um lembrete no chat. As trocas são retomadas sozinhas ao sair de combate se a janela ainda estiver aberta."

L["OPTIONS_LOCKED_HEADER"] = "Cofres de Ladino"
L["OPTIONS_LOCKED_DESC"] = "Ao negociar com um ladino, coloca o primeiro item trancado encontrado nas suas bolsas no espaço de item que \"não será trocado\", para que ele possa abrir."
L["OPTIONS_LOCKED"] = "Oferecer Itens Trancados a Ladinos"

L["OPTIONS_RESET_HEADER"] = "Redefinir"
L["OPTIONS_RESET_DESC"] = "Redefine todas as configurações do Water Dispenser neste personagem para o padrão, incluindo a sua lista de itens personalizados."
L["OPTIONS_RESET_BUTTON"] = "Redefinir todas as Opções"
L["OPTIONS_RESET_CONFIRM"] = "Tem certeza de que deseja redefinir todas as configurações neste personagem para os valores padrão?"

L["OPTIONS_COMMANDS_HEADER"] = "/Comandos"
L["OPTIONS_COMMANDS_DESC"] = "Comandos de chat para o Water Dispenser. O painel de opções tem tudo de que você precisa; esses comandos são para quem prefere usar o teclado."
L["OPTIONS_COMMAND_WD"] = "/wd"
L["OPTIONS_COMMAND_WD_DESC"] = "Abre as opções do Water Dispenser."
L["OPTIONS_COMMAND_WD_FILL"] = "/wd fill"
L["OPTIONS_COMMAND_WD_FILL_DESC"] = "Preenche a janela de troca agora, mesmo se o modo automático estiver desligado."
L["OPTIONS_COMMAND_WD_CLEAR"] = "/wd clear"
L["OPTIONS_COMMAND_WD_CLEAR_DESC"] = "Limpa todos os espaços da janela de troca."
L["OPTIONS_COMMAND_WD_AUTO"] = "/wd auto solo||group||raid on||off"
L["OPTIONS_COMMAND_WD_AUTO_DESC"] = "Ativa ou desativa o preenchimento automático para o escopo fornecido. Omita on/off para inverter o estado atual."
L["OPTIONS_COMMAND_WDA"] = "/wda"
L["OPTIONS_COMMAND_WDA_DESC"] = "Envia a mensagem de anúncio para o canal que corresponde ao seu estado de grupo atual."

L["CHAT_RESET"] = "Todas as opções foram redefinidas para o padrão."

L["OPTIONS_ITEMS_DESC"] = "Configure quantas pilhas de cada item devem ser distribuídas. Nota: Classic Era e TBC Anniversary não suportam a divisão automática de pilhas."
L["OPTIONS_ITEMS_EMPTY"] = "Nenhum item configurado. Abra a aba \"Adicionar Item\" para inserir consumíveis das suas bolsas."

L["OPTIONS_ITEM_SETTINGS"] = "Configurações do Item"
L["OPTIONS_ITEM_USE_NOT_FULL"] = "Usar Pilhas Incompletas"
L["OPTIONS_ITEM_USE_NOT_FULL_DESC"] = "Quando não houver uma pilha cheia, preenche a troca com a menor pilha disponível que você tem."

L["OPTIONS_ITEM_FACTOR_LEVEL"] = "Considerar Requisitos de Nível"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] = "Ignora este item caso o parceiro de troca esteja abaixo do nível necessário para usá-lo."

L["OPTIONS_ITEM_KEEP_AT_LEAST"] = "Manter no mínimo"
L["OPTIONS_ITEM_KEEP_AT_LEAST_DESC"] = "Sempre guarde pelo menos essa quantidade nas suas bolsas. Tudo acima disso será considerado como disponível para doação."

L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "Incluir Quantidade Restante na Macro"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] = "Quando a macro anunciar este item, mostrará quantos você ainda tem. Desative caso prefira apenas dizer que tem o item (comum para Pedras de Vida)."

L["OPTIONS_ITEM_PLAYER_CLASSES"] = "Apenas Distribuir ao Jogar com Esta(s) Classe(s)"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] = "Preenche as trocas e inclui no anúncio somente se a classe do seu personagem estiver selecionada abaixo."

L["OPTIONS_ITEM_REMOVE"] = "Remover Item"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "Remover este item da configuração de troca?"

L["OPTIONS_SCOPE_SOLO"] = "Desconhecidos"
L["OPTIONS_SCOPE_GROUP"] = "Membros do Grupo"
L["OPTIONS_SCOPE_RAID"] = "Membros da Raide"

L["OPTIONS_ADD_DESC"] = "Selecione um consumível negociável das suas bolsas para a configuração. Itens já configurados ou vinculados não aparecerão."
L["OPTIONS_ADD_SELECT"] = "Itens disponíveis"
L["OPTIONS_ADD_BUTTON"] = "Adicionar à configuração"
L["OPTIONS_ADD_EMPTY"] = "Nenhum consumível elegível encontrado em suas bolsas."

L["SUPPORT_DESC"] = "Relate problemas, sugira recursos ou venha dizer um olá no Discord."
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"

L["OPTIONS_ANNOUNCEMENTS"] = "Anúncios"
L["OPTIONS_ANNOUNCEMENTS_DESC"] = "O Water Dispenser pode criar uma macro para anunciar o que você tem a distribuir. A macro escolhe o canal certo (/dizer, /grupo, /raide) e usa as quantidades reais das bolsas."

L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "Ativar Macro de Anúncio"
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] = "Mantém uma macro específica do personagem chamada \"- Dispenser\" sempre atualizada. Desativar exclui a macro."

L["OPTIONS_ANNOUNCEMENTS_PREVIEW_HEADER"] = "Prévia ao Vivo"
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DESC"] = "Isto é o que a macro dirá se você a pressionar agora."
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] = "Nada a anunciar. Configure os itens, reabasteça as bolsas ou baixe o valor de \"Manter no mínimo\"."

L["ANNOUNCEMENTS_INTRO"] = "Eu tenho"
L["ANNOUNCEMENTS_OUTRO"] = ". Abra troca!"
L["ANNOUNCEMENTS_AND"] = "e"

L["CHAT_MACRO_CREATED"] = "A macro de anúncio \"- Dispenser\" está pronta. Abra o Menu de Macros (/m) e arraste-a para a barra de ação."
L["CHAT_MACRO_DELETED"] = "Macro de anúncio \"- Dispenser\" deletada."
L["CHAT_MACRO_FULL"] = "Não foi possível criar a macro: todos os espaços de macro do personagem estão em uso."
L["CHAT_NOTHING_TO_ANNOUNCE"] = "Nada a anunciar no momento."

L["ITEM_MAGE_WATER"] = "Qualquer Água Conjurada"
L["ITEM_MAGE_FOOD"] = "Qualquer Comida Conjurada"
L["ITEM_WARLOCK_HEALTHSTONE"] = "Qualquer Pedra de Vida"