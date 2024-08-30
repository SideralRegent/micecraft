Module:on("ColorPicked", function(colorPickerId, playerName, color)
	if colorPickerId == 0x838 then
		ui.setBackgroundColor(("#%x"):format(color))
	end
end)