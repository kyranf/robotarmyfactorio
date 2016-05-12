require("defines")

--gets an offset spawning location for an entity (droid assembler) 
function getDroidSpawnLocation(entity)
	local entPos = entity.position
	local direction = entity.direction
	
	 -- based on direction of building, set offset for spawn location
	if(direction == defines.direction.east) then entPos = ({x = entPos.x + 5,y = entPos.y }) end
	if(direction == defines.direction.north) then entPos = ({x = entPos.x,y = entPos.y + 5 }) end
	if(direction == defines.direction.south) then entPos = ({x = entPos.x,y = entPos.y - 5 }) end
	if(direction == defines.direction.west) then entPos = ({x = entPos.x - 5,y = entPos.y }) end
	
	randX = math.random() + math.random(0, 2) 
	randY = math.random() + math.random(0, 2) 
	
	entPos.x = entPos.x + randX
	entPos.y = entPos.y + randY
	
	return entPos
end
	