do
	local Keybinds = {
		[true] = {},
		[false] = {}
	}
	local Keybind = {}
	Keybind.__index = Keybind
	
	local setmetatable = setmetatable
	
	local void = function() end
	
	function Keybind:new(keyName, keyId, down, callback)
		return setmetatable({
			keyName = keyName,
			keyId = keyId,
			down = down,
			callback = callback or void
		}, self)
	end
	
	local pcall
	function Keybind:trigger(player, ...)
		local ok, result = pcall(self.callback, player, ...)
		
		if not ok then
			Module:emitWarning(mc.severity.mild, result)
		end
	end
	
	local next, type = next, type
	
	function Keybinds:new(keyName, down, callback)
		local keyId = mc.keys[keyName]
		
		local activation
		if down == nil then
			activation = {true, false}
		else
			activation = {down}
		end
		
		local cb
		for _, boolean in next, activation do
			if type(callback) == "string" then
				cb = self[boolean][mc.keys[callback]].callback
			else
				cb = callback
			end
			self[boolean][keyId] = Keybind:new(keyName, keyId, boolean, cb)
		end
	end
	
	do
		Keybinds:new("UP", true, function(player, _, x, y, vx, vy)
			player:updateInformation(x, y, vx, vy)
		end)
		
		Keybinds:new("DOWN", true, "UP")
		
		Keybinds:new("LEFT", true, function(player, _, x, y, vx, vy)
			player:updateInformation(x, y, vx, vy, false)
		end)
	
		Keybinds:new("RIGHT", true, function(player, _, x, y, vx, vy)
			player:updateInformation(x, y, vx, vy, true)
		end)
	
		Keybinds:new("F3", true, function(_)
			print("debug")
		end)
	
		Keybinds:new("ESC", true, function(player)
			player:promptMainMenu()
		end)
	
		Keybinds:new("L", true, function(player)
			ui.showColorPicker(0x838, player.name, 0x888888, "Background Color")
		end)
	
		Keybinds:new("V", true, function(player)
			--player:queueNearChunks(nil, true)	
		end)
	
		Keybinds:new("X", true, function(player)
			if player.keys[mc.keys.SHIFT] then
				player:showInventoryAction(false, false)
			else
				player:showInventoryAction(true, nil)
			end
		end)
	
		-- Hotbar shift
		Keybinds:new("K", true, function(player)
			player:shiftHotbarSelector(-1, true)
		end)
	
		Keybinds:new("L", true, function(player)
			player:shiftHotbarSelector(1, true)
		end)
	end
	
	local kdl = { -- For list
		[true] = true,
		[false] = nil,
	}
	-- TODO: Seek ways to optimize.
	function Keybinds:event(player, keyId, down, ...)
		local pk = player.keys
		local keybind = self[down][keyId]
		
		pk[keyId] = kdl[down]
		
	--[[	if down then
			pk.last = keyId
		else
			if keyId == pk.last then
				pk.last = -1
			end
		end]]
		
		
		if keybind then
			-- keybind:trigger or keybind.callback:
			-- **trigger** uses pcall but protected call can impact on performance
			-- **callback** is more straighforward but errors can be propagated
			keybind.callback(player, down, ...)
		end
	end
	
	Module.userInputClasses["Keyboard"] = Keybinds
	
	Module:on("Keyboard", function(playerName, keyId, down, ...)
		local player = Room:getPlayer(playerName)
		
		if player and player.isActive then
			Keybinds:event(player, keyId, down, ...)
		end
	end)
end