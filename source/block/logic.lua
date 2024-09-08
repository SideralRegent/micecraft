--- Retrieves the Chunk object from which the Block belongs to
-- @name Block:getChunk
-- @return `Chunk` The chunk object
function Block:getChunk()
	return Map:getChunk(self.chunkX, self.chunkY, CD_MTX)
end

function Block:requestPhysicsUpdate(segmentList)
	self:getChunk():refreshPhysics(Map.physicsMode, segmentList, true, {
		xStart = self.x, 
		xEnd = self.x, 
		yStart = self.y, 
		yEnd = self.y, 
		category = self.category
	})
end

do
--- Retrieves a list with the blocks adjacent to the Block.
-- @name Block:getBlocksAround
-- @param String:shape The shape to retrieve the blocks {cross: only adjacents, square: adjacents + edges}
-- @param Boolean:include Whether the Block itself should be included in the list.
-- @return `Table` An array with the adjacent blocks (in no particular order)
	local ti = function(t, v) -- Stands for [t]able [i]nsert
		t[#t + 1] = v
	end
	function Block:getBlocksAround(shape, include)
		local x, y = self.x, self.y
		local map = Map
		local blocks = {}
		if include then ti(blocks, self) end
		
		if shape == SH_CRS then
			local x = self.x
			ti(blocks, map:getBlock(x - 1, 	y, 		CD_MTX))
			ti(blocks, map:getBlock(x, 		y - 1, 	CD_MTX))
			ti(blocks, map:getBlock(x + 1, 	y, 		CD_MTX))
			ti(blocks, map:getBlock(x, 		y + 1, 	CD_MTX))
		elseif shape == SH_CRN then
			ti(blocks, map:getBlock(x - 1, y - 1, CD_MTX))
			ti(blocks, map:getBlock(x + 1, y - 1, CD_MTX))
			ti(blocks, map:getBlock(x - 1, y + 1, CD_MTX))
			ti(blocks, map:getBlock(x + 1, y + 1, CD_MTX))
		elseif shape == SH_SQR then
			for sy = -1, 1 do
				for sx = -1, 1 do
					if not (sx == 0 and sy == 0) then
						ti(blocks, map:getBlock(x + sx, y + sy, CD_MTX))
					end
				end
			end
		elseif shape == SH_UND then
			local sy = y + 1
			
			ti(blocks, map:getBlock(x, sy, CD_MTX))
			ti(blocks, map:getBlock(x - 1, sy, CD_MTX))
			ti(blocks, map:getBlock(x + 1, sy, CD_MTX))
		elseif shape == SH_LNR then
			ti(blocks, map:getBlock(x - 1, y, CD_MTX))
			ti(blocks, map:getBlock(x + 1, y, CD_MTX))
		end
		
		return blocks
	end
end

function Block:requestNeighborUpdate(inquireShape)
	local segmentList = {}
	local blocks = self:getBlocksAround(inquireShape, false)
	
	for _, block in next, blocks do
		if block.chunkId == self.chunkId then
			segmentList[block.segmentId] = true
		end
		
		block:onUpdate(self)
		-- block:pulse()
	end
	
	return segmentList
end

--- Interface for handling when a block state gets updated.
-- @name Block:updateEvent
-- @param Boolean:update Whether the blocks around should be updated (method: `Block:onUpdate`)
-- @param Boolean:updatePhysics Whether the physics of the Map should be updated
function Block:updateEvent(update, updatePhysics, lookupCategory)
	do
		local blocks = self:getBlocksAround(SH_CRS, false)
		local segmentList = {}
		if update ~= false then
			segmentList = self:requestNeighborUpdate(SH_CRS)
			
			self:assertStateActions()
		end
		
		segmentList[self.segmentId] = true
		
		if updatePhysics ~= false then
			local xBlocks = self:getBlocksAround(SH_CRN, false)
			for _, block in next, xBlocks do
				if block.chunkId == self.chunkId then
					if not (lookupCategory and block.category ~= lookupCategory) then
						segmentList[block.segmentId] = true
					end
				end
			end
			
			self:requestPhysicsUpdate(segmentList)
		end
	end
end

function Block:assertStateActions()
	local fall = self:assertFallAction()
	local cascade = self:assertCascadeDestroyAction()
	local flow = self:flowAction()
	
	return (fall or cascade or flow)
end

function Block:assertCascadeDestroyAction()
	if self.stateAction.cascadeDestroy then
		local lowerBlock = Map:getBlock(self.x, self.y + 1, CD_MTX)
		
		if lowerBlock then
			if lowerBlock.type == VOID then
				self:cascadeAction()
			end
		end
		
		return true
	end
	
	return false
end

function Block:cascadeAction() -- TODO: Test
	local type = self.type
	
	local y = self.y
	local block
	
	local segmentList = {}
	
	while y > 0 do
		block = Map:getBlock(self.x, y, CD_MTX)
			
		if block.type == type and not block:hasActiveTask() then
			block:pulse()
			
			block:destroy(true, false, false)
			block:requestNeighborUpdate(SH_LNR)
			segmentList[block.segmentId] = true
		else
			break
		end
		
		y = y - 1
	end
	
	
	self:getChunk():refreshPhysics(Map.physicsMode, segmentList, true, {
		xStart = self.x, 
		xEnd = self.x, 
		yStart = self.y, 
		yEnd = self.y, 
		category = self.category
	})


	if updatePhysics ~= false then
			local xBlocks = self:getBlocksAround(SH_CRN, false)
			for _, block in next, xBlocks do
				if block.chunkId == self.chunkId then
					if not (lookupCategory and block.category ~= lookupCategory) then
						print(block.category)
						segmentList[block.segmentId] = true
					end
				end
			end
			
			
	
	block:onUpdate()
end

function Block:assertFallAction()
	if self.stateAction.fallable then
		local lowerBlock = Map:getBlock(self.x, self.y + 1, CD_MTX)
		
		if lowerBlock then
			if (lowerBlock.type == VOID) or (lowerBlock.fluidRate > 0) then
				self:fallAction(lowerBlock)
			end
		end
		
		return true
	end
	
	return false
end

function Block:fallAction(lowerBlock)
	if not lowerBlock then return end
	if self:hasActiveTask(-1) then return end

	local type = self.type
	
	local y = self.y - 1
	local x = self.x
	local objective = self
	local block
	
	while y > 0 do
		block = Map:getBlock(x, y, CD_MTX)
		if block.type == type then -- Objective is the block that should get deleted
			objective = block 
			
			y = y - 1
		else
			break
		end
	end	
	
	lowerBlock:setTask(1, false, function()
		objective:destroy(true, true, true)
		-- objective:setVoid(true)
		
		lowerBlock:create(type, true, true, true)
		
		--lowerBlock:updateEvent(true, true) 
	end)
end

function Block:scheduleFluidCreation(delay, type, flowLevel, asSource, display, update, updatePhysics)
	return self:setTask(delay, false, function()
		self:createAsFluidWith(type, flowLevel, asSource, display, update, updatePhysics)	
	end)
end

-- TODO: Add condition for non-source
function Block:flowVerticalAction()
	local lowerBlock = Map:getBlock(self.x, self.y + 1, CD_MTX)
	if not lowerBlock then return false end
	
	local mustFlow = false
	
	if lowerBlock.type == blockMetadata._C_VOID then
		mustFlow = true
	elseif lowerBlock.fluidRate > 0 then
		if lowerBlock.type == self.type then
			-- Only if the fluid below is the same type AND not filled.
			mustFlow = (lowerBlock.fluidLevel < FL_FILL)
		else
			-- Implement behaviour when combining two different fluids.
		end
	end
	
	if mustFlow then
		lowerBlock:scheduleFluidCreation(self.fluidRate, self.type, FL_FILL, false, true, true, true)
	end
	
	return mustFlow or (lowerBlock.type == self.type) -- so it doesn't spill to the sides
end

do
	function Block:checkSidesFluidHeight(sides) -- Assumes that [self] is already a fluid
		sides = sides or self:getBlocksAround(SH_LNR, false)
		local count = 0
		
		local maxLevel, maxIndex = FL_EMPTY, 1
		local minLevel, minIndex = FL_FILL, 1
		
		for index, block in next, sides do
			if block.type == self.type and block.fluidLevel > self.fluidLevel then
				count = count + 1
								
				if block.fluidLevel > maxLevel then
					maxLevel = block.fluidLevel
					maxIndex = index
				elseif block.fluidLevel < minLevel then
					minIndex = index
					minLevel = block.fluidLevel
				end
			end
		end
		
		return count, maxIndex, minIndex
	end
end

function Block:hFlowCheckTo(block, nextLevel)
	local flowLevel = FL_EMPTY
	
	if block.type == blockMetadata._C_VOID then
		flowLevel = nextLevel
	elseif block.type == self.type then
		if block.fluidLevel < (nextLevel - 1) then
			flowLevel = nextLevel
		elseif block.fluidLevel > nextLevel then
			-- Do nothing
		end
	elseif block.fluidRate ~= 0 then
		-- Implement behaviour when colliding with other fluid
	end
	
	return flowLevel
end

function Block:hFlowContinous(sides, nextLevel)
	local flowLevel = FL_EMPTY
	
	for _, block in next, sides do
		flowLevel = self:hFlowCheckTo(block, nextLevel)
		
		if flowLevel > 0 then
			block:scheduleFluidCreation(self.fluidRate, self.type, flowLevel, false, true, true, true)
		end
	end	
end

function Block:hFlowIsolate(sides, maxIndex, minIndex, nextLevel)
	local flowLevel = FL_EMPTY

	local blockAbove = Map:getBlock(self.x, self.y - 1, CD_MTX)
	
	if (blockAbove and (blockAbove.type == self.type)) or self.isFluidSource then -- spills to both sides
		for _, block in next, sides do
			flowLevel = self:hFlowCheckTo(block, nextLevel)
			
			if flowLevel > 0 then
				if not block:hasActiveTask() then 
					block:scheduleFluidCreation(self.fluidRate, self.type, flowLevel, false, true, true, true)
				end
			end
		end
	else -- not spilling to both sides
		local candidate = sides[1]
		
		if #sides ~= 1 then --
			if sides[maxIndex].fluidLevel == sides[minIndex].fluidLevel then
				candidate = table.random(sides)
			else
				candidate = sides[minIndex]
			end
		end
		
		flowLevel = self:hFlowCheckTo(candidate, nextLevel)
		
		if flowLevel > 0 then
			candidate:scheduleFluidCreation(self.fluidRate, self.type, flowLevel, false, true, true, true)
			self:setTask(self.fluidRate, false, function() -- drains 1 level from current one
				self:setFluidState(self.fluidLevel - 1, false, true, true, true)
			end)
		end
	end
end

function Block:flowHorizontalAction()
	if self.fluidLevel <= 1 then
		return false
	end
	
	local nextLevel = self.fluidLevel - 1
	
	local sides = self:getBlocksAround(SH_LNR, false)
	local higherLevel, maxIndex, minIndex = self:checkSidesFluidHeight(sides)
	

	if higherLevel == 2 then
		local newLevel = self.fluidLevel + 1
		local asSource = (newLevel == FL_FILL)
		self:setTask(1, false, function()
			self:setFluidState(newLevel, asSource, true, true, true)
		end)
	elseif higherLevel == 1 or self.isFluidSource then
		self:hFlowContinous(sides, nextLevel)
	else -- Not a fluid source, nor it has a higher level of fluid around
		self:hFlowIsolate(sides, maxIndex, minIndex, nextLevel)
	end
end

function Block:flowAction()
	if self.fluidRate > 0 then
		-- We only want a fluid to expand downwards, and
		-- to the sides if the block downwards is solid.
		if not self:flowVerticalAction() then
			return self:flowHorizontalAction()
		end
		
		return true
	end
	
	return false
end

-- Could implement 'pushAction' in the future (for pistons)