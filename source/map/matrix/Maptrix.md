# Maptrix

---

### **Tile:getDisplay** ( index )
Returns a display object from the Tile, given the index, if it exists. 

**Parameters:**
- **index** (`Any`) : The identifier of the Display object

**Returns:**
- `Object` The Display object
- `Number` The numerical index
- `String` The string index 

---

### **Tile:display** (  )
Shows the Tile in the Map. All Displays are shown in the order established.

**Returns:**
- `Boolean` Whether it is displayed or not

---

### **Tile:addDisplay** ( name, order, imageUrl, targetLayer, displayX, displayY, scaleX, scaleY, rotation, alpha, anchorX, anchorY, show )
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
- **anchorX** (`Number`) : The horizontal anchor of the sprite
- **anchorY** (`Number`) : The vertical anchor of the sprite
- **show** (`Boolean`) : Whether the new display object should be instantly rendered

**Returns:**
- `Int` The order of the object in the Display stack
- `String` The name of the object

---

### **Tile:removeDisplay** ( index, hide )
Removes a Display object from the Tile 

**Parameters:**
- **index** (`Any`) : The index of the Display object
- **hide** (`Boolean`) : Whether the sprite attached to this display should be automatically removed

---

### **Tile:removeAllDisplays** ( hide )
Removes **all** displays from a Tile. 

**Parameters:**
- **hide** (`Boolean`) : Hide all associated sprites

---

### **Tile:hide** (  )
Hides a Tile and all its sprites from the map. 

**Returns:**
- `Boolean` If the hiding was successful

---

### **Tile:refreshDisplay** (  )
Refreshes the Display of a Tile All sprites are hidden and shown again.

**Returns:**
- `Boolean` Whether it refreshed successfully or not

---

### **Tile:refreshDisplayAt** ( index )
Refreshes a single Display object. Same behaviour as [Tile:refreshDisplay](Map.md#Tile:refreshDisplay).

**Parameters:**
- **index** (`Any`) : The index to refresh the Display