do
	local void = function() end
	blockMeta = MetaData:newMetaData({
		name = "null", -- Block Name, used for translations
		
		drop = "void", -- When broken, identifier of what it drops
		
		sound = {
			destroy = "cite18/ballon-touche-1",
			place = "cite18/bouton1"
		},
		
		state = {
			fallable = false,
			cascadeDestroy = false
		},
		
		fluidRate = 0, -- How many ticks it takes to "flow"
		fluidLevel = FL_EMPTY, -- The level of the fluid [n/4 of a block vertically]
		
		glow = 0, -- Light emission (none = 0; max: 15)
		translucent = false, -- If it is translucent (has different alpha values) [blocks with non-squarish/irregular shapes have this property too]
		
		--shadow = "17e2d5113f3.png", -- Sprite for shawdow [black]
		--lightning = "1817dc55c70.png", -- Sprite for lightning [white]
		sprite = false,-- "17e1315385d.png", -- Regular sprite
		shows = true,
		
		durability = 24, -- How durable is this block against hits
		
		hardness = 1, -- How complex is the structure of the block. The more complex, higher order tools will be needed to break it
		category = 1, -- The physics category the block belongs to. Different restitution and friction will be applied according to the category
		
		particle = 0, -- Particles that this block should emit when destroyed
		interactable = false, -- if it's possible to interact with this block (relevant for method onInteract), BOOLEAN (false) or NUMBER (TRUE), number denotes distance. Use block distance
		
		color = 0xA500BC, -- Misc
		restricted = false, -- If players shouldn't be able to hold this block
		fixedId = 0, -- Misc
		
		onCreate = void, -- Triggers when this block is created in the Map 
		onDestroy = void, -- Triggers when this block is destroyed
		-- Note: onCreate will not trigger when a block tile is created (block:new)
		
		onInteract = void, -- Triggers when an entity tries to interact with this block
		
		onDamage = void, -- Triggers when a block has been damaged
		
		onContact = void, -- Triggers when a Player makes contact with the Block
		
		onUpdate = void -- Triggers when a Block nearby has suffered an update of its properties
	})
end

blockMeta:newTemplate("Dirt", {
	name = "dirt",
	
	category = mc.category.grains,
	drop = "dirt",
	durability = 14,
	hardness = 0,
	
	sound = {
		place = "cite18/herbe4",
		destroy = "cite18/herbe1"
	},
	
	sprite = "17dd4af277b.png",
	
	translucent = false,
	
	interactable = false,
	color = 0x886245,
	onUpdate = function(self, block) -- Make grass
		if not block then return end
		if self.x == block.x and block.y == (self.y - 1) then -- If the block is right above us
			if block.type ~= blockMeta._C_VOID then -- If it isn't air
				if not block.translucent then -- If it isn't translucent
					return false -- Do nothing
				end
			end
			
			local grassifyTime = math.random(6, 16)
			self:pulse()
			self:setTask(grassifyTime, false, function()
				self:create(blockMeta.maps.grass, true, true, false) -- Create a grass block
			end)
	
			return true
		end
		
		return false
	end
})

blockMeta:newTemplate("Grass", "Dirt", {
	name = "grass",
	
	sprite = "17dd4b0a359.png",
	
	drop = "dirt",
	durability = 18,
	
	color = 0x7D7A42, -- avg: 827043
	
	onUpdate = function(self, block) -- Make it dirt
		if block.x == self.x and (block.y == self.y - 1) then -- If the block that updated is above this one
			if block.type ~= 0 then -- If it isn't air
				if not block.translucent then -- If the block isn't translucent
					self:pulse()
					local dirtifyTime = math.random(6, 16)
					self:setTask(dirtifyTime, false, function()
						self:create(blockMeta.maps.dirt, true, true, false) -- Create a dirt block
					end)
				
					return true
				end
			end
		end
		
		return false
	end
})

blockMeta:newTemplate("Fluid", {
	name = "x_flow",
	
	category = mc.category.water,
	drop = "void",
	
	glow = 0,
	
	translucent = true,
	sprite = "182076fc21b.png",
	
	fluidRate = 1,
	fluidLevel = FL_FILL,
	
	durability = math.huge,
	hardness = 9e99,
	
	color = 0x8BA8FF,
	particle = 7,
	
	onUpdate = function(self, _)
		self:assertStateActions()
	end
})

blockMeta:newTemplate("Granular", {
	name = "granular",
	
	category = mc.category.grains,
	drop = "void",
	
	glow = 0,
	translucent = false,
	sprite = "17dd4b5635b.png",
	
	state = {
		fallable = true,
	},
	
	durability = 18,
	hardness = 0,
	
	interactable = false,
	
	color = 0xDAD29E,
	particle = 24,
	
	--[[onContact = function(self, _)
		self:assertStateActions()
	end,]]
	
	onUpdate = function(self, _)
		self:assertStateActions()
	end
})

blockMeta:newTemplate("Stone", {
	name = "stone",
	
	category = mc.category.rocks_n_metals,
	drop = "void", -- To define
	
	glow = 0,
	translucent = false,
	sprite = "17dd4b6935c.png",
	
	durability = 34,
	hardness = 1,
	
	interactable = false,
	color = 0x7E7E7E,
	particle = 4
})

blockMeta:newTemplate("Ore", "Stone", {
	name = "default_ore",
	sprite = "17dd4b39b5c.png",
	durability = 42,
	particle = 3,
	glow = 0,
	
	color = 0x8D8580
})

blockMeta:setConstant("void", VOID)-- Assign block IDs to avoid clashes:
-- 0x [general identifier] d [specific identifier]
-- General identifier is just the type. It doesn't really matter for it to be consistent. 
-- Specific identifier is among that type.
-- Always separe them with D.
-- Write both in decimal even tho we're using hexa
blockMeta:set(VOID, "Void", {
	name = "void", 
	category = VOID,
	sprite = nil,
	color = 0x6A7495
})

blockMeta:set(0x1, "Dirt", {
	name = "dirt",
	color = 0x886245,
}) -- dirt

blockMeta:set(0x1d1, "Dirt", {
	name = "dirtcelium", 
	sprite = "17dd4ae8f5b.png"
}) -- dirtcelium

blockMeta:set(0x2, "Grass", {
	name = "grass",
	color = 0x7D7A42 -- avg: 827043
}) -- grass

blockMeta:set(0x2d1, "Grass", {
	name = "mycelium", 
	sprite = "17dd4b1875c.png",
	color = 0x70646A
}) -- mycelium

blockMeta:set(0x2d2, "Grass", {
	name = "snowed_grass", 
	sprite = "17dd4aedb5d.png",
	color = 0x9D897B
}) -- snowed grass

blockMeta:set(0x3, "Stone", {
	name = "stone",
	color = 0x7E7E7E
}) -- regular stone

blockMeta:set(0x3d1, "Ore", {
	name = "coal_ore", 
	sprite = "17dd4b26b5d.png",
	color = 0x767676
})

blockMeta:set(0x3d2, "Ore", {
	name = "iron_ore", 
	sprite = "17dd4b39b5c.png", 
	durability = 48, 
	hardness = 2, 
	particle = 2,
	
	color = 0x8D8580
})

blockMeta:set(0x3d3, "Ore", {
	name = "gold_ore", 
	sprite = "17dd4b34f5a.png", 
	durability = 48, 
	hardness = 2, 
	particle = 2,
	
	color = 0x9B9684
})

blockMeta:set(0x3d4, "Ore", {
	name = "diamond_ore", 
	sprite = "17dd4b2b75d.png", 
	durability = 56, 
	hardness = 3, 
	particle = 9,
	
	color = 0x87959B
})

blockMeta:set(0x3d5, "Ore", {
	name = "emerald_ore", 
	sprite = "17dd4b3035f.png", 
	durability = 48, 
	hardness = 3, 
	particle = 3,
	
	color = 0x79857C
})

blockMeta:set(0x3d6, "Ore", {
	name = "lazuli_ore", 
	sprite = "17e46514c5d.png", 
	durability = 48, 
	hardness = 2, 
	particle = 3,
	
	color = 0x707389
})

blockMeta:set(0x3d7, "Ore", {
	name = "redstone_ore", 
	sprite = "18149e3425f.png", 
	durability = 48, 
	hardness = 2, 
	particle = 3,
	
	color = 0x887474
})

blockMeta:set(0x4, "Stone", {
	name = "cobblestone", 
	sprite = "17dd4adf75b.png", 
	durability = 28,
	
	color = 0x808080
})

blockMeta:set(0x5, "Granular", {
	name = "sand",
	drop = 0x5,
	sprite = "17dd4b5635b.png",
	
	color = 0xDAD29E
})

blockMeta:set(0x5d1, "Stone", {
	name = "sandstone", 
	sprite = "17dd4b5af5c.png",
	drop = 0x5d1,
	
	color = 0xDDD5A5
})

blockMeta:set(0x6, {
	name = "cactus",
	drop = 0x6,
	state = {
		cascadeDestroy = true
	},
	durability = 10,
	glow = false,
	translucent = true,
	category = mc.category.other,
	sprite = "17e4651985c.png",
	
	onUpdate = function(self, block)
		self:assertCascadeDestroyAction()
	end,
	
	color = 0x4D7D3B
})

blockMeta:setConstant("bedrock", 256)
blockMeta:set(0x256, {
	name = "bedrock", 
	sprite = "17dd4adaaf0.png",
	
	color = 0x616161,
	
	durability = 0x2000, 
	hardness = 0x2000, 
	particle = 3,
	onDamage = function(self)
		self:repair(0x800, true, true, true, true)
	end
})

blockMeta:set(0x41d0, {
	name = "d_wood", 
	sprite = "19283089309.png", 
	color = 0x543221,
	
	durability = 20, 
	hardness = 0, 
	particle = 7
})

blockMeta:set(0x42d0, {
	name = "d_stone", 
	sprite = "19283105df0.png",
	
	color = 0x5C5C5D,
	
	durability = 30, 
	hardness = 0, 
	particle = 7
})

blockMeta:set(0x10, "Fluid", {
	name = "water",
	sprite = "182076fc21b.png", -- false
	color = 0x8BA8FF,
	shows = false,
	--sprite = "182076fc21b.png", 
	fluidImages = {"192398e7c9e.png", "192398febbe.png", "19239900dc4.png", "19239904431.png"}
})

blockMeta:set(0x10d1, "Fluid", {
	name = "lava", 
	sprite = "187ee766e73.png", -- false
	color = 0xD96E1F,
	shows = false,
	category = mc.category.lava,
	fluidRate = 3,
	fluidImages = {"192398e7c9e.png", "192398febbe.png", "19239900dc4.png", "19239904431.png"}
})