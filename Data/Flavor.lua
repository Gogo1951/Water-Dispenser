local ADDON_NAME, ns = ...

--------------------------------------------------------------------------------
-- Flavor
--------------------------------------------------------------------------------

--[[
	The TOC the client chose names the flavor. Never work it out from the client:
	WoW Forever reports WOW_PROJECT_MAINLINE, the same as Retail.
]]
ns.FLAVOR = C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-Flavor")

-- The game's major version, for "this expansion or later" comparisons.
ns.EXPANSION = ({ Era = 1, Forever = 1, TBC = 2, Wrath = 3, MoP = 5, Retail = 12 })[ns.FLAVOR]

-- Season of Discovery shares the Classic Era client, so no TOC can name it.
ns.IS_SOD = ns.FLAVOR == "Era" and C_Seasons.GetActiveSeason() == Enum.SeasonID.SeasonOfDiscovery

-- The Data/ folder whose tables this client built.
ns.DATA_FOLDER = ns.IS_SOD and "SoD" or ns.FLAVOR
