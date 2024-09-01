do
	local addImage = tfm.exec.addImage
	function Block:display(targetPlayer)
		if self.sprite then
			self.spriteId = addImage(
				self.sprite,
				"!999999",
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
	function Block:hide()
		if self.spriteId then
			self.spriteId = removeImage(self.spriteId, false)
		end
	end
	
	function Block:setSprite(sprite, refresh)
		self.sprite = sprite or blockMetadata:get(self.type).sprite
			
		if refresh then
			self:refreshDisplay()
		end
	end
	
	function Block:refreshDisplay()
		self:hide()
		self:display()
	end
end