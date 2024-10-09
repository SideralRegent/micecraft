Module:newMode("test", function(this, _)
	function this:init(Map)
		Map:setVariables(32, 32, 25, 12, 2, 2, 0, 0)
		Map:setPhysicsMode("rectangle_detailed")
	end
	
	function this:setMap(field)		
		local _, height = Map:getBlocks()
		
		--[[field:setLayer({
			overwrite = false,
			exclusive = true,
			dir = {
				min = 4,
				[1] = blockMeta.maps.cobblestone
			}
		})]]
		
		field:setFunction({
			overwrite = false,
			exclusive = true,
			dir = function(x, y)
				if y >= 20 then
					return blockMeta.maps.cactus
				else
					return VOID
				end
			end
		})
		--field:applyBedrockLayer()
	end
	
	function this:run()
		Module:on("NewGame", function()
				ui.setBackgroundColor("#6a7495")
		--	ui.setBackgroundColor("#5A5A5A")
		end)
--[[
		Module:on("PlayerDied", function(playerName)
			local player = Room:getPlayer(playerName)
			
			if player then
				player:init()
			end
		end)]]
	end
	
	function this:getSettings()
		
	end
end)