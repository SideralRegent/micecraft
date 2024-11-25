local color = {}

do
	local abs = math.abs
	local round = math.round
	color.hsl2rgb = function(h, s, l)
		local r, g, b
		local rs, gs, bs = 0, 0, 0
		
		local chroma = (1 - abs((2 * l) - 1)) * s
		local hd = h / 60
		local x = chroma * (1 - abs((hd % 2) - 1))
		
		if hd >= 0 and hd <= 1 then
			rs = chroma
			gs = x
		elseif hd > 1 and hd <= 2 then
			rs = x
			gs = chroma
		elseif hd > 2 and hd <= 3 then
			gs = chroma
			bs = x
		elseif hd > 3 and hd <= 4 then
			gs = x
			bs = chroma
		elseif hd > 4 and hd <= 5 then
			rs = x
			bs = chroma
		elseif hd > 5 and hd <= 6 then
			rs = chroma
			bs = x
		end
		
		local m = l - (chroma / 2)
		
		r = round((rs + m) * 255)
		g = round((gs + m) * 255)
		b = round((bs + m) * 255)
		
		return r, g, b
	end
	
	local math_max = math.max
	local math_min = math.min
	color.rgb2hsl = function(r, g, b)
		r = r / 255
		g = g / 255
		b = b / 255
		
		local max = math_max(r, g, b)
		local min = math_min(r, g, b)
		
		local delta = max - min
		local h, s, l = 0, 0, 0
		
		if delta == 0 then
			h = 0
		else
			if max == r then
				h = ((g - b) / delta) + (g < b and 6 or 0)
			elseif max == g then
				h = ((b - r) / delta) + 2
			elseif max == b then
				h = ((r - g) / delta) + 4
			end
		end
		
		h = round(h * 60)
		
		if h < 0 then
			h = h + 360
		end
		
		l = (max + min) / 2
		s = delta == 0 and 0 or delta / (1 - abs((2 * l) - 1))
		
		l = round(l * 100)
		s = round(s * 100)
	end
	
	color.rgbInterpolate = function(c1, c2, t)
		local r = round(c1.r + (c2.r - c1.r) * t)
		local g = round(c1.g + (c2.g - c1.g) * t)
		local b = round(c1.b + (c2.b - c1.b) * t)
		
		return r, g, b
	end
	
	color.rgbToHex = function(r, g, b)
		return (r * 0x10000) + (g * 0x100) + b
	end
	local floor = math.floor
	color.hexToRgb = function(hex)
		local r = floor(hex / 0x10000)
		local g = floor((hex%0x10000) / 0x100)
		local b = hex % 0x100
		
		return {r=r, g=g, b=b}
	end
	
	color.interpolate = function(c1, c2, width, toHex)
		local intp = color.rgbInterpolate
		local rgbToHex = color.rgbToHex
		local t = {}
		local c, r, g, b
		for i = 1, width do
			r, g, b = intp(c1, c2, i / width)
			
			if toHex then
				c = rgbToHex(r, g, b)
			else
				c = {r = r, g = g, b = b}
			end
			
			t[i] = c
		end
		
		return t
	end
end