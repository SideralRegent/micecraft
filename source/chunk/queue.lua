do
	local setmetatable = setmetatable
	local table = table
	--[[
		chunkInfo = {
			uniqueId = 0,
			x = 0,
			y = 0,
			operation = "setCollisions",
			args = {true, "Indexinel#5948"}
		}
		
		ChunkQueue:stack[n]
	]]
	
	function ChunkQueue:clear()
		self.stack = {}
		self.entries = {}
	end
	
	function ChunkQueue:setDefaultStep(number)
		self.defaultStep = number
	end
	
	function ChunkQueue:getDefaultStep()
		return self.defaultStep
	end
	
	function ChunkQueue:addBuffer(chunkInfo)
		local uniqueId = chunkInfo.uniqueId
		local buffer = self.buffer
		
		if not buffer[uniqueId] then
			buffer[uniqueId] = setmetatable({}, {__index = table})
		end
		self:removeBuffer(uniqueId, chunkInfo.operation, chunkInfo.args[1], true)
		buffer[uniqueId]:insert(chunkInfo)
	end
	
	function ChunkQueue:removeBuffer(uniqueId, operation, arg1, preserve)
		local buffer = self.buffer[uniqueId]
		
		if buffer then
			if (operation == nil and arg1 == nil) then
				self:clearBuffer(uniqueId)
			else
				local bufferSize = #buffer
				local i = 1
				
				while i <= bufferSize do
					if (operation == nil) or (buffer[i].operation == operation) then
						if (arg1 == nil) or (arg1 == buffer[i].args[1]) then
							buffer:remove(i)
							bufferSize = bufferSize - 1
						else
							i = i + 1
						end
					else
						i = i + 1
					end
				end
				
				if #buffer <= 0 and not preserve then
					self:clearBuffer(uniqueId)
				end
			end
		end
	end
	
	function ChunkQueue:clearBuffer(uniqueId)
		self.buffer[uniqueId] = nil
	end
	
	function ChunkQueue:push(index, chunkInfo)
		local stackSize = #self.stack
		if not chunkInfo then
			if not index then return end
			chunkInfo = index
			
			index = stackSize + 1
		end
		
		local entryId = self.entries[chunkInfo.uniqueId]
		if not entryId then
			if index <= stackSize then
				local ci, newIndex
				
				for i = stackSize, index, -1 do
					newIndex = i + 1
					ci = self.stack[i]
					
					self.stack[newIndex] = self.stack[i]
					self.entries[ci.uniqueId] = newIndex
				end
			end
			
			self.stack[index] = chunkInfo
			self.entries[chunkInfo.uniqueId] = index
		else
			local ci = self.stack[entryId]
			
			local sameOperation = (ci.operation == chunkInfo.operation)
			local sameInstruct = (ci.args[1] == chunkInfo.args[1])
			if not (sameOperation and sameInstruct) then
				self:addBuffer(chunkInfo)
			end
		end
	end
	
	function ChunkQueue:pop(index)
		local stackSize = #self.stack
		
		index = index or stackSize
		
		local chunkInfo = self.stack[index]
		
		if chunkInfo then
			self.entries[chunkInfo.uniqueId] = nil
			self.stack[index] = nil
			
			if index < stackSize then
				local ci
				for i = index, stackSize - 1 do
					ci = self.stack[i + 1]
					self.stack[i] = ci
					self.entries[ci.uniqueId] = i
				end
				
				ci = self.stack[stackSize]
				if ci then
					self.stack[stackSize] = nil
					self.entries[ci.uniqueId] = nil
				end
			end
			
			if self.buffer[chunkInfo.uniqueId] then
				local newInfo = self.buffer[chunkInfo.uniqueId]:remove(1)
				if newInfo then
					self:push(newInfo)
				else
					self:removeBuffer(chunkInfo.uniqueId)
				end
			end
		end
		
		return chunkInfo
	end
	
	function ChunkQueue:popEntry(entryId)
		local index = self.entries[entryId]
		
		if index then
			self:pop(index)
		end
	end
	
	function ChunkQueue:get(index)
		return self.stack[index]
	end
	
	function ChunkQueue:step(steps)
		if #self.stack == 0 then return end
		
		steps = steps or self.defaultStep or 4
		
		local info
		for _ = 1, steps do
			info = self:get(1)
			if info then
				local chunk = Map:getChunk(info.x, info.y, CD_MTX)
				
				local a = info.args
				chunk[info.operation](chunk, a[1], a[2], a[3], a[4])
				self:pop(1)
			end
		end
	end
	
	ChunkQueue.tickId = Tick:newTask(1, true, function()
		ChunkQueue:step()
	end)
end