Biome = {
	list = {},
	lookup = {},
}

function Biome:new(name, temperature, humidity, weirdness)
	temperature = temperature or 1.0
	humidity = humidity or 0.75
	weirdness = weirdness or 1.0
	
	self.list[enum.biome[name]] = {
		temperature = math.precision(temperature * 100, 0),
		humidity = math.precision(humidity * 100, 0),
		weirdness = 0
	}
end