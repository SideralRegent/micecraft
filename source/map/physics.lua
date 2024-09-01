do
	local default_cats = {
		[1] = true, 
		[2] = true, 
		-- [3] = true, 
		[4] = true, 
		[6] = true
	}
	local abs = math.abs
	local ipairs = ipairs
	local next = next
	
	local PM = {}
	
	function PM:getSegment(xs, ys, xe, ye, cat)
		return {
			xStart = xs,
			xEnd = xe,
			yStart = ys,
			yEnd = ye,
			height = (ye - ys) + 1,
			width = (xe - xs) + 1,
			category = cat or abs(self[ys][xs]),
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
					q(list, self:getSegment(x, y, x, y, self[y][x]))
					self[y][x] = -self[y][x]
				end
			end
		end
		
		return list
	end
	
	local max = math.max
	local min = math.min
	function PM:rectangle(xStart, xEnd, yStart, yEnd)
		local x, y = 0, 0
		local xs, xe, ys, ye
		local matches = 0
		local axisv = 0
		
		local list = {}
		local block 
		
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
	
	function PM:rectangle_detailed(xStart, xEnd, yStart, yEnd, catlist)
		local x, y = 0, 0
		local xs, xe, ys, ye
		local matches = 0
		local axisv = 0
		
		catlist = catlist or default_cats
		local list = {}
		local block 
		
		for cat, _ in next, catlist do -- There should be a better way to do this. At the moment I wrote it I couldn't think of one.
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
						if cat > 0 and self[y][x] == cat then -- Not processed
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
					q(list, self:getSegment(xs, ys, xe, ye, cat))
				end
				
			until (matches <= 0)
		end
		
		return list
	end
	
	function PM:line(xStart, xEnd, yStart, yEnd)
		local list = {}
		
		local match = false
		local ys, ye
		local ct 
		
		for x = xStart, xEnd do
			match = false
			ys = yStart
			ye = yEnd
			for y = yStart, yEnd do
				ct = self[y][x]
				if ct > 0 then
					if match then
						ye = y
					else
						ys = y
						ye = y
						match = true
					end
					self[y][x] = -ct
				end
				
				if ct <= 0 or y == yEnd then
					if match then
						q(list, self:getSegment(x, ys, x, ye, 1))
						match = false
					end
				end
			end
		end
		
		return list
	end
	
	function PM:line_detailed(xStart, xEnd, yStart, yEnd, catlist)
		local list = {}
		catlist = catlist or default_cats
		
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
				ct = self[y][x]
				if catlist[ct] and (ct == match or not match) then
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
	
		function PM:row_detailed(xStart, xEnd, yStart, yEnd, catlist)
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
				if catlist[ct] and (ct == match or not match) then
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