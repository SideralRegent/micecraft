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
	function Map:restartObjectList()
		self.objectList = {
			index = 0,
			object = {},
		}
	end
	
	local def = {}
	function Map:setCandidateShamanObject(t)
		self.objectList.object = t or def
	end
	
	local addShamanObject = tfm.exec.addShamanObject
	local removeShamanObject = tfm.exec.removeObject
	function Map:spawnShamanObject(objectType, xPosition, yPosition, angle, xSpeed, ySpeed, ghost, options)
		self:setCandidateShamanObject({
			x = xPosition,
			y = yPosition,
			ghost = not not ghost,
			angle = angle,
			type = objectType
		})
		
		local id = addShamanObject(objectType, xPosition, yPosition, angle, xSpeed, ySpeed, ghost, options)
		if id then			
			if options and options.despawn then
				Timer:new(options.despawn, false, function()
					removeShamanObject(id)
				end)
			end
		end
	end
	
	function Map:despawnShamanObject(objectId)
		self.objectList[objectId] = false
		removeShamanObject(objectId)
	end
	
	local restrict = math.restrict
	function Map:setMatrix(matrix, x, y, update)
		local maxWidth, maxHeight = self:getBlocks()
		local height, width = #matrix, #matrix[1]
		
		local xEnd = restrict(x + (width - 1), 1, maxWidth)
		local yEnd = restrict(y + (height - 1), 1, maxHeight)
		
		local block, type
		for yi = y, yEnd do
			for xi = x, xEnd do 
				type = matrix[(yi - y) + 1][(xi - x) + 1]
				block = Map:getBlock(xi, yi, CD_MTX)
				if type ~= VOID then
					block:create(
						type, -- type
						true, -- display
						update, -- update
						update -- update physics
					)
				end
			end
		end
		
		return x, y, xEnd, yEnd
	end
	
	function Map:spawnStructure(structureName, x, y, xAnchor, yAnchor, update)
		local structure = Structures[structureName]
		local VOID = blockMeta._C_VOID
		local type = 0
		
		xAnchor = xAnchor or 0.5
		yAnchor = yAnchor or 0.5
		
		local xStart = math.round(x - (structure.width * xAnchor))
		local yStart = math.round(y - (structure.height * yAnchor))
		
		--local xi, yi, xf, yf = 
		self:setMatrix(structure.matrix, xStart, yStart, update)
		
		--[[if update then
			self:forChunkArea(xi, yi, xf, yf, CD_BLK, "refreshPhysics", self.physicsMode, nil, true, {
				xStart = xi,
				xEnd = xf,
				yStart = yi,
				yEnd = yf
			})
		end]]
	end
	
	local defaultChunkPos = {
		x = 1,
		y = 1
	}
	
	local min, max = math.min, math.max
	function Map:getChunkArea(xi, yi, xf, yf, cdType)
		local xLi, yLi, xLf, yLf = self:getLimits(cdType)
		
		xi = max(xLi, xi)
		yi = max(yLi, yi)
		xf = min(xLf, xf)
		yf = min(yLf, yf)
		
		if cdType == CD_MTX then
			local list = {}
			
			for y = yi, yf do
				for x = xi, xf do
					list[#list + 1] = self:getChunk(x, y, CD_MTX)
				end
			end
						
			return list
		else
			local UL = self:getChunk(xi, yi, cdType)
			local LR = self:getChunk(xf, yf, cdType)
			
			UL = UL or defaultChunkPos
			LR = LR or UL
			
			return self:getChunkArea(
				UL.x, UL.y, 
				LR.x, LR.y, 
				CD_MTX
			)
		end
	end
	
	function Map:forChunkArea(xi, yi, xf, yf, cdType, actionName, ...)
		local chunkList = self:getChunkArea(xi, yi, xf, yf, cdType)
		
		for _, chunk in next, chunkList do
			chunk[actionName](chunk, ...)
		end
	end
end