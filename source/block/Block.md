# Block

---

### **Block:new** ( `uniqueId`: int, `type`: int, `foreground`: boolean, `MapX`: int, `MapY`: int, `displayX`: int, `displayY`: int, `width`: int, `height`: int )
Creates a new Block object. 


**Parameters:**
- **uniqueId** (`Int`) : The unique ID of the Block in the Map
- **type** (`Int`) : The Block type. Data will be consulted on **blockMetadata** to apply for this object
- **foreground** (`Boolean`) : Whether the Block should be in the foreground layer or not
- **MapX** (`Int`) : Horizontal position of the Block in the Map matrix
- **MapY** (`Int`) : Vertical position of the Block in the Map matrix
- **displayX** (`Int`) : Horizontal position of the Block in Transformice's map
- **displayY** (`Int`) : Vertical position of the Block in Transformice's map
- **width** (`Int`) : Width of the block in pixels
- **height** (`Int`) : Height of the block in pixels


**Returns:**
- `Block` The Block object

---

### **Block:setVoid** (  )
Sets the Block to a **void** state. 

---

### **Block:setRelativeCoordinates** ( `xInChunk`: int, `yInChunk`: int, `idInChunk`: int, `chunkX`: int, `chunkY`: int, `chunkId`: int )
Sets the Block relative coordinates to its chunk. 


**Parameters:**
- **xInChunk** (`Int`) : The horizontal position of the Block in its Chunk
- **yInChunk** (`Int`) : The vertical position of the Block in its Chunk
- **idInChunk** (`Int`) : The unique identifier of the Block in its Chunk 
- **chunkX** (`Int`) : The horizontal position of the Chunk in the Map
- **chunkY** (`Int`) : The vertical position of the Chunk in the Map
- **chunkId** (`Int`) : The unique identifier of the Chunk in the Map

---

### **Block:create** ( `type`: int, `foreground`: boolean, `display`: boolean, `update`: boolean, `updatePhysics`: boolean )
Creates a new Block. The state of the Block is changed from what it was previously to the new specified state. If the specified Block type doesn't exist, it will default to an invalid block type.


**Parameters:**
- **type** (`Int`) : The type of the Block
- **foreground** (`Boolean`) : Whether the new state belongs to the foreground layer or not
- **display** (`Boolean`) : Whether the new state should be automatically displayed
- **update** (`Boolean`) : Whether the nearby Blocks should receive the `Block:onUpdate` event
- **updatePhysics** (`Boolean`) : Whether the nearby physics should adjust automatically

---

### **Block:createAsFluidWith** ( `type`: int, `level`: int, `display`: boolean, `update`: boolean, `updatePhysics`: boolean )
Creates a Block of fluid type. It can be initialized with specific properties regarding fluids.


**Parameters:**
- **type** (`Int`) : The type of the block
- **level** (`Int`) : From 1 to 4, the level of the fluid
- **display** (`Boolean`) : Whether the new state should be automatically displayed
- **update** (`Boolean`) : Whether the nearby Blocks should receive the `Block:onUpdate` event
- **updatePhysics** (`Boolean`) : Whether the nearby physics should adjust automatically

---

### **Block:destroy** ( `display`: boolean, `update`: boolean, `updatePhysics`: boolean )
Destroys a Block. In case the Block was in foreground layer, it will descend to background layer, otherwise, it becomes void.


**Parameters:**
- **display** (`Boolean`) : Whether the new state should be automatically displayed
- **update** (`Boolean`) : Whether the nearby Blocks should receive the `Block:onUpdate` event
- **updatePhysics** (`Boolean`) : Whether the nearby physics should adjust automatically

---

### **Block:setDamageLevel** ( `amount`: int, `add`: boolean, `display`: boolean, `update`: boolean, `updatePhysics`: boolean )
Sets the damage level of a Block 


**Parameters:**
- **amount** (`Int`) : The amount of damage to set to the Block. Negative numbers are admited
- **add** (`Boolean`) : Whether the specified amount should be added or adjusted directly
- **display** (`Boolean`) : Whether the new state should be automatically displayed
- **update** (`Boolean`) : Whether the nearby Blocks should receive the `Block:onUpdate` event (in case it's destroyed)
- **updatePhysics** (`Boolean`) : Whether the nearby physics should adjust automatically (in case it's destroyed)


**Returns:**
- `Boolean` Whether the Block has the specified amount of damage

---

### **Block:setRepairDelay** ( `set`: boolean, `delay`: int, `...`: any )
Sets the delay time for repairing a block. 


**Parameters:**
- **set** (`Boolean`) : Whether the delay is being set or removed
- **delay** (`Int`) : How many ticks it should wait before fully repairing itself
- **...** (`Any`) : Arguments for `Block:repair`


**Returns:**
- `Boolean` Whether the Block has the specified amount of damage

---

### **Block:damage** ( `amount`: int, `add`: boolean, `display`: boolean, `update`: boolean, `updatePhysics`: boolean )
Damages a Block. This is just an interface to `Block:setDamageLevel`.


**Parameters:**
- **amount** (`Int`) : The amount of damage to apply to the Block
- **add** (`Boolean`) : Whether the specified amount should be added or adjusted directly
- **display** (`Boolean`) : Whether the new state should be automatically displayed
- **update** (`Boolean`) : Whether the nearby Blocks should receive the `Block:onUpdate` event (in case it's destroyed)
- **updatePhysics** (`Boolean`) : Whether the nearby physics should adjust automatically (in case it's destroyed)


**Returns:**
- `Boolean` Whether the Block has the specified amount of damage

---

### **Block:repair** ( `amount`: int, `add`: boolean, `display`: boolean, `update`: boolean, `updatePhysics`: boolean )
Repairs a Block previously damaged. This is just an interface to `Block:setDamageLevel`.


**Parameters:**
- **amount** (`Int`) : The amount of damage to remove from the Block
- **add** (`Boolean`) : Whether the specified amount should be removed or adjusted directly
- **display** (`Boolean`) : Whether the new state should be automatically displayed
- **update** (`Boolean`) : Whether the nearby Blocks should receive the `Block:onUpdate` event (in case its state changes)
- **updatePhysics** (`Boolean`) : Whether the nearby physics should adjust automatically (in case its state changes)


**Returns:**
- `Boolean` Whether the Block has the specified amount of damage

---

### **Block:interact** ( `player`: player )
Interacts with a Block. Triggers the method `Block:onInteract` for the provided player.


**Parameters:**
- **player** (`Player`) : The Player that interacts with this block


**Returns:**
- `Boolean` Whether the interaction was successful or not

---

### **Block:getChunk** (  )
Retrieves the Chunk object from which the Block belongs to 


**Returns:**
- `Chunk` The chunk object

---

### **Block:getBlocksAround** ( `shape`: string, `include`: boolean )
Retrieves a list with the blocks adjacent to the Block. 


**Parameters:**
- **shape** (`String`) : The shape to retrieve the blocks {cross: only adjacents, square: adjacents + edges}
- **include** (`Boolean`) : Whether the Block itself should be included in the list.


**Returns:**
- `Table` An array with the adjacent blocks (in no particular order)

---

### **Block:updateEvent** ( `update`: boolean, `updatePhysics`: boolean )
Interface for handling when a block state gets updated. 


**Parameters:**
- **update** (`Boolean`) : Whether the blocks around should be updated (method: `Block:onUpdate`)
- **updatePhysics** (`Boolean`) : Whether the physics of the Map should be updated

---

### **Block:getDisplay** ( `index`: any )
Returns a diplay object from the Block, given the index, if it exists. 


**Parameters:**
- **index** (`Any`) : The identifier of the Display object


**Returns:**
- `Object` The Display object
- `Number` The numerical index
- `String` The string index 

---

### **Block:display** (  )
Shows the Block in the Map. All Displays are shown in the order established.


**Returns:**
- `Boolean` Whether it displayed or not

---

### **Block:addDisplay** ( `name`: string, `order`: int, `imageUrl`: string, `targetLayer`: string, `displayX`: int, `displayY`: int, `scaleX`: number, `scaleY`: number, `rotation`: number, `alpha`: number, `show`: boolean )
Adds a new Display object to the Block. There's no check if a previous display already exists, beware of overwritting other of your displays when specifing its order.


**Parameters:**
- **name** (`String`) : The name of the Display object
- **order** (`Int`) : The position in the stack for it to be rendered. The stack iteration is ascending
- **imageUrl** (`String`) : The URL of the image in the domain `images.atelier801.com`.
- **targetLayer** (`String`) : The layer to show the sprite in
- **displayX** (`Int`) : The horizontal coordinate in the map
- **displayY** (`Int`) : The vertical coordinate in the map
- **scaleX** (`Number`) : The horizontal scale of the sprite
- **scaleY** (`Number`) : The vertical scale of the sprite
- **rotation** (`Number`) : The rotation, in radians, of the sprite
- **alpha** (`Number`) : The opacity of the sprite
- **show** (`Boolean`) : Whether the new display object should be instantly rendered


**Returns:**
- `Int` The order of the object in the Display stack
- `String` The name of the object

---

### **Block:removeDisplay** ( `index`: any, `hide`: boolean )
Removes a Display object from the Block 


**Parameters:**
- **index** (`Any`) : The index of the Display object
- **hide** (`Boolean`) : Whether the sprite attached to this display should be automatically removed

---

### **Block:removeAllDisplays** (  )
Removes **all** displays from a Block. 

---

### **Block:hide** (  )
Hides a Block and all its sprites from the map. 


**Returns:**
- `Boolean` If the hiding was successful

---

### **Block:refreshDisplay** (  )
Refreshes the Display of a Block All sprites are hidden and shown again.


**Returns:**
- `Boolean` Whether it refreshed successfully or not

---

### **Block:refreshDisplayAt** ( `index`: any )
Refreshes a single Display object. Same behaviour as [Block:refreshDisplay](Blocks.md#Block:refreshDisplay).


**Parameters:**
- **index** (`Any`) : The index to refresh the Display

---

### **Block:setDefaultDisplay** (  )
Sets the Block default display objects. These displays are: 1. The main object sprite according to its type. 2. The shadow sprite, in case it's in background layer.

---

### **Block:spreadParticles** (  )
Spreads particles from the Block. 


**Returns:**
- `Boolean` Whether the particles were successfully spreaded or not

---

### **Block:playSound** ( `soundKey`: string, `player`: player )
Plays the specified sound for the Block. A block can have different types of sounds according to the event that happens to them.


**Parameters:**
- **soundKey** (`String`) : The key that identifies the event. If it doesn't exist, it will default to a regular sound.
- **player** (`Player`) : The player that should hear this sound, if nil, applies to everyone.


**Returns:**
- `Boolean` Whether the sound was successfully played or not