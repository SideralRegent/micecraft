do -- TODO
	-- local tobase = math.tobase
	local tonumber = tonumber
	local lchar = {[true] = "+", [false] = "-", ["+"] = true, ["-"] = false}
	local concat = table.concat
	
	function Map:decode(ENCODED_STR)
		local field = {}
		local x, y = 1, 0
		local type, repeats, tangible
		
		for line in ENCODED_STR:gmatch("[^;]+") do
			y = y + 1
			x = 1
			field[y] = {}
			
			for tinfo, tchar in line:gmatch("([%d|:]-)([%+%-])") do
				tangible = lchar[tchar]
				
				if tinfo:find("|", 2, true) then
					type, repeats = tinfo:match("^([d%d]+)|([%w]+)$")
					type = tonumber(type, 16)
					repeats = tonumber(repeats)
					
					for xi = x, x + (repeats - 1) do
						x = xi
						
						field[y][x] = {type=type}
					end
				else
					field[y][x] = {type=tonumber(tinfo, 16)}
				end
				
				x = x + 1
			end
		end
		
		return field
	end
	
	-- Not working (won't fix)
	function Map:encode(xStart, yStart, xEnd, yEnd)
		xStart = xStart or 1
		yStart = yStart or 1
		xEnd = xEnd or self.totalBlockWidth
		yEnd = yEnd or self.totalBlockHeight
		
		local ENCODED_STR = ""
		local lineCount = 0
		local matches
		
		local lines = {}
		local line = {}
		local x = 1
		local tile, par
		
		local bm = self.blocks
		
		for y = yStart, yEnd do
			lineCount = lineCount + 1
			line = {}
			
			x = xStart
			while x <= xEnd do
				tile = bm[y][x]
				matches = 1
				for xi = x + 1, xEnd do
					par = bm[y][xi]
					
					if tile.type == par.type then
						matches = matches + 1
						x = xi
					else
						break
					end
				end
				
				if matches > 1 then
					line[#line + 1] = ("%d|%d%s"):format(tile.type, matches, lchar[tile.tangible])
				else
					line[#line + 1] = ("%s%s"):format(tile.type, lchar[tile.tangible])
				end
				
				x = x + 1
			end
			
			lines[lineCount] = concat(line)
		end
		
		ENCODED_STR = concat(lines, ";")
		
		return ENCODED_STR
	end
end

