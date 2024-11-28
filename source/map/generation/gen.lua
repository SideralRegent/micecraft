do
	local ceil = math.ceil
	local floor = math.floor
	local round = math.round
	local heightMap = math.heightMap
	local heightMapVar = math.heightMapVar
	local random = math.random
	
	
	-- idiom:
	-- p: positive
	-- n: negative
	-- HM: height map
	
	--- Creates a terrain island.
	-- @param Int:width Horizontal lenght of the island.
	-- @param Number:xCenter The position of the X center of the island, in the field.
	-- @param Number:yCenter Same as above, but for Y.
	-- @param Table:pLayer Information about the positive layer, format as follows:
	--[[
		pLayer = {
			overwrite = Boolean, -- If it should overwrite blocks other than void.
			
		}
	]]
	-- @param Table:nLayer Information about the negative layer. See **pLayer**.
	function Field:makeIsland(width, xCenter, yCenter, pLayer, nLayer)
		local w_width, w_height = Map:getBlocks()
		
		--local pHM = 
	end
	
	function Field:makeMountain(width, xCenter, yBase, peak, subPeaks, vibration)
		--[[local xStart = round(xCenter - width/2)
		local xEnd = round(xCenter + width/2)
		-- TODO: Finish
		local maps = {
			heightMapVar(peak.height, width, {}, truncate)
			heightMapVar(amplitude, waveLenght, width, offset, lower, higher, truncate)
			heightMap(amplitude, waveLenght, width, offset, lower, higher, truncate)
		}
		
		for i = 1
		]]
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
				if random(y) == 1 then
					self[height - (y - 1)][x] = BEDROCK
				end
			end
		end
	end
end