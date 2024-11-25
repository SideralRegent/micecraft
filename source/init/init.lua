local math, os, string, table =_G.math, _G.os, _G.string, _G.table
local debug, system, tfm, ui = _G.debug, _G.system, _G.tfm, _G.ui

local assert = _G.assert
local next, pcall, tonumber, tostring, type, setmetatable = _G.next, _G.pcall, _G.tonumber, _G.tostring, _G.type, _G.setmetatable

local currentTime = os.time

if tfm.get.room.name:lower():match("village") then
	system.exit()
end

local printf = function(str, ...)
	print(str:format(...))
end

--tfm.exec.chatMessage = print

math.randomseed(currentTime())

--- Crashes on the slightlest sign of a global.
-- We don't want globals in our code. They pollute the global environment,
-- are prone to cause memory leaks on the Lua VM, make debugging harder,
-- and unnecessarily increase the table accesses. Only Transformice events
-- should be globals, because that's the only way callbacks can be received.
-- @name _G.__newindex
-- @param Table:self Global space
-- @param Any:k Key
-- @param Any:v Value
do
	local rawset = rawset
	local error = error
	local setmetatable = setmetatable
	local tostring = tostring
	setmetatable(_G, {
		__newindex = function(self, k, v)
			if k:match("^event") then -- It's an Event (duh)
				rawset(self, k, v)
			else -- Not an Event. BAD GLOBAL !!
				while true do
					error(("NO GLOBALS ALLOWED !! Bad global: %q >:("):format(tostring(k)), 2)
				end
			end
		end
	})
end
--					Ca="" 
local xmlLoad = '<C><P L="%d" H="%d" /><Z><S></S><D><T X="%d" Y="%d" D="" /></D><O /></Z></C>'
--local xmlLoad = '<C><P Ca="" L="%d" H="%d"  /><Z><S></S><D><DS X="%d" Y="%d" /></D><O /></Z></C>'