function Player:checkEnable()
	--self.isActive = false
	
	local isValid, reason = self:assertValidity()
	
	if isValid then
		self:enable()
	else
		self:disable()
	end
	
	return self.isActive, reason
end

do
	local next = next
	local copykeys = table.copykeys
	
	local rankPerms = {
		loader = table.copykeys(enum.perms, true),
		staff = {
			damageBlock = true,
			placeBlock = true,
			useItem = nil,
			hitEntities = nil,
			mouseInteract = true,
			seeInventory = true,
			spectateWorld = true,
			joinWorld = true,
			respawn = true,
			useCommands = true,
			interfaceInteract = true,
			keyboardInteract = true
		},
		moderator = table.copykeys(enum.perms, true),
		roomAdmin = {
			damageBlock = true,
			placeBlock = true,
			useItem = true,
			hitEntities = true,
			mouseInteract = true,
			seeInventory = true,
			spectateWorld = true,
			joinWorld = true,
			respawn = true,
			useCommands = true,
			interfaceInteract = true,
			keyboardInteract = true
		},
		funcorp = table.copykeys(enum.perms, true),
	}
	
	
	function Player:setPermissions(perms)
		local rank = self:getRank()
			
		if rankPerms[rank] then
			perms = rankPerms[rank]
		end
		
		if perms then
			for permName, value in next, perms do
				self.perms[permName] = value
			end
		else
			self.perms = copykeys(enum.perms, false)
		end
	end
	
	local defaultNoPerms = {
		damageBlock = false,
		placeBlock = false,
		useItem = false,
		hitEntities = false
	}
	
	function Player:setModePermissions()
		self:setPermissions(Module.settings.defaultPerms)
	end
	
	function Player:disable()
		self.isActive = false
		self:kill()
		
		self.inventory:setView(false, false)
		
		-- These actions expect player to be alive.
		self:setPermissions(defaultNoPerms)
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
		
		self:setModePermissions()
	end
end

function Player:banDisable()
	self.isActive = false
	self:kill()
	
	self.inventory:setView(false, false)
	
	self:setPermissions(nil)
end

do
	local invalid = enum.invalidPlayerReason
	local time = os.time
	function Player:assertValidity()
		
		if self.isBanned then
			return false, invalid.banned
		else
			local room = tfm.get.room
			
			if room.isTribeHouse then
				return true
			else
				local dif = time() - self.registrationDate
				-- 60 * 60 * 1000
				local hours = (dif / 3600000)
				
				if hours < 24 then
					return false, invalid.newAccount
				else
					return true
				end
			end
		end
	end
end

function Player:checkJoin()
	if self.perms.joinWorld then
		local isValid, reason = self:checkEnable()
		if isValid then
			self:closeAllInterfaces()
			
			return true
		else
			tfm.exec.chatMessage("Not implemented.", self.name)
			return false, reason
		end
	else
		return false, enum.invalidPlayerReason.notAllowedRoom
	end
end

function Player:checkSpectate()
	self:disable()
	
	self:switchInterface("Spectator", self.perms.spectateWorld)
end

do
	local time = os.time
	local cooldowns = enum.cooldown
	function Player:checkCooldown(key)
		local currentTime = time()
		
		-- printf("%s : %d ms", key, currentTime - self.cooldown[key])
		if currentTime > self.cooldown[key] then
			self.cooldown[key] = currentTime + cooldowns[key]
			
			return true
		end
		
		return false
	end
end

function Player:__eq(other)
	return self.name == other.name
end