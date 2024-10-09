function Room:init()
	local this = tfm.get.room
	
	self.mode = nil
	self.MapSeed = 0
	self.language = this.language
	self.isTribe = this.isTribeHouse
	self.fullName = this.name or "defauñlt"
	self.isPrivate = (this.name:sub(1, 1) == "@") or this.passwordProtected--this.name:match("^@")
	
	self.isFunCorp = false
	
	self.args = {}
	do
		for arg in self.fullName:gmatch("[^%d%s]+") do
			table.insert(self.args, arg)
		end
	
		
		if #self.args >= 1 then
			if self.args[1]:find("#micecraft", 1, true) then
				self.mode = self.args[2] or "vanilla"
			
				if #self.args == 1 then
					self.MapSeed = enum.community
				else
					self.MapSeed = tonumber(self.fullName:match("#micecraft(%d+)")) or os.time()
				end
			else
				if self.isTribe then
					self.mode = self.fullName
					self.isFunCorp = false
				else
					self.isFunCorp = true
					self.mode = "funcorp"
				end
				
				self.MapSeed = 0
			end
		else
			Module:unload()
		end
	end
	
	self.presencePlayers = 0
	self.totalPlayers = 0
	self.activePlayers = 0
	self.bannedPlayers = 0
	
	
	self.playerList = {}
end

function Room:hasPlayer(playerName)
	return not not self.playerList[playerName]
end

function Room:getPlayer(playerName)
	return self.playerList[playerName]
end

function Room:initPlayers()
	for playerName, _ in next, tfm.get.room.playerList do
		_G.eventNewPlayer(playerName)
	end
end

do
	local bindMouse = system.bindMouse
	local bindKeyboard = system.bindKeyboard
	local lowerSyncDelay = tfm.exec.lowerSyncDelay
	
	function Room:newPlayer(playerName)
		if not self:hasPlayer(playerName) then
			self.playerList[playerName] = Player:new(playerName)
			
			self:getPlayer(playerName):loadData()
			
			bindMouse(playerName, true)
			
			for keyId, _ in next, enum.keys do
				bindKeyboard(playerName, keyId, true, true)
				bindKeyboard(playerName, keyId, false, true)
			end
			
			lowerSyncDelay(playerName)
			
			self.activePlayers = self.activePlayers + 1
		end
		
		self.presencePlayerList[playerName] = true
		self.presencePlayers = self.presencePlayers + 1
		
		return self:getPlayer(playerName)
	end
end

function Room:playerLeft(playerName)
	if self:hasPlayer(playerName) then
		self:getPlayer(playerName):saveData()	
		
		self.playerList[playerName] = nil
		
		self.activePlayers = self.activePlayers - 1
	end
	
	self.presencePlayerList[playerName] = nil
	self.presencePlayers = self.presencePlayers - 1
end