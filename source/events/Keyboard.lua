do
	local Keybinds = {
		[true] = {},
		[false] = {}
	}
	local Keybind = {}
	Keybind.__index = Keybind
	
	local setmetatable = setmetatable
	
	function Keybind:new(keyName, keyId, down, callback)
		local this = setmetatable({
			keyName = keyName,
			keyId = keyId,
			down = down,
			callback = callback
		}, self)
		this.__index = self
		
		return this
	end
	
	local pcall
	function Keybind:trigger(player, ...)
		local ok, result = pcall(self.callback, player, ...)
		
		if not ok then
			Module:throwException(2, result)
		end
	end
	
	local next, type = next, type
	
	function Keybinds:new(keyName, down, callback)
		local keyId = enum.keys[keyName]
		
		local activation
		if down == nil then
			activation = {true, false}
		else
			activation = {down}
		end
		
		local cb
		for _, boolean in next, activation do
			if type(callback) == "string" then
				cb = self[boolean][enum.keys[callback]].callback
			else
				cb = callback
			end
			self[boolean][keyId] = Keybind:new(keyName, keyId, boolean, cb)
		end
	end
	
	do
		Keybinds:new("UP", true, function(player, down, x, y, vx, vy)
			player:updateInformation(x, y, vx, vy)
		end)
		
		Keybinds:new("DOWN", true, "UP")
		
		Keybinds:new("LEFT", true, function(player, down, x, y, vx, vy)
			player:updateInformation(x, y, vx, vy, false)
		end)
	
		Keybinds:new("RIGHT", true, function(player, down, x, y, vx, vy)
			player:updateInformation(x, y, vx, vy, true)
		end)
	
		Keybinds:new("F3", true, function(player)
			print("debug")
		end)
	
		Keybinds:new("L", true, function(player)
			ui.showColorPicker(0x838, player.name, 0x888888, "Background Color")
		end)
	end
	
	local kdl = {
		[true] = true,
		[false] = nil,
	}
	
	function Keybinds:event(player, keyId, down, ...)
		player.keys[keyId] = kdl[down]
		
		if down then
			player.keys.last = keyId
		else
			if keyId == player.keys.last then
				player.keys.last = -1
			end
		end
		
		local keybind = self[down][keyId]
		
		if keybind then
			-- keybind:trigger or keybind.callback?
			-- **trigger** uses pcall but protected call can impact on performance
			-- **callback** is more straighforward but errors can be propagated
			keybind.callback(player, down, ...)
		end
	end
	
	Module:on("Keyboard", function(playerName, keyId, down, ...)
		local player = Room:getPlayer(playerName)
		
		if player then
			Keybinds:event(player, keyId, down, ...)
		end
	end)
end