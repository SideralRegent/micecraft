do
	local abs = math.abs
	local next = next
	
	local PM = Matrix:new()
	
	function PM:getSegment(xs, ys, xe, ye)
		return {
			xStart = xs,
			xEnd = xe,
			yStart = ys,
			yEnd = ye,
			height = (ye - ys) + 1,
			width = (xe - xs) + 1,
			category = abs(self[ys][xs]),
			block = Map:getBlock(xs, ys, CD_MTX)
		}
	end
	
	local q = function(t, v)
		t[#t + 1] = v
	end
	
	function PM:individual(xStart, xEnd, yStart, yEnd)
		local list = {}
		for y = yStart, yEnd do
			for x = xStart, xEnd do
				if self[y][x] > 0 then
					q(list, self:getSegment(x, y, x, y))
					self[y][x] = -self[y][x]
				end
			end
		end
		
		return list
	end
	
	function PM:rectangle(xStart, xEnd, yStart, yEnd)
		local x, y = 0, 0
		local xs, xe, ys, ye
		local matches = 0
		local axisv = 0
		
		local list = {}
		
		repeat
			matches = 0
			xe = xEnd
			ye = yEnd
			xs = xStart
			ys = nil
			
			axisv = ye
			x = xs
			while x <= xe do
				y = ys or yStart
				while y <= ye do
					if self[y][x] > 0 then -- Not processed
						if ys then
							if y == yEnd and x == xStart then
								ye = y
							end
						else
							ys = y
							xs = x
						end
						
						matches = matches + 1
						self[y][x] = -self[y][x]
					else -- Processed
						if ys then
							if x == xs then
								ye = y - 1
							else
								xe = x - 1
								
								for i = ys, y - 1 do
									self[i][x] = -self[i][x]
									matches = matches - 1
								end
								
								break
							end
						end
					end
					y = y + 1
				end
				x = x + 1
			end
			
			if matches > 0 then
				q(list, self:getSegment(xs, ys, xe, ye, 1))
			end
			
		until (matches == 0)
		
		return list
	end	
	
	-- For **detailed** functions: So, to process blocks it requires 
	-- the reference category to be equal to the block checked.
	-- If there's no reference category, then the block is set
	-- as the reference, but if there is then it doesn't get
	-- overwritten and thus checks against it. Then, it checks if 
	-- the block category is positive (not changed). This ensures
	-- that ONLY blocks not processed will get extra computations.
	-- It represents a 25% performance improvement from previous.
	
	function PM:rectangle_detailed(xStart, xEnd, yStart, yEnd)
		local x, y = 0, 0
		local xs, xe, ys, ye
		local matches = 0
		local axisv = 0
		
		local list = {}
		local cat
		
		repeat
			matches = 0
			xe = xEnd
			ye = yEnd
			xs = xStart
			ys = nil
			
			axisv = ye
			x = xs
			while x <= xe do
				y = ys or yStart
				while y <= ye do
					cat = cat or self[y][x]
					if self[y][x] > 0 and cat == self[y][x] then -- Not processed
						if ys then
							if y == yEnd and x == xStart then
								ye = y
							end
						else
							ys = y
							xs = x
						end
						
						matches = matches + 1
						self[y][x] = -cat
					else -- Processed
						if ys then
							if x == xs then
								ye = y - 1
							else
								cat = nil
								xe = x - 1
								
								for i = ys, y - 1 do
									self[i][x] = -self[i][x]
									matches = matches - 1
								end
								
								break
							end
						else
							cat = nil
						end
					end
					
					y = y + 1
				end
				x = x + 1
			end
			
			if matches > 0 then
				q(list, self:getSegment(xs, ys, xe, ye))
			end
			
		until (matches <= 0)
		
		return list
	end
	
	function PM:line(xStart, xEnd, yStart, yEnd)
		local list = {}
		
		local match = false
		local ys, ye
		local cat 
		
		for x = xStart, xEnd do
			match = false
			ys = yStart
			ye = yEnd
			for y = yStart, yEnd do
				cat = self[y][x]
				if cat > 0 then
					if match then
						ye = y
					else
						ys = y
						ye = y
						match = true
					end
					self[y][x] = -cat
				end
				
				if cat <= 0 or y == yEnd then
					if match then
						q(list, self:getSegment(x, ys, x, ye, 1))
						match = false
					end
				end
			end
		end
		
		return list
	end
	
	function PM:line_detailed(xStart, xEnd, yStart, yEnd)
		local list = {}
		
		local match = false
		local ys, ye
		local ct
		local y
		
		for x = xStart, xEnd do
			match = false
			ys = yStart
			ye = yEnd
			y = yStart
			while y <= yEnd do
				ct = ct or self[y][x]
				
				if ct == match or not match then
					if match then
						ye = y
					else
						ys = y
						ye = y
						match = ct
					end
					
					self[y][x] = -ct
				end
				
				if (ct <= 0 or ct ~= match) or y == yEnd then
					if match then
						q(list, self:getSegment(x, ys, x, ye, match))
						match = false
					end
					
					if match ~= ct then
						y = y + 1
					end
				else
					y = y + 1
				end
			end
		end
		
		return list
	end
	
	function PM:row(xStart, xEnd, yStart, yEnd)
		local list = {}
		
		local match = false
		local xs, xe
		local ct
		for y = yStart, yEnd do
			match = false
			xs = xStart
			xe = xEnd
			
			for x = xStart, xEnd do
				ct = self[y][x]
				if ct > 0 then
					if match then
						xe = x
					else
						xs = x
						xe = x
						match = true
					end
					self[y][x] = -ct
				end
				
				if ct <= 0 or x == xEnd then
					if match then
						q(list, self:getSegment(xs, y, xe, y, 1))
						match = false
					end
				end
			end
		end
		
		return list
	end
	
		function PM:row_detailed(xStart, xEnd, yStart, yEnd)
		local list = {}
		
		local match = false
		local xs, xe
		local ct
		local x
		
		for y = yStart, yEnd do
			match = false
			xs = xStart
			xe = xEnd
			
			x = xStart
			while x <= xEnd do
				ct = self[y][x]
				if (ct == match or not match) then
					if match then
						xe = x
					else
						xs = x
						xe = x
						match = ct
					end
					
					self[y][x] = -ct
				end
				
				if (ct <= 0 or ct ~= match) or x == xEnd then
					if match then
						q(list, self:getSegment(xs, y, xe, y, match))
						match = false
					else
						x = x + 1
					end
				else
					x = x + 1
				end
			end
		end
		
		return list
	end
	
	Map.physicsMap = PM
end