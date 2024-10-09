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
			insert = function(t, v)
				t[#t + 1] = v
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
		
		for _, imageId in next, object.img do
			removeImage(imageId, false)
		end
		
		for _, textId in next, object.txt do
			removeTextArea(textId, nil)
		end
		
		self.object[objectId] = nil
	end
	
	function Interface:current()
		return self.object[self.settingIndex]
	end
	
	local iaddTextArea = ui.iaddTextArea
	function Interface:addText(...)
		local id = iaddTextArea(...)
		
		self:current().txt:insert(id)
	end	
	
	local addImage = tfm.exec.addImage
	function Interface:addImage(...)
		local id = addImage(...)
		
		self:current().img:insert(id)
	end	
end