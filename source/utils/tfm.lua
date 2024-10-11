do
	local iTxCount = 100
	local fTx = ui.addTextArea
	function ui.iaddTextArea(...)
		local old = iTxCount
		fTx(old, ...)
		iTxCount = iTxCount + 1
		
		return old
	end
	
	local iPhObCount = 200
	local fPhOb = tfm.exec.addPhysicObject
	function tfm.exec.iaddPhysicObject(...)
		local old = iPhObCount
		fPhOb(old, ...)
		iPhObCount = iPhObCount + 1
		
		return old
	end
end