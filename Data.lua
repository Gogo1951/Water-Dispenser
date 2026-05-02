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
    ITEMS = "A335EE"
}

--------------------------------------------------------------------------------
-- URLs
--------------------------------------------------------------------------------

ns.URLS = {
    CURSEFORGE = "https://www.curseforge.com/wow/addons/water-dispenser",
    GITHUB = "https://github.com/Gogo1951/WaterDispenser",
    DISCORD = "https://discord.gg/eh8hKq992Q"
}

--------------------------------------------------------------------------------
-- Classes
--------------------------------------------------------------------------------

-- Ordered list used throughout the UI and config. Death Knight is omitted
-- because Water Dispenser targets Classic Era and TBC Classic.
ns.CLASSES = {
    "WARRIOR",
    "PALADIN",
    "HUNTER",
    "ROGUE",
    "PRIEST",
    "SHAMAN",
    "MAGE",
    "WARLOCK",
    "DRUID"
}

--------------------------------------------------------------------------------
-- Built-in Collections
--------------------------------------------------------------------------------

-- Each collection is two hash maps. Items maps an item ID to its rank
-- within the collection (1 = lowest tier). Spells maps a spell ID to its
-- rank in the same way. Both are one-line-per-id so the IDs are easy to
-- eyeball, and so that horizontal variants (e.g. talented healthstones)
-- can share a rank with their primary form without any extra plumbing.
--
-- The IDs were verified against Wowhead Classic / TBC Classic. If the
-- addon is ported to a later expansion, just add the new ranks at the
-- bottom of each map and the rest of the codebase picks them up
-- automatically via the reverse-lookup tables below.
ns.COLLECTIONS = {
    MageWater = {
        Items = {
            [5350] = 1, -- Conjured Water
            [2288] = 2, -- Conjured Fresh Water
            [2136] = 3, -- Conjured Purified Water
            [3772] = 4, -- Conjured Spring Water
            [8077] = 5, -- Conjured Mineral Water
            [8078] = 6, -- Conjured Sparkling Water
            [8079] = 7, -- Conjured Crystal Water
            [22018] = 8 -- Conjured Glacier Water (TBC)
        },
        Spells = {
            [5504] = 1, -- Conjure Water (rank 1)
            [5505] = 2, -- Conjure Water (rank 2)
            [5506] = 3, -- Conjure Water (rank 3)
            [6127] = 4, -- Conjure Water (rank 4)
            [10138] = 5, -- Conjure Water (rank 5)
            [10139] = 6, -- Conjure Water (rank 6)
            [10140] = 7, -- Conjure Water (rank 7)
            [27090] = 8 -- Conjure Water (TBC rank 8)
        }
    },
    MageFood = {
        Items = {
            [5349] = 1, -- Conjured Muffin
            [1113] = 2, -- Conjured Bread
            [1114] = 3, -- Conjured Rye
            [1487] = 4, -- Conjured Pumpernickel
            [8075] = 5, -- Conjured Sourdough
            [8076] = 6, -- Conjured Sweet Roll
            [22895] = 7 -- Conjured Cinnamon Roll (TBC)
        },
        Spells = {
            [587] = 1, -- Conjure Food (rank 1)
            [597] = 2, -- Conjure Food (rank 2)
            [990] = 3, -- Conjure Food (rank 3)
            [6129] = 4, -- Conjure Food (rank 4)
            [10144] = 5, -- Conjure Food (rank 5)
            [10145] = 6, -- Conjure Food (rank 6)
            [28612] = 7 -- Conjure Food (TBC rank 7)
        }
    },
    WarlockHealthstone = {
        -- Each rank has up to two "horizontal" talented variants. They
        -- share a rank with their primary form so the player gets credit
        -- for the highest tier they can produce regardless of which
        -- variant currently fills the bag.
        Items = {
            [5512] = 1, -- Minor Healthstone
            [19004] = 1, -- Minor Healthstone (horizontal A)
            [19005] = 1, -- Minor Healthstone (horizontal B)
            [5511] = 2, -- Lesser Healthstone
            [19006] = 2,
            [19007] = 2,
            [5509] = 3, -- Healthstone
            [19008] = 3,
            [19009] = 3,
            [5510] = 4, -- Greater Healthstone
            [19010] = 4,
            [19011] = 4,
            [9421] = 5, -- Major Healthstone
            [19012] = 5,
            [19013] = 5
        },
        Spells = {
            [6201] = 1, -- Create Healthstone (Minor)
            [6202] = 2, -- Create Healthstone (Lesser)
            [5699] = 3, -- Create Healthstone
            [11729] = 4, -- Create Healthstone (Greater)
            [11730] = 5 -- Create Healthstone (Major)
        }
    }
}

-- Reverse-lookups built once at file load. ITEM_TO_COLLECTION is the
-- source of truth for "is this item part of a collection?" — bag scans
-- consult it to tag inventory entries regardless of whether the player
-- knows the matching conjure spell. ITEM_RANK gives the in-collection
-- rank, used by the announcement and trade fill to pick the highest tier
-- the player has stacks of.
ns.ITEM_TO_COLLECTION = {}
ns.SPELL_TO_COLLECTION = {}
ns.ITEM_RANK = {}
for key, c in pairs(ns.COLLECTIONS) do
    for itemId, rank in pairs(c.Items) do
        ns.ITEM_TO_COLLECTION[itemId] = key
        ns.ITEM_RANK[itemId] = rank
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

-- Authoritative required-level per rank. GetItemInfo's itemMinLevel returns
-- 0 or stale values for some conjured items (e.g. fresh login, before the
-- cache warms), which would cause the level filter in FillTrade to either
-- pick a too-high-rank item or skip a usable lower-rank one. Hard-coding
-- the levels here keeps the level filter accurate regardless of cache
-- state. Healthstones are intentionally omitted; they're warlock-only
-- giveaways with no partner-level filtering in practice.
ns.COLLECTION_RANK_LEVELS = {
    MageWater = {5, 15, 25, 35, 45, 55, 65, 75},
    MageFood = {5, 15, 25, 35, 45, 55, 65}
}

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