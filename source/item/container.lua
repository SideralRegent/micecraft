do
	local ceil = math.ceil
	local setmetatable = setmetatable
	function ItemContainer:new(uniqueId)
		return setmetatable({
			uniqueId = uniqueId,
			item = nil,
			displayInfo = {},
			amount = 0,
			maxAmount = 0,--item:meta("maxAmount")
			restrictedTo = {
			-- category
			}
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
	
	function ItemContainer:setRestriction(categoryName, value)
		self.restrictedTo[categoryName] = value
	end
	
	function ItemContainer:isCompatible(container)
		if self.item then
			return not container.restrictedTo[self.item.category]
		else
			return true
		end
	end
	
	function ItemContainer:isMutuallyCompatible(container)
		return self:isCompatible(container) and container:isCompatible(self)
	end
	
	function ItemContainer:setEmpty(updateDisplay)
		self.item = nil
		self.amount = 0
		self.maxAmount = 0
		
		if updateDisplay then
			self:setHide(nil, true, true, true, false, nil)
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
	
	function ItemContainer:getActiveDisplay(default)
		for _, display in next, self.displayInfo do
			if display.active then
				return display
			end
		end
		-- It will only come here if it didn't find any up there
		if default then
			return self.displayInfo[default] or next(self.displayInfo, nil)
		end
	end
	
	local abs = math.abs
	
	function ItemContainer:setDisplayInfo(key, info)
		info.barX = info.x
		info.barY = info.y + ((1.0 - info.originY) * TEXTURE_SIZE * info.scaleY)
		
		info.fixedPos = not not info.targetLayer:find("^[:~&]")
		
		info.textSize = 20 * info.scaleX
		
		info.selectWidth =  TEXTURE_SIZE * info.scaleX * 1.10
		info.selectHeight = TEXTURE_SIZE * info.scaleY * 1.10
		
		info.selectX = info.x - (info.originX * info.selectWidth)
		info.selectY = info.y - (info.originY * info.selectHeight)
		
		info.active = false
		
		-- info.callback = ...
		
		self.displayInfo[key] = info
	end
	
	local addImage = tfm.exec.addImage
	local removeImage = tfm.exec.removeImage
	
	local bar_status = { -- 32 x 4 -- TODO: Add actual status images
		"192623b20dd.png", -- Fewer uses
		"192623afe9f.png",
		"192623ac1dd.png",
		"192623aa2e3.png",
		"192623a846b.png",
		"192623a4794.png",
		"192623a2113.png",
		"1926239fff0.png",
		"1926239d5dd.png", -- Most uses
	}
	
	function ItemContainer:setUsageBarDisplay(key, show)
		local i = self:gdisp(key)
		
		if i.id_bar then
			i.id_bar = removeImage(i.id_bar, i.fade)
		end
		
		if show ~= false and self.item then
			local consumable = self.item.consumable
			
			if consumable and consumable.uses ~= 0 then				
				local image = ceil((consumable.uses / consumable.maxUses) * #bar_status)
				
				i.id_bar = addImage(
					bar_status[image],
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
	
	function ItemContainer:removeCounterDisplay(key)
		local i = self:gdisp(key)
		
		if i.id_counter then
			removeTextArea(i.id_counter + 1, i.playerName)
			removeTextArea(i.id_counter, i.playerName)
			i.id_counter = nil
		end
	end
	
	function ItemContainer:showCounterDisplay(key)
		local i = self:gdisp(key)
		
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
	
	function ItemContainer:updateCounterDisplay(key)
		local i = self:gdisp(key)
		
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
	
	function ItemContainer:setCounterDisplay(key, show)
		local i = self:gdisp(key)
		
		if show == false or self.amount == 0 then
			self:removeCounterDisplay(key)
		else
			if show and not self.id_counter then
				self:showCounterDisplay(key)
			end
			
			self:updateCounterDisplay(key)
		end
	end
	
	local sel = ("<a href='event:%%s'>%s</a>"):format(('\n'):rep(15))
	function ItemContainer:setSelectable(key, show)
		local i = self:gdisp(key)
		if show and i.callback then
			i.id_select = iaddTextArea(
				sel:format(i.callback),
				i.playerName,
				i.selectX, i.selectY,
				i.selectWidth, i.selectHeight,
				0xFFFFFF, 0xFFFFFF,
				0.25,
				i.fixedPos
			)
		else
			if i.id_select then
				i.id_select = removeTextArea(i.id_select, i.playerName)
			end
			
			if show == nil then
				-- this is dangerous
				self:setSelectable(key, true)
			end
		end
	end
	
	function ItemContainer:display(key)
		local item = self.item
		local display = self:gdisp(key)
		
		if item then
			display.id_main = item:setImage(display)
			
			return true 
		end
		
		return false
	end
	
	
	function ItemContainer:hide(key)
		local display = self:gdisp(key)
		
		if display.id_main then
			display.id_main = removeImage(display.id_main, display.fade)
		end
	end
	
	function ItemContainer:displayAll(key, selector)
		if key then
			self:setShow(key, true, true, true, true, true)
		else
			self:forEach("displayAll", selector)
		end
	end
	
	function ItemContainer:setShow(key, sprite, usageBar, counter, selector, state)
		if key then
			if sprite then
				self:display(key)
			end
			
			if usageBar then
				self:setUsageBarDisplay(key, true)
			end
			
			if counter then
				self:setCounterDisplay(key, true)
			end
			
			if selector then
				self:setSelectable(key, true)
			end
			
			if state ~= nil then
				self.displayInfo[key].active = state
			end
		else
			if state == nil then
				self:forEach("setShow", sprite, usageBar, counter, selector, nil)
			end
		end
	end
	
	function ItemContainer:displayAll(key, selector)
		if key then
			self:setShow(key, true, true, true, selector, true)
		else
			self:forEach("displayAll", selector)
		end
	end
	
	function ItemContainer:setHide(key, sprite, usageBar, counter, selector, state)
		if key then
			if sprite then
				self:hide(key)
			end
			
			if usageBar then
				self:setUsageBarDisplay(key, false)
			end
			
			if counter then
				self:setCounterDisplay(key, false)
			end
			
			if selector then
				self:setSelectable(key, false)
			end
			
			if state ~= nil then
				self.displayInfo[key].active = state
			end
		else
			if state == nil then
				self:forEach("setHide", sprite, usageBar, counter, selector, nil)
			end
		end
	end
	
	function ItemContainer:hideAll(key, selector)
		if key then
			self:setHide(key, true, true, true, true, selector, false)
		else
			self:forEach("hideAll", selector)
		end
	end
	
	function ItemContainer:refreshDisplay(key, usageBar, counter, selector)
		if key then
			self:setHide(key, true, usageBar, counter, selector, nil)
			
			if self.item then
				self:setShow(key, true, usageBar, counter, false, true)
			end
			
			if selector then
				self:setSelectable(key, true)
			end
		else
			self:forEach("refreshDisplay", usageBar, counter, selector)
		end
	end
	
	function ItemContainer:refreshDisplay2(key, counter, usageBar, selector, status)
		if key then
			if selector then
				self:setSelectable(key, nil)
			end
			
			if self.item then
				if (self.amount ~= 0) then
					if counter then
						self:setCounterDisplay(key, nil)
					end
					
					if usageBar then
						self:setUsageBarDisplay(key, nil)
					end
				end
			else
				self:setHide(key, true, true, true, false, nil)
			end
			
			self.displayInfo[key].active = true
		else
			self:forEach("refreshDisplay2", counter, usageBar, selector, status)
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
		self.amount = restrict(value, 0, self.maxAmount)
		
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
				self.amount = 0
			else
				remainder = self:setValue(value)
			end
		end
				
		if self.amount <= 0 then
			self:setEmpty(false)
		end
		
		if updateDisplay then
			self:refreshDisplay2(nil, true, true, false)
		end
		
		return remainder
	end
	
	function ItemContainer:useItem(updateDisplay, ...)
		local item = self.item
		if not item then return false end
		
		local destroyed = item:checkUse(false, ...)
		if destroyed then
			-- If self.amount is 1 then it will get erased
			self:setAmount(-1, true, false)
		end
		
		if updateDisplay then
			self:refreshDisplay2(nil, true, true, false)
		end
		
		return destroyed
	end
	
	function ItemContainer:placeItem(updateDisplay, ...)
		local item = self.item
		if not item then return false end
		
		if item:place(...) then
			self:setAmount(-1, true, false)
			
			if updateDisplay then
				self:refreshDisplay2(nil, true, false, false)
			end
			
			return true
		end
		
		return false
	end
end