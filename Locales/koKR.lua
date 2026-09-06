local L = LibStub("AceLocale-3.0"):NewLocale("WaterDispenser", "koKR")
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
	"버전 %s. 설정(이 메시지를 끄는 옵션 포함)은 옵션 > 애드온 > Water Dispenser에서 찾을 수 있습니다. 이 애드온이 마음에 드시나요? 친구에게 알려주세요! (="
L["CHAT_NO_TRADE"] = "활성화된 거래 창이 없습니다."
L["CHAT_COMBAT_BLOCKED"] = "WoW는 전투 중 자동 거래를 차단합니다."
L["CHAT_OPTIONS_IN_COMBAT"] = "안전을 위해 전투 중에는 설정 창을 열 수 없습니다."
-- The item and its count are appended after the colon by the code.
L["CHAT_MISSING_STACK"] = "부족:"
--[[
	%s is the item's name, %d the Maximum per Session it has hit.
	"Maximum per Session" must match OPTIONS_ITEM_SESSION_CAP.
]]
L["CHAT_SESSION_CAP_REACHED"] =
	"%s은(는) 추가되지 않았습니다: 이번 세션에 이미 %d개를 받았습니다. 세션당 최대량을 변경하거나, 다시 불러와 초기화하세요."
-- %s is the item's name, %d the amount that could not be split off.
L["CHAT_SPLIT_REFUSED"] =
	"%s은(는) 추가되지 않았습니다: 이 클라이언트가 묶음에서 %d개를 나누지 못했고, 대신 묶음 전체를 건네면 요청한 것보다 훨씬 많이 주게 됩니다. 이 아이템의 수량을 묶음 전체로 설정하면 거래할 수 있습니다."
-- %s is the player's class name. "Dispensed Items" must match TAB_DISPENSED_ITEMS.
L["CHAT_NONE_ACTIVE_FOR_CLASS"] =
	"%s(으)로 플레이하는 동안 분배하도록 설정된 아이템이 없습니다. 옵션 > 분배 아이템을 열어 이 직업에 대한 아이템을 활성화하세요."
-- "- Dispenser" is the macro's literal name and is never translated.
L["CHAT_MACRO_DELETED"] = '"- Dispenser" 알림 매크로가 삭제되었습니다.'
L["CHAT_MACRO_FULL"] = "캐릭터 전용 매크로 슬롯이 꽉 차서 매크로를 만들 수 없습니다."

--------------------------------------------------------------------------------
-- Player Tooltips
--------------------------------------------------------------------------------

L["TOOLTIP_OPEN_TRADE"] = "거래를 거세요!"
-- %d/%d is the warlock's Improved Healthstone rank out of its maximum.
L["TOOLTIP_HEALTHSTONE"] = "생명석 (등급 %d/%d)"

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BUTTON_CLEAR"] = "거래 창 비우기"
L["BUTTON_FILL"] = "거래 창 채우기"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

-- The tooltip's feature row reuses TAB_DISPENSE for its name; these are its state and click words.
L["UI_ENABLED"] = "활성화됨"
L["UI_DISABLED"] = "비활성화됨"
L["UI_LEFT_CLICK"] = "좌클릭"
L["UI_TOGGLE"] = "켜기/끄기"
L["MINIMAP_OPTIONS"] = "Water Dispenser 설정"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + 가운데 클릭"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"손쉬운 소비 아이템 분배. 거래 창을 물, 음식, 생명석으로 자동으로 채웁니다. 모래시계 모래나 저항력 물약처럼 원하는 아이템을 무엇이든 추가해 공격대에 나눠 주세요."

L["OPTIONS_WELCOME_MESSAGE"] = "환영 메시지 사용"
L["OPTIONS_WELCOME_MESSAGE_DESC"] =
	"Water Dispenser를 불러올 때 대화창에 한 줄짜리 인사말을 출력합니다."
L["OPTIONS_MINIMAP"] = "미니맵 버튼 사용"
L["OPTIONS_MINIMAP_DESC"] = "Water Dispenser 미니맵 버튼을 표시합니다."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "수량이 부족할 때 경고 사용"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] =
	"설정한 수량을 줄 만큼 해당 아이템이 가방에 없을 때 대화창에 알림을 출력합니다."
-- The label says what it does; the tooltip only covers why it is needed and when it stands down.
L["OPTIONS_RESTACK"] = "가방의 남은 묶음 자동 합치기"
L["OPTIONS_RESTACK_DESC"] =
	"창조된 물과 음식은 시전할 때마다 새 가방 칸에 들어가고 게임은 이를 다시 합쳐 주지 않지만, 전투 중이거나 거래 창이 열려 있거나 커서에 무언가를 들고 있을 때는 절대 실행되지 않습니다."

L["OPTIONS_COMMANDS_HEADER"] = "/명령어"
L["OPTIONS_COMMAND"] = "/wd"
L["OPTIONS_COMMAND_DESCRIPTION"] = "이 애드온의 설정 창을 엽니다."

-- Names the panel, its section header, and the mini-map tooltip's feature row.
L["TAB_DISPENSE"] = "분배"
L["OPTIONS_DISPENSE_DESC"] = "거래가 열리면 거래 창을 자동으로 채웁니다."
L["OPTIONS_DISPENSE_MASTER"] = "분배 활성화"
L["OPTIONS_DISPENSE_MASTER_DESC"] = "설정에 따라 거래 창을 자동으로 채웁니다."
L["OPTIONS_DISPENSE_SOLO"] = "모르는 사람에게 사용"
L["OPTIONS_DISPENSE_SOLO_DESC"] =
	"파티나 공격대에 속하지 않은 사람과 거래할 때 거래 창을 자동으로 채웁니다."
L["OPTIONS_DISPENSE_GROUP"] = "파티에 사용"
L["OPTIONS_DISPENSE_GROUP_DESC"] = "파티원과 거래할 때 거래 창을 자동으로 채웁니다."
L["OPTIONS_DISPENSE_RAID"] = "공격대에 사용"
L["OPTIONS_DISPENSE_RAID_DESC"] = "공격대원과 거래할 때 거래 창을 자동으로 채웁니다."

L["TAB_INVENTORY_TOOLTIPS"] = "보유 목록 툴팁"
L["OPTIONS_TOOLTIPS_DESC"] =
	"Water Dispenser를 사용하는 파티원의 플레이어 툴팁에 나눠 줄 수 있는 보유 목록을 표시합니다."
L["OPTIONS_SHOW_INVENTORY"] = "플레이어 툴팁에 보유 목록 표시"
L["OPTIONS_SHOW_INVENTORY_DESC"] =
	"플레이어 툴팁에 Water Dispenser 항목을 추가해 그들이 나눠 주도록 설정한 것과 보유 수량을 보여 주며, 본인의 목록은 파티 여부와 관계없이 항상 표시됩니다."
L["OPTIONS_SHARE_INVENTORY"] = "내 보유 목록 공유"
L["OPTIONS_SHARE_INVENTORY_DESC"] =
	"파티와 공격대에 자신이 무엇을 가지고 있는지 알려 상대가 마우스를 올렸을 때 보유 목록이 나타나게 하되, 대화창에는 아무것도 게시하지 않고 파티 밖의 누구에게도 전달하지 않으며, 이 옵션을 꺼도 다른 사람의 목록은 계속 볼 수 있습니다."

L["OPTIONS_COMBAT_HEADER"] = "전투"
L["OPTIONS_COMBAT_DESC"] =
	"WoW는 전투 중 애드온이 거래 창으로 아이템을 옮기는 것을 차단합니다."
L["OPTIONS_COMBAT_NOTIFY"] = "분배가 차단되었을 때 알림 사용"
L["OPTIONS_COMBAT_NOTIFY_DESC"] =
	"전투로 인해 거래를 채우지 못했을 때 대화창에 알림을 출력하며, 이 옵션을 끄면 Water Dispenser는 거래가 비어 있는 이유를 알려 주지 않습니다."

--------------------------------------------------------------------------------
-- Options — Dispensed Items
--------------------------------------------------------------------------------

L["TAB_DISPENSED_ITEMS"] = "분배 아이템"
L["OPTIONS_ITEMS_DESC"] =
	"각 아이템을 얼마나 분배할지 설정하세요. 수량은 묶음이 아니라 개수로 세므로 물 20개는 물 20개, 물약 1개는 물약 1개입니다. 필요하면 묶음을 정확한 수량만큼 쪼갭니다."
-- "Add an Item" must match OPTIONS_ADD_ITEM.
L["OPTIONS_ITEMS_EMPTY"] =
	'설정된 아이템이 없습니다. 목록에서 "아이템 추가"를 선택하여 가방에 있는 소비 아이템을 추가하세요.'

L["OPTIONS_ITEM_DISTRIBUTION"] = "분배량"
L["OPTIONS_ITEM_DISTRIBUTION_DESC"] =
	"거래 상대가 모르는 사람인지, 파티원인지, 공격대원인지에 따라 각 직업이 얼마나 받을지 정하세요. 묶음이 아니라 개수로 셉니다. 0이면 이 아이템을 절대 주지 않습니다."
L["OPTIONS_ITEM_EVERYONE"] = "전체"
L["OPTIONS_ITEM_EVERYONE_DESC"] =
	"Enter를 누르면 이 수량을 모든 직업에 한 번에 적용하며, 아래 직업들의 값이 서로 다르면 빈칸으로 표시됩니다."
-- The accept button inside every number box in this panel.
L["OPTIONS_ITEM_APPLY"] = "적용"
-- %d is the highest amount this item accepts, which is 1 for anything unique.
L["OPTIONS_ITEM_COUNT_TOO_HIGH"] =
	"이 아이템이 분배할 수 있는 양보다 많습니다. 최대 %d개까지 가능합니다."
L["OPTIONS_ITEM_COUNT_INVALID"] =
	"아이템 개수를 입력하거나, 절대 분배하지 않으려면 0을 입력하세요."
L["OPTIONS_ITEM_SETTINGS"] = "아이템 설정"
-- "In Group" and "In Raid" in the tooltip must match the two dropdown entries below.
L["OPTIONS_ITEM_DISTRIBUTE"] = "분배 범위"
L["OPTIONS_ITEM_DISTRIBUTE_DESC"] =
	"이 아이템을 언제 나눠 줄지 정하며, 선택한 범위를 벗어나면 거래되지도, 알림에 포함되지도, 툴팁에 표시되지도 않고, 파티에서는 파티와 공격대를 모두 포함하며 공격대에서는 공격대만 해당합니다."
-- Dropdown entries. The stored values are "Always", "Group", and "Raid"; these are only their labels.
L["OPTIONS_ITEM_DISTRIBUTE_ALWAYS"] = "항상"
L["OPTIONS_ITEM_DISTRIBUTE_GROUP"] = "파티에서"
L["OPTIONS_ITEM_DISTRIBUTE_RAID"] = "공격대에서"
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "사용 레벨 조건 확인"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] =
	"거래 대상의 레벨이 아이템의 요구 레벨보다 낮으면 이 아이템을 건너뜁니다."
L["OPTIONS_ITEM_RESERVE"] = "예비 수량 사용"
L["OPTIONS_ITEM_RESERVE_DESC"] =
	"가방에 항상 최소 이만큼은 남겨 두며, 분배와 알림 매크로는 그 수를 넘는 수량만 나눠 줄 수 있는 것으로 취급합니다."
L["OPTIONS_ITEM_SESSION_CAP"] = "세션당 최대량 사용"
L["OPTIONS_ITEM_SESSION_CAP_DESC"] =
	"상대가 이만큼을 받고 나면 접속을 종료하거나 다시 불러올 때까지 모든 거래를 통틀어 이 아이템을 더 주지 않으며, 이 아이템의 수량을 하나라도 바꾸면 모두의 누적이 초기화됩니다."
-- The label carries the meaning on its own; the tooltip only says why you'd switch it off.
L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "플레이어 툴팁과 알림 매크로에 수량 포함"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] =
	"끄면 아이템 옆에 수량 없이 이름만 표시되며, 생명석처럼 하나만 가지고 다니는 아이템은 그 편이 더 자연스럽습니다."
L["OPTIONS_ITEM_PLAYER_CLASSES"] = "특정 직업일 때만 분배"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] =
	"본인 캐릭터의 직업이 아래에서 선택되어 있을 때만 거래를 채우고, 알림 매크로에 넣고, 플레이어 툴팁에 표시합니다."
L["OPTIONS_ITEM_REMOVE"] = "아이템 제거"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "거래 설정에서 이 아이템을 제거하시겠습니까?"

L["OPTIONS_SCOPE_SOLO"] = "모르는 사람"
L["OPTIONS_SCOPE_GROUP"] = "파티"
L["OPTIONS_SCOPE_RAID"] = "공격대"

L["OPTIONS_ADD_ITEM"] = "아이템 추가"
L["OPTIONS_ADD_DESC"] =
	"거래 설정에 추가할 거래 가능한 아이템을 가방에서 선택하세요. 이미 설정되었거나 귀속된 아이템은 표시되지 않습니다."
L["OPTIONS_ADD_SELECT"] = "사용 가능 아이템"
L["OPTIONS_ADD_BUTTON"] = "설정에 추가"
L["OPTIONS_ADD_EMPTY"] = "가방에서 거래 가능한 아이템을 찾을 수 없습니다."

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["TAB_ANNOUNCEMENTS"] = "알림"
L["OPTIONS_ANNOUNCEMENTS_DESC"] =
	"Water Dispenser는 나눠 줄 수 있는 물품을 알리는 매크로를 만들 수 있습니다. 매크로는 알맞은 채널을 자동으로 고르고(파티가 없으면 일반, 파티에서는 파티, 공격대에서는 공격대) 가방의 최신 수량을 그대로 사용합니다."
L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "알림 매크로 사용"
-- "- Dispenser" is the macro's literal name and is never translated.
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] =
	'"- Dispenser"라는 캐릭터 전용 매크로를 현재 나눔 목록에 맞게 항상 최신화하며, 이 옵션을 끄면 매크로를 삭제합니다.'
-- "Enable Reserves" must match OPTIONS_ITEM_RESERVE.
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] =
	"알릴 내용이 없습니다. 아이템을 설정하거나, 가방을 채우거나, 예비 수량 사용에서 값을 낮추세요."

-- Macro message template (%s is the item list) and the connector before the last list entry.
L["ANNOUNCEMENTS_BODY"] = "%s 보유 중입니다. 거래를 거세요!"
L["ANNOUNCEMENTS_AND"] = "및"

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["OPTIONS_SUPPORT"] = "피드백 및 지원"
-- Precedes the version number on the General panel's last line.
L["VERSION"] = "버전"
L["SUPPORT_CURSEFORGE"] = "CurseForge"
L["SUPPORT_GITHUB"] = "GitHub"
L["SUPPORT_DISCORD"] = "Discord"
L["SUPPORT_WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Built-in Collections
--------------------------------------------------------------------------------

L["ITEM_MAGE_WATER"] = "창조된 물"
L["ITEM_MAGE_FOOD"] = "창조된 음식"
L["ITEM_WARLOCK_HEALTHSTONE"] = "생명석"
