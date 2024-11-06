--- Sets the display state of a Chunk.
-- When active, all blocks corresponding to this Chunk will be
-- displayed, otherwise hidden. If active is **nil** then the Chunk
-- will hide and display to reload all displays.
-- @name Chunk:setDisplayState
-- @param Boolean:active Whether it should be active or not
function Chunk:setDisplayState(active, targetPlayer)
	local matrix = Map.blocks
	local deco = Map.decorations
	local mBlock, mDeco
	
	if active == nil then
		mBlock = Block.refreshDisplay
		mDeco = deco.implement.refreshDisplay
	else
		if active then
			mBlock = Block.display
			mDeco = deco.implement.display
		else
			mBlock = Block.hide
			mDeco = deco.implement.hide
			self.displaysTo = {}
		end
	end
	
	for y = self.yf, self.yb do
		for x = self.xf, self.xb do
			mBlock(matrix[y][x]) -- Block:[method]()
			mDeco(deco[y][x], targetPlayer)
		end
	end
	
	self.displayActive = (active ~= false)
	
	Map:setCounter("chunks_display", self.displayActive and 1 or -1, true)
	
	return self.displayActive
end

function Chunk:setDebugDisplay(active)
	if self.debugImageId then
		self.debugImageId = tfm.exec.removeImage(self.debugImageId, false)
	end
	
	if active then
		self.debugImageId = tfm.exec.addImage(
			"18675afb472.png", "!999999",
			self.dx, self.dy,
			nil,
			(self.width * REFERENCE_SCALE_X) + 0.125 * REFERENCE_SCALE_X,
			(self.height * REFERENCE_SCALE_Y) + 0.125 * REFERENCE_SCALE_Y,
			0, 0.37,
			0, 0,
			false
		)
	end
end