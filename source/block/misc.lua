do	
	--- Spreads particles from the Block.
	-- @name Block:spreadParticles
	-- @return `Boolean` Whether the particles were successfully spreaded or not
	local displayParticle = tfm.exec.displayParticle
	local random = math.random
	function Block:spreadParticles()
		local par = self.particles
		local pcount = #par
		
		if pcount > 0 then
			local amount = random(6, 11)
			local tw = (2*self.width) / 3
			local th = (2*self.height) / 3
		
			local xc, yc = self.dxc, self.dyc
			
			local xt, xf, xv, yv
			
			for i = 1, amount do
				xt = random(tw)
				xf = random(2) == 1 and -1 or 1
				xv = (random(40,60) / 10) * xf * REFERENCE_SCALE_X
				yv = -0.2 * REFERENCE_SCALE_Y
				displayParticle(
					par[random(pcount)],
					xc + (xt * xf),
					yc + random(-th, th),
					xv, yv,
					-xv/10, -yv/10
				)
			end
			
			return true
		end
		
		return false
	end
	
	-- To do: Particles should spread differently according to a specified 'mode'
end

do
	--- Plays the specified sound for the Block.
	-- A block can have different types of sounds according to the event that happens to them.
	-- @name Block:playSound
	-- @param String:soundKey The key that identifies the event. If it doesn't exist, it will default to a regular sound.
	-- @param Player:player The player that should hear this sound, if nil, applies to everyone.
	-- @return `Boolean` Whether the sound was successfully played or not
	local playSound = tfm.exec.playSound
	function Block:playSound(soundKey, player)
		-- pc - bc
		if self.sound then
			local sound = self.sound[soundKey] or self.sound.default
			playSound(
				sound, 100,
				player and (player.x - self.dxc) * REFERECE_SCALE_X or self.dxc,
				player and (player.y - self.dyc) * REFERECE_SCALE_Y or self.dyc,
				player and player.name or nil
			)
			
			return true
		end
		
		return false
	end
	
	function Block:hasActiveTask(tick)
		tick = tick or Tick.current 
		local task = Tick:getTask(self.eventTimer)
		
		if task then
			if tick ~= -1 then
				return (task.tickTarget == tick)
			else
				return true
			end
		else
			return false
		end
		
		return false
	end
end