local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor

local AceGUI = LibStub("AceGUI-3.0")

--------------------------------------------------------------------------------
-- AceConfig UI Helpers
--------------------------------------------------------------------------------

-- Shared widget builders so every options panel looks identical. Loads first in the Options block so panel files can reference these helpers.

-- The third argument collapses the header along with the section it titles.
function ns.OptionsHeader(text, order, hidden)
	return { type = "header", name = GetColor("TITLE") .. text .. "|r", order = order, hidden = hidden }
end

function ns.OptionsDesc(text, order)
	return { type = "description", name = text, fontSize = "medium", order = order }
end

function ns.OptionsSpacer(order)
	return { type = "description", name = " ", order = order }
end

--[[
	The left half of a label-beside-control row: the control that follows carries
	name = "" and ns.OPTIONS_CONTROL_WIDTH, so the two total one row and flow onto
	the same line. A row whose control needs more room passes its own width here.

	A label has no state of its own, so nothing hides it unless it is told to: one
	left out of a gated section is the caption still floating after everything it
	described has gone.
]]
function ns.OptionsRowLabel(text, order, width, hidden)
	return {
		type = "description",
		name = text,
		fontSize = "medium",
		width = width or ns.OPTIONS_LABEL_WIDTH,
		order = order,
		hidden = hidden,
	}
end

--[[
	Sized to the longest sub-option caption with room to spare. An exact fit sits on
	the wrap boundary, where the control tips onto its own line and strands the indent.
]]
local SUB_TOGGLE_WIDTH = 2.0

--------------------------------------------------------------------------------
-- Sub-Option Rows
--------------------------------------------------------------------------------

--[[
	A sub-option is a control that only means anything while the toggle above it
	is on, and it is marked two ways at once.

	The row leads with a blank indent cell, which moves the checkbox itself.
	Padding the label instead would indent only the caption -- AceConfig pins a
	checkbox at the left edge of its own widget -- leaving the box lined up with
	its parent's and the words drifting away from it.

	OptionsSubLabel then colors the caption HELP silver against the parent's white, so the
	row reads as subordinate rather than merely shifted.

	The unnamed inline group is load-bearing, not decoration. Laid out flat, the
	indent and its control are two more widgets in the panel's flow, and the pair
	after them packs onto whatever space is left until the indent stops indenting
	anything. A fill widget always gets a line to itself, so one group per
	sub-option pins one row per sub-option. hidden belongs on the group for the
	same reason: hung off the controls, the indent is left behind on its own line
	when the section collapses.
]]
function ns.OptionsSubRow(order, hidden, controls)
	local args = {
		indent = {
			type = "description",
			name = " ",
			width = ns.OPTIONS_SUB_INDENT_WIDTH,
			order = 1,
		},
	}

	for index, control in ipairs(controls) do
		control.order = index + 1
		args["control" .. index] = control
	end

	return {
		type = "group",
		name = "",
		inline = true,
		order = order,
		hidden = hidden,
		args = args,
	}
end

function ns.OptionsSubLabel(text)
	return GetColor("HELP") .. text .. "|r"
end

--[[
	Sub-row controls sit inside the inline group, so info[#info] is the group's arg
	key rather than the setting name; these read and write the profile directly.
]]
function ns.OptionsSubToggle(key, name, desc, onSet)
	return {
		type = "toggle",
		name = ns.OptionsSubLabel(name),
		desc = desc,
		width = SUB_TOGGLE_WIDTH,
		get = function()
			return ns.db.profile[key]
		end,
		set = function(_, value)
			ns.db.profile[key] = value
			if onSet then
				onSet()
			end
		end,
	}
end

--------------------------------------------------------------------------------
-- Profile Accessors
--------------------------------------------------------------------------------

-- For a widget whose arg key is its setting name, which is every plain profile toggle.
function ns.OptionsGetDB(info)
	return ns.db.profile[info[#info]]
end

function ns.OptionsSetDB(info, value)
	ns.db.profile[info[#info]] = value
end

--------------------------------------------------------------------------------
-- Number Entry
--------------------------------------------------------------------------------

--[[
	AceGUI's EditBox grows a small accept button once you start typing, labelled
	with Blizzard's OKAY. "Okay" says nothing about what it will do; every box on
	the Dispensed Items panel writes a whole column or a whole row, so the button
	says Apply.

	Registered as our own widget type rather than patched into the library: AceGUI
	is an external, re-fetched at package time, so an edit there would not survive
	a build -- and the label is Blizzard's global string, which is not ours to
	change for every other add-on in the client.

	Building on AceGUI.WidgetRegistry's EditBox constructor rather than
	AceGUI:Create("EditBox") keeps the widget out of the EditBox pool: it is created
	fresh, and only ever recycled under this type. Guarded throughout, so a future
	AceGUI that renames its internals costs the label and nothing else.
]]
ns.NUMBER_BOX_WIDGET_TYPE = ns.LOCALE_NAME .. "_NumberBox"
if AceGUI and AceGUI.WidgetRegistry and AceGUI.WidgetRegistry.EditBox then
	AceGUI:RegisterWidgetType(ns.NUMBER_BOX_WIDGET_TYPE, function()
		local widget = AceGUI.WidgetRegistry.EditBox()
		widget.type = ns.NUMBER_BOX_WIDGET_TYPE
		if widget.button then
			widget.button:SetText(L["OPTIONS_ITEM_APPLY"])
			-- "Apply" is wider than "Okay"; the stock 40 clips it.
			widget.button:SetWidth(52)
		end
		return widget
	end, 1)
end

--[[
	Every amount on the Dispensed Items panel is a free-typed count of individual
	items. Dropdowns
	were fine while a number meant a stack and six was a lot; counting items pushes
	the useful range past a hundred, and no ladder short enough to pick from covers
	both "1 potion" and "120 water" without leaving out whatever the player actually
	wanted.

	Blank reads as zero so clearing a field is a way to say "never", and anything
	that is not a number at all is rejected by Validate rather than silently
	becoming one.
]]
local NUMBER_MAX = 1000

function ns.OptionsParseCount(value, maxCount)
	local number = tonumber(value)
	if not number then
		return nil
	end
	number = math.floor(number + 0.5)
	if number < 0 then
		number = 0
	end
	local ceiling = maxCount or NUMBER_MAX
	if number > ceiling then
		number = ceiling
	end
	return number
end

--[[
	AceConfig shows the returned string and refuses the edit, leaving the old value
	in place. maxCount is the per-item cap: 1 for unique items, nothing otherwise.
]]
function ns.OptionsValidateCount(value, maxCount)
	if value == nil or value == "" then
		return true
	end
	if not tonumber(value) then
		return L["OPTIONS_ITEM_COUNT_INVALID"]
	end
	if maxCount and (tonumber(value) or 0) > maxCount then
		return format(L["OPTIONS_ITEM_COUNT_TOO_HIGH"], maxCount)
	end
	return true
end
