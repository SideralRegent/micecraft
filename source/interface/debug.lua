do
	local Debug = {}
	
	function Debug.Close(playerName, x, y, fixed)
		Interface:addText(
			("<a href='event:iclose-%d'>X</a>"):format(Interface:getIndex()),
			playerName,
			x, y,
			0, 0,
			0x0, 0x0,
			1.0, fixed
		)
	end
	
	local concat = table.concat
		
	
	local _ = nil
	local newLine = ""
	local chunk_contextual = concat({
		"<J>Chunk #%d - %d %d</J>",
		newLine,
		"bshift: %d",
		"dim: %d %d %d %d",
		"dp: %d %d",
		"f/b: (%d, %d) (%d, %d)",
		"colliding: %s",
		"viewing: %s",
		"T: %d %d",
		newLine,
		"<a href='event:chunk-encode-%d'>Get as text</a>",
		"<a href='event:chunk-load-%d'>Load from text</a>"
	}, '\n')
	local ccontxwidth = 150
	function Debug.ChunkContextual(playerName, chunk, x, y)
		Interface:setView()
		
		Interface:addText(
			chunk_contextual:format(
				chunk.uniqueId, chunk.x, chunk.y,
				chunk.uniqueIdBlock,
				chunk.width, chunk.height, chunk.blockWidth, chunk.blockHeight,
				chunk.dx, chunk.dy,
				chunk.xf, chunk.yf, chunk.xb, chunk.yb,
				chunk.collidesTo[Room:getPlayer(playerName).presenceId] and 'O' or 'X',
				chunk.displaysTo[Room:getPlayer(playerName).presenceId] and 'O' or 'X',
				chunk.collisionTimer, chunk.displayTimer,
				chunk.uniqueId,
				chunk.uniqueId
			),
			playerName,
			x, y,
			ccontxwidth, 0, 
			0x010101, 0x010101,
			0.5, false
		)
		
		Debug.Close(playerName, x + ccontxwidth - 25, y, false)
		
		return Interface:getIndex()
	end
	
	local block_contextual = concat({
		"<J>Block #%d - %d %d</J>",
		newLine,
		"chunk: %d",
		"type: %d (%s)",
		"dp: %d %d",
		"cat: %d",
		newLine,
		"seg: %d"
	}, '\n')
	function Debug.BlockContextual(playerName, block)
		Interface:setView()
		
		Interface:addText(
			block_contextual:format(
				block.uniqueId, block.x, block.y,
				block.chunkId,
				block.type, tostring(blockMeta.maps[block.type]),
				block.dx, block.dy,
				block.category,
				block.segmentId
			),
			playerName,
			block.dxc, block.dyc,
			ccontxwidth, 0, 
			0x010101, 0x010101,
			0.5, false
		)
		
		Debug.Close(playerName, block.dxc + ccontxwidth - 25, block.dyc, false)
		
		return Interface:getIndex()
	end
	
	Interface.Debug = Debug
end