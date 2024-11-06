Module:newMode("editor", function(this, _L)	
	local TilePointer = {}
	TilePointer.__index = TilePointer
	
	function TilePointer:new(uniqueId, type, owner)
		return setmetatable({
			uniqueId = uniqueId,
			type = type,
			dx = 0,
			dy = 0,
			imgId = -1,
			sprite = nil,
			selectId = -1,
			typeId = 0,
			owner = owner,
			
			callback = ("editorpick-%s-%d"):format(type, uniqueId)
		}, self)
	end
	do
		local addImage = tfm.exec.addImage
		local removeImage = tfm.exec.removeImage
		function TilePointer:setImage(show)
			if self.imgId then
				self.imgId = removeImage(self.imgId, false)
			end
			
			if show then
				if self.sprite then
					self.imgId = addImage(
						self.sprite, "~10", 
						self.dx + 2, self.dy + 2, 
						self.owner,
						0.8, 0.8,
						0.0, 1.0,
						0.0, 0.0,
						false
					)
				end
			end
		end
		
		local iaddTextArea, removeTextArea = ui.iaddTextArea, ui.removeTextArea
		local callback = ("<a href='event:%%s'>%s</a>"):format(('\n'):rep(10))
		function TilePointer:setClickable(show)
			if show then
				self.selectId = iaddTextArea(
					callback:format(self.callback),
					self.owner,
					self.dx, self.dy,
					32, 32,
					0x010101, 0xFAFAFA,
					0.35, true
				)
			else
				removeTextArea(self.selectId, self.owner)
			end
		end
		
		function TilePointer:setInfo(source, update)
			self.sprite = source.sprite
			self.typeId = source.id
			
			if update then
				self:setImage(true)
			end
		end
		
		function TilePointer:setPos(dx, dy, update)
			self.dx = dx
			self.dy = dy
			
			if update then
				self:setImage(true)
				self:setClickable(false)
				self:setClickable(true)
			end
		end
	end
	
	local Page = {}
	Page.__index = Page
	
	function Page:new(tiles, type, owner, posSolver, x, y)
		local this = setmetatable({
			owner = owner,
			type = type,
			index = 1,
			maxIndex = 1,
			panelId = -1,
			barId = -1,
			dx = 0,
			dy = 0,
		}, self)
		
		for i = 1, tiles do
			this[i] = TilePointer:new(i, type, owner)
		end
		
		this:setPositions(posSolver, x, y)
		
		return this
	end
	
	function Page:setPositions(solve, x, y)
		local dx, dy
		for i = 1, #self do
			dx, dy = solve(i)
			
			self[i].setPos(self[i], dx, dy, false)
		end
		
		self.dx = x
		self.dy = y
	end
	
	function Page:inquire(source, update)
		local size = #self
		
		local start = ((self.index - 1) * #self) + 1
		local finish = #self * self.index
		local offset = start - 1
		local tile 
		
		for i = start, math.min(#source, finish) do
			tile = self[i - offset]
			
			tile:setInfo(source[i], update)
		end
	end
	
	do
		local template = "<p align='center'><font color='#FFFFFF'> %s | %d / %d | %s</font></p>"
		local cpage = "<a href='event:editorpage-%%s-%s'>%s</a>"
		local cdec = cpage:format("dec", "«")
		local cinc = cpage:format("inc", "»")
	function Page:updateInterfaceBar()
		local callback = template:format(cdec, self.index, self.maxIndex, cinc)
			:format(self.type, self.type)
		ui.updateTextArea(self.barId, callback, self.owner)
	end
	
	end
	
	function Page:setInterface(show)
		if show ~= false then
			self.panelId = ui.iaddTextArea(
				"", self.owner, 
				(self.dx - 100), self.dy,
				200, 250,
				0x010101, 0xFFFFFF,
				0.3, true
			)
			
			self.barId = ui.iaddTextArea(
				"", self.owner, 
				(self.dx - 50), self.dy + 350,
				100, 0,
				0x010101, 0xFFFFFF,
				0.3, true
			)
			
			self:updateInterfaceBar()
		else
			if self.panelId then
				self.panelId = ui.removeTextArea(self.panelId, self.owner)
			end
			
			if self.barId then
				self.barId = ui.removeTextArea(self.barId, self.owner)
			end
		end
	end
	
	function Page:setDisplay(set)
		if set ~= false then
			if set then
				self:setInterface(set)
			end
			
			for _, tile in ipairs(self) do
				tile:setImage(true)
				
				if set then
					tile:setClickable(true)
				end
			end
		else
			for _, tile in ipairs(self) do
				tile:setClickable(false)
				tile:setImage(false)
			end
			
			self:setInterface(false)
		end
	end
	
	function Page:setIndex(index, source, update)
		self.maxIndex = math.ceil(#source/#self)
		self.index = math.restrict(index, 1, self.maxIndex)
		
		self:updateInterfaceBar()
		
		self:inquire(source, update)
	end
	
	local EditorPlayer = {}
	EditorPlayer.__index = EditorPlayer
	
	local meta_table = {__index = table}
	local EditorInterface = {
		editors = {},
		block = setmetatable({}, meta_table),
		deco = setmetatable({}, meta_table)
	}
	
	for id, element in next, blockMeta do
		if type(id) == "number" then
			EditorInterface.block:insert({id = id, sprite = element.sprite})
		end
	end
	
	function EditorPlayer:new(name)
		local this = setmetatable({
			name = name,
			block = Page:new(4 * 10, "block", name, function(id)
				return 810 + (((id - 1) % 4) * 32),
					20 + math.floor((id - 0.5) / 4) * 32
			end, 820, 15),
			
			deco = Page:new(3 * 5, "deco", name, function(id)
				return -10 - (((id - 1) % 4) * 32),
					20 + math.floor((id - 0.5) / 4) * 32
			end, -120, 15),
			selector = {
				typeId = 0,
				typeName = "block"
			}
		}, self)

		this:setIndex("block", 1, false, false)
		this:setIndex("deco", 1, false, false)

		return this
	end
	
	function EditorPlayer:showPanels(show)
		self.block:setDisplay(show)
		self.deco:setDisplay(show)
	end
	
	function EditorPlayer:setIndex(type, value, increment, update)
		local page = self[type]
		
		page:setIndex(increment and value + page.index or value, EditorInterface[type], update)
	end
	
	function EditorPlayer:setSelected(type, id)
		local cell = self[type][id]
		
		self.selector.typeId = cell.id
		self.selector.typeName = type
	end
	
	local width, height = 25, 12
	
	function EditorInterface:newPlayer(playerName)
		self.editors[playerName] = EditorPlayer:new(playerName)
	end
	
	function EditorInterface:removePlayer(playerName)
		self.editors[playerName] = nil
	end

	function this:init(Map)
		Map:setVariables(32, 32, width, height, 1, 1, 0, 0)
		Map:setPhysicsMode("rectangle_detailed")
	end
	
	function this:setMap(field)		
		-- Empty.
	end
	
	function this:run()
		tfm.exec.chatMessage("Micecraft editor.")
		
		Module:onUserInput("TextAreaCallback", "editorpick", function(player, value)
			local editor = EditorInterface.editors[player.name]
			
			--editor
		end)
		Module:onUserInput("TextAreaCallback", "editorpage", function(player, type, direction)
			local editor = EditorInterface.editors[player.name]
			
			editor:setIndex(type, direction == "inc" and 1 or -1, true, true)
		end)
	
		Module:on("NewPlayer", function(playerName)
			if Room:isAdmin(playerName) then
				EditorInterface:newPlayer(playerName)
				
				local editor = EditorInterface.editors[playerName]
				editor:showPanels(true)
				print("shew")
			end
		end)
	
		Module:on("PlayerLeft", function(playerName)
			EditorInterface:removePlayer(playerName)
		end)
		
		Module:on("NewGame", function()
				ui.setBackgroundColor("#6A7495")
		--	ui.setBackgroundColor("#5A5A5A")
		end)
	end
	
	this.settings = {
		defaultPerms = {
			damageBlock = false,
			placeBlock = false,
			useItem = false,
			hitEntities = false,
			
			mouseInteract = false,
			seeInventory = false,
			spectateWorld = true,
			joinWorld = true,
			respawn = true,
			useCommands = false,
			interfaceInteract = true,
			keyboardInteract = false
		},
	}
end)