function Player:generateData()
	local info = {
		cw = self.custom
	}
	
	-- ...
	return info
end

function Player:loadData()
	self.awaitingData = system.loadPlayerData(self.name)
end

function Player:readData(rawdata)
	local dat = data.decode(rawdata)
	-- apply
	self.custom = dat.cw
end

do
	local encode = data.encode
	local setToModule = data.setToModule
	
	function Player:writeData()
		local info = self:generateData()
		
		local encoded = encode(info)
		
		self.dataFile = setToModule(self.dataFile, "MCR", encoded)
	end
end

do
	local savePlayerData = system.savePlayerData
	
	function Player:saveData(update)
		if update then
			self:writeData()
		end
		
		savePlayerData(self.name, self.dataFile)
	end
end

function Player:saveWorld(database)
	local chunk = Map:getChunk(1, 1, CD_MTX)
	
	self.custom = Map:encode(chunk.xf, chunk.yf, chunk.xb, chunk.yb)
	
	self:writeData()
	
	if database then
		self:saveData(false)
	end
end