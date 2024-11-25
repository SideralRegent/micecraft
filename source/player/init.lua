do
	local copykeys = table.copykeys
	function Player:new(playerName)
		local info = tfm.get.room.playerList[playerName] or {}
		
		local this = setmetatable({
			name = playerName,
			presenceId = 0,
			id = info.id,
			
			language = info.language,
			registrationDate = info.registrationDate,
			
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
			interface = {
				MainMenu = false,
				Spectator = false,
				RoomSettings = false
			},
			
			perms = copykeys(mc.perms, false),
			cooldown = copykeys(mc.cooldown, 0),
			
			inventory = PlayerInventory:new(playerName, info.id),		
			selectedFrame = SelectFrame:new(playerName, info.id),
			
			internalTime = 0,
			
			dataFile = "",
			awaitingData = false
		}, self)
		
		 -- Auto set
		this:setPresenceId()
		this:checkSetPermissions(mc.perms.player)
		
		this.inventory:set()
		this:setSelectedContainer(1, this.inventory.bank, false)
		
		this:freeze(true, true, 0, 0)
		
		return this
	end
end

do
	local ID = 1
	function Player:setPresenceId()
		self.presenceId = ID
		
		Room.presencePlayerList[ID] = self.name
		
		ID = ID + 1
	end
end

function Player:init(enable)
	local this = tfm.get.room.playerList[self.name] or {}
	
	self.isMoving = false
	self.isJumping = false
	self.isFacingRight = true
	
	self.isAlive = not this.isDead
	
	self.isActive = false
	
	if enable then
		Module:checkEnableUser(self)
		--self:checkEnable()
	end
end