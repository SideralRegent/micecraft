function IEntity:updatePosition(x, y, vx, vy)
	local map = Map
	
	self.x = x or self.x
	self.y = y or self.y
	
	self.vx = vx or self.vx
	self.vy = vy or self.vy
	
	self.bx = (self.x - map.horizontalOffset) / map.blockWidth
	self.by = (self.y - map.verticalOffset) / map.blockHeight
end

function IEntity:move(xPosition, yPosition, positionOffset, xSpeed, ySpeed, speedOffset, ...)
	xPosition = xPosition or 0
	yPosition = yPosition or 0
	positionOffset = positionOffset or false
	xSpeed = xSpeed or 0
	ySpeed = ySpeed or 0
	speedOffset = speedOffset or false
	
	self.clientMove(
		self.clientIdentifier, 
		xPosition, yPosition, 
		positionOffset, 
		xSpeed, ySpeed, 
		speedOffset,
		...
	)
	
	self:updatePosition(
		positionOffset and self.x + xPosition or xPosition,
		positionOffset and self.y + yPosition or yPosition,
		speedOffset and self.vx + xSpeed or xSpeed,
		speedOffset and self.vy + ySpeed or ySpeed
	)
end

function IEntity:setClock(time, add, runEvents)
	if add then
		time = time or 500
		self.internalTime = self.internalTime + time
	else
		self.internalTime = time
	end

	if runEvents then
		self:runEvents()
	end
end

function IEntity:runEvents()

end