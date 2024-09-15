Module:newMode("test", function(this, _)
	function this:init(Map)
		Map:setVariables(32, 32, 2, 2, 30, 20, 0, 0)
		Map:setPhysicsMode("rectangle_detailed")
	end
	
	function this:setMap(field)		
		local _, height = Map:getBlocks()
		
		--[[field:setLayer({
			overwrite = false,
			exclusive = true,
			dir = {
				min = 4,
				[1] = blockMetadata.maps.cobblestone
			}
		})]]
		
		field:setFunction({
			overwrite = false,
			exclusive = true,
			dir = function(x, y)
				if x % 3 == 0 then
					if y % 4 == 0 then
						return blockMetadata.maps.cobblestone
					end
				else
					if (y + 2) % 4 == 0 then
						return blockMetadata.maps.cobblestone
					end
				end
				
				return VOID
			end
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