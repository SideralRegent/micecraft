do
	local math_ceil = math.ceil
	local math_floor = math.floor
	local math_round = math.round
	local math_line = math.line
	local math_heightMap = math.heightMap
	local math_heightMapVar = math.heightMapVar
	local math_random = math.random
	local math_combineMaps = math.combineMaps
	
	local table_append = table.append
	
	local table_shift = table.shift
	
	--- Creates a terrain island.
	-- @param Table:settings Unified Field settings. See **field.lua**.
	-- @param Table:info Describes parameters for the island:
	function Field:makeIsland(settings)
		local info = settings.extra
		assert(info and info.width and info.xCenter and info.yCenter
				and info.upperPeak and info.upperShift and info.upperOctaves
				and info.lowerPeak and info.lowerShift and info.lowerOctaves,
			"One or more values expected in Field:makeIsland call."
		)
		
		local xStart = info.xCenter - math_floor(info.width / 2)
		local xEnd = info.xCenter + math_floor(info.width / 2) 
		
		local upperPeakX = (xStart - 1) + info.upperShift
		local lowerPeakX = (xStart - 1) + info.lowerShift		
		
		local raising = table_append(
			math_line(0, info.upperPeak, info.upperShift, info.yCenter, nil, nil, true),
			math_line(info.upperPeak, 0, info.width - info.upperShift + 1, info.yCenter, nil, nil, true)
		)
		
		local descending = table_append(
			math_line(0, info.lowerPeak, info.lowerShift, info.yCenter, nil, nil, true),
			math_line(info.lowerPeak, 0, info.width - info.lowerShift + 1, info.yCenter, nil, nil, true)
		)
		
		raising = math_combineMaps(raising, info.upperOctaves, "sub")
		descending = math_combineMaps(descending, info.lowerOctaves, "add")
		
		settings.limits = {
			xStart = xStart,
			xEnd = xEnd,
			
			yStart = table_shift(raising, xStart - 1),
			yEnd = table_shift(descending, xStart - 1)
		}
		
		-- Could add a setting such that you can add more custom terrain to both sides of the island.
		-- with math_combineMaps(a, b, math.min) and playing with arrays.
		-- But it would need a middle map to be defined or so, as the bound between lower and upper.
		
		self:setLayer(settings)
	end
	
	function Field:makeMountain(width, xCenter, yBase, peak, subPeaks, vibration)
		
	end
	
	local randomseed = math.randomseed
	function Field:applyBedrockLayer(size)
		size = size or 3
		
		-- randomseed(0x132B7F7) -- Magic number which provides randomness to the random seed.
		
		randomseed(os.time())
		
		local width, height = Map:getBlocks()
		
		size = math.restrict(size, 1, height - 1)
		
		local BEDROCK = blockMeta.maps.bedrock
		
		for x = 1, width do
			for y = 1 , size do
				if math_random(y) == 1 then
					self[height - (y - 1)][x] = BEDROCK
				end
			end
		end
	end
end