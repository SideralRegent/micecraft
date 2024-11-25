do
	-- Localize standard functions to reduce direct workload on built functions
	local floor = math.floor
	local ceil = math.ceil
	local abs = math.abs
	local min, max = math.min, math.max
	local sqrt = math.sqrt
	local cos = math.cos
	local pi = math.pi
	local random = math.random
	
	local tostring = tostring
	local BASEDIGITS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz@!" -- Used for base conversion
	
	local insert = table.insert
	local concat = table.concat
	
	--- Rounds a number to the nearest integer.
	-- For numbers with decimal digit under 0.5, it will floor that number, 
	-- and for numbers over 0.5 it will ceil that number.
	-- @name math.round
	-- @param Number:n The number to round
	-- @return `Number` The number rounded.
	math.round = function(number)
		return floor(number + 0.5)
	end
	
	--- Restrict the given input between two limits.
	-- @name math.restrict
	-- @param Number:number The number to restrict
	-- @param Number:lower The lower limit
	-- @param Number:higher The higher limit
	-- @return `Number` The number between the specified range.
	math.restrict = function(number, lower, higher)
		return max(lower, min(number, higher))
	end
	
	--- Returns the distance between two points on a cartesian plane.
	-- @name math.pythag
	-- @param Number:ax The horizontal coordinate of the first point
	-- @param Number:ay The vertical coordinate of the first point
	-- @param Number:bx The horizontal coordinate of the second point
	-- @param Number:by The vertical coordinate of the second point
	-- @return `Number` The distance between both points.
	math.pythag = function(ax, ay, bx, by)
		return sqrt((bx - ax)^2 + (by - ay)^2)
	end
	
	math.magnitude = function(x, y)
		return sqrt(x^2 + y^2)
	end
	
	--- Returns the absolute difference between two numbers.
	-- @name math.udist
	-- @param Number:a The first number
	-- @param Number:b The second number
	-- @return `Number` The absolute difference.
	math.udist = function(a, b)
		return abs(a - b)
	end
	
	--- Rounds a number to the specified level of precision.
	-- The precision is the amount of decimal points after the integer part.
	-- @name math.precision
	-- @param Number:number The number to correct precision
	-- @param Int:precision The decimal digits of precision that this number will have
	-- @return `Number` The number with the corrected precision.
	math.precision = function(number, precision)
		local elevator = 10^precision
		
		return floor(number * elevator) / elevator
	end
	
	--- Converts a number to a string representation in another base.
	-- The base can be as lower as 2 or as higher as 64, otherwise it returns nil.
	-- @name math.tobase
	-- @param Number:number The number to convert
	-- @param Int:base The base to convert this number to
	-- @return `String` The number converted to the specified base.
	math.tobase = function(number, base)
		base = base or 10
		if base < 2 or base > 64 then return end
		number = floor(number)
		
		if base == 10 then
			return tostring(number)
		end
		
		local digits = BASEDIGITS
		local composition = {}
		
		local sign = (number < 0 and "-" or "")
		if sign == "-" then
			number = -number
		end
		
		repeat
			local digit = (number % base) + 1
			number = floor(number / base)
			insert(composition, 1, digits:sub(digit, digit))
		until number == 0		return sign .. concat(composition, "")
	end
	
	local STRDIGITS = {}
	for i = 1, #BASEDIGITS do
		STRDIGITS[BASEDIGITS:sub(i, i)] = i - 1
	end
	
	--- Converts a string to a number, if possible.
	-- The base can be as lower as 2 or as higher as 64, otherwise it returns nil.
	-- When bases are equal or lower than 36, it uses the native Lua `tonumber` method.
	-- @name math.tonumber
	-- @param String:str The string to convert
	-- @param Int:base The base to convert this string to number
	-- @return `String` The string converted to number from the specified base.
	math.tonumber = function(str, base)
		if base <= 36 then
			return tonumber(str, base)
		else
			local number = 0
			local len = #str
			local value
			for i = len, 1, -1 do
				value = STRDIGITS[str:sub(i, i)]
				if (not value) or (value >= base) then
					return nil
				else
					number = number + ((base ^ (len - i)) * value)
				end
			end
			
			return number
		end
	end
	
	--- Interpolates two points with a cosine curve.
	-- @name math.cosint
	-- @param Number:a First Point
	-- @param Number:b Second point
	-- @param Number:s Curve size
	-- @return `Number` Resultant point with value interpolated through cosine function.
	math.cosint = function(a, b, s)
		local f = (1 - cos(s * pi)) * 0.5
		
		return (a * (1 - f)) + (b * f)
	end
	
	math.line = function(startPoint, finishPoint, width, offset, lower, higher, truncate)
		offset = offset or 0
		lower = lower or math.min(startPoint, finishPoint)
		higher = higher or math.max(finishPoint, startPoint)
		local step = (finishPoint - startPoint) / width
		local line = {}
		
		local y
		
		for x = 1, width do
			y = math.restrict(offset + startPoint + ((x - 1) * step), lower, higher)
			if truncate then
				y = math.round(y)
			end
			
			line[x] = y
		end
		
		return line
	end
	
	--- Generates a Height Map based on the current `random seed`.
	-- @name math.heightMap
	-- @param Number:amplitude How tall can a wave be
	-- @param Number:waveLenght How wide will a wave be
	-- @param Int:width How large should the height map be
	-- @param Number:offset Overall height for which map will be increased
	-- @param Number:lower The lower limit of height
	-- @param Number:higher The higher limit of height
	-- @return `Table` An array that contains each point of the height map.
	local cosint = math.cosint
	local restrict = math.restrict
	math.heightMap = function(amplitude, waveLenght, width, offset, lower, higher, truncate)
		lower = lower or 0
		higher = higher or amplitude + offset
		local heightMap = {}
		local a, b = random(), random()
		
		local x, y = 0, 0
		
		while x < width do
			if x % waveLenght == 0 then
				a = b
				b = random()
				y = (a * amplitude)
			else
				y = cosint(a, b, (x % waveLenght) / waveLenght) * amplitude
			end
			
			heightMap[x + 1] = restrict(y + offset, lower, higher)
			
			if truncate then
				heightMap[x + 1] = math.round(heightMap[x + 1])
			end
			
			x = x + 1
		end
		
		return heightMap
	end
	
	local ipairs = ipairs
	local round = math.round
	math.heightMapVar = function(amplitude, width, direction, truncate)
		local heightMap = {}
		
		local xEnd = 0
		local xStart = 1
		local a, b = 0, 0
		
		local y = 0
		local s = 0
		
		for _, section in ipairs(direction) do
			xStart = xEnd + 1
			s = xEnd
			xEnd = section[1]
			a = b
			b = section[2]
			
			if truncate then
				for x = xStart, xEnd do
					y = cosint(a, b, s) * amplitude
					
					heightMap[#heightMap + 1] = round(y)
				end
			else
				for x = xStart, xEnd do
					y = cosint(a, b, s) * amplitude
					
					heightMap[#heightMap + 1] = y
				end
			end
		end
		
		return heightMap
	end
	
	do
		local op = {
			add = function(a, b)
				return a + b
			end,
			sub = function(a, b)
				return a - b
			end,
			mul = function(a, b)
				return a * b
			end,
			div = function(a, b)
				return a / b
			end,
			overwrite = function(a, b)
				return b or a
			end
		}
		
		--- Combines two Height maps based on the operation provided.
		-- The built-in operations are: `sum`, `sub`, `mul`, `div`.
		-- @name math.combineMaps
		-- @param Table:a The first map
		-- @param Table:b The second map
		-- @param String|Function:operation The operation to do. If the type is function, the structure needed is: `function(a, b)` and must return Int.
		-- @param Int:start In which part should it start the operation onto the first array (default = 1)
		-- @param Int:finish In which part should it stop (default = min of #a and #b)
		-- @param Int:offset Offset from map 2
		-- @return `Table` A Height Map with the processed operation
		math.combineMaps = function(a, b, operation, start, finish, offset)
			local newMap = table.copy(a)
			start = math.max(start or 1, 1)
			finish = finish or math.min(#a, #b)
			offset = offset or 0
			
			operation = operation or "add"
			local f
			if type(operation) == "function" then
				f = operation
			else
				f = op[operation] or op.add
			end
			
			for i = start, finish do
				newMap[i] = f(a[i], b[i + offset])
			end
		
			return newMap
		end
	end
	
	--- Stretches a height map, or array with numerical values.
	-- @name math.stretchMap
	-- @param Table:ls The array to stretch.
	-- @param Int:mul How much should it be stretched
	-- @return `Table` The array stretched
	math.stretchMap = function(ls, mul)
		local ex = {}
		
		local k, mod
		
		local a, b = 0, 0
		
		for i = 1, #ls * mul do
			k = ceil(i / mul)
			
			mod = (i-1) % mul
			
			if mod == 0 then
				a = b
				b = ls[k]
				
				ex[#ex + 1] = a
			else
				ex[#ex + 1] = cosint(a,	b, mod / mul)
			end
		end
		
		return ex
	end
end