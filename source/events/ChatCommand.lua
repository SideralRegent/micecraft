do
	local Commands = {
		list = {},
		aliases = {}
	}
	local Command = {}
	Command.__index = Command
	
	local setmetatable = setmetatable
	local pcall = pcall
	local table = table
	local ipairs = ipairs
	local unpack = table.unpack
	
	local ranks = enum.ranks
	
	-- Some defaults to not create too many tables
	local none = {}
	local staff = {ranks.staff}
	local moderators = {ranks.staff, ranks.moderator}
	local roomModifier = {ranks.moderator, ranks.roomAdmin}
	local everyone = table.copyvalues(ranks)
	
	function Command:new(commandName, callback, aliases, allowedRanks)
		local this = setmetatable({
			name = commandName,
			callback = callback,
			issues = setmetatable({}, {__index = table}),
			aliases = aliases,
			allowedRanks = {
				[ranks.loader] = true
			}
		}, self)
		
		for _, rank in ipairs(allowedRanks) do
			this.allowedRanks[rank] = true
		end
			
		return this
	end
	
	function Command:isAllowed(player) -- TODO: Check player data
		local rank = player:getRank()
		
		return self.allowedRanks[rank]
	end
	
	function Command:execute(args)
		local ok, result = pcall(self.callback, unpack(args))
		
		if not ok then
			self:logError(result, args[-1])
		end
	end
	
	function Command:logError(result, raw_args)
		local message = ("<N>[Command <ROSE>%s</ROSE>] %s</N> ( %s )"):format(self.name, result, raw_args)
		self.issues:insert({error = result, raw = raw_args})
	
		Module:emitWarning(2, message)
	end
	
	function Commands:new(commandName, aliases, ranks, callback)
		aliases = aliases or {}
		ranks = ranks or {}
		self.list[commandName] = Command:new(commandName, callback, aliases, ranks)
		
		for _, alias in ipairs(aliases) do
			self.aliases[alias] = commandName
		end
	end
	
	
	-- === === === === === === === === === === === === === === === --
	-- For all commands, the first argument passed is the player
	-- that invoked it.
	
	Commands:new("list", none, none, 
	function(player, _)
		tfm.exec.chatMessage("<J>List of Registered Blocks</J>", player.name)
		for index, info in next, blockMeta do
			if type(info) == "table" and info.name then
				tfm.exec.chatMessage(("<CEP>%s</CEP> - <VP>%s</VP>"):format(index, info.name), player.name)
			end
		end
	end)
	
	Commands:new("time", {"t"}, roomModifier,
	function(player, time)
		if time then
			World:setTime(time, false, true)
		else
			tfm.exec.chatMessage(World.currentTime, player.name)
		end
	end)
	
	Commands:new("tp", {"teleport"}, roomModifier,
	function(player, x, y, offset)
		player:move(x, y, offset)
	end)

	Commands:new("btp", {"block_teleport"}, roomModifier,
	function(player, x, y)
		local block = Map:getBlock(x, y, CD_MTX)
		if block then
			player:move(block.dxc, block.dyc, false)
		end
	end)
	
	Commands:new(
		"goto", 
		{"gt"},
		staff,
	function(player, target1, target2)
		local p1 = Room:getPlayer(target1)
		local p2 = Room:getPlayer(target2)
		
		if p2 then -- Move target 1 to target2
			if target1 == "*" then
				for _, p in next, Room.playerList do
					p:move(p2.x, p2.y, false)
				end
			else
				if p1 then
					p1:move(p2.x, p2.y, false)
				end
			end
		else
			if p1 then
				player:move(p1.x, p1.y, false)
			end
		end
	end)

	Commands:new("runtime", {"rt"}, everyone,
	function(player)
		ui.addTextArea(enum.textId.runtime, "NaN ms", player.name, 750, 384, 0, 0, 0x0, 0x0, 1.0, true)
	end)

	Commands:new("reload", none, staff,
	function()
		print("Reloading map.")
		Module:loadMap()
	end)

	Commands:new("save", none, roomModifier,
	function(player)
		if player.name == Room.referenceAdmin then
			player:saveWorld(false)
		end
	end)
	
	Commands:new("api", {"lua", "lu"}, none,
	function(player, func, ...)		
		local env = {
			tfm = {
				enum = tfm.enum,
				exec = tfm.exec,
				get = tfm.get,
			},
			ui = ui,
			system = system,
			debug = debug,
			
			system = system,
			math = math,
			os = os,
			table = table,
			string = string
		}
		
		local obj = table.copy(env)
		
		for index in func:gmatch("[^%.]+") do
			if type(obj) == "table" then
				obj = obj[index]
			else
				break
			end
		end
		
		local returnValue = nil
		
		if type(obj) == "function" then
			returnValue = obj(...)
		else
			returnValue = obj
		end
		
		print(obj)
		
		if returnValue ~= nil then -- This ensures that the whole text will be printed
			local returnText = table.tostring(returnValue, 0, nil, true)
			local textSlideSize = 950
			local textSlides = math.ceil(#returnText / textSlideSize)
			local lead = ""
			for slide=1, textSlides do
				local partition = lead .. returnText:sub(
					((slide - 1) * textSlideSize) + 1,
					math.min(#returnText, slide * textSlideSize)
				)
				local message
				message, lead = partition:match("^(.*)(<[^<]-)$")
				if not message then
					message = partition
				end
				
				tfm.exec.chatMessage(("<N>%s</N>"):format(message), player.name)
			end
		else
			if type(obj) ~= "function" then
				tfm.exec.chatMessage(("This parameter (%s) doesn't exist."):format(func), player.name)
			end
		end
		
	end)

	Commands:new("getchunk", none, everyone,
	function(player)
		local chunk = Map:getChunk(player.x, player.y, CD_MAP)
		if chunk then
			tfm.exec.chatMessage(
				Map:encode(chunk.xf, chunk.yf, chunk.xb, chunk.yb), 
				player.name
			)
		end
	end)
	
	-- === === === === === === === === === === === === === === === --
	
	function Commands:get(commandName)
		return self.list[commandName] or self.list[self.aliases[commandName]]
	end
	
	Module.userInputClasses["ChatCommand"] = Commands
	
	local booleans = {
		["true"] = true,
		["yes"] = true,
		["y"] = true,
		
		["false"] = false,
		["no"] = false,
		["n"] = false
	}
	local tonumber, tostring = tonumber, tostring
	
	function Commands:parse(message)
		local command, args = "", {}
		
		args[-1] = message
		
		local value, counter = nil, 1
		for arg in message:gmatch("[^ ]+") do
			if booleans[arg] ~= nil then
				value = booleans[arg]
			else
				if arg == "nil" then
					value = nil
				else
					value = tonumber(arg) or arg
				end
			end
			
			args[counter] = value
		
			counter = counter + 1
		end
		
		command = tostring(args[1]):lower()
		args[1] = nil
		
		return command, args
	end
	
	function Commands:process(playerName, message)
		local player = Room:getPlayer(playerName)
		
		if player and player.perms.useCommands then
			local commandName, arguments = self:parse(message)
			local command = self:get(commandName)
			arguments[1] = player
			
			if command then
				if command:isAllowed(player) then
					command:execute(arguments)
				end
			end
		end
	end
	
	Module:on("ChatCommand", function(playerName, message)
		Commands:process(playerName, message)
	end)
end