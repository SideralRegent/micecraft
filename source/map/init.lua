function Map:initPhysics(width, height)
	local pm = self.physicsMap
	
	for y = 1, height do
		pm[y] = {}
		for x = 1, width do
			pm[y][x] = 0
		end
	end
end

function Map:initBlocks(width, height)
	local blockId = 0
	
	local blocks = self.blocks
	local field = Field
	local pm = self.physicsMap
	
	local block = Block
	
	local bw, bh = self:getBlockDimensions()
	local ox, oy = self:getEdges()
	
	local temp
	
	local dy
	local line, fl, pml
	
	local dxl = {}
	
	for x = 1, width do
		dxl[x] = ox + ((x-1) * bw)
	end
	
	for y = 1, height do
		line = {}
		fl = field[y]
		pml = pm[y]
		dy = oy + ((y-1) * bh)
		
		for x = 1, width do
			blockId = blockId + 1
			
			temp = fl[x]
			
			line[x], pml[x] = block:new(
				blockId,
				temp.type,
				x, y,
				dxl[x], dy,
				bw, bh
			)
		end
		
		blocks[y] = line
	end
end

function Map:initChunks()
	local widthLim, heightLim = self:getChunks()
	local width, height = self:getChunkDimensions()
	local xoff, yoff = self:getOffsets()
	local xp, yp = self:getChunkPixelDimensions()
	local chunkId = 0
	
	local yFact, dy
	
	local chunk = Chunk
	local this
	
	local xFactList = {}
	local dxList = {}
	
	for x = 1, widthLim do
		xFactList[x] = ((x-1) * width) + 1
		dxList[x] = xoff + ((x - 1) * xp)
	end
	
	local chunks = self.chunks
	
	local line
	
	for y = 1, heightLim do
		line = {}
		
		yFact = ((y-1) * height) + 1
		dy = yoff + ((y-1) * yp)
		
		for x = 1, widthLim do
			chunkId = chunkId + 1
			
			this = chunk:new(
				chunkId, 
				x, y, 
				width, height, 
				xFactList[x], yFact,
				dxList[x], dy,
				1
			)
			
			this:getCollisions(self.physicsMode)
			self.chunkLookup[chunkId] = {x=x, y=y}
			
			line[x] = this
		end
		
		chunks[y] = line
	end
end

function Map:init()
	self:setPhysicsMode()
	local mode = Module:getMode()
	
	local width, height = self:getBlocks()
	
	Field:generateNew(width, height)
	
	mode:setMap(Field)
	
	self:initPhysics(width, height)

	self:initBlocks(width, height)
	
	self:initChunks()
end