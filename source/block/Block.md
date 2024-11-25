# Block

---

### **Block:new** ( uniqueId, type, MapX, MapY, displayX, displayY, width, height )
Creates a new Block object. 

**Parameters:**
- **uniqueId** (`Int`) : The unique ID of the Block in the Map
- **type** (`Int`) : The Block type. Data will be consulted on **blockMeta** to apply for this object
- **MapX** (`Int`) : Horizontal position of the Block in the Map matrix
- **MapY** (`Int`) : Vertical position of the Block in the Map matrix
- **displayX** (`Int`) : Horizontal position of the Block in Transformice's map
- **displayY** (`Int`) : Vertical position of the Block in Transformice's map
- **width** (`Int`) : Width of the block in pixels
- **height** (`Int`) : Height of the block in pixels

**Returns:**
- `Block` The Block object

---

### **Block:setVoid** ( update )
Sets the Block to a **void** state. 

**Parameters:**
- **update** (`Boolean`) : Whether it should update nearby blocks or not

---

### **Block:setRelativeCoordinates** ( xInChunk, yInChunk, idInChunk, chunkX, chunkY, chunkId )
Sets the Block relative coordinates to its chunk. 

**Parameters:**
- **xInChunk** (`Int`) : The horizontal position of the Block in its Chunk
- **yInChunk** (`Int`) : The vertical position of the Block in its Chunk
- **idInChunk** (`Int`) : The unique identifier of the Block in its Chunk 
- **chunkX** (`Int`) : The horizontal position of the Chunk in the Map
- **chunkY** (`Int`) : The vertical position of the Chunk in the Map
- **chunkId** (`Int`) : The unique identifier of the Chunk in the Map

---

### **Block:__eq** ( other )
Compares with another block object. 

**Parameters:**
- **other** (`Block`) : Another block

**Returns:**
- `Boolean` Whether they are equal or not

---

### **Block:onCreate** (  )
Triggers when the Block is "created" to the world. Declare as `onCreate = function(self)`.

---

### **Block:onDestroy** (  )
Triggers when the Block is destroyed. Declare as `onDestroy = function(self, player)`.

---

### **Block:onInteract** ( player )
Triggers when the Block gets interaction with a **player**. Declare as `onInteract = function(self, player)`.

**Parameters:**
- **player** (`Player`) : The player object who interacted with this block

---

### **Block:onDamage** ( amount, player )
Triggers when the Block gets damaged. Declare as `onDamage = function(self, amount, player)`.

**Parameters:**
- **amount** (`Int`) : The damage received from this block.
- **player** (`Player`) : The player object who damaged this block

---

### **Block:onContact** ( player )
Triggers when the Block gets touched by a **player**. Declare as `onContact = function(self, player)`.

**Parameters:**
- **player** (`Player`) : The player object who touched this block

---

### **Block:onUpdate** ( block )
Triggers when the Block gets updated by the actions of another block. Declare as `onUpdate = function(self, block)`.

**Parameters:**
- **block** (`Block`) : The block that requests this one to be updated

---

### **Block:create** ( type, display, update, updatePhysics )
Creates a new Block. The state of the Block is changed from what it was previously to the new specified state. If the specified Block type doesn't exist, it will default to an invalid block type.

**Parameters:**
- **type** (`Int`) : The type of the Block
- **display** (`Boolean`) : Whether the new state should be automatically displayed
- **update** (`Boolean`) : Whether the nearby Blocks should receive the `Block:onUpdate` event
- **updatePhysics** (`Boolean`) : Whether the nearby physics should adjust automatically

---

### **Block:createAsFluidWith** ( type, level, display, update, updatePhysics )
Creates a Block of fluid type. It can be initialized with specific properties regarding fluids.

**Parameters:**
- **type** (`Int`) : The type of the block
- **level** (`Int`) : From 1 to 4, the level of the fluid
- **display** (`Boolean`) : Whether the new state should be automatically displayed
- **update** (`Boolean`) : Whether the nearby Blocks should receive the `Block:onUpdate` event
- **updatePhysics** (`Boolean`) : Whether the nearby physics should adjust automatically

---

### **Block:destroy** ( display, update, updatePhysics )
Destroys a Block. The block will become void/air.

**Parameters:**
- **display** (`Boolean`) : Whether the new state should be automatically displayed
- **update** (`Boolean`) : Whether the nearby Blocks should receive the `Block:onUpdate` event
- **updatePhysics** (`Boolean`) : Whether the nearby physics should adjust automatically

---

### **Block:setDamageLevel** ( amount, add, display, update, updatePhysics )
Sets the damage level of a Block 

**Parameters:**
- **amount** (`Int`) : The amount of damage to set to the Block. Negative numbers are admited
- **add** (`Boolean`) : Whether the specified amount should be added or adjusted directly
- **display** (`Boolean`) : Whether the new state should be automatically displayed
- **update** (`Boolean`) : Whether the nearby Blocks should receive the `Block:onUpdate` event (in case it's destroyed)
- **updatePhysics** (`Boolean`) : Whether the nearby physics should adjust automatically (in case it's destroyed)

**Returns:**
- `Boolean` Whether the Block has the specified amount of damage
- `Boolean` Whether the Block was destroyed

---

### **Block:setRepairDelay** ( set, delay, ... )
Sets the delay time for repairing a block. 

**Parameters:**
- **set** (`Boolean`) : Whether the delay is being set or removed
- **delay** (`Int`) : How many ticks it should wait before fully repairing itself
- **...** (`Any`) : Arguments for `Block:repair`

**Returns:**
- `Boolean` Whether the Block has the specified amount of damage

---

### **Block:damage** ( amount, add, display, update, updatePhysics )
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

### **Block:repair** ( amount, add, display, update, updatePhysics )
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

### **Block:interact** ( player )
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

### **Block:requestPhysicsUpdate** ( segmentList )
Triggers a recalculation of the physic body (segment) that concerns this block. 

**Parameters:**
- **segmentList** (`Table`) : A list of other segments to take into consideration

---

### **Block:getBlocksAround** ( shape, include )
Retrieves a list with the blocks adjacent to the Block. 

**Parameters:**
- **shape** (`String`) : The shape to retrieve the blocks {cross: only adjacents, square: adjacents + edges}
- **include** (`Boolean`) : Whether the Block itself should be included in the list.

**Returns:**
- `Table` An array with the adjacent blocks (in no particular order)

---

### **Block:requestNeighborUpdate** ( inquireShape )
Requests an update to its neighbours. 

**Parameters:**
- **inquireShape** (`Int`) : The type of shape to get the nearby blocks from.

**Returns:**
- `Table` A list of segments

---

### **Block:updateEvent** ( update, updatePhysics, lookupCategory )
Interface for handling when a block state gets updated. 

**Parameters:**
- **update** (`Boolean`) : Whether the blocks around should be updated (method: `Block:onUpdate`)
- **updatePhysics** (`Boolean`) : Whether the physics of the Map should be updated
- **lookupCategory** (`Int`) : A category to specifically lock segment updates to

---

### **Block:assertStateActions** (  )
Checks all possible actions that a Block could take based on its state metadata. 

**Returns:**
- `Boolean` Whether anything happened or not

---

### **Block:assertCascadeDestroyAction** (  )
Checks if a block meets the conditions to get destroyed. It will do the same with the above blocks and bulk destroy all of them. All considerations are handled on this function, so no need to update outside.

**Returns:**
- `Boolean` Whether it happened

---

### **Block:cascadeAction** (  )
Bulk deletes upwardly all blocks of equal type. 

---

### **Block:assertCascadeDestroyAction** (  )
Checks if a block meets the conditions to fall. It will check the above blocks as well, and at most two blocks will get shifted. All considerations are handled on this function, so no need to update outside.

**Returns:**
- `Boolean` Whether it happened

---

### **Block:assertCascadeDestroyAction** (  )
Deletes the upmost block of the same type and creates a new one on the expected downard position. 

**Returns:**
- `Boolean` Whether it happened

---

### **Block:display** (  )
Displays the sprite that corresponds to this block, if any. 

**Parameters:**
- **nil** (`nil`) : nil

---

### **Block:hide** (  )
Removes the sprite from the corresponding block, if any. 

---

### **Block:refreshDisplay** (  )
Hides and shows the sprite from the block. 

---

### **Block:setSprite** ( sprite, refresh )
Establishes the sprite for the designed block. 

**Parameters:**
- **sprite** (`String`) : The sprite URL from the Atelier801 servers
- **refresh** (`Boolean`) : Whether it should refresh the sprite in the world or not

---

### **Block:pulse** ( image )
Makes a visible pulse. 

**Parameters:**
- **image** (`String`) : A image to make the pulse. If not given will default to white

---

### **nil** ( x, y, vx, vy )
Displays particles when a block is touched. They display from the contact point and try to follow a convincing representation of real life dust and debris coming out of nature objects life stones and such. 

**Parameters:**
- **x** (`Number`) : X coordinate
- **y** (`Number`) : Y coordinate
- **vx** (`Number`) : X speed (player)
- **vy** (`Number`) : Y speed (player)

---

### **nil** ( type, x, y, vx, vy )
Displays particles from the block according to a specified mode. 

**Parameters:**
- **type** (`Number`) : The spreading type
- **x** (`Number`) : X coordinate
- **y** (`Number`) : Y coordinate
- **vx** (`Number`) : X speed (player)
- **vy** (`Number`) : Y speed (player)

---

### **Block:playSound** ( soundKey, player )
Plays the specified sound for the Block. A block can have different types of sounds according to the event that happens to them.

**Parameters:**
- **soundKey** (`String`) : The key that identifies the sound. If it doesn't exist, it will default to a regular sound.
- **player** (`Player`) : The player that should hear this sound, if nil, applies to everyone.

**Returns:**
- `Boolean` Whether the sound was successfully played or not

---

### **nil** (  )
Returns the decorative tile that lies in the same space grid as this block. 

**Returns:**
- `Tile` The tile object