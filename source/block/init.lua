--- Creates a new Block object.
-- @name Block:new
-- @param Int:uniqueId The unique ID of the Block in the Map
-- @param Int:type The Block type. Data will be consulted on **blockMeta** to apply for this object
-- @param Int:MapX Horizontal position of the Block in the Map matrix
-- @param Int:MapY Vertical position of the Block in the Map matrix
-- @param Int:displayX Horizontal position of the Block in Transformice's map
-- @param Int:displayY Vertical position of the Block in Transformice's map
-- @param Int:width Width of the block in pixels
-- @param Int:height Height of the block in pixels
-- @return `Block` The Block object
do
	local setmetatable = setmetatable
	function Block:new(uniqueId, type, MapX, MapY, displayX, displayY, width, height)
		local meta = blockMeta[type] or blockMeta[0]
		
		return setmetatable({ -- Define this way to save some table acceses.
			uniqueId = uniqueId,
			chunkId = 0,
			segmentId = -1,
			
			type = type,
			category = meta.category,
			
			timestamp = 0,
			eventTimer = T_NULL,
			repairTimer = T_INF,
			
			isSolid = meta.isSolid,
			
			stateAction = meta.state,
			
			fluidRate = meta.fluidRate,
			fluidLevel = meta.fluidLevel,
			
			glow = meta.glow,
			translucent = meta.translucent,
			particle = meta.particle,
			
			drop = meta.drop,
			
			damagePhase = 0,
			damageLevel = 0,
			durability = meta.durability,
			hardness = meta.hardness,
			
			act = -meta.category,
			
			x = MapX,
			y = MapY,
			
			cx = 0, -- Chunk X
			cy = 0, -- Chunk Y
			
			dx = displayX,
			dy = displayY,
			dxc = 0,
			dyc = 0,
			
			width = width,
			height = height,
			
			sprite = meta.sprite,
			spriteId = nil,
			--[[shadow = meta.shadow,
			lighting = meta.lighting,]]
			
			dx = displayX,
			dy = displayY,
			
			hide = self.hide,
			display = self.display,
			refreshDisplay = self.refreshDisplay,
			-- setSprite = self.setSprite,
			
			onCreate = meta.onCreate,
			onDestroy = meta.onDestroy,
			onInteract = meta.onInteract,
			onDamage = meta.onDamage,
			onContact = meta.onContact,
			onUpdate = meta.onUpdate
		}, {__index = self}), 
			meta.category	-- return value 2
	end
end

do
	local void = function() end
	
	--- Sets the Block to a **void** state.
	-- @name Block:setVoid
	-- @param Boolean:update Whether it should update nearby blocks or not
	function Block:setVoid(update)
		
		self.type = VOID
		
		self.isSolid = false
		
		self.category = 0
		
		self:hide()
		
		self.drop = 0
		
		self.stateAction = {}
		self.fluidRate = 0
		self.fluidLevel = FL_EMPTY
		self.isFluidSource = false
		
		self.damageLevel = 0
		self.durability = 0
		self.hardness = 0
		
		self.particle = nil
		
		self.timestamp = 0
		self:removeEventTimer()
		self:setRepairDelay(false)
		
		self.onCreate = void
		self.onDestroy = void
		self.onInteract = void
		self.onDamage = void
		self.onContact = void
		self.onUpdate = void
		
		self.sprite = false
		
		self:getDecoTile():removeDisplay(1, true)
		
		Map.physicsMap[self.y][self.x] = 0
		
		if update then
			self:updateEvent(true, false)
		end
	end
end

--- Sets the Block relative coordinates to its chunk.
-- @name Block:setRelativeCoordinates
-- @param Int:xInChunk The horizontal position of the Block in its Chunk
-- @param Int:yInChunk The vertical position of the Block in its Chunk
-- @param Int:idInChunk The unique identifier of the Block in its Chunk 
-- @param Int:chunkX The horizontal position of the Chunk in the Map
-- @param Int:chunkY The vertical position of the Chunk in the Map
-- @param Int:chunkId The unique identifier of the Chunk in the Map
function Block:setRelativeCoordinates(xInChunk, yInChunk, idInChunk, chunkX, chunkY, chunkId)
	self.cx = xInChunk
	self.cy = yInChunk
	self.chunkUniqueId = idInChunk
	
	self.chunkX = chunkX
	self.chunkY = chunkY
	self.chunkId = chunkId
	
	self.dxc = self.dx + (self.width / 2)
	self.dyc = self.dy + (self.height / 2)
end

function Block:meta(field, type)
	self.type = type or self.type
	
	local metadata = blockMeta:get(self.type)
	if field then
		return metadata[field]
	else
		return metadata
	end
end

--- Compares with another block object.
-- @name Block:__eq
-- @param Block:other Another block
-- @return `Boolean` Whether they are equal or not
function Block:__eq(other)
	return self.uniqueId == other.uniqueId
end

-- REFERENCE FOR METHODS (also failsafe in case it is NIL for some reason)

--- Triggers when the Block is "created" to the world.
-- Declare as `onCreate = function(self)`.
-- @name Block:onCreate
function Block:onCreate()
	print("created")
end

--- Triggers when the Block is destroyed.
-- Declare as `onDestroy = function(self, player)`.
-- @name Block:onDestroy
function Block:onDestroy()
	print("destroyed")
end

--- Triggers when the Block gets interaction with a **player**.
-- Declare as `onInteract = function(self, player)`.
-- @name Block:onInteract
-- @param Player:player The player object who interacted with this block
function Block:onInteract(player)
	print(player.name)
end

--- Triggers when the Block gets damaged.
-- Declare as `onDamage = function(self, amount, player)`.
-- @name Block:onDamage
-- @param Int:amount The damage received from this block.
-- @param Player:player The player object who damaged this block
function Block:onDamage(amount, player)
	print(amount, player)
end

--- Triggers when the Block gets touched by a **player**.
-- Declare as `onContact = function(self, player)`.
-- @name Block:onContact
-- @param Player:player The player object who touched this block
function Block:onContact(player)
	print(player.name)
end

--- Triggers when the Block gets updated by the actions of another block.
-- Declare as `onUpdate = function(self, block)`.
-- @name Block:onUpdate
-- @param Block:block The block that requests this one to be updated
function Block:onUpdate(block)
	print(block.uniqueId)
end