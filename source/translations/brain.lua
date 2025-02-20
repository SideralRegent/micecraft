function Translations:new(commu, contents)
	assert(
		type(commu) == "string"
		and type(contents) == "table", 
		("Malfored translation definition for commu [%s]."):format(tostring(commu))
	)
	
	assert(not self[commu], "Community [".. commu  .."] already exists.")
	
	self[commu] = table.copy(contents)
end

function Translations:search(commu, key)
	local obj = self[commu] or self[self.default]
	local success = false
	
	for index in key:gmatch("[^%.]+") do
		if obj[index] then
			obj = obj[index]
		else
			obj = nil
			break
		end
	end
	
	if obj then
		success = true
	else
		if commu ~= self.default then
			obj, success = self:search(self.default, key)
		else
			obj, success = ("!%s!"):format(tostring(key)), false
		end
	end
	
	return obj, success
end

do
	local next = next
	local tostring = tostring
	local match = "&(.-)&"
	function Translations:format(text, formatting)
		return text:gsub(match, formatting)
	end
end

function Translations:checkLanguage(commu)
	if commu:len() == 2 then
		return commu
	else
		local player = Room:getPlayer(commu)
		
		if player then
			return player.language or self.default
		else
			return tfm.get.room.language
		end
	end
end

--[[
2: male
1: female
0: none
]]
function Translations:getGender(text, gender)
	text = text:gsub("%((.-)%)", function(str)
		local ge = {}
		for gs in str:gmatch("[^|]+") do
			ge[#ge + 1] = gs
		end
		
		return ge[3 - gender] or ge[2] or ge[1] or "!NIL!"
	end)

	return text
end

function Translations:get(commu, key, formatting, gender)
	commu = self:checkLanguage(commu)
	
	local text, found = self:search(commu, key)	
	
	if found then 
		text = self:getGender(text, gender or 1)
		if formatting then
			return self:format(text, formatting)
		else
			return text
		end
	else
		return text
	end
end

Translations.r = Translations.get

function Translations:getf(commu, str, key, formatting)
	return str:format(self:get(commu, key, formatting))
end

function Translations:set(commu, key, text)
	local obj = self[commu]
	if not obj then return false end
	
	local isTable = (type(text) == "table")
	
	local indexes = {}
	for index in key:gmatch("[^%.]+") do
		indexes[#indexes + 1] = index
	end
	
	local index
	for i = 1, #indexes - 1 do
		index = indexes[i]
		
		if not obj[index] then
			obj[index] = {}
		end
		
		obj = obj[index]
	end
	
	obj[indexes[#indexes]] = text
end

setmetatable(Translations, { -- Seems like this is randomly broken.
	__call = Translations.get
})