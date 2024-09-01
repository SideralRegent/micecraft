do	
	local keys = enum.keys
	
	local Mousebinds = {
		keys = {}
	}
	local Mousebind = {}
	Mousebind.__index = Mousebind
	
	local setmetatable = setmetatable
	function Mousebind:new(keyId, blockOperator, callback)
		local this = setmetatable({
			keyId = keyId,
			isBlockOperator = blockOperator,
			callback = callback
		}, self)
		this.__index = self
		
		return this
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
		Mousebinds:new(-1, true, function(player, block, xPosition, yPosition)
			block:damage(24, true, true, true)
		end)	
		
		Mousebinds:new(keys.SHIFT, true, function(player, block, xPosition, yPosition)
			if block.type ~= blockMetadata.maps.bedrock then
				--if player.selected then
					--block:create(player.selected, not player.keys[enum.keys.SPACE], true, true, true)
				--end
				
				block:createAsFluidWith("10", 4, true, true, true, true)
			end
		end)
		
		Mousebinds:new(keys.one, true, function(player, block, xPosition, yPosition)
			block:create(blockMetadata.maps.stone, true, true, true)	
		end)
		
		Mousebinds:new(keys.ALT, false, function(player, _, xPosition, yPosition)
			player:move(xPosition, yPosition, false)
		end)
	
		Mousebinds:new(keys.C, true, function(player, block, xPosition, yPosition)
			tfm.exec.chatMessage("This keybind is no longer supported.", player.name)
		end)
	
		Mousebinds:new(keys.M, true, function(player, block, xPosition, yPosition)
			Map:spawnStructure("SandPiramidSmall", block.x, block.y, 0.6, 1.0)
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
	
	Module:on("Mouse", function(playerName, xPosition, yPosition)
		local player = Room:getPlayer(playerName)
		
		if player then
			Mousebinds:event(player, xPosition, yPosition)
		end
	end)
end