
do
	local setmetatable = setmetatable
	function ItemBank:new(containersAmount)
		local this = setmetatable({
			containers = {},
			display = {}
		}, self)

		for index = 1, containersAmount do
			this.containers[index] = ItemContainer:new(index)
		end
		
		return this
	end
	
	function ItemBank:forEachInDisp(key, instruction, ...)
		local clist = self.containers
		local solve = ItemContainer[instruction]
		local lower = 1
		local upper = #clist
		if key then
			local display = self.display[key]
			
			lower = display.lower
			upper = display.upper
		end
		
		for index = lower, upper do
			solve(clist[index], key, ...)
		end
	end
	
	do
		function ItemBank:setContainersDisplay(key, instruct)
			local solve = instruct.solve
			local lowerLimit = instruct.lowerLimit or 1
			local upperLimit = instruct.upperLimit or #self.containers
			
			self.display[key] = {
				lower = lowerLimit,
				upper = upperLimit,
				solve = solve
			}
			
			local info
			local clist = self.containers
			for index = lowerLimit, upperLimit do
				info = solve(index)
				clist[index]:setDisplayInfo(key, info)
			end
		end
	end
	
	function ItemBank:showContainers(key)
		self:forEachInDisp(key, "displayAll")
	end
	
	function ItemBank:hideContainers(key)
		self:forEachInDisp(key, "hideAll")
	end
	
	function ItemBank:refreshContainers(key)
		self:forEachInDisp(key, "refreshDisplay", true, true)
	end
	
	function ItemBank:updateContainers(key)
		self:forEachInDisp(key, "updateDisplay")
	end
	
	function ItemBank:bulkClear(updateDisplay)		
		for _, container in next, self.containers do
			container:setEmpty(updateDisplay)
		end
	end
	
	function ItemBank:bulkFill(item, updateDisplay)
		for _, container in next, self.containers do
			container:setItemType(item, 99, updateDisplay)
		end
		
		if updateDisplay then
		--	self:refreshContainers(nil)
		end
	end
end