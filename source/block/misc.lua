do	
	--- Makes a visible pulse.
	-- @name Block:pulse
	
	function Block:pulse(image)
		image = image or "1817dc55c70.png"
		tfm.exec.removeImage(tfm.exec.addImage(image, "!9999999", self.dx, self.dy, nil, 1, 1, 0, 1, 0, 0, false), true)
	end
	
	local displayParticle = tfm.exec.displayParticle
	local random = math.random
	local atan2 = math.atan2
	local abs = math.abs
	
	local pi = math.pi
	local PIo4 = pi / 4
	
	local floor = math.floor
	local magnitude = math.magnitude
	
	function Block:displayTouchParticles(x, y, vx, vy)
		local angle = atan2(y - self.dyc, x - self.dxc)
		local amount = random(2, floor(magnitude(vx, vy)))
		
		if abs(angle % pi) <= (pi / 4) then -- Horizontal
			if abs(vx) > 4 then
				local dir = (x < (self.dx + 1)) and -1 or 1
				local xv
				local ay
				for _ = 1, amount do
					xv = (random(40, 60) / 500) * REFERENCE_SCALE_X * vx
					ay = -(random(20, 30) / 100) * REFERENCE_SCALE_Y
					displayParticle(
						self.particle,
						x, y,
						xv, vy
						-xv / 15, ay
					)
				end
			end
		else -- Vertical
			if vy < -2.5 or vy > 5.0 then
				local ay, xv
				for _ = 1, amount do
					ay = (random(20, 30) / 120) * REFERENCE_SCALE_Y
					xv = (random(7, 14) / 150) * vx * REFERENCE_SCALE_X
					
					displayParticle(
						self.particle,
						x, y,
						xv, 0,
						-xv / 15, ay 
					)
				end
			end
		end
	end
	
	function Block:displayParticles(type, x, y, vx, vy)
		if not self.particle then return end
		
		local amount
		local PD = enum.particle_display
		
		if type == PD.touch then
			self:displayTouchParticles(x, y, vx, vy)
		end
	end
	
	function Block:spreadParticles()
		local par = self.particles
		local pcount = #par
		
		if pcount > 0 then
			local amount = random(6, 11)
			local tw = (2*self.width) / 3
			local th = (2*self.height) / 3
		
			local xc, yc = self.dxc, self.dyc
			
			local xt, xf, xv, yv
			
			while amount > 0 do
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
				amount = amount - 1
			end
			
			return true
		end
		
		return false
	end
	
	-- TODO: Particles should spread differently according to a specified 'mode'
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
				player and (player.x - self.dxc) * REFERENCE_SCALE_X or self.dxc,
				player and (player.y - self.dyc) * REFERENCE_SCALE_Y or self.dyc,
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
	
	function Block:getDecoTile()
		return Map:getDecoTile(self.x, self.y)
	end
end