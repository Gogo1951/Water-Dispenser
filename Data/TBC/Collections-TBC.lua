local _, ns = ...

-- [collectionKey] = { Items = { [itemId] = { Rank, Use Level, Heal } }, Spells = { [spellId] = Rank } }
ns.COLLECTIONS = {
	MageWater = {
		-- [itemId] = { Rank, Use Level }, -- Item Name
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
		-- [spellId] = Rank, -- Spell Name (Rank)
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
		-- [itemId] = { Rank, Use Level }, -- Item Name
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
		-- [spellId] = Rank, -- Spell Name (Rank)
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
		-- [itemId] = { Rank, Use Level, Heal }, -- Item Name (Heal)
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
		},
		-- [spellId] = Rank, -- Spell Name (Rank)
		Spells = {
			[6201] = 1, -- Create Healthstone (Rank 1)
			[6202] = 2, -- Create Healthstone (Rank 2)
			[5699] = 3, -- Create Healthstone (Rank 3)
			[11729] = 4, -- Create Healthstone (Rank 4)
			[11730] = 5, -- Create Healthstone (Rank 5)
			[27230] = 6, -- Create Healthstone (Rank 6)
		},
	},
}

-- spellId, -- Spell Name (Rank)
ns.HEALTHSTONE_TALENT_SPELLS = {
	18692, -- Improved Healthstone (Rank 1)
	18693, -- Improved Healthstone (Rank 2)
}

--[[
How We Got the Data

Last Validated
	2026-10-08, TBC Anniversary 2.5.6.69795

Notes
	- The class-made supplies Water Dispenser hands out in trades: a mage's conjured water and food, and a warlock's healthstones. Each collection lists every item its conjure spell makes on this client, and every rank of that spell.
	- Rank is an item's tier within its collection, 1 the lowest. A spell's rank is the rank of the items it makes, which is how Features/Utilities.lua pairs each conjure spell with its items (SPELL_TO_ITEMS). Items sharing a rank are one tier, like the three healthstones made at each rank.
	- Use Level is the level a player needs to use the item, as its tooltip states. Trades and the conjure buttons (Features/Conjure-Buttons.lua) read it to pick the best rank the partner can use. It's stored rather than read from C_Item.GetItemInfo, whose minimum level comes back 0 or stale for some conjured items.
	- Heal, on healthstones only, is the health the stone restores, as its tooltip states. Only Diagnostic Tools reads it.
	- Each healthstone rank has three items: the stones a warlock makes with 0, 1 and 2 points in Improved Healthstone. They share rank and use level, and each point adds 10% to the heal.
	- HEALTHSTONE_TALENT_SPELLS holds Improved Healthstone's two ranks, as the passive spells the talent grants, lowest first. The highest one a warlock knows is the rank they took (HealthstoneTalentRank in Features/Group-Spares.lua).
	- On this client the stones made at 0, 1 and 2 points are three different unique items, so a raid can carry one of each at once and coordinates around which rank each warlock took. That's why the player tooltip states a warlock's rank even when they carry no stone.

SQL (CMaNGOS)
	tbc-db

	ns.COLLECTIONS.MageWater
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

	ns.COLLECTIONS.MageFood
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

	ns.COLLECTIONS.WarlockHealthstone
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

	ns.HEALTHSTONE_TALENT_SPELLS
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	None.
]]
