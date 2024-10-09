function Player:showMainMenu(set)
	if set then
		self.interface.menu = Interface:MainMenu(self.name)
	else
		if self.interface.menu then
			Interface:removeView(self.interface.menu)
		end
	end
end

function Player:promptMainMenu()
	self:disable()
	self:showMainMenuReturn(false)
	self:showMainMenu(true)
end

function Player:showMainMenuReturn(set)
	if set then
		self.interface.returns = Interface:MainMenuReturn(self.name)
	else
		if self.interface.returns then
			Interface:removeView(self.interface.returns)
		end
	end
end