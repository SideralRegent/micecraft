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
	function Player:updateInformation(x, y, vx, vy, facingRight)
		local info = tfm.get.room.playerList[self.name] or {}
		local k = self.keys
		
		self:updatePosition(
			x or info.x,
			y or info.y,
			vx or info.vx,
			vy or info.vy
		)
		
		self.isJumping = info.isJumping
		
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
	
	function Player:updateChunkArea()
		local chunk = Map:getChunk(self.bx, self.by, CD_BLK)
		
		if chunk then
			if chunk.uniqueId ~= self.currentChunk then
				self.lastChunk = chunk.uniqueId
			end
			
			if chunk.collidesTo[self.name] then
				if self.isFrozen then
					self:freeze(false, true)
				end
			else
				if not self.isFrozen then
					self:freeze(true, false, 0, 0)
				end
			end
			
			self:queueNearChunks(chunk, true)
			
			self.currentChunk = chunk.uniqueId
		end
	end
	
	function Player:setClock(time, add, runEvents)
		if add then
			time = time or 500
			self.internalTime = self.internalTime + time
		else
			self.internalTime = time
		end

		if runEvents then
			-- if self.internalTime % 1000 == 0 then
				if self.internalTime % 2500 == 0 then -- Every 2.5 seconds
					self:updateChunkArea()
				end
			-- end
		end
	end
end