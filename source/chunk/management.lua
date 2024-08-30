do
	local unloadingTime = 120
	local copykeys = table.copykeys
	local isEmpty = table.isEmpty
	--- Sets the Time that the Chunk should wait before unloading.
-- There are three options to pick: physics, graphics, items.
-- Note: Items unload removes them permanently.
-- @name Chunk:setUnloadDelay
-- @param Int:ticks How many ticks should the Chunk await
-- @param String:type The type of unload
-- @return `Boolean` Whether the unload scheduling was successful or not.
	function Chunk:setUnloadDelay(ticks, type)
		if type == "physics" then
			Tick:removeTask(self.collisionTimer)
			self.collisionTimer = self:setQueue(ticks, "setPhysicState", false, nil)
		
			return (not not self.collisionTimer)
		elseif type == "graphics" then
			Tick:removeTask(self.displayTimer)
			self.displayTimer = self:setQueue(ticks, "setDisplayState", false, nil)
		
			return (not not self.displayTimer)
		end
		
		return false
	end

	local type = type
	function Chunk:setQueue(set, operation, ...)
		
		local chunkInfo = {
			uniqueId = self.uniqueId,
			x = self.x,
			y = self.y,
			operation = operation,
			args = {...}
		}
		
		if type(set) == "boolean" then -- Instant
			if set then
				ChunkQueue:push(chunkInfo)
			else
				ChunkQueue:popEntry(self.uniqueId)
				ChunkQueue:clearBuffer()
			end
		elseif type(set) == "number" then -- Await some ticks
			return Tick:newTask(set, false, function()
				ChunkQueue:push(chunkInfo)
			end)
		end
	end
	
	--- Sets the Collisions for the Chunk.
	-- This is just an interface function that manages the interactions between
	-- players and the Chunk, to ensure no innecessary calls for players that had
	-- the Chunk already loaded.
	-- @name Chunk:setCollisions
	-- @param Boolean|Nil:active Sets the collision state. If nil then a reload will be performed for all players
	-- @param String|Nil:targetPlayer The target that asks for the collision update. If nil then player check wont be accounted
	-- @return `Boolean` Whether the specified action happened or not
	function Chunk:setCollisions(active, targetPlayer)
		if active == nil then
			self:setCollisions(false, nil)
			self:setCollisions(true, nil)
		else
			local goAhead = false
			if targetPlayer and active then
				goAhead = (not self.collidesTo[targetPlayer] == active)
				self.collidesTo[targetPlayer] = active
			else
				goAhead = true
				self.collidesTo = copykeys(Room.presencePlayerList, not not active)
			end
			
			if goAhead then
				self:setQueue(true, "setPhysicState", active)
			end
			
			if active then
				self:setUnloadDelay(unloadingTime, "physics")
			end
			
			return goAhead
		end
	end
	
	--- Sets the Display state of a Chunk.
	-- This is just an interface function that manages the interactions between
	-- players and the Chunk, to ensure no innecessary calls for players that had
	-- the Chunk already displayed.
	-- @name Chunk:setDisplay
	-- @param Boolean|Nil:active Sets the Display state. If nil then a reload will be performed for all players
	-- @param String|Nil:targetPlayer The target that asks for the Display. If nil then player check wont be accounted
	-- @return `Boolean` Whether the specified action happened or not
	function Chunk:setDisplay(active, targetPlayer)
		if active == nil then
			self:setDisplay(false, nil)
			self:setDisplay(true, nil)
			
			return true
		else
			local goAhead = false
			if targetPlayer and active then
				if isEmpty(self.displaysTo) then
					return self:setDisplay(true, nil)
				else
					goAhead = (not self.displaysTo[targetPlayer] == active)
					self.displaysTo[targetPlayer] = active
				end
			else
				goAhead = true
				self.displaysTo = copykeys(Room.presencePlayerList, active)
			end
			
			if goAhead then
				if targetPlayer == nil then
					if active then
						self:setQueue(true, "setDisplayState", nil)
					else
						
						self:setQueue(true, "setDisplayState", false)
					end
				else
					self:setQueue(true, "setDisplayState", active, targetPlayer)
				end
			end
			
			if active then
				self:setUnloadDelay(math.ceil(unloadingTime * 1.5), "graphics")
			end
			
			return goAhead
		end
	end
end

function Chunk:setState(collision, display, targetPlayer)
	self:setCollisions(collision, targetPlayer)
	self:setDisplay(display, targetPlayer)
end

do
	local ap = function(t, v) t[#t + 1] = v end
	function Chunk:getChunksAround(mode, include)
		local list = {}
		local map = Map
		
		if include then
			ap(list, self)
		end
		
		local xx = self.x
		local yy = self.y
		
		if mode == "special" then -- Order matters
			local p1x = xx + 1
			local s1x = xx - 1
			local p1y = yy + 1
			local s1y = yy - 1
			ap(list, Map:getChunk(p1x, yy, CD_MTX))
			ap(list, Map:getChunk(s1x, yy, CD_MTX))
			ap(list, Map:getChunk(xx, p1y, CD_MTX))
			ap(list, Map:getChunk(xx, s1y, CD_MTX))
			
			ap(list, Map:getChunk(s1x, p1y, CD_MTX))
			ap(list, Map:getChunk(p1x, p1y, CD_MTX))
			ap(list, Map:getChunk(p1x, s1y, CD_MTX))
			ap(list, Map:getChunk(s1x, s1y, CD_MTX))
			
			ap(list, Map:getChunk(p1x + 1, yy, CD_MTX))
			ap(list, Map:getChunk(s1x - 1, yy, CD_MTX))
			ap(list, Map:getChunk(p1x + 1, s1y, CD_MTX))
			ap(list, Map:getChunk(s1x - 1, p1y, CD_MTX))
			
			ap(list, Map:getChunk(xx, p1y + 1, CD_MTX))
		elseif mode == SH_CRS then
			ap(list, Map:getChunk(xx - 1, yy, CD_MTX))
			ap(list, Map:getChunk(xx, yy - 1, CD_MTX))
			ap(list, Map:getChunk(xx + 1, yy, CD_MTX))
			ap(list, Map:getChunk(xx, yy + 1, CD_MTX))
		elseif mode == SH_SQR then
			for y = -1, 1 do
				for x=-1, 1 do
					if not (x == 0 and y == 0) then
						ap(list, Map:getChunk(xx + x, yy + y, CD_MTX))
					end
				end
			end
		end
		
		return list
	end
end