do	
	-- GUIDELINE:
	-- * This class should declare its methods as X_Matrix_Y where
	--		X is a verb, and Y is the direct object.
	-- * This is to avoid clashes, since many different classes inherit this.
	local setmetatable = setmetatable
	function Matrix:new(class, lines)
		local this = setmetatable({
			implement = class
		}, self)
		
		return this
	end
	
	local max = math.max
	function Matrix:setMatrixDimensions(height)		
		for y = 1, height do
			self[y] = {}
		end
		
		for y = height + 1, #self do
			self[y] = nil
		end		
	end
	
	function Matrix:clearMatrixInformation()
		for y = 1, #self do
			self[y] = nil
		end
	end
	
	
	function Matrix:copyMatrixCells(other, solve)
		self:setMatrixDimensions(#other)
		
		for y = 1, #other do
			for x = 1, #other[1] do
				self[y][x] = solve(other, x, y)
			end
		end
	end
	
	local restrict = math.restrict
	local min = math.min
	function Matrix:getMatrixRectangularSection(xStart, yStart, width, height)
		local result = {}
		
		local xEnd = min(#self[1], xStart + width - 1)
		local yEnd = min(#self, yStart + height - 1)
		
		local yShift
		
		for y = yStart, yEnd do
			yShift = (y - yStart) + 1
			result[yShift] = {}
			
			for x = xStart, xEnd do
				result[yShift][(x - xStart) + 1] = self[y][x]
			end
		end
		
		return result
	end
	
	function Matrix:setMatrixRectangularSection(other, xStart, yStart, width, height)		
		local xEnd = restrict(1, #self[1], xStart + width)
		local yEnd = restrict(1, #self, yStart + height)
		
		local yShift
		
		for y = yStart, yEnd do
			yShift = (yEnd - yStart) + 1
			
			for x = xStart, xEnd do
				self[y][x] = other[yShift][(xEnd - xStart) + 1]
			end
		end
	end
end