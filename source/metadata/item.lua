do
local void = function() end
	itemMeta = MetaData:newMetaData({
		name = "Null",
		category = enum.icat.null,
		class = enum.iclass.null,
		
		sprite = "17e1315385d.png", -- nil
		sound = {
			place = nil,
			destroy = nil,
			use = nil
		},
		
		placeable = false,
		consumable = false,
		
		properties = {},
		
		onUse = void,
		onPlacement = void,
		onDestroy = void,
		
		maxAmount = 9999 -- For ItemContainer
	})
end

itemMeta:import(blockMeta, { -- config
		shift = 0x256d100,
		template = {
			category = enum.icat.block,
			class = enum.iclass.block,
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
	category = enum.icat.null,
	sprite = nil,
	consumable = false,
	placeable = false
})

itemMeta:set(0x7A315A, {
	name = "Test_Sigil",
	category = enum.icat.null,
	sprite = "1925f762ea4.png",
	consumable = false,
	placeable = false
})