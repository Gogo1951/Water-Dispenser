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

-- All player-facing chat prints live here, regardless of which feature emits them.
L["CHAT_LOADED"] =
	"버전 %s. 설정(이 메시지를 끄는 옵션 포함)은 옵션 > 애드온 > Water Dispenser에서 찾을 수 있습니다. Water Dispenser가 마음에 드시나요? 친구에게 알려주세요! (="
L["CHAT_NO_TRADE"] = "활성화된 거래 창이 없습니다."
L["CHAT_COMBAT_PAUSED"] = "전투 중에는 분배가 일시 정지됩니다."
L["CHAT_COMBAT_RESUMED"] = "전투 종료. 분배를 재개합니다."
L["CHAT_MISSING_STACK"] = "부족:"
L["CHAT_NONE_ACTIVE_FOR_CLASS"] =
	"%s(으)로 플레이하는 동안 분배하도록 설정된 아이템이 없습니다. 옵션 > 분배 규칙을 열어 이 직업에 대한 아이템을 활성화하세요."
L["CHAT_ITEM_SAVED"] = "저장됨:"
L["CHAT_ITEM_REMOVED"] = "제거됨:"
L["CHAT_MACRO_CREATED"] =
	'"- Dispenser" 알림 매크로가 준비되었습니다. 매크로 창(게임 메뉴 > 매크로 또는 /m)을 열고 행동 단축바에 끌어다 놓으세요.'
L["CHAT_MACRO_DELETED"] = '"- Dispenser" 알림 매크로가 삭제되었습니다.'
L["CHAT_MACRO_FULL"] = "캐릭터 전용 매크로 슬롯이 꽉 차서 매크로를 만들 수 없습니다."

--------------------------------------------------------------------------------
-- Trade Side Panel
--------------------------------------------------------------------------------

L["BUTTON_CLEAR"] = "거래 창 비우기"
L["BUTTON_FILL"] = "거래 창 채우기"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["MINIMAP_DISPENSE"] = "분배"
L["UI_ENABLED"] = "활성화됨"
L["UI_DISABLED"] = "비활성화됨"
L["UI_LEFT_CLICK"] = "좌클릭"
L["UI_TOGGLE"] = "켜기/끄기"
L["MINIMAP_OPTIONS"] = "Water Dispenser 설정"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + 가운데 클릭"

--------------------------------------------------------------------------------
-- Options — General
--------------------------------------------------------------------------------

L["OPTIONS_DESC"] =
	"거래 대상의 직업, 레벨 및 파티 상태에 따라 물, 음식, 생명석 또는 기타 설정한 소비 용품을 거래 창에 자동으로 채웁니다."

L["OPTIONS_WELCOME_MESSAGE"] = "환영 메시지 사용"
L["OPTIONS_WELCOME_MESSAGE_DESC"] =
	"Water Dispenser가 불러와질 때 대화창에 짧은 인사말을 출력합니다."
L["OPTIONS_MINIMAP"] = "미니맵 버튼 사용"
L["OPTIONS_MINIMAP_DESC"] = "Water Dispenser 미니맵 버튼을 표시합니다."
L["OPTIONS_MISSING_STACK_WARNINGS"] = "묶음 부족 경고 사용"
L["OPTIONS_MISSING_STACK_WARNINGS_DESC"] =
	"설정된 아이템이 거래 창을 채울 만큼 가방에 충분하지 않을 때 대화창에 메시지를 표시합니다."

L["OPTIONS_COMMANDS"] = "/명령어"
L["OPTIONS_COMMANDS_WD"] = "Water Dispenser 설정 창을 엽니다."

L["OPTIONS_DISPENSE_HEADER"] = "분배"
L["OPTIONS_DISPENSE_DESC"] =
	"거래가 열리면 거래 창을 자동으로 채웁니다. 아래 각 옵션을 개별적으로 켜고 끄십시오."
L["OPTIONS_DISPENSE_MASTER"] = "분배 활성화"
L["OPTIONS_DISPENSE_MASTER_DESC"] = "설정에 따라 거래 창을 자동으로 채웁니다."
L["OPTIONS_DISPENSE_SOLO"] = "모르는 사람에게 채우기"
L["OPTIONS_DISPENSE_SOLO_DESC"] =
	"파티나 공격대에 속하지 않은 사람과 거래할 때 창을 자동으로 채웁니다."
L["OPTIONS_DISPENSE_GROUP"] = "파티원에게 채우기"
L["OPTIONS_DISPENSE_GROUP_DESC"] = "파티원과 거래할 때 창을 자동으로 채웁니다."
L["OPTIONS_DISPENSE_RAID"] = "공격대원에게 채우기"
L["OPTIONS_DISPENSE_RAID_DESC"] = "공격대원과 거래할 때 창을 자동으로 채웁니다."

L["OPTIONS_COMBAT_HEADER"] = "전투"
L["OPTIONS_COMBAT_DESC"] =
	"인터페이스 오류를 방지하기 위해 전투 중에는 분배가 항상 일시 정지됩니다. 이때 채팅 메시지로 알려 줍니다. 거래 창이 아직 열려 있다면 전투가 끝난 뒤 자동으로 재개됩니다."

--------------------------------------------------------------------------------
-- Options — Distribution Rules
--------------------------------------------------------------------------------

L["OPTIONS_ITEMS"] = "분배 규칙"
L["OPTIONS_ITEMS_DESC"] =
	"각 아이템의 분배할 묶음 수를 설정합니다. 주의: 클래식 시대 서버 및 불타는 성전 서버는 자동 묶음 나누기를 지원하지 않습니다. 죄송합니다!"
L["OPTIONS_ITEMS_EMPTY"] =
	'설정된 아이템이 없습니다. "아이템 추가" 탭을 열어 가방에 있는 소비 아이템을 추가하세요.'

L["OPTIONS_ITEM_SETTINGS"] = "아이템 설정"
L["OPTIONS_ITEM_USE_NOT_FULL"] = "부족한 묶음으로 채우기"
L["OPTIONS_ITEM_USE_NOT_FULL_DESC"] =
	"가득 찬 묶음이 없을 경우, 가방에 있는 적은 수량의 묶음으로 거래 창을 채웁니다."
L["OPTIONS_ITEM_FACTOR_LEVEL"] = "요구 레벨 조건 확인"
L["OPTIONS_ITEM_FACTOR_LEVEL_DESC"] =
	"거래 대상의 레벨이 아이템 사용 요구 레벨보다 낮으면 거래를 생략합니다."
L["OPTIONS_ITEM_KEEP_AT_LEAST"] = "최소 보유 수량"
L["OPTIONS_ITEM_KEEP_AT_LEAST_DESC"] =
	"가방에 항상 최소 이만큼은 남겨 둡니다. 분배와 알림 매크로는 이 수를 넘는 수량을 나눠 줄 수 있는 것으로 취급합니다."
L["OPTIONS_ITEM_INCLUDE_QUANTITY"] = "알림 매크로에 남은 수량 포함"
L["OPTIONS_ITEM_INCLUDE_QUANTITY_DESC"] =
	"매크로에서 아이템을 알릴 때 남은 개수를 포함합니다. (생명석과 같이) 개수 없이 가지고 있다는 것만 알리려면 끄세요."
L["OPTIONS_ITEM_PLAYER_CLASSES"] = "특정 직업일 때만 분배"
L["OPTIONS_ITEM_PLAYER_CLASSES_DESC"] =
	"본인 캐릭터의 직업이 아래 선택 항목과 일치할 때만 거래를 채우고 알림에 포함합니다."
L["OPTIONS_ITEM_REMOVE"] = "아이템 제거"
L["OPTIONS_ITEM_REMOVE_CONFIRM"] = "거래 설정에서 이 아이템을 제거하시겠습니까?"

L["OPTIONS_SCOPE_SOLO"] = "모르는 사람"
L["OPTIONS_SCOPE_GROUP"] = "파티원"
L["OPTIONS_SCOPE_RAID"] = "공격대원"

L["OPTIONS_ADD_ITEM"] = "아이템 추가"
L["OPTIONS_ADD_DESC"] =
	"가방에서 설정에 추가할 거래 가능한 소비 용품을 선택하세요. 이미 설정되었거나 귀속된 아이템은 표시되지 않습니다."
L["OPTIONS_ADD_SELECT"] = "사용 가능 아이템"
L["OPTIONS_ADD_BUTTON"] = "설정에 추가"
L["OPTIONS_ADD_EMPTY"] = "가방에 추가할 수 있는 소비 용품이 없습니다."

--------------------------------------------------------------------------------
-- Options — Announcements
--------------------------------------------------------------------------------

L["OPTIONS_ANNOUNCEMENTS"] = "알림"
L["OPTIONS_ANNOUNCEMENTS_DESC"] =
	"Water Dispenser는 나눠 줄 수 있는 물품을 알리는 매크로를 만들 수 있습니다. 매크로는 알맞은 채널을 자동으로 고르고(파티가 없으면 일반, 파티에서는 파티, 공격대에서는 공격대) 가방의 최신 수량을 사용합니다."
L["OPTIONS_ANNOUNCEMENTS_ENABLE"] = "알림 매크로 사용"
L["OPTIONS_ANNOUNCEMENTS_ENABLE_DESC"] =
	'"- Dispenser"라는 캐릭터 전용 매크로를 나눔 목록에 맞게 항상 최신화합니다. 비활성화 시 매크로가 삭제됩니다.'
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_HEADER"] = "미리보기"
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_DESC"] = "지금 매크로를 클릭했을 때 전송될 메시지입니다."
L["OPTIONS_ANNOUNCEMENTS_PREVIEW_EMPTY"] =
	'알릴 내용이 없습니다. 아이템을 설정하거나, 가방을 채우거나, "최소 보유 수량" 값을 낮추세요.'

-- Macro message template (%s is the item list) and the connector before the last list entry.
L["ANNOUNCEMENTS_BODY"] = "%s 보유 중입니다. 거래를 거세요!"
L["ANNOUNCEMENTS_AND"] = "및"

--------------------------------------------------------------------------------
-- Options — Support
--------------------------------------------------------------------------------

L["OPTIONS_SUPPORT"] = "피드백 및 지원"
L["SUPPORT_DESC"] = "Discord에서 버그를 제보하거나 새로운 기능을 요청하고 인사해 주세요."
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
