do
	local UserMenu = {}
	local template = "<font face='Consolas,Lucida Console,Monospace' size='%d' color='#%s'><p align='%s'>%s</p></font>"
	local tempcall = "<font face='Consolas,Lucida Console,Monospace' size='%d' color='#%s'><p align='%s'><a href='event:%s'>%s</a></p></font>"
	
	function UserMenu.MainMenu(playerName)
		Interface:setView()
		local scale = 1--400/1908
		-- "1926e83a199.jpg"
		Interface:addImage("19354ee0a45.jpg", ":100", 400, 200, playerName, scale, scale, 0, 1.0, 0.5, 0.5, false)
		
		local title = template:format(80, "0", "center", "Micecraft")
		local version = template:format(12, "0",  "center", 
			Translations(playerName, "version", {ver=Module.version})
		)
		
		local play = tempcall:format(
			26, "0",  "center", "play", 
			Translations(playerName, "menu.play")
		)
		local spectate = tempcall:format(
			26, "0",  "center", "spectate",
			Translations(playerName, "menu.spectate")
		)
		
		local roomSettings = tempcall:format(
			26, "0",  "center", "room_settings",
			Translations(playerName, "menu.settings")
		)
		
		
		Interface:addText(title, playerName, 0, 50, 800, 0, 0x0, 0x0, 1.0, true)
		Interface:addText(version, playerName, 0, 135, 800, 0, 0x0, 0x0, 1.0, true)
		
		Interface:addText(play, playerName, 0, 200, 800, 0, 0x0, 0x0, 1.0, true)
		Interface:addText(spectate, playerName, 0, 240, 800, 0, 0x0, 0x0, 1.0, true)
		Interface:addText(roomSettings, playerName, 0, 280, 800, 0, 0x0, 0x0, 1.0, true)
		
		local ext = template:format(9, "0", "center", os.date("<i>Nezushin#9359 - %Y</i>"))
		
		Interface:addText(ext, playerName, 0, 380, 800, 0, 0x0, 0x0, 1.0, true)
		
		return Interface:getIndex()
	end
	
	
	function UserMenu.ElementReturnMenu(playerName)
		local ret = template:format(24, "FFFFFF", "center", "<a href='event:retmainmen'>&lt;</a>")
		
		Interface:addText(ret, playerName, 5, 20, 0, 0, 0x010101, 0xFFFFFF, 1.0, true)
	end
	
	function UserMenu.Spectator(playerName, canSee)
		Interface:setView()
		
		if not canSee then
			Interface:addText("", playerName, -1000, -1000, 3000, 3000, 0x010101, 0x010101, 1.0, true)
		end
		
		Interface.UserMenu.ElementReturnMenu(playerName)
		
		return Interface:getIndex()
	end
	
	function UserMenu.RoomSettings(playerName, ...)
		Interface:setView()
		
		local scale = 0.20
		Interface:addImage("192a568cf40.jpg", ":100", 400, 200, playerName, scale, scale, 0, 1.0, 0.5, 0.5, false)
		
		--Interface:addText("", playerName, 5, 5, 790, 400, 0x010101, 0x010101, 0.40, true)
		
		Interface.UserMenu.ElementReturnMenu(playerName)
		
		local ret = template:format(72, "FFFFFF", "center", Translations(playerName, "wip"))
		
		Interface:addText(ret, playerName, 5, 150, 790, 0, 0x0, 0x0, 1.0, true)
		
		return Interface:getIndex()
	end
	
	Interface.UserMenu = UserMenu
end