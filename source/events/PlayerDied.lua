do
	local respawnPlayer = tfm.exec.respawnPlayer
	Module:on("PlayerDied", function(playerName)
		local player = Room:getPlayer(playerName)
	
		if player then
			player.isAlive = false
		end
	end)
end