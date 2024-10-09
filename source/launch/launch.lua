function Module:loadMap()
	local spawn = Map:getSpawn()
	local width, height = Map:getMapPixelDimensions()
	
	tfm.exec.newGame(xmlLoad:format(width, height, spawn.dx, spawn.dy))
end

function Module:start()
	print("<T>Starting module...</T>")
	Room:init()
	
	--local mode = self:setMode(Room.mode)
	local mode = self:setMode("test")	
	
	debug.pmeasure("World: %s", World.init, World)
	--World:init()
	debug.pmeasure("Mode: %s", mode.init, mode, Map)
	--mode:init(Map)
	--Map:init()
	debug.pmeasure("Map: %s", Map.init, Map)
	
	
	print("<b>Setting room...</b>")
	
	tfm.exec.disableAfkDeath(true)
	tfm.exec.disableAutoNewGame(true)
	tfm.exec.disableAutoScore(true)
	tfm.exec.disableAutoShaman(true)
	tfm.exec.disableAutoTimeLeft(true)
	tfm.exec.disablePhysicalConsumables(true)
	system.disableChatCommandDisplay(nil)
	
	debug.pmeasure("Mode (run): %s", mode.run, mode)
	
	print("<b>Loading map...</b>")
	
	self:loadMap()
	
	printf("<J>Micecraft %s</J>", self.version)
	
	Room:initPlayers()
end


Module:start()
--[[xpcall(Module.start, function(err)
	Module:throwException(true, err)
end, Module)]]