function Player:generateData()
	
end

function Player:loadData()
	self.awaitingData = system.loadPlayerData(self.name)
end

function Player:readData(rawdata)
	table.print(rawdata)
--	local dat = data.decode(rawdata)
	
	-- apply
end

function Player:writeData(save)
	local dat = {
		-- ...
	}
	
	local encoded = data.encode(dat)
	self.dataFile = data.setToModule(self.dataFile, "MCR", encoded)
	
	if save then
		self:saveData(false)
	end
end

function Player:saveData(generate)
	if generate or self.dataFile == "" then
		self:generateData(false)
	end
	
	system.savePlayerData(self.name, self.dataFile)
end