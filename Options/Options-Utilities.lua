local _, ns = ...

local GetColor = ns.GetColor

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

-- Sized to the longest sub-option caption with room to spare. An exact fit sits on
-- the wrap boundary, where the control tips onto its own line and strands the indent.
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

-- Sub-row controls sit inside the inline group, so info[#info] is the group's arg
-- key rather than the setting name; these read and write the profile directly.
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
