local _, ns = ...

--------------------------------------------------------------------------------
-- Bag Moves
--------------------------------------------------------------------------------

--[[
	The two bag operations the dispenser is built on, and the only places this
	add-on writes to a bag. Both exist because a trade slot takes a whole bag slot:
	the fill hands over slots, so the bags have to already hold slots of the right
	size.

	  Restack  merges loose partials back together, between trades.
	  Portion  splits an exact count onto the cursor, for the caller to drop into a
	           trade slot.

	Neither is the merge step README-Technical bans. That one ran *inside* an open
	trade and made a mid-trade conjure wait for a full stack; the restack never runs
	with a trade open, and a portion only ever produces the amount the fill asked for.

	Both follow the same rules, learned the hard way in Consumable-Connoisseur's
	Restocker: never move against a locked slot, and never leave an item stranded on
	the cursor -- a stranded cursor is what makes the *next* split fail with
	"Couldn't split those items". Neither reports that a move *landed*: the server
	has the last word, so the caller re-scans on the bag update that follows.

	Empty slots are always found with GetContainerItemInfo, which is nil only when a
	slot is truly empty. A container's free-slot *count* can disagree with its
	per-slot contents, and GetContainerItemLink is also nil for an item that is
	merely uncached -- both mislead into "placing" onto an occupied slot.
]]

--------------------------------------------------------------------------------
-- Candidate Slots
--------------------------------------------------------------------------------

-- Item IDs worth tidying: the built-in collections, plus whatever the player added.
local function IsTracked(itemId)
	if not itemId then
		return false
	end
	if ns.ITEM_TO_COLLECTION[itemId] then
		return true
	end
	local items = ns.db and ns.db.profile.Items
	if not items then
		return false
	end
	-- Built-ins are keyed by collection name, handled above; user items by numeric item ID.
	return items[itemId] ~= nil
end

--[[
	Every unlocked partial stack of a tracked item, grouped by item ID.

	A locked slot is mid-move server-side; a second move issued against one is
	dropped with no error, so it waits for the bag update that follows. Full stacks
	and items that don't stack are left out -- neither can absorb anything. An
	uncached max stack is skipped rather than guessed: unlike the scanner, which has
	to take a view this pass, a restack loses nothing by waiting for a warm cache.
]]
local function CollectPartials()
	local partials = {}
	for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local slots = ns.GetContainerNumSlots(bag) or 0
		for slot = 1, slots do
			local info = ns.GetContainerItemInfo(bag, slot)
			local itemId = info and info.itemID
			if itemId and not info.isLocked and IsTracked(itemId) then
				local _, _, _, _, _, _, _, maxStack = ns.GetItemInfo(itemId)
				local count = info.stackCount or 0
				if maxStack and maxStack > 1 and count > 0 and count < maxStack then
					local list = partials[itemId]
					if not list then
						list = {}
						partials[itemId] = list
					end
					list[#list + 1] = { Bag = bag, Slot = slot, Count = count }
				end
			end
		end
	end
	return partials
end

--------------------------------------------------------------------------------
-- Merging
--------------------------------------------------------------------------------

-- Fullest first. Bag and slot break the tie so the comparator is a strict ordering and table.sort can't fault on equal counts.
local function ByCountDescending(a, b)
	if a.Count ~= b.Count then
		return a.Count > b.Count
	end
	if a.Bag ~= b.Bag then
		return a.Bag < b.Bag
	end
	return a.Slot < b.Slot
end

--[[
	Moves the smallest partial onto the largest: the one most likely to vanish
	completely, onto the one closest to being a full stack the fill can use.
]]
local function Merge(src, dst)
	ClearCursor()
	ns.PickupContainerItem(src.Bag, src.Slot)
	ns.PickupContainerItem(dst.Bag, dst.Slot)
	--[[
		A source bigger than the room left in the destination merges what fits and
		keeps the rest on the cursor. Put that back into the source slot, empty by now,
		so a leftover never rides the cursor into whatever the player clicks next. Both
		calls no-op when the merge was clean and the cursor is already empty.
	]]
	ns.PickupContainerItem(src.Bag, src.Slot)
	ClearCursor()
end

--[[
	Every merge this pass can make without reusing a slot, then hand back to the
	event loop.

	The "one move per pass" rule exists because a slot locks for its server round
	trip and a second move against a locked slot is dropped with no error. That
	only forbids reusing a *slot*, not batching: merges over disjoint pairs cannot
	race each other, so pairing the whole list off at once collapses what used to
	be one round trip per merge into one per pass. Four loose stacks settle in two
	passes rather than three, and the player watches their bags shuffle for a
	fraction as long.

	Pairing is smallest onto largest, working inwards: the stack most likely to
	vanish completely, onto the one closest to being a full stack the fill can use.

	It terminates: a merge either empties its source or fills its destination, so
	each pass leaves strictly fewer partial stacks of that item than it found.
]]
local function MergeDisjoint()
	for _, list in pairs(CollectPartials()) do
		if #list >= 2 then
			table.sort(list, ByCountDescending)
			local low, high = #list, 1
			while high < low do
				Merge(list[low], list[high])
				low, high = low - 1, high + 1
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Pass Guard
--------------------------------------------------------------------------------

local function Restack()
	--[[
		Combine Partial Stacks is a sub-option of Dispense in the panel, so it hides
		when the master is off; reading both here is what keeps it from carrying on
		invisibly once its control is out of sight.
	]]
	if not (ns.db and ns.db.profile.Dispense and ns.db.profile.RestackBags) then
		return
	end
	if not (ns.GetContainerNumSlots and ns.GetContainerItemInfo and ns.PickupContainerItem) then
		return
	end
	--[[
		Bags are left alone in combat, matching every other bag path here. A reshuffle
		mid-fight is the last thing the player wants, and nothing is lost by waiting --
		PLAYER_REGEN_ENABLED picks the pass back up.
	]]
	if ns.IsInCombat() then
		return
	end
	--[[
		Something already on the cursor means the player is mid-drag -- and picking an
		item up locks its slot, which is itself a bag update, so this fires exactly when
		they are moving things by hand. Merging now would clear the cursor out from
		under them and drop what they were holding. Their next drop is another bag
		update, so the pass loses nothing by standing down.
	]]
	if GetCursorInfo() then
		return
	end
	--[[
		Never during a trade. Offered slots are locked, the conjure watch compares raw
		slot counts and would read a merge as a cast, and partials are already being
		offered as they land. TRADE_CLOSED runs the pass that was skipped.
	]]
	if ns.State.Trade.Active then
		return
	end
	MergeDisjoint()
end

ns.RestackBags = Restack

--------------------------------------------------------------------------------
-- Portioning
--------------------------------------------------------------------------------

--[[
	Portioning is two primitives rather than one call, because where the split
	lands is the caller's business and the difference is worth a whole server round
	trip.

	A portion goes into a free *bag* slot, and the pass after hands that slot over
	whole. Going straight from the cursor into the trade window would be a frame
	faster, but it rests on knowing how many items the cursor holds -- and nothing
	can know that. GetCursorInfo reports the item, never the count, and the source
	slot has not always caught up by the next line, so a same-frame check reports
	refusals that never happened.

	Landing in a bag needs no such knowledge. If the client honors the count, the
	next scan finds a slot of exactly the right size and the ordinary whole-slot
	path trades it. If the client hands over the whole stack instead, all that
	happened is a stack moved between bag slots -- and the whole-slot rule, which
	only places a slot no larger than what is still owed, makes over-giving
	impossible either way. Being wrong is cheap; that is the point.
]]

--[[
	Splits `count` off (bag, slot) onto the cursor. True means the cursor is holding
	something and the caller MUST put it somewhere -- StowCursorItem is the
	catch-all. False means nothing reached the cursor and there is nothing to clean
	up.

	It does not promise the cursor holds exactly `count`. It cannot: no API reports
	the cursor's stack size, and reading the source slot back in the same frame is
	unreliable. What actually landed is settled by the next bag scan, which is why
	the caller stows this in a bag rather than handing it to anyone.
]]
function ns.SplitToCursor(bag, slot, count)
	if not (ns.SplitContainerItem and ns.GetContainerItemInfo) then
		return false
	end
	if not count or count <= 0 then
		return false
	end
	--[[
		A locked source is still mid-move server-side, and splitting from one is
		exactly what earns "Couldn't split those items". The count check is not
		belt-and-braces: splitting a slot's entire contents is refused, and the caller
		should have placed that slot whole anyway.
	]]
	local info = ns.GetContainerItemInfo(bag, slot)
	if not info or info.isLocked or (info.stackCount or 0) <= count then
		return false
	end
	-- Something already held is the player's; taking the cursor would drop it.
	if GetCursorInfo() then
		return false
	end

	local before = info.stackCount or 0
	ClearCursor()

	--[[
		Two entry points, tried in turn. On Classic Era 1.15.9 the C_Container one has
		been seen answering with the whole stack, and some legacy container globals do
		survive on that client, so the older one gets a go if the first leaves the
		cursor empty.
	]]
	ns.SplitContainerItem(bag, slot, count)
	if not CursorHasItem() and ns.SplitContainerItemLegacy then
		ns.SplitContainerItemLegacy(bag, slot, count)
	end
	if not CursorHasItem() then
		return false
	end

	--[[
		Recorded, not acted on. What the source slot reads this instant is the best
		clue available to a bug report about whether the count was honored -- left=18
		on a 20 asked for 2 means yes, left=20 or an empty slot means the client did
		something else -- but it is not reliable enough to decide on, so the caller
		stows the cursor either way and lets the next scan tell the truth.
	]]
	if ns.diagnostics and ns.diagnostics.logging then
		local after = ns.GetContainerItemInfo(bag, slot)
		ns:LogEventNow(
			"SPLIT",
			bag,
			slot,
			"asked=" .. count,
			"before=" .. before,
			"left=" .. tostring(after and after.stackCount or 0)
		)
	end
	return true
end

--[[
	Parks whatever is on the cursor in an empty bag slot. True if it landed there,
	false if it had to go back where it came from. Either way the cursor is empty
	afterwards, which is the point: a stranded cursor is what makes the *next* split
	fail with "Couldn't split those items", and it leaves an item stuck to the
	player's pointer.
]]
function ns.StowCursorItem()
	if not CursorHasItem() then
		return false
	end
	--[[
		Try every empty slot rather than just the first. A profession bag has empty
		slots that will not take a potion, and a refused drop is silent -- the item
		simply stays on the cursor -- so the only way to know is to look afterwards.
	]]
	for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local slots = ns.GetContainerNumSlots(bag) or 0
		for slot = 1, slots do
			if not ns.GetContainerItemInfo(bag, slot) then
				ns.PickupContainerItem(bag, slot)
				if not CursorHasItem() then
					return true
				end
			end
		end
	end

	ClearCursor()
	return false
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function ns.InitRestacker()
	--[[
		BAG_UPDATE_DELAYED, not BAG_UPDATE: the client already coalesces a conjure's
		several slot events into one settle, and each merge's own settle drives the
		next pass.
	]]
	ns.RegisterEvent("BAG_UPDATE_DELAYED", Restack)
	--[[
		The two states a pass bails on. Registered after InitDispenser, so the
		dispenser's own TRADE_CLOSED handler has already cleared State.Trade.Active by
		the time this one reads it.
	]]
	ns.RegisterEvent("PLAYER_REGEN_ENABLED", Restack)
	ns.RegisterEvent("TRADE_CLOSED", Restack)
end
