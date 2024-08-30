function World:init()
	local ci = color.interpolate
	local sky = {
		midnight = {r=67, g=49, b=97}, -- 0000 - 4000 (2000)
		early_morning = {r=71, g=58, b=114}, -- 0400 > 0575 (0475)
		sunrise = {r=211, g=141, b=161}, -- 0575 > 0650
		morning = {r=53, g=192, b=252}, -- 0650 > 1050
		mid_day = {r=122, g=219, b=236}, -- 1050 > 1350
		afternoon = {r=108, g=196, b=236}, -- 1350 > 1750
		sunset = {r=254, g=151, b=122}, -- 1750 > 1900
		night = {r=113, g=95, b=175} -- 1900 > 2000 - 2300
	}
	
	self.skyColors = table.append(
		ci(sky.midnight, sky.early_morning, 0575, true),
		ci(sky.early_morning, sky.sunrise, 0650 - 0575, true),
		ci(sky.sunrise, sky.morning, 0750 - 0650, true),
		ci(sky.morning, sky.mid_day, 1200 - 0750, true),
		ci(sky.mid_day, sky.afternoon, 1700 - 1200, true),
		ci(sky.afternoon, sky.sunset, 1825 - 1700, true),
		ci(sky.sunset, sky.night, 1900 - 1825, true),
		ci(sky.night, sky.midnight, 2400 - 1900, true)
	)	
end