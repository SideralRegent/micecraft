
do
	local ceil = math.ceil
	local floor = math.floor
	local round = math.round
	local heightMap = math.heightMap
	local heightMapVar = math.heightMapVar
	local random = math.random
	
	function Field:makeIsland(width, xCenter, yCenter, pLayer, nLayer)
		-- TODO: Make
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
	
	local random = math.random
	local randomseed = math.randomseed
	function Field:applyBedrockLayer(size)
		size = size or 3
		
		randomseed(0x132B7F7) -- Magic number which provides randomness to the random seed.
		
		local width, height = Map:getBlocks()
		local BEDROCK = blockMeta.maps.bedrock
		
		for x = 1, width do
			for y = 1 , size do
				if random(y) == 1 then
					self:assignTemplate(x, height - (y - 1), BEDROCK)
				end
			end
		end
	end
end