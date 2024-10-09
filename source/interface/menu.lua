do
	local template = "<font face='Consolas,Lucida Console,Monospace' size='%d' color='#%s'><p align='%s'>%s</p></font>"
	function Interface:MainMenu(playerName)
		self:setView()
		local scale = 1.0--400/1908
		self:addImage("1926e83a199.jpg", ":100", 400, 200, playerName, scale, scale, 0, 1.0, 0.5, 0.5, false)
		
		local title = template:format(80, "FFFFFF", "center", "Micecraft")
		local version = template:format(12, "FFFFFF",  "center", ("version %s"):format(Module.version))
		
		local play = template:format(26, "FFFFFF",  "center", "<a href='event:play'>Play</a>")
		local spectate = template:format(26, "FFFFFF",  "center","<a href='event:spectate'>Spectate</a>")
		
		
		self:addText(title, playerName, 0, 50, 800, 0, 0x0, 0x0, 1.0, true)
		self:addText(version, playerName, 0, 135, 800, 0, 0x0, 0x0, 1.0, true)
		
		self:addText(play, playerName, 0, 200, 800, 0, 0x0, 0x0, 1.0, true)
		self:addText(spectate, playerName, 0, 240, 800, 0, 0x0, 0x0, 1.0, true)
		
		self:addText(spectate, playerName, 0, 240, 800, 0, 0x0, 0x0, 1.0, true)
		
		local ext = template:format(12, "0", "center", "Enjoy a random image.")
		
		
		self:addText(ext, playerName, 0, 380, 800, 0, 0x0, 0x0, 1.0, true)
		
		return self:getIndex()
	end
	
	function Interface:MainMenuReturn(playerName)
		self:setView()
		
		local ret = template:format(12, "FFFFFF", "right", "<a href='event:retmainmen'>Return to main menu</a>")
		
		self:addText(ret, playerName, 0, 20, 800, 400, 0x0, 0x0, 1.0, true)
		
		return self:getIndex()
	end
end