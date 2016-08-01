require("util")
require("robolib.util")
require("prototypes.DroidUnitList")
require("stdlib/game")

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

function sendSquadHome(squad)

	local distFromHome = util.distance(squad.unitGroup.position, squad.home)
	if distFromHome > 15 then
		Game.print_force(force, "Moving squad back to guard station, they strayed too far!")
		squad.unitGroup.set_command({type=defines.command.go_to_location, destination=squad.home, 
									radius=DEFAULT_SQUAD_RADIUS, distraction=defines.distraction.by_anything})
		squad.unitGroup.start_moving()

	end
end

-- inputs are the squad table, and the list of patrol-pole entities found by find_entities_filtered
-- returns true if it removed a pole from the pole list, or false if nothing was removed
function removeCurrentPole(squad, poleList)
	
	if table.countValidElements(poleList) == 0 then return false end
	
	--if the squad has a table entry for lastPole, then remove it from the pole list
	if squad.currentPole and squad.currentPole.valid then
	
		for _, pole in pairs(poleList) do
		
			if squad.currentPole == pole then
				
				Game.print_force(pole.force, "Removed current pole from polelist")
				pole = nil
				return true
			end
		end
	
	end
	return false
end

-- inputs are the squad table, and the list of patrol-pole entities found by find_entities_filtered
-- returns true if it removed a pole from the pole list, or false if nothing was removed
function removeLastPole(squad, poleList)
	
	if table.countValidElements(poleList) == 0 then return false end
	
	--if the squad has a table entry for lastPole, then remove it from the pole list
	if squad.lastPole and squad.lastPole.valid then
	
		for _, pole in pairs(poleList) do
		
			if squad.lastPole == pole then
				
				Game.print_force(pole.force, "Removed last pole from polelist")
				pole = nil
				return true
			end
		end
	
	end
	return false
end


function getClosestPole(poleList, position)

	local dist = 0
	local distance = 999999
	local closestPole = nil
	for _, pole in pairs(poleList) do
	
	--distance between the droid assembler and the squad
		if pole and pole.valid then
			dist = util.distance(pole.position, position)
			if dist <= distance then
				closestPole = pole
				distance = dist
			end	
		end												
	end
	
	Game.print_all(string.format("closest pole fount at %d:%d", closestPole.position.x, closestPole.position.y) )
	return closestPole
	
end

--waypointList is a list of LuaPositions, 
function getClosestWayPoint(waypointList, position)

	local dist = 0
	local distance = 999999
	local closestIndex = nil
	for index, waypoint in pairs(waypointList) do
	
	--distance between the droid assembler and the squad

		dist = util.distance(waypoint, position)
		if dist <= distance then
			closestIndex = index
			distance = dist
		end	
														
	end
	
	Game.print_all(string.format("closest waypoint fount at index %d", closestIndex) )
	return closestIndex

end

function buildWaypointList(waypointList, surface, poleArea, squad, force)
	local squadPosition = squad.unitGroup.position
	local poleList = surface.find_entities_filtered({area = poleArea, squadPosition, name="patrol-pole"})
	local poleCount = table.countValidElements(poleList)
	
	
	--Game.print_all(string.format("Waypoint building pole count %d", poleCount))
		
	local masterPoleList = {}
	for _, pole in pairs(poleList) do
		
		local connected = pole.circuit_connected_entities.green 
		for _,	entity in pairs(connected) do
			if entity.name == "patrol-pole" and (table.contains(masterPoleList, entity) == false) then
				table.insert(masterPoleList, entity)
			end
		end
			
	end
	
	local masterPoleCount = table.countValidElements(masterPoleList)
	
	--Game.print_all(string.format("first iteration of master pole list count %d", masterPoleCount))

	local recursiveSearch = true
	while recursiveSearch do
		local sizeBefore = table.countValidElements(masterPoleList)
		local sizeAfter = recursiveAdd(masterPoleList)
		--Game.print_all(string.format("Recursive search - list size before %d, size after %d", sizeBefore, sizeAfter ))
		if sizeBefore == sizeAfter then 
			recursiveSearch = false
			--Game.print_all("ending recursive search!")
		end
	end
	
	
	for index, pole in pairs(masterPoleList) do
	
		local waypoint = pole.position
		waypoint.x = waypoint.x+3
		waypoint.y = waypoint.y+3
		--Game.print_all(string.format("Adding waypoint to list, (%d,%d)", waypoint.x, waypoint.y))
		table.insert(waypointList, waypoint )
	
	end
	
end

function recursiveAdd(poleList)

	for _, pole in pairs(poleList) do
		
		local connected = pole.circuit_connected_entities.green 
		for _,	entity in pairs(connected) do
			
			if entity.name == "patrol-pole" and (table.contains(poleList, entity) == false) then
				table.insert(poleList, entity)
			end
		end
			
	end
	
	local newPoleCount = table.countValidElements(poleList)
	
	return newPoleCount
end


function getFirstValidSoldier(squad)

	for _, soldier in pairs(squad.members) do
	
		if soldier and soldier.valid then
			return soldier
		end
	
	end

end