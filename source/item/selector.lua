function SelectFrame:new(playerName)
	return setmetatable({
		playerName = playerName
	}, self)
end