function Player:new(playerName)
	local info = tfm.get.room.playerList[playerName] or {}
	
	local this = setmetatable({
		name = playerName,
		
		language = info.language,
		
		x = 0,
		y = 0,
		
		vx = 0,
		vy = 0,
		
		isMoving = false,
		isJumping = false,
		isFacingRight = true,
		
		isAlive = false,
		isBanned = false,
		
		currentChunk = -1,
		lastChunk = -1,
		
		keys = {},
		
		internalTime = 0,
		
		dataFile = "",
		awaitingData = false
	}, self)

	this.__index = self
	
	return this
end

function Player:init()
-- 	local this = tfm.get.room.playerList[self.name] or {}
	
	self.isMoving = false
	self.isJumping = false
	self.isFacingRight = true
	
	self.isAlive = false
	self.isActive = false
	
	if self:assertValidity() then
		self.isActive = true
		self:respawn()
	else
		self.isActive = false
		self:kill()
	end
end

function Player:init()
	local this = tfm.get.room.playerList[self.name] or {}
	
	self.isMoving = false
	self.isJumping = false
	self.isFacingRight = true
	
	self.isAlive = not this.isDead
	self.isActive = false
	
	if self:assertValidity() then
		if not self.isAlive then
			self.isActive = true
			tfm.exec.respawnPlayer(self.name)
		end
	else
		self.isActive = false
		tfm.exec.killPlayer(self.name)
	end
end

function Player:assertValidity() -- TODO: Implement persistent data checking
	return not self.isBanned
end

function Player:__eq(other)
	return self.name == other.name
end