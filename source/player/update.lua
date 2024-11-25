function Player:updatePosition(x, y, vx, vy)
	local map = Map
	
	self.x = x or self.x
	self.y = y or self.y
	
	self.vx = vx or self.vx
	self.vy = vy or self.vy
	
	self.bx = (self.x - map.horizontalOffset) / map.blockWidth
	self.by = (self.y - map.verticalOffset) / map.blockHeight
end

do
	function Player:tfmUpdateInformation()
		local info = tfm.get.room.playerList[self.name] or {}
		self:updatePosition(info.x, info.y, info.vx, info.vy)
		self:updateDirection(nil, info.isJumping)
	end
	
	function Player:updateInformation(x, y, vx, vy, facingRight)
		local info = tfm.get.room.playerList[self.name] or {}
		local k = self.keys
		
		self:updatePosition(
			x or info.x,
			y or info.y,
			vx or info.vx,
			vy or info.vy
		)
		
		--self.isJumping = info.isJumping
		
		self:updateDirection(facingRight, k[0] or k[2] or info.isJumping)
	end
	
	function Player:updateDirection(facingRight, moving)
		local facingUpdated, movingUpdated
		if facingRight ~= nil then
			self.isFacingRight = facingRight
			facingUpdated = true
		end
		
		if moving ~= nil then
			self.isMoving = moving
			movingUpdated = true
		end
		
		if facingUpdated or movingUpdated then
			-- self:adjustItemHeld()
		end
	end
	
	function Player:checkForCurrentChunk(chunk)
		chunk = chunk or Map:getChunk(self.bx, self.by, CD_BLK)
		if not chunk then return end
		
		if chunk.uniqueId ~= self.currentChunk then
			self.lastChunk = self.currentChunk
		end
		
		self.currentChunk = chunk.uniqueId
			
		if chunk.collidesTo[self.presenceId] then
			if self.isFrozen then
				self:freeze(false, true)
			end
		else
			if not self.isFrozen then
				self:freeze(true, false, 0, 0)
			end
		end
		
		return chunk
	end
	
	function Player:updateChunkArea()
		local chunk = self:checkForCurrentChunk()
		
		if chunk then
			self:queueNearChunks(chunk, false)
		end
	end
	
	function Player:setClock(time, add, runEvents)
		if add then
			time = time or 1
			self.internalTime = self.internalTime + time
		else
			self.internalTime = time
		end		if runEvents then
			self:runEvents()
		end
	end
	
	-- Tables do not reference correctly on Tick:newTask, so I can't pass
	--	player directly and I won't duplicate Tick class just for this
	
	-- How bad could this become?
	function Player:runEvents()
		local internalTime = self.internalTime 
		if internalTime % 8 == 0 then -- Every 4 seconds
			self:updateChunkArea()
			
			if internalTime % 40 == 0 then -- Every 20 seconds
				if internalTime % 120 == 0 then -- Every 1 min
					self:saveData(true)
				else
					self:writeData()
				end
			end
		end
		
		self:checkForCurrentChunk()
	end
end