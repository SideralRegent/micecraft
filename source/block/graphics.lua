do
	--- Returns a diplay object from the Block, given the index, if it exists.
	-- @name Block:getDisplay
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
end

do
	--- Shows the Block in the Map.
	-- All Displays are shown in the order established.
	-- @name Block:display
	-- @return `Boolean` Whether it displayed or not
	local addImage = tfm.exec.addImage
	local next = next
	function Block:display(targetPlayer)
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
end

do	
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
	local addImage = tfm.exec.addImage
	local removeImage
	local tinsert = table.insert
	function Block:addDisplay(name, order, imageUrl, targetLayer, displayX, displayY, scaleX, scaleY, rotation, alpha, show)
		self.associativeList[order] = name
		self.associativeList[name] = order
		
		if self.displayList[order] then
			local previousRemoveIndex = self.displayList[order].removeIndex or -1
			removeImage(previousRemoveIndex, false)
		end
		
		self.displayList[order] = {
			imageUrl or self.sprite,
			targetLayer or (self.foreground and "!100" or "_100"),
			displayX or self.dx,
			displayY or self.dy,
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
end

do
	--- Removes a Display object from the Block
	-- @name Block:removeDisplay
	-- @param Any:index The index of the Display object
	-- @param Boolean:hide Whether the sprite attached to this display should be automatically removed
	local type
	local removeImage = tfm.exec.removeImage
	function Block:removeDisplay(index, hide)
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
	
	
	--- Removes **all** displays from a Block.
	-- @name Block:removeAllDisplays
	function Block:removeAllDisplays()
		self.displayList = {}
	end
end

do
	local removeImage = tfm.exec.removeImage
	
	--- Hides a Block and all its sprites from the map.
	-- @name Block:hide
	-- @return `Boolean` If the hiding was successful
	function Block:hide()
		local rlist = self.removalList
		
		if #rlist > 0 then
			for i = 1, #rlist do
				rlist[i] = removeImage(rlist[i], false)
			end
			
			return true
		end
		
		return false
	end
end

do
	--- Refreshes the Display of a Block
	-- All sprites are hidden and shown again.
	-- @name Block:refreshDisplay
	-- @return `Boolean` Whether it refreshed successfully or not
	function Block:refreshDisplay(targetPlayer)
		local hidden = self:hide()
		local displayed = self:display(targetPlayer)
		
		return hidden and displayed
	end
	
	local addImage = tfm.exec.addImage
	local removeImage = tfm.exec.removeImage
	
	--- Refreshes a single Display object.
	-- Same behaviour as [Block:refreshDisplay](Blocks.md#Block:refreshDisplay).
	-- @name Block:refreshDisplayAt
	-- @param Any:index The index to refresh the Display
	function Block:refreshDisplayAt(index)
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
end

--- Sets the Block default display objects.
-- These displays are:
-- 1. The main object sprite according to its type.
-- 2. The shadow sprite, in case it's in background layer.
-- @name Block:setDefaultDisplay
function Block:setDefaultDisplay(show)
	if self.type ~= blockMetadata._C_VOID then
		self:addDisplay("main", 1, self.sprite, nil, self.dx, self.dy, REFERENCE_SCALE_X, REFERENCE_SCALE_Y, 0, 1.0, show)
		
		if not self.foreground then
			self:addDisplay("shadow", 3, self.shadow, "_99999999", self.dx, self.dy, REFERENCE_SCALE_X, REFERENCE_SCALE_Y, 0, 0.33, show)
		end
	end
end