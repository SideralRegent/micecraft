function Ui.Template:new(identifier, parent)
	local this = parent:new()
	setmetatable(this, self)
	this.__index = self
	
	return this
end