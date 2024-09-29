do
local void = function() end
	itemMeta = MetaData:newMetaData({
		name = "Null",
		category = 0,
		
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
			category = "Block",
			placeable = true
		},
		name = "Block"
	}, { -- dictionary
		["sprite"] = "sprite",
		["sound"] = "sound",
		["name"] = "name"
		-- ...
})

itemMeta:set(VOID, {
	name = "Your_bank's_account",
	category = VOID,
	sprite = nil,
	consumable = false,
	placeable = false
})