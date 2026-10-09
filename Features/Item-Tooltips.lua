local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Bag Item Tooltips
--------------------------------------------------------------------------------

--[[
	Appends one branded line to a carried bag item's tooltip when that item is set
	to be given out, so the player can see what the add-on will hand over without
	opening the panel.

	Read-only. Nothing here decides anything the fill does; it reports the same two
	answers the fill reads, through the same helpers.

	Two hook paths, picked by what GameTooltip itself does. Where it still has the
	OnTooltipSetItem script (Era and TBC Anniversary) its setters never pass through
	TooltipDataProcessor -- TBC ships that table, but its GameTooltip ignores it --
	so the live path is a hooksecurefunc on GameTooltip:SetBagItem. Forever's Retail
	engine has no such script and builds every tooltip through TooltipDataProcessor,
	so it takes the post-call. Only one is ever active, so the line can never double
	up.

	Hooking the setter rather than the shared OnTooltipSetItem script is what keeps
	the line: a heavy tooltip add-on that clears and re-fills the tooltip on
	OnTooltipSetItem would otherwise wipe it. Combined with registering late (see
	ns.SetupItemTooltips), we wrap whatever wrappers other add-ons installed and
	land outermost, so the line is added last and sits at the bottom.
]]

--[[
	The bag and slot a tooltip is anchored to, or nil unless the anchor is one of
	the player's carried bags. Only the TooltipDataProcessor path needs it, since
	that fires for every item tooltip -- merchant, bank and chat links included.
	The SetBagItem path is already bag-scoped by its own arguments.
]]
local function GetCarriedBagSlot(tooltip)
	local owner = tooltip:GetOwner()
	if not owner then
		return nil
	end

	local slot = owner.GetID and owner:GetID()
	if type(slot) ~= "number" then
		return nil
	end

	local getBagID = owner.GetBagID
	if type(getBagID) ~= "function" then
		return nil
	end
	local ok, bag = pcall(getBagID, owner)
	if ok and type(bag) == "number" and bag >= 0 and bag <= ns.LAST_BAG_INDEX then
		return bag, slot
	end
	return nil
end

--[[
	The line for one item ID, or nil when it earns none. Two gates, both the fill's
	own: the item has to be configured, and it has to be switched on for the class
	being played -- a warlock holding conjured water is carrying something that
	would never leave their bags, so saying it will be dispensed would be a lie.

	Everything is gated on the master Dispense switch as well. With dispensing off
	nothing is handed to anyone, so the line would promise something that is not
	going to happen.
]]
local function BuildLine(itemId)
	if not itemId then
		return nil
	end
	if not (ns.db and ns.db.profile.ShowBagTooltips and ns.db.profile.Dispense) then
		return nil
	end

	local configKey = ns.GetItemConfigKey(itemId)
	if not configKey then
		return nil
	end
	if not ns.IsItemActiveForPlayer(ns.db.profile.Items[configKey]) then
		return nil
	end

	return ns.BuildBrandedLine(GetColor("TEXT") .. L["TOOLTIP_WILL_DISPENSE"] .. "|r")
end

-- Adds the line under a blank spacer so it reads as a footer. True when something was added.
local function AddDispenseLine(tooltip, itemId)
	local line = BuildLine(itemId)
	if not line then
		return false
	end
	tooltip:AddLine(" ")
	tooltip:AddLine(line)
	return true
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

-- Records the path taken in ns.bagTooltipPath, which the Diagnostic Tools context report prints.
function ns.SetupItemTooltips()
	if not GameTooltip:HasScript("OnTooltipSetItem") then
		--[[
			Fires for every item tooltip, so gate it to carried bag slots. data.id is
			the item ID (Enum.TooltipDataType.Item).
		]]
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
			if GetCarriedBagSlot(tooltip) then
				AddDispenseLine(tooltip, data and data.id)
			end
		end)
		ns.bagTooltipPath = "TooltipDataProcessor"
		return
	end

	--[[
		hooksecurefunc wraps whatever GameTooltip:SetBagItem currently is, so it runs
		after the wrapped call returns. Bag-scoped by its own arguments, so bank bags
		are excluded by the range check and no owner sniffing is needed, which is what
		keeps this working under replacement bag add-ons.

		Running outermost means the tooltip has already been sized and shown, so
		AddLine alone would draw outside the frame. Re-Show it when a line was added
		so the tooltip grows to fit.
	]]
	hooksecurefunc(GameTooltip, "SetBagItem", function(tooltip, bag, slot)
		if type(bag) ~= "number" or bag < 0 or bag > ns.LAST_BAG_INDEX then
			return
		end
		local info = C_Container.GetContainerItemInfo(bag, slot)
		if AddDispenseLine(tooltip, info and info.itemID) then
			tooltip:Show()
		end
	end)
	ns.bagTooltipPath = "SetBagItem"
end
