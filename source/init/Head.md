# Head

---

### **Module:init** (  )
Initializes the Module. This function creates the table for the event list, the registers of runtime and may be used to verify various other things. It should only be called on pre-start, because it doesn't check if previous values already exist, and may delete all of them.

---

### **Module:assertVersion** ( apiVersion, tfmVersion )
Asserts if API version matches the defined version for this Module. In case it doesn't, a warning will be displayed for players to inform the developer. 

**Parameters:**
- **apiVersion** (`Unknown`) : The defined API version that this Module has been updated for.
- **tfmVersion** (`Unknown`) : The defined TFM version.

**Returns:**
- `Boolean` Whether the versions defined match

---

### **Module:emitWarning** ( severity, message )
Emits a warning, as a message on chat, with the issue provided. 

**Parameters:**
- **severity** (`Int`) : How severe is the warning. Accepts values from 1 to 4, being 1 the most severe and 4 the least severe.
- **message** (`String`) : The warning message to display.

---

### **Module:unload** ( handled, errorMessage, ... )
Triggers an exit of the proccess. It should only be called on special situations, as a server restart or a module crash. It will automatically save all the data that needs to be saved, in case the unload is 'handled'.

**Parameters:**
- **handled** (`Boolean`) : Wheter the unloading is caused by a handled situation or not.
- **errorMessage** (`String`) : The reason of the error.
- **...** (`Any`) : Extra arguments

---

### **Module:onError** ( errorMessage, ... )
Callback when the Module crashes for any error. Save data

**Parameters:**
- **errorMessage** (`String`) : The reason of the error.
- **...** (`Any`) : Extra arguments

---

### **Module:throwException** ( fatal, errorMessage, ... )
Throws an exception report. The exception can either be fatal or not, and the handling of the Module against that exception will change accordingly.

**Parameters:**
- **fatal** (`Boolean`) : Wheter the Exception happened on a sensitive part of the Module or not (throws error screen)
- **errorMessage** (`String`) : The reason for this Exception
- **...** (`Any`) : Extra arguments

---

### **Module:log** ( level, errorMessage, ... )
Logs an error. Errors will be stored in a table, as given, with the fields 'level', 'message' & 'args' (if any).

**Parameters:**
- **level** (`Int`) : Severity of this error. See Module:emitWarning
- **errorMessage** (`String`) : The reason for this Exception
- **...** (`Any`) : Extra arguments

---

### **Module:logf** ( level, errorMessage, ... )
Logs an error with a formatted string. See Module:log.

**Parameters:**
- **level** (`Int`) : Severity of this error. See Module:emitWarning
- **errorMessage** (`String`) : The reason for this Exception
- **...** (`Any`) : Extra arguments to format errorMessage

---

### **Module:on** ( eventName, callback )
Creates a callback to trigger when an Event is emmited. In case the Event exists, it will append the callback to the internal list of the Event, so every callback will be executed on the order it is defined. Otherwise it doesn't exist, an Event object will be created, and the Event will be defined on the Global Space.

**Parameters:**
- **eventName** (`String`) : The name of the Event.
- **callback** (`Function`) : The callback to trigger.

**Returns:**
- `Boolean` Whether a new Event object was created or not.
- `Number` The position of the callback in the calls list.

---

### **Module:addEvent** ( eventName )
Adds an Event listener. It will create the Event object required, with the event name that has been provided.

**Parameters:**
- **eventName** (`String`) : The name of the Event to create.

**Returns:**
- `Boolean` Whether or not a new Event object has been created.

---

### **Module:trigger** ( eventName )
Triggers the callbacks of an event emmited. This function should not be called manually. Also, since it only gets called inside a Module:on, it is guaranteed that the eventlistener will exist, thus no need to check for its validity.

**Parameters:**
- **eventName** (`String`) : The event to trigger.

**Returns:**
- `Boolean` Whether the Event triggered without errors.

---

### **Module:increaseRuntime** ( increment )
Increases the runtime counter of the Module. It will also check if the runtime reaches the limit established for the module, and trigger a `Module Pause` in such case.

**Parameters:**
- **increment** (`Int`) : The amount of milliseconds to increment into the counter.

**Returns:**
- `Boolean` Whether the increment in runtime has caused the Module to pause.

---

### **Module:pause** (  )
Triggers a Module Pause. When it triggers, no events will be listened, and all objects will freeze. This function is automatically called by a runtime check when an event triggers, however, it `should` be safe to call it dinamically. After pausing, the Module will automatically ressume on the next cycle.

**Returns:**
- `Number` The time it will take to ressume the Module, in milliseconds.

---

### **Module:continue** (  )
Continues the Module execution. All events ressume listening, as well as players take back their movility. It will check if the Module is already paused, so it is safe to call it without previous checks.

**Returns:**
- `Boolean` Whether the Module has been resumed or not.

---

### **Module:setCycle** (  )
Sets the appropiate Cycle of runtime checking. Whenever a new cycle occurs, the runtime counter will reset, and its fingerprint will log.

**Returns:**
- `Number` The current cycle.

---

### **Module:setSync** ( playerName )
Seeks for the player with the lowest latency to make them the sync, or establishes the selected one. 

**Parameters:**
- **playerName** (`String`) : The Player to set as sync, if not provided then it will be picked automatically

**Returns:**
- `String` The new sync.