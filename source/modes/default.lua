Module:newMode("default", function(this, _L)
	function this:init(Map)
		Map:setVariables(
		--	X	Y
			32, 32, -- Block size (in pixels)
			12, 8, -- Chunk size (in blocks) 
			48, 24, -- World size (in chunks)
			800, 400 -- Offset (in pixels) [applies to both sides]
		)
		
		Map:setPhysicsMode("rectangle_detailed")
	end
	
	-- [[
	function this:setMap(field)
		local width, height = Map:getBlocks()
		
		--local baseMap = math.heightMap()
		
		local grassBase = math.heightMap(90, 20, width, 30, 1, height, true)
		
		--[[field:setLayer({
			overwrite = true,
			exclusive = false,
			
			limits = {
				yStart = grassBase,
				yEnd = math.heightMap(4, 9, width, 0, 3, nil, true),
				
				y_asOffset = "yEnd"
			},
			array = {
				[1] = blockMeta.maps.grass,
				[2] = blockMeta.maps.dirt
			}
		})]]
		
		--[[
		field:setLayer({
			overwrite = false,
			exclusive = {
				[VOID] = true
			},
			
			limits = {
				yStart = math.heightMap(100, 25, width, 50, 1, height, true),
				yEnd = math.heightMap(100, 25, width, 50, 1, height, true),
			},
			array = {
				[1] = blockMeta.maps.water,
			}
		})
		--]]
		-- [[
		for i = 1, 1 do
			local island_width = math.random(500, 600)
			field:makeIsland({
				overwrite = false,
				exclusive = { [VOID] = true },
				
				extra = {
					width = island_width,
					xCenter = width/2,--math.round(math.random(3) * (width/3)) - width/6,
					yCenter = height/2,--math.round(math.random(2) * (height/2)) - height/4,
					upperPeak = -70, --math.random(-60, -30),
					upperShift = (island_width/2) + math.random(-200, 200),
					lowerPeak = 70, --math.random(30, 60),
					lowerShift = (island_width/2) + math.random(-200, 200),
					
					upperOctaves = math.heightMap(6, 5, island_width, 0, nil, nil, true),
					lowerOctaves = math.heightMap(6, 5, island_width, 0, nil, nil, true),
					
					arraySeparator = math.heightMap(6, 5, island_width, 0, nil, nil, true),
					upperArray = {
						[1] = blockMeta.maps.grass,
						[2] = blockMeta.maps.dirt,
						[10] = blockMeta.maps.stone
					},
					lowerArray = {
						[1] = blockMeta.maps.mycelium,
					--	[2] = blockMeta.maps.mycelium,
						[10] = blockMeta.maps.cobblestone
					},
				--	lowerArray = {
				--		[1] = blockMeta.maps.bedrock,
				--		[3] = blockMeta.maps.lava
				--	}
				}
			})
		end
		--]]
		-- [[
		for i = 1, 5 do
			field:setLayer({
				overwrite = true,
				exclusive = nil,
				excludes = { [blockMeta.maps.water] = true},
				array = { [1] = VOID },
				limits = {
					--xEnd = width,
					yStart = math.heightMap(20, 10, width, (i*height/5)-35, nil, nil, true),
					yEnd = math.heightMap(20, 5, width, 0, nil, nil, true),
					
					y_asOffset = "yEnd"
				}
			})
		end
		--]]
		
		field:applyBedrockLayer(6)
	end
	
	function this:run()
		Module:on("NewGame", function()
			ui.setBackgroundColor("#5947A6")
			--	ui.setBackgroundColor("#6a7495")
		--	ui.setBackgroundColor("#5A5A5A")
		end)

		Module:on("PlayerDied", function(playerName)
			local player = Room:getPlayer(playerName)
			
			if player then
				player:init()
			end
		end)
	end
	
	this.settings = {
		unloadDelay = 90,
		
		disabledPerms = {
			damageBlock = false,
			placeBlock = false,
			useItem = false,
			spectateWorld = true,
			hitEntities = false,
			seeInventory = true,
			mouseInteract = false,
			joinWorld = true,
			respawn = false,
			useCommands = true,
			interfaceInteract = true,
			keyboardInteract = false,
		},
		
		enabledPerms = {
			damageBlock = true,
			placeBlock = true,
			useItem = true,
			spectateWorld = true,
			hitEntities = true,
			seeInventory = true,
			mouseInteract = true,
			joinWorld = true,
			respawn = true,
			useCommands = true,
			interfaceInteract = true,
			keyboardInteract = true
		},
		
		promptsMenu = true
	}
end)