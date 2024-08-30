do
	local next = next

	function Player:queueNearChunks(centralChunk, include, forceUpdate)
		centralChunk = centralChunk or Map:getChunk(self.bx, self.by, CD_BLK)
		local chunkList = centralChunk:getChunksAround("special", true)
		
		for _, chunk in next, chunkList do
			chunk:setCollisions(true, self.name) 
			
			chunk:setDisplay(true, self.name)
		end
	end
end

function Player:setDebugInformation(show)
	local db = Debug
	if show ~= nil then
		self.showDebugInfo = show
		db:showFields(self.name, show)
		db:updateField("player_name", self.name, self.name, "NORMAL")
	else
		db:updateField("player_Mappos", self.name, self.x, self.y)
		db:updateField("player_blockpos", self.name, self.bx, self.by)
		db:updateField("player_chunk", self.name, self.currentChunk, self.lastChunk)
		db:updateField("player_facing", self.name, self.isFacingRight and "&gt;" or "&lt;")
		db:updateField("player_lastkey", self.name, self.keys.last)
	end
end