do
	local template = "<font face='Consolas,Lucida Console,Monospace' size='%d' color='#%s'><p align='%s'>%s</p></font>"
	
	function Interface:MainMenu(playerName)
		self:setView()
		local scale = 0.75--400/1908
		self:addImage("1926e83a199.jpg", ":100", 400, 200, playerName, scale, scale, 0, 1.0, 0.5, 0.5, false)
		
		local title = template:format(80, "FFFFFF", "center", "Micecraft")
		local version = template:format(12, "FFFFFF",  "center", ("version %s"):format(Module.version))
		
		local play = template:format(26, "FFFFFF",  "center", "<a href='event:play'>Play</a>")
		local spectate = template:format(26, "FFFFFF",  "center","<a href='event:spectate'>Spectate</a>")
		
		local roomSettings = template:format(26, "FFFFFF",  "center","<a href='event:room_settings'>Settings</a>")
		
		
		self:addText(title, playerName, 0, 50, 800, 0, 0x0, 0x0, 1.0, true)
		self:addText(version, playerName, 0, 135, 800, 0, 0x0, 0x0, 1.0, true)
		
		self:addText(play, playerName, 0, 200, 800, 0, 0x0, 0x0, 1.0, true)
		self:addText(spectate, playerName, 0, 240, 800, 0, 0x0, 0x0, 1.0, true)
		self:addText(roomSettings, playerName, 0, 280, 800, 0, 0x0, 0x0, 1.0, true)
		
		local ext = template:format(9, "0", "center", "<i>Enjoy a random image.</i>")
		
		self:addText(ext, playerName, 0, 380, 800, 0, 0x0, 0x0, 1.0, true)
		
		return self:getIndex()
	end
	
	
	function Interface:ElementReturnMenu(playerName)
		local ret = template:format(24, "FFFFFF", "center", "<a href='event:retmainmen'>&lt;</a>")
		
		self:addText(ret, playerName, 5, 20, 0, 0, 0x010101, 0xFFFFFF, 1.0, true)
	end
	
	function Interface:Spectator(playerName, canSee)
		self:setView()
		
		if not canSee then
			self:addText("", playerName, -1000, -1000, 3000, 3000, 0x010101, 0x010101, 1.0, true)
		end
		
		self:ElementReturnMenu(playerName)
		
		return self:getIndex()
	end
	
	function Interface:RoomSettings(playerName, ...)
		self:setView()
		
		local scale = 0.20
		self:addImage("192a568cf40.jpg", ":100", 400, 200, playerName, scale, scale, 0, 1.0, 0.5, 0.5, false)
		
		--self:addText("", playerName, 5, 5, 790, 400, 0x010101, 0x010101, 0.40, true)
		
		self:ElementReturnMenu(playerName)
		
		local ret = template:format(72, "FFFFFF", "center", "On construction")
		
		self:addText(ret, playerName, 5, 150, 790, 0, 0x0, 0x0, 1.0, true)
		
		return self:getIndex()
	end
end