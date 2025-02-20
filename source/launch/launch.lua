do 
	function Module:loadMap()		
		local spawn = Map:getSpawn()
		local width, height = Map:getMapPixelDimensions()
		
		tfm.exec.newGame(xmlLoad:format(width, height, spawn.dx, spawn.dy + 16))
	end
end

function Module:softRelaunch(schedule)
	if schedule then
		self.scheduleId = Tick:newTask(6, false, self.softRelaunch, self, false)
	else
		self.scheduleId = nil
		print("<b>Charging new map...</b>")
		
		self:loadMap()
	end
end

function Module:start()
	print("<T><b>Starting module...</b></T>")
	Room:init()
	
	local mode = self:setMode(Room.mode or "testing")	
	
	--World:init()
	debug.pmeasure("<u>World:</u> %s", World.init, World)
	
	--mode:init(Map)
	debug.pmeasure("<u>Mode:</u> %s", mode.init, mode, Map)
	
	--Map:init()
	debug.pmeasure("<u>Map:</u> %s", Map.init, Map)
	
	print("Setting room...")
	Room:setConfiguration()
	
	-- mode:run()
	debug.pmeasure("<u>Mode (run):</u> %s", mode.run, mode)
	printf("«%s» has been loaded", mode.name)
	
	if not self.settings.manualLaunch then
		print("<b>Loading map...</b>")
		self:loadMap()
	end
	
	print("Setting current players...")
	Room:initPlayers()
	
	printf("<J>Micecraft %s</J>", self.version)
end

--[[xpcall(Module.start, function(err)
	Module:throwException(true, err)
end, Module)]]
do
	local ok, result = pcall(Module.start, Module)
	
	if not ok then
		Module:throwException(true, result)
	end
end