do
	local setmetatable = setmetatable
	local rawset = rawset
	local removeShamanObject = tfm.exec.removeObject
	Module:on("NewGame", function()
		Map.objectList = {}
		--- Removes any illegal object.
		-- @name tfm.get.room.objectList.__newindex
		setmetatable(tfm.get.room.objectList, {
			__newindex = function(self, k, v)
				if Map.objectList[k] then
					rawset(self, k, v)
				else
					removeShamanObject(k)
				end
			end
		})
		
		
		
		--[[for _, player in next, Room.playerList do
			player:showMainMenu(true)--player:init()
		end]]
	end)
end