do
	
	function Player:closeInterface(key)
		local interface = self.interface
		if interface[key] then
			Interface:removeView(interface[key])
		end
				
		interface[key] = false
	end
	
	function Player:openInterface(key, ...)
		self:closeInterface(key)
		self.interface[key] = Interface[key](Interface, self.name, ...)
	end
	
	local tkeys = table.keys
	local next = next
	-- Inneficient
	function Player:switchInterface(name, ...)
		local interface = self.interface
		local keys = tkeys(interface)
		
		self:openInterface(name, ...)
		
		for _, key in next, keys do
			if key ~= name then
				self:closeInterface(key)
			end
		end
	end
	
	function Player:closeAllInterfaces()
		local interface = self.interface
		local keys = tkeys(interface)
		
		for _, key in next, keys do
			if interface[key] then
				Interface:removeView(interface[key])
			end
			
			interface[key] = false
		end
	end
end

function Player:promptMainMenu()
	self:disable()
	self:switchInterface("MainMenu")
end