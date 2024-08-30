Module:on("NewPlayer", function(playerName)
	Room:newPlayer(playerName)
	
	Room.totalPlayers = Room.totalPlayers + 1
end)