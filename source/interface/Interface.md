# Interface

---

### **IComp:** ( n )
d 

**Parameters:**
- **n** (`t`) : d

**Returns:**
- `t` d

---

### **remove_method** ( id, F )
Defines the methods to remove this object from view. 

**Parameters:**
- **id** (`Int`) : Object identifier.
- **F** (`Table`) : The list of args given originally.

---

### **IComp:destroy** (  )
Destroys a composition object. It basically deletes all its stack and references. This is a destructive operation, object is left unusable after destroying.

---

### **render_method** ( F )
Defines methods to render each type of object. 

**Parameters:**
- **F** (`Table`) : List of arguments for rendering.

**Returns:**
- `Int|Table` Identifier or object itself (child comp case).

---

### **IComp:setIText** ( id, ... )
Builds a Text Area which also accepts alignment values. 

**Parameters:**
- **id** (`Int`) : Identifier.
- **...** (`Any`) : Extra arguments.

**Returns:**
- `nil` nil

---

### **IComp:kSetIText** ( alias, ... )
See IComp:setItext. Accepts an alias. 

**Parameters:**
- **alias** (`Any`) : Alternative name for this field, useful for IComp:updateElement
- **...** (`Any`) : Extra arguments.

**Returns:**
- `nil` nil

---

### **IComp:setText** ( ... )
Builds a Text Area which also accepts alignment values. Id is generated automatically.

**Parameters:**
- **...** (`Any`) : Extra arguments.

**Returns:**
- `nil` nil

---

### **IComp:kSetText** ( alias, ... )
See IComp:setText. Accepts an alias. 

**Parameters:**
- **alias** (`Any`) : Alternative name for this field, useful for IComp:updateElement
- **...** (`Any`) : Extra arguments.

**Returns:**
- `nil` nil

---

### **IComp:setImage** ( ... )
Builds an image. 

**Parameters:**
- **...** (`Any`) : Extra arguments.

**Returns:**
- `nil` nil

---

### **IComp:kSetImage** ( alias, ... )
See IComp:setImage. Accepts an alias. 

**Parameters:**
- **alias** (`Any`) : Alternative name for this field, useful for IComp:updateElement
- **...** (`Any`) : Extra arguments.

**Returns:**
- `nil` nil

---

### **IComp:setComp** ( comp, ... )
Stores another Composition. 

**Parameters:**
- **comp** (`Comp`) : A composition object itself.
- **...** (`Any`) : Extra arguments.

**Returns:**
- `nil` nil

---

### **IComp:kSetComp** ( alias, ... )
See IComp:setComp. Accepts an alias. 

**Parameters:**
- **alias** (`Any`) : Alternative name for this field, useful for IComp:updateElement
- **...** (`Any`) : Extra arguments.

**Returns:**
- `nil` nil

---

### **IComp:render** (  )
Renders this composition (shows everything) 

**Returns:**
- `Int` The unique identifier of this object in the interface.

---

### **IComp:mRender** ( argmap, ... )
Same as IComp:render. You can dinamically modify/overwrite some fields,  based on the type of interface. This is useful for interfaces that are common to every player, but only need their 'playerName' field to be modified. The 'playerName' preset will replace only playerName correspoding fields.

**Parameters:**
- **argmap** (`Table|String`) : A map that replaces arguments.
- **...** (`Any`) : Extra arguments for the argmap (presets' case).

**Returns:**
- `Int` The unique identifier of this object in the interface.

---

### **IComp:set** ( ... )
Adds elements, based on the settler functions stored. 

**Parameters:**
- **...** (`Any`) : Arguments for the settler functions.

**Returns:**
- `nil` nil

---

### **IComp:flush** (  )
Throws away all elements from the stack but keeps the table. 

---

### **IComp:reload** ( ... )
Recalculates all the objects from this composition. This is just an interface that calls flush then set.

**Parameters:**
- **...** (`Any`) : Arguments for IComp:set.

---

### **IComp:addSettler** ( settler )
Adds a settler function. The expected format is `nil <- foo(IComp, ...)`.

**Parameters:**
- **settler** (`Function`) : A function that when called, adds elements.

**Returns:**
- `nil` nil

---

### **Interface:getValidKey** ( key )
Returns a (new) valid key for the Interface to assign to this composition. 

**Parameters:**
- **key** (`Any`) : Key (for checking)

**Returns:**
- `Any|Int` A key to store the composition

---

### **Interface:newCompositon** ( key )
Creates a new, empty composition object. 

**Parameters:**
- **key** (`Any`) : A key to store this composition

**Returns:**
- `Any|int` The key that stores this composition.

---

### **Interface:newFromTemplate** ( n )
d 

**Parameters:**
- **n** (`t`) : d

**Returns:**
- `t` d