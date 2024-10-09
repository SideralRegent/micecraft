function Player:new(playerName)
	local info = tfm.get.room.playerList[playerName] or {}
	
	local this = setmetatable({
		name = playerName,
		id = info.id,
		
		language = info.language,
		
		x = 0, y = 0,
		vx = 0, vy = 0,
		
		isMoving = false,
		isJumping = false,
		isFacingRight = true,
		
		isAlive = false,
		isBanned = false,
		
		currentChunk = -1,
		lastChunk = -1,
		
		keys = {},
		interface = {},
		
		inventory = PlayerInventory:new(playerName, info.id),		
		selectedFrame = SelectFrame:new(playerName, info.id),
		
		internalTime = 0,
		
		dataFile = "",
		awaitingData = false
	}, self)
	-- ...
	
	this.inventory:set()
	this:setSelectedContainer(1, this.inventory.bank, false)
	
	this:freeze(true, true, 0, 0)
	
	return this
end

function Player:init(enable)
	local this = tfm.get.room.playerList[self.name] or {}
	
	self.isMoving = false
	self.isJumping = false
	self.isFacingRight = true
	
	self.isAlive = not this.isDead
	
	self.isActive = false
	
	if enable then
		self:checkEnable()
	end
end

function Player:checkEnable()
	--self.isActive = false
	if self:assertValidity() then
		self:enable()
	else
		self:disable()
	end
	
	return self.isActive
end

function Player:enable()
	if not self.isAlive then
		self:respawn()
	end
	
	if not self.isActive then
		self.isActive = true
			
		self.inventory:setDisplay("hotbar", true)
		self:freeze(false, false)
	end
end

function Player:disable()
	self.isActive = false
	self:kill()
	
	self.inventory:setDisplay("hotbar", false)
	self.inventory:setDisplay("remainder", false)
end

function Player:assertValidity() -- TODO: Implement persistent data checking
	return not self.isBanned
end

function Player:__eq(other)
	return self.name == other.name
end