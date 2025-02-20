do
	local math_ceil = math.ceil
	local math_floor = math.floor
	local math_round = math.round
	local math_line = math.line
	local math_heightMap = math.heightMap
	local math_heightMapVar = math.heightMapVar
	local math_random = math.random
	local math_combineMaps = math.combineMaps
	
	local table_appendt = table.appendt
	
	local table_shift = table.shift
	
	--- Creates a terrain island.
	-- @param Table:settings Unified Field settings. See **field.lua**.
	-- @param Table:info Describes parameters for the island:
	function Field:makeIsland(settings)
		local info = settings.extra
		assert(info and info.width and info.xCenter and info.yCenter
				and info.upperPeak and info.upperShift and info.upperOctaves
				and info.lowerPeak and info.lowerShift and info.lowerOctaves
				and not (info.arraySeparator and not info.upperArray),
			"One or more values expected in Field:makeIsland call."
		)
		
		info.upperShift = math_round(info.upperShift)
		info.lowerShift = math_round(info.lowerShift)
		
		local xStart = math_round(info.xCenter - (info.width / 2))
		local xEnd = xStart + info.width - 1
		--local xEnd = math_round(info.xCenter + (info.width / 2))
		
		local raising = table_appendt(
			info.width,
			math_line(0, info.upperPeak, info.upperShift, info.yCenter, nil, nil, true),
			math_line(info.upperPeak, 0, info.width - info.upperShift, info.yCenter, nil, nil, true)
		)
		
		local descending = table_appendt(
			info.width,
			math_line(0, info.lowerPeak, info.lowerShift, info.yCenter, nil, nil, true),
			math_line(info.lowerPeak, 0, info.width - info.lowerShift, info.yCenter, nil, nil, true)
		)	
		
		
		raising = math_combineMaps(raising, info.upperOctaves, "sub")
		raising = table_shift(raising, xStart - 1)
		
		descending = math_combineMaps(descending, info.lowerOctaves, "add")
		descending = table_shift(descending, xStart - 1)
		
		if info.arraySeparator then
			info.arraySeparator = table.forValues(info.arraySeparator, nil, nil, function(v)
				return v + info.yCenter
			end)
			info.arraySeparator = table_shift(info.arraySeparator, xStart - 1)
			
			-- Lower
			settings.array = info.lowerArray
			info.inverse = true
			settings.limits = {
				xStart = xStart,
				xEnd = xEnd,
				yStart = info.arraySeparator,
				yEnd = descending
			}
			settings.extra = info
			self:setLayer(settings)
			
			-- Upper
			settings.array = info.upperArray
			info.inverse = false
			settings.limits = {
				xStart = xStart,
				xEnd = xEnd,
				yStart = raising,
				yEnd = info.arraySeparator
			}
			settings.extra = info
			self:setLayer(settings)
		else
			settings.limits = {
				xStart = xStart,
				xEnd = xEnd,
				
				yStart = raising,
				yEnd = descending
			}
			self:setLayer(settings)
		end
	end
	
	
	function Field:makeMountain(width, xCenter, yBase, peak, subPeaks, vibration)
		-- Todo
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