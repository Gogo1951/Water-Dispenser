local _, ns = ...

--------------------------------------------------------------------------------
-- Default Configuration
--------------------------------------------------------------------------------

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
        DRUID = druid
    }
end

ns.DEFAULT_CONFIGURATION = {
    Version = 11,
    -- WelcomeMessage is account-wide (WaterDispenserDB); its default is applied
    -- in ns.InitDB, not here.
    MissingStackWarnings = false,
    Dispense = true,
    DispenseSolo = true,
    DispenseGroup = true,
    DispenseRaid = true,
    Items = {
        MageWater = {
            NoRemove = true,
            Icon = "Interface\\ICONS\\INV_Drink_18",
            -- Restacking merges conjured partials into full stacks, so the fill
            -- dispenses full stacks only and the leftover partial stays in bags.
            UseNotFullStack = false,
            FactorLevel = false,
            -- Mages reserve a personal stash; everything beyond it is giveable.
            KeepAtLeast = 20,
            IncludeQuantity = true,
            PlayerClasses = {MAGE = true},
            -- Mana classes get water; warriors and rogues are served by MageFood.
            --       war pal hun rog pri sha mag wlk dru
            Solo = CountsFor(0, 1, 1, 0, 1, 1, 0, 1, 1),
            Group = CountsFor(0, 1, 1, 0, 1, 1, 0, 1, 1),
            Raid = CountsFor(0, 2, 2, 0, 2, 2, 0, 2, 2)
        },
        MageFood = {
            NoRemove = true,
            Icon = "Interface\\ICONS\\INV_Misc_Food_09",
            -- Restacking merges conjured partials into full stacks, so the fill
            -- dispenses full stacks only and the leftover partial stays in bags.
            UseNotFullStack = false,
            FactorLevel = false,
            KeepAtLeast = 0,
            IncludeQuantity = true,
            PlayerClasses = {MAGE = true},
            -- Every class except mages (who conjure their own); scales 1/1/2.
            --       war pal hun rog pri sha mag wlk dru
            Solo = CountsFor(1, 1, 1, 1, 1, 1, 0, 1, 1),
            Group = CountsFor(1, 1, 1, 1, 1, 1, 0, 1, 1),
            Raid = CountsFor(2, 2, 2, 2, 2, 2, 0, 2, 2)
        },
        WarlockHealthstone = {
            NoRemove = true,
            Icon = "Interface\\ICONS\\INV_Stone_04",
            UseNotFullStack = false,
            FactorLevel = false,
            -- No count in the announcement: listeners care that you have one.
            IncludeQuantity = false,
            PlayerClasses = {WARLOCK = true},
            KeepAtLeast = 0,
            Solo = CountsFor(1, 1, 1, 1, 1, 1, 1, 0, 1),
            Group = CountsFor(1, 1, 1, 1, 1, 1, 1, 0, 1),
            Raid = CountsFor(1, 1, 1, 1, 1, 1, 1, 0, 1)
        }
    },
    Announcements = {
        Enabled = true
    }
}
