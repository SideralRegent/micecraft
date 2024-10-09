do
	local void = function() end
	local setmetatable = setmetatable
	function Item:new(uniqueId)
		return setmetatable({
			uniqueId = uniqueId or 0,
			type = 0,
			category = 0,
			
			sprite = nil,
			sound = {},
			
			placeable = false,
			consumable = false,
			--[[ consumable = {
				uses = 0,
				maxUses
			} ]]
			
			properties = {},
			
			damage = 2,
			
			onUse = void,
			onPlacement = void,
			onDestroy = void
		}, {__index = self})
	end
	
	function Item:__eq(other)
		return self.uniqueId == other.uniqueId
	end
	
	function Item:meta(field, type)
		self.type = type or self.type
		
		local metadata = itemMeta:get(self.type)
		
		if field then
			return metadata[field]
		else
			return metadata
		end
	end
	
	function Item:setFromType(typeId, clean) -- Set all fields to meta info
		self.type = typeId or self.type
		local meta = itemMeta:get(self.type)
		
		self.category = meta.category
		
		self.sprite = meta.sprite
		self.sound = meta.sound
		
		self.placeable = meta.placeable
		
		if type(meta.consumable) == "boolean" then
			self.consumable = meta.consumable
		else
			self.consumable = {
				uses = 0,
				maxUses = meta.consumable
			}
		end
		
		self.damage = meta.damage
		
		self.onUse = meta.onUse
		self.onPlacement = meta.onPlacement
		self.onDestroy = meta.onDestroy
		
		if clean then
			self:setProperties(nil)
		end
	end
	
	function Item:setFromItem(item) -- Copy, basically
		self.uniqueId = item.uniqueId
		
		self:setFromType(item.type)
		
		self:setProperties(item)
	end
	
	local copy = table.copy
	function Item:setProperties(item)
		self.properties = copy(item or {})
	end
	
	function Item:reset() -- Make all fields 0 and delete all info
		self:setFromType(VOID, true)
	end
	
	local addImage = tfm.exec.addImage
	function Item:setImage(i)
		if self.sprite then
			return addImage(
				self.sprite,
				i.targetLayer,
				i.x, i.y,
				i.playerName,
				i.scaleX, i.scaleY,
				i.angle, -- angle
				i.alpha, -- alpha
				i.originX, i.originY, -- anchor X, Y
				i.fade -- fadeIn
			)
		end
	end
	
	local restrict = math.restrict
	function Item:use(user, ...)
		local consumable = self.consumable
		local aintBroken = true
		if consumable then
			consumable.uses = consumable.uses + 1
			
			aintBroken = consumable.uses < consumable.maxUses
		end
		
		self:onUse(user, ...)
		
		return aintBroken
	end
	
	local abs = math.abs
	function Item:setUses(value, additive, ...)
		local consumable = self.consumable
		if not consumable then return 0 end
		
		value = value or 1
		local target = additive and (consumable.uses + value) or value
		
		consumable.uses = restrict(target, 1, consumable.maxUses)
		
		return abs(target - consumable.uses)
	end
	
	function Item:checkUse(erase, ...)
		local destroyed = not self:use(...)
		if destroyed then
			self:onDestroy(...)
			
			if self.consumable then
				if not erase then
					self.consumable.uses = 0
				end
			end
		end
		
		return destroyed
	end
	
	function Item:place(blockTarget, perpetrator)
		if self.placeable then
			blockTarget:create(self:meta("blockId"), true, true, true)
			--blockTarget:onPlacement(perpetrator)
			
			return true
		end
		
		return false
	end
	
	function Item:destroy(...)
		self:onDestroy(...)
		
		self:reset()
	end
end