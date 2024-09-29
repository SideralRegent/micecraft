--- Creates a new Block.
-- The state of the Block is changed from what it was previously to
-- the new specified state. If the specified Block type doesn't exist,
-- it will default to an invalid block type.
-- @name Block:create
-- @param Int:type The type of the Block
-- @param Boolean:display Whether the new state should be automatically displayed
-- @param Boolean:update Whether the nearby Blocks should receive the `Block:onUpdate` event
-- @param Boolean:updatePhysics Whether the nearby physics should adjust automatically
do
	local currentTime = os.time
	function Block:create(type, display, update, updatePhysics)
		if type == blockMeta._C_VOID then
			self:setVoid()
		else
			local meta = self:meta(nil, type)
			
			self.timestamp = currentTime()
			
			self:removeEventTimer()
			self:setRepairDelay(false)
			
			do
				self.type = type
				self:setCategory(meta.category)
				
				self.drop = meta.drop
				
				self.isSolid = meta.isSolid
				
				self.stateAction = meta.state
				self.fluidRate = meta.fluidRate
				self.fluidLevel = meta.fluidLevel
				self.isFluidSource = false
				
				self.damageLevel = 0
				self.damagePhase = 0
				self.durability = meta.durability
				self.hardness = meta.hardness
				
				self.glow = meta.glow
				self.translucent = meta.translucent
				self.particle = meta.particle
				
				self.sprite = meta.sprite
				self.shadow = meta.shadow
				self.lighting  = meta.lighting
				
				self.onCreate = meta.onCreate
				self.onDestroy = meta.onDestroy
				self.onInteract = meta.onInteract
				self.onDamage = meta.onDamage
				self.onContact = meta.onContact
				self.onUpdate = meta.onUpdate
			end
			
			if display then
				self:refreshDisplay()
			end
			
			self:updateEvent(update, updatePhysics, meta.category)
			
			self:onCreate()
		end
	end
end


--- Creates a Block of fluid type.
-- It can be initialized with specific properties regarding fluids.
-- @name Block:createAsFluidWith
-- @param Int:type The type of the block
-- @param Int:level From 1 to 4, the level of the fluid
-- @param Boolean:display Whether the new state should be automatically displayed
-- @param Boolean:update Whether the nearby Blocks should receive the `Block:onUpdate` event
-- @param Boolean:updatePhysics Whether the nearby physics should adjust automatically
function Block:createAsFluidWith(type, level, source, display, update, updatePhysics)
	self:create(type, true, false, false, false)
	self:setFluidState(level, source, display, update, updatePhysics)
end

--- Destroys a Block.
-- The block will become void/air.
-- @name Block:destroy
-- @param Boolean:display Whether the new state should be automatically displayed
-- @param Boolean:update Whether the nearby Blocks should receive the `Block:onUpdate` event
-- @param Boolean:updatePhysics Whether the nearby physics should adjust automatically
do
	local time = os.time
	function Block:destroy(player, display, update, updatePhysics)
		if self.type ~= VOID then
			self.timestamp = time()
					
			self:removeEventTimer()
			local oldCat = self.category
			self.category = 0
			
			self:onDestroy(player)
			self:setVoid()

			if display then
				self:refreshDisplay()
			end
			
			self:updateEvent(update, updatePhysics, oldCat)
		end
	end
end

do
	local restrict = math.restrict
	local ceil = math.ceil
	
	local damage_sprites = {
		"17dd4b6df60.png", -- 1
		"17dd4b72b5d.png", -- 2
		"17dd4b7775d.png", -- 3
		"17dd4b7c35f.png", -- 4
		"17dd4b80f5e.png", -- 5
		"17dd4b85b5f.png", -- 6
		"17dd4b8a75e.png", -- 7
		"17dd4b8f35f.png", -- 8
		"17dd4b93f5e.png", -- 9
		"17dd4b98b5d.png" -- 10
	}
	
	--- Sets the damage level of a Block
	-- @name Block:setDamageLevel
	-- @param Int:amount The amount of damage to set to the Block. Negative numbers are admited
	-- @param Boolean:add Whether the specified amount should be added or adjusted directly
	-- @param Boolean:display Whether the new state should be automatically displayed
	-- @param Boolean:update Whether the nearby Blocks should receive the `Block:onUpdate` event (in case it's destroyed)
	-- @param Boolean:updatePhysics Whether the nearby physics should adjust automatically (in case it's destroyed)
	-- @return `Boolean` Whether the Block has the specified amount of damage
	function Block:setDamageLevel(amount, add, player, display, update, updatePhysics)
		if self.type ~= blockMeta._C_VOID then
			amount = amount or 1
			local fx = (add and self.damageLevel + amount or amount)
			
			self.damageLevel = restrict(fx, 0, self.durability)
			
			self.damagePhase = ceil((self.damageLevel * 10) / self.durability)
			
			if self.damageLevel >= self.durability then
				self:destroy(player, display, update, updatePhysics)
				
				if fx > self.durability then
					self:setDamageLevel(fx - self.durability, true, player, display, update, updatePhysics)
					self:setRepairDelay(true, 2, 10000, true, display, update, updatePhysics)
				end
				
				return false
			else
				local tile = self:getDecoTile()
				
				if self.damagePhase > 0 then
					local image = damage_sprites[self.damagePhase]
					
					tile:addDisplay("damage", 1, image, "!99999999", 0, 0, true, nil, nil, 0, 1.0)
					
					if display then
						
						tile:refreshDisplayAt(1)
					end
				else
					tile:removeDisplay(1, true)
				end
			end
			
			return true
		end
		
		return false
	end
	
	--- Sets the delay time for repairing a block.
	-- @name Block:setRepairDelay
	-- @param Boolean:set Whether the delay is being set or removed
	-- @param Int:delay How many ticks it should wait before fully repairing itself
	-- @param Any:... Arguments for `Block:repair`
	-- @return `Boolean` Whether the Block has the specified amount of damage
	function Block:setRepairDelay(set, delay, ...)
		if self.repairTimer then
			Tick:removeTask(self.repairTimer)
		end
		
		if set then
			self.repairTimer = Tick:newTask(delay, false, function(...)
				self:repair(...)
			end, ...)
		end
	end
end


--- Damages a Block.
-- This is just an interface to `Block:setDamageLevel`.
-- @name Block:damage
-- @param Int:amount The amount of damage to apply to the Block
-- @param Boolean:add Whether the specified amount should be added or adjusted directly
-- @param Boolean:display Whether the new state should be automatically displayed
-- @param Boolean:update Whether the nearby Blocks should receive the `Block:onUpdate` event (in case it's destroyed)
-- @param Boolean:updatePhysics Whether the nearby physics should adjust automatically (in case it's destroyed)
-- @return `Boolean` Whether the Block has the specified amount of damage
function Block:damage(amount, add, display, update, updatePhysics, player)
	if self.type ~= VOID then		
		local success = self:setDamageLevel(amount, add, player, display, update, updatePhysics)
	
		if success then
			self:onDamage(amount, player)
			
			-- self:setRepairDelay(true, 2, 10000, add, display, update, updatePhysics)
		end
	
		return success
	end
	
	return false
end

--- Repairs a Block previously damaged.
-- This is just an interface to `Block:setDamageLevel`.
-- @name Block:repair
-- @param Int:amount The amount of damage to remove from the Block
-- @param Boolean:add Whether the specified amount should be removed or adjusted directly
-- @param Boolean:display Whether the new state should be automatically displayed
-- @param Boolean:update Whether the nearby Blocks should receive the `Block:onUpdate` event (in case its state changes)
-- @param Boolean:updatePhysics Whether the nearby physics should adjust automatically (in case its state changes)
-- @return `Boolean` Whether the Block has the specified amount of damage
function Block:repair(amount, add, player, display, update, updatePhysics)
	if self.type ~= VOID then
		return self:setDamageLevel(-amount, add, player, display, update, updatePhysics)
	end
	
	return false
end

do
	--- Interacts with a Block.
	-- Triggers the method `Block:onInteract` for the provided player.
	-- @name Block:interact
	-- @param Player:player The Player that interacts with this block
	-- @return `Boolean` Whether the interaction was successful or not
	local dist = math.udist
	function Block:interact(player)
		if self.interactable then
			local x, y = self:getPixelCenter()
			local width, height = Map:getBlockDimensions()
			
			local xd = dist(player.x, x)
			local yd = dist(player.y, y)
			
			local xr = (self.interactable * width)
			local yr = (self.interactable * height)
			
			if xd <= xr and yd <= yr then
				return self:onInteract(player)
			end
		end
		
		return nil
	end
end

function Block:removeEventTimer()
	if self.eventTimer ~= T_NULL then
		Tick:removeTask(self.eventTimer)
	end
	
	self.eventTimer = T_NULL
end

function Block:setTask(delay, shouldLoop, callback, ...)
	self:removeEventTimer()
	
	self.eventTimer = Tick:newTask(delay, shouldLoop, callback, ...)
	
	return self.eventTimer
end

function Block:setCategory(category)
	self.category = category
	Map.physicsMap[self.y][self.x] = category
end

function Block:setFluidState(level, isSource, display, update, updatePhysics)
	local meta = blockMeta:get(self.type)
	if self.fluidRate > 0 then
		self.fluidLevel = level or 0
		self.isFluidSource = isSource
		self:setCategory(meta.category + self.fluidLevel)
	end
	
	if display and self.sprite then
		self.sprite = meta.fluidImages and meta.fluidImages[self.fluidLevel] or meta.sprite
		
		self:refreshDisplay()
	end

	self:updateEvent(update, updatePhysics, meta.category)
end