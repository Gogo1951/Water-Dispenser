local _, ns = ...

local L = ns.L

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

--[[
	Bag moves issued during this trade, and the ceilings on them.

	A move -- a split, or a merge -- is driven by the bag update it causes: move,
	re-fill, place. That is self-limiting while the server cooperates, but a move
	the server accepts and then bounces back is *also* a bag change, so a bouncing
	item would re-enter the fill forever, shuffling the bags on every pass. The
	counters are what stop that; ns.ShapeStack is where they are spent.

	Per item, eight covers one merge and one split with room for a handful of loose
	scraps to be worked through. Per trade,
	twenty-four is deliberately generous, so a legitimate fill can never reach it.
	Both reset on TRADE_SHOW, because the ceilings are meant to catch one wedged
	trade, not to ration the day.
]]
local MAX_MOVES_PER_TRADE = 24
local MAX_MOVES_PER_ITEM = 8
local movesThisTrade = 0
local movesPerItem = {}

--[[
	The loose slot counts of each item as they stood when its last move was issued,
	as a sorted string. A move that lands always changes them -- a split adds a
	slot, a merge removes one -- so finding them unchanged once the move's settle
	window (below) has closed means it bounced: on Classic Era the split call has been seen moving the whole
	stack to a fresh slot instead, which leaves the same counts in different
	places. One bounce ends shaping for that item this trade, where the ceilings
	alone would let it reshuffle the bags several more times first.
]]
local lastShape = {}

--[[
	Items whose last shaping move is still settling, as shapeSettling[configId] =
	the GetTime() it is given up on.

	On Forever a split can take several bag updates to land: the portion reads as
	an empty slot until the server confirms it, and the source slot can unlock with
	its old count first. A pass in that gap sees the bags short, so it would split
	again into the same slot, or read the unchanged counts as a bounce and hand the
	loose scraps over instead. While an item is settling, a slot that already
	matches is still placed whole, but the item is neither shaped again nor handed
	over loose; the bag update the move causes, or the settle check after the
	window, comes back here.
]]
local SHAPE_SETTLE = 1
local shapeSettling = {}
local settleTimer

--------------------------------------------------------------------------------
-- Portioning
--------------------------------------------------------------------------------

--[[
	Splits `portion` off (bag, slot) into a free bag slot, so the pass that follows
	can hand that slot over whole. True if a move was issued.

	The trade window is deliberately not involved. Dropping a just-split stack
	straight into it would save a round trip but stakes everything on the cursor
	holding the amount that was asked for, which nothing can verify -- and getting
	it wrong puts a whole stack in front of a partner who is owed two. Landing in a
	bag first means the next scan reports what actually happened, and the whole-slot
	rule refuses to place anything larger than what is still owed.
]]
local function PortionIntoBag(source, portion)
	if not ns.SplitToCursor(source.Bag, source.Slot, portion) then
		return false
	end
	-- Never leaves the cursor holding anything, whatever the client did with the split.
	ns.StowCursorItem()
	return true
end

--------------------------------------------------------------------------------
-- Stack Shaping
--------------------------------------------------------------------------------

--[[
	Shapes one bag slot holding exactly `want` of an item out of `loose`: the slots
	of that item the fill has not used this pass, sorted biggest first. The partner
	then receives one stack, where handing the loose slots over as they are gives
	them a trade slot per scrap -- two Runecloth as two slots of one.

	Returns moved, waiting. `moved` means a bag move was issued and the bag update it
	causes re-enters the fill, where the shaped slot is an exact match for the
	whole-slot rule. `waiting` means nothing was issued but nothing should be placed
	either: the player is holding something on the cursor, and their next drop is a
	bag update of its own. Both false means the bags cannot be shaped and the caller
	hands the loose slots over as they are.

	Cheapest move first, since every one is a server round trip:

	  1. Two loose slots that add up to exactly `want` merge into one. One move, and
	     it leaves no scrap behind.
	  2. A slot larger than `want` has `want` split off it into an empty bag slot --
	     the smallest such slot, so breaking a 7 to find 5 leaves a full 20 intact.
	     One move; the scrap it leaves stays where it falls.
	  3. Otherwise every loose slot is smaller than `want`, so they merge pairwise,
	     smallest onto largest, and the pass after finds one big enough for step 2
	     or an exact match.

	Every move is retried implicitly by the bag update it causes, so each is charged
	against the per-item and per-trade ceilings declared at the top. A refused split
	-- nothing reached the cursor, the one unambiguous signal that this client will
	not split -- spends the item's whole budget at once, so it is said once and not
	retried on every bag update.
]]
function ns.ShapeStack(configId, loose, want)
	shapeSettling[configId] = nil
	if #loose == 0 then
		return false, false
	end
	if (movesPerItem[configId] or 0) >= MAX_MOVES_PER_ITEM or movesThisTrade >= MAX_MOVES_PER_TRADE then
		return false, false
	end
	-- Something already held is the player's; a merge or split would drop it.
	if GetCursorInfo() then
		return false, true
	end

	local counts = {}
	for index, bagEntry in ipairs(loose) do
		counts[index] = bagEntry.Count
	end
	local shape = table.concat(counts, ",")
	local logging = ns.diagnostics and ns.diagnostics.logging
	if shape == lastShape[configId] then
		movesPerItem[configId] = MAX_MOVES_PER_ITEM
		if logging then
			ns:LogEventNow("SHAPE", configId, "want=" .. want, "loose=" .. shape, "bounced")
		end
		return false, false
	end

	local function Spend(moves, how)
		movesPerItem[configId] = (movesPerItem[configId] or 0) + moves
		movesThisTrade = movesThisTrade + moves
		lastShape[configId] = shape
		if logging then
			ns:LogEventNow("SHAPE", configId, "want=" .. want, "loose=" .. shape, how)
		end
	end

	-- 1. An exact pair. Sorted biggest first, so the later slot is the smaller and moves onto the earlier.
	for i = 1, #loose - 1 do
		for j = i + 1, #loose do
			if loose[i].Count + loose[j].Count == want then
				Spend(1, "pair")
				ns.MergeSlots(loose[j], loose[i])
				return true, false
			end
		end
	end

	-- 2. The smallest slot larger than `want`.
	local source
	for index = #loose, 1, -1 do
		if loose[index].Count > want then
			source = loose[index]
			break
		end
	end
	if source then
		Spend(1, "split")
		if PortionIntoBag(source, want) then
			return true, false
		end
		movesPerItem[configId] = MAX_MOVES_PER_ITEM
		--[[
			Opt-in, since by then the player has usually seen the trade work. Never
			inferred from a fill that is still short on a later pass: a pass running
			before the move settles is also still short, so a good split would report
			itself refused a fraction of a second before handing the items over.
		]]
		if ns.db.profile.MissingStackWarnings then
			local name = ns.GetItemConfigName(configId) or "?"
			-- The stack size names the amount that would work. The item is in the bags, so its info is cached.
			local info = C_Container.GetContainerItemInfo(source.Bag, source.Slot)
			local stackSize = info and select(8, C_Item.GetItemInfo(info.itemID)) or want
			ns.PrintMessage(format(L["CHAT_SPLIT_NEEDS_FULL_STACK"], name, want, stackSize))
		end
		return false, false
	end

	-- 3. Everything is smaller than `want`: combine, and let the next pass look again.
	local merges = ns.MergePartials(loose)
	if merges > 0 then
		Spend(merges, "combine")
		return true, false
	end
	return false, false
end

--------------------------------------------------------------------------------
-- Settle Window
--------------------------------------------------------------------------------

--[[
	One fill pass after the newest move's settle window closes. The move's own bag
	update normally re-enters the fill first; this covers the move whose last bag
	update came while it was still settling. Dropping the inventory cache makes the
	scan report a change, so the non-forced pass runs.
]]
local function ScheduleSettleCheck()
	if settleTimer then
		settleTimer:Cancel()
	end
	settleTimer = C_Timer.NewTimer(SHAPE_SETTLE, function()
		settleTimer = nil
		if ns.State.Trade.Active and ns.State.MissingStack and not ns.IsInCombat() then
			ns.ClearInventory()
			ns.FillTrade(false)
		end
	end)
end

-- Starts an item's settle window after a move, with one more fill pass when it closes.
function ns.MarkShapeSettling(configId)
	shapeSettling[configId] = GetTime() + SHAPE_SETTLE
	ScheduleSettleCheck()
end

function ns.IsShapeSettling(configId)
	return (shapeSettling[configId] or 0) > GetTime()
end

--------------------------------------------------------------------------------
-- Trade Lifecycle
--------------------------------------------------------------------------------

-- TRADE_SHOW: the ceilings, shapes and settle windows are all per trade.
function ns.ResetShaping()
	movesThisTrade = 0
	wipe(movesPerItem)
	wipe(lastShape)
	wipe(shapeSettling)
end

-- TRADE_CLOSED: nothing is left to settle, and the check after the window must not fire.
function ns.StopShapeSettling()
	wipe(shapeSettling)
	if settleTimer then
		settleTimer:Cancel()
		settleTimer = nil
	end
end

--------------------------------------------------------------------------------
-- Diagnostics
--------------------------------------------------------------------------------

-- Copies of the shaping brakes, for ns.GetFillState and the Diagnostic Tools Trade & Fill report.
function ns.GetShapingState()
	local now = GetTime()
	local state = {
		MovesThisTrade = movesThisTrade,
		MaxMovesPerTrade = MAX_MOVES_PER_TRADE,
		MaxMovesPerItem = MAX_MOVES_PER_ITEM,
		MovesPerItem = {},
		LastShape = {},
		SettlingSeconds = {},
	}
	for key, moves in pairs(movesPerItem) do
		state.MovesPerItem[key] = moves
	end
	for key, shape in pairs(lastShape) do
		state.LastShape[key] = shape
	end
	for key, giveUpAt in pairs(shapeSettling) do
		state.SettlingSeconds[key] = giveUpAt - now
	end
	return state
end
