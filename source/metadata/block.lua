do
	local void = function() end
	blockMetadata = MetaData:newMetaData({
		name = "null", -- Block Name, used for translations
		
		drop = "0", -- When broken, identifier of what it drops
		
		state = {
			fallable = false,
			cascadeDestroy = false
		},
		
		fluidRate = 0, -- How many ticks it takes to "flow"
		fluidLevel = FL_EMPTY, -- The level of the fluid [n/4 of a block vertically]
		
		glow = 0, -- Light emission (none = 0; max: 15)
		translucent = false, -- If it is translucent (has different alpha values) [blocks with non-quadratic/irregular shapes have this property too]
		
		shadow = "17e2d5113f3.png", -- Sprite for shawdow [black]
		lightning = "1817dc55c70.png", -- Sprite for lightning [white]
		sprite = "17e1315385d.png", -- Regular sprite
		
		durability = 24, -- How durable is this block against hits
		
		hardness = 1, -- How complex is the structure of the block. The more complex, higher order tools will be needed to break it
		category = 1, -- The physics category the block belongs to. Different restitution and friction will be applied according to the category
		placeable = true, -- If an entity should be able to place this block
		
		particles = {}, -- Particles that this block should emit when destroyed
		interactable = false, -- if it's possible to interact with this block (relevant for method onInteract), BOOLEAN (false) or NUMBER (TRUE), number denotes distance. Use block distance
		
		color = 0xFFFFFF, -- Misc
		restricted = false, -- If players shouldn't be able to hold this block
		fixedId = 0, -- Misc
		
		onCreate = void, -- Triggers when this block is created in the Map 
		onPlacement = void, -- Triggers when this block is placed by an entity
		onDestroy = void, -- Triggers when this block is destroyed
		-- Note: Generally, onCreate and onPlacement might act as the same, however,
		-- onCreate is always triggered first, and onPlacement is triggered after the
		-- actual creation. onPlacement will only be triggered by ENTITIES.
		-- Note 2: onCreate will not trigger when a block tile is created (block:new)
		
		onInteract = void, -- Triggers when an entity tries to interact with this block
		
		onHit = void, -- Triggers when a block has been hit
		onDamage = void, -- Triggers when a block has been damaged
		-- Note: While both methods could act as the same almost all times, onHit
		-- will always trigger when an entity cause it and before the actual damage
		-- happens, while onDamage will trigger after the damage is applied, however,
		-- if the block is destroyed because of a Hit, then onDamage will not trigger.
		-- onHit only triggers with entities, onDamage does always.
		
		onContact = void, -- Triggers when a Player makes contact with the Block (only works on foreground layer)
		
		onUpdate = void -- Triggers when a Block nearby has suffered an update of its properties
	})
end

blockMetadata:newTemplate("Dirt", {
	name = "dirt",
	
	category = enum.category.grains,
	drop = "1",
	durability = 14,
	hardness = 0,
	
	sprite = "17dd4af277b.png",
	
	translucent = false,
	
	interactable = false,
	color = 0x866042,
	onUpdate = function(self, block) -- Make grass
		if self.x == block.x and block.y < self.y then -- If the block is right above us
			if block.type ~= blockMetadata._C_VOID then -- If it isn't air
				if not (self.foreground and not block.foreground) then -- If its layer isn't lower than ours
					if not block.translucent then -- If it isn't translucent
						return false -- Do nothing
					end
				end
			end
			
			local grassifyTime = math.random(6, 16)
			self:setTask(grassifyTime, false, function()
				self:create(blockMetadata.maps.grass, self.foreground, true, true, false) -- Create a grass block
			end)
	
			return true
		end
		
		return false
	end
})

blockMetadata:newTemplate("Grass", "Dirt", {
	name = "grass",
	
	sprite = "17dd4b0a359.png",
	
	drop = "1",
	durability = 18,
	
	color = 0x44AA44,
	
	onUpdate = function(self, block) -- Make it dirt
		if block.x == self.x and block.y < self.y then -- If the block that updated is above this one
			if block.type ~= 0 then -- If it isn't air
				if not (self.foreground and not block.foreground) then -- If the block layer isn't lower than ours
					if not block.translucent then -- If the block isn't translucent
						local dirtifyTime = math.random(6, 16)
						self:setTask(dirtifyTime, false, function()
							self:create(blockMetadata.maps.dirt, self.foreground, true, true, false) -- Create a dirt block
						end)
					
						return true
					end
				end
			end
		end
		
		return false
	end
})

blockMetadata:newTemplate("Fluid", {
	name = "x_flow",
	
	category = enum.category.water,
	drop = "0",
	
	glow = 0,
	
	translucent = true,
	sprite = "182076fc21b.png",
	
	fluidRate = 1,
	fluidLevel = FL_FILL,
	
	durability = math.huge,
	hardness = 9e99,
	
	placeable = true,
	color = 0x0000FF,
	particles = {7},
	
	onUpdate = function(self, block)
		self:assertStateActions()
	end
})

blockMetadata:newTemplate("Granular", {
	name = "granular",
	
	category = enum.category.grains,
	drop = "0",
	
	glow = 0,
	translucent = false,
	sprite = "17dd4b5635b.png",
	
	state = {
		fallable = true,
	},
	
	durability = 18,
	hardness = 0,
	
	placeable = true,
	interactable = false,
	
	color = 0xFFAA00,
	particles = {24},
	
	onContact = function(self, player)
		self:assertStateActions()
	end,
	
	onUpdate = function(self, block)
		self:assertStateActions()
	end
})

blockMetadata:newTemplate("Stone", {
	name = "stone",
	
	category = enum.category.rocks_n_metals,
	drop = 0, -- To define
	
	glow = 0,
	translucent = false,
	sprite = "17dd4b6935c.png",
	
	durability = 34,
	hardness = 1,
	
	placeable = true,
	interactable = false,
	color = 0xA0A0A0,
	particles = {4}
})

blockMetadata:newTemplate("Ore", "Stone", {
	name = "default_ore",
	sprite = "17dd4b39b5c.png",
	durability = 42,
	particles = {3, 4},
	glow = 0,
	onHit = function(self, entity)
		-- Emit particles
	end
})

blockMetadata:setConstant("void", "0")

blockMetadata:set("0", "Void", {
	name = "void", 
	category = 0
})

blockMetadata:set("1", "Dirt", {
	name = "dirt"
}) -- dirt

blockMetadata:set("1:1", "Dirt", {
	name = "dirtcelium", 
	sprite = "17dd4ae8f5b.png"
}) -- dirtcelium


blockMetadata:set("2", "Grass", {
	name = "grass"
}) -- grass

blockMetadata:set("2:1", "Grass", {
	name = "mycelium", 
	sprite = "17dd4b1875c.png"
}) -- mycelium

blockMetadata:set("2:2", "Grass", {
	name = "snowed_grass", 
	sprite = "17dd4aedb5d.png"
}) -- snowed grass

blockMetadata:set("3", "Stone", {
	name = "stone"
}) -- regular stone

blockMetadata:set("3:1", "Ore", {
	name = "coal_ore", 
	sprite = "17dd4b26b5d.png"
})

blockMetadata:set("3:2", "Ore", {
	name = "iron_ore", 
	sprite = "17dd4b39b5c.png", 
	durability = 48, 
	hardness = 2, 
	particles = {3,2,1}
})

blockMetadata:set("3:3", "Ore", {
	name = "gold_ore", 
	sprite = "17dd4b34f5a.png", 
	durability = 48, 
	hardness = 2, 
	particles = {2,3,11,24}
})

blockMetadata:set("3:4", "Ore", {
	name = "diamond_ore", 
	sprite = "17dd4b2b75d.png", 
	durability = 56, 
	hardness = 3, 
	particles = {3, 1, 9, 23}
})

blockMetadata:set("3:5", "Ore", {
	name = "emerald_ore", 
	sprite = "17dd4b3035f.png", 
	durability = 48, 
	hardness = 3, 
	particles = {3,11,22}
})

blockMetadata:set("3:6", "Ore", {
	name = "lazuli_ore", 
	sprite = "17e46514c5d.png", 
	durability = 48, 
	hardness = 2, 
	particles = {3, 1, 9, 23}
})

blockMetadata:set("3:7", "Ore", {
	name = "redstone_ore", 
	sprite = "18149e3425f.png", 
	durability = 48, 
	hardness = 2, 
	particles = {3, 1, 9, 23}
})

blockMetadata:set("4", "Stone", {
	name = "cobblestone", 
	sprite = "17dd4adf75b.png", 
	durability = 28
})

blockMetadata:set("5", "Granular", {
	name = "sand",
	drop = "5",
	sprite = "17dd4b5635b.png"
})
blockMetadata:set("5:1", "Stone", {
	name = "sandstone", 
	sprite = "17dd4b5af5c.png",
	drop = "5:1"
})

blockMetadata:set("6", {
	name = "cactus",
	drop = "6",
	state = {
		cascadeDestroy = true
	},
	durability = 10,
	glow = false,
	category = enum.category.other,
	placeable = true,
	sprite = "17e4651985c.png"
})

blockMetadata:setConstant("bedrock", "256")
blockMetadata:set("256", {
	name = "bedrock", 
	sprite = "17dd4adaaf0.png", 
	durability = 0x141D6A4, 
	hardness = 0x141D6A4, 
	particles = {3},
	onDamage = function(self)
		self:repair(0x141D6A4, true, true, true, true)
	end
})

blockMetadata:set("10", "Fluid", {name = "water", sprite = "182076fc21b.png", fluidImages = {"17dd4b26b5d.png", "17dd4b39b5c.png", "17dd4b34f5a.png", "17dd4b2b75d.png"}})
blockMetadata:set("10:1", "Fluid", {
	name = "lava", 
	sprite = "187ee766e73.png",
	category = enum.category.lava,
	fluidRate = 2
})