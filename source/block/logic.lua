--- Retrieves the Chunk object from which the Block belongs to
-- @name Block:getChunk
-- @return `Chunk` The chunk object
function Block:getChunk()
	return Map:getChunk(self.chunkX, self.chunkY, CD_MTX)
end

do
--- Retrieves a list with the blocks adjacent to the Block.
-- @name Block:getBlocksAround
-- @param String:shape The shape to retrieve the blocks {cross: only adjacents, square: adjacents + edges}
-- @param Boolean:include Whether the Block itself should be included in the list.
-- @return `Table` An array with the adjacent blocks (in no particular order)
	local ti = function(t, v) -- Stands for [t]able [i]nclude
		t[#t + 1] = v
	end
	function Block:getBlocksAround(shape, include)
		local map = Map
		local blocks = {}
		if include then ti(blocks, self) end
		
		if shape == SH_CRS then
			ti(blocks, Map:getBlock(self.x - 1, self.y, CD_MTX))
			ti(blocks, Map:getBlock(self.x, self.y - 1, CD_MTX))
			ti(blocks, Map:getBlock(self.x + 1, self.y, CD_MTX))
			ti(blocks, Map:getBlock(self.x, self.y + 1, CD_MTX))
		elseif shape == SH_CRN then
			ti(blocks, Map:getBlock(self.x-1, self.y-1, CD_MTX))
			ti(blocks, Map:getBlock(self.x+1, self.y-1, CD_MTX))
			ti(blocks, Map:getBlock(self.x-1, self.y+1, CD_MTX))
			ti(blocks, Map:getBlock(self.x+1, self.y+1, CD_MTX))
		elseif shape == SH_SQR then
			for y = -1, 1 do
				for x = -1, 1 do
					if not (x == 0 and y == 0) then
						ti(blocks, Map:getBlock(self.x + x, self.y + y, CD_MTX))
					end
				end
			end
		elseif shape == SH_UND then
			local y = self.y + 1
			local x = self.x
			
			ti(blocks, Map:getBlock(x, y, CD_MTX))
			ti(blocks, Map:getBlock(x - 1, y, CD_MTX))
			ti(blocks, Map:getBlock(x + 1, y, CD_MTX))
		elseif shape == SH_LNR then
			ti(blocks, Map:getBlock(self.x - 1, self.y, CD_MTX))
			ti(blocks, Map:getBlock(self.x + 1, self.y, CD_MTX))
		end
		
		return blocks
	end
end


--- Interface for handling when a block state gets updated.
-- @name Block:updateEvent
-- @param Boolean:update Whether the blocks around should be updated (method: `Block:onUpdate`)
-- @param Boolean:updatePhysics Whether the physics of the Map should be updated
function Block:updateEvent(update, updatePhysics)
	do
		local blocks = self:getBlocksAround(SH_CRS, false)
		local segmentList = {
			[self.segmentId] = true
		}
		if update ~= false then
			for position, block in next, blocks do
				if block.chunkId == self.chunkId then
					segmentList[block.segmentId] = true
				end
				block:onUpdate(self)
			end
			
			self:assertStateActions()
		end
		
		if updatePhysics ~= false then
			local xBlocks = self:getBlocksAround(SH_CRN, false)
			for position, block in next, xBlocks do
				if block.chunkId == self.chunkId then
					segmentList[block.segmentId] = true
				end
			end
			
			self:getChunk():refreshPhysics(Map.physicsMode, segmentList, true, {
					xStart = self.x, 
					xEnd = self.x, 
					yStart = self.y, 
					yEnd = self.y, 
					category = self.category
				}
			)
		end
	end
end

function Block:assertStateActions()
	return self:assertFallAction()
		or self:assertCascadeDestroyAction()
		or self:flowAction()
end

function Block:assertCascadeDestroyAction()
	if self.stateAction.cascadeDestroy then
		local lowerBlock = Map:getBlock(self.x, self.y + 1, CD_MTX)
		
		if lowerBlock then
			if lowerBlock.type == blockMetadata._C_VOID or (self.foreground and not lowerBlock.foreground) then
				self:cascadeAction()
			end
		end
		
		return true
	end
	
	return false
end

function Block:cascadeAction()
	local tangible = self.foreground
	local type = self.type
	
	local y = self.y
	local block
	while y > 0 do
		block = Map:getBlock(self.x, y, CD_MTX)
			
		if block.type == type then
			block:setTask(1 + (self.y - y), false, function(xPoint, yPoint)
				-- Can't pass 'block' because, for some reason, it will only send the last block checked
				-- So I have to grab the block in the anonymous call instead
				-- Can't pass 'block' into the arguments because the referece is lost and modifying it makes a new table.
				-- Lua issue or Java implementation issue?
				local target = Map:getBlock(xPoint, yPoint, CD_MTX)
				target:destroy(true, true, true, true)
			end, self.x, y)
		else
			break
		end
		
		y = y - 1
	end
end

function Block:assertFallAction()
	if self.stateAction.fallable then
		local lowerBlock = Map:getBlock(self.x, self.y + 1, CD_MTX)
		
		if lowerBlock then
			if lowerBlock.type == blockMetadata._C_VOID or lowerBlock.translucent or lowerBlock.fluidRate then
				self:fallAction(lowerBlock)
			end
		end
		
		return true
	end
	
	return false
end

function Block:fallAction(lowerBlock)
	local tangible = self.foreground
	local type = self.type
	
	local y = self.y - 1
	local objective = self
	local block
	
	while y > 0 do
		block = Map:getBlock(self.x, y, CD_MTX)
		if block.type == type and block.tangible == tangible then
			objective = block 
		else
			break
		end
		
		y = y - 1
	end
	
	self:setTask(1, false, function()
		objective:destroy(true, true, true)
		objective:setVoid(true)
		
		lowerBlock:create(type, tangible, true, true, true)
	end)
end

function Block:scheduleFluidCreation(delay, type, flowLevel, asSource, display, update, updatePhysics)
	self:setTask(delay, false, function()
		self:createAsFluidWith(type, flowLevel, asSource, display, update, updatePhysics)	
	end)
end

function Block:flowVerticalAction()
	local lowerBlock = Map:getBlock(self.x, self.y + 1, CD_MTX)
	local mustFlow = false
	
	if lowerBlock.type == blockMetadata._C_VOID then
		mustFlow = true
	elseif lowerBlock.fluidRate then
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
local max = math.max
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
	elseif block.fluidRate then
		-- Implement behaviour when colliding with other fluid
	end
	
	return flowLevel
end

function Block:hFlowContinous(sides, nextLevel)	
	local flowLevel = FL_EMPTY
	
	for index, block in next, sides do
		flowLevel = self:hFlowCheckTo(block, nextLevel)
		
		if flowLevel > 0 then
			block:scheduleFluidCreation(self.fluidRate, self.type, flowLevel, false, true, true, true)
		end
	end	
end

function Block:hFlowIsolate(sides, maxIndex, minIndex, nextLevel)
	local candidate = sides[1]
	local flowLevel = FL_EMPTY

	if #sides ~= 1 then
		if sides[maxIndex].fluidLevel == sides[minIndex].fluidLevel then
			candidate = table.random(sides)
		else
			candidate = sides[minIndex]
		end
	end
	
	flowLevel = self:hFlowCheckTo(candidate, nextLevel)
	
	if flowLevel > 0 then
		candidate:scheduleFluidCreation(self.fluidRate, self.type, flowLevel, false, true, true, true)
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
	if self.fluidRate then
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