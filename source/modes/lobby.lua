Module:newMode("lobby", function(this, _L)
	function this:init(Map)
		Map:setVariables(32, 32, 25, 12, 1, 1, 0, 0)
		Map:setPhysicsMode("rectangle_detailed")
		
	end
	
	function this:setMap(field)		
		local _, height = Map:getBlocks()
		
		local W = blockMeta.maps.d_wood
		local S = blockMeta.maps.d_stone
		
		local matrix = {
			{S,S,S},
			{S,0,S},
			{S,S,S}
		}
		
		for i=1, 7 do
			field:setMatrix(matrix, math.random(1, 23), math.random(1, 10))
		end
		
		field:setLayer({
			overwrite = false,
			exclusive = true,
			dir = {
				min = 10,
				[1] = blockMeta.maps.cobblestone
			}
		})
		
		--[[field:setFunction({
			overwrite = false,
			exclusive = true,
			dir = function(x, y)
				if y >= 20 then
					return blockMeta.maps.cactus
				else
					return VOID
				end
			end
		}}]]
	end
	
	function this:run()
		tfm.exec.chatMessage("~ Micecraft", nil)
		
		Module:on("NewGame", function()
			ui.setBackgroundColor("#6A7495")
		end)
	end
	
	this.settings = {
		defaultPerms = {
			damageBlock = false,
			placeBlock = false,
			useItem = false,
			spectateWorld = false,
			hitEntities = false,
			seeInventory = false,
			mouseInteract = false,
			
			joinWorld = true,
			respawn = true,
			useCommands = true,
			interfaceInteract = true,
			keyboardInteract = true
		},
		
		permOverwrite = {
			-- playerName = {
			-- ...	
			--}
		},
		
		promptsMenu = false
	}
end)