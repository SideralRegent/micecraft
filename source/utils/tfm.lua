do
	local counter = 100
	local f = ui.addTextArea
	function ui.iaddTextArea(...)
		local old = counter
		f(old, ...)
		counter = counter + 1
		
		return old
	end
end