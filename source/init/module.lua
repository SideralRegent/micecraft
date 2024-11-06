--- Initializes the Module.
-- This function creates the table for the event list, the registers of
-- runtime and may be used to verify various other things. It should
-- only be called on pre-start, because it doesn't check if previous
-- values already exist, and may delete all of them.
-- @name Module:init
function Module:init()
	self.modeList = {}
	
	self.loader = select(2, pcall(nil)):match("^(.+)%.") or "server"
	
	self.eventList = {}
	self.currentCycle = 0
	self.cycleDuration = 4100
	
	self.runtimeLog = {}
	self.currentRuntime = 0
	self.runtimeLimit = 52
	
	self.isPaused = false
	
	self.args = {}
end

--- Asserts if API version matches the defined version for this Module.
-- In case it doesn't, a warning will be displayed for players to
-- inform the developer. 
-- @name Module:assertVersion
-- @param Unknown:apiVersion The defined API version that this Module has been updated for.
-- @param Unknown:tfmVersion The defined TFM version.
-- @return `Boolean` Whether the versions defined match
do
	local misc = tfm.get.misc
	function Module:assertVersion(apiVersion, tfmVersion)		
		self.apiVersion = apiVersion or misc.apiVersion
		self.tfmVersion = tostring(tfmVersion or misc.transformiceVersion)
		
		local apiMatch = (self.apiVersion == misc.apiVersion)
		local tfmMatch = (self.tfmVersion == tostring(misc.transformiceVersion))
		
		if not apiMatch then
			self:emitWarning(3, "Module API version mismatch")
		end
		
		if not tfmMatch then
			self:emitWarning(4, "Transformice version mismatch")
		end
		
		return (apiMatch and tfmMatch)
	end
end

do
	local colors = {
		"R",
		"O",
		"J",
		"V"
	}
	--- Emits a warning, as a message on chat, with the issue provided.
	-- @name Module:emitWarning
	-- @param Int:severity How severe is the warning. Accepts values from 1 to 4, being 1 the most severe and 4 the least severe.
	-- @param String:message The warning message to display.
	function Module:emitWarning(severity, message)
		message = message or "unknown"
		severity = severity or 4
		local color = colors[severity] or "V"
		
		local announce = ("<%s>[Warning]</%s> <N>%s</N>"):format(color, color, message)
		tfm.exec.chatMessage(announce)
		print(announce)
	end
end

do
	--- Triggers an exit of the proccess.
	-- It should only be called on special situations, as a server restart
	-- or a module crash. It will automatically save all the data that
	-- needs to be saved, in case the unload is 'handled'.
	-- @name Module:unload
	-- @param Boolean:handled Wheter the unloading is caused by a handled situation or not.
	-- @param String:errorMessage The reason of the error.
	-- @param Any:... Extra arguments
	function Module:unload(handled, errorMessage, ...)
		if handled then
			self:emitWarning(1, errorMessage, ...)
			
			system.exit()
			--while true do end
		else
			self:emitWarning(1, "The Module has been unloaded due to an uncatched exception.\nIssue: " .. (errorMessage or "Unknown"))
			system.exit()
		end
		
		--[[system.newTimer(function()
			while true do end
		end, 500, false)]]
	end
end

--- Callback when the Module crashes for any error.
-- @name Module:onError
-- @param String:errorMessage The reason of the error.
-- @param Any:... Extra arguments
function Module:onError(errorMessage, ...)
	-- Save data
	self:unload(true, errorMessage, ...)
end

--- Throws an exception report.
-- The exception can either be fatal or not, and the handling of
-- the Module against that exception will change accordingly.
-- @name Module:throwException
-- @param Boolean:fatal Wheter the Exception happened on a sensitive part of the Module or not
-- @param String:errorMessage The reason for this Exception
-- @param Any:... Extra arguments
function Module:throwException(fatal, errorMessage, ...)
	print(debug.traceback())
	if fatal then
		self:onError(errorMessage, ...)
	else
		self:emitWarning(1, errorMessage)
	end
end


local Event = {} -- Should this class be documented? No possible uses outside of **Module**...
Event.__index = Event

do
		local time = os.time
	local next = next
	local pcall = pcall
	local rawget = rawget
	local rawset = rawset
	local max = math.max
	local newTimer = system.newTimer
	
	local critical = {
		-- API
		["eventFileLoaded"] = true,
		["eventLoop"] = true,
		["eventNewGame"] = true,
		["eventNewPlayer"] = true,
		["eventPlayerLeft"] = true,
		["eventPlayerDataLoaded"] = true,
		
		-- Module
		["eventPause"] = true,
		["eventResume"] = true,
 	}
	
	local nativeEvents = {
		["ChatCommand"] = true,
		["ChatMessage"] = true,
		["ColorPicked"] = true,
		["ContactListener"] = true,
		["EmotePlayed"] = true,
		["FileLoaded"] = true,
		["FileSaved"] = true,
		["Keyboard"] = true,
		["Mouse"] = true,
		["Loop"] = true,
		["NewGame"] = true,
		["NewPlayer"] = true,
		["PlayerDataLoaded"] = true,
		["PlayerDied"] = true,
		["PlayerGetCheese"] = true,
		["PlayerBonusGrabbed"] = true,
		["PlayerLeft"] = true,
		["PlayerVampire"] = true,
		["PlayerWon"] = true,
		["PlayerRespawn"] = true,
		["PlayerMeep"] = true,
		["PopupAnswer"] = true,
		["SummoningCancel"] = true,
		["SummoningEnd"] = true,
		["SummoningStart"] = true,
		["TextAreaCallback"] = true,
		["TalkToNPC"] = true
	}
	function Event:new(eventName)
		local this = setmetatable({
			keyName = eventName,
			isNative = nativeEvents[eventName],
			calls = {}
		}, self)
		
		this.trigger = this.isNative and Event.triggerCount or Event.triggerUncount
		
		return this
	end

	function Event:append(callback)
		self.calls[#self.calls + 1] = callback
		
		return #self.calls
	end
	function Event:triggerUncount(...)
		for _, instance in next, self.calls do
			if not Module.isPaused then
				instance(...)
			end
		end
	end
	--[[
	-- pcall is for little kids
	function Event:triggerUncount(...)
		local ok, result
		
		for _, instance in next, self.calls do
			if not Module.isPaused then
				--ok = true
				--instance(...)
				ok, result = pcall(instance, ...)
				
				if not ok then
					return false, result
				end
			end
		end
		
		return true, "success"
	end
	]]
	
	function Event:triggerCount(...)
		local startTime
		
		for _, instance in next, self.calls do
			if not Module.isPaused then
				startTime = time()
				instance(...)
			--	print(("%s (%d) - %d"):format(self.keyName, _, time() - startTime))
				Module:increaseRuntime(time() - startTime)
			end
		end
	end
	--[[
	-- pcall is for little kids
	function Event:triggerCount(...)		
		local ok, result, startTime
		
		for _, instance in next, self.calls do
			if not Module.isPaused then
				startTime = time()
				--ok = true
				--instance(...)
				ok, result = pcall(instance, ...)
				
				if ok then
					Module:increaseRuntime(time() - startTime)
				else
					return false, result
				end
			end
		end
		
		return true, "success"
	end
	]]

	-- Gets the Event object by the event name provided.
	-- @name Module:getEvent
	-- @param String:eventName The name of the Event to get its object from.
	-- @return `Event|nil` The Event object, if it exists.
	function Module:getEvent(eventName)
		return self.eventList[eventName]
	end

	-- Tells if an Event has been defined on the module.
	-- @name Module:hasEvent
	-- @param String:eventName The name of the Event to assert.
	-- @return `Boolean` Whether the Event exists or not.
	function Module:hasEvent(eventName)
		return not not self:getEvent(eventName)
	end

	--- Creates a callback to trigger when an Event is emmited.
	-- In case the Event exists, it will append the callback to the
	-- internal list of the Event, so every callback will be executed
	-- on the order it is defined. Otherwise it doesn't exist, an
	-- Event object will be created, and the Event will be defined on
	-- the Global Space.
	-- @name Module:on
	-- @param String:eventName The name of the Event.
	-- @param Function:callback The callback to trigger.
	-- @return `Boolean` Whether a new Event object was created or not.
	-- @return `Number` The position of the callback in the calls list.
	function Module:on(eventName, callback)
		local createdNewObject, position
		local eventFullName = ("event%s"):format(eventName)

		if not self:hasEvent(eventName) then
			createdNewObject = self:addEvent(eventName)
			
			if nativeEvents[eventName] then
				rawset(_G, eventFullName, function(...)
					--if not self.isPaused then
						self:trigger(eventName, ...)
					--end
				end)
			else
				rawset(_G, eventFullName, function(...)
					self:trigger(eventName, ...)
				end)
			end
		end
		
		position = self:getEvent(eventName):append(callback)
		
		return createdNewObject, position
	end

	--- Adds an Event listener.
	-- It will create the Event object required, with the event name
	-- that has been provided.
	-- @name Module:addEvent
	-- @param String:eventName The name of the Event to create.
	-- @return `Boolean` Whether or not a new Event object has been created.
	function Module:addEvent(eventName)
		if not self:hasEvent(eventName) then
			self.eventList[eventName] = Event:new(eventName)
			
			return true
		end
		
		return false
	end
	
	--- Triggers the callbacks of an event emmited.
	-- This function should not be called manually. Also, since it only gets
	-- called inside a Module:on, it is guaranteed that the eventlistener will
	-- exist, thus no need to check for its validity.
	-- @name Module:trigger
	-- @param String:eventName The event to trigger.
	-- @return `Boolean` Whether the Event triggered without errors.
	function Module:trigger(eventName, ...)
		self:getEvent(eventName):trigger(...) -- dafuq?
		--[[local ok, result =
		if not ok then
			local isFatal = not not critical[eventName]
			self:throwException(isFatal, result)
		end
		
		return ok]]
	end
	
	--- Increases the runtime counter of the Module.
	-- It will also check if the runtime reaches the limit established for the
	-- module, and trigger a `Module Pause` in such case.
	-- @name Module:increaseRuntime
	-- @param Int:increment The amount of milliseconds to increment into the counter.
	-- @return `Boolean` Whether the increment in runtime has caused the Module to pause.
	local updateTextArea = ui.updateTextArea
	function Module:increaseRuntime(increment)
		self.currentRuntime = self.currentRuntime + increment
		
		updateTextArea(12, ("<font color='#000000'>%d ms"):format(self.currentRuntime), nil)
		
		if self.currentRuntime >= self.runtimeLimit then
			self:pause()
			
			return true
		end
		
		return false
	end

	--- Triggers a Module Pause.
	-- When it triggers, no events will be listened, and all objects will freeze.
	-- This function is automatically called by a runtime check when an event
	-- triggers, however, it `should` be safe to call it dinamically.
	-- After pausing, the Module will automatically ressume on the next cycle.
	-- @name Module:pause
	-- @return `Number` The time it will take to ressume the Module, in milliseconds.
	function Module:pause()
		local time = max(500, ((self.currentCycle + 1.25) * self.cycleDuration) - time())
		
		self.isPaused = true
		
		self:trigger("Pause", time)
		newTimer(function(_)
			self:continue()
		end, time, false)

		return time
	end

	--- Continues the Module execution.
	-- All events ressume listening, as well as players take back their movility.
	-- It will check if the Module is already paused, so it is safe to call it
	-- without previous checks.
	-- @name Module:continue
	-- @return `Boolean` Whether the Module has been resumed or not.
	function Module:continue()
		if self.isPaused then
			self.isPaused = false
			
			self:setCycle()
			
			self:trigger("Resume")
			
			return true
		end

		return false
	end

	--- Sets the appropiate Cycle of runtime checking.
	-- Whenever a new cycle occurs, the runtime counter will reset,
	-- and its fingerprint will log.
	-- @name Module:setCycle
	-- @return `Number` The current cycle.
	function Module:setCycle()
		local lastCycle = self.currentCycle
		
		self.currentCycle = math.ceil(currentTime() / self.cycleDuration)
		
		if self.currentCycle ~= lastCycle then
			self.runtimeLog[lastCycle] = self.currentRuntime
			
			self.currentRuntime = 0
		end
		
		return self.currentCycle
	end
	--[[
	function Module:setPercentageCounter()
		
	end

	function Module:updatePercentage(increment)

	end

	function Module:getDebugInfo()
		
	end]]

	--- Seeks for the player with the lowest latency to make them the sync, or establishes the selected one.
	-- @name Module:setSync
	-- @param String:playerName The Player to set as sync, if not provided then it will be picked automatically
	-- @return `String` The new sync.
	function Module:setSync(playerName) -- Seeks for the player with the lowest latency for syncing.
		if playerName then
			if not Room:hasPlayer(playerName) then
				playerName = nil
			end
		end
		
		if not playerName then
			local candidate, bestLatency = "", math.huge
			
			for playerName, player in next, tfm.get.room.playerList do
				if player.averageLatency <= bestLatency then
					bestLatency = player.averageLatency
					candidate = playerName
				end
			end
			
			playerName = candidate
		end
		
		tfm.exec.setPlayerSync(playerName)
		
		return playerName
	end

	function Module:newMode(modeName, constructor)
		self.modeList[modeName] = Mode:new(modeName, constructor)
	end

	function Module:getMode(modeName)
		modeName = modeName or self.subMode or ""
		return self.modeList[modeName] or self.modeList[modeName:lower()]
	end

	function Module:hasMode(modeName)
		return not not self:getMode(modeName or "")
	end
	
	function Module:setMode(modeName)
		local mode = self:getMode(modeName) or self:getMode("default")
		
		if mode then
			mode:constructor({ -- Proxy table
				__index = function(_, k)
					return rawget(mode.environment, k)
				end,
				__newindex = function(_, k, v)
					rawset(mode.environment, k, v)
				end
			})
			mode.__index = mode
		
			self.settings = mode.settings or {}
		end
		
		self.subMode = mode.name or "unknown"
		
		return mode
	end
end

do
	function Module:onUserInput(type, ...)
		local class = self.userInputClasses[type]
		
		class:new(...)
	end
end