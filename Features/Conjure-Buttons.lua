local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Rank Lists
--------------------------------------------------------------------------------

--[[
	Per built-in collection, its conjure spells best first: { SpellId, Level, Items },
	where Level is the use level of what that rank makes. Sorted by level here, so
	the data's row order carries no meaning.
]]
local RANKS = {}
for key, collection in pairs(ns.COLLECTIONS) do
	local list = {}
	for spellId in pairs(collection.Spells) do
		local items = ns.SPELL_TO_ITEMS[spellId]
		local level = items and items[1] and ns.ITEM_LEVEL[items[1]]
		if level then
			list[#list + 1] = { SpellId = spellId, Level = level, Items = items }
		end
	end
	table.sort(list, function(a, b)
		if a.Level ~= b.Level then
			return a.Level > b.Level
		end
		return a.SpellId > b.SpellId
	end)
	RANKS[key] = list
end

local function CarriesAny(itemIds)
	for _, itemId in ipairs(itemIds) do
		if C_Item.GetItemCount(itemId) > 0 then
			return true
		end
	end
	return false
end

--[[
	The rank a conjure button casts for a partner of this level: the best rank the
	player knows whose item the partner can use. A unique item (the healthstone)
	skips a rank already carried, so the next press makes the tier below rather than
	an error. With no rank fitting, the lowest rank the player actually knows, since
	casting an untrained rank silently does nothing. The second return is true when
	that fallback chose it.
]]
function ns.GetConjureSpell(key, partnerLevel)
	local list = RANKS[key]
	if not list then
		return nil
	end
	local meta = ns.COLLECTION_META[key]
	local unique = meta and meta.Unique
	for _, row in ipairs(list) do
		if ns.IsSpellLearned(row.SpellId) and row.Level <= partnerLevel and not (unique and CarriesAny(row.Items)) then
			return row, false
		end
	end
	for index = #list, 1, -1 do
		if ns.IsSpellLearned(list[index].SpellId) then
			return list[index], true
		end
	end
	return nil
end

--------------------------------------------------------------------------------
-- Buttons
--------------------------------------------------------------------------------

--[[
	Secure buttons, so they live in their own holder parented to UIParent: a frame
	with protected children becomes protected itself, and the trade panel has to
	stay free to show and hide at any time. Attributes and visibility only ever
	change out of combat.

	Registered for both up and down clicks. Every client decides whether a secure
	button acts on the down or the up stroke from the ActionButtonUseKeyDown
	setting, and a button registered for one stroke only never fires when the
	setting picks the other.
]]
local holder
local buttons = {}
local pendingHide = false

-- What each button casts right now, for its tooltip and the context probe: [key] = { Row, Fallback }.
ns.conjureChoices = {}

local function ShowButtonTooltip(button)
	local choice = ns.conjureChoices[button.key]
	if not choice then
		return
	end
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
	GameTooltip:AddLine(GetColor("TITLE") .. (C_Spell.GetSpellName(choice.Row.SpellId) or "") .. "|r")
	local itemName = C_Item.GetItemInfo(choice.Row.Items[1])
	if itemName then
		local text
		if choice.Fallback then
			text = format(L["TRADE_CONJURE_MAKES_LOWEST"], itemName)
		else
			local trade = ns.State.Trade
			text =
				format(L["TRADE_CONJURE_MAKES"], itemName, ns.NameWithoutRealm(trade.Partner) or "?", trade.Level or 0)
		end
		GameTooltip:AddLine(GetColor("HELP") .. text .. "|r", 1, 1, 1, true)
	end
	GameTooltip:Show()
end

local function CreateButtons()
	holder = CreateFrame("Frame", nil, UIParent)
	holder:SetSize(160, 1)
	holder:Hide()

	local previous
	for _, key in ipairs(ns.BUILTIN_ORDER) do
		local button = CreateFrame("Button", nil, holder, "SecureActionButtonTemplate, UIPanelButtonTemplate")
		button:SetSize(160, 22)
		button:RegisterForClicks("AnyUp", "AnyDown")
		button:SetAttribute("type", "spell")
		button.key = key
		button:SetScript("OnEnter", ShowButtonTooltip)
		button:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
		if previous then
			button:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -2)
		else
			button:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
		end
		buttons[key] = button
		previous = button
	end
end

local function HideButtons()
	if not holder then
		return
	end
	if ns.IsInCombat() then
		pendingHide = true
		return
	end
	pendingHide = false
	holder:Hide()
	if ns.TradeUI then
		ns.TradeUI:SetStatusAnchor(nil)
	end
end

--[[
	Re-picks every button's rank for the current partner and shows the ones the
	player can cast. Only beside an open trade the panel is showing, only while the
	switch and Dispense are both on, and never in combat.
]]
function ns.RefreshConjureButtons()
	local trade = ns.State.Trade
	local db = ns.db and ns.db.profile
	if not (trade.Active and db and db.ConjureButtons and db.Dispense) or not (ns.TradeUI and ns.TradeUI:IsShown()) then
		HideButtons()
		return
	end
	if ns.IsInCombat() then
		return
	end
	if not holder then
		CreateButtons()
	end

	local shown, last = 0, nil
	wipe(ns.conjureChoices)
	for _, key in ipairs(ns.BUILTIN_ORDER) do
		local button = buttons[key]
		local row, fallback = ns.GetConjureSpell(key, trade.Level or UnitLevel("player"))
		local name = row and C_Spell.GetSpellName(row.SpellId)
		button:ClearAllPoints()
		if name then
			ns.conjureChoices[key] = { Row = row, Fallback = fallback }
			button:SetAttribute("spell", row.SpellId)
			button:SetText(name)
			if last then
				button:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -2)
			else
				button:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
			end
			button:Show()
			shown = shown + 1
			last = button
		else
			button:SetAttribute("spell", nil)
			button:Hide()
		end
	end

	if shown == 0 then
		HideButtons()
		return
	end
	holder:SetHeight(shown * 24)
	holder:ClearAllPoints()
	holder:SetPoint("TOPLEFT", ns.TradeUI.fillButton, "BOTTOMLEFT", 0, -8)
	holder:SetFrameStrata(ns.TradeUI:GetFrameStrata())
	holder:Show()
	ns.TradeUI:SetStatusAnchor(holder)
end

--------------------------------------------------------------------------------
-- Diagnostics
--------------------------------------------------------------------------------

-- The buttons' own state, for the Diagnostic Tools Conjure & Restack report.
function ns.GetConjureButtonsState()
	return {
		HolderExists = holder ~= nil,
		HolderShown = holder ~= nil and holder:IsShown(),
		PendingHide = pendingHide,
	}
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function ns.InitConjureButtons()
	-- Registered after the dispenser's, so the trade panel is already attached when this runs.
	ns.RegisterEvent("TRADE_SHOW", ns.RefreshConjureButtons)
	ns.RegisterEvent("TRADE_CLOSED", HideButtons)
	-- A healthstone just made moves the next press down a tier; a new rank learned moves it up.
	ns.RegisterEvent("BAG_UPDATE_DELAYED", function()
		if ns.State.Trade.Active then
			ns.RefreshConjureButtons()
		end
	end)
	ns.RegisterEvent("SPELLS_CHANGED", function()
		if ns.State.Trade.Active then
			ns.RefreshConjureButtons()
		end
	end)
	ns.RegisterEvent("PLAYER_REGEN_ENABLED", function()
		if pendingHide then
			HideButtons()
		end
	end)
end
