local success, info = dofile("build/merger.lua")
--local matrix, info = dofile("build/merger.lua")

local worldImage, worldCanvas
local scale = 1

function love.load()
	if not success then
		love.event.quit()
		
		return
	end
	
	love.graphics.setDefaultFilter("nearest", "nearest", 1)
	love.system.setClipboardText(info.source)

	if success and info.preview and info.result then
		local matrix = info.result.field
		local height = #matrix
		local width = #matrix[1]
		
		scale = math.min(1200 / width, 700 / height)
		
		worldImage = love.image.newImageData(width, height)
		worldCanvas = love.graphics.newCanvas(width, height)
		local r, g, b
		local color
		
		local tc = {}
		
		local conv = function(hex)
			local r = math.floor(hex / 0x10000)
			local g = math.floor((hex%0x10000) / 0x100)
			local b = hex % 0x100
						
			return {r=r, g=g, b=b}
		end
		
		for id, block in next, info.result.blockMeta do
			if type(id) == "number" then
				tc[id] = conv(block.color)
			end
		end
		
		local ta = {}
		
		local col_cand
		
		local xa, ya
		for y=1, height do
			for x=1, width do
				color = tc[ matrix[y][x] ] or {r=255, g=255, b=255}
				r, g, b = (color.r/255), (color.g/255), (color.b/255)
				
				worldImage:setPixel(x-1, y-1, r, g, b, 1)
			end
		end
		
		love.window.setMode(width*scale, height*scale)
		
		do
			local f = io.open("world.png", "wb")
			f:write(worldImage:encode("png"):getString())
			f:close()
		end
		
		worldImage = love.graphics.newImage(worldImage)
	end
	
	worldCanvas:renderTo(function()
		love.graphics.draw(worldImage, 0, 0, 0, 1.0, 1.0)
	end)
	
	if not info.preview then
		love.event.quit()
	end
end

function love.update()
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end
end

function love.draw()
	if worldCanvas then
		love.graphics.draw(worldCanvas, 0, 0, 0, scale, scale)
	end
end