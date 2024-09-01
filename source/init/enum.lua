enum.community = { -- Based on Forum codes. Affects on nothing.
	-- Community 0 is just current player community
	["xx"] = 1,
	["int"] = 1, -- International  (all of them)
	["fr"] = 2, -- French
	["ru"] = 3, -- Russian
	["br"] = 4, -- Brazilian
	["es"] = 5, -- Spanish
	["cn"] = 6, -- Chinese
	["tr"] = 7, -- Turkish
	["sk"] = 8, -- Scandinavian (need to check code)
	["pl"] = 9, -- Polish
	["hu"] = 10, -- Hungary
	["nl"] = 11, -- Netherlands
	["ro"] = 12, -- Romania
	["id"] = 13, -- Indonesia
	["de"] = 14, -- Deutschland (Germany)
	["en"] = 15, -- English
	["ar"] = 16, -- Arabian
	["ph"] = 17, -- Phillipines / Tagalog (need to check code)
	["lt"] = 18, -- Lituanian
	["jp"] = 19,
	-- Community 20 is INT, but only Public INT
	["fi"] = 21, -- Finnish
	["cz"] = 22, -- Czech
	["sl"] = 23, -- Probably Slovakia (need to check code)
	["ct"] = 24, -- Probably Croatia (need to check code)
	["bg"] = 25, -- Bulgaria (unluckily, couldn't find code)
	["lv"] = 26, -- Letonian
	["he"] = 27, -- Hebrew
	["it"] = 28, -- Italian
	["et"] = 29, -- Estonian
	["az"] = 30, -- Azerbaiyan
	["pt"] = 31 -- Portuguese (had BR flag, but `technically` they're different communities)
}

enum.category = {
	
	default = 1,
	grains = 2,
	-- wood = 3,
	rocks_n_metals = 4,
	crystals = 5,
	--other = 6,
	water = 70,
	water_1 = 71,
	water_2 = 72,
	water_3 = 73,
	water_4 = 74,
	lava = 80,
	lava_1 = 81,
	lava_2 = 82,
	lava_3 = 83,
	lava_4 = 84,
	cobweb = 9,
	acid = 10
}

enum.physics = {
	rectangle = 1, -- Searches for the biggest rectangle
	line = 2, -- Searches vertically, for the largest set of blocks within the same line
	row = 3, -- Same as line, but horizontally
	rectangle_detailed = 4, -- Takes into account block's categories
	line_detailed = 5, -- ^
	row_detailed = 6, -- ^
	individual = 10 -- Each block has its individual collision (not recommended)
}
-- Generación de terreno:
-- Generar mapas para temperatura y Humedad
-- Generar Altitud
-- Generar mapa para rareza
-- Calcular bioma
-- Añadir octavas al terrenosegún el bioma
-- Suavizar altitud nuevamente (3 bloques de margen a cada lado del borde entre chunks)
-- Añadir elementos característicos por bioma
enum.biome = { -- T: Temperatura (-1 - 2)	H: Humedad (0 - 2)		R: Rareza (0 _1_ 2 3)
	-- Temperatura:
	--		-1.0 <= T < 0.0 : Helado
	--		0.0 <= T < 0.5 : Frío
	--		0.5 <= T < 1.0 : Templado
	--		1.0 <= T < 1.5 : Cálido
	--		1.5 <= T < 2.0 : Desértico
	
	-- Humedad:
	--		H < 1.0 : Continental
	--		1.0 <= H < 2.0 : Océanico
	
	-- Rareza:
	--		R < 1.0 : No usado
	--		1.0 <= R < 1.5 : Común
	--		1.5 <= R < 2.0 : Poco común
	--		2.0 <= R < 2.5 : Raro
	--		2.5 <= R < 3.0 : Super raro
	void = 0, -- T: 0.0, H: 0.0, R: 0.0
	
	plains = 1, -- T: 0.8, H: 0.4, R: 1.0
	sunflower_plains = 101, -- T: 0.8, H: 0.4, R: 1.25
	meadow = 102, -- T: 0.5 , H: 0.8, R: 2
	
	stony_peaks = 110, -- T: 1.0, H: 0.3, R: 1.75
	
	
	forest = 2, -- T: 0.7, H: 0.8, R: 1.0
	flower_forest = 201,  -- T: 0.7, H: 0.8, R: 1.25
	
	birch_forest = 210,  -- T: 0.6, H: 0.6, R: 1
	growth_birch_forest = 211, -- T: 0.6, H: 0.6, R: 1.5
	
	dark_forest = 220, -- T: 0.7, H: 0.8, R: 1
	
	swamp = 230, -- T: 0.8, H: 0.9, R: 1
	mangrove_swamp = 231, -- T: 0.8, H: 0.9, R: 1.5
	
	jungle = 240, -- T: 0.95, H: 0.9, R: 1
	sparse_jungle = 241, -- T: 0.95, H: 0.8, R: 1.5
	bamboo_jungle = 242, -- T: 0.95, H: 0.9, R: 1.75
	
	savanna = 250, -- T: 2.0, H: 0.2, R: 1
	savanna_plateau = 251, -- T: 2.0, H: 0.2, R: 1.5
	windswept_savanna = 252, -- T: 2.0 , H: 0.2, R: 2.5
	
	
	beach = 3, -- T: 0.8, H: 0.4, R: 1.0
	
	
	mushroom_fields = 4, -- T: 0.9, H: 1.0, R: 2.75
	
	
	desert = 5, -- T: 2.0, H: 0.0, R: 1.0
	badlands = 510, -- T: 2.0, H: 0.0, R: 1.75
	wooden_badlands = 511, -- T: 2.0, H: 0.2, R: 2
	eroded_badlands = 512, -- T: 2.0, H: 0.0, R: 2.25
	
	
	snowy_plains = 6, -- T: 0.25, H: 0.4, R: 1.0
	
	snowy_taiga = 610, -- T: 0.25, H: 0.6, R: 1.0
	grove = 611, -- T: 0.35 , H: 0.6, R: 1.25
	
	ice_spikes = 620, -- T: 0.0, H: 0.5, R: 1.5
	jagged_peaks = 621, -- T: -0.7, H: 0.9, R: 2
	frozen_peaks = 622, -- T: -0.7, H: 0.9, R: 1.5
	
	
	windswept_hills = 7, -- T: 0.2, H: 0.3, R: 1.0
	windswept_gravelly_hills = 701, -- T: 0.2, H: 0.3, R: 1.75
	
	windswept_forest = 710, -- T: 0.3, H: 0.3, R: 1.0
	taiga = 711, -- T: 0.25, H: 0.8, R: 1.0
	growth_pine_taiga = 712, -- T: 0.3, H: 0.8, R: 1.0
	
	stony_shore = 720, -- T: 0.2, H: 0.95, R: 1.0
	
	
	ocean = 8, -- T: 0.5, H: 1.5, R: 1.0
	
	warm_ocean = 810, -- T: 0.7, H: 1.5, R: 1.0
	lukewarm_ocean = 811, -- T: 0.8, H: 1.75, R: 1.5
	
	cold_ocean = 820, -- T: 0.3, H: 1.5, R: 1.0
	frozen_ocean = 821, -- T: -0.5, H: 1.5, R: 1.0 
	
	--=== NETHER ===--
	nether_wastes = 9, -- T: 2.0, H: 0.0, R: 1.0
	
	crimson_forest = 910, -- T: 2.0, H: 0.5, R: 1.0
	warped_forest = 911, -- T: 2.0, H: 1.0, R: 
	
	basalt_deltas = 920, -- T: 1.0, H: 1.0, R: 
	
	soulsand_valley = 940, -- T: 0.5, H: 1.0, R: 1.0
	
	
	--=== END ===--
	
	the_end = 10, -- T: 1.0, H: 0.0, R: 1.0
	
	small_end_islands = 1010, -- T: 0.65, H: 0.35, R: 1.0
	end_midlands = 1011, -- T: 0.35, H: 0.65, R: 1.0
	end_highlands = 1012, -- T: 0.0, H: 1.0, R: 
}


-- **Can't use:**
-- (AZERTY/QWERTY issues): A, D, S, Q, W, Z
-- (Mac issues): CONTROL
-- (Interface issues): TAB, I, M, R, T, Y, E

-- TAB, CONTROL		A, D, I, M, Q, R, S, T, W, Y, Z
-- Else				B, C, F, G, H, J, K, L, N, O, P, U, V, X, 

enum.keys = {
	[0] = "LEFT",
	[1] = "UP",
	[2] = "RIGHT",
	[3] = "DOWN",
	
--	[9] = "TAB", -- Game binding

	[16] = "SHIFT",
--	[17] = "CONTROL", -- Issues with Mac
	[18] = "ALT",
	
	[32] = "SPACE",
	
	[49] = "one",
	[50] = "two",
	[51] = "two",
	[52] = "three",
	[53] = "four",
	[54] = "five",
	[55] = "six",
	[56] = "seven",
	[57] = "eight",
	[58] = "nine",
	
	[67] = "C",
	
	[76] = "L",
	[77] = "M",
	
	[114] = "F3"
}

do
	local associate = function(t)
		local it = {}
		
		for k, v in next, t do
			it[k] = v
			it[v] = k
		end
		
		t = it
		
		return t
	end
	
	enum.community = associate(enum.community)
	enum.category = associate(enum.category)
	enum.physics = associate(enum.physics)
	enum.keys = associate(enum.keys)
end