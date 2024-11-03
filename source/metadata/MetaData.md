# MetaData

---

### **nil** ( default )
Creates a new Meta Data handler. A handler can automatically fill void properties, return defaults or function as Class inheritor, by supporting Templates.

**Parameters:**
- **default** (`Any`) : The default object for this Meta Data handler.

**Returns:**
- `MetaData` The Meta Data handler for this object

---

### **nil** ( identifier, definition, aux )
Creates a new Template for the specified Meta Data handler. A template can serve to apply specific properties automatically to new objects created under it. Templates can be derivated from other templates to support higher abstraction.

**Parameters:**
- **identifier** (`Any`) : The identifier for this template
- **definition** (`Any`) : The definition for this template. In case aux is present, this can be another identifier for a template to inherit
- **aux** (`Any`) : In case it's present, it will perform a double inheritance, serving as main definition

**Returns:**
- `Template` The new template.

---

### **nil** ( identifier )
Gets a template, if it exists. 

**Parameters:**
- **identifier** (`Any`) : The identifier of the desired template

**Returns:**
- `Template` The template object, if it exists, otherwise the default Meta Data value.

---

### **nil** ( index, template, definition )
Sets a new object under the Meta Data storage. An object can inherit properties from a template or from another object.

**Parameters:**
- **index** (`Any`) : The index to storage this object into
- **template** (`Any`) : If definition is not defined, this will be the object to set, which will inherit default object
- **definition** (`Any`) : If present, it will inherit, first from template, and second from default

**Returns:**
- `Object` The new object.

---

### **nil** ( index )
Gets an object, if it exists. 

**Parameters:**
- **index** (`Any`) : The identifier of the desired object

**Returns:**
- `Object` The object, if it exists, otherwise the default Meta Data value.