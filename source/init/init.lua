local math, os, string, table =_G.math, _G.os, _G.string, _G.table
local debug, system, tfm, ui = _G.debug, _G.system, _G.tfm, _G.ui

local next, pcall, tonumber, tostring, type, setmetatable = _G.next, _G.pcall, _G.tonumber, _G.tostring, _G.type, _G.setmetatable
local currentTime = os.time

if tfm.get.room.name:lower():match("village") then
	system.exit()
end

tfm.exec.chatMessage = print

math.randomseed(currentTime())

--- Crashes on the slightlest sign of a global.
-- We don't want globals in our code. They pollute the global environment,
-- are prone to cause memory leaks on the Lua VM, make debugging harder,
-- and increases unnecessarily the table acceses. Only Transformice events
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
local xmlLoad = '<C><P Ca="" L="%d" H="%d" /><Z><S></S><D><T X="%d" Y="%d" D="" /></D><O /></Z></C>'
--local xmlLoad = '<C><P Ca="" L="%d" H="%d"  /><Z><S></S><D><DS X="%d" Y="%d" /></D><O /></Z></C>'

local Module = {
	version = "0.2.0-alpha",
	apiVersion = "",
	tfmVersion = "",
	
	modeList = {},
	
	eventList = {},
	currentCycle = 0,
	cycleDuration = 0,
	
	runtimeLog = {},
	currentTime = {},
	runtimeLimit = {},
	
	isPaused = false,
	args = {}
}

local Room = {
	playerList = {},
	presencePlayerList = {}
}

local Mode = {}

local enum = {}

-- local Ui = {}

local Block = {}
Block.__index = Block

local Chunk = {}
Chunk.__index = Chunk

local ChunkQueue = {
	name = "Chunk Queue",
	duplicates = false,
	stack = {},
	entries = {},
	buffer = {},
	defaultStep = 4
}
ChunkQueue.__index = ChunkQueue

local Map = {
	physicsMap = {},
	lightningMap = {},
	decorations = {},
	blocks = {},
	
	chunks = {},
	chunkLookup = {},
	
	counter = {},
	gravityForce = 0,
	windForce = 0
}

local World = {
	currentTime = 0,
}

local Field = {}

local Structures = {}
local Structure = {}
Structure.__index = Structure

local MetaData = {}
MetaData.__index = MetaData
local blockMetadata = {}

local Player = {}
Player.__index = Player

local Timer = {
	uniqueId = -1,
	list = {},
	counter = 0
}

--[[
local Debug = {
	fields = {}
}
]]

Timer.__index = Timer
local Tick = {
	current = 0,
	halted = 0,
	tps = 0,
	lastTickTimestamp = os.time(),
	lastTick = 0,
	slice = {},
	taskList = {}
}
Tick.__index = Tick