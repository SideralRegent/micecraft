do
	local saw = {}
	Module:on("Play", function(player) -- Event needs to be defined.
	end)	Module:on("NewPlayer", function(playerName)
		-- This stuff, however, is not necessary.
		if not saw[playerName] then
			tfm.exec.chatMessage(Translations(playerName, "howto"), playerName)
			saw[playerName] = true
		end
	end)
end