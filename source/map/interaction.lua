do
	local ceil = math.ceil
	function Map:getBlock(x, y, ctype)
		local fx, fy -- Fixed Positions
		
		if ctype == CD_MTX then
			fx, fy = x, y
		elseif ctype == CD_MAP then
			local ox, oy = self:getEdges()
			local bx, by = self:getBlockDimensions()
			
			x = x - ox
			y = y - oy
			
			fx = ceil(x / bx)
			fy = ceil(y / by)
		end
		
		if self.blocks[fy] then			
			return self.blocks[fy][fx]
		end
	end
	
	function Map:getChunk(x, y, ctype)
		local fx, fy -- Fixed Positions
		
		if ctype == CD_MTX then
			fx = x
			fy = y
		elseif ctype  == CD_UID then
			local info = self.chunkLookup[x]
			fx = info.x
			fy = info.y
		elseif ctype == CD_MAP then
			local ox, oy = self:getEdges()
			local cx, cy = self:getChunkPixelDimensions()
			
			fx = ceil((x - ox) / cx)
			fy = ceil((y - oy) / cy)
		elseif ctype == CD_BLK then
			local cx, cy = self:getChunkDimensions()
			
			fx = ceil(x / cx)
			fy = ceil(y / cy)
		end
		
		if self.chunks[fy] then
			return self.chunks[fy][fx]
		end
	end
end

function Map:setPhysicsMode(physicsMode)
	self.physicsMode = physicsMode or self.physicsMode or "rectangle_detailed"
end

do
	local setMapGravity = tfm.exec.setMapGravity
	function Map:setForces(gravity, wind)
		self.gravityForce = gravity or 10.0
		self.windForce = wind or 0.0
		
		setMapGravity(self.windForce, self.gravityForce)
		
		return self.gravityForce, self.windForce
	end
end

function Map:setCounter(counterName, value, add)
	local counter = self.counter
	value = value or 0
	if not counter[counterName] then
		counter[counterName] = 0
	end
	
	if add then
		counter[counterName] = counter[counterName] + value
	else
		counter[counterName] = value or 0
	end
end

function Map:getSpawn()	
	local x = math.ceil(self.totalBlockWidth / 2)
	
	local block
	local target
	for y = 1, #self.blocks do
		block = self.blocks[y][x]
		
		if block.type == VOID then
			target = block
		else
			break
		end
	end
	
	target = target or block
	
	self.spawnPoint = {
		x = target.x,
		y = target.y,
		dx = target.dxc,
		dy = target.dyc
	}
	
	--[[if self.spawnPoint then
		local under = self:getBlock(self.spawnPoint.x, self.spawnPoint.y + 1, CD_MTX)
		
		if under then
			--self:spawnStructure("SpawnPoint", under.x, under.y, 0.5, 0.8)
		end
	end]]
	
	return self.spawnPoint
end
do
	local addShamanObject = tfm.exec.addShamanObject
	local removeShamanObject = tfm.exec.removeObject
	function Map:spawnShamanObject(objectType, Position, yPosition, angle, xSpeed, ySpeed, ghost, options)
		local id = addShamanObject(objectType, Position, yPosition, angle, xSpeed, ySpeed, ghost, options)
		if id then
			self.objectList[id] = true
			
			if options and options.despawn then
				Timer:new(options.despawn, false, function()
					removeShamanObject(id)
				end)
			end
		end
	end
	
	function Map:spawnStructure(structureName, x, y, xAnchor, yAnchor)
		local structure = Structures[structureName]
		local VOID = blockMeta._C_VOID
		
		xAnchor = xAnchor or 0.5
		yAnchor = yAnchor or 0.5
		
		local xStart = math.round(x - (structure.width * xAnchor))
		local yStart = math.round(y - (structure.height * yAnchor))
		
		local maxWidth, maxHeight = self:getBlocks()
		local height, width = #structure.matrix, #structure.matrix[1]
		
		local xEnd = math.restrict(xStart + (width - 1), 1, maxWidth)
		local yEnd = math.restrict(yStart + (height - 1), 1, maxHeight)
		
		local template, block
		for y = yStart, yEnd do
			for x = xStart, xEnd do 
				template = structure.matrix[(y - yStart) + 1][(x - xStart) + 1]
				block = Map:getBlock(x, y, CD_MTX)
				if not (template.type == VOID) then
					block:create(
						template.type, -- type
						true, -- display
						true, -- update
						true -- update physics
					)
				end
			end
		end
	end
end