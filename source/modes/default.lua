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
		
		for i = 1, 15 do
			local island_width = math.random(40, 140)
			field:makeIsland({
				overwrite = false,
				exclusive = { [VOID] = true },
				
				array = {
					[1] = blockMeta.maps.grass,
					[2] = blockMeta.maps.dirt,
					[10] = blockMeta.maps.stone
				},
				
				extra = {
					width = island_width,
					xCenter = math.round(math.random(6) * (width/6)),
					yCenter = math.round(math.random(4) * (height/4)),
					upperPeak = math.random(-60, -1),
					upperShift = (island_width/2) + math.random(-30, 30),
					lowerPeak = math.random(60),
					lowerShift = (island_width/2) + math.random(-30, 30),
					
					upperOctaves = math.heightMap(6, 5, 90, 0, nil, nil, true),
					lowerOctaves = math.heightMap(6, 5, 90, 0, nil, nil, true)
					--[[info.width and info.xCenter and info.yCenter
					and info.upperPeak and info.upperShift and info.upperOctaves
					and info.lowerPeak and info.lowerShift and info.lowerOctaves]]
				}
			})
		end
		
		field:applyBedrockLayer(6)
	end
	
	function this:run()
		Module:on("NewGame", function()
			ui.setBackgroundColor("#5947A6")
			--	ui.setBackgroundColor("#6a7495")
		--	ui.setBackgroundColor("#5A5A5A")
		end)		Module:on("PlayerDied", function(playerName)
			local player = Room:getPlayer(playerName)
			
			if player then
				player:init()
			end
		end)
	end
	
	this.settings = {
		unloadDelay = 90,
		
		defaultPerms = {
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
		}
	}
end)