do
	local DEC --= {}
	local Tile = {}
	Tile.__index = Tile
	
	local setmetatable = setmetatable
	local next = next
	function Tile:new(dx, dy)
		return setmetatable({
			dx = dx,
			dy = dy,
			
			ncount = 6,
			
			associativeList = {},
			displayList = {},
			removalList = {},
		}, self)
	end	--- Returns a display object from the Tile, given the index, if it exists.
	-- @name Tile:getDisplay
	-- @param Any:index The identifier of the Display object
	-- @return `Object` The Display object
	-- @return `Number` The numerical index
	-- @return `String` The string index 
	local type = type
	function Tile:getDisplay(index)
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
			for _, sprite in next, self.displayList do
				rindex = #rlist + 1
				
				rlist[rindex] = addImage(
					sprite[1], sprite[2],
					sprite[3], sprite[4],
					targetPlayer,
					sprite[5], sprite[6],
					sprite[7], sprite[8],
					sprite[9], sprite[10],
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
	-- @name Tile:addDisplay
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
	-- @param Number:anchorX The horizontal anchor of the sprite
	-- @param Number:anchorY The vertical anchor of the sprite
	-- @param Boolean:show Whether the new display object should be instantly rendered
	-- @return `Int` The order of the object in the Display stack
	-- @return `String` The name of the object
	local removeImage = tfm.exec.removeImage
	local tinsert = table.insert
	function Tile:addDisplay(name, order, imageUrl, targetLayer, displayX, displayY, asOffset, scaleX, scaleY, rotation, alpha, anchorX, anchorY, show)
		if not order then
			order = self.ncount + 1
			self.ncount = order
		end
		name = name or tostring(order)
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
			anchorX or 0.0,
			anchorY or 0.0,
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
				sprite[9], sprite[10],
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
	-- @param Boolean:hide Hide all associated sprites
	function Tile:removeAllDisplays(hide)
		local keys = table.keys(self.displayList)
		
		for _, key in next, keys do
			self:removeDisplay(key, hide)
		end
		
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
					sprite[9], sprite[10],
					false
				)
			end
		else
			self:refreshDisplay()
		end
	end
	--[[
	self.displayList[order] = {
			imageUrl or "17e1315385d.png",
			targetLayer or "!100",
			displayX,
			displayY,
			scaleX or REFERENCE_SCALE_X,
			scaleY or REFERENCE_SCALE_Y,
			rotation or 0,
			alpha or 1.0,
			anchorX or 0.0,
			anchorY or 0.0,
			removeIndex = previousRemoveIndex
		}
	]]
	local tobase = math.tobase
	local tonumber = tonumber
	function Tile:serialize()
		local ser = {}
		local sin
		local code, fmt
		local layer, pos
		for _, sprite in next, self.displayList do
			code, fmt = sprite[1]:match("(%w+)%.(%w+)")
			code = tobase(tonumber(code, 16), 64)
			layer, pos = sprite[2]:match("(.)(%d+)")
			pos = tobase(pos, 64)
			sin = ("%s,%s,%s,%s,%g,%g,%g,%g,%g,%g"):format(
				("%s.%s"):format(code, fmt:sub(1,1)),
				("%s%s"):format(layer, pos),
				tobase(sprite[3], 64), tobase(sprite[4], 64),
				sprite[5], sprite[6],
				sprite[7], sprite[8],
				sprite[9], sprite[10]
			):gsub("%.0,", ","):gsub(",0%.(%d+)", ",.%1")
			
			ser[#ser+1] = sin
		end
		
		return table.concat(ser, ";")
	end
	
	DEC = Matrix:new(Tile)
	
	local fmtref = {
		p = "png",
		j = "jpg",
		w = "webp",
		g = "gif"
	}
	
	local mtonumber = math.tonumber
	function DEC:deserialize(STR)
		local ret = {}
		local obj, block, tile
		
		local sprite, layer, dx, dy, scaleX, scaleY, rotation, alpha, anchorX, anchorY
		local sp1, sp2, ly1, ly2
		for decoObj in STR:gmatch("[^;]+") do
			obj = {}
			
			for field in decoObj:gmatch("[^,]+") do
				obj[#obj + 1] = field
			end
			
			if #obj == 10 then
				sp1, sp2 = obj[1]:match("^(.-)%.(.-)$")
				obj[1] = ("%s.%s"):format(tobase(mtonumber(sp1, 64), 16):lower(), fmtref[sp2])
				ly1, ly2 = obj[2]:match("^(.)(.+)$")
				obj[2] = ("%s%s"):format(ly1, mtonumber(ly2, 64))
				obj[3] = mtonumber(obj[3], 64)
				obj[4] = mtonumber(obj[4], 64)
				obj[5], obj[6] = tonumber(obj[5]), tonumber(obj[6])
				obj[7], obj[8] = tonumber(obj[7]), tonumber(obj[8])
				obj[9], obj[10] = tonumber(obj[9]), tonumber(obj[10])
				
				ret[#ret + 1] = obj
			else
				Module:throwException(true, ("Malformed decoration string for '%s'."):format(decoObj))
			end
		end
		
		return ret
	end
	
	function DEC:setFromList(list)
		local tile, block
		for _, obj in ipairs(list) do
			block = Map:getBlock(obj[3], obj[4], CD_MAP)
			block:pulse()
			tile = self[block.y][block.x]
			tile:addDisplay(
				nil, nil, 
				obj[1], obj[2], 
				obj[3], obj[4], false, 
				obj[5], obj[6], 
				obj[7], obj[8], 
				obj[9], obj[10], 
				true
			)
		end
	end
	
	function DEC:initAt(x, y, dx, dy)
		self[y][x] = Tile:new(dx, dy)
	end
	
	function DEC:getTile(x, y)
		return self[y][x]
	end
	
	
	Map.decorations = DEC
	
	function Map:getDecoTile(x, y)
		return self.decorations[y][x]
	end
end