do
	local setmetatable = setmetatable
	function ItemBank:new(containersAmount)
		local this = setmetatable({
			containers = {},
			display = {}
		}, self)		for index = 1, containersAmount do
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
		self:forEachInDisp(key, "displayAll", true)
	end
	
	function ItemBank:hideContainers(key)
		self:forEachInDisp(key, "hideAll", true)
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
	
	function ItemBank:bulkFill(item, amount, updateDisplay)
		for _, container in next, self.containers do
			container:setItemType(item , amount, updateDisplay)
		end
	end
	
	function ItemBank:bulkFillTest(updateDisplay)
		local types = {}
		for itemName, id in next, itemMeta.maps do
			types[#types + 1] = id
		end
		
		local current = 1
		for _, container in next, self.containers do
			container:setItemType(types[current], 512, updateDisplay)
			
			current = 1 + current % #types
		end
	end
	
	function ItemBank:shiftContainers(A, B)
		B:setItem(A.item, A.amount, false)
		A:setEmpty()
	end
	
	function ItemBank:exchangeContainers(A, B)
		local X = {
			item = A.item,
			amount = A.amount
		}
		
		A:setItem(B.item, B.amount)
		B:setItem(X.item, X.amount)
	end
	
	function ItemBank:pourContainer(A, B)
		local leftover = B:setAmount(A.amount, true, false)
		
		if leftover == A.amount then
			return false
		else
			A:setAmount(leftover, false, false)
		end
	end
	
	--- Moves an item from container S to container D
	
	local p = print
	function ItemBank:moveItem(conS, conD, updateDisplay)
		if conS == conD then return false end
		
		local S = self.containers[conS]
		local D = self.containers[conD]
		
		local success = false
		
		if S.item then
			if D.item then -- D has an item, need to perform checks
				if S:isMutuallyCompatible(D) then
					-- Same type, can just change amounts
					if S.item.type == D.item.type then
						success = self:pourContainer(S, D)
					else -- Different types, just exchange
						self:exchangeContainers(S, D)
						
						success = true
					end
				else -- Can't move
					success = false
				end
			else -- D is empty, just copy contents
				self:exchangeContainers(S, D)
				
				success = true
			end
		elseif D.item then -- if S is empty but not D
			-- reuse same logic
			return self:moveItem(conD, conS, updateDisplay)
		end
		
		if updateDisplay then
			S:refreshDisplay(nil, true, true, true)
			D:refreshDisplay(nil, true, true, true)
		end
		
		return success
	end
end