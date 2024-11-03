do	
	local keys = enum.keys
	
	local Mousebinds = {
		keys = {}
	}
	local Mousebind = {}
	Mousebind.__index = Mousebind
	
	local setmetatable = setmetatable
	function Mousebind:new(keyId, blockOperator, callback)
		return setmetatable({
			keyId = keyId,
			isBlockOperator = blockOperator,
			callback = callback
		}, self)
	end
	
	local pcall = pcall
	function Mousebind:trigger(player, block, xPosition, yPosition)
		local goAhead = true
		if self.isBlockOperator then
			goAhead = not not block
		end
		
		if goAhead then
			local ok, result = pcall(self.callback, player, block, xPosition, yPosition)
			
			if not ok then
				Module:throwException(2, result)
			end
		end
		
		return true
	end
	
	function Mousebinds:new(keyId, blockOperator, callback)		
		self.keys[keyId] = Mousebind:new(keyId, blockOperator, callback)
	end
	
	do
		-- (-1) : No key active
		Mousebinds:new(-1, true, function(player, targetBlock)
			player:damageBlock(targetBlock)
		end)	
		
		Mousebinds:new(keys.SHIFT, true, function(player, targetBlock, x, y)
			if not player:placeBlock(targetBlock) then
				player:useItem(targetBlock, x, y)
			end
		end)
		
		Mousebinds:new(keys.one, true, function(_, block, ...)
			block:create(blockMeta.maps.stone, true, true, true)	
		end)
		
		Mousebinds:new(keys.ALT, false, function(player, _, x, y)
			player:move(x, y, false)
		end)
	
		Mousebinds:new(keys.C, true, function(player, ...)
			tfm.exec.chatMessage("This keybind is no longer supported.", player.name)
		end)
	
		Mousebinds:new(keys.M, true, function(_, block, ...)
			Map:spawnStructure("SandPiramidSmall", block.x, block.y, 0.6, 1.0, true)
		end)
	end
	
	function Mousebinds:get(keyId)
		return self.keys[keyId]
	end
	
	local next = next
	function Mousebinds:event(player, xPosition, yPosition)
		local block = Map:getBlock(xPosition, yPosition, CD_MAP)
		
		local mousebind
		
		local count = 0
		for keyId, _ in next, player.keys do
			mousebind = self:get(keyId)
			
			if mousebind then
				if mousebind:trigger(player, block, xPosition, yPosition) then
					count = count + 1
				end
			end
		end
		
		if count == 0 then
			self:get(-1):trigger(player, block, xPosition, yPosition)
		end
	end
	
	local o = os.time()
	Module:on("Mouse", function(playerName, xPosition, yPosition)
		local player = Room:getPlayer(playerName)
		
		if player and player.perms.mouseInteract then--and player.isActive and player.isAlive then
			Mousebinds:event(player, xPosition, yPosition)
		end
	end)
end