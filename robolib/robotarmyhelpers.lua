require("util")
require("robolib.util")
require("prototypes.DroidUnitList")
require("stdlib/game")
require("stdlib/log/logger")
--gets an offset spawning location for an entity (droid assembler) 
-- uses surface.find_non_colliding_position() API call here, to check for a small square around entPos and return the result of that function instead.
-- this will help avoid getting units stuck in stuff. If that function returns nil, then we have problems so try to mention that to whoever call by ret -1
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
	local finalPos = entity.surface.find_non_colliding_position(entity.name, entPos, 10, 1)
	if not finalPos then 
		return -1 --we can catch this later
	else
		return finalPos
	end
end

--entity is the guard station 
function getGuardSpawnLocation(entity)
	local entPos = entity.position
	local direction = entity.direction
	
	--final check, let the game find us a good spot if we've failed by now.
	local finalPos = game.surfaces[1].find_non_colliding_position(entity.name, entPos, 20, 1)
	if not finalPos then
		LOGGER.log("ERROR: getGuardSpawnLocation failed to find a suitable spawn location!")
		return -1 --an error we can catch later
	end
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


function getSquadHuntSize(force)

	if global.settings and global.settings[force.name] and global.settings[force.name].huntSizeOverride then
		  return global.settings[force.name].huntSizeOverride	--overriden value from settings combinator for that force	
	else
		return SQUAD_SIZE_MIN_BEFORE_HUNT --default one set in config.lua
	end
end

function getSquadGuardSize(force)

	if global.settings and global.settings[force.name] and global.settings[force.name].guardSizeOverride then
		  return global.settings[force.name].guardSizeOverride	--overriden value from settings combinator for that force	
	else
		return GUARD_STATION_GARRISON_SIZE --default one set in config.lua
	end
end

function getSquadRetreatSize(force)

	if global.settings and global.settings[force.name] and global.settings[force.name].retreatSizeOverride then
		  return global.settings[force.name].retreatSizeOverride	--overriden value from settings combinator for that force	
	else
		return SQUAD_SIZE_MIN_BEFORE_RETREAT --default one set in config.lua
	end
end

function getSquadHuntRange(force)

	if global.settings and global.settings[force.name] and global.settings[force.name].huntRangeOverride then
		  return global.settings[force.name].huntRangeOverride	--overriden value from settings combinator for that force	
	else
		return SQUAD_HUNT_RADIUS --default one set in config.lua
	end
end


function checkSettingsModules()

	if not global.settingsModule then global.settingsModule = {} end --quick check to ensure state
	if not global.settings then global.settings = {} end
	
	--for each force, update settings if they are different
	for _, gameForce in pairs(game.forces) do

		--check the signals of each force's settings modules, and if there are the correct signals, set them as override values
		if global.settingsModule[gameForce.name] and global.settingsModule[gameForce.name].valid then
			
			local settingsModule = global.settingsModule[gameForce.name]

			
			if not global.settings[gameForce.name] then global.settings[gameForce.name] = {} end
			
			
			--get the parameters, go through and check each one, while also checking the values are logically okay.
			local behaviour = settingsModule.get_or_create_control_behavior() -- a LuaConstantCombinatorControlBehavior		
			local parameters = behaviour.parameters.parameters -- ridiculous, we have to do parameters.parameters. WHY WUBE WHY
			
			--Game.print_force(gameForce, string.format("Parameters table of force's settings module is length %d", #parameters))
			
			for index, parameter in pairs(parameters) do
				if parameter.count and parameter.signal.name ~= nil then 
					--Game.print_force(gameForce, string.format("Settings module signal %s with count %d being checked...", parameter.signal.name, parameter.count))
					local sigName = parameter.signal.name
					if sigName == "signal-squad-size" then --huntSizeOverride
						if global.settings[gameForce.name].huntSizeOverride ~= parameter.count and checkValidSignalSetting(gameForce, sigName, parameter.count) then
							global.settings[gameForce.name].huntSizeOverride = parameter.count
							Game.print_force(gameForce, string.format("Setting hunt squad size override value to %d for force %s",parameter.count, gameForce.name))
						end
						
					elseif sigName == "signal-guard-size" then --guardSizeOverride
						if global.settings[gameForce.name].guardSizeOverride ~= parameter.count and checkValidSignalSetting(gameForce, sigName, parameter.count) then
							global.settings[gameForce.name].guardSizeOverride = parameter.count
							Game.print_force(gameForce, string.format("Setting guard squad size override value to %d for force %s",parameter.count, gameForce.name))
						end
					elseif sigName == "signal-retreat-size" then --retreatSizeOverride
						if global.settings[gameForce.name].retreatSizeOverride ~= parameter.count and checkValidSignalSetting(gameForce, sigName, parameter.count) then
							global.settings[gameForce.name].retreatSizeOverride = parameter.count
							Game.print_force(gameForce, string.format("Setting retreat squad size override value to %d for force %s",parameter.count, gameForce.name))
						end
					elseif sigName == "signal-hunt-radius" then --huntRangeOverride
						if global.settings[gameForce.name].huntRangeOverride ~= parameter.count and checkValidSignalSetting(gameForce, sigName, parameter.count) then
							global.settings[gameForce.name].huntRangeOverride = parameter.count
							Game.print_force(gameForce, string.format("Setting hunt radius override value to %d for force %s",parameter.count, gameForce.name))
						end
					end
				end	
			end
		end
	end	
end

function checkValidSignalSetting(force, signal, count)

	if signal == "signal-squad-size" then
	
		if count > 0 then  --all we care about is positive numbers here
			return true
		else
			Game.print_force(force, string.format("WARNING: The droid settings signal %s must be positive and non-zero!", signal))
			return false
		end
	
	elseif signal == "signal-guard-size" then
	
		if count > 0 then  --all we care about is positive numbers here
			return true
		else
			Game.print_force(force, string.format("WARNING: The droid settings signal %s must be positive and non-zero!", signal))
			return false
		end
	
	elseif signal == "signal-retreat-size" then
		
		-- we care about retreat size being smaller than the current huntSizeOverride if there is one, otherwise just less than the default hunt squad size.
		if global.settings[force.name].huntSizeOverride then 
			
			if count > 0 and count < global.settings[force.name].huntSizeOverride then
				return true
			end
		
		elseif count > 0 and count < SQUAD_SIZE_MIN_BEFORE_HUNT then
			return true
		else
			Game.print_force(force, string.format("WARNING: The droid settings signal %s must be positive and less than current squad hunt size setting!", signal))
			return false
		end
	
	elseif signal == "signal-hunt-radius" then
		
		-- Change the 10000 at your own risk. Don't come whining to me if you change this to something silly like 5000000 and then let the slider get that high
		-- because each squad will the seach a massive radius, and even though the game has optimised this call well, I fear the FPS will be so bad you won't be able to change
		-- the slider and you'll have to load from a recent save. 
		if count > 10000 then
			Game.print_force(force, string.format("WARNING: The droid settings signal %s must be less than 10,000 for performance reasons!", signal))
			return false
		elseif count >= 0 then  --all we care about is positive numbers here, and 0 is also okay (nobody will hunt, ever.)
			return true
		else
			Game.print_force(force, string.format("WARNING: The droid settings signal %s must be positive!", signal))
			return false
		end
	
	end

end

function doCounterUpdate()
	--for each force in game, sum droids, then find/update droid-counters
	for _, gameForce in pairs(game.forces) do
		local sum = 0	
		local rifleDroids = gameForce.get_entity_count("droid-rifle")
		local battleDroids = gameForce.get_entity_count("droid-smg")
		local rocketDroids = gameForce.get_entity_count("droid-rocket")
		local fireBots = gameForce.get_entity_count("droid-flame")
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
					{index=5, count = fireBots, signal={type="virtual",name="signal-droid-flame-count"}},
					{index=6, count = terminators, signal={type="virtual",name="signal-droid-terminator-count"}}
				} --end parameters table
			
			}-- end circuitParams
		
		
			maintainTable(global.droidCounters[gameForce.name])
			
			for _, counter in pairs(global.droidCounters[gameForce.name]) do
				
				if(counter.valid) then
					
					local currentParams = counter.get_or_create_control_behavior().parameters 
					local lengthOld = #currentParams.parameters
					local lengthNew = #circuitParams.parameters
					Game.print_force(counter.force, string.format("counter number of signals %d, number of new signals %d",lengthOld, lengthNew))
					
					if lengthOld ~= lengthNew then
					
						local pos = counter.position
						local surface = counter.surface
						counter.destroy()
						counter = surface.create_entity({name = "droid-counter" , position = pos, direction = defines.direction.east, force = gameForce })
						Game.print_force(counter.force, string.format("Counter replaced at X %d,Y %d to update signal output table. Will need new wires if you had any!", pos.x, pos.y))
						
					end
					
					
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

--this function handles the possibility that the squad table might be old and won't have the surface defined. 
--using this wrapper we can catch this issue and deal with it at the same time while keeping other code cleaner.
function getSquadSurface(squad)

	if not squad then 
		return nil  --barf if the input was empty
	end 

	if not squad.surface then 
		local unit = getFirstValidSoldier(squad)
		squad.surface = unit.surface -- save this shit for next time!
		return unit.surface
	else
		return squad.surface
	end
end

--logic for handling loot chest spawning, cannot have more than one per force.
function handleBuiltLootChest(event)

	--check if there is a global table entry for loot chests yet, make one if not.
	if not global.lootChests then
		global.lootChests = {}
	end
	
	local chest = event.created_entity
	local force = chest.force
	LOGGER.log( string.format("Adding loot chest to force %s", force.name) )
	if not global.lootChests[force.name] or not global.lootChests[force.name].valid  then
		global.lootChests[force.name] = chest   --this is now the force's chest. 
	else
		Game.print_force(force,"Error: Can only place one loot chest!")
		chest.surface.spill_item_stack(chest.position, {name="loot-chest", count = 1})
		chest.destroy()
		LOGGER.log("WARNING: Can only place one loot chest!")
	end
end

--logic for handling settings module spawning, cannot have more than one per force.
function handleBuiltDroidSettings(event)

	--check if there is a global table entry for settings modules yet, make one if not.
	if not global.settingsModule then
		global.settingsModule = {}
	end
	
	local entity = event.created_entity
	local force = entity.force

	if not global.settingsModule[force.name] or not global.settingsModule[force.name].valid  then
		LOGGER.log( string.format("Adding settings module to force %s", force.name) )
		global.settingsModule[force.name] = entity   --this is now the force's settings module. 
	else
	
		Game.print_force(force,"Error: Can only place one settings module!")	
		entity.surface.spill_item_stack(entity.position, {name="droid-settings", count = 1})
		entity.destroy()
		LOGGER.log("WARNING: Can only place one settings module!")
	
	end
end

function handleBuiltDroidCounter(event)
	
	local entity = event.created_entity 
	local entityForce = entity.force.name
	LOGGER.log( string.format("Adding droid counter to force %s", entityForce) )
	if not global.droidCounters then			
		global.droidCounters = {}		
		global.droidCounters[entityForce] = {}
		table.insert(global.droidCounters[entityForce], entity )
	elseif not global.droidCounters[entityForce] then 
		global.droidCounters[entityForce] = {}
		table.insert(global.droidCounters[entityForce], entity)
	else
		table.insert(global.droidCounters[entityForce], entity)
	end
end


function handleBuiltRallyBeacon(event)

	local entity = event.created_entity
	if global.Squads and global.Squads[entity.force.name] then
		trimSquads(game.forces)
		
		--game.players[1].print(string.format("Rally point built, for force %s...", entity.force.name))
		--loop through all squads on the force, checking for those who are hunting or 'assembling' and make them move to the rally point and then continue what they were doing.
		for _, squad in pairs(global.Squads[entity.force.name]) do
			--game.players[1].print("checking squad..")
			if squad and squad.unitGroup and squad.unitGroup.valid then
				--game.players[1].print("checking squad command...")
				if squad.command ~= commands.guard and squad.command ~= commands.patrol then
			
					--game.players[1].print(string.format("Sending squad %d to rally point...", squad.squadID))
					local pos = entity.position
					pos.x = pos.x+2
					pos.y = pos.y+2
					--give them command to move. distraction by damage means if they are shot at/bit, they will at least try and defend themselves while running away.
					squad.unitGroup.set_command({type=defines.command.go_to_location, destination=pos, distraction=defines.distraction.none})
					--squad.unitGroup.start_moving()
				
				end
			end	
		end
	end
end



function handleDroidSpawned(event)

	local entity = event.created_entity
	local player = game.players[event.player_index]
	local force = entity.force
	--player.print(string.format("Processing new entity %s spawned by player %s", entity.name, player.name) )
	local position = entity.position
	
	--if this is the first time we are using the player's tables, make it
	if not global.Squads[force.name] then 
		global.Squads[force.name] = {}
	end

	--trimSquads(game.players) -- maintain squad tables before checking for distance to nearest squad
	
	local squadref = getClosestSquadToPos(global.Squads[force.name], entity.position, SQUAD_CHECK_RANGE)
	
	if(getSquadSurface(global.Squads[force.name][squadref]) ~= entity.surface) then
		squadref = nil  --we cannot allow a squad to be joined if it's on the wrong surface
	end
	
	if  not squadref then
		--if we didnt find a squad nearby, create one	
		squadref = createNewSquad(global.Squads[force.name], player, entity)

	end
	 

	addMember(global.Squads[force.name][squadref],entity)		
	--checkMembersAreInGroup(global.Squads[player.force.name][squadref])
	global.Squads[entity.force.name][squadref].unitGroup.add_member(entity)
	
	local squadOfInterest = global.Squads[force.name][squadref]
	
	if event.guard == true then
		if squadOfInterest.command ~= commands.guard then
			squadOfInterest.command = commands.guard
			squadOfInterest.home = event.guardPos
			--game.players[1].print(string.format("Setting guard squad to wander around %s", event.guardPos))
			
			--check if the squad it just joined is patrolling, if it is, don't force any more move commands because it will be disruptive!
			
			if not squadOfInterest.patrolState or (squadOfInterest.patrolState and squadOfInterest.patrolState.currentWaypoint == -1) then
				--Game.print_force(entity.force, "Setting move command to squad home..." )
				squadOfInterest.unitGroup.set_command({type=defines.command.wander, destination = squadOfInterest.home, distraction=defines.distraction.by_enemy})
				squadOfInterest.unitGroup.start_moving()
			end
		end
	end

end

function handleGuardStationPlaced(event)

	local entity = event.created_entity
	local force = entity.force
	LOGGER.log( string.format("Adding guard station to force %s", force.name) )
	
	--check for droid guard station global tables first.
	if not global.droidGuardStations then
		global.droidGuardStations = {}
	end
	if not global.droidGuardStations[force.name] then
		global.droidGuardStations[force.name] = {}
	end
	
	table.insert(global.droidGuardStations[force.name], entity)
	maintainTable(global.droidGuardStations[force.name]) -- helps remove old invalid/nil entries.

end

function handleDroidAssemblerPlaced(event)
	local entity = event.created_entity
	local force = entity.force
	
	--check for droid guard station global tables first.
	if not global.DroidAssemblers then
		global.DroidAssemblers = {}
	end
	if not global.DroidAssemblers[force.name] then
		global.DroidAssemblers[force.name] = {}
	end
	LOGGER.log( string.format("Adding assembler to force %s", force.name) )	
	if global.DroidAssemblers and global.DroidAssemblers[force.name] then
		table.insert(global.DroidAssemblers[force.name], entity)
	else
		
		LOGGER.log("WARNING: no global table for droid assemblers and/or the force is missing one for it")
	end


end
