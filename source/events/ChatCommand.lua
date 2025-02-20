do
	local Commands = {
		list = {},
		aliases = {},
		safe = {}
	}
	local Command = {}
	Command.__index = Command
	
	local setmetatable = setmetatable
	local pcall = pcall
	local table = table
	local ipairs = ipairs
	local table_unpack = table.unpack
	
	local mc_ranks = mc.ranks
	
	-- Some defaults to not create too many tables
	local preset_none = {}
	local preset_staff = {mc_ranks.staff}
	local preset_moderators = {mc_ranks.staff, mc_ranks.moderator}
	local preset_roomModifier = {mc_ranks.moderator, mc_ranks.roomAdmin}
	local preset_everyone = table.copyvalues(mc_ranks)
	
	function Command:new(commandName, callback, aliases, allowedRanks)
		local this = setmetatable({
			name = commandName,
			callback = callback,
			issues = setmetatable({}, {__index = table}),
			aliases = aliases,
			allowedRanks = {
				[mc_ranks.loader] = true
			}
		}, self)
		
		for _, rank in ipairs(allowedRanks) do
			this.allowedRanks[rank] = true
		end
			
		return this
	end
	
	function Command:isAllowed(player) -- TODO: Check player data
		return player.perms.useCommands and self.allowedRanks[player:getRank()]
	end
	
	function Command:execute(args)
		local ok, result = pcall(self.callback, table_unpack(args))
		
		if not ok then
			self:logError(result, args[-1])
		end
	end
	
	function Command:logError(result, raw_args)
		local message = ("<N>[Command <ROSE>%s</ROSE>] %s</N> ( %s )"):format(self.name, result, raw_args)
		self.issues:insert({error = result, raw = raw_args})
	
		Module:emitWarning(mc.severity.mild, message)
	end
	
	function Commands:new(commandName, aliases, ranks, callback, safe)
		assert( type(commandName) == "string"
			and (type(aliases) == "table" or not aliases)
			and (type(ranks) == "table" or not ranks)
			and type(callback) == "function", 
			"Malformed eventChatCommand callback for key " .. tostring(commandName).. "."
		)
		
		aliases = aliases or {}
		ranks = ranks or {}
		self.list[commandName] = Command:new(commandName, callback, aliases, ranks)
		
		for _, alias in ipairs(aliases) do
			self.aliases[alias] = commandName
		end
		
		self.safe[commandName] = not not safe
	end
	
	
	-- === === === === === === === === === === === === === === === --
	-- For all commands, the first argument passed is the player
	-- that invoked it.
	
	Commands:new("list", preset_none, preset_none, 
	function(player, _)
		tfm.exec.chatMessage("<J>List of Registered Blocks</J>", player.name)
		for index, info in next, blockMeta do
			if type(info) == "table" and info.name then
				tfm.exec.chatMessage(("<CEP>%s</CEP> - <VP>%s</VP>"):format(index, info.name), player.name)
			end
		end
	end)
	
	Commands:new("time", {"t"}, preset_roomModifier,
	function(player, time)
		if time then
			World:setTime(time, false, true)
		else
			tfm.exec.chatMessage(World.currentTime, player.name)
		end
	end)
	
	Commands:new("tp", {"teleport"}, preset_roomModifier,
	function(player, x, y, offset)
		player:move(x, y, offset)
	end)	Commands:new("btp", {"block_teleport"}, preset_roomModifier,
	function(player, x, y)
		local block = Map:getBlock(x, y, CD_MTX)
		if block then
			player:move(block.dxc, block.dyc, false)
		end
	end)
	
	Commands:new(
		"goto", 
		{"gt"},
		preset_staff,
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
	end)	Commands:new("runtime", {"rt"}, preset_everyone,
	function(player)
		ui.addTextArea(mc.textId.runtime, "NaN ms", player.name, 755, 384, 45, 0, 0x0, 0x0, 1.0, true)
	end)	Commands:new("reload", preset_none, preset_staff,
	function()
		print("Reloading map.")
		Module:loadMap()
	end)	Commands:new("save", preset_none, preset_roomModifier,
	function(player)
		if player.name == Room.referenceAdmin then
			player:saveWorld(false)
		end
	end)
	
	Commands:new("api", {"lua", "lu"}, preset_none,
	function(player, func, ...)		
		local env = table.shallowcopy(_G)
		
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
				
		if returnValue ~= nil then -- This ensures that the whole text will be printed
			local returnText = table.tostring(returnValue, 0, nil, not returnValue == env, 3)
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
				tfm.exec.chatMessage(("This parameter (%s) doesn't exist."):format(tostring(func)), player.name)
			end
		end
		
	end)	Commands:new("logs", preset_none, preset_staff,
	function(player)
		local logs = Module.errorLog:concatf("message", "\n"):sub(1, 990)
		
		tfm.exec.chatMessage(logs, player.name)
	end)
	Commands:new("getchunk", preset_none, preset_everyone,
	function(player)
		local chunk = Map:getChunk(player.x, player.y, CD_MAP)
		if chunk then
			tfm.exec.chatMessage(
				Map:encode(chunk.xf, chunk.yf, chunk.xb, chunk.yb), 
				player.name
			)
		end
	end)
	
	Commands:new("perms", preset_none, preset_staff,
	function(player, targetPlayer)
		local target
		if targetPlayer then
			target = Room:getPlayer(targetPlayer)
		else
			target = player
		end
		
		if target then
			tfm.exec.chatMessage(table.tostring(target.perms, 0, nil, true, nil), player.name)
		end
	end, true)

	Commands:new("checkperms", preset_none, preset_everyone,
	function(player)
		player:setRankPermissions()
	end, true)
	
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
		
		if player then
			local commandName, arguments = self:parse(message)
			local command = self:get(commandName)
			arguments[1] = player
			
			if command then
				if self.safe[commandName] or command:isAllowed(player) then
					command:execute(arguments)
				else
					tfm.exec.chatMessage("You're not allowed to use this command.", playerName)
				end
			end
		end
	end
	
	Module:on("ChatCommand", function(playerName, message)
		Commands:process(playerName, message)
	end)
end