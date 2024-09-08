function World:setTime(time, add, display)
	time = time or 0750
	
	if add then
		time = self.currentTime + time
	end
	
	self.currentTime = ((time - 1) % 2400) + 1
	
	--[[if display and self.currentTime % 5 == 0 then
		self:setSkyColor()
	end]]
end

function World:setSkyColor()
	local cl = self.skyColors[self.currentTime]
	ui.setBackgroundColor(("#%x"):format(cl or 0x6A7495))
end

function World:stepTime()
	self:setTime(1, true, true)
end