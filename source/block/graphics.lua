do
	local addImage = tfm.exec.addImage
	--- Displays the sprite that corresponds to this block, if any.
	-- @name Block:display
	-- @param String:targetPlayer
	function Block:display(targetPlayer)
		if self.sprite then
			self.spriteId = addImage(
				self.sprite,
				"!100",
				self.dx, self.dy,
				targetPlayer,
				REFERENCE_SCALE_X, REFERENCE_SCALE_Y,
				0, -- rotation
				1.0, -- alpha
				0, 0,
				false
			)
		end
	end
	
	local removeImage = tfm.exec.removeImage
	--- Removes the sprite from the corresponding block, if any.
	-- @name Block:hide
	function Block:hide()
		if self.spriteId then
			self.spriteId = removeImage(self.spriteId, false)
		end
	end
	
	--- Hides and shows the sprite from the block.
	-- @name Block:refreshDisplay
	function Block:refreshDisplay()
		self:hide()
		self:display()
	end
	
	--- Establishes the sprite for the designed block.
	-- @name Block:setSprite
	-- @param String:sprite The sprite URL from the Atelier801 servers
	-- @param Boolean:refresh Whether it should refresh the sprite in the world or not
	function Block:setSprite(sprite, refresh)
		self.sprite = sprite or blockMeta:get(self.type).sprite
			
		if refresh then
			self:refreshDisplay()
		end
	end
end