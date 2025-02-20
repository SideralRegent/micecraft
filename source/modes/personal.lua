Module:newMode("personal", function(this, _L)
	function this:init(Map)
		Map:setVariables(32, 32, 25, 12, 1, 1, 0, 0)
		Map:setPhysicsMode("rectangle_detailed")
	end
	
	function this:setMap(field)		
		local _, height = Map:getBlocks()
		Field:setLayer({
			overwrite = true,
			exclusive = nil,
			limits = {
				yStart = height,
				yEnd = height
			},
			array = {
				[1] = blockMeta.maps.cobblestone
			}
		})
	end
	
	function this:run()		
		Module:on("NewGame", function()
				ui.setBackgroundColor("#6A7495")
		--	ui.setBackgroundColor("#5A5A5A")
		end)		
		
		Module:on("PlayerDataLoaded", function(playerName, playerData)
			-- Assumes data has been already processed by the main event
			if playerName == Room.referenceAdmin then
				local player = Room:getPlayer(Room.referenceAdmin)
			
				if player.custom then
					Map:loadFromPlayer(player)
					Module:loadMap()
				end
			end
		end)
	
		Tick:newTask(60, true, function()
			local player = Room:getPlayer(Room.referenceAdmin)
			
			if player then
				player:saveWorld(true)
			end
		end)
	end
	
	this.settings = {
		unloadDelay = math.huge,
		manualLaunch = true,
		
		enabledPerms = {
			damageBlock = false,
			placeBlock = false,
			useItem = false,
			hitEntities = false,
			
			mouseInteract = true,
			seeInventory = true,
			spectateWorld = true,
			joinWorld = true,
			respawn = true,
			useCommands = true,
			interfaceInteract = true,
			keyboardInteract = true
		},
	}
end)