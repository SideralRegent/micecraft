local logpath = ("./build/log/%s.lua"):format(os.date("%Y%m%d%H%M%S"))
local buildpath = './build/micecraft.lua'

local shouldLog = false
local releaseBuild = false
local preview = false
local shouldCreateFile = false

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
		"math",
		"table",
		"data",
		"timer",
		"tick",
		"color"
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
	--[[	__name = "Interface",
		__directory = "source/interface",
		__docs = true,
		"ui",
		"object",
		"template"]]
	},
	{
		__name = "Map",
		__directory = "source/map",
		__docs = true,
		"init",
		"environment",
		"interaction",
		"field",
		"physics",
		"decoration",
		"encoding"
	},
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
		__name = "Player",
		__directory = "source/player",
		__docs = true,
		"init",
		"data",
		"update",
		"action",
		"handle",
		"world"
	},
	{
		__name = "MetaData",
		__directory = "source/metadata",
		__docs = true,
		"logic",
		"block"
	},
	{
		__name = "Modes",
		__directory = "source/modes",
		__docs = false,
		"init",
		"vanilla",
		"testing"
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

os.readFile = function(fileName)
    local File, result = io.open(fileName, "r")
    local raw

    if File then
        raw = File:read("*all")
        File:close()
    end

    return raw, result
end

local formatDoc = function(dt)
	local dlines = {}
	local plist1 = {}
	local plist2 = {}
	local rlist = {}
	for pos, param in ipairs(dt.params) do
		plist1[pos] = ("`%s`: %s"):format(param.name, (param.type or ""):lower())
		plist2[pos] = ("- **%s** (`%s`) : %s"):format(param.name, param.type, param.description)
	end
	
	for pos, ret in ipairs(dt.returns) do
		rlist[pos] = ("- `%s` %s"):format(ret.type, ret.description)
	end
	
	plist1 = #plist1 > 0 and table.concat(plist1, ", ") or ""
	plist2 = #plist2 > 0 and table.concat(plist2, "\n") or ""
	
	dlines[1] = ("### **%s** ( %s )"):format(dt.name, plist1) 
	dlines[2] = dt.summary .. " " .. table.concat(dt.description, " "):gsub("  ", " ")
	if plist2 ~= "" then
		dlines[3] = "\n\n**Parameters:**"
		dlines[4] = plist2
	end
	
	if #rlist > 0 then 
		dlines[#dlines + 1] = "\n\n**Returns:**"
		dlines[#dlines + 1] = table.concat(rlist, "\n")
	end
	
	return table.concat(dlines, "\n")
end

local generateDocs = function(content, moduloName)
	local docs = {}
	
	for doc in content:gmatch("(%-%-%-.-%-%-.-)\n%s+[^%-]+") do
		local this = {
			description = {},
			params = {},
			returns = {}
		}
		for line in doc:gmatch("[^\n]+") do
			local command, description = line:match("-- @(.-) (.+)$")
			if command then
				if command == "param" then
					local type, pname, desc = description:match("^(.-):(.-) (.+)$")
					this.params[#this.params + 1] = {
						type = type,
						name = pname,
						description = desc
					}
				elseif command == "return" then
					local type, desc = description:match("^`(.-)` (.+)$")
					this.returns[#this.returns + 1] = {
						type = type,
						description = desc
					}
				elseif command == "name" then
					this.name = description
				else
					this[command] = description
				end
			else
				description = line:match("%-%-%- (.+)$")
				if description then
					this.summary = description
				else
					description = line:match("%-%- (.+)$")
					
					this.description[#this.description + 1] = description
				end
			end
		end
		
		docs[#docs + 1] = formatDoc(this)
	end

	if #docs > 0 then
		return table.concat(docs, "\n\n---\n\n")
	else
		return nil
	end
end

local buildModule = function(modulo, log)
    local arrayFiles = {}
	local docs = {}
    local path
    local fileContent, result

    for index, fileName in ipairs(modulo) do
        path = ("%s/%s.lua"):format(modulo.__directory, fileName)
        fileContent, result = os.readFile(path)
        if log then
            if fileContent then
				if modulo.__docs then docs[#docs + 1] = generateDocs(fileContent, modulo.__name) end
                print(("[success] %s (%d)"):format(path, #fileContent))

				-- So the extension doesn't annoy me about it
				fileContent = fileContent:gsub("%-%-%s-[T]ODO:.-\n", "\n")
                if releaseBuild then
                    fileContent = fileContent:gsub("[^%p ]print", "--%1")
					fileContent = fileContent:gsub("%-%-%[%[.-%]%]", "")
					fileContent = fileContent:gsub("%-%-.-\n", "\n")
					fileContent = fileContent:gsub("\n%s*", "\n")
					fileContent = fileContent:gsub("([%w])%s-([=,])%s-([%w{])", "%1%2%3")
                end
            else
                print(("[failure] %s: %s"):format(path, result))
            end
        end
        if releaseBuild then
            arrayFiles[index] = fileContent or ""
        else
            arrayFiles[index] = ("-- >> %s\n%s\n-- %s <<"):format(path, fileContent or "", path)
        end
    end

    local filesComp = table.concat(arrayFiles, "\n") or ""
	

    if log then
        print(("[MODULE] '%s' has been built (%d characters).\n"):format(modulo.__name, #filesComp))
    end
	
	if modulo.__docs then
		local docsComp = table.concat(docs, "\n\n---\n\n") or ""
		local dpath = ("%s/%s.md"):format(modulo.__directory, modulo.__name)
		local Doc = io.open(dpath, "w")
		Doc:write(("# %s\n\n---\n\n%s"):format(modulo.__name, docsComp))
		Doc:close()
	end
	
    local Module

    if releaseBuild then
        Module = filesComp
    else
        Module = ("-- %s\t%s\t%s --\n\n %s"):format(("="):rep(7), modulo.__name, ("="):rep(7), filesComp)
    end

    return Module
end

do
	local build
    local arrayModules = {}
    for index, modulo in ipairs(fileList) do
        arrayModules[index] = buildModule(modulo, true)
    end

    local compModules = table.concat(arrayModules, "\n")
    do
		local licenseFile = io.open("./LICENSE", "r")
        if licenseFile then
            local license = licenseFile:read("*all")
            
            build = ("--[[\n\n%s\n]]--\n%s"):format(license, compModules)
            licenseFile:close()
        end
	end
    
    
	
	if shouldCreateFile then
		local File, result = io.open(buildpath, "w")
		
		if File then
			File:write(build)
			File:close()
			
			print("SUCCESS! Module succesfully written at " .. buildpath .. ". (" .. build:len() .. " characters)")
		else
			print(("Failure on writing the final file on %s: %s"):format(buildpath, result))
		end
	else
		os.remove(buildpath)
	end

    do -- Assert

        load = loadstring or load
		
        local success, code = load('package.path = "build/?.lua;" .. package.path; require("tfmenv");' .. build .. "\n\nreturn Field", "micecraft")
        if success then
            print("[TEST] File syntax is correct. Testing execution...\n")
			
            local assertion, result = pcall(success)
            if assertion then
                print("\n[TEST] Module executes correctly !")
            else
                print("\n[FAILURE] " .. result)
				
				local line = tonumber(result:match(":(%d+):"))
				
				local cline = 1
				local target = 1
				local previous = 1
				
				while cline < line do
					previous = target
					target = build:find("\n", target + 1)
					cline = cline + 1
				end
				-- source/utils/math.lua <<
				local fileName = build:match("-- source/([%w/%.]+) <<", target)
				local fileInfo = build:match("%s*([^\n]+)\n", target)
				print(("[FAILURE] At file %s\nline: %s"):format(fileName, fileInfo))
            end
			
			return result, {source=build, preview=preview}
        else
            print("[TEST] File fails at executing: " .. code)
        end
    -- else
     --   
    end
	
	if shouldLog then
		File, result = io.open(logpath, "w")
        if File then
            File:write(arrayModules)
            File:close()
        end
	end
end