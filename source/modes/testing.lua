Module:newMode("testing", function(this, _L)
	function this:init(Map)
		Map:setVariables(32, 32, 10, 8, 20, 25, 600, 600)
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
		
		field:applyBedrockLayer(3)
	end
	
	function this:run()
		tfm.exec.chatMessage("Test room detected.", nil)
		
		Module:on("NewGame", function()
				ui.setBackgroundColor("#6A7495")
		--	ui.setBackgroundColor("#5A5A5A")
		end)
	end
	
	this.settings = {
		defaultPerms = {
			damageBlock = true,
			placeBlock = true,
			useItem = true,
			hitEntities = true,
			
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