function Room:init()
	local this = tfm.get.room
	
	self.mode = nil
	--self.MapSeed = 0
	self.language = this.language
	self.isTribe = this.isTribeHouse
	self.fullName = this.name or ""
	self.isPrivate = (this.name:sub(1, 1) == "@") or this.passwordProtected--this.name:match("^@")
	
	self.isFunCorp = false
	
	self.ranks = {}
	self.referenceAdmin = nil
	
	self:evaluateName()
	
	self:setRank(Module.loader, "loader", true)
	
	self.presencePlayers = 0
	self.totalPlayers = 0
	self.activePlayers = 0
	self.bannedPlayers = 0
	
	
	self.playerList = {}
end

function Room:setConfiguration()
	tfm.exec.disableAfkDeath(true)
	tfm.exec.disableAutoNewGame(true)
	tfm.exec.disableAutoScore(true)
	tfm.exec.disableAutoShaman(true)
	tfm.exec.disableAutoTimeLeft(true)
	tfm.exec.disablePhysicalConsumables(true)
	system.disableChatCommandDisplay(nil)
end

function Room:evaluateName()
	local tinsert = table.insert
	self.args = {}
	
	local isNormalRoom, arguments = self.fullName:match("([%*@]?#micecraft)[%d%s_]+(.-)$")
	
	if isNormalRoom then
		local C, playerName, tag
		for arg in arguments:gmatch("[^%s]+") do
			C, playerName, tag = arg:match("^(%a)([%w_]+)#(%d%d%d%d)$")
			if C and playerName and tag then
				playerName = ("%s%s#%s"):format(C:upper(), playerName:lower(), tag)
				
				self:setRank(playerName, "roomAdmin", false)
				
				if not self.referenceAdmin then
					self.referenceAdmin = playerName
					self.mode = "personal"
				end
			else
				self.args[#self.args + 1] = arg
			end
		end
		
		if self.mode ~= "personal" then
			self.mode = self.args[1] or "default"
		end
	else
		if self.isTribe then
			self.mode = "tribehouse"
		else
			if self.fullName:match("%*?#micecraft$") then
				self.mode = "lobby"
			elseif self.fullName:find('#') then -- Not #micecraft, but still a module room
				self.mode = "testing"
			else	-- Normal room
				self.mode = "funcorp"
				self.isFuncorp = true
				Module:unload(true, "Unexpected room.")
			end
		end
	end	
end

function Room:isAdmin(playerName)
	return self.ranks[playerName] == enum.ranks.roomAdmin
end

function Room:hasPlayer(playerName)
	return not not self.playerList[playerName]
end

function Room:getPlayer(playerName)
	return self.playerList[playerName]
end

function Room:setRank(playerName, perm, overwrite)
	if perm then
		if overwrite or not self.ranks[playerName] then
			self.ranks[playerName] = enum.ranks[perm]
			printf("%s is now %s.", playerName, perm)
		end
	else
		self.ranks[playerName] = nil
	end
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
	
	local staff = {
		["0010"] = true,
		["0015"] = true,
		["0001"] = true
	}
	
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
		
		local player = self:getPlayer(playerName)
		
		self.presencePlayerList[player.presenceId] = playerName
		self.presencePlayers = self.presencePlayers + 1
		
		local name, tag = data.parseName(playerName)
		
		if staff[tag] then
			self:setRank(playerName, "staff", false)
		else
			self:setRank(playerName, "player", false)
		end
		
		return 
	end
end

function Room:playerLeft(playerName)
	if self:hasPlayer(playerName) then
		local player = self:getPlayer(playerName)
		player:saveData(true)
		self.presencePlayerList[player.presenceId] = nil
		
		
		self.activePlayers = self.activePlayers - 1
	end
	
	self:setRank(playerName, nil, true)
	self.playerList[playerName] = nil	
	
	self.presencePlayers = self.presencePlayers - 1
end