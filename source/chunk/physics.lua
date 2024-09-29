do
	local Segment = {}
	Segment.__index = Segment
	
	local setmetatable = setmetatable
	local ipairs,next = ipairs, next
	local abs = math.abs
	local min, max = math.min, math.max
	local copykeys = table.copykeys
	
	function Segment:new(description, block)
		local this = setmetatable({
			uniqueId = block.chunkUniqueId,
			presenceId = block.uniqueId,
			chunkId = block.chunkId,
			
			category = block.category,
			
			x = 0,
			xtl = block.dx,
			width = description.width,
			xs = description.xStart,
			xe = description.xEnd,
			
			y = 0,
			ytl = block.dy,
			height = description.height,
			ys = description.yStart,
			ye = description.yEnd,
			
			bw = block.width,
			bh = block.height,
			
			bodydef = {},
			active = false,
		}, self)
		
		this:setBlocksState(true)
		this:setBodydef()
		
		return this
	end
	
	local catinfo = {
		[enum.category.default] = {type=14, friction=0.30, restitution=0.20, collides=true, y_offset = 0}, -- Default
		[enum.category.grains] = {type=14, friction=0.5, restitution=0.00, collides=true, y_offset = 0}, -- Grains
		-- [enum.category.wood] = {type=14, friction=0.60, restitution=0.25, collides=true, y_offset = 0}, -- Wood stuff
		[enum.category.rocks_n_metals] = {type=14, friction=0.40, restitution=0.40, collides=true, y_offset = 0}, -- Rocks and Metals
		[enum.category.crystals] = {type=14, friction=0.10, restitution=0.20, collides=true, y_offset = 0}, -- Crystal
		-- [enum.category.other] = {type=14, friction=0.50, restitution=0.00, collides=true, y_offset = 0}, -- Others (leaves, wool)
		[enum.category.water] = {type=09, friction=0.00, restitution=0.00, collides=false, y_offset = 0}, -- Water
		[enum.category.lava] = {type=19, friction=2.00, restitution=500.00, collides=true, y_offset = 0}, -- Lava
		[enum.category.cobweb] = {type=15, friction=0.00, restitution=0.00, collides=false, y_offset = 0}, -- Cobweb
		[enum.category.acid]= {type=19, friction=20.0, restitution=0.00, collides=true, y_offset = 0}, -- Acid
	}
	catinfo.default = catinfo[enum.category.default]
	for _, liquid in next, {"lava", "water"} do
		local t
		for i = 1, 4 do
			t = table.copy(catinfo[enum.category[liquid]])
			t.y_offset = (4 - i) / 4
			catinfo[enum.category[("%s_%d"):format(liquid, i)]] = t
		end
	end
	
	function Segment:setBlocksState(own)
		local id = own and self.uniqueId or 0
		local bm = Map.blocks
		for y = self.ys, self.ye do
			for x = self.xs, self.xe do
				bm[y][x].segmentId = id
			end
		end
	end
	
	function Segment:setBodydef()
		local catdef = catinfo[self.category] or catinfo.default or {}
		
		local w = self.width * self.bw
		local h = (self.height - catdef.y_offset) * self.bh
		self.bodydef = {
			type = catdef.type,
			
			width = w,
			height = h,
			
			friction = catdef.friction,
			restitution = catdef.restitution,
			
			miceCollision = catdef.collides,
			groundCollision = catdef.collides,
			contactListener = catdef.collides,
			
			foreground = true,
			angle = 0,
			
			dynamic = false
		}
		
		self.x = self.xtl + (w / 2)
		self.y = self.ytl + (h / 2) + (catdef.y_offset * self.bh)
	end
	
	local addPhysicObject = tfm.exec.addPhysicObject
	local removePhysicObject = tfm.exec.removePhysicObject
	function Segment:setState(active)
		if active == nil then
			self:reload()
		else
			if active then
				addPhysicObject(self.presenceId, self.x, self.y, self.bodydef)
			else
				removePhysicObject(self.presenceId)
			end
			
			self.state = active
		end
	end
	
	local addImage, removeImage = tfm.exec.addImage, tfm.exec.removeImage
	function Segment:setDebugDisplay(display)
		if self.imageId then
			self.imageId = removeImage(self.imageId, false)
		end
		
		if display then
			self.imageId = addImage(
				"1866a699d14.png", 
				"!9999999", 
				self.x, self.y, 
				nil, 
				self.width * REFERENCE_SCALE_X,
				self.height * REFERENCE_SCALE_Y,
				0, 0.33,
				0.5, 0.5,
				false
			)
		end
	end
	
	function Segment:reload()
		self:setState(false)
		self:setState(true)
	end
	
	function Segment:free()
		self:setState(false)
		self:setDebugDisplay(false)

		local physicsMap = Map.physicsMap
		local blocksMap = Map.blocks
		for y = self.ys, self.ye do
			for x = self.xs, self.xe do
				physicsMap[y][x] = abs(physicsMap[y][x])
				blocksMap[y][x].segmentId = 0
			end
		end
		
		return self.xs, self.ys, self.xe, self.ye, self.category
	end
	
	--- Creates a new Segment object, with the description provided
	-- @name Chunk:setSegment
	-- @param Table:description The description for the Segment to be created
	function Chunk:setSegment(description)
		local segmentId = description.block.chunkUniqueId
		
		self.segments[segmentId] = Segment:new(description, description.block, self)
	end
	
	--- Deletes a Segment from the Chunk.
	-- All blocks for which this Segment was attached will be deattached
	-- and their physic state will be reset.
	-- @name Chunk:deleteSegment
	-- @param Int:segmentId The identifier of the Segment
	-- @return `Int` The left-most block coordinate of the Segment
	-- @return `Int` The top-most coordinate
	-- @return `Int` The right-most coordinate
	-- @return `Int` The down-most coordinate
	-- @return `Int` The category that this segment had
	function Chunk:deleteSegment(segmentId)
		local segment = self.segments[segmentId]
		local xStart, yStart, xEnd, yEnd, category
		if segment then
			xStart, yStart, xEnd, yEnd, category = segment:free()
		end
		
		self.segments[segmentId] = nil
		
		return xStart, yStart, xEnd, yEnd, category
	end
	
	--- Gets the collisions from a Chunk.
	-- For blocks that don't have a segment assigned, it will calculate
	-- their collisions and assign them a new Segment.
	-- @name Chunk:getCollisions
	-- @param String:mode The coordinate calculation mode
	-- @param Int:xStart The left-most block coordinates to calculate
	-- @param Int:xEnd The right-most coordinates
	-- @param Int:yStart The top-most coordinates
	-- @param Int:yEnd The down-most coordinates
	-- @param Table:categories A list with the categories that should be matched
	-- @return `Table` A list with new Segments created
	function Chunk:getCollisions(mode, xStart, xEnd, yStart, yEnd, categories)
		mode = mode or "rectangle_detailed"
		
		-- here
		local seglist = Map.physicsMap[mode](Map.physicsMap,
			xStart or self.xf,
			xEnd or self.xb,
			yStart or self.yf,
			yEnd or self.yb,
			categories or self.lc
		)
		
		local newEntries = {}
		for _, segment in ipairs(seglist) do
			self:setSegment(segment)
			newEntries[segment.block.chunkUniqueId] = true
		end
		
		return newEntries
	end
	
	
	--- Sets the state for the physics of the Chunk or some of its segments.
	-- @name Chunk:setPhysicState
	-- @param Boolean:active Whether the collisions should be active or not
	-- @param Table:segmentList An associative list with the Segments that should change their physic state
	-- @return `Boolean` The state of the physics in the Chunk
	function Chunk:setPhysicState(active, segmentList)
		if segmentList then
			if active == self.collisionActive then
				local segment
				
				for segmentId, _ in next, segmentList do
					segment = self.segments[segmentId]
					
					if segment then
						segment:setState(active)
					end
				end
			end
		else
			for _, segment in next, self.segments do
				segment:setState(active)
			end
			
			self.collisionActive = active
			
			if not active then
				self.collidesTo = {}
			end
			
			Map:setCounter("chunks_collide", self.collisionActive and 1 or -1, true)
		end
		
		return self.collisionActive
	end
	
	--- Recalculates the collisions of the given segments, or the whole chunk.
	-- @name Chunk:refreshPhysics
	-- @param String:mode The algorithm to calculate collisions with
	-- @param Table:segmentList An associative Table with all the segments that need their physics to be reloaded
	-- @param Boolean:update Whether 
	-- @param Table:origin A table with the strucutre `{xStart=Int, xEnd=Int, yStart=Int, yEnd=Int, category=Int}` that corresponds to the Block(s) that asked for refresh
	function Chunk:refreshPhysics(mode, segmentList, update, origin)
		segmentList = segmentList or copykeys(self.segments, true)
		
		local xs, ys, xe, ye, catlist = self.xb, self.yb, self.xf, self.yf, {}
		if origin then
			xs = origin.xStart
			xe = origin.xEnd
			ys = origin.yStart
			ye = origin.yEnd
			catlist[origin.category] = true
		end
		
		local xStart, yStart, xEnd, yEnd, category
		for segmentId, _ in next, segmentList do
			xStart, yStart, xEnd, yEnd, category = self:deleteSegment(segmentId)
			if xStart and yStart and xEnd and yEnd and category then
				if category ~= 0 then
					catlist[category] = true
				end
				
				xs = min(xs, xStart)
				ys = min(ys, yStart)
				xe = max(xe, xEnd)
				ye = max(ye, yEnd)
			end
		end
		
		local list = self:getCollisions(mode, xs, xe, ys, ye, catlist)
		
		if update then
			self:setPhysicState(true, list)
		end
	end
	
	--- Empties a Chunk.
	-- All blocks from this Chunk will become **void**, their displays
	-- will be hidden and it will not have collisions.
	-- @name Chunk:clear
	function Chunk:clear()
		local matrix = Map.blocks
		for y = self.yf, self.yb do
			for x = self.xf, self.xb do
				matrix[y][x]:setVoid()
			end
		end
		
		for _, segment in next, self.segments do
			segment:free()
		end
		
		self.segments = {}
	end
end