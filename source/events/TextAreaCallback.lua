do
	local TextAreaBinds = {
		list = {}
	}
	local TextAreaBind = {}
	TextAreaBind.__index = TextAreaBind
	
	local setmetatable = setmetatable
	function TextAreaBind:new(key, callback)
		return setmetatable({
			key = key,
			callback = callback
		}, self)
	end
	
	local pcall = pcall
	function TextAreaBind:trigger(player, ...)	
		local ok, result = pcall(self.callback, player, ...)
			
		if not ok then
			Module:emitWarning(mc.severity.mild, result)
		end
		
		return true
	end
	
	function TextAreaBinds:new(key, callback)		
		assert( type(key) == "string"
			and type(callback) == "function", 
			"Malformed eventTextAreaCallback callback for key " .. tostring(key).. "."
		)
		self.list[key] = TextAreaBind:new(key, callback)
	end
	
	function TextAreaBinds:event(player, eventName, info)
		local textbind = self.list[eventName]
		
		if textbind then
			local a = {}
			
			if info then
				for arg in info:gmatch("[^%-]+") do
					a[#a + 1] = tonumber(arg) or arg
				end
			end
			
			textbind:trigger(player, a[1], a[2], a[3], a[4], a[5])
		end
	end
	
	-- === -- === -- === -- === -- === --
	
	do
		TextAreaBinds:new("Inv", function(player, targetPlayerName, targetSlot)
			if targetPlayerName == player.name then
				if player.keys[mc.keys.SHIFT] then
					player:moveItem(targetSlot)
				end
			
				player:setSelectedContainer(targetSlot, nil, true)
			else
				tfm.exec.chatMessage("Not implemented.", player.name)
			end
		end)
	
		TextAreaBinds:new("play", function(player, ...)
			local joined, reason = player:checkJoin()
			
			if not joined then
				tfm.exec.chatMessage("You can't join this game, reason: " .. reason, player.name)
			else
				Module:trigger("Play", player, ...)
			end
		end)
		
		TextAreaBinds:new("spectate", function(player, ...)
			player:checkSpectate()
		end)
	
		TextAreaBinds:new("retmainmen", function(player, ...)
			player:switchInterface("MainMenu")
		end)
	
		TextAreaBinds:new("room_settings", function(player, ...)
			player:switchInterface("RoomSettings")
		end)
	
		TextAreaBinds:new("iclose", function(player, index)
			Interface:removeView(index)
		end)
	
		TextAreaBinds:new("chunk", function(player, action, id)
			if action == "encode" then
				local chunk = Map:getChunk(id, nil, CD_UID)
				
				tfm.exec.chatMessage(
					("<CS>%s</CS>"):format(Map:encode(chunk.xf, chunk.yf, chunk.xb, chunk.yb)), 
					player.name
				)
			elseif action == "load" then
				ui.iaddPopup(
					"cloadrecv", -- chunk load receiver
					id, 2,
					"Input chunk decodable.",
					player.name, 
					300, 175,
					200, true
				)
			end
		end)
	end
	
	Module.userInputClasses["TextAreaCallback"] = TextAreaBinds
	
	Module:on("TextAreaCallback", function(textAreaId, playerName, eventName)
		local player = Room:getPlayer(playerName)
		
		if player and player.perms.interfaceInteract then
			local name, info = eventName:match("^([_%a]+)%-(.+)$")
			name = name or eventName
			TextAreaBinds:event(player, name, info)
		end
	end)
end