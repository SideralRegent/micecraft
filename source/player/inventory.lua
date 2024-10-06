function PlayerInventory:new(ownerName)
	return setmetatable({
		owner = ownerName,
		bank = ItemBank:new(4 * 10),
		showing = {
			hotbar = false,
			remainder = false
		},
		map = {}
	}, self)
end

do -- This is crap.
	local floor = math.floor
	local hotbarLim = 4
	local line = hotbarLim
	local collumn = 10
	local scale = 0.625
	local pxsize = scale * 32
	local offset = 0.35 * pxsize
	local pxoffset = pxsize + offset
		
	local X, Y = 15, 25
		
	function PlayerInventory:set()
		local callback = ("Inv-%s-%%d"):format(self.owner)
		self.bank:setContainersDisplay("remainder", {
			lowerLimit = hotbarLim + 1,
			solve = function(index)
				local pos = index - 1
				return {
					targetLayer = ":99999",
					scaleX = scale,
					scaleY = scale, -- 20 px
					y = Y + ((pos % line) * pxoffset),
					x = X + (floor(pos / line) * pxoffset),
					
				--	x = X + (((index * line) % collumn) * pxoffset),
					playerName = self.owner,
					angle = 0,
					alpha = 1.0,
					originX = 0,
					originY = 0,
					fade = false,
					callback = callback:format(index)
				}
			end
			}
		)
		
		self.bank:setContainersDisplay("hotbar", {
			upperLimit = hotbarLim,
			solve = function(index)
				local pos = index - 1
				return {
					targetLayer = ":99999",
					scaleX = scale,
					scaleY = scale, -- 20 px
					y = Y + ((pos % line) * pxoffset),
					x = X,
					playerName = self.owner,
					angle = 0,
					alpha = 1.0,
					originX = 0,
					originY = 0,
					fade = false,
					callback = callback:format(index)
				}
			end
			}
		)
		
		for i = 1, hotbarLim do
			self.map[i] = "hotbar"
		end
		
		for i = hotbarLim + 1, #self.bank.containers do
			self.map[i] = "remainder"
		end
		
		self.bank:bulkFill(0x7A315A, false)
		self.bank:showContainers("hotbar")
	end
end

function PlayerInventory:setDisplay(key, display)
	if display == nil then
		self:setDisplay(key, not self.showing[key])
	else
		self.showing[key] = display
		
		if display then
			self.bank:showContainers(key)
		else
			self.bank:hideContainers(key)
		end
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

function Player:shiftHotbarSelector(value, updateDisplay)
	value = value or 1
	local selector = self.selectedFrame
	
	-- 1 to 4: size of hotbar
	local success = selector:shiftPointer(value, 1, 4, "hotbar")
	
	selector:setView(success and updateDisplay)
end

function Player:setSelectedContainer(index, bank, updateDisplay)
	bank = bank or self.inventory.bank
	local selector = self.selectedFrame
		
	local isEqual = (bank == selector.bank) and (index == selector.pointer)
	
	selector:setReferenceBank(bank)
	
	if isEqual then -- Deselection
		index = 0
	end
	
	local success = selector:setPointer(index, self.inventory.map[index])
	
	selector:setView(success and updateDisplay)
	
	return not isEqual
end