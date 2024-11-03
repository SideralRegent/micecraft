do
	function Interface:getIndex()
		return self.settingIndex
	end
	
	function Interface:setIndex(index)
		if index then
			self.settingIndex = index
		else
			self.objAc = self.objAc + 1
			self.settingIndex = self.objAc
		end
		
		return self.settingIndex
	end
	
	local aux = {
		__index = {
			insert = function(t, i, p)
				t[#t + 1] = {id=i, playerName=p}
			end
		}
	}
	
	function Interface:setView(objectId)
		objectId = objectId or self:setIndex(nil)
		
		self.object[objectId] = {
			img = setmetatable({}, aux),
			txt = setmetatable({}, aux),
		}
	end
	
	local removeImage = tfm.exec.removeImage
	local removeTextArea = ui.removeTextArea
	function Interface:removeView(objectId)
		local object = self.object[objectId]
		if not object then return end
		
		for _, imageInfo in next, object.img do
			removeImage(imageInfo.id, false)
		end
		
		for _, textInfo in next, object.txt do
			removeTextArea(textInfo.id, textInfo.playerName)
		end
		
		self.object[objectId] = nil
		
		return false
	end
	
	function Interface:current()
		return self.object[self.settingIndex]
	end
	
	local iaddTextArea = ui.iaddTextArea
	function Interface:addText(text, targetPlayer, ...)
		local id = iaddTextArea(text, targetPlayer, ...)
		
		self:current().txt:insert(id, targetPlayer)
	end	
	
	local addTextArea = ui.addTextArea
	function Interface:addIText(id, text, targetPlayer, ...)
		addTextArea(id, text, targetPlayer, ...)
		
		self:current().txt:insert(id, targetPlayer)
	end	
	
	function Interface:updateText(...)
		updateTextArea(...)
	end
	
	local addImage = tfm.exec.addImage
	function Interface:addImage(...)
		local id = addImage(...)
		
		self:current().img:insert(id)
	end	
end