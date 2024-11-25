do
	local type = type
	local tostring = tostring
	local print = print
	local next = next
	local setmetatable = setmetatable
	local getmetatable = getmetatable
	
	local remove = table.remove
	local concat = table.concat
	local sort = table.sort
	
	local min = math.min
	local random = math.random
	
	--- Checks if the Table has no elements.
	-- @name table.isEmpty
	-- @param Table:t The table to check
	-- @return `Boolean` Whether the Table is empty or not.
	table.isEmpty = function(t)
		return not next(t)
	end
	
	table.concatf = function(list, field, sep, i, j)
		i = i or 1
		j = j or #list
		local t = {}
		
		for n = i, j do
			t[#t + 1] = list[n][field]
		end
		
		return concat(t, sep)
	end
	
	--- Copies a table and all its values recursively.
	-- It avoids keeping references over values.
	-- @name table.copy
	-- @param Table:t The table to copy
	-- @return `Table` The table copied.
	table.copy = function(t, seen)
		seen = seen or {}
		if type(t) == "table" and not seen[t] then
			seen[t] = true
			local ut = {}
			
			for k, v in next, t do
				ut[k] = table.copy(v, seen)
			end
			
			setmetatable(ut, getmetatable(t))
			
			return ut
		else
			return t
		end
	end
	
	table.shallowcopy = function(t)
		if type(t) == "table" then
			local ut = t
			
			for k, v in next, t do
				ut[k] = v
			end
			
			setmetatable(ut, getmetatable(t))
			
			return ut
		else
			return t
		end
	end
	
	--- Copies only the values from a table, in an arbitrary order.
	-- @name table.copyvalues
	-- @param Table:t The table to copies values from
	-- @retrun `Table` A list with all the values.
	table.copyvalues = function(t)
		local list = {}
		
		for _, v in next, t do
			list[#list + 1] = v
		end
		
		return list
	end
	
	--- Appends two numerical tables
	-- @name table.append
	-- @param Table:t The first table
	-- @param Table:... Other tables to append
	-- @return `Table` The new table.
	table.append = function(t1, ...)
		local t = table.copy(t1)
		
		for _, tb in next, {...} do
			local t_size = #t
			
			for i = 1, #tb do 
				t[t_size + i] = tb[i]
			end
		end
		
		return t
	end
	
	--- Inhertis all values to a table, from the specified one.
	-- It does not modify the original tables, but copies them, to avoid links.
	-- All values to inherit will overwrite values on the target table.
	-- @name table.inherit
	-- @param Table:t The table for which values will be inherited.
	-- @param Table:ex The table to inherit values from.
	-- @return `Table` The new child table, product of the tables provided.
	table.inherit = function(t, ex)
		local it
		if type(t) == "table" then
			it = table.copy(t)
		else
			it = {}
		end
		
		for k, v in next, ex do
			if type(v) == "table" then
				it[k] = table.inherit(it[k], v)
			else
				it[k] = v
			end
		end
		
		return it
	end
	
	--- Searches for a value across a table.
	-- Will return the first index of where it was found, otherwise returns nil.
	-- @name table.find
	-- @param Table:t The table to search the value into.
	-- @param Any:e The element to search into the table.
	-- @return `Any` The key or index where the element was found.
	-- @return `Any` The element specified.
	table.find = function(t, e)
		for k, v in next, t do
			if v == e then
				return k, v
			end
		end
	end
	
	--- Searches for a value, but in a depth of 1 index.
	-- Refer to table.find for more information.
	-- @name table.kfind
	-- @param Table:t The table to search the value into.
	-- @param Any:key The key to search from all elements.
	-- @param Any:e The element to search into the table.
	-- @return `Any` The key or index where the element was found.
	-- @return `Any` The element specified.
	table.kfind = function(t, key, e)
		for k, v in next, t do
			if v[key] == e then
				return k, v
			end
		end
	end
	
	--- Extracts a value from the given table.
	-- @name table.extract
	-- @param Table:t The table to extract the value from
	-- @param Any:e The value to extract from the table
	-- @return `Any` The index were the value was found 
	-- @return `Table` The table 
	table.extract = function(t, e)
		local i = table.find(t, e)
		
		if type(i) == "number" and #t > 0 then
			remove(t, i)
		else
			t[i] = nil
		end
		
		return i, t
	end
	
	--- Returns an array with all the keys/indexes from the given table.
	-- @name table.keys
	-- @param Table:t The table to get keys from
	-- @return `Table` The array with the keys.
	table.keys = function(t)
		local array = {}
		
		for k, _ in next, t do
			array[#array + 1] = k
		end
		
		return array
	end
	
	--- Counts all entries in a Table.
	-- @name table.count
	-- @param Table:t The table to count values on
	-- @return `Int` The amount of entries
	table.count = function(t)
		local count = 0
		local index = next(t)
		
		while index do
			index = next(t, index)
			count = count + 1
		end
		
		return count
	end
	
	--- Copies all the keys from the table and assigns them the value given.
	-- @name table.copykeys
	-- @param Table:t The table to copy keys from
	-- @param Any:v The value to assign to the keys
	-- @return `Table` The table with the keys.
	table.copykeys = function(t, v)
		local nt = {}
		
		for k in next, t do
			nt[k] = v
		end
		
		return nt
	end
	
	--- Gives the value of a random entry from the table.
	-- If the table is associative it converts the keys to an array.
	-- @name table.random
	-- @param Table:t The table to get the random element from
	-- @param Boolean:associative Wheter the table is associative or numerical
	-- @return `Any` The random value
	-- @return `Any` The index were it was picked from
	table.random = function(t, associative)
		local index
		if associative or #t <= 0 then
			local array = table.keys(t)
			
			index = table.random(array, false)
		else
			index = random(#t)
		end
		
		return t[index], index
	end
	
	local alphabetic_sort = function(a, b)
		local ca, cb 
		
		for i = 1, min(#a, #b) do
			ca = a:byte(i)
			cb = b:byte(i)
			
			if ca > cb then
				return false
			elseif ca < cb then
				return true
			end
		end
		
		return false
	end
	
	--- Converts a table to a string, in a reasonable format.
	-- @name table.tostring
	-- @param Table|Any:value The table to convert to string
	-- @param Int:tb The depth in the table
	-- @param Table:seen A list of tables that have been seen when iterating
	-- @return `String` The value converted to string
	-- TODO: Add special parsing for keys.
	
	local colors = {
		string = "CEP",
		boolean = "ROSE",
		number = "V",
		coroutine = "VP",
		["function"] = "VI"
	}
	local prettify = function(value, type)
		local color = colors[type]
		
		return ("<%s>%s</%s>"):format(color, tostring(value), color)
	end
	
	table.tostring = function(value, tb, seen, pretty, lim)
		lim = lim or 8
		tb = tb or 0
		if tb > lim then return "..." end -- Do not descend anymore.
		
		local tv = type(value)
		if tv == "table" then
			seen = seen or {}
			
			local args = {}
			local kk, vv
			local p1 = tb + 1
			for k, v in next, value do
				kk = table.tostring(k, p1, nil, pretty, lim)
				if not seen[v] and not tostring(k):match("__index") then
					if type(v) == "table" then
						seen[v] = true
						vv = table.tostring(v, p1, seen, pretty)
					else
						vv = table.tostring(v, p1, seen, pretty)
					end
					
					args[#args + 1] = ("%s%s"):format(
						("\t"):rep(p1),
						("%s = %s"):format(kk, vv)
					)
				end
			end
			
			sort(args, alphabetic_sort)
			
			args = concat(args, ",\n")
			
			if pretty then
				return ("<N>{\n%s\n%s}</N>"):format(args, ("\t"):rep(tb))
			else
				return ("{\n%s\n%s}"):format(args, ("\t"):rep(tb))
			end
		else
			if tv == "string" then
				value = ('"%s"'):format(value:gsub("<", "&lt;"):gsub(">", "&gt;"))
			end
			
			return pretty and prettify(value, tv) or tostring(value)
		end
	end
	
	--- Prints a table. This is just a wrap of table.tostring.
	-- @name table.print
	-- @param Table:t The table to print
	-- @param Boolean:pretty Add colors and stuff to this print
	-- @param Int:lim How many subtables should it descend to
	table.print = function(t, pretty, lim)
		print(table.tostring(t, 0, nil, pretty, lim))
	end	
end