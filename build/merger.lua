-- Merger by Rafael Flores. The UNLICENSE applies to this file.
local INCREMENT_PATCH = true

local Merger = {
	scriptName = "Micecraft",
	scriptVersion = "",
	path = {
		log = ("./build/log/%s.lua"):format(os.date("%Y%m%d%H%M%S")),
		build = "./build/micecraft.lua",
		version = "./build/version"
	},
	
	settings = {
		shouldLog = false,
		releaseBuild = true,
		preview = true,
		shouldCreateFile = true
	},
	
	script = ""
}

local fileList = {
    {
        __name = "Init",
        __directory = "source/init",
		__docs = false,
        "init",
		"constants"
    },
	{
		__name = "Utilities",
		__directory = "source/utils",
		__docs = true,
		"tfm",
		"math",
		"debug",
		"table",
		"data",
		"timer",
		"tick",
		"color",
		"os",
	},
	{
		__name = "Head",
		__directory = "source/init",
		__docs = true,
		"module",
		"room",
		"env",
		"enum",
		"prestart"
	},
	{
		__name = "Interface",
		__directory = "source/interface",
		__docs = true,
		"def",
		"menu"
	},
	-- >> MAP
	{
		__name = "Map",
		__directory = "source/map",
		__docs = true,
		"init",
		"environment",
		"interaction"
	},
	{
		__name = "Mapgen",
		__directory = "source/map/generation",
		__docs = true,
		"field",
		"gen",
		"physics"
	},
	{
		__name = "Maptrix",
		__directory = "source/map/matrix",
		__docs = true,
		"decoration",
		"encoding"
	},
	-- << MAP
	{
		__name = "World",
		__directory = "source/world",
		__docs = true,
		"init",
		"time",
	},
	{
		__name = "Block",
		__directory = "source/block",
		__docs = true,
		"init",
		"interaction",
		"logic",
		"graphics",
		"misc"
	},
	{
		__name = "Chunk",
		__directory = "source/chunk",
		__docs = true,
		"init",
		"physics",
		"graphics",
		"management",
		"queue"
	},
	{
		__name = "Structure",
		__directory = "source/structure",
		__docs = false,
		"init"
	},
	{
		__name = "Item",
		__directory = "source/item",
		__docs = false,
		"item",
		"container",
		"bank",
		"selector",
	},
	{
		__name = "Player",
		__directory = "source/player",
		__docs = true,
		"init",
		"check",
		"data",
		"inventory",
		"update",
		"action",
		"handle",
		"world",
		"interface"
	},
	{
		__name = "MetaData",
		__directory = "source/metadata",
		__docs = true,
		"logic",
		"block",
		"item"
	},
	{
		__name = "Modes",
		__directory = "source/modes",
		__docs = false,
		"init",
		"default",
		"testing",
		"lobby",
		"personal"
	},
	{
		__name = "Events",
		__directory = "source/events",
		__docs = false,
		"Loop",
		"NewGame",
		"ContactListener",
		"NewPlayer",
		"PlayerDataLoaded",
		"PlayerLeft",
		"Mouse",
		"Keyboard",
		"PlayerDied",
		"PlayerRespawn",
		"ChatCommand",
		"ColorPicked",
		"TextAreaCallback",
		"Pause",
		"Resume"
	},
	{
		__name = "Launch",
		__directory = "source/launch",
		__docs = false,
		--"debug",
		"launch",
	--	"visualizator"
	}
}

local os = os
local io = io
local tonumber = tonumber
local ipairs = ipairs
local LOG

local table_concat = table.concat

do
	local print = print
	LOG = function(text, ...)
		print(text:format(...))
	end
end

os.readFile = function(fileName)
    local File, result = io.open(fileName, "r")
    local raw

    if File then
        raw = File:read("*all")
        File:close()
    end

    return raw, result
end

os.writeFile = function(fileName, contents)
	local File, result = io.open(fileName, 'w')
	
	if File then
		File:write(contents)
		File:close()
	end
	
	return (not not File), result
end

function Merger:setVersion()
	local verFile = os.readFile(self.path.version)
	local major, minor, patch, tag = verFile:match(
		"^major=(%d+),minor=(%d+),patch=(%d+),tag=(.+)$"
	)
	
	patch = tonumber(patch)
	
	if INCREMENT_PATCH then
		patch = patch + 1
	end
	
	if tag ~= "null" then
		self.scriptVersion = ("%s.%s.%d-%s"):format(major, minor, patch, tag)
	else
		self.scriptVersion = ("%s.%s.%d"):format(major, minor, patch)
	end
	
	local versionInfo = ("major=%s,minor=%s,patch=%d,tag=%s"):format(
		major, minor, patch, tag
	)
	
	os.writeFile(self.path.version, versionInfo)
end


function Merger:formatDocumentation(data)
	local lines = {}
	local inlineArguments
	local listArguments
	local returns = {}
	
	-- Formats return segment
	for index, retValue in ipairs(data.returns) do
		returns[index] = ("- `%s` %s"):format(retValue.type, retValue.description)
	end
			
	if #data.params > 0 then
		-- Format all given parameters
		inlineArguments = {}
		listArguments = {}
		
		for index, parameter in ipairs(data.params) do
			-- ("`%s`: %s"):format(param.name, (param.type or ""):lower())
			inlineArguments[index] = parameter.name
			
			listArguments[index] = ("- **%s** (`%s`) : %s"):format(
				parameter.name,
				parameter.type,
				parameter.description
			)
		end
		
		inlineArguments = table_concat(inlineArguments, ", ")
		listArguments = table_concat(listArguments, "\n")
	else
		inlineArguments = ""
		listArguments = ""
	end
	
	lines[1] = ("### **%s** ( %s )"):format(data.name, inlineArguments)
	lines[2] = ("%s %s"):format(
		data.summary, 
		table_concat(data.description, " "):gsub("  ", " ")
	)
	
	if listArguments ~= "" then
		lines[3] = "\n**Parameters:**"
		lines[4] = listArguments
	end
	
	if #returns > 0 then
		lines[#lines + 1] = "\n**Returns:**"
		lines[#lines + 1] = table_concat(returns, '\n')
	end
	
	return table_concat(lines, '\n')
end

function Merger:generateDocs(content, moduleName)
	local docs = {}
	
	for docText in content:gmatch("(%-%-%-.-%-%-.-)\n%s+[^%-]+") do
		local doc = {
			description = {},
			params = {},
			returns = {}
		}
		
		for line in docText:gmatch("[^\n]+") do
			local command, description = line:match("-- @(.-) (.+)$")
			if command then
				if command == "param" then
					local type, pname, desc = description:match("^(.-):(.-) (.+)$")
					doc.params[#doc.params + 1] = {
						type = type,
						name = pname,
						description = desc
					}
					
				elseif command == "return" then
					local type, desc = description:match("^`(.-)` (.+)$")
					doc.returns[#doc.returns + 1] = {
						type = type,
						description = desc
					}
					
				elseif command == "name" then
					doc.name = description
				else
					doc[command] = description
				end
			else
				description = line:match("%-%-%- (.+)$")
				if description then
					doc.summary = description
				else
					description = line:match("%-%- (.+)$")
					
					doc.description[#doc.description + 1] = description
				end
			end
		end
		
		docs[#docs + 1] = self:formatDocumentation(doc)
	end

	if #docs > 0 then
		return table_concat(docs, "\n\n---\n\n")
	else
		return nil
	end
end

function Merger:formatRelease(text)
	return text
		:gsub("[^%p ]print", "--%1") -- Removes all prints (comments them)
		:gsub("%-%-%[%[.-%]%]", "") -- Removes all comment blocks
		:gsub("%-%-.-\n", "\n") -- Removes all inline comments
	--	:gsub("\n%s*", "\n") -- Removes all excess lines & tabs
	--	:gsub("([%w])%s-([=,])%s-([%w{])", "%1%2%3") -- Removes all unnecesary spaces
end

function Merger:processModule(directory, log)
	local filesList = {}
	local docsList = {}
    local path
    local fileContent, result

    for index, fileName in ipairs(directory) do
        path = ("%s/%s.lua"):format(directory.__directory, fileName)
		
        fileContent, result = os.readFile(path)
        if log then
            if fileContent then
				if directory.__docs then 
					docsList[#docsList + 1] = self:generateDocs(
						fileContent, 
						directory.__name
					) 
				end
				
				LOG("[success] %s (%d ch)", path, #fileContent)

				-- So the extension doesn't annoy me about it
				-- fileContent = fileContent:gsub("%-%-%s-[T]ODO:.-\n", "\n")
				
                if self.settings.releaseBuild then
					fileContent = self:formatRelease(fileContent)
                end
            else
				LOG("[failure] %s: %s", path, result)
            end
        end
		
        if self.settings.releaseBuild then
            filesList[index] = fileContent or ""
        else
            filesList[index] = ("-- >> %s\n%s\n-- %s <<"):format(path, fileContent or "", path)
        end
    end
	
	return filesList, docsList
end

local separator = ('='):rep(7)

function Merger:buildModule(directory, log)
	local filesList, docsList = self:processModule(directory, log)
	
	local fileComposition = table_concat(filesList, "\n") or ""

    if log then
		LOG("[Module] '%s' has been built (%d ch).\n", directory.__name, #fileComposition)
    end
	
	if directory.__docs then
		local docsComposition = table_concat(docsList, "\n\n---\n\n") or ""
		local docsPath = ("%s/%s.md"):format(directory.__directory, directory.__name)
		
		local docsText = ("# %s\n\n---\n\n%s"):format(directory.__name, docsComposition)
		
		os.writeFile(docsPath, docsText)
	end
	
    local _module

    if self.settings.releaseBuild then
        _module = fileComposition
    else
        _module = ("-- %s\t%s\t%s --\n\n %s"):format(
			separator, 
			directory.__name, 
			separator, 
			fileComposition
		)
    end

    return _module
end

function Merger:getLicense()
	local text = os.readFile("./LICENSE")
	
	if text then
		return ("--[[\n%s.lua\n%s\n]]--"):format(self.scriptName, text)
	else
		return ""
	end
end

function Merger:buildAllModules(directories)
	local directoriesList = {}
	
	for index, directory in ipairs(directories) do
        directoriesList[index] = self:buildModule(directory, true)
					:gsub("SCRIPT_VERSION", self.scriptVersion)
    end
		
	return table_concat(directoriesList, "\n")
end


function Merger:makeFile()
	self:setVersion()
	
	local licenseText = self:getLicense()
	local directoriesText = self:buildAllModules(fileList)
	
	local script = ("%s\n%s"):format(licenseText, directoriesText)
	
	if self.settings.shouldCreateFile then
		local success, reason = os.writeFile(self.path.build, script)
		if success then
			LOG("SUCCESS! Script succesfully written at %s. (%d characters)", self.path.build, script:len())
		else
			LOG("Failure on writing the final file on %s: %s", self.path.build, reason)
		end
	else
		os.remove(self.path.build)
	end
	
	self.script = script
end

function Merger:testScript()
	local load = loadstring or load
	
	local testCode = 'package.path = "build/?.lua;" .. package.path; require("tfmenv");' .. self.script
	
	local codeChunk, reason = load(testCode, self.scriptName)
	
	if codeChunk then
		LOG("[TEST] File syntax is correct. Testing execution...\n")
		
		local assertion, result = pcall(codeChunk)
		if assertion then
			LOG("\n[TEST] Script executes correctly !")
		else
			LOG("\n[FAILURE] %s", result)
			
			-- Finds the line giving trouble
			local line = tonumber(result:match(":(%d+):"))
			
			local currentLine = 1
			local target = 1
			local previous = 1
			
			while currentLine < line do
				previous = target
				target = self.script:find("\n", target + 1)
				currentLine = currentLine + 1
			end
			
			local fileName = self.script:match("-- ([%w/%.]+) <<", target)
			local fileInfo = self.script:match("%s*([^\n]+)\n", target)
			
			LOG("[FAILURE] At file %s\nline: %s", fileName, fileInfo)
		end
		
		return result, {
			source = self.script, 
			preview = self.settings.preview
		}
	else
		LOG("[TEST] Syntax error: %s", reason)
		
		return false, {
			source = self.script,
			preview = false
		}
	end
end

function Merger:logFile()
	os.writeFile(self.path.log, self.script)
end

function Merger:run()
	self:makeFile()
	
	local success, info = true, {source=self.script}
	
	if self.settings.preview then
		success, info = self:testScript()
	end
	
	if self.settings.shouldLog then
		self:logFile()
	end
	
	return success, info
end

return Merger:run()