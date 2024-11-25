do
	local void = function() end
	itemMeta = MetaData:newMetaData({
		name = "Null",
		category = mc.icat.null,
		class = mc.iclass.null,
		
		sprite = "17e1315385d.png", -- nil
		sound = {
			place = nil,
			destroy = nil,
			use = nil
		},
		
		placeable = false,
		consumable = false,
		durability = math.huge,
		
		properties = {},
		
		onUse = void,
		onPlacement = void,
		onDestroy = void,
		
		maxAmount = 9999, -- For ItemContainer
		
		damage = function(self, element, class)
			return 2
		end
	})
end

itemMeta:import(blockMeta, { -- config
		shift = 0x256d100,
		template = {
			category = mc.icat.block,
			class = mc.iclass.block,
			placeable = true,
			getBlock = function(self)
				return blockMeta:get(self.fixedId - 0x256d100)
			end
		},
		name = "Block"
	}, { -- dictionary
		["sprite"] = "sprite",
		["sound"] = "sound",
		["name"] = "name",
		["fixedId"] = "blockId"
		-- ...
})

itemMeta:set(VOID, {
	name = "Your_bank's_account",
	category = mc.icat.null,
	sprite = nil,
	consumable = false,
	placeable = false
})

itemMeta:set(0x7A315A, {
	name = "Test_Sigil",
	category = mc.icat.null,
	sprite = "1925f762ea4.png",
	consumable = 8,
	onUse = function(self, user, targetBlock, x, y)
		user:move(x, y, false, 0, 0, true)
	end,
	maxAmount = 3,
	placeable = false,
})