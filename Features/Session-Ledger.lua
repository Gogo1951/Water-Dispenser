local _, ns = ...

--------------------------------------------------------------------------------
-- Session Ledger
--------------------------------------------------------------------------------

--[[
	How much of each configured item every trade partner has already been given,
	and the per-trade latch that keeps the "they have had their share" notice to a
	single line.

	Runtime only and deliberately never saved, so a reload or a logout starts
	everyone's budget over. That is the whole definition of "session" here.
]]

-- sessionGiven[configKey][partnerKey] = items handed over so far this session.
local sessionGiven = {}

-- Items whose session cap has already been reported this trade, so the notice is said once and not once per bag update.
local capNoticed = {}

--------------------------------------------------------------------------------
-- Partner Identity
--------------------------------------------------------------------------------

-- Name-realm for a partner from another realm, plain name otherwise.
function ns.TradePartnerKey()
	local name, realm = UnitName("NPC")
	if not name then
		return nil
	end
	if realm and realm ~= "" then
		return name .. "-" .. realm
	end
	return name
end

--------------------------------------------------------------------------------
-- Ledger
--------------------------------------------------------------------------------

function ns.GivenThisSession(configKey, partnerKey)
	local perPlayer = sessionGiven[configKey]
	return (perPlayer and perPlayer[partnerKey]) or 0
end

function ns.CreditSession(configKey, partnerKey, count)
	local perPlayer = sessionGiven[configKey]
	if not perPlayer then
		perPlayer = {}
		sessionGiven[configKey] = perPlayer
	end
	perPlayer[partnerKey] = (perPlayer[partnerKey] or 0) + count
end

--[[
	Forgets what everyone has already been given of an item, so a limit changed
	part-way through a session is measured from now rather than against giving that
	happened under the old number. Without it, raising Maximum per Session from 2 to
	10 hands over nothing until the next reload, which reads as the setting being
	ignored. Passing nil clears every item.
]]
function ns.ResetSessionLedger(configKey)
	if configKey == nil then
		wipe(sessionGiven)
		return
	end
	sessionGiven[configKey] = nil
end

--------------------------------------------------------------------------------
-- Cap Notice Latch
--------------------------------------------------------------------------------

--[[
	True the first time an item's cap notice is claimed this trade and false every
	time after, so the caller can latch on the claim itself rather than testing and
	setting a flag it does not own.
]]
function ns.ClaimSessionCapNotice(configKey)
	if capNoticed[configKey] then
		return false
	end
	capNoticed[configKey] = true
	return true
end

-- Cleared on TRADE_SHOW: the latch is per trade, where the ledger above is per session.
function ns.ResetSessionCapNotices()
	wipe(capNoticed)
end
