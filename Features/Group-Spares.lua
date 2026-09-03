local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

-- Addon-message prefix. The client caps these at 16 characters.
local ADDON_PREFIX = "WaterDispenser"

--[[
	Payload budget per message: the client's ceiling less 25 bytes of headroom for
	the "<chunk>/<total>|" header this file prepends.
]]
local MESSAGE_MAX_LENGTH = ns.CHAT_MESSAGE_MAX_LENGTH - 25

-- Healthstones are Common quality; the talent row has no single item to read it from.
local HEALTHSTONE_QUALITY = 1

-- Leading pad on each row, matching the other add-ons' tooltip blocks.
local ROW_INDENT = " "

-- Coalesces a burst of bag changes into one broadcast.
local BROADCAST_DEBOUNCE = 2

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

--[[
	What each group member last said they would hand over:
	receivedSpares[playerKey] = { Items = { [itemId] = { Count, ShowQuantity } }, Talent }.

	Runtime only. Nothing another player told us is ever written to disk, and the
	table is emptied when we leave a group.
]]
local receivedSpares = {}

-- Partial broadcasts, keyed by sender, until their last chunk arrives.
local incoming = {}

local broadcastTimer

-- True once the group has been told we have nothing, so it is said only once.
local sentEmpty = false

--------------------------------------------------------------------------------
-- Player Keys
--------------------------------------------------------------------------------

--[[
	One spelling of a player, "Name-Realm", so the tooltip can match what arrived
	over the wire. CHAT_MSG_ADDON already reports its sender that way, with the
	realm's spaces stripped; UnitName only appends a realm for a foreign one, so the
	local realm is filled in and stripped the same way.
]]
local function UnitKey(unit)
	local name, realm = UnitName(unit)
	if not name or name == "" then
		return nil
	end
	if not realm or realm == "" then
		realm = GetRealmName() or ""
	end
	return name .. "-" .. realm:gsub("%s+", "")
end

--------------------------------------------------------------------------------
-- Building the Offer
--------------------------------------------------------------------------------

--[[
	0, 1 or 2 for a warlock, nil for anyone else. Talents grant passive spells, so
	the highest rank the player knows is the rank they took.
]]
local function HealthstoneTalentRank()
	local _, class = UnitClass("player")
	if class ~= "WARLOCK" then
		return nil
	end

	local rank = 0
	for index, spellId in ipairs(ns.HEALTHSTONE_TALENT_SPELLS) do
		if (IsSpellKnown and IsSpellKnown(spellId)) or (IsPlayerSpell and IsPlayerSpell(spellId)) then
			rank = index
		end
	end
	return rank
end

--[[
	Item ID to how many of it this player is carrying, for every item on their
	Dispensed Items list.

	No distribution rules, no reserve, no class filter. Putting an item on the list
	is the statement that it is up for grabs, so the tooltip answers the only
	question left: how many have you got.

	Empty while Dispense is switched off. Someone not dispensing is not offering, so
	their own tooltip drops the block and the group is told they have nothing.
]]
local function BuildOffer()
	local offer = { Items = {} }
	if not ns.BuildTooltipSnapshot then
		return offer
	end
	if not (ns.db and ns.db.profile.Dispense) then
		return offer
	end

	for _, entry in ipairs(ns.BuildTooltipSnapshot()) do
		offer.Items[entry.Id] = { Count = entry.Count, ShowQuantity = entry.IncludeQuantity }
	end
	--[[
		The healthstone row's quantity preference travels with the talent rather than
		with a carried stone: a warlock holding none sends no healthstone item, and the
		row still has to know whether to print its 0.
	]]
	offer.Talent = HealthstoneTalentRank()
	if offer.Talent then
		local config = ns.db.profile.Items.WarlockHealthstone
		local show = config and config.IncludeQuantity
		if show == nil then
			show = true
		end
		offer.TalentShowQuantity = show
	end

	return offer
end

--------------------------------------------------------------------------------
-- Wire Format
--------------------------------------------------------------------------------

--[[
	"<chunk>/<total>|<itemId>:<count>;..", the count being how many they carry. An
	item whose quantity is switched off sends a third field, "<itemId>:<count>:0",
	left out otherwise so the common case stays short. A warlock also sends
	"H:<rank>", their Improved Healthstone rank, which is not an item and so cannot
	collide with an item chunk.

	Chunked because a player with many configured items overruns one message, and a
	silently truncated list is worse than a slow one. A receiver resets its buffer on
	chunk 1, so a broadcast that starts again mid-way simply replaces the old one.
]]
local function EncodeOffer(offer)
	local parts = {}
	for itemId, item in pairs(offer.Items) do
		parts[#parts + 1] = itemId .. ":" .. item.Count .. (item.ShowQuantity and "" or ":0")
	end
	table.sort(parts)
	if offer.Talent then
		table.insert(parts, 1, "H:" .. offer.Talent .. (offer.TalentShowQuantity and "" or ":0"))
	end

	local messages, current = {}, ""
	for _, part in ipairs(parts) do
		local candidate = (current == "") and part or (current .. ";" .. part)
		if #candidate > MESSAGE_MAX_LENGTH then
			messages[#messages + 1] = current
			current = part
		else
			current = candidate
		end
	end
	messages[#messages + 1] = current
	return messages
end

local function DecodeInto(target, payload)
	for chunk in payload:gmatch("[^;]+") do
		local talent, talentShown = chunk:match("^H:(%d):?(%d*)$")
		if talent then
			target.Talent = tonumber(talent)
			target.TalentShowQuantity = talentShown ~= "0"
		else
			local itemId, count, shown = chunk:match("^(%d+):(%d+):?(%d*)$")
			itemId, count = tonumber(itemId), tonumber(count)
			if itemId and count and count > 0 then
				target.Items[itemId] = { Count = count, ShowQuantity = shown ~= "0" }
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Broadcasting
--------------------------------------------------------------------------------

--[[
	Sends the current offer to the group. Silent when ungrouped (there is nobody to
	tell), when sharing is switched off, or in combat, where the client can drop
	addon traffic and nobody is reading tooltips anyway.
]]
local function Broadcast()
	broadcastTimer = nil
	if ns.IsInCombat() then
		return
	end

	local channel = ns.GetGroupChatChannel()
	if not channel then
		return
	end
	if not (C_ChatInfo and C_ChatInfo.SendAddonMessage) then
		return
	end

	--[[
		An empty offer is still worth sending once: it clears us from everyone's
		tooltip when Dispense goes off or the last item leaves the bags. Repeating it
		afterwards would be pure noise, so the empty state is announced exactly once.
	]]
	--[[
		Sharing off is broadcast as an empty offer rather than silence, so the group
		stops showing a list we are no longer standing behind. Reading tooltips is the
		master switch, so it gates this as well as the block itself.
	]]
	local sharing = ns.db and ns.db.profile.ShowInventoryTooltips and ns.db.profile.ShareInventory
	local offer = sharing and BuildOffer() or { Items = {} }
	local isEmpty = next(offer.Items) == nil and offer.Talent == nil
	if isEmpty and sentEmpty then
		return
	end
	sentEmpty = isEmpty

	local messages = EncodeOffer(offer)
	local total = #messages
	for index, payload in ipairs(messages) do
		C_ChatInfo.SendAddonMessage(ADDON_PREFIX, index .. "/" .. total .. "|" .. payload, channel)
	end
end

local function ScheduleBroadcast()
	if broadcastTimer then
		return
	end
	broadcastTimer = C_Timer.NewTimer(BROADCAST_DEBOUNCE, Broadcast)
end

--------------------------------------------------------------------------------
-- Receiving
--------------------------------------------------------------------------------

local function OnAddonMessage(_, prefix, message, _, sender)
	if prefix ~= ADDON_PREFIX or not sender then
		return
	end

	local index, total, payload = message:match("^(%d+)/(%d+)|(.*)$")
	index, total = tonumber(index), tonumber(total)
	if not index or not total then
		return
	end

	-- Chunk 1 replaces whatever that player last sent, rather than merging into it.
	if index == 1 then
		incoming[sender] = { Items = {} }
	end
	local buffer = incoming[sender]
	if not buffer then
		return
	end

	DecodeInto(buffer, payload)
	if index >= total then
		receivedSpares[sender] = buffer
		incoming[sender] = nil
	end
end

-- Nothing is kept for players we are no longer grouped with.
local function PruneToGroup()
	if not ns.GetGroupChatChannel() then
		wipe(receivedSpares)
		wipe(incoming)
		return
	end
	for playerKey in pairs(receivedSpares) do
		if not UnitInParty(playerKey) and not UnitInRaid(playerKey) then
			receivedSpares[playerKey] = nil
			incoming[playerKey] = nil
		end
	end
end

--------------------------------------------------------------------------------
-- Tooltip
--------------------------------------------------------------------------------

local function QualityColor(quality)
	return ns.ITEM_QUALITY_COLORS[quality or 1] or ns.ITEM_QUALITY_COLORS[1]
end

-- The rows for one player, sorted by name. Nil when there is nothing to show, so
-- the caller adds no heading to an empty block.
local function BuildRows(offer, isWarlock)
	local rows = {}
	local healthstones = 0

	for itemId, item in pairs(offer.Items) do
		if isWarlock and ns.ITEM_TO_COLLECTION[itemId] == "WarlockHealthstone" then
			-- Folded into the talent row below rather than listed as its own item.
			healthstones = healthstones + item.Count
		else
			local name, _, quality = ns.GetItemInfo(itemId)
			if name then
				rows[#rows + 1] = { Name = name, Quality = quality, Amount = item.ShowQuantity and item.Count or nil }
			end
		end
	end

	--[[
		A warlock always gets a healthstone row, carrying none included. Which of the
		three talent variants they make is what a raid coordinates around, and that is
		true whether or not one is in their bags right now.
	]]
	if isWarlock and offer.Talent then
		rows[#rows + 1] = {
			Name = format(L["TOOLTIP_HEALTHSTONE"], offer.Talent, #ns.HEALTHSTONE_TALENT_SPELLS),
			Quality = HEALTHSTONE_QUALITY,
			Amount = offer.TalentShowQuantity and healthstones or nil,
		}
	end
	if #rows == 0 then
		return nil
	end

	table.sort(rows, function(a, b)
		return a.Name < b.Name
	end)
	return rows
end

local function AddSpareBlock(tooltip, unit)
	if not (ns.db and ns.db.profile.ShowInventoryTooltips) then
		return
	end
	if ns.IsInCombat() or not UnitIsPlayer(unit) then
		return
	end

	--[[
		Own tooltip is built from local data and shows everywhere, grouped or not:
		it is the only way to see what the add-on is offering on your behalf. Anyone
		else has to be in the group and to have told us something.
	]]
	local offer
	if UnitIsUnit(unit, "player") then
		offer = BuildOffer()
	elseif UnitInParty(unit) or UnitInRaid(unit) then
		offer = receivedSpares[UnitKey(unit)]
	end
	if not offer then
		return
	end

	local _, unitClass = UnitClass(unit)
	local rows = BuildRows(offer, unitClass == "WARLOCK")
	if not rows then
		return
	end

	--[[
		The same branded line a chat print carries: blue name, gray separator, white
		body. Item names keep their quality color rather than the silver other add-ons
		use for a plain label, because here the label is an item.
	]]
	tooltip:AddLine(" ")
	tooltip:AddLine(ns.BuildBrandedLine(L["TOOLTIP_OPEN_TRADE"]))
	for _, row in ipairs(rows) do
		-- Quantity switched off keeps the name column and drops the number.
		tooltip:AddDoubleLine(
			ROW_INDENT .. "|cff" .. QualityColor(row.Quality) .. row.Name .. "|r",
			row.Amount and (GetColor("TEXT") .. row.Amount .. "|r") or ""
		)
	end
	tooltip:Show()
end

--[[
	One tooltip system. TooltipDataProcessor arrived in Dragonflight and was never
	backported: the Diagnostic Tools API probe reports it absent on Era 1.15.9, which
	carries every other modern namespace this add-on uses, so the pre-Dragonflight
	script is what both supported flavors have. Do not add the modern branch back
	without a client that actually passes that probe.
]]
local function HookTooltip()
	GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
		local _, unit = tooltip:GetUnit()
		if unit then
			AddSpareBlock(tooltip, unit)
		end
	end)
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function ns.InitGroupSpares()
	if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
		C_ChatInfo.RegisterAddonMessagePrefix(ADDON_PREFIX)
	end

	HookTooltip()

	ns.RegisterEvent("CHAT_MSG_ADDON", OnAddonMessage)
	-- Bag changes settle into one broadcast; BAG_UPDATE_DELAYED fires once per batch.
	ns.RegisterEvent("BAG_UPDATE_DELAYED", ScheduleBroadcast)
	ns.RegisterEvent("GROUP_ROSTER_UPDATE", function()
		PruneToGroup()
		-- Someone who just joined has heard nothing from us yet.
		ScheduleBroadcast()
	end)
	ns.RegisterEvent("PLAYER_ENTERING_WORLD", ScheduleBroadcast)
	-- Also fires on a talent change, which moves a warlock's healthstone rank.
	ns.RegisterEvent("SPELLS_CHANGED", ScheduleBroadcast)
end

-- The options panel rebroadcasts through this after a rule changes.
ns.RefreshGroupSpares = ScheduleBroadcast
