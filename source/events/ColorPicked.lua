Module:on("ColorPicked", function(colorPickerId, _, color)
	if colorPickerId == 0x838 then
		ui.setBackgroundColor(("#%x"):format(color))
	end
end)