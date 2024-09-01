Module:newMode("test", function(this, g)
	function this:init(Map)
		Map:setVariables(32, 32, 10, 6, 20, 2, 80, 16)
		Map:setPhysicsMode("rectangle_detailed")
	end
	
	function this:setMap(field)
		local barrierGround = math.line(1, 1, 20, nil, nil, nil, true)
		
		
		local width, height = Map:getBlocks()
		
		field:setLayer({
			overwrite = false,
			exclusive = true,
			dir = {
				min = height,
				[1] = {type = blockMetadata.maps.cobblestone}
			}
		})
		
		
		--field:applyBedrockLayer()
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