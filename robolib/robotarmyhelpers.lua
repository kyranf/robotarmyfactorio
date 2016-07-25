require("util")
require("robolib.util")
require("prototypes.DroidUnitList")

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
	local finalPos = entity.surface.find_non_colliding_position(entity.name, entPos, 5, 1)
	if not finalPos then 
		return entPos --just force it... oh well.
	else
		return finalPos
	end
end

--entity is the guard station 
function getGuardSpawnLocation(entity)
	local entPos = entity.position
	local direction = entity.direction
	
	--final check, let the game find us a good spot if we've failed by now.
	local finalPos = game.surfaces[1].find_non_colliding_position(entity.name, entPos, 10, 1)
	return finalPos
end
	

--function to count nearby droids. counts in a 32 tile radius, which is 1 chunk.
--inputs are position, force, and radius
function countNearbyDroids(position, force, radius)

	local sum = 0
	local surface = game.surfaces[1] --hardcoded for surface 1. this means underground/space whatever surfaces are not handled.
	for _, droid in pairs(spawnable) do
		sum = sum + surface.count_entities_filtered{area={{position.x - 16 , position.y - 16 }, {position.x + 16, position.y + 16}}, name = droid, force = force}
	end

	return sum
end



function doCounterUpdate(event)
	--for each force in game, sum droids, then find/update droid-counters
	for _, gameForce in pairs(game.forces) do
		local sum = 0	
		local rifleDroids = gameForce.get_entity_count("droid-rifle")
		local battleDroids = gameForce.get_entity_count("droid-smg")
		local rocketDroids = gameForce.get_entity_count("droid-rocket")
		local terminators = gameForce.get_entity_count("terminator")
		if global.droidCounters and global.droidCounters[gameForce.name] then
			--sum all droids named in the spawnable list
			for _, droidName in pairs(spawnable) do
			
				sum = sum + gameForce.get_entity_count(droidName)
			
			end
			
			
			
					
			local circuitParams = {
				parameters={  
					{index=1, count = sum, signal={type="virtual",name="signal-droid-alive-count"}}, --end global droid count
					{index=2, count = rifleDroids, signal={type="virtual",name="signal-droid-rifle-count"}},
					{index=3, count = battleDroids, signal={type="virtual",name="signal-droid-smg-count"}},
					{index=4, count = rocketDroids, signal={type="virtual",name="signal-droid-rocket-count"}},
					{index=5, count = terminators, signal={type="virtual",name="signal-droid-terminator-count"}}
				} --end parameters table
			
			}-- end circuitParams
		
		
			maintainTable(global.droidCounters[gameForce.name])
			
			for _, counter in pairs(global.droidCounters[gameForce.name]) do
				
				if(counter.valid) then
					counter.get_or_create_control_behavior().parameters = circuitParams
				end
			end
		
		end
		
	end
end