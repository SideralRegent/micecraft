Module:newMode("vanilla", function(this, g)
	function this:init(Map)
		Map:setVariables(32, 32, 12, 8, 80, 18, 0, 200)
		Map:setPhysicsMode("rectangle_detailed")
	end
	
	function this:setMap(field)
		local width, height = Map:getBlocks()
		
		local WATER_LEVEL = math.ceil((height / 2) * 1.1)
		local ICE_LEVEL = math.ceil(height * 0.33)
		
		local baseMap = math.heightMap(height * 0.6, 80, width, height * 0.4, nil, height, true) -- 24, 16, -, 60
		local baseOctaves = math.heightMap(24, 16, width, 15, nil, height, true)
		baseMap = math.combineMaps(baseMap, baseOctaves, "sub")
		local heightMap
		do
			local bwidth = 36
			local barrierLeft = math.line(
				baseMap[1], 1, 
				bwidth, 0, 
				nil, nil,
				true
			)
			local barrierRight = math.line(
				1, baseMap[width], 
				bwidth, 0, 
				nil, nil, 
				true
			)
			
			heightMap = math.combineMaps(
				baseMap, barrierLeft,
				"sub",
				1, bwidth,
				0
			)
			heightMap = math.combineMaps(
				heightMap, barrierRight, 
				"sub", 
				(width - bwidth) + 1, width,
				bwidth - width
 			)
		end
		
		field:setLayer({ -- Dirt layer
			overwrite = true,
			exclusive = false,
			dir = {
				--max = WATER_LEVEL - 1,
				[1] = {type = blockMetadata.maps.grass},
				[2] = {type = blockMetadata.maps.dirt},
				[10] = {type = -1},
			}
		}, heightMap)

		field:setLayer({
			overwrite = true,
			exclusive = true,
			dir = {
				max = ICE_LEVEL,
				[1] = {type = blockMetadata.maps.snowed_grass},
				[2] = {type = -1}
			}
		}, heightMap)

		field:setLayer({ -- Submarine layer
			overwrite = true,
			exclusive = true,
			dir = {
				min = WATER_LEVEL - 8,
				[1] = {type = blockMetadata.maps.sand},
				--[6] = {type = blockMetadata.maps.sandstone},
				[10] = {type = -1}
			}
		}, heightMap)
		
		
		local stoneOctaves = math.heightMap(4, 4, width, 3, nil, nil, true)
		local stoneLayerMap = math.combineMaps(heightMap, stoneOctaves, "add")
		field:setLayer({ -- Stone layer
			overwrite = true,
			--exclusive = true,
			dir = {
				--max = WATER_LEVEL,
				[1] = {type = blockMetadata.maps.stone}
			}
		}, stoneLayerMap)

		field:setLayer({ -- Sandstone layer
			overwrite = true,
			exclusive = true,	
			dir = {
				min = WATER_LEVEL - 5,
				[1] = {type = blockMetadata.maps.sandstone}
			}
		}, stoneLayerMap)
		
		field:setLayer({
			overwrite = false,
			exclusive = true,
			dir = {
				min = WATER_LEVEL,
				[1] = {type = blockMetadata.maps.water}
			}
		})
	
		for i = 1, 8 do
			local caveMap = math.heightMap(
				math.random(28, 40), math.random(12, 20), width, (i-1)*18, 1, height, true)
			field:setLayer({
				overwrite = true,
				dir = {
					[1] = {type=blockMetadata._C_VOID},
					[math.random(4, 6)] = {type=-1},
					excepts = {
						[blockMetadata.maps.water] = true
					}
				}
			}, caveMap)
		end
		
		do
			local x = 4
			while x < width do
				if heightMap[x] < (WATER_LEVEL - 5) then
					field:setStructure(Structures.tree, x, heightMap[x], 0.5, 1.0)
				end
				
				x = x + math.random(7, 17)
			end
		end
		field:applyBedrockLayer()
	end
	
	function this:run()
		Module:on("NewGame", function()
				ui.setBackgroundColor("#6a7495")
		--	ui.setBackgroundColor("#5A5A5A")
		end)

		Module:on("PlayerDied", function(playerName)
			local player = Room:getPlayer(playerName)
			
			if player then
				player:init()
			end
		end)
	end
	
	function this:getSettings()
		
	end
end)