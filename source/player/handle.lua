do
	local next = next

	function Player:queueNearChunks(centralChunk) -- , include, forceUpdate)
		centralChunk = centralChunk or Map:getChunk(self.bx, self.by, CD_BLK)
		local chunkList = centralChunk:getChunksAround(CD_SPC, true)
		
		for _, chunk in next, chunkList do
			chunk:setCollisions(true, self.name) 
			
			chunk:setDisplay(true, self.name)
		end
	end
end