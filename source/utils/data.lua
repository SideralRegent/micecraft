local data = {}

do -- Localize variables to reduce workload
	local type = type
	local ipairs, pairs, next = ipairs, pairs, next
	local concat = table.concat
	local char = string.char
	
	local xCHAR = char(17)
	
	--- Gives the specific data of a module from an encoded string.
	-- @name data.getFromModule
	-- @param String:str The data to search into
	-- @param String:m_id The module identificator, being at least three uppercase characters.
	-- @return `String` The raw data for this module, otherwise an empty string.
	data.getFromModule = function(str, m_id)
		
		local rawdata = str:match(("%s (.-)%s"):format(m_id or "", xCHAR))
		if rawdata and rawdata ~= ("") then
			return rawdata
		else
			print(("Could not find data for module '%s'"):format(m_id))
		end
		
		return ""
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
	data.setToModule = function(str, m_id, rawdata)
		local pattern = ("%s (.-)%s"):format(m_id or "", xCHAR)
		local oldModuleData = str:match(pattern)
		local newData
		
		local newstr = ("%s %s%s"):format(m_id, rawdata, xCHAR)
		
		if oldModuleData then
			newData = str:gsub(pattern, newstr)
		else
			if m_id then
				newData = ("%s%s"):format(str, newstr)
			end
		end
		
		return newData, rawdata, str, oldModuleData
	end
	
	--- Decodes a piece of raw data.
	-- @name data.decode
	-- @param String:str The raw data
	-- @param Int:depth The depth to look at, in case it's a table.
	-- @return `Table` The table with the data.
	data.decode = function(str, depth)
		depth = depth or 1
		local this = {}
		local count = 1

		local pattern = "[^" .. char(17 + depth) .. "]+"
		
		local key, value
		for info in str:gmatch(pattern) do
			key, value = info:match("(%w+)=(.+)")
			if not key then
				key = count
				value = info
				count = count + 1
			end
			this[key] = data.parse(value or "", depth)
		end
		
		return this
	end

	--- Parses a value encoded or compressed.
	-- @name data.parse
	-- @param String:str The encoded data.
	-- @param Int:depth The deep to look at, in case it's a Table
	-- @return `Any` The value decoded.
	data.parse = function(str, depth)
		local booleans = {
			["+"] = true,
			["-"] = true
		}
		if booleans[str] then
			return (str == '+')
		end
		
		local value = str:match('^"(.-)"$')
		if value then
			return value
		else
			value = str:match("^{(.-)}$")
			if value then
				return data.decode(value, depth + 1)
			else
				return math.tonumber(str, 64) or str
			end
		end
	end

	--- Encondes a value into a reasonable format.
	-- @name data.serialize
	-- @param Any:this The value to convert
	-- @param Int:depth The depth to encode at, in case it's a table
	-- @return `String` The value encoded.
	data.serialize = function(this, depth)
		local value = ""
		depth = depth or 0
		if type(this) == "table" then
			local concat = {}
			for k, v in next, this do
				concat[#concat + 1] = data.serialize(v, depth + 1)
			end
			value = ("{%s}"):format(concat(concat, char(17 + depth)))
		else
			if type(this) == "number" then
				value = math.tobase(this, 64)
			elseif type(this) == "boolean" then
				value = this and "+" or "-"
			elseif type(this) == "string" then
				value = ('"%s"'):format(this)
			end
		end
		
		return value
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
		
		return concat(str, separator)
	end
end