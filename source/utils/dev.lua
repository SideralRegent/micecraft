local devInstance = {}
devInstance.__index = devInstance

do
	local setmetatable = setmetatable
	local dummyFunc = function() end
	
	--[[
		Usage:
		
		local neighborChunks = devInstance:new(function(instance, vargs, mode, include)
			print("Called getChunksAround")
			local id = instance:addImage(...) -- will be deleted anyways on instance:cleanUp()
			instance:addTextArea(458139, ...)
		end)
		neighborChunks:injectTo(Chunk, "getChunksAround", true) -- in this case vargs = {}
		neighborChunks:injectTo(Chunk, "getChunksAround", false) -- in this case vargs = whatever getChunksAround returns
		
		-- Profit
		
		neighborChunks:ejectFrom(Chunk) -- to disable
	]]
	
	function devInstance:new(debugFunction)
		local this = setmetatable({
			implementedFunction = dummyFunc,
			debugFunction = debugFunction,
			replacementFunction = dummyFunc,
			res = {
				img = {},
				textArea = {}
			}
		}, self)
		
		this.__index = self
	end
	
	local next = next
	local removeImage = tfm.exec.removeImage
	local removeTextArea = ui.removeTextArea
	function devInstance:cleanUp()
		for id, _ in next, self.res.img do
			removeImage(id, false)
		end
		
		for id, _ in next, self.res.img do
			removeTextArea(id, nil)
		end
		
		self.res = {
			img = {},
			textArea = {}
		}
	end
	
	local addImage = tfm.exec.addImage
	function devInstance:addImage(...)
		local id = addImage(...)
		
		self.res.img[id] = true
		
		return id
	end
	
	local addTextArea = ui.addTextArea
	function devInstance:addTextArea(id, ...)
		addTextArea(id, ...)
		self.res.textArea[id] = true
		
		return id
	end
	
	function devInstance:setReplacementFunction(before)
		if before then
			self.replacementFunction = function(...)
				self:debugFunction({}, ...)
				return self.implementedFunction(...)
			end
		else
			self.replacementFunction = function(...)
				local a, b, c, d, e, f = self.implementedFunction(...)
				
				self:debugFunction({a, b, c, d, e, f}, ...)
				
				return a, b, c, d, e, f
			end
		end
	end
		
	function devInstance:overwrite(class)
		class[self.implementedName] = self.replacementFunction
	end
	
	function devInstance:prepareInjection(class, functionName, before)
		self.implementedName = functionName
		self.implementedFunction = class[functionName]
		
		self:setReplacementFunction(before)
	end
	
	function devInstance:injectTo(class, functionName, before)
		self:prepareInjection(class, functionName, before)
		self:overwrite(class)
		
		return self.replacementFunction
	end
	
	function devInstance:ejectFrom(class)
		class[self.implementedName] = self.implementedFunction
		
		self:cleanUp()
	end
end

local dev = {
	instances = {}
}

do
	local copy = table.copy
	function dev:newInstance(name, flags, class, functionName, before, debugFunction)
		local instance = devInstance:new(debugFunction)
		instance:prepareInjection(class, functionName, before)
		
		self.instances[name] = copy(flags)
		self.instances[name].value = instance
		
		return instance
	end

end

function dev:removeInstance(name)
	local instance = self.instances[name].value
	instance:cleanUp()
	
	self.instances[name] = nil
end