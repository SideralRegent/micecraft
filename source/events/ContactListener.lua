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
				ci.contactX + (5 * cos(angle) * REFERENCE_SCALE_X),
				ci.contactY + (5 * sin(angle) * REFERENCE_SCALE_Y),
				CD_MAP
			)
			
			if block then
				-- IDK why, but this wont execute sometimes. It doesn't matter.
				block:onContact(player)
				block:displayTouchParticles(
					ci.contactX, ci.contactY,
					ci.speedX, ci.speedY
				)
			end
		end
	end)
end