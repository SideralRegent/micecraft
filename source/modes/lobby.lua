Module:newMode("lobby", function(this, _L)
	function this:init(Map)
		Map:setVariables(32, 32, 25, 12, 1, 1, 0, 0)
		Map:setPhysicsMode("rectangle_detailed")
		
	end
	local MAP_STR = "0|4,4,0|20;0|25;0|2,4|5,0|3,4|2,0|2,4|4,0|6,2;0|2,4,0|3,4,0|9,1d1,0|6,2,1;0|15,1d1,0|3,2|4,1|2;0|14,1d1,0|3,2,1|6;0|7,6,0|5,1d1,0|4,1,2d1|6;0|7,6,0|2,2|2,0,1,1d1,0|9,2d1;10|6,5|2,2|2,1|2,2,1|2,1d1,0|8,2d1;5|2,10|3,5|2,3,1|8,1d1|3,3d3,3|2,10d1|2,3;5d1|2,5,10,5,5d1|2,3d5,3d1|2,1|8,3|2,3d4,3,10d1|2,3;5d1|6,3|3,3d3,3,1|3,3d5,3|8,3d2|2_NtKjojT.p,!5zU3!,5W,1G,1,1,0,1,0,.0;PCwJg@l.p,?C,60,2m,1,1,0,1,.5,.5"
	
	local blocks, decos = Map:decode(MAP_STR)
	
	function this:setMap(field)		
		local _, height = Map:getBlocks()
		field:setMatrix(blocks, 1, 1)
	end
	
	function this:run()
		Map.decorations:setFromList(decos)
		tfm.exec.chatMessage("<i>Micecraft !</i>", nil)
		
		Module:on("NewGame", function()
			ui.setBackgroundColor("#6A7495")
		end)
	
		Module:on("PlayerDied", function(playerName)
			tfm.exec.respawnPlayer(playerName)
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
			-- playerRank = {
			-- ...	
			--}
		},
		
		promptsMenu = false,
		
		unloadDelay = math.huge
	}
end)