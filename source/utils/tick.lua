--- Steps the specified amount of Ticks.
-- If the amount is just 1, then the Timer will just increase. Otherwise,
-- it will execute all the tasks for the next ticks.
-- @name Tick:step
-- @param Int:amount The amount of steps to make.
function Tick:step(amount)
	amount = amount or 1
	if amount > 1 then
		for _ = 1, amount do
			self:handle()
		end
	else
		self.current = self.current + amount
	end
end

do
	local setmetatable = setmetatable
	local copy = table.copy
	local next = next
	
	local Task = {
		counter = 0,
		uniqueId = 0,
		sliceInternalId = 0,
		awaitTicks = 0,
		tickTarget = 0,
		shouldLoop = false,
		callback = nil,
		args = {}
	}
	Task.__index = Task
	
	--- Creates a new Task object.
	-- Tasks are used as an abstraction layer for executing events with a delay
	-- on a controlated environment.
	-- @name Task:new
	-- @param Int:awaitTicks The ticks that the task should await before executing
	-- @param Boolean:shouldLoop Whether the specified task should be executed repeatedly or only once
	-- @param Function:callback The task to execute
	-- @param Any:... Extra arguments for task
	-- @return `Task` A Task object.
	function Task:new(awaitTicks, shouldLoop, callback, ...)
		self.counter = self.counter + 1
		return setmetatable({
			uniqueId = self.counter,
			sliceInternalId = 0,
			awaitTicks = awaitTicks or 1,
			tickTarget = Tick.current + awaitTicks,
			
			shouldLoop = shouldLoop or false,
			
			callback = callback,
			args = {...}
		}, self)
	end
	
	--- Renews a Task execution time.
	-- The new time will be the current tick, plus the assigned ticks of delay.
	-- @name Task:renew
	-- @return `Int` The new tick were the Task will be executed
	function Task:renew()
		self.tickTarget = Tick.current + self.awaitTicks
		Tick:setTaskTime(self.uniqueId, self.tickTarget)
		
		return self.tickTarget
	end
	
	--- Destroys a Task object.
	-- @name Task:kill
	-- @param String:reason The reason for the call. Used internally only when an error happens
	local print, tostring = print, tostring
	function Task:kill(reason)
		if reason then
			print(("<b><ROSE>[Task #%d]</ROSE></b> <VI>%s</VI>"):format(self.uniqueId, tostring(reason)))
		end
		
		Tick:removeTask(self.uniqueId)
	end
	
	
	--- Executes the callback of the Task.
	-- @name Task:execute
	-- @return `Boolean` Whether the task has been renewed or not
	local pcall = pcall
	local unpack = table.unpack
	local time = os.time
	function Task:execute()
		local ok, result = pcall(self.callback, unpack(self.args))
		
		if ok then
			if self.shouldLoop then
				self:renew()
				
				return false
			else
				self:kill()
			end
		else
			self:kill(result)
		end
		
		return true
	end
	
	--- Creates a new Slice.
	-- Slices consist of lookup tables with identifiers of the Task that need
	-- to be executed at an exact tick. A slice is, thus, the list of tasks
	-- for a specific tick.
	-- @name Tick.slice:new
	-- @param Int:tick The tick for which this slice belongs to
	function Tick.slice:new(tick)
		self[tick] = {
			tickId = tick,
			tasks = {},
			
			runtimeLapse = 0,
			
			counter = 0,
			pending = 0,
			
			queue = function(this, taskId)
				this.counter = this.counter + 1
				if not this.tasks[taskId] then
					this.tasks[taskId] = true
					this.pending = this.pending + 1
				end
		
				return this.counter
			end,
			
			pop = function(this, taskId)
				if this.tasks[taskId] then					
					this.pending = this.pending - 1
				end
				
				this.tasks[taskId] = nil
			end,
			
			execute = function(this)
				this.runtimeLapse = 0
				local list = copy(this.tasks)
				
				local startTime = 0
				local task
				
				for taskId in next, list do
					startTime = time()
					
					task = Tick:getTask(taskId)
					
					if task then
						task:execute()
						this:pop(taskId)
					else
						this.pending = this.pending - 1
						this.tasks[taskId] = nil
					end
					
					this.runtimeLapse = time() - startTime
					
					if this.runtimeLapse > 4 then
						break
					end
				end
				
				return (this.pending <= 0), this.runtimeLapse
			end
		}
	end
	
	--- Adds a Task to a Slice's stack.
	-- @name Tick.slice:addTask
	-- @param Int:tick The identifier of the slice
	-- @param Int:taskId The identifier of the Task
	-- @return `Int` The internal position of the task in the Slice's stack.
	function Tick.slice:addTask(tick, taskId)
		if not self[tick] then
			self:new(tick)
		end
		
		return self[tick]:queue(taskId)
	end
	
	--- Retrieves a Slice object.
	-- @name Tick.slice:get
	-- @param Int:tick The identifier of the slice
	-- @return `Slice` A Slice object, if it exists.
	function Tick.slice:get(tick)
		return self[tick]
	end
	
	--- Deletes a Slice object.
	-- @name Tick.slice:remove
	-- @param Int:tick The identifier of the slice
	function Tick.slice:remove(tick)
		self[tick] = nil
	end
	
	--- Adds a New Task to the stack.
	-- @name Tick:newTask
	-- @param Int:awaitTicks The ticks that the task should await before executing
	-- @param Boolean:shouldLoop Whether the specified task should be executed repeatedly or only once
	-- @param Function:callback The task to execute
	-- @param Any:... Extra arguments for task
	-- @return `Int` The identifier of the Task.
	function Tick:newTask(awaitTicks, shouldLoop, callback, ...)
		local task = Task:new(awaitTicks, shouldLoop, callback, ...)
		
		self.taskList[task.uniqueId] = task
		self.slice:addTask(task.tickTarget, task.uniqueId)
		
		return task.uniqueId
	end
	
	--- Retrieves a Task object.
	-- @name Tick:getTask
	-- @param Int:taskId The identifier of the Task object
	-- @return `Task` The task Object, if it exists.
	function Tick:getTask(taskId)
		return self.taskList[taskId]
	end
	
	--- Removes a Task from the stack.
	-- @name Tick:removeTask
	-- @param Int:taskId The identifier of the Task
	function Tick:removeTask(taskId)
		self.taskList[taskId or -1] = nil
	end
	
	--- Sets a new time for the specified Task.
	-- @name Tick:setTaskTime
	-- @param Int:taskId The identifier of the Task
	-- @param Int:tick The tick were that task should execute
	-- @return `Boolean` Whether the time was successfully set or not
	function Tick:setTaskTime(taskId, tick)
		local task = self.taskList[taskId]
		
		if task then
			self.slice:addTask(tick, taskId)
			
			return true
		end
		
		return false
	end
	
	--- Handles the execution of all Tasks scheduled for a tick.
	-- A tick doesn't end unless all tasks have been executed.
	-- @name Tick:handle
	-- @return `Boolean` Whether the tick has stepped one (1) unit or not.
	function Tick:handle()
		local slice = self.slice:get(self.current)
		local completed, lapse = true
		if slice then
			completed, lapse = slice:execute()
		end
		
		if completed then
			self.halted = 0
			
			self.lastTick = time() - self.lastTickTimestamp 
			self.lastTickTimestamp = time()
			
			self.slice:remove(self.current)
			
			self:step(1)
		else
			self.halted = self.halted + 1
			
			if self.halted >= 20 then -- The tick system is being halted
				self.slice:remove(self.current)
			end
		end
		
		return completed, lapse
	end
end