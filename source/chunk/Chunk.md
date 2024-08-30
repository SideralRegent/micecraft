# Chunk

---

### **Chunk:new** ( `uniqueId`: int, `x`: int, `y`: int, `width`: int, `height`: int, `xFact`: int, `yFact`: int, `dx`: int, `dy`: int, `biome`: int )
Creates a new Chunk object. A chunk can hold information about blocks and items within a certain range, as well as collision information and other stuff.


**Parameters:**
- **uniqueId** (`Int`) : The unique identifier of the Chunk
- **x** (`Int`) : The horizontal position of the Chunk in the Map matrix
- **y** (`Int`) : The vertical position of the Chunk in the Map matrix
- **width** (`Int`) : The width of the Chunk, in blocks
- **height** (`Int`) : The height of the Chunk, in blocks
- **xFact** (`Int`) : The left position of the first block that corresponds to this chunk in the Map matrix
- **yFact** (`Int`) : The top position of the same block
- **dx** (`Int`) : The horizontal position of the Chunk, in pixels
- **dy** (`Int`) : The vertical position of the Chunk, in pixels
- **biome** (`Int`) : An identifier of the biome that corresponds to this Chunk


**Returns:**
- `Chunk` A new Chunk object.

---

### **Chunk:setSegment** ( `description`: table )
Creates a new Segment object, with the description provided 


**Parameters:**
- **description** (`Table`) : The description for the Segment to be created

---

### **Chunk:deleteSegment** ( `segmentId`: int )
Deletes a Segment from the Chunk. All blocks for which this Segment was attached will be deattached and their physic state will be reset.


**Parameters:**
- **segmentId** (`Int`) : The identifier of the Segment


**Returns:**
- `Int` The left-most block coordinate of the Segment
- `Int` The top-most coordinate
- `Int` The right-most coordinate
- `Int` The down-most coordinate
- `Int` The category that this segment had

---

### **Chunk:getCollisions** ( `mode`: string, `xStart`: int, `xEnd`: int, `yStart`: int, `yEnd`: int, `categories`: table )
Gets the collisions from a Chunk. For blocks that don't have a segment assigned, it will calculate their collisions and assign them a new Segment.


**Parameters:**
- **mode** (`String`) : The coordinate calculation mode
- **xStart** (`Int`) : The left-most block coordinates to calculate
- **xEnd** (`Int`) : The right-most coordinates
- **yStart** (`Int`) : The top-most coordinates
- **yEnd** (`Int`) : The down-most coordinates
- **categories** (`Table`) : A list with the categories that should be matched


**Returns:**
- `Table` A list with new Segments created

---

### **Chunk:setPhysicState** ( `active`: boolean, `segmentList`: table )
Sets the state for the physics of the Chunk or some of its segments. 


**Parameters:**
- **active** (`Boolean`) : Whether the collisions should be active or not
- **segmentList** (`Table`) : An associative list with the Segments that should change their physic state


**Returns:**
- `Boolean` The state of the physics in the Chunk

---

### **Chunk:refreshPhysics** ( `mode`: string, `segmentList`: table, `update`: boolean, `origin`: table )
Recalculates the collisions of the given segments, or the whole chunk. 


**Parameters:**
- **mode** (`String`) : The algorithm to calculate collisions with
- **segmentList** (`Table`) : An associative Table with all the segments that need their physics to be reloaded
- **update** (`Boolean`) : Whether 
- **origin** (`Table`) : A table with the strucutre `{xStart=Int, xEnd=Int, yStart=Int, yEnd=Int, category=Int}` that corresponds to the Block(s) that asked for refresh

---

### **Chunk:clear** (  )
Empties a Chunk. All blocks from this Chunk will become **void**, their displays will be hidden and it will not have collisions.

---

### **Chunk:setDisplayState** ( `active`: boolean )
Sets the display state of a Chunk. When active, all blocks corresponding to this Chunk will be displayed, otherwise hidden. If active is **nil** then the Chunk will hide and display to reload all displays.


**Parameters:**
- **active** (`Boolean`) : Whether it should be active or not

---

### **Chunk:setUnloadDelay** ( `ticks`: int, `type`: string )
Sets the Time that the Chunk should wait before unloading. There are three options to pick: physics, graphics, items. Note: Items unload removes them permanently.


**Parameters:**
- **ticks** (`Int`) : How many ticks should the Chunk await
- **type** (`String`) : The type of unload


**Returns:**
- `Boolean` Whether the unload scheduling was successful or not.

---

### **Chunk:setCollisions** ( `active`: boolean|nil, `targetPlayer`: string|nil )
Sets the Collisions for the Chunk. This is just an interface function that manages the interactions between players and the Chunk, to ensure no innecessary calls for players that had the Chunk already loaded.


**Parameters:**
- **active** (`Boolean|Nil`) : Sets the collision state. If nil then a reload will be performed for all players
- **targetPlayer** (`String|Nil`) : The target that asks for the collision update. If nil then player check wont be accounted


**Returns:**
- `Boolean` Whether the specified action happened or not

---

### **Chunk:setDisplay** ( `active`: boolean|nil, `targetPlayer`: string|nil )
Sets the Display state of a Chunk. This is just an interface function that manages the interactions between players and the Chunk, to ensure no innecessary calls for players that had the Chunk already displayed.


**Parameters:**
- **active** (`Boolean|Nil`) : Sets the Display state. If nil then a reload will be performed for all players
- **targetPlayer** (`String|Nil`) : The target that asks for the Display. If nil then player check wont be accounted


**Returns:**
- `Boolean` Whether the specified action happened or not