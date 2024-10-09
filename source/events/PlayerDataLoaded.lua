Module:on("PlayerDataLoaded", function(playerName, rawdata)
	local player = Room:getPlayer(playerName)
	
	if player then
		player.dataFile = rawdata
		local moduleData = data.getFromModule(rawdata, "MCR")
		player:readData(moduleData)
		player.awaitingData = false
		
		if not player.isActive then
			player:init()
			
			player:promptMainMenu()
		end
	end
end)