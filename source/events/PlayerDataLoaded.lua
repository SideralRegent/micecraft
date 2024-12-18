Module:on("PlayerDataLoaded", function(playerName, rawdata)
	local player = Room:getPlayer(playerName)
	
	if player then
		player.dataFile = rawdata
		local moduleData = data.getFromModule(rawdata, "MCR")
		player:readData(moduleData)
		player.awaitingData = false
		
		if not player.isActive then
			player:init(false)
			
			Module:checkEnableUser(player)
		end
	end
end)