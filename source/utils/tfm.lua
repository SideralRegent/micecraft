do
	local iTextAreaCount = 100
	local ui_addTextArea = ui.addTextArea
	local ui_iaddTextArea = function(...)
		local old = iTextAreaCount
		ui_addTextArea(old, ...)
		iTextAreaCount = iTextAreaCount + 1
		
		return old
	end
	
	ui.iaddTextArea = ui_iaddTextArea
	
	local ui_ciaddTextArea = function(text, targetPlayer, x, y, width, height, alignX, alignY, ...)
		alignX = alignX or 0.0
		alignY = alignY or 0.0
		
		return ui_iaddTextArea(
			text, 
			targetPlayer, 
			x - (width * alignX),
			y - (height * alignY),
			width, height,
			...
		)
	end
	
	ui.ciaddTextArea = ui_ciaddTextArea
	
	local iPhysicObjectCount = 200
	local tfm_exec_addPhysicObject = tfm.exec.addPhysicObject
	function tfm.exec.iaddPhysicObject(...)
		local old = iPhysicObjectCount
		tfm_exec_addPhysicObject(old, ...)
		iPhysicObjectCount = iPhysicObjectCount + 1
		
		return old
	end
	
	local iPopupCount = 100
	local ui_addPopup = ui.addPopup
	local ui_iaddPopup = function(eventName, eventInfo, ...)
		local old = iPopupCount
		temp.popup[old] = {eventName, eventInfo}
		
		ui_addPopup(old, ...)
		iPopupCount = iPopupCount + 1
		
		return old
	end
	
	ui.iaddPopup = ui_iaddPopup
end