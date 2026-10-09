local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader

--------------------------------------------------------------------------------
-- Display Context
--------------------------------------------------------------------------------

--[[
    Answers "the mini-map button is gone / off-screen" reports: screen size, UI
    scale, and the button's saved placement. Read-only. Which button, and which
    settings table holds its placement, come from the add-on's own
    ns.DIAGNOSTIC_MINIMAP manifest: name is its LibDBIcon name, settings returns
    the table handed to LibDBIcon, and savedPath the keys that reach that table
    inside the SavedVariables global, so the report reads whichever scope and
    identity the add-on uses.
]]
function ns:BuildDisplayContextReport()
	local lines = { GetClientHeader(), "" }

	local width, height = GetPhysicalScreenSize()
	lines[#lines + 1] = string.format("Physical screen size: %s x %s", tostring(width), tostring(height))
	lines[#lines + 1] = string.format("UIParent scale: %s", tostring(UIParent and UIParent:GetScale()))
	lines[#lines + 1] = string.format("uiScale CVar: %s", tostring(GetCVar("uiScale")))

	local manifest = ns.DIAGNOSTIC_MINIMAP
	if not manifest then
		return table.concat(lines, "\n")
	end

	lines[#lines + 1] = ""
	local LibDBIcon = LibStub("LibDBIcon-1.0")
	local button = LibDBIcon:GetMinimapButton(manifest.name)
	lines[#lines + 1] = string.format(
		"Mini-map button %s registered: %s",
		manifest.name,
		tostring(LibDBIcon:IsRegistered(manifest.name))
	)
	lines[#lines + 1] = string.format("Mini-map button created: %s", button and "yes" or "no")

	local minimap = manifest.settings()
	if type(minimap) == "table" then
		lines[#lines + 1] = string.format("Mini-map button hidden: %s", tostring(minimap.hide or false))
		lines[#lines + 1] = string.format("Mini-map saved angle: %s", tostring(minimap.minimapPos))
	else
		lines[#lines + 1] = "Mini-map saved position: (none yet)"
	end

	--[[
	    Where a dragged position lives, link by link: LibDBIcon's drag handler
	    computes the angle with math.atan2 every frame and writes it into the
	    button's db, which has to be the very table AceDB saves, and the raw
	    SavedVariables value is what the client writes at logout.
	]]
	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format("math.atan2 present: %s", tostring(type(math.atan2) == "function"))
	lines[#lines + 1] = string.format("LibDBIcon-1.0 minor: %s", tostring(LibStub.minors["LibDBIcon-1.0"]))
	if button then
		lines[#lines + 1] = string.format("Button db present: %s", tostring(button.db ~= nil))
		lines[#lines + 1] = string.format(
			"Button db is the add-on's settings table: %s",
			tostring(button.db ~= nil and minimap ~= nil and button.db == minimap)
		)
		lines[#lines + 1] = string.format("Button db.minimapPos: %s", tostring(button.db and button.db.minimapPos))
	end
	local value = _G[ns.SAVED_VARIABLES_NAME]
	local path = { ns.SAVED_VARIABLES_NAME }
	for _, key in ipairs(manifest.savedPath()) do
		path[#path + 1] = tostring(key)
		value = type(value) == "table" and value[key] or nil
	end
	lines[#lines + 1] = string.format(
		"%s.minimapPos: %s",
		table.concat(path, "."),
		tostring(type(value) == "table" and value.minimapPos or nil)
	)

	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Other Add-ons
--------------------------------------------------------------------------------

function ns:BuildAddOnReport()
	local lines = { GetClientHeader(), "" }
	local count = C_AddOns.GetNumAddOns()
	for index = 1, count do
		local name, _, _, loadable = C_AddOns.GetAddOnInfo(index)
		local version = C_AddOns.GetAddOnMetadata(index, "Version") or "?"
		lines[#lines + 1] = string.format("%s v%s [%s]", name, version, loadable and "loadable" or "disabled")
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Saved Variables
--------------------------------------------------------------------------------

local function DumpTable(value, indent, depth, lines)
	if depth > 8 then
		lines[#lines + 1] = indent .. "<max depth>"
		return
	end
	local keys = {}
	for key in pairs(value) do
		keys[#keys + 1] = key
	end
	table.sort(keys, function(a, b)
		return tostring(a) < tostring(b)
	end)
	for _, key in ipairs(keys) do
		local entry = value[key]
		if type(entry) == "table" then
			lines[#lines + 1] = indent .. tostring(key) .. " = {"
			DumpTable(entry, indent .. "    ", depth + 1, lines)
			lines[#lines + 1] = indent .. "}"
		else
			lines[#lines + 1] = indent .. tostring(key) .. " = " .. tostring(entry)
		end
	end
end

--[[
    Dumps the single AceDB-managed table (profiles, profileKeys, char, global)
    so a player can paste their exact configuration: every setting in each
    profile, and every Protect List and Erase List row in both scopes.
]]
function ns:BuildSavedVariablesReport()
	local lines = { GetClientHeader(), "", ns.SAVED_VARIABLES_NAME .. " = {" }
	DumpTable(_G[ns.SAVED_VARIABLES_NAME] or {}, "    ", 1, lines)
	lines[#lines + 1] = "}"
	return table.concat(lines, "\n")
end
