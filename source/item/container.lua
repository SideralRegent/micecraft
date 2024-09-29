do
	local ceil = math.ceil
	local setmetatable = setmetatable
	function ItemContainer:new(uniqueId)
		return setmetatable({
			uniqueId = uniqueId,
			item = nil,
			displayInfo = {},
			amount = 0,
			maxAmount = 0--item:meta("maxAmount")
		}, {__index = self})
	end
	
	function ItemContainer:forEach(index, ...)
		local solve = self[index]
		
		for k, v in next, self.displayInfo do
			if v.active then
				solve(self, k, ...)
			end
		end
	end
	
	function ItemContainer:setEmpty(updateDisplay)
		self.item = nil
		self.amount = 0
		self.maxAmount = 0
		
		if updateDisplay then
			self:hideAll(nil)
		end
	end
	
	function ItemContainer:getItem(key)
		if key and self.item then
			return self.item[key]
		else
			return self.item
		end
	end
	
	function ItemContainer:setItem(item, amount, updateDisplay)
		if item then
			self.item = item
			self.amount = amount or 1 -- on purpose not using :setValue
			self.maxAmount = item:meta("maxAmount")
			
			if updateDisplay then
				self:refreshDisplay(nil, true, true)
			end
		else
			self:setEmpty(true)
		end
	end
	
	function ItemContainer:setItemType(item, amount, updateDisplay)
		if item and item ~= VOID then
			local iTarget = Item:new(0)
			iTarget:setFromType(item)
			self:setItem(iTarget, amount, updateDisplay)
		else
			self:setEmpty(updateDisplay)
		end
	end
	
	function ItemContainer:gdisp(key)
		return self.displayInfo[key]
	end
	
	local abs = math.abs
	
	function ItemContainer:setDisplayInfo(key, info)
		info.barX = info.x
		info.barY = info.y + ((1.0 - info.originY) * TEXTURE_SIZE * info.scaleY)
		
		info.fixedPos = not not info.targetLayer:find("^[:~&]")
		
		info.textSize = 20 * info.scaleX
		
		info.selectX = info.x - (info.originX * TEXTURE_SIZE * info.scaleX)
		info.selectY = info.y - (info.originY * TEXTURE_SIZE * info.scaleY)
		
		info.selectWidth = abs(info.x - info.selectX) * 2
		info.selectHeight = abs(info.y - info.selectY) * 2
		
		-- info.callback ...
		
		self.displayInfo[key] = info
	end
	
	local addImage = tfm.exec.addImage
	local removeImage = tfm.exec.removeImage
	
	local bar_status = { -- 32 x 4 -- TODO: Add actual status images
		[0] = " ",
		"A",
		"B",
		"C",
		"D",
	}
	
	function ItemContainer:setUsageBarDisplay(key, show)
		local i = self:gdisp(key)
		
		if not show and i.id_bar then
			i.id_bar = removeImage(i.id_bar, i.fade)
		end
		
		if show ~= false and self.item then
			local consumable = self.item.consumable
			
			if consumable then				
				local image = ceil((consumable.uses / consumable.maxUses) * #bar_status)
				
				i.id_bar = addImage(
					image,
					i.targetLayer,
					i.barX, i.barY,
					i.playerName,
					i.scaleX, i.scaleY,
					i.angle,
					i.alpha,
					i.originX, i.originY,
					i.fade
				)
			end
		end
	end
	
	local removeTextArea = ui.removeTextArea
	local updateTextArea = ui.updateTextArea
	local iaddTextArea = ui.iaddTextArea
	
	local counterText = "<font size='%d' color='#FFFFFF' face='Arial'>%d</font>"
	local counterBack = "<font size='%d' color='#0' face='Arial'><b>%d</b></font>"
	function ItemContainer:setCounterDisplay(key, show)
		local i = self:gdisp(key)
		
		if show == false then
			if i.id_counter then
				removeTextArea(i.id_counter + 1, i.playerName)
				i.id_counter = removeTextArea(i.id_counter, i.playerName)
			end
		else
			if show == true then
				i.id_counter = iaddTextArea(
					"", i.playerName,
					i.x + 1, i.y + 1,
					0, 0,
					0x0, 0x0,
					1.0,
					i.fixedPos
				)
				
				iaddTextArea(
					"", i.playerName,
					i.x, i.y,
					0, 0,
					0x0, 0x0,
					1.0,
					i.fixedPos
				)
			end
			
			if i.id_counter then
				updateTextArea(
					i.id_counter, 
					counterBack:format(i.textSize, self.amount),
					i.playerName
				)
				updateTextArea(
					i.id_counter + 1, 
					counterText:format(i.textSize, self.amount),
					i.playerName
				)
			end
		end
	end
--	( id, text, targetPlayer, x, y, width, height, backgroundColor, borderColor, backgroundAlpha, fixedPos)
	
	local sel = ("<a href='event:%%s'>%s</a>"):format(('\n'):rep(15))
	function ItemContainer:setSelectable(key, show)
		local i = self:gdisp(key)
		if show and i.callback then
			i.id_select = iaddTextArea(
				sel:format(i.callback),
				i.playerName,
				i.selectX, i.selectY,
				i.selectWidth, i.selectHeight,
				0x0, 0x0,
				1.0,
				i.fixedPos
			)
		else
			if i.id_select then
				i.id_select = removeTextArea(i.id_select, i.playerName)
			end
		end
	end
	
	function ItemContainer:display(key)
		local item = self.item
		local display = self:gdisp(key)
		display.active = true
		
		if item then
			display.id_main = item:setImage(display)
			
			return true 
		end
		
		return false
	end
	
	
	function ItemContainer:hide(key)
		local display = self:gdisp(key)
		display.active = false
		
		if display.id_main then
			display.id_main = removeImage(display.id_main, display.fade)
		end
	end
	
	function ItemContainer:displayAll(key)
		if key then
			self:display(key)
			self:setUsageBarDisplay(key, true)
			self:setCounterDisplay(key, true)
			self:setSelectable(key, true)
		else
			self:forEach("displayAll")
		end
	end
	
	function ItemContainer:hideAll(key)
		if key then
			self:hide(key)
			self:setUsageBarDisplay(key, false)
			self:setCounterDisplay(key, false)
			self:setSelectable(key, false)
		else
			self:forEach("hideAll")
		end
	end
	
	function ItemContainer:refreshDisplay(key, usageBar, counter)
		if key then
			self:hide(key)
			self:setUsageBarDisplay(key, false)
			if self.item then
				self:display(key)
				
				if usageBar then
					self:setUsageBarDisplay(key, true)
				end
				
				if counter then
					self:setCounterDisplay(key, nil)
				end
			end
		else
			self:forEach("refreshDisplay", usageBar, counter)
		end
	end
	
	function ItemContainer:updateDisplay(key)
		if key then
			self:refreshDisplay(key)
		else
			self:forEach("refreshDisplay")
		end
	end
	
	local restrict = math.restrict
	function ItemContainer:setValue(value)
		self.amount = restrict(value, 1, self.maxAmount)
		
		return abs(value - self.amount)
	end
	
	function ItemContainer:shiftValue(value)		
		return self:setValue(self.amount + value)
	end
	
	function ItemContainer:setAmount(value, additive, updateDisplay) -- returns leftover
		local remainder = 0
		if additive then
			remainder = self:shiftValue(value)
		else
			if value == 0 then
				self:setEmpty(updateDisplay)
			else
				remainder = self:setValue(value)
			end
		end
		
		if updateDisplay then
			self:refreshDisplay(nil, true, true)
		end
		
		return remainder
	end
	
	function ItemContainer:useItem(updateDisplay)
		local item = self.item
		if not item then return false end
		
		local destroyed = item:checkUse(false)
		if destroyed then
			-- If self.amount is 1 then it will get erased
			self:shiftValue(-1)
		end
		
		if updateDisplay then
			self:refreshDisplay(nil, true, true)
		end
		
		return destroyed
	end
end