function Player:setInventories()
	self.inventory:setContainersDisplay("main", {
		solve = function(index)
			index = index - 1
			return {
				targetLayer = ":99999",
				scaleX = 0.625,
				scaleY = 0.625, -- 20 px
				y = 40 + ((index % 4) * 27),
				x = 100 + (((index * 4) % 10) * 27),
				playerName = self.name,
				angle = 0,
				alpha = 1.0,
				originX = 0,
				originY = 0,
				fade = false
			}
		end
		}
	)
	
	self.inventory:setContainersDisplay("hotbar", {
		upperLimit = 5,
		solve = function(index)
			index = index - 1
			return {
				targetLayer = ":99999",
				scaleX = 0.625,
				scaleY = 0.625, -- 20 px
				y = 25 + ((index % 4) * 27),
				x = 15,
				playerName = self.name,
				angle = 0,
				alpha = 1.0,
				originX = 0,
				originY = 0,
				fade = false
			}
		end
		}
	)
	
	self.inventory:bulkFill(itemMeta.maps.dirt, false)
	self.inventory:showContainers("hotbar")
end

function Player:setMainInventoryDisplay(display)
	if display then
		self.inventory:showContainers("main")
	else
		self.inventory:hideContainers("main")
	end
end

function Player:setHotbarActive(isActive)
	self.hotbarActive = isActive
	if isActive then
		self.inventory:showContainers("hotbar")
	else
		self.inventory:hideContainers("hotbar")
	end
end

function Player:showInventory(show)
	self.showingInventory = show
	
	if self.hotbarActive == show then
		self:setHotbarActive(not show)
	end
	
	self:setMainInventoryDisplay(show)
end

do
	

	function Player:setSelectedFrame(index)
		if not self.selectedFrame then
			self.selectedFrame = SelectFrame:new(self.name)
		end
		
		
	end
end