Module:on("NewPlayer", function(playerName)
	local player = Room:newPlayer(playerName)
	
	Room.totalPlayers = Room.totalPlayers + 1
end)