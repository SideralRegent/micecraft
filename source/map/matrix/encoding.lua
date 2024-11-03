do -- TODO
	-- local tobase = math.tobase
	local tonumber = tonumber
	local concat = table.concat
	
	function Map:decode(ENCODED_STR)
		local field = {}
		local x, y = 1, 0
		local type, repeats, tangible
		
		for line in ENCODED_STR:gmatch("[^;]+") do
			y = y + 1
			x = 1
			field[y] = {}
			
			for potentialRow in line:gmatch("[^,]+") do
				if potentialRow:find("|", 2, true) then
					type, repeats = potentialRow:match("^([d%d]+)|(%d+)$")
					type = tonumber(type, 16)
					repeats = tonumber(repeats)
					
					for xi = x, x + (repeats - 1) do
						x = xi
						
						field[y][x] = type
					end
				else -- It's a single tile
					field[y][x] = tonumber(potentialRow, 16)
				end
				
				x = x + 1
			end
		end
		
		return field
	end
	
	function Map:encode(xStart, yStart, xEnd, yEnd)
		xStart = xStart or 1
		yStart = yStart or 1
		xEnd = xEnd or self.totalBlockWidth
		yEnd = yEnd or self.totalBlockHeight
		
		local ENCODED_STR = ""
		local lineCount = 0
		local matches
		
		local lines = {}
		local currentLine = {}
		local x = 1
		local referenceTile, currentTile
		
		local blockMatrix = self.blocks
		local blockLine
		
		for y = yStart, yEnd do
			blockLine = blockMatrix[y]
			lineCount = lineCount + 1
			currentLine = {}
			
			x = xStart
			while x <= xEnd do
				referenceTile = blockLine[x].type
				matches = 1
				for xIndex = x + 1, xEnd do					
					if referenceTile == blockLine[xIndex].type then
						matches = matches + 1
						x = xIndex
					else
						break
					end
				end
				
				if matches > 1 then
					currentLine[#currentLine + 1] = ("%x|%d"):format(referenceTile, matches)
				else
					currentLine[#currentLine + 1] = ("%x"):format(referenceTile)
				end
				
				x = x + 1
			end
			
			lines[lineCount] = concat(currentLine, ",")
		end
		
		ENCODED_STR = concat(lines, ";")
		
		return ENCODED_STR
	end
end

