do	
	--- Makes a visible pulse.
	-- @name Block:pulse
	-- @param String:image A image to make the pulse. If not given will default to white
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
	
	--- Displays particles when a block is touched.
	-- They display from the contact point and try to follow a convincing
	-- representation of real life dust and debris coming out of nature objects
	-- life stones and such. 
	-- @param Number:x X coordinate
	-- @param Number:y Y coordinate
	-- @param Number:vx X speed (player)
	-- @param Number:vy Y speed (player)
	function Block:displayTouchParticles(x, y, vx, vy)
		local angle = atan2(y - self.dyc, x - self.dxc)
		local amount = random(2, floor(magnitude(vx, vy)))
		
		if abs(angle % pi) <= PIo4 then -- Horizontal
			if abs(vx) > 4 then
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
	
	--- Displays particles from the block according to a specified mode.
	-- @param Number:type The spreading type
	-- @param Number:x X coordinate
	-- @param Number:y Y coordinate
	-- @param Number:vx X speed (player)
	-- @param Number:vy Y speed (player)
	function Block:displayParticles(type, x, y, vx, vy)
		if not self.particle then return end
		
	--	local amount
		local PD = enum.particle_display
		
		if type == PD.touch then
			self:displayTouchParticles(x, y, vx, vy)
		end
	end	
	-- TODO: Particles should spread differently according to a specified 'mode'
end

do
	--- Plays the specified sound for the Block.
	-- A block can have different types of sounds according to the event that happens to them.
	-- @name Block:playSound
	-- @param String:soundKey The key that identifies the sound. If it doesn't exist, it will default to a regular sound.
	-- @param Player:player The player that should hear this sound, if nil, applies to everyone.
	-- @return `Boolean` Whether the sound was successfully played or not
	local playSound = tfm.exec.playSound
	function Block:playSound(soundKey, player)
		
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
		local task = Tick:getTask(self.eventTimer)
		
		if task then
			tick = tick or Tick.current 
			
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
	
	--- Returns the decorative tile that lies in the same space grid as this block.
	-- @return `Tile` The tile object
	function Block:getDecoTile()
		return Map:getDecoTile(self.x, self.y)
	end
end