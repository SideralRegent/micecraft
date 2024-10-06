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
			Module:throwException(2, result)
		end
		
		return true
	end
	
	function TextAreaBinds:new(key, callback)		
		self.list[key] = TextAreaBind:new(key, callback)
	end
	
	function TextAreaBinds:event(player, eventName, info)
		local textbind = self.list[eventName]
		
		if textbind then
			local a = {}
			
			for arg in info:gmatch("[^%-]+") do
				a[#a + 1] = tonumber(arg) or arg
			end
			
			textbind:trigger(player, a[1], a[2], a[3], a[4], a[5])
		end
	end
	
	do
		TextAreaBinds:new("Inv", function(player, targetPlayerName, targetSlot)
			if targetPlayerName == player.name then
				if player.keys[enum.keys.SHIFT] then
					player:moveItem(targetSlot)
				end
			
				player:setSelectedContainer(targetSlot, nil, true)
			else
				tfm.exec.chatMessage("Not implemented.", player.name)
			end
		end)
	end
	
	
	Module:on("TextAreaCallback", function(textAreaId, playerName, eventName)
		local player = Room:getPlayer(playerName)
		
		if player then
			local name, info = eventName:match("^(%a+)%-(.+)$")
			
			TextAreaBinds:event(player, name, info)
		end
	end)
end