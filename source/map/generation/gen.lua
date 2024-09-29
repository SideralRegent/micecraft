
do
	function Field:makeIsland(width, xCenter, yCenter, pLayer, nLayer)
		-- TODO: Make
	end
	
	local random = math.random
	local randomseed = math.randomseed
	function Field:applyBedrockLayer()
		randomseed(0x132B7F7) -- Magic number which provides randomness to the random seed.
		
		local width, height = Map:getBlocks()
		local BEDROCK = blockMeta.maps.bedrock
		
		for x = 1, width do
			self:assignTemplate(x, height, BEDROCK)
		end
		
		for x = 1, width do
			for y = height - 2, height - 1 do
				if random(2) == 1 then
					self:assignTemplate(x, y, BEDROCK)
				end
			end
		end
	end
end