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
		[mc.ranks.loader] = table.copykeys(mc.perms, true),
		[mc.ranks.staff] = {
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
		[mc.ranks.moderator] = table.copykeys(mc.perms, true),
		[mc.ranks.roomAdmin] = {
			damageBlock = true,
			placeBlock = true,
			useItem = true,
			hitEntities = true,
			mouseInteract = true,
			seeInventory = nil,
			spectateWorld = true,
			joinWorld = true,
			respawn = true,
			useCommands = true,
			interfaceInteract = true,
			keyboardInteract = true
		},
		[mc.ranks.funcorp] = table.copykeys(mc.perms, true),
	}
	
	function Player:setRankPermissions()
		local rank = self:getRank()
		if rankPerms[rank] then
			self:setPermissions(rankPerms[rank])
			
			return true
		end
		
		return false
	end
	
	function Player:setPermissions(perms)
		if perms then
			for permName, value in next, perms do
				self.perms[permName] = value
			end
		else
			self.perms = copykeys(mc.perms, false)
		end
	end
	
	function Player:checkSetPermissions(perms)
		if not self:setRankPermissions() then
			self:setPermissions(perms)
		end
	end
	
	local defaultNoPerms = {
		damageBlock = false,
		placeBlock = false,
		useItem = false,
		hitEntities = false
	}
	
	function Player:setModePermissions()
		self:checkSetPermissions(Module.settings.defaultPerms)
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
				
			self:showInventoryAction(true, false)
		end
		
		self:setModePermissions()
		
		self:checkForCurrentChunk()
	end
end

function Player:banDisable()
	self.isActive = false
	self:kill()
	
	self.inventory:setView(false, false)
	
	self:setPermissions(false)
end

do
	local invalid = mc.invalidPlayerReason
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
		return false, mc.invalidPlayerReason.notAllowedRoom
	end
end

function Player:checkSpectate()
	self:disable()
	
	self:switchInterface("Spectator", self.perms.spectateWorld)
end

do
	local time = os.time
	local cooldowns = mc.cooldown
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