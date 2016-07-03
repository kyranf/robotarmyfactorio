
--gets an offset spawning location for an entity (droid assembler) 
-- should use surface.find_non_colliding_position() API call here, to check for a small square around entPos and return the result of that function instead.
-- this will help avoid getting units stuck in stuff.
function getDroidSpawnLocation(entity)
	local entPos = entity.position
	local direction = entity.direction
	
	 -- based on direction of building, set offset for spawn location
	if(direction == defines.direction.east) then 
		entPos = ({x = entPos.x - 5,y = entPos.y }) end
	if(direction == defines.direction.north) then 
		entPos = ({x = entPos.x,y = entPos.y + 5 }) end
	if(direction == defines.direction.south) then 
		entPos = ({x = entPos.x,y = entPos.y - 5 }) end
	if(direction == defines.direction.west) then 
		entPos = ({x = entPos.x + 5,y = entPos.y }) end
	
	if(direction == defines.direction.east) then
		randX = math.random() - math.random(0, 4) 
	else
		randX = math.random() + math.random(0, 4) 
	end
	
	if(direction == defines.direction.north) then
		randY = math.random() + math.random(0, 4) 
	else
		randY = math.random() - math.random(0, 4) 
	end
	
	
	entPos.x = entPos.x + randX
	entPos.y = entPos.y + randY
	--final check, let the game find us a good spot if we've failed by now.
	local finalPos = game.surfaces[1].find_non_colliding_position(entity.name, entPos, 2, 0.5)
	if not finalPos then 
		return entPos --just force it... oh well.
	else
		return finalPos
	end
end
	