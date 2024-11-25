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
		if self.perms.respawn then
			respawnPlayer(self.name)
			
			return true
		else
			return false
		end
	end
	
	function Player:placeBlock(targetBlock)
		if self.perms.placeBlock then
			if (targetBlock.type ~= 0) and (targetBlock.fluidRate == 0) then
				return false
			end
			
			if self:checkCooldown("placeBlock") then
				if self.selectedFrame:validatePointer() then
					local success = self.selectedFrame:placeItem(targetBlock, self)
					
					if success then
						targetBlock:playSound("place")
					end
					
					return success
				end
			end
		end
		
		return false
	end
	
	function Player:damageBlock(targetBlock)
		if self.perms.damageBlock then
			if targetBlock.type == 0 then return false end
			
			if self:checkCooldown("blockDamage") then
				local _, destroyed = targetBlock:damage(1, true, true, true, true, self)
				
				if destroyed then
					targetBlock:playSound("destroy")
				end
			end
		end
		
		return false
	end
	
	function Player:useItem(targetBlock, x, y)
		if self.perms.useItem then
			if self:checkCooldown("useItem") then
				self.selectedFrame:useItem(self, targetBlock, x, y)
			end
		end
	end
	
	function Player:moveItem(targetIndex)
		if not self.perms.seeInventory then return end
		
		local selector = self.selectedFrame
		local inventory = self.inventory
		if selector:validatePointer() and inventory:checkIndex(targetIndex) then
			if inventory:checkView(selector.pointer, targetIndex) then
				inventory.bank:moveItem(selector.pointer, targetIndex, true)
			end
		end
	end
	
	function Player:showInventoryAction(hotbar, remainder)
		if not self.perms.seeInventory then return end
		
		if self:checkCooldown("playerInventory") then
			self.inventory:setView(hotbar, remainder)		
			self:assertSelectorView()
		end
	end
end