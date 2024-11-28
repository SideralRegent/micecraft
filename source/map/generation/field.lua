-- TODO:
--	> Implement Field:heightMap in the new system (?) possibly useless.
--	> Refactor all calls to Field class in other parts of the code, to
--		follow the new format.

Field = Matrix:new()

--- Initializes the field matrix.
-- @name Field:generateNew
-- @param Int:width Matrix width.
-- @param Int:height Matrix height.
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

do
	local type = type
	local inf = math.huge
	
	local math_restrict = math.restrict
	
	local table_copy = table.copy
	local table_inherit = table.inherit
	local table_numsetf = table.numsetf
	
	local no_except = {}
	
	local default_settings = {
		-- **Logical filters:**
		overwrite = false, -- <boolean> Write over any cell, even if its value isn't VOID.
		excepts = no_except, -- <table> If `overwrite` is active, a list of types to **not** overwrite.
		
		exclusive = nil, -- <table|nil> If present, only affect this block on operations.
		-- Expected format:
		-- exclusive = {
		-- 		[typeA] = true,
		-- 		[typeB] = true,
		--		...
		-- }
		-- defaults to `blockMeta.maps`, if not given.
		
		-- **Limiters:**
		limits = { -- <table> Contains writting limits.
			-- All limits can either be integers or tables.
			-- For the case of tables, the complementary coordinate will be checked.
			-- i.e. given xEnd = heightMapA, such table will be traversed through Y
			-- coordinates and viceversa.
			xStart = 1, -- <int|table> 
			xEnd = inf, -- <int|tables>
			
			yStart = 1, -- <int|tables>
			yEnd = inf, -- <int|tables>
			
			x_asOffset = nil, -- <string|nil>
			y_asOffset = nil -- <string|nil>
			-- Notes:
			-- > Upper Y values in TFM map are smaller in the field matrix.
			-- > The fields `R_asOffset` if given, expect a string that defines
			--		which of both fields (either `rStart` or `rEnd`) is an offset
			--		of the other. Any other value will be treated as nil.
			-- > Only one of the two coordinates can have tables as their
			--		limits. This is because the function needs to determine
			--		which of both will be the reference (Int coordinates), and
			--		thus generate the proper **for** loop configuration.
			-- > Due to the previous note, a field `verticalPrecedence` <boolean> 
			-- 		will be created automatically to determine the loop config.
		},
		
		-- **Settlers:**
		array = nil, -- <table|nil>
		-- Formerly known as **dir**. Dictates how the type of a succesion of blocks will be established.
		-- The expected format is as follows:
		-- array = {
		--		[1] = typeA,
		--		[2] = typeB,
		--		Empty spaces [3], [4], [5], will be automatically filled by the last valid space [2].
		--		[5] = typeC,
		-- }
		-- Will be traversed until hitting: 
		-- a) `limits.xEnd - limits.xStart + 1`
		-- b) `Map.blockHeight`
		
		solver = nil, -- <function|nil>
		-- A function of the form `type <- f(x, y)` that solves types based on position.
		
		matrix = nil, -- <table|nil>
		-- A matrix of types that gets copied into the field.
	}
	
	function Field:correctLimits(limits, matrix) -- Limit corrections
		local width, height = Map:getBlocks()
		
		if matrix then
			if limits.xStart and limits.yStart then
				limits.yEnd = math_restrict(limits.yEnd or (limits.yStart + #matrix - 1), 1, height)
				limits.xEnd = math_restrict(limits.xEnd or (limits.xStart + #matrix[1] - 1), 1, width)
			elseif limits.xEnd and limits.yEnd then
				limits.yStart = math_restrict(limits.yStart or (limits.yEnd - #matrix + 1), 1, height)
				limits.xStart = math_restrict(limits.xStart or (limits.xEnd - #matrix[1] + 1), 1, width)
			end
			
			limits.verticalPrecedence = true
			
			return
		end
		
		if limits.verticalPrecedence == nil then
			if type(limits.xStart) == "number" and type(limits.xEnd) == "number" then
				limits.verticalPrecedence = false
			elseif type(limits.yStart) == "number" and type(limits.yEnd) == "number" then
				limits.verticalPrecedence = true
			else
				error("Field call can not have mutually dependant coordinate limits.")
			end
		end
		
		-- Yes, I could do "set p_X and t_X" to represent the precedence and
		-- the target, but guess what. That would add overhead to the operation.
		-- More overhead to an already bloated implementation of a Field
		-- generator. So for now we're repeating code.
		if limits.verticalPrecedence then
			if limits.y_asOffset == "yEnd" then
				limits.yEnd = limits.yStart + limits.yEnd
			elseif limits.y_asOffset == "yStart" then
				limits.yStart = limits.yEnd - limits.yStart
			end
			
			limits.yStart = math_restrict(limits.yStart, 1, height)
			limits.yEnd = math_restrict(limits.yEnd, 1, height)
			
			limits.xStart = table_numsetf(limits.xStart, limits.yEnd, limits.yStart, math.max, 1)
			limits.xEnd = table_numsetf(limits.xEnd, limits.yEnd, limits.yStart, math.min, width)
			
			if limits.x_asOffset == "xEnd" then -- xEnd is an offset of xStart
				for y = limits.yStart, limits.yEnd do
					limits.xEnd[y] = limits.xStart[y] + limits.xEnd[y]
				end
			elseif limits.x_asOffset == "xStart" then -- xStart is an offset of xEnd 
				for y = limits.yStart, limits.yEnd do
					limits.xStart[y] = limits.xEnd[y] - limits.xStart[y]
				end
			end -- else: no changes, both are absolute coordinates
		else -- horizontal precedence
			if limits.x_asOffset == "xEnd" then
				limits.xEnd = limits.xStart + limits.xEnd
			elseif limits.x_asOffset == "xStart" then
				limits.xStart = limits.xEnd - limits.xStart
			end
			
			limits.xStart = math_restrict(limits.xStart, 1, width)
			limits.xEnd = math_restrict(limits.xEnd, 1, width)
			
			limits.yStart = table_numsetf(limits.yStart, limits.xEnd, limits.xStart, math.max, 1)
			limits.yEnd = table_numsetf(limits.yEnd, limits.xEnd, limits.xStart, math.min, height)
			
			if limits.y_asOffset == "yEnd" then -- yEnd is an offset of xStart
				for x = limits.xStart, limits.xEnd do
					limits.yEnd[x] = limits.yStart[x] + limits.yEnd[x]
				end
			elseif limits.y_asOffset == "yStart" then -- yStart is an offset of xEnd 
				for x = limits.xStart, limits.xEnd do
					limits.yStart[x] = limits.yEnd[x] - limits.yStart[x]
				end
			end -- else: no changes, both are absolute coordinates
		end
	end
	
	-- Normalizes the given settings.
	-- Allows to universally use the same settings for all external Field calls.
	-- It uses `default_settings` and its derivates as templates.
	-- @name Field:normalizeConfig
	-- @param Table:ext_settings User provided settings.
	-- @return `Table` A table with corrected settings.
	function Field:normalizeConfig(ext_settings, extra)
		local settings = table_inherit(default_settings, ext_settings)
		
		if not settings.exclusive then
			settings.exclusive = blockMeta.maps
		end
		
		if settings.matrix then
			assert(
				type(settings.matrix) == "table"
				and type(settings.matrix[1]) == "table", 
				"Field call matrix must be a bidimensional table."
			)
		end
		
		if settings.array then
			local arr = settings.array
			assert(type(arr) == "table", "Field call array must be a table.")
			
			local width, height = Map:getBlocks()
			
			local max = 0
			if settings.limits.verticalPrecedence then
				max = height
			else
				max = width
			end
			
			local prev = arr[1]
			for i = 2, max do
				arr[i] = arr[i] or prev
				
				prev = arr[i]
			end
		end
		
		if settings.solver then
			assert(type(settings.solver) == "function", "Field call solver must be a function.")
		end
		
		self:correctLimits(settings.limits, settings.matrix)
		
		settings.extra = extra
		
		return settings
	end
	
	--- Assigns the specified type to the specified cell.
	-- @name Field:checkAssign
	-- @param Int:x X position in matrix.
	-- @param Int:y Y position in matrix.
	-- @param Int:c_type Block cell type. See **blockMeta**.
	-- @param Boolean:overwrite Write over this cell even if the block isn't void.
	-- @param List:excepts If given, a list of types which should not be overwritten.
	function Field:checkAssign(x, y, c_type, overwrite, exclusive, excepts)
		local cell = self[y][x]
		
		if exclusive[cell] then
			self[y][x] = c_type
		else
			if (cell == VOID or overwrite) and not excepts[cell] then
				self[y][x] = c_type
			end
		end
	end
	--- Sets a types matrix to the field.
	-- @name Field:setMatrix
	-- @param table:matrix A types matrix. See **blockMeta** for types.
	-- @param Int:xStart X position to start setting values.
	-- @param Int:yStart Y position to start setting values.
	function Field:setMatrix(settings)
		settings = self:normalizeConfig(settings)
		
		local overwrite = settings.overwrite
		local exclusive = settings.exclusive
		local excepts = settings.excepts
		local c_type
		local matrix = settings.matrix
		local mLine
				
		if settings.matrix then
			local limits = settings.limits
			local yStart = limits.yStart
			local xStart = limits.xStart
			local xEnd = limits.xEnd
			
			for y = yStart, limits.yEnd do
				mLine = matrix[(y - yStart) + 1]
				for x = xStart, xEnd do
					c_type = mLine[(x - xStart) + 1]
					
					self:checkAssign(x, y, c_type, overwrite, exclusive, excepts)
				end
			end
			
			return true
		end
		
		return false
	end
	
	local math_round = math.round
	--- Wrapper for Field:setMatrix for structures.
	-- @name Field:setStructure
	-- @param Table:settings See **field.lua**.
	-- @param Structure:structure A structure
	-- @param Number:xAnchor In a scale of 0 to 1, X center of the structure.
	-- @param Number:yAnchor In a scale of 0 to 1, Y center of the structure.
	function Field:setStructure(settings, structure, xAnchor, yAnchor)
		xAnchor = xAnchor or 0.5
		yAnchor = yAnchor or 0.5
		settings.matrix = structure.matrix
		
		settings.limits.xStart = math_round(x - (structure.width * xAnchor))
		settings.limits.yStart = math_round(y - (structure.height * yAnchor))
		
		self:setMatrix(settings)
	end
	
	--- Traverses the field, given the limits and executor.
	-- @name Field:wrapTraverse
	-- @param Table:settings See **field.lua**.
	-- @param Function:execute A function called on each position.
	-- Expected on the form `execute(Field, x, y, i, iStart, iEnd)` and returns a type.
	function Field:wrapTraverse(settings, execute)
		local limits = settings.limits
		local xStart, xEnd = limits.xStart, limits.xEnd
		local yStart, yEnd = limits.yStart, limits.yEnd
		
		local overwrite = settings.overwrite
		local exclusive = settings.exclusive
		local excepts = settings.excepts
				
		if limits.verticalPrecedence then
			local xs, xe
			for y = yStart, yEnd do
				xs, xe = xStart[y], xEnd[y]
				for x = xs, xe do
					self:checkAssign(x, y,
						execute(x, y, x, xs, xe),
						overwrite, exclusive, excepts
					)
				end
			end
		else
			local ys, ye
			for x = xStart, xEnd do
				ys, ye = yStart[x], yEnd[x]
				for y = ys, ye do
					self:checkAssign(x, y,
						execute(x, y, y, ys, ye),
						overwrite, exclusive, excepts
					)
				end
			end
		end
	end
		
	--- Sets all cells to the value given by the function.
	-- @name Field:setFunction
	-- @param Table:settings See **field.lua**.
	-- Field `solver` expected as detailed on **Field:wrapTraverse**.
	function Field:setFunction(settings)
		settings = self:normalizeConfig(settings)
		
		if settings.solver then
			self:wrapTraverse(settings, settings.solver)
		end
		
		return false
	end
	
	function Field:setLayer(settings)
		settings = self:normalizeConfig(settings)
		
		local array = settings.array
		
		if array then
			local aux_setLayer
			
			if settings.extra and settings.extra.inverse then
				aux_setLayer = function(x, y, i, _iStart, iEnd)
					return array[(iEnd - i) + 1]
				end
			else
				aux_setLayer = function(x, y, i, iStart, _iEnd)
					return array[(i - iStart) + 1]
				end
			end
			
			self:wrapTraverse(settings, aux_setLayer)
		end
	end
	
	-- 
	
	function Field:setHeightMap(mapInfo)
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