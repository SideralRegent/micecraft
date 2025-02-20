local Module = {
	version = "SCRIPT_VERSION",
	apiVersion = "",
	tfmVersion = "",
	
	modeList = {},
	
	eventList = {},
	currentCycle = 0,
	cycleDuration = 0,
	
	runtimeLog = {},
	currentTime = {},
	runtimeLimit = {},
	
	loader = "",
	lastMapLoad = 0,
	
	isPaused = false,
	args = {},
	
	userInputClasses = {
		
	}
}

local Interface = {
	object = {},
	settingIndex = 0,
	objAc = 0,
}

local Room = {
	playerList = {},
	presencePlayerList = {}
}

local Mode = {}

local mc = {}

-- local Ui = {}

local Matrix = {}
Matrix.__index = Matrix

local Block = {}
Block.__index = Block

local Chunk = {}
Chunk.__index = Chunk

local ChunkQueue = {
	name = "Chunk Queue", -- wth is this for?
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
	blocks = nil, -- ...
	
	chunks = nil, -- ...
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
local blockMeta = {}
local itemMeta = {}
local decoMeta = {}

local Item = {}
Item.__index = Item

local ItemContainer = {}
ItemContainer.__index = ItemContainer

local ItemBank = {}
ItemBank.__index = ItemBank

local SelectFrame = {}
SelectFrame.__index = SelectFrame

local IEntity = {}

local Player = setmetatable({}, {__index = IEntity})
Player.__index = Player
--[[
do
local NOISE = {
checkForCurrentChunk = true,
tfmUpdateInformation = true,
updatePosition = true,
setClock = true,
runEvents = true,	
updateDirection = true,
getNearChunks = true,
queueNearChunks = true,
updateChunkArea = true
}
Player.__index = function(t, k)
	local v = rawget(t, k) or rawget(Player, k)
	if type(v) == "function" then
		return function(p, ...)
			if p.name == "Nazrin#4663" and not NOISE[k] then
				local args = {...}
				for i = 1, #args do
					args[i] = tostring(args[i])
				end
				
				printf("%s:%s(%s)", p.name, k, table.concat(args, ", "))
			end
			return v(p, ...)
		end
	end
	
	return v
end
end --]]

--Player

local PlayerInventory = {}
PlayerInventory.__index = PlayerInventory

local Timer = {
	uniqueId = -1,
	list = {},
	counter = 0
}
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

local temp = {
	popup = {}
} -- garbage goes here

local Translations = {
	default = 'en'
}