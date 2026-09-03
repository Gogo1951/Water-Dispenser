local _, ns = ...

--------------------------------------------------------------------------------
-- Built-in Collections
--------------------------------------------------------------------------------

--[[
	Each collection: Items[itemId] = {rank, level [, heal]}, Spells[spellId] = rank.
	  rank   in-collection tier (1 = lowest); horizontal variants share a rank.
	  level  player level required to use it. Authoritative — GetItemInfo's
			 itemMinLevel is 0 or stale for some conjured items.
	  heal   healthstone only; amount restored (informational).
]]
ns.COLLECTIONS = {
	MageWater = {
		--[[

		SELECT 
			CONCAT('	[', entry, '] = {', spell_rank, ', ', req_level, '}, -- ', item_name) AS lua_array_output
		FROM (
			SELECT 
				it.entry AS entry,
				ROW_NUMBER() OVER(ORDER BY it.RequiredLevel ASC) AS spell_rank,
				it.RequiredLevel AS req_level,
				it.name AS item_name
			FROM item_template it
			JOIN spell_template st ON st.EffectItemType1 = it.entry
			WHERE 
				st.SpellName = 'Conjure Water' 
				AND st.Effect1 = 24
		) AS base_data
		ORDER BY req_level ASC;

		]]
		-- [itemId] = {rank, level}, -- item name
		Items = {
			[5350] = { 1, 1 }, -- Conjured Water
			[2288] = { 2, 5 }, -- Conjured Fresh Water
			[2136] = { 3, 15 }, -- Conjured Purified Water
			[3772] = { 4, 25 }, -- Conjured Spring Water
			[8077] = { 5, 35 }, -- Conjured Mineral Water
			[8078] = { 6, 45 }, -- Conjured Sparkling Water
			[8079] = { 7, 55 }, -- Conjured Crystal Water
			[30703] = { 8, 60 }, -- Conjured Mountain Spring Water
			[22018] = { 9, 65 }, -- Conjured Glacier Water
		},
		-- [spellId] = rank, -- spell name (rank)
		Spells = {
			[5504] = 1, -- Conjure Water (Rank 1)
			[5505] = 2, -- Conjure Water (Rank 2)
			[5506] = 3, -- Conjure Water (Rank 3)
			[6127] = 4, -- Conjure Water (Rank 4)
			[10138] = 5, -- Conjure Water (Rank 5)
			[10139] = 6, -- Conjure Water (Rank 6)
			[10140] = 7, -- Conjure Water (Rank 7)
			[37420] = 8, -- Conjure Water (Rank 8)
			[27090] = 9, -- Conjure Water (Rank 9)
		},
	},
	MageFood = {
		--[[

		SELECT 
			CONCAT('	[', entry, '] = {', spell_rank, ', ', req_level, '}, -- ', item_name) AS lua_array_output
		FROM (
			SELECT 
				it.entry AS entry,
				ROW_NUMBER() OVER(ORDER BY it.RequiredLevel ASC) AS spell_rank,
				it.RequiredLevel AS req_level,
				it.name AS item_name
			FROM item_template it
			WHERE EXISTS (
				SELECT 1 
				FROM spell_template st 
				WHERE st.EffectItemType1 = it.entry 
				  AND st.SpellName = 'Conjure Food' 
				  AND st.Effect1 = 24
			)
		) AS base_data
		ORDER BY req_level ASC;

		]]
		-- [itemId] = {rank, level}, -- item name
		Items = {
			[5349] = { 1, 1 }, -- Conjured Muffin
			[1113] = { 2, 5 }, -- Conjured Bread
			[1114] = { 3, 15 }, -- Conjured Rye
			[1487] = { 4, 25 }, -- Conjured Pumpernickel
			[8075] = { 5, 35 }, -- Conjured Sourdough
			[8076] = { 6, 45 }, -- Conjured Sweet Roll
			[22895] = { 7, 55 }, -- Conjured Cinnamon Roll
			[22019] = { 8, 65 }, -- Conjured Croissant
		},
		-- [spellId] = rank, -- spell name (rank)
		Spells = {
			[587] = 1, -- Conjure Food (Rank 1)
			[597] = 2, -- Conjure Food (Rank 2)
			[990] = 3, -- Conjure Food (Rank 3)
			[6129] = 4, -- Conjure Food (Rank 4)
			[10144] = 5, -- Conjure Food (Rank 5)
			[10145] = 6, -- Conjure Food (Rank 6)
			[28612] = 7, -- Conjure Food (Rank 7)
			[33717] = 8, -- Conjure Food (Rank 8)
		},
	},
	WarlockHealthstone = {
		--[[

		SELECT 
			CONCAT('	[', entry, '] = {', item_rank, ', ', req_level, ', ', heal_amount, '}, -- ', item_name, ' (', heal_amount, ')') AS lua_array_output
		FROM (
			SELECT 
				it.entry AS entry,
				DENSE_RANK() OVER(ORDER BY it.RequiredLevel ASC) AS item_rank,
				it.RequiredLevel AS req_level,
				it.name AS item_name,
				(st.EffectBasePoints1 + 1) AS heal_amount
			FROM item_template it
			JOIN spell_template st ON st.Id = COALESCE(
				NULLIF(it.spellid_1, 0), 
				NULLIF(it.spellid_2, 0), 
				NULLIF(it.spellid_3, 0), 
				NULLIF(it.spellid_4, 0), 
				NULLIF(it.spellid_5, 0)
			)
			WHERE 
				it.name LIKE '%Healthstone%' 
				AND it.class = 0 
				AND it.entry != 30347 -- Explicitly ignores Alexander's Test Healthstone
		) AS base_data
		ORDER BY req_level ASC, heal_amount ASC;

		]]
		-- [itemId] = {rank, level, heal}, -- item name (heal)
		Items = {
			[5512] = { 1, 1, 100 }, -- Minor Healthstone (100)
			[19004] = { 1, 1, 110 }, -- Minor Healthstone (110)
			[19005] = { 1, 1, 120 }, -- Minor Healthstone (120)
			[5511] = { 2, 12, 250 }, -- Lesser Healthstone (250)
			[19006] = { 2, 12, 275 }, -- Lesser Healthstone (275)
			[19007] = { 2, 12, 300 }, -- Lesser Healthstone (300)
			[5509] = { 3, 24, 500 }, -- Healthstone (500)
			[19008] = { 3, 24, 550 }, -- Healthstone (550)
			[19009] = { 3, 24, 600 }, -- Healthstone (600)
			[5510] = { 4, 36, 800 }, -- Greater Healthstone (800)
			[19010] = { 4, 36, 880 }, -- Greater Healthstone (880)
			[19011] = { 4, 36, 960 }, -- Greater Healthstone (960)
			[9421] = { 5, 48, 1200 }, -- Major Healthstone (1200)
			[19012] = { 5, 48, 1320 }, -- Major Healthstone (1320)
			[19013] = { 5, 48, 1440 }, -- Major Healthstone (1440)
			[22103] = { 6, 60, 2080 }, -- Master Healthstone (2080)
			[22104] = { 6, 60, 2288 }, -- Master Healthstone (2288)
			[22105] = { 6, 60, 2496 }, -- Master Healthstone (2496)
			[36889] = { 7, 63, 3500 }, -- Demonic Healthstone (3500)
			[36890] = { 7, 63, 3850 }, -- Demonic Healthstone (3850)
			[36891] = { 7, 63, 4200 }, -- Demonic Healthstone (4200)
			[36892] = { 8, 69, 4280 }, -- Fel Healthstone (4280)
			[36893] = { 8, 69, 4708 }, -- Fel Healthstone (4708)
			[36894] = { 8, 69, 5136 }, -- Fel Healthstone (5136)
		},
		-- [spellId] = rank, -- spell name (rank)
		Spells = {
			[6201] = 1, -- Create Healthstone (Rank 1)
			[6202] = 2, -- Create Healthstone (Rank 2)
			[5699] = 3, -- Create Healthstone (Rank 3)
			[11729] = 4, -- Create Healthstone (Rank 4)
			[11730] = 5, -- Create Healthstone (Rank 5)
			[27230] = 6, -- Create Healthstone (Rank 6)
			[47871] = 7, -- Create Healthstone (Rank 7)
			[47878] = 8, -- Create Healthstone (Rank 8)
		},
	},
}

--------------------------------------------------------------------------------
-- Improved Healthstone
--------------------------------------------------------------------------------

--[[
	The talent's two ranks, as the passive spells they grant, ascending. The highest
	one the warlock knows is their rank.

	Before Wrath, a stone made at 0, 1 and 2 points was three different unique items,
	so a raid could carry one of each at once. Which rank a warlock took is therefore
	something the raid coordinates around, which is why the tooltip states it even
	when they are carrying nothing. It is also why each rank in ns.COLLECTIONS has
	three entries with the same rank and level but 10%% apart on heal.
]]
ns.HEALTHSTONE_TALENT_SPELLS = { 18692, 18693 }

--------------------------------------------------------------------------------
-- Built-in Collection Metadata
--------------------------------------------------------------------------------

-- Shared display order (trade fill, announcement, options sidebar).
ns.BUILTIN_ORDER = { "MageWater", "MageFood", "WarlockHealthstone" }

--[[
	Virtual items the user configures in options; they resolve to a real item ID
	at trade time from the partner's level. Keys match ns.COLLECTIONS.
]]
ns.COLLECTION_META = {
	MageWater = {
		NameKey = "ITEM_MAGE_WATER",
		Icon = "Interface\\ICONS\\INV_Drink_18",
	},
	MageFood = {
		NameKey = "ITEM_MAGE_FOOD",
		Icon = "Interface\\ICONS\\INV_Misc_Food_09",
	},
	WarlockHealthstone = {
		NameKey = "ITEM_WARLOCK_HEALTHSTONE",
		Icon = "Interface\\ICONS\\INV_Stone_04",
		-- Healthstones are unique, so a trade can only ever carry 0 or 1.
		Unique = true,
	},
}
