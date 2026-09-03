local _, ns = ...

--------------------------------------------------------------------------------
-- Database Defaults
--------------------------------------------------------------------------------

--[[
	AceDB-3.0 defaults. `profile` holds every user setting -- one "Default"
	profile shared across characters unless a character opts into its own.
	`global` is unused under this model. AceDB applies these itself, so there is
	no hand-merge.
]]

-- Positional helper that keeps the per-class default tables readable below. Every number is individual items, not stacks.
local function CountsFor(warrior, paladin, hunter, rogue, priest, shaman, mage, warlock, druid)
	return {
		WARRIOR = warrior,
		PALADIN = paladin,
		HUNTER = hunter,
		ROGUE = rogue,
		PRIEST = priest,
		SHAMAN = shaman,
		MAGE = mage,
		WARLOCK = warlock,
		DRUID = druid,
	}
end

ns.DATABASE_DEFAULTS = {
	profile = {
		showWelcome = true,
		-- Mini-map button position and hide flag; passed straight to LibDBIcon.
		minimap = {},
		MissingStackWarnings = false,
		Dispense = true,
		DispenseSolo = true,
		DispenseGroup = true,
		DispenseRaid = true,
		CombatNotifications = true,
		RestackBags = true,
		ShowInventoryTooltips = true,
		ShareInventory = true,
		Announcements = {
			Enabled = true,
		},
		Items = {
			MageWater = {
				NoRemove = true,
				Distribute = "Always",
				FactorLevel = false,
				-- Mages reserve a personal stash; everything beyond it is giveable.
				KeepAtLeastEnabled = true,
				KeepAtLeast = 20,
				SessionCapEnabled = false,
				SessionCap = 2,
				IncludeQuantity = true,
				PlayerClasses = { MAGE = true },
				-- Mana classes get water; warriors and rogues are served by MageFood. A conjured stack is 20, so these are the old one-stack and two-stack defaults.
				--	   war pal hun rog pri sha mag wlk dru
				Solo = CountsFor(0, 20, 20, 0, 20, 20, 0, 20, 20),
				Group = CountsFor(0, 20, 20, 0, 20, 20, 0, 20, 20),
				Raid = CountsFor(0, 40, 40, 0, 40, 40, 0, 40, 40),
			},
			MageFood = {
				NoRemove = true,
				Distribute = "Always",
				FactorLevel = false,
				KeepAtLeastEnabled = false,
				KeepAtLeast = 0,
				SessionCapEnabled = false,
				SessionCap = 2,
				IncludeQuantity = true,
				PlayerClasses = { MAGE = true },
				-- Every class except mages (who conjure their own). A conjured stack is 20, so one stack each and two in a raid.
				--	   war pal hun rog pri sha mag wlk dru
				Solo = CountsFor(20, 20, 20, 20, 20, 20, 0, 20, 20),
				Group = CountsFor(20, 20, 20, 20, 20, 20, 0, 20, 20),
				Raid = CountsFor(40, 40, 40, 40, 40, 40, 0, 40, 40),
			},
			WarlockHealthstone = {
				NoRemove = true,
				Distribute = "Always",
				FactorLevel = false,
				-- No count in the announcement: listeners care that you have one.
				IncludeQuantity = false,
				PlayerClasses = { WARLOCK = true },
				KeepAtLeastEnabled = false,
				KeepAtLeast = 0,
				SessionCapEnabled = false,
				SessionCap = 2,
				Solo = CountsFor(1, 1, 1, 1, 1, 1, 1, 0, 1),
				Group = CountsFor(1, 1, 1, 1, 1, 1, 1, 0, 1),
				Raid = CountsFor(1, 1, 1, 1, 1, 1, 1, 0, 1),
			},
		},
	},
}
