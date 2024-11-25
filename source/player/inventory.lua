do
	function PlayerInventory:new(ownerName)
		
		return setmetatable({
			owner = ownerName,
			bank = ItemBank:new(4 * 10),
			section = {},
			hotbarLim = 4,
		}, self)
	end
end

function PlayerInventory:setSection(name, lowerLim, upperLim, solver)
	local section = {
		name = name,
		lower = lowerLim or 1,
		upper = upperLim or #self.inventory.bank,
		active = false,
		solver = solver
	}
	
	self.bank:setContainersDisplay(section.name, {
		lowerLimit = section.lower,
		upperLimit = section.upper,
		solve = section.solver
	})	self.section[name] = section
end

do
	local unpack = table.unpack
	function PlayerInventory:getSectionByIndex(index)
		local t = {}
		
		for name, section in next, self.section do
			if index >= section.lower and index <= section.upper then
				t[#t + 1] = section
			end
		end
		
		return unpack(t)
	end

	-- This is crap.
	local floor = math.floor
	local collumn = 10
	local scale = 0.625
	local pxsize = scale * 32
	local offset = 0.5 * pxsize
	local pxoffset = pxsize + offset
		
	local X, Y = 15, 32
		
	function PlayerInventory:set()
		local line = self.hotbarLim
		local callback = ("Inv-%s-%%d"):format(self.owner)
		
		local solveFunction = function(index)
			local pos = index - 1
			return {
				targetLayer = ":99999",
				
				scaleX = scale,
				scaleY = scale, -- 20 px
				
				y = Y + ((pos % line) * pxoffset),
				x = X + (floor(pos / line) * pxoffset),
				
				playerName = self.owner,
				
				angle = 0,
				alpha = 1.0,
				
				originX = 0,
				originY = 0,
				
				fade = false,
				
				callback = callback:format(index)
			}
		end
		
		self:setSection("hotbar", 1, self.hotbarLim, solveFunction)
		self:setSection("remainder", self.hotbarLim + 1, 40, solveFunction)
				
		self.bank:bulkFillTest(false)
	end
end

function PlayerInventory:setDisplay(key, display)
	if display == nil then
		self:setDisplay(key, not self.section[key].active)
	else
		if display then
			if not self.section[key].active then
				self.bank:showContainers(key)
			end
		else
			self.bank:hideContainers(key)
		end
		
		self.section[key].active = display
	end
end

function PlayerInventory:setView(hotbar, remainder)
	self:setDisplay("hotbar", hotbar)
	self:setDisplay("remainder", remainder)	
end

function PlayerInventory:serialize()
	
end

function PlayerInventory:deserialize()
	
end

function PlayerInventory:checkIndex(index)
	return not not self.bank.containers[index]
end

function PlayerInventory:checkView(...)
	local checks = {...}
	local section
	for _, index in next, checks do
		section = self:getSectionByIndex(index)
		
		if not (section and section.active) then
			return false 
		end
	end
	
	return true
end

function Player:shiftHotbarSelector(value, updateDisplay)
	value = value or 1
	local selector = self.selectedFrame
	
	local success = selector:shiftPointer(value, 1, self.inventory.hotbarLim, "hotbar")
	
	selector:setView(success and updateDisplay)
end

function Player:setSelectedContainer(index, bank, updateDisplay)
	index = index or self.selectedFrame.pointer
	bank = bank or self.inventory.bank
	local selector = self.selectedFrame
		
	local isEqual = (bank == selector.bank) and (index == selector.pointer)
	
	selector:setReferenceBank(bank)
	
	if isEqual then -- Deselection
		index = 0
	end
	
	local section = self.inventory:getSectionByIndex(index)
	
	local success = selector:setPointer(index, section and section.index or "null")
	
	selector:setView(success and updateDisplay)
	
	return not isEqual
end

function Player:assertSelectorView()
	if not self.inventory:checkView(self.selectedFrame.pointer) then
		self:setSelectedContainer(0, nil, true)
	end
end