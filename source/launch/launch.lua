function Module:start()
	Room:init()
	
	local mode = self:setMode("test")--self:setMode(Room.mode)	
	
	World:init()
	mode:init(Map)
	Map:init()
	
	tfm.exec.disableAfkDeath(true)
	tfm.exec.disableAutoNewGame(true)
	tfm.exec.disableAutoScore(true)
	tfm.exec.disableAutoShaman(true)
	tfm.exec.disableAutoTimeLeft(true)
	tfm.exec.disablePhysicalConsumables(true)
	system.disableChatCommandDisplay(nil)
	
	mode:run()
	
	do
		local spawn = Map:getSpawn()
		local width, height = Map:getMapPixelDimensions()
		tfm.exec.newGame(xmlLoad:format(width, height, spawn.dx, spawn.dy))
	end
end


Module:start()
--[[xpcall(Module.start, function(err)
	Module:throwException(true, err)
end, Module)]]