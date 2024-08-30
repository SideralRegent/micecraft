function Field:generateNew(width, height)
	local VOID = blockMetadata._C_VOID
	for y = 1, height do
		self[y] = {}
		for x = 1, width do
			self[y][x] = {type = VOID, tangible = false}
		end
	end
end


function Field:assignTemplate(x, y, template)
	local this = self[y][x]
	if template.type ~= nil then
		this.type = template.type
	end
	
	if template.tangible ~= nil then
		this.tangible = template.tangible
	end
end

do
	function Field:setStructure(structure, x, y, xAnchor, yAnchor)
		xAnchor = xAnchor or 0.5
		yAnchor = yAnchor or 0.5
		
		local xStart = math.round(x - (structure.width * xAnchor))
		local yStart = math.round(y - (structure.height * yAnchor))
		
		self:setMatrix(structure.matrix, xStart, yStart)
	end
	
	function Field:setMatrix(matrix, xStart, yStart)
		local VOID = blockMetadata._C_VOID
		local maxWidth, maxHeight = Map:getBlocks()
		local height, width = #matrix, #matrix[1]
		
		xStart = math.restrict(xStart, 1, maxWidth)
		yStart = math.restrict(yStart, 1, maxHeight)
		
		
		local xEnd = math.restrict(xStart + (width - 1), 1, maxWidth)
		local yEnd = math.restrict(yStart + (height - 1), 1, maxHeight)
		
		local template
		for y = yStart, yEnd do
			for x = xStart, xEnd do 
				template = matrix[(y - yStart) + 1][(x - xStart) + 1]
				if not (template.type == VOID and template.tangible) then
					self:assignTemplate(x, y, template)
				end
			end
		end
	end
	
	local max = math.max
	local min = math.min
	
	function Field:setLayer(layer, heightMap)
		local VOID = blockMetadata._C_VOID
		
		local width, height = Map:getBlocks()
		local dir = layer.dir
		local overwrite = layer.overwrite
		local exclusive = layer.exclusive
		
		local minc, maxc, start
		
		local template = dir[1]
		local depth = 1
		
		if layer.vertical then
			minc = max(dir.min or 1, 1) -- X Start
			maxc = min(dir.max or width, width) -- X End
			
			for y = 1, height do
				depth = 1
				template = dir[depth]
				start = (heightMap and heightMap[y] or minc)
				if not (exclusive and start < minc) then
					for x = max(start, minc), maxc do
						template = dir[depth] or template
						
						if template.type == -1 then
							break
						end
						
						if overwrite or self[y][x].type == VOID then
							self:assignTemplate(x, y, template)
						end
						
						depth = depth + 1
					end
				end
			end
		else
			minc = max(dir.min or 1, 1) -- Y Start
			maxc = min(dir.max or height, height) -- Y End
			for x = 1, width do
				depth = 1
				template = dir[depth]
				start = (heightMap and heightMap[x] or minc)
				if not (exclusive and start < minc) then
					for y = max(start, minc), maxc do
						template = dir[depth] or template
						
						if template.type == -1 then
							break
						end
						
						if overwrite or self[y][x].type == VOID then
							self:assignTemplate(x, y, template)
						end
						
						depth = depth + 1
					end
				end
			end
		end
	end

	function Field:setHeightMap(mapInfo)
		local VOID = blockMetadata._C_VOID
		
		local dir = mapInfo.dir
		local heightMap = mapInfo.heightMap
		local loops = mapInfo.loops
		local width, height = Map:getBlocks()
		
		local xs = mapInfo.xStart or 1 -- X Start
		local xe = mapInfo.xEnd or min(xs + #heightMap, width) -- X End
		
		local xo -- X Offset
		local yo -- Y Offset
		
		local ys -- Y Start
		
		local mod = 1
		
		if loops then
			for k, v in next, dir do
				mod = max(k, mod)
			end
		end
		
		local template = {type = VOID, tangible = false}
		
		for x = xs, xe do
			xo = (x - xs) + 1
			
			ys = heightMap[xo] or 1
			
			template = {type = VOID, tangible = false}
			
			for y = ys, height do
				yo = loops and ((y - ys) % mod) or (y - ys) + 1 -- I have no idea what 'mod' is supposed to do now.
				
				template = dir[yo] or template
				
				if template.type == -1 then
					break
				end
				
				self:assignTemplate(x, y, template)
			end
		end
	end
end
-- To Do: Add 2D Noise parser

function Field:setNoiseMap(mapInfo)
	local VOID = blockMetadata._C_VOID
	
	local noiseMap = mapInfo.noiseMap
	local dir = mapInfo.dir

	local width, height = Map:getBlocks()
	
	local xs = math.range(dir.xStart or 1, 1, width)
	local xe = math.range(dir.xEnd or width, 1, width)
	
	local ys = math.range(dir.yStart or 1, 1, height)
	local ye = math.range(dir.yEnd or height, 1, height)
	
	local xo, yo
	
	local threshold = dir.threshold or 0.5
	
	local sqr = 1
	
	for y = ys, ye do
		yo = (y - ys) + 1
		
		if noiseMap[yo] then
			for x = xs, xe do
				xo = (x - xs) + 1
				
				sqr = noiseMap[yo][xo] or 0
				
				if sqr > threshold then
					self:assignTemplate(x, y, dir)
				end
			end
		end
	end
end

do
	local random = math.random
	local randomseed = math.randomseed
	function Field:applyBedrockLayer()
		randomseed(0x132B7F7) -- Magic number which provides randomness to the random seed.
		
		local width, height = Map:getBlocks()
		local BEDROCK = blockMetadata._C_BEDROCK
		
		for x = 1, width do
			self:assignTemplate(x, height, {type = BEDROCK, tangible=true})
		end
		
		for x = 1, width do
			for y = height - 2, height - 1 do
				if random(20) > 7 then
					self:assignTemplate(x, y, {type = BEDROCK, tangible=true})
				end
			end
		end
	end
end