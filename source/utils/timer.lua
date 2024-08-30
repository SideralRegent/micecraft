do
	local setmetatable = setmetatable
	local max = math.max
	local time = os.time
	local print, tostring = print, tostring
	local pcall = pcall
	local unpack = table.unpack
	
	--- Creates a new Timer.
	-- Timers can wait an established amount of seconds before triggering a callback.
	-- @name Timer:new
	-- @param Int:awaitTime The time that the Timer should wait before executing, in milliseconds
	-- @param Boolean:loop Whether the timer should trigger repeatedly or once
	-- @param Function:callback The function to call when the Timer triggers
	-- @param Any:... Extra arguments for callback
	-- @return `Int` The internal identifier of the Timer
	function Timer:new(awaitTime, loop, callback, ...)
		local ms = max(awaitTime, 500)
		self.counter = self.counter + 1
		
		local this = {
			uniqueId = self.counter,
			
			awaitTime = ms,
			expireTime = time() + ms,
			isLooping = (not not loop),
			
			arguments = {...},
			
			renew = function(timer)
				if timer.isLooping then
					timer.expireTime = time() + timer.awaitTime
				end
			end,
			
			kill = function(timer, reason)
				if reason then
					print(("<FC>[Timer #%d]</FC> <J>%s</J>"):format(timer.uniqueId, tostring(reason)))
				end
				self.list[timer.uniqueId] = nil
				
			end,
			
			trigger = function(timer)
				local ok, result = pcall(timer.callback, unpack(timer.arguments))
				
				if ok then
					if timer.isLooping then
						timer:renew()
					else
						timer:kill()
					end
				else					
					timer:kill(result)
				end
				
				return ok, result
			end
		}

		self.list[this.uniqueId] = this
		
		return this.uniqueId
	end
end

--- Retrieves a Timer object.
-- @name Timer:get
-- @param Int:timerId The identifier of the Timer.
-- @return `Timer` The timer object
function Timer:get(timerId)
	return self.list[timerId]
end

--- Removes a Timer from the stack.
-- @name Timer:remove
-- @param Int:timerId The identifier of the Timer.
function Timer:remove(timerId)
	local this = self:get(timerId)
	
	if this then
		this:kill()
	end
end

do
	local time = os.time
	local unpack = table.unpack
	local next, ipairs = next, ipairs
	local pcall = pcall
	local keys = table.keys
	
	--- Handles the execution of all Timers present on the stack.
	-- The timers are called in protected mode, so if an error happens,
	-- the timer will be killed and the error wont be propagated.
	-- @name Timer:handle
	-- @return `Int` The amount of timers executed in this cycle.
	-- @return `Int` The amount of timers that had an error in this cycle.
	function Timer:handle()
		local rm = {}
		local ok
		
		local array = keys(self.list)
		local timer
		local executed = 0
		local crashed = 0
		for _, uniqueId in ipairs(array) do
			timer = self:get(uniqueId)
			
			if time() >= timer.expireTime then
				executed = executed + 1
				ok = timer:trigger()
				
				if not ok then
					crashed = crashed + 1
				end
			end
		end
		
		return executed, crashed
	end
end
