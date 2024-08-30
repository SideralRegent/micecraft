Module:on("PlayerRespawn", function(playerName)
	local player = Room:getPlayer(playerName)
	
	if player then
		player.isAlive = true
		player:freeze(true, false, 0, 0)
	end
end)