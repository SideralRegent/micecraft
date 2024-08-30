Ui = {
	__templates = {},
	Template = {},
	Object = {}
}

Ui.Object.__index = Ui.Object
Ui.Template.__index = Ui.Template

do
	local addImage = tfm.exec.addImage
	local removeImage = tfm.exec.removeImage
	
	local addTextArea = ui.addTextArea
	local removeTextArea = ui.removeTextArea
	local updateTextArea = ui.updateTextArea
	
	local addPopup = ui.addPopup
	
	local setBackgroundColor = ui.setBackgroundColor
	local setMapName = ui.setMapName
	local setShamanName = ui.setShamanName
	
	local showColorPicker = ui.showColorPicker
	
	
	function Ui:addImage(...)
		return addImage(...)
	end
	
	function Ui:removeImage(id, ...)
		removeImage(id, ...)
	end
	
	function Ui:addTextArea(id, ...)
		addTextArea(id, ...)
	end
	
	function Ui:removeTextArea(id, ...)
		removeTextArea(id, ...)
	end
	
	function Ui:updateTextArea(id, ...)
		updateTextArea(id, ...)
	end
	
	function Ui:addPopup(id, ...)
		addPopup(id, ...)
	end
	
	function Ui:removePopup(id, targetPlayer)
		addPopup(id, 0, "", targetPlayer, 400, 500, 20, true)
	end
end

do
	local copy = table.copy
	local keys = table.keys
	local type = type
	local next = next
	local pcall = pcall
	local print = print
	function Ui:forTarget(targetPlayer, f)
		if not f then return end
		local tp = type(targetPlayer)
		local playerList = {}
		
		-- Gets playerList for 'targetPlayer', so the final result is always an array of players' names.
		if tp == "string" then
			playerList[1] = targetPlayer
		elseif tp == "table" then
			if #targetPlayer > 0 then
				playerList = targetPlayer
			else
				playerList = keys(targetPlayer)
			end
		else
			playerList = keys(tfm.get.room.playerList)
		end
		
		local ok, result
		for _, playerName in next, playerList do
			ok, result = pcall(f, playerName)
			
			if not ok then
				print(result)
				break
			end
		end
	end
end

function Ui:newTemplate(identifier, parent)
	self.__templates[identifier] = self.Template:new(identifier, parent)
	
	return self.__templates[identifier]
end

function Ui:getTemplate(identifier)
	return self.__templates[identifier]
end

function Ui:deleteTemplate(identifier)
	self.__templates[identifier] = nil
end

do
	local assert = assert
	local type = type
	function Ui:newObject(identifier, templateName)
		assert(type(identifier) == "number", "Ui:newObject 'identifier' argument must be a number.")
		
		local Object = self.Object:new(identifier)
		
		if templateName then
			local Template = self:getTemplate(templateName)
			
			if Template then
				Object:copyFrom(Template)
			end
		end
	end
end