do
	local movePlayer = tfm.exec.movePlayer
	
	function Player:move(xPosition, yPosition, positionOffset, xSpeed, ySpeed, speedOffset)
		xPosition = xPosition or 0
		yPosition = yPosition or 0
		positionOffset = positionOffset or false
		xSpeed = xSpeed or 0
		ySpeed = ySpeed or 0
		speedOffset = speedOffset or false
		
		movePlayer(
			self.name, 
			xPosition, yPosition, 
			positionOffset, 
			xSpeed, ySpeed, 
			speedOffset
		)
		
		self:updatePosition(
			positionOffset and self.x + xPosition or xPosition,
			positionOffset and self.y + yPosition or yPosition,
			speedOffset and self.vx + xSpeed or xSpeed,
			speedOffset and self.vy + ySpeed or ySpeed
		)
	end
	
	local setPlayerGravityScale = tfm.exec.setPlayerGravityScale
	local freezePlayer = tfm.exec.freezePlayer
	
	function Player:freeze(active, show, gravity, wind)
		if active and not self.isFrozen then
			setPlayerGravityScale(self.name, gravity or 1.0, wind or 1.0)
			self:move(0, 0, true, 0, 0, not (gravity or wind))
			
			freezePlayer(self.name, true, show)
			
			self.isFrozen = true
		elseif not active and self.isFrozen then
			setPlayerGravityScale(self.name, 1.0, 1.0)
			freezePlayer(self.name, false, show)
			
			self.isFrozen = false
		end
	end
	
	local killPlayer = tfm.exec.killPlayer
	
	function Player:kill()
		killPlayer(self.name)
	end
	
	local respawnPlayer = tfm.exec.respawnPlayer
	
	function Player:respawn()
		respawnPlayer(self.name)
	end
	
	function Player:setSelected(selected)
		self.selected = selected or "0"
	end
end