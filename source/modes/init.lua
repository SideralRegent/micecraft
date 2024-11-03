function Mode:new(name, constructor)
	local this = setmetatable({
		name = name,
		environment = {},
		constructor = constructor,
		settings = {}
	}, self)
	
	return this
end

function Mode:constructor(g) -- Default
	print("dumb dumb, define this func !" .. tostring(g))
	-- Here you define the functions init, setMap, etc
	return {}  -- ...
end

function Mode:init()
	-- Here you init the Map and all stuff you need
	Map:setVariables(32, 32, 16, 16, 8, 8, 0, 200)
end

function Mode:setMap()
	-- Here you generate your Map
end

function Mode:run()
	-- Start your mode
	Module:on("NewPlayer", function(playerName)
		tfm.exec.chatMessage("I'm a default message. Say hi " .. playerName .."!", playerName)
	end)
end