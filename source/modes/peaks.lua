Module:newMode("peaks", function(this, _L)
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
		
		local grassBase = math.heightMap(height, 4, width, 1, 1, height, true)
		
		field:setLayer({
			overwrite = true,
			exclusive = false,
			
			limits = {
				yStart = grassBase,
				--yEnd = math.heightMap(4, 9, width, 0, 3, nil, true),
				
				--y_asOffset = "yEnd"
			},
			array = {
				[1] = blockMeta.maps.grass,
				[2] = blockMeta.maps.dirt,
				[8] = blockMeta.maps.stone
			}
		})
		
		
		field:setLayer({
			overwrite = false,
			exclusive = {
				[VOID] = true
			},
			
			limits = {
				yStart = math.heightMap(25, 75, width, height/2, 1, height, true),
				--yEnd = math.heightMap(100, 25, width, 50, 1, height, true),
			},
			array = {
				[1] = blockMeta.maps.lava,
			}
		})
		--]]
		
		
		field:applyBedrockLayer(6)
	end
	
	function this:run()
		Module:on("NewGame", function()
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
		}
	}
end)