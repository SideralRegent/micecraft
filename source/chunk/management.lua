do
	local copykeys = table.copykeys
	local isEmpty = table.isEmpty
	--- Sets the Time that the Chunk should wait before unloading.
-- There are three options to pick: physics, graphics, items.
-- Note: Items unload removes them permanently.
-- @name Chunk:setUnloadDelay
-- @param Int:ticks How many ticks should the Chunk await
-- @param String:type The type of unload
-- @return `Boolean` Whether the unload scheduling was successful or not.
	local valid = {
		setPhysicState = true,
		setDisplayState = true
	}
	function Chunk:setUnloadDelay(ticks, type)
		if valid[type] then
			local timer = self.timers[type]
			Tick:removeTask(timer and timer.taskId or 0)
			
			return not not self:setQueue(ticks, type, false, nil)
		end
		
		return false
	end	local type = type
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
			local taskId = Tick:newTask(set, false, function()
				ChunkQueue:push(chunkInfo)
			end)
		
			self.timers[operation] = {
				taskId = taskId,
				targetForRenewal = Tick.current + (set - 10) -- Magic number, excercise for the reader c:
			}
		
			return taskId
		end
	end
	
	--- Evaluates wheter it is proper or not to make a Unload Delay renewal and proceeds.
	-- @name Chunk:requestUnloadDelayRenewal
	-- @param Number:time Delay in ticks
	-- @param String:operation Which function to call for renewal
		
	function Chunk:requestUnloadDelayRenewal(time, operation)
		local threesold = (self.timers[operation] and self.timers[operation].targetForRenewal or 0)
		
		if Tick.current > threesold then
			self:setUnloadDelay(time, operation)
		end
	end
	
	--- Sets the Collisions for the Chunk.
	-- This is just an interface function that manages the interactions between
	-- players and the Chunk, to ensure no innecessary calls for players that had
	-- the Chunk already loaded.
	-- @name Chunk:setCollisions
	-- @param Boolean|Nil:active Sets the collision state. If nil then a reload will be performed for all players
	-- @param Int|Nil:targetPresenceId The target that asks for the collision update. If nil then player check wont be accounted
	-- @return `Boolean` Whether the specified action happened or not
	function Chunk:setCollisions(active, targetPresenceId)
		if active == nil then
			self:setCollisions(false, nil)
			self:setCollisions(true, nil)
		else
			local goAhead = false
			if targetPresenceId and active then
				goAhead = (not self.collidesTo[targetPresenceId] == active)
				self.collidesTo[targetPresenceId] = active
			else -- nil players
				goAhead = true
				self.collidesTo = copykeys(Room.presencePlayerList, not not active)
			end
			
			if goAhead then
				self:setQueue(true, "setPhysicState", active)
			end
			
			if active then
				self:requestUnloadDelayRenewal(
					Module.settings.unloadDelay or 90,
					"setPhysicState"
				)
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
	-- @param Int|Nil:targetPresenceId The target that asks for the Display. If nil then player check wont be accounted
	-- @return `Boolean` Whether the specified action happened or not
	function Chunk:setDisplay(active, targetPresenceId)
		if active == nil then
			self:setDisplay(false, nil)
			self:setDisplay(true, nil)
			
			return true
		else
			local goAhead = false
			if targetPresenceId and active then
				if isEmpty(self.displaysTo) then
					return self:setDisplay(true, nil)
				else
					goAhead = (not self.displaysTo[targetPresenceId] == active)
					self.displaysTo[targetPresenceId] = active
				end
			else
				goAhead = true
				self.displaysTo = copykeys(Room.presencePlayerList, active)
			end
			
			if goAhead then
				local activeType = nil
				
				if not active then
					activeType = false
				end
				
				self:setQueue(true, "setDisplayState", activeType, targetPresenceId)
			end
			
			if active then
				self:requestUnloadDelayRenewal(
					Module.settings.unloadDelay or 90,
					"setDisplayState"
				)
			end
			
			return goAhead
		end
	end
end

function Chunk:setState(collision, display, targetPresenceId)
	self:setCollisions(collision, targetPresenceId)
	self:setDisplay(display, targetPresenceId)
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
		
		if mode == CD_SPC then -- Order matters
			local p1x = xx + 1
			local s1x = xx - 1
			local p1y = yy + 1
			local s1y = yy - 1
			ap(list, map:getChunk(p1x, yy, CD_MTX))
			ap(list, map:getChunk(s1x, yy, CD_MTX))
			ap(list, map:getChunk(xx, p1y, CD_MTX))
			ap(list, map:getChunk(xx, s1y, CD_MTX))
			
			ap(list, map:getChunk(s1x, p1y, CD_MTX))
			ap(list, map:getChunk(p1x, p1y, CD_MTX))
			ap(list, map:getChunk(p1x, s1y, CD_MTX))
			ap(list, map:getChunk(s1x, s1y, CD_MTX))
			
			ap(list, map:getChunk(p1x + 1, yy, CD_MTX))
			ap(list, map:getChunk(s1x - 1, yy, CD_MTX))
			ap(list, map:getChunk(p1x + 1, s1y, CD_MTX))
			ap(list, map:getChunk(s1x - 1, p1y, CD_MTX))
			
			ap(list, map:getChunk(xx, p1y + 1, CD_MTX))
		elseif mode == SH_CRS then
			ap(list, map:getChunk(xx - 1, yy, CD_MTX))
			ap(list, map:getChunk(xx, yy - 1, CD_MTX))
			ap(list, map:getChunk(xx + 1, yy, CD_MTX))
			ap(list, map:getChunk(xx, yy + 1, CD_MTX))
		elseif mode == SH_SQR then
			for y = -1, 1 do
				for x=-1, 1 do
					if not (x == 0 and y == 0) then
						ap(list, map:getChunk(xx + x, yy + y, CD_MTX))
					end
				end
			end
		end
		
		return list
	end
end