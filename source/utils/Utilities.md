# Utilities

---

### **math.round** ( `n`: number )
Rounds a number to the nearest integer. For numbers with decimal digit under 0.5, it will floor that number, and for numbers over 0.5 it will ceil that number.

**Parameters:**
- **n** (`Number`) : The number to round

**Returns:**
- `Number` The number rounded.

---

### **math.restrict** ( `number`: number, `lower`: number, `higher`: number )
Restrict the given input between two limits. 

**Parameters:**
- **number** (`Number`) : The number to restrict
- **lower** (`Number`) : The lower limit
- **higher** (`Number`) : The higher limit

**Returns:**
- `Number` The number between the specified range.

---

### **math.pythag** ( `ax`: number, `ay`: number, `bx`: number, `by`: number )
Returns the distance between two points on a cartesian plane. 

**Parameters:**
- **ax** (`Number`) : The horizontal coordinate of the first point
- **ay** (`Number`) : The vertical coordinate of the first point
- **bx** (`Number`) : The horizontal coordinate of the second point
- **by** (`Number`) : The vertical coordinate of the second point

**Returns:**
- `Number` The distance between both points.

---

### **math.udist** ( `a`: number, `b`: number )
Returns the absolute difference between two numbers. 

**Parameters:**
- **a** (`Number`) : The first number
- **b** (`Number`) : The second number

**Returns:**
- `Number` The absolute difference.

---

### **math.precision** ( `number`: number, `precision`: int )
Rounds a number to the specified level of precision. The precision is the amount of decimal points after the integer part.

**Parameters:**
- **number** (`Number`) : The number to correct precision
- **precision** (`Int`) : The decimal digits of precision that this number will have

**Returns:**
- `Number` The number with the corrected precision.

---

### **math.tobase** ( `number`: number, `base`: int )
Converts a number to a string representation in another base. The base can be as lower as 2 or as higher as 64, otherwise it returns nil.

**Parameters:**
- **number** (`Number`) : The number to convert
- **base** (`Int`) : The base to convert this number to

**Returns:**
- `String` The number converted to the specified base.

---

### **math.tonumber** ( `str`: string, `base`: int )
Converts a string to a number, if possible. The base can be as lower as 2 or as higher as 64, otherwise it returns nil. When bases are equal or lower than 36, it uses the native Lua `tonumber` method.

**Parameters:**
- **str** (`String`) : The string to convert
- **base** (`Int`) : The base to convert this string to number

**Returns:**
- `String` The string converted to number from the specified base.

---

### **math.cosint** ( `a`: number, `b`: number, `s`: number )
Interpolates two points with a cosine curve. 

**Parameters:**
- **a** (`Number`) : First Point
- **b** (`Number`) : Second point
- **s** (`Number`) : Curve size

**Returns:**
- `Number` Resultant point with value interpolated through cosine function.

---

### **math.heightMap** ( `amplitude`: number, `waveLenght`: number, `width`: int, `offset`: number, `lower`: number, `higher`: number )
Generates a Height Map based on the current `random seed`. 

**Parameters:**
- **amplitude** (`Number`) : How tall can a wave be
- **waveLenght** (`Number`) : How wide will a wave be
- **width** (`Int`) : How large should the height map be
- **offset** (`Number`) : Overall height for which map will be increased
- **lower** (`Number`) : The lower limit of height
- **higher** (`Number`) : The higher limit of height

**Returns:**
- `Table` An array that contains each point of the height map.

---

### **nil** (  )
Combines two Height maps based on the operation provided. The built-in operations are: `sum`, `sub`, `mul`, `div`.

---

### **math.stretchMap** ( `ls`: table, `mul`: int )
Stretches a height map, or array with numerical values. 

**Parameters:**
- **ls** (`Table`) : The array to stretch.
- **mul** (`Int`) : How much should it be stretched

**Returns:**
- `Table` The array stretched

---

### **table.isEmpty** ( `t`: table )
Checks if the Table has no elements. 

**Parameters:**
- **t** (`Table`) : The table to check

**Returns:**
- `Boolean` Whether the Table is empty or not.

---

### **table.copy** ( `t`: table )
Copies a table and all its values recursively. It avoids keeping references over values.

**Parameters:**
- **t** (`Table`) : The table to copy

**Returns:**
- `Table` The table copied.

---

### **table.append** ( `t`: table, `...`: table )
Appends two numerical tables 

**Parameters:**
- **t** (`Table`) : The first table
- **...** (`Table`) : Other tables to append

**Returns:**
- `Table` The new table.

---

### **table.inherit** ( `t`: table, `ex`: table )
Inhertis all values to a table, from the specified one. It does not modify the original tables, but copies them, to avoid links. All values to inherit will overwrite values on the target table.

**Parameters:**
- **t** (`Table`) : The table for which values will be inherited.
- **ex** (`Table`) : The table to inherit values from.

**Returns:**
- `Table` The new child table, product of the tables provided.

---

### **table.find** ( `t`: table, `e`: any )
Searches for a value across a table. Will return the first index of where it was found, otherwise returns nil.

**Parameters:**
- **t** (`Table`) : The table to search the value into.
- **e** (`Any`) : The element to search into the table.

**Returns:**
- `Any` The key or index where the element was found.
- `Any` The element specified.

---

### **table.kfind** ( `t`: table, `key`: any, `e`: any )
Searches for a value, but in a depth of 1 index. Refer to table.find for more information.

**Parameters:**
- **t** (`Table`) : The table to search the value into.
- **key** (`Any`) : The key to search from all elements.
- **e** (`Any`) : The element to search into the table.

**Returns:**
- `Any` The key or index where the element was found.
- `Any` The element specified.

---

### **table.extract** ( `t`: table, `e`: any )
Extracts a value from the given table. 

**Parameters:**
- **t** (`Table`) : The table to extract the value from
- **e** (`Any`) : The value to extract from the table

**Returns:**
- `Any` The index were the value was found 
- `Table` The table 

---

### **table.keys** ( `t`: table )
Returns an array with all the keys/indexes from the given table. 

**Parameters:**
- **t** (`Table`) : The table to get keys from

**Returns:**
- `Table` The array with the keys.

---

### **table.count** ( `t`: table )
Counts all entries in a Table. 

**Parameters:**
- **t** (`Table`) : The table to count values on

**Returns:**
- `Int` The amount of entries

---

### **table.copykeys** ( `t`: table, `v`: any )
Copies all the keys from the table and assigns them the value given. 

**Parameters:**
- **t** (`Table`) : The table to copy keys from
- **v** (`Any`) : The value to assign to the keys

**Returns:**
- `Table` The table with the keys.

---

### **table.random** ( `t`: table, `associative`: boolean )
Gives the value of a random entry from the table. If the table is associative it converts the keys to an array.

**Parameters:**
- **t** (`Table`) : The table to get the random element from
- **associative** (`Boolean`) : Wheter the table is associative or numerical

**Returns:**
- `Any` The random value
- `Any` The index were it was picked from

---

### **table.tostring** ( `value`: table|any, `tb`: int, `seen`: table )
Converts a table to a string, in a reasonable format. TODO: Add special parsing for keys.

**Parameters:**
- **value** (`Table|Any`) : The table to convert to string
- **tb** (`Int`) : The depth in the table
- **seen** (`Table`) : A list of tables that have been seen when iterating

**Returns:**
- `String` The value converted to string

---

### **table.print** ( `t`: table )
Prints a table. 

**Parameters:**
- **t** (`Table`) : The table to print

---

### **data.getFromModule** ( `str`: string, `m_id`: string )
Gives the specific data of a module from an encoded string. 

**Parameters:**
- **str** (`String`) : The data to search into
- **m_id** (`String`) : The module identificator, being at least three uppercase characters.

**Returns:**
- `String` The raw data for this module, otherwise an empty string.

---

### **data.setToModule** ( `str`: string, `m_id`: string, `rawdata`: string )
Sets the data to the specified module on an encoded string 

**Parameters:**
- **str** (`String`) : The complete raw data
- **m_id** (`String`) : The module identifier
- **rawdata** (`String`) : The raw data to apply to the specified module

**Returns:**
- `String` The new encoded data
- `String` The new raw data for the module
- `String` The old encoded data
- `String` The old raw data for the module

---

### **data.decode** ( `str`: string, `depth`: int )
Decodes a piece of raw data. 

**Parameters:**
- **str** (`String`) : The raw data
- **depth** (`Int`) : The depth to look at, in case it's a table.

**Returns:**
- `Table` The table with the data.

---

### **data.parse** ( `str`: string, `depth`: int )
Parses a value encoded or compressed. 

**Parameters:**
- **str** (`String`) : The encoded data.
- **depth** (`Int`) : The deep to look at, in case it's a Table

**Returns:**
- `Any` The value decoded.

---

### **data.serialize** ( `this`: any, `depth`: int )
Encondes a value into a reasonable format. 

**Parameters:**
- **this** (`Any`) : The value to convert
- **depth** (`Int`) : The depth to encode at, in case it's a table

**Returns:**
- `String` The value encoded.

---

### **data.encode** ( `this`: table, `depth`: int )
Encodes a table into a reasonable format. 

**Parameters:**
- **this** (`Table`) : The table to encode
- **depth** (`Int`) : The depth to encode at (by default it's 1)

**Returns:**
- `String` The encoded table

---

### **Timer:new** ( `awaitTime`: int, `loop`: boolean, `callback`: function, `...`: any )
Creates a new Timer. Timers can wait an established amount of seconds before triggering a callback.

**Parameters:**
- **awaitTime** (`Int`) : The time that the Timer should wait before executing, in milliseconds
- **loop** (`Boolean`) : Whether the timer should trigger repeatedly or once
- **callback** (`Function`) : The function to call when the Timer triggers
- **...** (`Any`) : Extra arguments for callback

**Returns:**
- `Int` The internal identifier of the Timer

---

### **Timer:get** ( `timerId`: int )
Retrieves a Timer object. 

**Parameters:**
- **timerId** (`Int`) : The identifier of the Timer.

**Returns:**
- `Timer` The timer object

---

### **Timer:remove** ( `timerId`: int )
Removes a Timer from the stack. 

**Parameters:**
- **timerId** (`Int`) : The identifier of the Timer.

---

### **Timer:handle** (  )
Handles the execution of all Timers present on the stack. The timers are called in protected mode, so if an error happens, the timer will be killed and the error wont be propagated.

**Returns:**
- `Int` The amount of timers executed in this cycle.
- `Int` The amount of timers that had an error in this cycle.

---

### **Tick:step** ( `amount`: int )
Steps the specified amount of Ticks. If the amount is just 1, then the Timer will just increase. Otherwise, it will execute all the tasks for the next ticks.

**Parameters:**
- **amount** (`Int`) : The amount of steps to make.

---

### **Task:new** ( `awaitTicks`: int, `shouldLoop`: boolean, `callback`: function, `...`: any )
Creates a new Task object. Tasks are used as an abstraction layer for executing events with a delay on a controlated environment.

**Parameters:**
- **awaitTicks** (`Int`) : The ticks that the task should await before executing
- **shouldLoop** (`Boolean`) : Whether the specified task should be executed repeatedly or only once
- **callback** (`Function`) : The task to execute
- **...** (`Any`) : Extra arguments for task

**Returns:**
- `Task` A Task object.

---

### **Task:renew** (  )
Renews a Task execution time. The new time will be the current tick, plus the assigned ticks of delay.

**Returns:**
- `Int` The new tick were the Task will be executed

---

### **Task:kill** ( `reason`: string )
Destroys a Task object. 

**Parameters:**
- **reason** (`String`) : The reason for the call. Used internally only when an error happens

---

### **Task:execute** (  )
Executes the callback of the Task. 

**Returns:**
- `Boolean` Whether the task has been renewed or not

---

### **Tick.slice:new** ( `tick`: int )
Creates a new Slice. Slices consist of lookup tables with identifiers of the Task that need to be executed at an exact tick. A slice is, thus, the list of tasks for a specific tick.

**Parameters:**
- **tick** (`Int`) : The tick for which this slice belongs to

---

### **Tick.slice:addTask** ( `tick`: int, `taskId`: int )
Adds a Task to a Slice's stack. 

**Parameters:**
- **tick** (`Int`) : The identifier of the slice
- **taskId** (`Int`) : The identifier of the Task

**Returns:**
- `Int` The internal position of the task in the Slice's stack.

---

### **Tick.slice:get** ( `tick`: int )
Retrieves a Slice object. 

**Parameters:**
- **tick** (`Int`) : The identifier of the slice

**Returns:**
- `Slice` A Slice object, if it exists.

---

### **Tick.slice:remove** ( `tick`: int )
Deletes a Slice object. 

**Parameters:**
- **tick** (`Int`) : The identifier of the slice

---

### **Tick:newTask** ( `awaitTicks`: int, `shouldLoop`: boolean, `callback`: function, `...`: any )
Adds a New Task to the stack. 

**Parameters:**
- **awaitTicks** (`Int`) : The ticks that the task should await before executing
- **shouldLoop** (`Boolean`) : Whether the specified task should be executed repeatedly or only once
- **callback** (`Function`) : The task to execute
- **...** (`Any`) : Extra arguments for task

**Returns:**
- `Int` The identifier of the Task.

---

### **Tick:getTask** ( `taskId`: int )
Retrieves a Task object. 

**Parameters:**
- **taskId** (`Int`) : The identifier of the Task object

**Returns:**
- `Task` The task Object, if it exists.

---

### **Tick:removeTask** ( `taskId`: int )
Removes a Task from the stack. 

**Parameters:**
- **taskId** (`Int`) : The identifier of the Task

---

### **Tick:setTaskTime** ( `taskId`: int, `tick`: int )
Sets a new time for the specified Task. 

**Parameters:**
- **taskId** (`Int`) : The identifier of the Task
- **tick** (`Int`) : The tick were that task should execute

**Returns:**
- `Boolean` Whether the time was successfully set or not

---

### **Tick:handle** (  )
Handles the execution of all Tasks scheduled for a tick. A tick doesn't end unless all tasks have been executed.

**Returns:**
- `Boolean` Whether the tick has stepped one (1) unit or not.