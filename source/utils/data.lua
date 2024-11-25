local data = {}

do
	local TRUE = "°"
	local FALSE = "|"
	local BASE_REF = 36
	local type = type
	local next = next
	local tconcat = table.concat
	local char = string.char
	
	local reference = char(17)
	
	--- Gives the specific data of a module from an encoded string.
	-- @name data.getFromModule
	-- @param String:str The data to search into
	-- @param String:m_id The module identificator, being at least three uppercase characters.
	-- @return `String` The raw data for this module, otherwise an empty string.
	data.getFromModule = function(str, moduleId)
		
		local moduleData = str:match(("%s (.-)%s"):format(moduleId or "", reference))
		if moduleData and moduleData ~= ("") then
			return moduleData
		else
			print(("Could not find data for module '%s'"):format(moduleId))
			
			return ""
		end
	end
	
	--- Sets the data to the specified module on an encoded string
	-- @name data.setToModule
	-- @param String:str The complete raw data
	-- @param String:m_id The module identifier
	-- @param String:rawdata The raw data to apply to the specified module
	-- @return `String` The new encoded data
	-- @return `String` The new raw data for the module
	-- @return `String` The old encoded data
	-- @return `String` The old raw data for the module
	data.setToModule = function(oldWholeData, moduleId, rawData)
		local modulePattern = ("%s (.-)%s"):format(moduleId or "", reference)
		local oldModuleData = oldWholeData:match(modulePattern)
		local newWholeData
		
		local newModuleData = ("%s %s%s"):format(moduleId, rawData, reference)
		
		if oldModuleData then
			newWholeData = oldWholeData:gsub(modulePattern, newModuleData)
		else -- There is not old module data, so it has to be added
			if moduleId then
				newWholeData = ("%s%s"):format(oldWholeData, newModuleData)
			end
		end
		
		return newWholeData, rawData, oldWholeData, oldModuleData
	end
	
	--- Decodes a piece of raw data.
	-- @name data.decode
	-- @param String:str The raw data
	-- @param Int:depth The depth to look at, in case it's a table.
	-- @return `Table` The table with the data.
	data.decode = function(str, depth)
		depth = depth or 1
		local this = {}		local pattern = ("[^%c]+"):format(17 + depth)
		
		local d_parse = data.parse
		
		local key, value		
		local count = 1
		for info in str:gmatch(pattern) do
			key, value = info:match("(%w+)=(.+)")
			
			if not key then -- It's numeric
				key = count
				value = info
				count = count + 1
			end
			
			this[key] = d_parse(value or "", depth)
		end
		
		return this
	end	--- Parses a value encoded or compressed.
	-- @name data.parse
	-- @param String:str The encoded data.
	-- @param Int:depth The deep to look at, in case it's a Table
	-- @return `Any` The value decoded.
	
	local bools = {
		[TRUE] = true,
		[FALSE] = true,
	}
	
	data.parse = function(str, depth)
		if bools[str] then
			return (str == TRUE)
		end
		
		local value = str:match('^"(.-)"$') -- Assert string
		if value then
			return value
		else
			value = str:match("^{(.-)}$")
			if value then -- Assert table
				return data.decode(value, depth + 1)
			else -- Must be a number
				return math.tonumber(str, BASE_REF) or str
			end
		end
	end	--- Encondes a value into a reasonable format.
	-- @name data.serialize
	-- @param Any:this The value to convert
	-- @param Int:depth The depth to encode at, in case it's a table
	-- @return `String` The value encoded.
	
	local solve = {
		table = function(this, depth)
			local list = {}
			local d_ser = data.serialize
			
			for _, value in next, this do
				list[#list + 1] = d_ser(v, depth + 1)
			end
			
			return ("{%s}"):format(tconcat(list, char(17 + depth)))
		end,
		number = function(this)
			return math.tobase(this, BASE_REF)
		end,
		boolean = function(this)
			return this and TRUE or FALSE
		end,
		string = function(this)
			return ('"%s"'):format(this)
		end,
		coroutine = function(this)
			return error("No.")
		end,
		["function"] = function(this)
			return error("CHECK YOUR CODE!")
		end
	}
	
	data.serialize = function(this, depth)
		depth = depth or 0
		
		return solve[type(this)](this, depth)
	end
	
	--- Encodes a table into a reasonable format.
	-- @name data.encode
	-- @param Table:this The table to encode
	-- @param Int:depth The depth to encode at (by default it's 1)
	-- @return `String` The encoded table
		
	data.encode = function(this, depth)
		depth = depth or 1
		local separator = char(17 + depth)
		local str = {}
		local k, v
		
		local numeric = (#this > 0)
		
		for key, value in next, this do
			k, v = key, data.serialize(value, depth + 1)
			
			if numeric and type(key) == "number" then
				str[#str + 1] = v
			else
				str[#str + 1] = ("%s=%s"):format(k, v)
			end
		end
		
		return tconcat(str, separator)
	end
	
	data.parseName = function(str)
		local name, tag = str:match("([%w_]+)#(%d%d%d%d)")
		
		return name, tag
	end
end