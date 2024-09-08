do
	local next = next
	Module:on("Loop", function(elapsedTime)
		Module:setCycle()
			
		if elapsedTime >= 500 then
			for _, player in next, Room.playerList do
				player:updateInformation()
				player:setClock(500, true, true)
			end
		end
	end)
end

Module:on("Loop", function()
	World:stepTime()
	Tick:handle()
end)

Module:on("Loop", function()
	Timer:handle()
end)
