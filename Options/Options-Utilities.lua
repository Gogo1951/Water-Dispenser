local _, ns = ...

local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- AceConfig UI Helpers
--------------------------------------------------------------------------------

-- Shared widget builders so every options panel looks identical. Loads first
-- in the Options block so panel files can reference these helpers.
function ns.OptionsHeader(text, order)
    return {type = "header", name = GetColor("TITLE") .. text .. "|r", order = order}
end

function ns.OptionsDesc(text, order)
    return {type = "description", name = text, fontSize = "medium", order = order}
end

function ns.OptionsSpacer(order)
    return {type = "description", name = " ", order = order}
end

function ns.OptionsSubHeader(text, order)
    return {
        type = "description",
        name = "\n" .. GetColor("TITLE") .. text .. "|r",
        fontSize = "medium",
        order = order
    }
end
