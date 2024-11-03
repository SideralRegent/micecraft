do
	local ti = function(table, value)
		table[#table + 1] = value
	end
	function Player:getNearChunks(centralChunk)
		local map = Map
		centralChunk = centralChunk or map:getChunk(self.bx, self.by, CD_BLK)
		if not centralChunk then return end
		
		local cx, cy = centralChunk.x, centralChunk.y
		local chunkList = {centralChunk}
		
		local xLim, yLim = map:getFieldNormRanges()
		
		
		for x = 1, xLim do
			ti(chunkList, map:getChunk(cx + x, cy, CD_MTX))
			ti(chunkList, map:getChunk(cx - x, cy, CD_MTX))
		end
		
		for y = 1, yLim do
			ti(chunkList, map:getChunk(cx, cy + y, CD_MTX))
			ti(chunkList, map:getChunk(cx, cy - y, CD_MTX))
			for x = 1, xLim do
				ti(chunkList, map:getChunk(cx + x, cy + y, CD_MTX))
				ti(chunkList, map:getChunk(cx - x, cy + y, CD_MTX))
				ti(chunkList, map:getChunk(cx + x, cy - y, CD_MTX))
				ti(chunkList, map:getChunk(cx - x, cy - y, CD_MTX))
			end
		end
		
		return chunkList
	end
	
	local next = next
	function Player:queueNearChunks(centralChunk, forceUpdate) -- , include, forceUpdate)
		local chunkList = self:getNearChunks(centralChunk)
		if not chunkList then return end
		local update = true
		
		if forceUpdate then
			update = nil
		end
		
		for _, chunk in next, chunkList do
			chunk:setState(update, update, self.presenceId)
		end
	end
	
	function Player:getRank()
		return Room.ranks[self.name]
	end
end