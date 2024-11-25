Field = Matrix:new()

function Field:generateNew(width, height)
	local VOID = blockMeta._C_VOID
	local line
	for y = 1, height do
		line = {}
		for x = 1, width do
			line[x] = VOID
		end
		
		self[y] = line
	end
end

function Field:checkAssign(x, y, type, overwrite, excepts)
	if type == -1 then return false end
	
	local cell = self[y][x]
	
	if overwrite or cell == VOID then
		if not (excepts and excepts[cell]) then
			self[y][x] = type or VOID
			return true
		end
	end
	
	return false
end

do
	local restrict = math.restrict
	function Field:setMatrix(matrix, xStart, yStart)
		local maxWidth, maxHeight = Map:getBlocks()
		local height, width = #matrix, #matrix[1]
		
		xStart = restrict(xStart, 1, maxWidth)
		yStart = restrict(yStart, 1, maxHeight)
		
		
		local xEnd = restrict(xStart + (width - 1), 1, maxWidth)
		local yEnd = restrict(yStart + (height - 1), 1, maxHeight)
		
		local type
		for y = yStart, yEnd do
			for x = xStart, xEnd do 
				type = matrix[(y - yStart) + 1][(x - xStart) + 1]
				if type ~= VOID then
					self[y][x] = type
				end
			end
		end
	end
	
	local round = math.round
	function Field:setStructure(structure, x, y, xAnchor, yAnchor)
		xAnchor = xAnchor or 0.5
		yAnchor = yAnchor or 0.5
		
		local xStart = round(x - (structure.width * xAnchor))
		local yStart = round(y - (structure.height * yAnchor))
		
		self:setMatrix(structure.matrix, xStart, yStart)
	end
end

do
	local max = math.max
	local min = math.min
	
	function Field:setFunction(config)
		local width, height = Map:getBlocks()
		local solve = config.dir
		local overwrite = config.overwrite
		local excepts = config.excepts
		
		local minx = max(1, config.startX or 1)
		local maxx = min(width, config.startX or width)
		
		local miny = max(1, config.startY or 1)
		local maxy = min(height, config.startY or height)
		
		local type = VOID
		
		for y = miny, maxy do
			for x = minx, maxx do
				type = solve(x, y)
				
				self:checkAssign(x, y, type, overwrite, excepts)
			end
		end
	end
		
	function Field:setLayer(layer, heightMap)		
		local width, height = Map:getBlocks()
		
		local dir = layer.dir
		local overwrite = layer.overwrite
		local exclusive = layer.exclusive
		
		local excepts = dir.excepts
		
		local type = dir[1]
		local depth = 1
		
		local limit = layer.vertical and width or height
		
		local minc = max(dir.min or 1, 1)
		local maxc = min(dir.max or limit, limit)
		
		local start
		
		if layer.vertical then			
			for y = 1, height do
				depth = 1
				type = dir[1]
				start = (heightMap and heightMap[y] or minc)
				if not (exclusive and start < minc) then
					for x = max(start, minc), maxc do
						type = dir[depth] or type
						
						if self:checkAssign(x, y, type, overwrite, excepts) then
							depth = depth + 1
						end
					end
				end
			end
		else
			for x = 1, width do
				depth = 1
				type = dir[1]
				start = (heightMap and heightMap[x] or minc)
				if not (exclusive and start < minc) then
					for y = max(start, minc), maxc do
						type = dir[depth] or type
						
						if self:checkAssign(x, y, type, overwrite, excepts) then
							depth = depth + 1
						end
					end
				end
			end
		end
	end	function Field:setHeightMap(mapInfo)
		local VOID = blockMeta._C_VOID
		
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
			for k, _ in next, dir do
				mod = max(k, mod)
			end
		end
		
		local type = VOID
		
		for x = xs, xe do
			xo = (x - xs) + 1
			
			ys = heightMap[xo] or 1
			
			type = VOID
			
			for y = ys, height do
				yo = loops and ((y - ys) % mod) or (y - ys) + 1 -- I have no idea what 'mod' is supposed to do now.
				
				type = dir[yo] or VOID
				
				if type == -1 then
					break
				end
				
				self[y][x] = type
			end
		end
	end
end
-- TODO: Add 2D Noise parser

function Field:setNoiseMap(mapInfo)	
	local noiseMap = mapInfo.noiseMap
	local dir = mapInfo.dir	local width, height = Map:getBlocks()
	
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
					self[y][x] = dir
				end
			end
		end
	end
end