function Structure:new(name, definition)	
	local td = type(definition)
	local matrix
	
	if td == "string" then
		matrix = Map:decode(definition)
	elseif td == "table" then
		matrix = {}
		for y = 1, #definition do
			matrix[y] = {}
			for x = 1, #definition[1] do
				matrix[y][x] = {
					type = definition[y][x][1]
				}
			end
		end
	elseif td == "function" then
		matrix = definition(self)
	end
	
	Structures[name] = setmetatable({
		name = name,
		matrix = matrix,
		height = #matrix,
		width = #matrix[1]
	}, self)
	
	return Structures[name]
end

Structure:new("SpawnPoint", "0,256|3,0;256|5;256,0|3,256;0|5;256|5")
Structure:new("tree", "0|2,3,0|2;0,3|3,0;3|5;0,3|3,0;0|2,1,0|2;0|2,1,0|2;0|2,1,0|2")
Structure:new("SandPiramidSmall", "0|3,5,0|3;0|2,5|3,0|2;0,5|5,0;5|7")