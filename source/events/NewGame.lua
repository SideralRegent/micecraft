do
	local setmetatable = setmetatable
	local rawset = rawset
	local removeObject = tfm.exec.removeObject
	Module:on("NewGame", function()
		Map:restartObjectList()
		
		--- Removes any illegal object.
		-- @name tfm.get.room.objectList.__newindex
		setmetatable(tfm.get.room.objectList, {
			__newindex = function(self, id, object)
				if self[k] then return end
				
				rawset(self, id, object)
				
				for key, value in next, Map.objectList.object do
					if object[key] ~= value then
						return removeObject(id)
					end
				end
				
				Map.objectList[id] = true
				Map.objectList.index = id
				Map:setCandidateShamanObject(nil)
			end
		})
	
		Room.presencePlayerList = nil
		Room.presencePlayerList = {}
		
		for _, player in next, Room.playerList do
			player:setPresenceId()
			if Module.settings.promptsMenu then
				player:promptMainMenu()
			else
				player:checkEnable()
			end
		end
		
		local spawn = Map:getSpawn()
		
		Map:forChunkArea(
			spawn.dx - 400, spawn.dy - 200,
			spawn.dx + 400, spawn.dy + 200, CD_MAP,
			"setState", true, true, nil
		)
		
		--local chunk = Map:getChunk(spawn.x, spawn.y, CD_BLK)
		
		--chunk:setState(true, true, nil)
		
		Module.lastMapLoad = os.time()
	end)
end