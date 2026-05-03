local _, ns = ...

ns.L = LibStub("AceLocale-3.0"):GetLocale("WaterDispenser")

--------------------------------------------------------------------------------
-- Colors
--------------------------------------------------------------------------------

local C_TITLE = "FFD100" -- Gold: Titles, Headers, Section Names
local C_INFO = "00BBFF" -- Blue: Interactions, Toggles, Links, Keybinds
local C_BODY = "CCCCCC" -- Silver: Descriptions, Help Text
local C_TEXT = "FFFFFF" -- White: Messages, Values, Item Names
local C_SUCCESS = "33CC33" -- Green: Enabled / On
local C_DISABLED = "CC3333" -- Red: Disabled / Off
local C_SEP = "AAAAAA" -- Gray: Separators, Dividers
local C_MUTED = "808080" -- Dark Gray: Meta-data, Version Numbers

local COLOR_PREFIX = "|cff"

ns.COLORS = {
    TITLE = COLOR_PREFIX .. C_TITLE,
    INFO = COLOR_PREFIX .. C_INFO,
    DESC = COLOR_PREFIX .. C_BODY,
    TEXT = COLOR_PREFIX .. C_TEXT,
    SUCCESS = COLOR_PREFIX .. C_SUCCESS,
    DISABLED = COLOR_PREFIX .. C_DISABLED,
    SEP = COLOR_PREFIX .. C_SEP,
    MUTED = COLOR_PREFIX .. C_MUTED
}

ns.CLASS_COLORS = {
    DEATHKNIGHT = "C41E3A",
    DRUID = "FF7C0A",
    HUNTER = "AAD372",
    MAGE = "3FC7EB",
    PALADIN = "F48CBA",
    PRIEST = "FFFFFF",
    ROGUE = "FFF468",
    SHAMAN = "0070DD",
    WARLOCK = "8788EE",
    WARRIOR = "C69B6D",
    ITEMS = "A335EE",
}

--------------------------------------------------------------------------------
-- URLs
--------------------------------------------------------------------------------

ns.URLS = {
    CURSEFORGE = "https://www.curseforge.com/wow/addons/water-dispenser",
    GITHUB = "https://github.com/Gogo1951/Water-Dispenser",
    DISCORD = "https://discord.gg/eh8hKq992Q"
}

--------------------------------------------------------------------------------
-- Classes
--------------------------------------------------------------------------------

-- Ordered list used throughout the UI and config. Death Knight is omitted
-- because Water Dispenser targets Classic Era and TBC Classic.
ns.CLASSES = {
    "DRUID",
    "HUNTER",
    "MAGE",
    "PALADIN",
    "PRIEST",
    "ROGUE",
    "SHAMAN",
    "WARLOCK",
    "WARRIOR",
}

--------------------------------------------------------------------------------
-- Built-in Collections
--------------------------------------------------------------------------------

-- Each collection is two hash maps. Items maps an item ID to a metadata
-- table { rank, level, heal? } where rank is the in-collection tier
-- (1 = lowest), level is the player level required to *use* the item
-- (authoritative; do not rely on GetItemInfo's itemMinLevel since it
-- returns 0 or stale values for some conjured items), and heal is the
-- amount restored by healthstones (purely informational, but kept here
-- so future features have a single source of truth). Spells maps a spell
-- ID to the rank it produces.
--
-- Horizontal variants (e.g. talented healthstones at the same rank but
-- different heal values) share a rank with their primary form so the
-- player gets credit for the highest tier they can produce regardless of
-- which variant currently fills the bag.
ns.COLLECTIONS = {
    MageWater = {
        -- { rank, level }
        Items = {
            [5350]  = {rank = 1, level = 1},  -- Conjured Water
            [2288]  = {rank = 2, level = 5},  -- Conjured Fresh Water
            [2136]  = {rank = 3, level = 15}, -- Conjured Purified Water
            [3772]  = {rank = 4, level = 25}, -- Conjured Spring Water
            [8077]  = {rank = 5, level = 35}, -- Conjured Mineral Water
            [8078]  = {rank = 6, level = 45}, -- Conjured Sparkling Water
            [8079]  = {rank = 7, level = 55}, -- Conjured Crystal Water
            [30703] = {rank = 8, level = 60}, -- Conjured Mountain Spring Water
            [22018] = {rank = 9, level = 65}  -- Conjured Glacier Water
        },
        Spells = {
            [5504]  = 1, -- Conjure Water (Rank 1)
            [5505]  = 2, -- Conjure Water (Rank 2)
            [5506]  = 3, -- Conjure Water (Rank 3)
            [6127]  = 4, -- Conjure Water (Rank 4)
            [10138] = 5, -- Conjure Water (Rank 5)
            [10139] = 6, -- Conjure Water (Rank 6)
            [10140] = 7, -- Conjure Water (Rank 7)
            [37420] = 8, -- Conjure Water (Rank 8)
            [27090] = 9, -- Conjure Water (Rank 9)
            [42955] = 1, -- Conjure Refreshment (Rank 1)
            [42956] = 2  -- Conjure Refreshment (Rank 2)
        }
    },
    MageFood = {
        -- { rank, level }
        Items = {
            [5349]  = {rank = 1, level = 1},  -- Conjured Muffin
            [1113]  = {rank = 2, level = 5},  -- Conjured Bread
            [1114]  = {rank = 3, level = 15}, -- Conjured Rye
            [1487]  = {rank = 4, level = 25}, -- Conjured Pumpernickel
            [8075]  = {rank = 5, level = 35}, -- Conjured Sourdough
            [8076]  = {rank = 6, level = 45}, -- Conjured Sweet Roll
            [22895] = {rank = 7, level = 55}, -- Conjured Cinnamon Roll
            [22019] = {rank = 8, level = 65}  -- Conjured Croissant
        },
        Spells = {
            [587]   = 1, -- Conjure Food (Rank 1)
            [597]   = 2, -- Conjure Food (Rank 2)
            [990]   = 3, -- Conjure Food (Rank 3)
            [6129]  = 4, -- Conjure Food (Rank 4)
            [10144] = 5, -- Conjure Food (Rank 5)
            [10145] = 6, -- Conjure Food (Rank 6)
            [28612] = 7, -- Conjure Food (Rank 7)
            [33717] = 8  -- Conjure Food (Rank 8)
        }
    },
    WarlockHealthstone = {
        -- { rank, level, heal } — heal is the HP restored by the
        -- highest-talented variant; horizontal variants stack rank.
        Items = {
            [5512]  = {rank = 1, level = 1,  heal = 100},  -- Minor Healthstone (100)
            [19004] = {rank = 1, level = 1,  heal = 110},  -- Minor Healthstone (110)
            [19005] = {rank = 1, level = 1,  heal = 120},  -- Minor Healthstone (120)
            [5511]  = {rank = 2, level = 12, heal = 250},  -- Lesser Healthstone (250)
            [19006] = {rank = 2, level = 12, heal = 275},  -- Lesser Healthstone (275)
            [19007] = {rank = 2, level = 12, heal = 300},  -- Lesser Healthstone (300)
            [5509]  = {rank = 3, level = 24, heal = 500},  -- Healthstone (500)
            [19008] = {rank = 3, level = 24, heal = 550},  -- Healthstone (550)
            [19009] = {rank = 3, level = 24, heal = 600},  -- Healthstone (600)
            [5510]  = {rank = 4, level = 36, heal = 800},  -- Greater Healthstone (800)
            [19010] = {rank = 4, level = 36, heal = 880},  -- Greater Healthstone (880)
            [19011] = {rank = 4, level = 36, heal = 960},  -- Greater Healthstone (960)
            [9421]  = {rank = 5, level = 48, heal = 1200}, -- Major Healthstone (1200)
            [19012] = {rank = 5, level = 48, heal = 1320}, -- Major Healthstone (1320)
            [19013] = {rank = 5, level = 48, heal = 1440}, -- Major Healthstone (1440)
            [22103] = {rank = 6, level = 60, heal = 2080}, -- Master Healthstone (2080)
            [22104] = {rank = 6, level = 60, heal = 2288}, -- Master Healthstone (2288)
            [22105] = {rank = 6, level = 60, heal = 2496}, -- Master Healthstone (2496)
            [36889] = {rank = 7, level = 63, heal = 3500}, -- Demonic Healthstone (3500)
            [36890] = {rank = 7, level = 63, heal = 3850}, -- Demonic Healthstone (3850)
            [36891] = {rank = 7, level = 63, heal = 4200}, -- Demonic Healthstone (4200)
            [36892] = {rank = 8, level = 69, heal = 4280}, -- Fel Healthstone (4280)
            [36893] = {rank = 8, level = 69, heal = 4708}, -- Fel Healthstone (4708)
            [36894] = {rank = 8, level = 69, heal = 5136}  -- Fel Healthstone (5136)
        },
        Spells = {
            [6201]  = 1, -- Create Healthstone (Rank 1)
            [6202]  = 2, -- Create Healthstone (Rank 2)
            [5699]  = 3, -- Create Healthstone (Rank 3)
            [11729] = 4, -- Create Healthstone (Rank 4)
            [11730] = 5, -- Create Healthstone (Rank 5)
            [27230] = 6, -- Create Healthstone (Rank 6)
            [47871] = 7, -- Create Healthstone (Rank 7)
            [47878] = 8  -- Create Healthstone (Rank 8)
        }
    }
}

-- Reverse-lookups built once at file load. ITEM_TO_COLLECTION is the
-- source of truth for "is this item part of a collection?" — bag scans
-- consult it to tag inventory entries regardless of whether the player
-- knows the matching conjure spell. ITEM_RANK and ITEM_LEVEL are used
-- by the announcement and trade fill to pick the highest tier the player
-- has stacks of, and to filter by what the trade partner can use.
ns.ITEM_TO_COLLECTION = {}
ns.SPELL_TO_COLLECTION = {}
ns.ITEM_RANK = {}
ns.ITEM_LEVEL = {}
for key, c in pairs(ns.COLLECTIONS) do
    for itemId, meta in pairs(c.Items) do
        ns.ITEM_TO_COLLECTION[itemId] = key
        ns.ITEM_RANK[itemId] = meta.rank
        ns.ITEM_LEVEL[itemId] = meta.level
    end
    for spellId in pairs(c.Spells) do
        ns.SPELL_TO_COLLECTION[spellId] = key
    end
end

-- Pick lock spell — used by the rogue lockbox flow, not part of any
-- consumable collection.
ns.SPELL_PICK_LOCK = 1804

--------------------------------------------------------------------------------
-- Built-in Collection Metadata
--------------------------------------------------------------------------------

-- Display order for built-in collections. Used by the trade fill, the
-- announcement message, and the options sidebar so the three places agree on
-- "water → food → healthstones."
ns.BUILTIN_ORDER = {"MageWater", "MageFood", "WarlockHealthstone"}

-- Keys here match the keys of ns.COLLECTIONS. These are the "virtual"
-- items the user configures in the options panel even though they resolve to
-- different real item IDs at trade time based on the partner's level.
ns.COLLECTION_META = {
    MageWater = {
        NameKey = "ITEM_MAGE_WATER",
        Icon = "Interface\\ICONS\\INV_Drink_18"
    },
    MageFood = {
        NameKey = "ITEM_MAGE_FOOD",
        Icon = "Interface\\ICONS\\INV_Misc_Food_09"
    },
    WarlockHealthstone = {
        NameKey = "ITEM_WARLOCK_HEALTHSTONE",
        Icon = "Interface\\ICONS\\INV_Stone_04"
    }
}

--------------------------------------------------------------------------------
-- Default Saved Variables
--------------------------------------------------------------------------------

-- Class count defaults are expressed as small tables here purely to make the
-- defaults readable. Use-case-driven defaults: mages and mana users get water,
-- melee get food, everyone except the warlock gets a healthstone.
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

ns.DB_DEFAULTS = {
    Version = 8,
    WelcomeMessage = true,
    MissingStackWarnings = false,
    AutoFillSolo = true,
    AutoFillGroup = true,
    AutoFillRaid = true,
    LockedSlot = true,
    Items = {
        MageWater = {
            NoRemove = true,
            Icon = "Interface\\ICONS\\INV_Drink_18",
            UseNotFullStack = false,
            FactorLevel = true,
            -- Mages reserve a personal stash by default; the announcement
            -- and trade fill draw from anything beyond the reserve.
            KeepAtLeast = 20,
            IncludeQuantity = true,
            -- Only mages broadcast/fill conjured water by default.
            PlayerClasses = {MAGE = true},
            -- Mana classes get water; warriors and rogues get nothing here
            -- (they're served by MageFood instead).
            --       war pal hun rog pri sha mag wlk dru
            Solo = CountsFor(0, 1, 1, 0, 1, 1, 0, 1, 1),
            Group = CountsFor(0, 2, 2, 0, 2, 2, 0, 2, 2),
            Raid = CountsFor(0, 4, 4, 0, 4, 4, 0, 4, 4)
        },
        MageFood = {
            NoRemove = true,
            Icon = "Interface\\ICONS\\INV_Misc_Food_09",
            UseNotFullStack = false,
            FactorLevel = true,
            KeepAtLeast = 0,
            IncludeQuantity = true,
            -- Only mages broadcast/fill conjured food by default.
            PlayerClasses = {MAGE = true},
            -- Every class gets food by default except mages, who conjure
            -- their own. Numbers scale 1/2/4 across solo / group / raid.
            --       war pal hun rog pri sha mag wlk dru
            Solo = CountsFor(1, 1, 1, 1, 1, 1, 0, 1, 1),
            Group = CountsFor(2, 2, 2, 2, 2, 2, 0, 2, 2),
            Raid = CountsFor(4, 4, 4, 4, 4, 4, 0, 4, 4)
        },
        WarlockHealthstone = {
            NoRemove = true,
            Icon = "Interface\\ICONS\\INV_Stone_04",
            UseNotFullStack = false,
            FactorLevel = true,
            -- Healthstones don't get a quantity in the announcement by
            -- default — listeners care whether you have one to spare, not
            -- the exact count. Users can flip this on per-item if they
            -- want stack counts.
            IncludeQuantity = false,
            -- Only warlocks broadcast/fill healthstones by default.
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

--------------------------------------------------------------------------------
-- Icon Coordinates for Inline Textures
--------------------------------------------------------------------------------

-- WoW inline icon escape:
--   |T<path>:w:h:xOff:yOff:srcW:srcH:left:right:top:bottom|t
-- Width/height of 0 matches the surrounding line height. The cropping quad
-- (4..60 of 64) trims the transparent border present on most Blizzard icons.
ns.ICON_COORDS = ":0:0:0:0:64:64:4:60:4:60"