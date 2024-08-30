Module:on("PlayerLeft", function(playerName)
	Room:playerLeft(playerName)
	
	Room.totalPlayers = Room.totalPlayers - 1
end)