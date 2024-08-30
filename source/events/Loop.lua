do
	local next = next
	Module:on("Loop", function(elapsedTime, remainingTime)
		Module:setCycle()
			
		if elapsedTime >= 500 then
			for playerName, player in next, Room.playerList do
				player:updateInformation()
				player:setClock(500, true, true)
			end
		end
	end)
end

Module:on("Loop", function(elapsedTime, remainingTime)
	World:stepTime()
	Tick:handle()
end)

Module:on("Loop", function(elapsedTime, remainingTime)
	Timer:handle()
end)
