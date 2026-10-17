local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor

local Header = ns.OptionsHeader
local Desc = ns.OptionsDesc
local Spacer = ns.OptionsSpacer

--------------------------------------------------------------------------------
-- Feedback & Support Panel
--------------------------------------------------------------------------------

-- The Level Up note, one paragraph per key, in page order.
local PARAGRAPHS = {
	"OPTIONS_LEVEL_UP_INTRO",
	"OPTIONS_LEVEL_UP_WAYS",
	"OPTIONS_LEVEL_UP_FEEDBACK",
	"OPTIONS_LEVEL_UP_FRIEND",
	"OPTIONS_LEVEL_UP_CURSEFORGE",
	"OPTIONS_LEVEL_UP_GITHUB",
	"OPTIONS_LEVEL_UP_THANKS",
}

-- { captionKey, linkKey }, in display order
local LINKS = {
	{ "OPTIONS_DISCORD", "DISCORD" },
	{ "OPTIONS_CURSEFORGE", "CURSEFORGE" },
	{ "OPTIONS_WAGO", "WAGO" },
	{ "OPTIONS_GITHUB", "GITHUB" },
}

-- The label is one short word and the box holds a full URL, so the row still ends where every other row does.
local LINK_LABEL_WIDTH = 0.6

function ns.BuildFeedbackSupportOptions()
	local args = {}
	local order = 1

	for index, key in ipairs(PARAGRAPHS) do
		if index > 1 then
			args["spaceParagraph" .. index] = Spacer(order)
			order = order + 1
		end
		args["paragraph" .. index] = Desc(L[key], order)
		order = order + 1
	end

	args.spaceLinks0 = Spacer(order)
	args.headerLinks = Header(L["OPTIONS_FEEDBACK_LINKS_HEADER"], order + 1)
	args.spaceLinks1 = Spacer(order + 2)
	order = order + 3

	for index, row in ipairs(LINKS) do
		local captionKey, linkKey = row[1], row[2]
		if index > 1 then
			args["spaceLink" .. index] = Spacer(order)
			order = order + 1
		end
		args["linkLabel" .. index] =
			ns.OptionsRowLabel(GetColor("TITLE") .. L[captionKey] .. "|r", order, LINK_LABEL_WIDTH)
		args["linkURL" .. index] = {
			type = "input",
			name = "",
			order = order + 1,
			width = ns.OPTIONS_ROW_WIDTH - LINK_LABEL_WIDTH,
			get = function()
				return ns.LINKS[linkKey]
			end,
			set = function() end,
		}
		order = order + 2
	end

	args.spaceCopy = Spacer(order)
	args.copyCaption = Desc(GetColor("HELP") .. L["OPTIONS_COPY_LINK"] .. "|r", order + 1)

	args.spaceVersion = {
		type = "description",
		name = " ",
		width = "full",
		order = 998,
	}
	args.versionLine = {
		type = "description",
		name = function()
			return GetColor("INFO") .. L["OPTIONS_VERSION"]:format(ns.Version) .. "|r"
		end,
		fontSize = "medium",
		order = 999,
	}

	return {
		type = "group",
		name = L["OPTIONS_LEVEL_UP_TITLE"],
		args = args,
	}
end
