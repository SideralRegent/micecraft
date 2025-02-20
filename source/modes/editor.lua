Module:newMode("editor", function(this, _L)	
	Translations:set('en', "editor", {
		gcode = "Get as code",
		lcode = "Load from code",
		svacc = "Save",
		lacc = "Load",
		objsel = "Object [&val&] of type [&type&] selected.",
		svacc_conf = "Do you want to save the current world? This will overwrite your previous world.",
		lacc_conf = "Do you want to load your saved world over this map? This will overwrite the current world.",
		err_not_loaded = "File has not been yet loaded.",
		map_playable = "You can play this map on /room #micecraft &user&",
		fullscreen = "To use the editor correctly, please activate fullscreen mode."
	})	Translations:set('es', "editor", {
		gcode = "Generar código",
		lcode = "Cargar código",
		svacc = "Guardar",
		lacc = "Cargar",
		objsel = "Objeto [&val&] de tipo [&type&] seleccionado.",
		svacc_conf = "¿Deseas guardar el mundo actual? Esto sobreescribirá tu mundo anterior.",
		lacc_conf = "¿Deseas cargar tu mundo guardado sobre este mapa? Esto sobreescribirá el mundo actual.",
		err_not_loaded = "El archivo aún no se ha cargado.",
		map_playable = "Puedes jugar este mapa en /sala #micecraft &user&",
		fullscreen = "Para usar el editor correctamente, por favor activa la pantalla completa."
	})
	
	local T_WIDTH = 32
	local T_HEIGHT = 32
	local T_OFFX = T_WIDTH / 2
	local T_OFFY = T_HEIGHT / 2
	local T_X_SEP = 5
	local T_Y_SEP = 5
	local P_WIDTH = 4
	local P_HEIGHT = 8
		
	local LOFFX = 10
	local LOFFY = 30
		
	local BAR_SEP = 10
	
	local MARGIN = 5
	
	local T_OFFSET_X = LOFFX + T_OFFX + MARGIN
	local T_OFFSET_Y = LOFFY + T_OFFY + MARGIN
	
	local PANEL_WIDTH = (T_WIDTH + T_X_SEP) * P_WIDTH + MARGIN
	local PANEL_HEIGHT = (T_HEIGHT + T_Y_SEP) * P_HEIGHT + MARGIN
	
	local X_PAGE_POS = (PANEL_WIDTH / 2) + LOFFX
	local Y_PAGE_POS = (PANEL_HEIGHT / 2) + LOFFY
	
	local Y_BAR_POS = PANEL_HEIGHT + LOFFY + BAR_SEP	
		
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
						self.dx, self.dy, 
						self.owner,
						self.scale, self.scale,
						self.rotation, self.opacity,
						0.5, 0.5,
						false
					)
				end
			end
		end
		
		local iaddTextArea, removeTextArea = ui.iaddTextArea, ui.removeTextArea
		local ciaddTextArea = ui.ciaddTextArea
		local callback = ("<a href='event:%%s'>%s</a>"):format(('\n'):rep(10))
		function TilePointer:setClickable(show)
			if show then
				self.selectId = ciaddTextArea(
					callback:format(self.callback),
					self.owner,
					self.dx, self.dy,
					32, 32,
					0.5, 0.5,
					0x0, 0x0,
					0.35, true
				)
			else
				removeTextArea(self.selectId, self.owner)
			end
		end
		
		function TilePointer:setInfo(source, update)
			self.sprite = source.sprite
			self.typeId = source.id
			self.width = source.width or TEXTURE_SIZE
			self.height = source.height or TEXTURE_SIZE
			
			self.opacity = source.opacity or 1.0
			self.rotation = source.rotation or 0.0
			self.fades = not not source.fades
			
			self.scale = (TEXTURE_SIZE / math.max(self.width, self.height)) * 0.85
			
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
			self.panelId = ui.ciaddTextArea(
				"", self.owner, 
				self.dx, self.dy,
				PANEL_WIDTH, PANEL_HEIGHT,
				0.5, 0.5,
				0x010101, 0xFFFFFF,
				0.85, true
			)
			
			self.barId = ui.ciaddTextArea(
				"", self.owner, 
				self.dx, Y_BAR_POS,
				100, 0,
				0.5, 0.5,
				0x010101, 0xFFFFFF,
				0.85, true
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
		deco = setmetatable({}, meta_table),
		boxIds = {}
	}
	
	for id, element in next, blockMeta do
		if type(id) == "number" and id ~= 0 then
			EditorInterface.block:insert({id = id, sprite = element.sprite})
		end
	end
	
	do
		local obj
		for id, element in next, decoMeta do
			if type(id) == "number" and id ~= 0 then
				obj = table.copy(element)
				obj.id = id
				EditorInterface.deco:insert(obj)
			end
		end
	end
	
	do
		
		local floor = math.floor
		local positions = function(id, xOffset, yOffset)
			return 	xOffset + ((id - 1) % P_WIDTH) * (T_WIDTH + T_X_SEP),
					yOffset + floor((id - 0.5) / P_WIDTH) * (T_HEIGHT + T_Y_SEP)
		end
		
		function EditorPlayer:new(name)
			local this = setmetatable({
				name = name,
				block = Page:new(P_WIDTH * P_HEIGHT, "block", name, function(id)
					return positions(id, 800 + T_OFFSET_X, T_OFFSET_Y)
				end, 800 + X_PAGE_POS, Y_PAGE_POS),
				
				deco = Page:new(P_WIDTH * P_HEIGHT/2, "deco", name, function(id)
					local x, y = positions(id, T_OFFSET_X, T_OFFSET_Y)
					x = -x
					
					return x, y
				end, -X_PAGE_POS, Y_PAGE_POS),
				selector = {
					typeId = 0,
					typeName = "block",
				},
				loadId = -1,
				generateId = -1,
				saveTextId = -1,
				loadTextId = -1
			}, self)			this:setIndex("block", 1, false, false)
			this:setIndex("deco", 1, false, false)			return this
		end
	end
	
	function EditorPlayer:showPanels(show)
		self.block:setDisplay(show)
		self.deco:setDisplay(show)
	end
	
	
	local ff = "<font color='#FFFFFF'><p align='center'><a href='event:%s'>%s</a></p></font>"
	function EditorPlayer:showButtons(show)
		if show then
			self.generateId = ui.iaddTextArea(
				ff:format("chunk-encode-1", Translations(self.name, "editor.gcode")),
				self.name,
				705, -20,
				90, 20,
				0x010101, 0xFFFFFF,
				0.85, true
			)
			
			self.loadId = ui.iaddTextArea(
				ff:format("chunk-load-1", Translations(self.name, "editor.lcode")),
				self.name,
				5, -20,
				90, 20,
				0x010101, 0xFFFFFF,
				0.85, true
			)
			
			self.saveTextId = ui.iaddTextArea(
				ff:format("wcsaveedit", Translations(self.name, "editor.svacc")),
				self.name,
				405, -20,
				90, 20,
				0x010101, 0xFFFFFF,
				0.85, true
			)
			
			self.loadTextId = ui.iaddTextArea(
				ff:format("wcloadedit", Translations(self.name, "editor.lacc")),
				self.name,
				305, -20,
				90, 20,
				0x010101, 0xFFFFFF,
				0.85, true
			)
		else
			ui.removeTextArea(self.loadId)
			ui.removeTextArea(self.generateId)
			ui.removeTextArea(self.saveTextId)
			ui.removeTextArea(self.loadTextId)
		end
	end
	
	function EditorPlayer:showInterfaces(show)
		self:showPanels(show)
		self:showButtons(show)
	end
	
	function EditorPlayer:setIndex(type, value, increment, update)
		local page = self[type]
		
		page:setIndex(increment and value + page.index or value, EditorInterface[type], update)
	end
	
	function EditorPlayer:setSelected(type, id)
		local cell = self[type][id]
		
		self.selector.typeId = cell.typeId
		self.selector.typeName = type
	end
	
	local width, height = 25, 12
	
	function EditorInterface:newPlayer(playerName)
		self.editors[playerName] = EditorPlayer:new(playerName)
		
		self:secludePlayer(playerName)
	end
	
	function EditorInterface:removePlayer(playerName)
		self.editors[playerName] = nil
	end
	
	function EditorInterface:secludePlayer(playerName)
		tfm.exec.freezePlayer(playerName, true, false)
		tfm.exec.setPlayerGravityScale(playerName, 0, 0)
		tfm.exec.movePlayer(playerName, 400, -500, false, 0, 0, false)
	end
	
	function this:init(Map)
		Map:setVariables(32, 32, width, height, 1, 1, 0, 0)
		Map:setPhysicsMode("rectangle_detailed")
	end
	
	function this:setMap(field)		
		-- Empty.
	end
	
	function this:run()		
		Module:onUserInput("TextAreaCallback", "editorpick", function(player, type, value)
			local editor = EditorInterface.editors[player.name]
			
			editor:setSelected(type, value)
			tfm.exec.chatMessage(
				Translations(player.language, "editor.objsel", {val=value, type=type}),
				player.name
			)
		end)
	
		Module:onUserInput("TextAreaCallback", "editorpage", function(player, type, direction)
			local editor = EditorInterface.editors[player.name]
			
			editor:setIndex(type, direction == "inc" and 1 or -1, true, true)
		end)
		
		Module:onUserInput("TextAreaCallback", "wcsaveedit", function(player)
			ui.iaddPopup(
				"wsaveedit", nil, 1,
				Translations(player.language, "editor.svacc_conf"),
				player.name,
				200, 150,
				400, true
			)
		end)
	
		Module:onUserInput("TextAreaCallback", "wcloadedit", function(player)
			ui.iaddPopup(
				"wloadedit", nil, 1,
				Translations(player.language, "editor.lacc_conf"),
				player.name,
				200, 150,
				400, true
			)
		end)
	
		do
			local seen = {}
			Module:onUserInput("PopupAnswer", "wsaveedit", function(player, answer)
				if answer == "yes" then
					player:saveWorld(true)
					if not seen[player.name] then
						tfm.exec.chatMessage(
							Translations(player.language, "editor.map_playable", {user=player.name}),
							player.name
						)
						seen[player.name] = true
					end
				end
			end)
		end
	
		Module:onUserInput("PopupAnswer", "wloadedit", function(player, answer)
			if answer == "yes" then
				if player.custom then
					Map:loadFromPlayer(player)
				else
					ui.iaddPopup(
						"", nil, 0,
						Translations(player.language, "editor.err_not_loaded"), 
						player.name, 
						350, 150, 
						100, true
					)
				end
			end
		end)
	
		-- Overwrites
		Module:onUserInput("Mouse", -1, true, function(player, targetBlock, x, y)
			local editor = EditorInterface.editors[player.name]
			
			if editor then
				--if editor.selector.typeName == "deco" then
					targetBlock:getDecoTile():removeAllDisplays(true) -- 3: mdeco
				--else
					targetBlock:destroy(player, true, false, true)
				--end
			end
		end)
		
		Module:onUserInput("Mouse", mc.keys.SHIFT, true, function(player, targetBlock, x, y)
			local editor = EditorInterface.editors[player.name]
			
			if editor and editor.selector.typeId ~= 0 then
				if editor.selector.typeName == "deco" then
					local meta = decoMeta:get(editor.selector.typeId)
					targetBlock:getDecoTile():addDisplay(
						nil, nil, 
						meta.sprite, "?12", 
						0, 0, true, 
						1.0, 1.0, 
						meta.rotation, meta.opacity,
						meta.anchorX, meta.anchorY,
						true
					)
					
					local se = targetBlock:getDecoTile():serialize()
					print(#se)
					print(se)
				else
					targetBlock:create(editor.selector.typeId, true, false, true)
				end
			end
		end)
	
		Module:onUserInput("Keyboard", "ESC", true, function(player)
			local editor = EditorInterface.editors[player.name]
			
			if editor then
				editor:showInterfaces(false)
			end
		end)
	
		Module:onUserInput("Keyboard", "ESC", false, function(player)
			local editor = EditorInterface.editors[player.name]
			
			if editor then
				editor:showInterfaces(true)
			end
		end)
		
		Module:on("NewPlayer", function(playerName)
			if Room:isAdmin(playerName) then
				EditorInterface:newPlayer(playerName)
				
				local editor = EditorInterface.editors[playerName]
				editor:showInterfaces(true)
				
				tfm.exec.chatMessage(Translations(playerName, "editor.fullscreen"), playerName)
			end
			
			EditorInterface:secludePlayer(playerName)
		end)
	
		Module:on("Play", function(player)
			local editor = EditorInterface.editors[player.name]
			
			editor:showInterfaces(true)
			EditorInterface:secludePlayer(player.name)
		end)
	
		Module:on("PlayerRespawn", function(playerName)
			EditorInterface:secludePlayer(playerName)	
		end)
	
		Module:on("PlayerDied", function(playerName)
			tfm.exec.respawnPlayer(playerName)
		end)
	
		Module:on("PlayerLeft", function(playerName)
			EditorInterface:removePlayer(playerName)
		end)
		
		Module:on("NewGame", function()
			ui.setBackgroundColor("#6A7495")
			
			for playerName, _ in next, Room.playerList do
				EditorInterface:secludePlayer(playerName)
			end
		--	ui.setBackgroundColor("#5A5A5A")
		end)
	end
	
	this.settings = {
		promptsMenu = false,
		unloadDelay = math.huge,
		
		enabledPerms = {
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