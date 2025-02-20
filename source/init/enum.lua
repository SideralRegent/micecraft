mc.icat = {
	null = 0,
	block = 1,
	tool = 2
}

mc.iclass = { -- icat 2
	player = -1,
	null = 0,
	block = 1,
	sword = 21,
	shovel = 22,
	pickaxe = 23,
	axe = 24
}

mc.community = { -- Based on Forum codes. Affects on nothing.
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

mc.category = {
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

mc.physics = {
	rectangle = 1, -- Searches for the biggest rectangle
	line = 2, -- Searches vertically, for the largest set of blocks within the same line
	row = 3, -- Same as line, but horizontally
	rectangle_detailed = 4, -- Takes into account block's categories
	line_detailed = 5, -- ^
	row_detailed = 6, -- ^
	individual = 10 -- Each block has its individual collision (not recommended)
}

-- **Can't use:**
-- Super
-- (AZERTY/QWERTY issues): A, D, S, Q, W, Z
-- (Mac issues): CONTROL
-- Linux issues: ALT
-- (Interface issues): TAB, I, M, R, T, Y, E, C
-- TAB, CONTROL		A, D, I, M, Q, R, S, T, W, Y, Z

-- Else	(good)		B, F, G, H, J, K, L, N, O, P, U, V, X, SHIFT, FN [1 - 12] (?)

mc.keys = {
	[-1] = "none",
	[0] = "LEFT",
	[1] = "UP",
	[2] = "RIGHT",
	[3] = "DOWN",
	
--	[9] = "TAB", -- Game binding	
	[16] = "SHIFT",
--	[17] = "CONTROL", -- Issues with Mac
	[18] = "ALT", -- Issues with Linux
	
	[27] = "ESC",
	
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
	
	[75] = "K",
	[76] = "L",
	[77] = "M",
	[86] = "V",
	[88] = "X",
	
	[114] = "F3",
	
	[220] = "BACKSLASH"
}

mc.particle_display = {
	touch = 1,
	damage = 2,
	explode = 3,
	touhou = 9
}

mc.cooldown = {
	playerInventory = 400,
	blockDamage = 125,
	placeBlock = 200,
	useItem = 200,
}

mc.ranks = {
	loader = 0,
	staff = 1,
	moderator = 3,
	roomAdmin = 5,
	funcorp = 8,
	player = 10
}

mc.perms = { -- player
	damageBlock = false,
	placeBlock = false,
	useItem = false,
	hitEntities = false,
	respawn = false,
	useCommands = false,
	seeInventory = false,
	keyboardInteract = false,
	mouseInteract = false,
	
	spectateWorld = true,
	joinWorld = true,
	interfaceInteract = true,
}

mc.invalidPlayerReason = {
	banned = 1,
	newAccount = 2,
	souris = 3,
	notAllowedRoom = 4
}

mc.severity = {
	panic = 0,
	fatal = 1,
	important = 2,
	mild = 3,
	minimal = 4,
	trivial = 5
}

-- Reserved on 0 <= ID < 100
mc.textId = {
	runtime = 12,
	
	maxPlayers = 20,
	maxSpectators = 21,
	
	canOpenInventory = 41,
	canPlaceBlock = 42,
	canDamageBlock = 43,
	canUseItem = 44,
	
	password = 50,
	
}

do
	mc.associate = function(self, key)		
		local t = {}
		
		for k, v in next, self[key] do
			t[v] = k
		end
		
		for k, v in next, t do
			self[key][k] = v
		end
	end
	
	mc:associate("community")
	mc:associate("category")
	mc:associate("physics")
	mc:associate("keys")
	mc:associate("particle_display")
	mc:associate("invalidPlayerReason")
	mc:associate("ranks")
	mc:associate("severity")
	mc:associate("textId")
end