# Mapgen

---

### **Field:generateNew** ( width, height )
Initializes the field matrix. 

**Parameters:**
- **width** (`Int`) : Matrix width.
- **height** (`Int`) : Matrix height.

---

### **Field:checkAssign** ( x, y, c_type, overwrite, excepts )
Assigns the specified type to the specified cell. 

**Parameters:**
- **x** (`Int`) : X position in matrix.
- **y** (`Int`) : Y position in matrix.
- **c_type** (`Int`) : Block cell type. See **blockMeta**.
- **overwrite** (`Boolean`) : Write over this cell even if the block isn't void.
- **excepts** (`List`) : If given, a list of types which should not be overwritten.

---

### **Field:setMatrix** ( matrix, xStart, yStart )
Sets a types matrix to the field. 

**Parameters:**
- **matrix** (`table`) : A types matrix. See **blockMeta** for types.
- **xStart** (`Int`) : X position to start setting values.
- **yStart** (`Int`) : Y position to start setting values.

---

### **Field:setStructure** ( settings, structure, xAnchor, yAnchor )
Wrapper for Field:setMatrix for structures. 

**Parameters:**
- **settings** (`Table`) : See **field.lua**.
- **structure** (`Structure`) : A structure
- **xAnchor** (`Number`) : In a scale of 0 to 1, X center of the structure.
- **yAnchor** (`Number`) : In a scale of 0 to 1, Y center of the structure.

---

### **Field:wrapTraverse** ( settings, execute )
Traverses the field, given the limits and executor. Expected on the form `execute(Field, x, y, i, iStart, iEnd)` and returns a type.

**Parameters:**
- **settings** (`Table`) : See **field.lua**.
- **execute** (`Function`) : A function called on each position.

---

### **Field:setFunction** ( settings )
Sets all cells to the value given by the function. Field `solver` expected as detailed on **Field:wrapTraverse**.

**Parameters:**
- **settings** (`Table`) : See **field.lua**.

---

### **nil** ( settings, info )
Creates a terrain island. 

**Parameters:**
- **settings** (`Table`) : Unified Field settings. See **field.lua**.
- **info** (`Table`) : Describes parameters for the island: