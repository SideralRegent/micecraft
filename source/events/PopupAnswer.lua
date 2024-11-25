do
	local empty = {}
	
	local PopupBinds = {
		list = {}
	}
	
	local PopupBind = {}
	PopupBind.__index = PopupBind
	
	local setmetatable = setmetatable
	function PopupBind:new(key, callback)
		return setmetatable({
			key = key,
			callback = callback
		}, self)
	end
	
	local pcall = pcall
	function PopupBind:trigger(player, ...)	
		local ok, result = pcall(self.callback, player, ...)
			
		if not ok then
			Module:emitWarning(mc.severity.mild, result)
		end
		
		return true
	end
	
	function PopupBinds:new(key, callback)		
		assert( type(key) == "string"
			and type(callback) == "function", 
			"Malformed eventPopupAnswer callback for key " .. tostring(key).. "."
		)
		
		self.list[key] = PopupBind:new(key, callback)
	end
	
	function PopupBinds:event(player, eventName, answer, info)
		local popupbind = self.list[eventName]
		
		if popupbind then
			popupbind:trigger(player, answer, info)
		end
	end
	
	-- === -- === -- === -- === -- === --
	
	do
		PopupBinds:new("cloadrecv", function(player, answer, chunkId)
			local chunk = Map:getChunk(chunkId, nil, CD_UID)
			
			local matrix = Map:decode(answer)
			
			if #matrix == chunk.height and #matrix[1] == chunk.width then
				Map:setMatrix(matrix, chunk.xf, chunk.yf, false, true)
				chunk:reloadPhysics()
			else
				tfm.exec.chatMessage(
					("Answer must contain a %dx%d chunk."):format(chunk.width, chunk.height),
					player.name
				)
			end			
		end)
	end
	
	Module.userInputClasses["PopupAnswer"] = PopupBinds
	
	Module:on("PopupAnswer", function(popupId, playerName, answer)
		local player = Room:getPlayer(playerName)
		
		if player and player.perms.interfaceInteract then
			local info = temp.popup[popupId] or empty
			
			PopupBinds:event(player, info[1], answer, info[2])
			
			temp.popup[popupId] = nil
		end
	end)
end