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

local enum = {}

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