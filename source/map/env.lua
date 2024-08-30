function Map:setVariables(blockWidth, blockHeight, chunkWidth, chunkHeight, MapChunkRows, MapChunkLines, horizontalOffset, verticalOffset)
	-- Block
	self.blockWidth = blockWidth or 32
	self.blockHeight = blockHeight or 32
	self.blockSize = self.blockWidth + ((self.blockWidth - self.blockHeight) / 2)
	
	REFERENCE_SCALE = self.blockSize / TEXTURE_SIZE
	REFERENCE_SCALE_X = self.blockWidth / TEXTURE_SIZE
	REFERENCE_SCALE_Y = self.blockHeight / TEXTURE_SIZE
	
	-- Chunk
	
	self.chunkWidth = chunkWidth or 16
	self.chunkHeight = chunkHeight or 16
	
	self.chunkSize = self.chunkWidth * self.chunkHeight
	
	self.chunkPixelWidth = self.chunkWidth * self.blockWidth
	self.chunkPixelHeight = self.chunkHeight * self.blockHeight
	
	-- Map
	
	self.chunkRows = MapChunkRows or self.chunkRows
	self.chunkLines = MapChunkLines or self.chunkLines
	
	self.totalChunks = self.chunkRows * self.chunkLines
	
	self.totalBlockWidth = self.chunkRows * self.chunkWidth
	self.totalBlockHeight = self.chunkLines * self.chunkHeight
	
	self.totalBlocks = self.totalChunks * self.chunkSize
	
	self.pixelWidth = math.min(BOX2D_MAX_SIZE, self.blockWidth * (self.chunkWidth * self.chunkRows))
	self.pixelHeight = math.min(BOX2D_MAX_SIZE, self.blockHeight * (self.chunkHeight * self.chunkLines))
	
	self.horizontalOffset = math.min(horizontalOffset*2, (BOX2D_MAX_SIZE - self.pixelWidth) / 2)
	self.verticalOffset = math.min(verticalOffset, (BOX2D_MAX_SIZE - self.pixelHeight) / 2)
	
	self.leftEdge = self.horizontalOffset
	self.rightEdge = (2 * self.horizontalOffset) + self.pixelWidth
	
	self.upperEdge = self.verticalOffset
	self.lowerEdge = (2 * self.verticalOffset) + self.pixelHeight
	
	self:setCounter("chunks_collide", 0, false)
	self:setCounter("chunks_display", 0, false)
	self:setCounter("chunks_item", 0, false)
end

function Map:getBlockDimensions()
	return self.blockWidth, self.blockHeight, self.blockSize
end

function Map:getChunkDimensions()
	return self.chunkWidth, self.chunkHeight, self.chunkSize
end

function Map:getChunkPixelDimensions()
	return self.chunkPixelWidth, self.chunkPixelHeight
end

function Map:getPixelDimensions()
	return self.pixelWidth, self.pixelHeight
end

function Map:getMapPixelDimensions()
	return self.rightEdge, self.lowerEdge
end

function Map:getBlocks()
	return self.totalBlockWidth, self.totalBlockHeight
end

function Map:getChunks()
	return self.chunkRows, self.chunkLines
end

function Map:getOffsets()
	return self.horizontalOffset, self.verticalOffset
end

function Map:getEdges()
	return self.leftEdge, self.upperEdge, self.rightEdge, self.lowerEdge
end