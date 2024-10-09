function SelectFrame:new(playerName)
	return setmetatable({
		owner = playerName,
		pointer = 1,
		dTarget = nil,
		pObj = nil,
		bank = {},
		cursor_id = nil,
	}, self)
end

function SelectFrame:validatePointer()
	self.pObj = self.bank.containers[self.pointer]
	
	return not not self.pObj
end

function SelectFrame:setReferenceBank(bank)
	self.bank = bank
end

function SelectFrame:setPointer(index, dTarget)
	self.pointer = index or 1
	self.dTarget = dTarget
	
	return self:validatePointer()
end

do
	local restrict = math.restrict
	function SelectFrame:shiftPointer(value, lower, upper, dTarget)
		lower = lower or 1
		upper = upper or #self.bank.containers
		
		local distance = (upper - lower) + 1
		
		local index = lower + ((self.pointer + value - lower) % distance)
				
		return self:setPointer(index, dTarget)
	end
end

do
	local removeImage = tfm.exec.removeImage
	local addImage = tfm.exec.addImage
	function SelectFrame:setView(show)
		if self.cursor_id then
			self.cursor_id = removeImage(self.cursor_id, false)
		end
		
		if show and self:validatePointer() then
			local d = self.pObj:getActiveDisplay(self.dTarget)
			
			if d then
				self.cursor_id = addImage(
					"1923e974792.png",
					d.targetLayer,
					d.x, d.y,
					d.playerName,
					d.scaleX, d.scaleY,
					d.rotation,
					d.alpha,
					d.originX, d.originY,
					false
				)
			end
		end
	end
	
	function SelectFrame:useItem(user, block, x, y)
		if not (user and block) then return false end
		
		if self:validatePointer() then
			return self.pObj:useItem(true, user, block, x, y)
		end
		
		return false
	end
	
	function SelectFrame:placeItem(blockTarget, perpetrator)
		perpetrator = perpetrator or Room:getPlayer(self.owner)
		
		if not (blockTarget and perpetrator) then return false end
		
		if self:validatePointer() then
			return self.pObj:placeItem(true, blockTarget, perpetrator)
		end
		
		return false
	end
end