do
	local atan2 = math.atan2
	local sin = math.sin
	local cos = math.cos
	Module:on("ContactListener", function(playerName, _, ci)
		local player = Room.playerList[playerName]
		
		if player then
			local angle = atan2(
				ci.contactY - ci.playerY,
				ci.contactX - ci.playerX
			)
			
			local block = Map:getBlock(
				ci.contactX + (cos(angle) * 5),
				ci.contactY + (sin(angle) * 5),
				CD_MAP
			)
			
			if block then
				block:onContact(player)
			end
		end
	end)
end