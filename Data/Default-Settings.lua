local _, ns = ...

--------------------------------------------------------------------------------
-- Database Defaults
--------------------------------------------------------------------------------

--[[
	AceDB-3.0 defaults. `profile` holds every user setting -- one "Default"
	profile shared across characters unless a character opts into its own.
	`global` holds only the minimap button position, which stays account-wide.
	AceDB applies these via metatables, so there is no hand-merge.
]]

-- Positional helper that keeps the per-class default tables readable below.
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
		MissingStackWarnings = false,
		Dispense = true,
		DispenseSolo = true,
		DispenseGroup = true,
		DispenseRaid = true,
		Announcements = {
			Enabled = true,
		},
		Items = {
			MageWater = {
				NoRemove = true,
				Icon = "Interface\\ICONS\\INV_Drink_18",
				-- Restack merges conjured partials into full stacks, so only full stacks dispense and the leftover partial stays in bags.
				UseNotFullStack = false,
				FactorLevel = false,
				-- Mages reserve a personal stash; everything beyond it is giveable.
				KeepAtLeast = 20,
				IncludeQuantity = true,
				PlayerClasses = { MAGE = true },
				-- Mana classes get water; warriors and rogues are served by MageFood.
				--	   war pal hun rog pri sha mag wlk dru
				Solo = CountsFor(0, 1, 1, 0, 1, 1, 0, 1, 1),
				Group = CountsFor(0, 1, 1, 0, 1, 1, 0, 1, 1),
				Raid = CountsFor(0, 2, 2, 0, 2, 2, 0, 2, 2),
			},
			MageFood = {
				NoRemove = true,
				Icon = "Interface\\ICONS\\INV_Misc_Food_09",
				-- Restack merges conjured partials into full stacks, so only full stacks dispense and the leftover partial stays in bags.
				UseNotFullStack = false,
				FactorLevel = false,
				KeepAtLeast = 0,
				IncludeQuantity = true,
				PlayerClasses = { MAGE = true },
				-- Every class except mages (who conjure their own); scales 1/1/2.
				--	   war pal hun rog pri sha mag wlk dru
				Solo = CountsFor(1, 1, 1, 1, 1, 1, 0, 1, 1),
				Group = CountsFor(1, 1, 1, 1, 1, 1, 0, 1, 1),
				Raid = CountsFor(2, 2, 2, 2, 2, 2, 0, 2, 2),
			},
			WarlockHealthstone = {
				NoRemove = true,
				Icon = "Interface\\ICONS\\INV_Stone_04",
				UseNotFullStack = false,
				FactorLevel = false,
				-- No count in the announcement: listeners care that you have one.
				IncludeQuantity = false,
				PlayerClasses = { WARLOCK = true },
				KeepAtLeast = 0,
				Solo = CountsFor(1, 1, 1, 1, 1, 1, 1, 0, 1),
				Group = CountsFor(1, 1, 1, 1, 1, 1, 1, 0, 1),
				Raid = CountsFor(1, 1, 1, 1, 1, 1, 1, 0, 1),
			},
		},
	},
	global = {
		-- Minimap button position only; passed directly to LibDBIcon.
		minimap = {},
	},
}
