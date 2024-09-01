do
	local DEC = {}
	
	local Tile = {}
	Tile.__index = Tile
	
	local setmetatable = setmetatable
	local next = next
	function Tile:new(dx, dy)
		local this = setmetatable({
			dx = dx,
			dy = dy,
			
			associativeList = {},
			displayList = {},
			removalList = {},
		}, self)
		
		this.__index = self
	end

	--- Returns a display object from the Tile, given the index, if it exists.
	-- @name Tile:getDisplay
	-- @param Any:index The identifier of the Display object
	-- @return `Object` The Display object
	-- @return `Number` The numerical index
	-- @return `String` The string index 
	local type = type
	function Block:getDisplay(index)
		local numeric, str
		if type(index) == "string" then
			numeric = self.associativeList[index]
			str = index
		else
			numeric = index
			str = self.associativeList[index]
		end
		
		return self.displayList[numeric], numeric, str
	end
	
	--- Shows the Tile in the Map.
	-- All Displays are shown in the order established.
	-- @name Tile:display
	-- @return `Boolean` Whether it is displayed or not
	local addImage = tfm.exec.addImage
	
	function Tile:display(targetPlayer)
		if self.displayList then
			local rlist = self.removalList
			local rindex
			for index, sprite in next, self.displayList do
				rindex = #rlist + 1
				
				rlist[rindex] = addImage(
					sprite[1], sprite[2],
					sprite[3], sprite[4],
					targetPlayer,
					sprite[5], sprite[6],
					sprite[7], sprite[8],
					0, 0,
					false
				)
				sprite.removeIndex = rindex
			end
			
			return true
		end
		
		return false
	end
	
	--- Adds a new Display object to the Block.
	-- There's no check if a previous display already exists, beware of
	-- overwritting other of your displays when specifing its order.
	-- @name Block:addDisplay
	-- @param String:name The name of the Display object
	-- @param Int:order The position in the stack for it to be rendered. The stack iteration is ascending
	-- @param String:imageUrl The URL of the image in the domain `images.atelier801.com`.
	-- @param String:targetLayer The layer to show the sprite in
	-- @param Int:displayX The horizontal coordinate in the map
	-- @param Int:displayY The vertical coordinate in the map
	-- @param Number:scaleX The horizontal scale of the sprite
	-- @param Number:scaleY The vertical scale of the sprite
	-- @param Number:rotation The rotation, in radians, of the sprite
	-- @param Number:alpha The opacity of the sprite
	-- @param Boolean:show Whether the new display object should be instantly rendered
	-- @return `Int` The order of the object in the Display stack
	-- @return `String` The name of the object
	local removeImage = tfm.exec.removeImage
	local tinsert = table.insert
	function Tile:addDisplay(name, order, imageUrl, targetLayer, displayX, displayY, asOffset, scaleX, scaleY, rotation, alpha, show)
		self.associativeList[order] = name
		self.associativeList[name] = order
		
		local previousRemoveIndex
		if self.displayList[order] then
			previousRemoveIndex = self.displayList[order].removeIndex or -1
			removeImage(previousRemoveIndex, false)
		end
		
		if asOffset then
			displayX = (displayX or 0) + self.dx
			displayY = (displayY or 0) + self.dy
		else
			displayX = displayX or self.dx
			displayY = displayY or self.dy
		end
		
		self.displayList[order] = {
			imageUrl or "17e1315385d.png",
			targetLayer or "!100",
			displayX,
			displayY,
			scaleX or REFERENCE_SCALE_X,
			scaleY or REFERENCE_SCALE_Y,
			rotation or 0,
			alpha or 1.0,
			removeIndex = previousRemoveIndex
		}
		
		if show then
			local sprite = self.displayList[order]
			
			tinsert(self.removalList, addImage(
				sprite[1], sprite[2],
				sprite[3], sprite[4],
				nil,
				sprite[5], sprite[6],
				sprite[7], sprite[8],
				0, 0,
				false
			))
			
			sprite.removeIndex = #self.removalList
		end
		
		return order, name
	end
	
	--- Removes a Display object from the Tile
	-- @name Tile:removeDisplay
	-- @param Any:index The index of the Display object
	-- @param Boolean:hide Whether the sprite attached to this display should be automatically removed
	function Tile:removeDisplay(index, hide)
		local sprite, num, str = self:getDisplay(index)
		
		if sprite then
			if hide then
				removeImage(self.removalList[sprite.removeIndex] or -1, false)
			end
			
			self.displayList[num] = nil
			self.associativeList[num] = nil
			self.associativeList[str] = nil
		end
	end
	
	--- Removes **all** displays from a Tile.
	-- @name Tile:removeAllDisplays
	function Tile:removeAllDisplays()
		self.displayList = {}
	end
	
	--- Hides a Tile and all its sprites from the map.
	-- @name Tile:hide
	-- @return `Boolean` If the hiding was successful
	function Tile:hide()
		local rlist = self.removalList
		
		if #rlist > 0 then
			for i = 1, #rlist do
				rlist[i] = removeImage(rlist[i], false)
			end
			
			return true
		end
		
		return false
	end
	
	--- Refreshes the Display of a Tile
	-- All sprites are hidden and shown again.
	-- @name Tile:refreshDisplay
	-- @return `Boolean` Whether it refreshed successfully or not
	function Tile:refreshDisplay(targetPlayer)
		local hidden = self:hide()
		local displayed = self:display(targetPlayer)
		
		return hidden and displayed
	end
	
	--- Refreshes a single Display object.
	-- Same behaviour as [Tile:refreshDisplay](Map.md#Tile:refreshDisplay).
	-- @name Tile:refreshDisplayAt
	-- @param Any:index The index to refresh the Display
	function Tile:refreshDisplayAt(index)
		if index then
			local sprite = self:getDisplay(index)
			if sprite then
				sprite.removeIndex = sprite.removeIndex or (#self.removalList + 1)
				removeImage(
					self.removalList[sprite.removeIndex] or -1,
					false
				)
				
				self.removalList[sprite.removeIndex] = addImage(
					sprite[1], sprite[2],
					sprite[3], sprite[4],
					nil,
					sprite[5], sprite[6],
					sprite[7], sprite[8],
					0, 0,
					false
				)
			end
		else
			self:refreshDisplay()
		end
	end
	
	-- Tile:setDefaultDisplay doesn't apply.
	
	function DEC:initAt(x, y, dx, dy)
		self[y][x] = Tile:new(dx, dy)
	end
	
	function DEC:getTile(x, y)
		if self[y] then
			return self[y][x]
		end
	end
	
	
	Map.decorations = DEC
end