local _, ns = ...

local L = ns.L

--------------------------------------------------------------------------------
-- Trade Status Line
--------------------------------------------------------------------------------

-- The partner as the status line names them; nil only if the trade opened without one.
function ns.TradePartnerName()
	return ns.NameWithoutRealm(ns.State.Trade.Partner) or "?"
end

-- Built-ins in their display order, then user items by key, so the reason shown never depends on pairs().
local function FirstInItemOrder(byKey)
	for _, key in ipairs(ns.BUILTIN_ORDER) do
		if byKey[key] then
			return byKey[key]
		end
	end
	local keys = {}
	for key in pairs(byKey) do
		keys[#keys + 1] = key
	end
	table.sort(keys, function(a, b)
		return tostring(a) < tostring(b)
	end)
	return keys[1] and byKey[keys[1]]
end

--[[
	"Added" plus what the player's side of the window holds, read from the window
	itself so a stack dragged in by hand or conjured mid-trade counts too. With the
	window empty: the trade-wide note, else the first item the fill held back.
]]
function ns.RefreshTradeStatus()
	local trade = ns.State.Trade
	if not (trade.Active and ns.TradeUI) then
		return
	end

	local totals, order = {}, {}
	for slot = 1, MAX_TRADABLE_ITEMS do
		local link = GetTradePlayerItemLink(slot)
		local _, _, slotCount = GetTradePlayerItemInfo(slot)
		local itemId = link and tonumber(link:match("item:(%d+)"))
		if itemId and slotCount and slotCount > 0 then
			if not totals[itemId] then
				order[#order + 1] = itemId
				totals[itemId] = 0
			end
			totals[itemId] = totals[itemId] + slotCount
		end
	end

	local text
	if #order > 0 then
		local parts = {}
		for _, itemId in ipairs(order) do
			local name = C_Item.GetItemInfo(itemId) or ("item:" .. itemId)
			parts[#parts + 1] = format(L["FORMAT_ITEM_COUNT"], name, totals[itemId])
		end
		text = format(L["TRADE_STATUS_ADDED"], ns.JoinList(parts))
		local short = FirstInItemOrder(trade.ShortNotes)
		if short then
			text = text .. " " .. short
		end
	else
		text = trade.Note or FirstInItemOrder(trade.HoldReasons)
	end
	trade.Status = text
	ns.TradeUI:SetStatus(text)
end

-- Starts a trade's status from nothing: a fresh trade, or a fill pass about to record its own reasons.
function ns.ResetTradeStatus(note)
	local trade = ns.State.Trade
	trade.Note = note
	wipe(trade.HoldReasons)
	wipe(trade.ShortNotes)
end
