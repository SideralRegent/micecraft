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
	
	local block = Block
	local decoTile = self.decorations.implement
	
	-- Localization
	local blocks = Matrix:new(Block)--self.blocks
	local field = Field
	local physics = self.physicsMap
	local deco = self.decorations
	
	-- Values for correct positioning
	local blockWidth, blockHeight = self:getBlockDimensions()
	local originX, originY = self:getEdges()
	
	-- local temp
	
	local displayY
	local displayX = {}
	
	-- For general line indexing (saves acceses)
	local line, fieldLine, physicsLine, decoLine
	
	-- Calculates the display X once and stores it. 
	for x = 1, width do
		displayX[x] = originX + ((x - 1) * blockWidth)
	end
	
	for y = 1, height do
		line = {} -- For storing blocks in a single line
		decoLine = {}
		fieldLine = field[y] -- For indexing only once the line
		physicsLine = physics[y] -- Same as above
		
		-- Calculates Y pos with proper displacement
		displayY = originY + ((y - 1) * blockHeight)
		
		for x = 1, width do
			blockId = blockId + 1
			-- temp = fieldLine[x]
			
			-- Creates a block and stores it in the lines
			line[x], physicsLine[x] = block:new(
				blockId,
				fieldLine[x],
				x, y,
				displayX[x], displayY,
				blockWidth, blockHeight
			)
			
			decoLine[x] = decoTile:new(displayX[x], displayY)
		end
		
		blocks[y] = line
		deco[y] = decoLine
	end
	
	self.blocks = blocks
	self.decorations = deco
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
	
	local chunks = Matrix:new(chunk)
	local method = self.physicsMap[self.physicsMode]
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
			
			this:getCollisionsFast(method)
			self.chunkLookup[chunkId] = {x = x, y = y}
			
			line[x] = this
		end
		
		chunks[y] = line
	end
	
	self.chunks = chunks
end

function Map:init()
	self:setPhysicsMode()
	local mode = Module:getMode()
	
	local width, height = self:getBlocks()
	
	debug.pmeasure("- F_init: %s", Field.generateNew, Field, width, height)
	--Field:generateNew(width, height)
	
	debug.pmeasure("- F_set: %s", mode.setMap, mode, Field)
	--mode:setMap(Field)
	
	debug.pmeasure("- Init physics: %s", self.initPhysics, self, width, height)
	--self:initPhysics(width, height)
	
	debug.pmeasure("- Init blocks: %s", self.initBlocks, self, width, height)
	--self:initBlocks(width, height)
	
	debug.pmeasure("- Chunks: %s", self.initChunks, self)
	--self:initChunks()
end