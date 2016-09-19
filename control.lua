require("util")
require("config.config") -- config for squad control mechanics - important for anyone using 
require("robolib.util") -- some utility functions not necessarily related to robot army mod
require("robolib.robotarmyhelpers") -- random helper functions related to the robot army mod
require("robolib.Squad") -- allows us to control squads, add entities to squads, etc.
require("prototypes.DroidUnitList") -- so we know what is spawnable
require("stdlib/log/logger")
require("stdlib/game")
LOGGER = Logger.new("robotarmy", "robot_army_logs", true, {log_ticks = true})

global.runOnce = false

script.on_init(function() 

	LOGGER.log("Robot Army mod Init script running...")
	if not global.Squads then
		global.Squads = {}
	end

	if not global.uniqueSquadId then
		global.uniqueSquadId = {}
	end

	if not global.DroidAssemblers then 
		global.DroidAssemblers = {}
	end

	if not global.droidCounters then
		global.droidCounters = {}
	end

	if not global.lootChests then
		global.lootChests = {}
	end
	
	if not global.rallyBeacons then
		global.rallyBeacons = {}
	end
	
	if not global.droidGuardStations then
		global.droidGuardStations = {}
	end		
	
	if not global.updateTable then
		global.updateTable = {}
	end	
	
	--deal with player force as default set-up process

	handleForceCreated(game.forces["player"])
	handleForceCreated(game.forces["enemy"])
	handleForceCreated(game.forces["neutral"])
	LOGGER.log("Robot Army mod Init script finished...")
end)

script.on_event(defines.events.on_force_created, function(event)
	handleForceCreated(event.force)
 end)
 
function handleForceCreated(force)


    LOGGER.log(string.format("New force detected... %s",force.name) )
    global.DroidAssemblers = global.DroidAssemblers or {}
    global.DroidAssemblers[force.name] = global.DroidAssemblers[force.name] or {}

    global.Squads = global.Squads or {}
    global.Squads[force.name] = global.Squads[force.name] or {}

    global.uniqueSquadId = global.uniqueSquadId or {}
    global.uniqueSquadId[force.name] = global.uniqueSquadId[force.name] or 1

    global.lootChests = global.lootChests or {}
    global.lootChests[force.name] = global.lootChests[force.name] or {}

    global.droidCounters = global.droidCounters or {}
    global.droidCounters[force.name] = global.droidCounters[force.name] or {}

    global.droidGuardStations = global.droidGuardStations or {}
    global.droidGuardStations[force.name] = global.droidGuardStations[force.name] or {} 

	global.rallyBeacons = global.rallyBeacons or {}
	global.rallyBeacons[force.name] = global.rallyBeacons[force.name] or {}
	
	global.updateTable = global.updateTable or {}
	global.updateTable[force.name] = global.updateTable[force.name] or {}
	
	--not needed as of factorio 0.13.10 which removes friendly fire issue.
	force.set_cease_fire(force, true) --set ceasefire on your own force. maybe this will prevent friendlyfire stuff?
    LOGGER.log("New force handler finished...")

end


script.on_event(defines.events.on_built_entity, function(event)
    
   local entity = event.created_entity
  
	if(entity.name == "droid-assembling-machine") then 
		handleDroidAssemblerPlaced(event)
	elseif(entity.name == "droid-guard-station") then
		handleGuardStationPlaced(event)
	elseif(entity.name == "droid-counter") then
		handleBuiltDroidCounter(event)
	elseif(entity.name == "droid-settings") then
		handleBuiltDroidSettings(event)
	elseif entity.name == "loot-chest" then
		handleBuiltLootChest(event)
	elseif entity.name == "rally-beacon" then
		handleBuiltRallyBeacon(event)	
	elseif entity.type == "unit" and table.contains(squadCapable, entity.name) then --squadCapable is defined in DroidUnitList.
		handleDroidSpawned(event) --this deals with droids spawning
	end
	
  
end)


script.on_event(defines.events.on_robot_built_entity, function(event)
	local entity = event.created_entity
	if(entity.name == "droid-assembling-machine") then 
		handleDroidAssemblerPlaced(event)
	elseif(entity.name == "droid-guard-station") then
		handleGuardStationPlaced(event)
	elseif(entity.name == "droid-counter") then
		handleBuiltDroidCounter(event)
	elseif(entity.name == "droid-settings") then
		handleBuiltDroidSettings(event)
	elseif entity.name == "rally-beacon" then
		handleBuiltRallyBeacon(event)
	elseif entity.name == "loot-chest" then
		handleBuiltLootChest(event)
	end

end)



-- during the on-tick event, lets check if we need to update squad AI, spawn droids from assemblers, or update bot counters, etc
function onTickHandler(event)

	if not global.runOnce then
		LOGGER.log("Running the runOnce function to reset recipes and tech to ensure all are correct...")
		--force reset every force's recipes and techs. I'm sick of it not doing this for me!
		for _, force in pairs(game.forces) do
			force.reset_recipes()
			force.reset_technologies()
		end
		global.runOnce = true
	
	end



	if not global.lastTick then
		global.lastTick = 0
	end
	
	
	
  -- has enough time elapsed to go through and set squad orders yet?
  if event.tick > (global.lastTick + TICK_UPDATE_SQUAD_AI) then
	
	local forces = game.forces
	local players = game.players -- list of players 
	trimSquads(forces) -- does some quick maintenance of the squad tables. 

	global.lastTick = event.tick
	
  end
  
  
  runTableTickUpdates(event.tick) -- new function that uses the new tick table update method
  
  
  
  
  if (event.tick % ASSEMBLER_UPDATE_TICKRATE == 0) then

	local players = game.players
	
	for _, player in pairs(players) do
	
		if global.DroidAssemblers and global.DroidAssemblers[player.force.name] then
	--for each building in their list using name as key\
			for index, assembler in pairs(global.DroidAssemblers[player.force.name]) do
				
				if assembler and assembler.valid and assembler.force == player.force then

					local inv = assembler.get_output_inventory() --gets us a LuaInventory
					
					-- checks list of spawnable droid names, returns nil if none found. otherwise we get a spawnable entity name
					local spawnableDroidName = containsSpawnableDroid(inv) 

					if (spawnableDroidName ~= nil and type(spawnableDroidName) == "string") then
					
						-- uses assmbler pos, direction, and spawns droid at an offset +- random amount. Does a final "find_non_colliding_position" before returning
						local droidPos =  getDroidSpawnLocation(assembler) 
						if droidPos ~= -1 then

							local returnedEntity = assembler.surface.create_entity({name = spawnableDroidName , position = droidPos, direction = defines.direction.east, force = assembler.force })

							if returnedEntity then
														
								local eventStub = {player_index = player.index, created_entity = returnedEntity}
								handleDroidSpawned(eventStub)
							
							end
							
							inv.clear() --clear output slot
						end
					end

				end
				
			end

		end --end if they have a list of droid assemblers
		
		--handle guard station spawning here
		
		if global.droidGuardStations and global.droidGuardStations[player.force.name] then
		
			for _, station in pairs(global.droidGuardStations[player.force.name]) do
			
				if station and station.valid and station.force == player.force then
					
					local inv = station.get_output_inventory() --gets us a luainventory
					local spawnableDroidName = containsSpawnableDroid(inv) 

					local nearby = countNearbyDroids(station.position, station.force, 30) --inputs are position, force, and radius
										
					--if we have a spawnable droid ready, and there is not too many droids nearby, lets spawn one!
					if (spawnableDroidName ~= nil and type(spawnableDroidName) == "string") and nearby < getSquadGuardSize(station.force) then
							
							local droidPos =  getGuardSpawnLocation(station) -- uses station pos			
			
							if droidPos ~= -1 then 
							local returnedEntity = station.surface.create_entity({name = spawnableDroidName , position = droidPos, direction = defines.direction.east, force = station.force })

							if returnedEntity then
														
								local eventStub = {player_index = player.index, created_entity = returnedEntity, guard = true, guardPos = station.position}
								handleDroidSpawned(eventStub)
							
							end
							
							inv.clear() --clear output slot
						end
					end
					
					
				end
			
			end
		
		end

	end -- end for each player in players list

  end
  
  
  
  if( event.tick % BOT_COUNTERS_UPDATE_TICKRATE == 0) then
  
	doCounterUpdate()
	checkSettingsModules()
  
  end
 
  --once every 3 seconds on the 5th tick, run the rally pole command for each force that has them active.
  if(event.tick % 180 == 5) then
	
	doBeaconUpdate()
  
  end
 

  if(event.tick % LONE_WOLF_CLEANUP_SCRIPT_PERIOD == 0) then
  
	--begin lone-wolf cleanup process. finds and removes units who are not in a unitGroup
	--this is unfinished, will be in next release
  
  end
 
end


script.on_event(defines.events.on_tick, function( event) 
	onTickHandler(event)
 end)

 

function runTableTickUpdates(tick)
	
	if not global.updateTable then global.updateTable = {} end

	if not global.Squads then global.Squads = {} end	

	
	for i, force in pairs(game.forces) do
		if not global.updateTable[force.name] then global.updateTable[force.name] = {} end
		
		if(force.name == "enemy" or force.name == "neutral") then 
			goto ENDFORCELOOP
		end
		
		--check if the table has the 1st tick in it. if not, then go through and fill the table
		if not global.updateTable[force.name][1] then 
			Game.print_all("filling update tick table")
			fillTableWithTickEntries(global.updateTable[force.name]) -- make sure it has got the 0-59 tick entries initialized
		end
		
		if not global.updateTable[force.name] or not global.Squads[force.name]  then 
			Game.print_all("Update Table or squad table for force is missing! Can't run update functions - force name:")
			Game.print_all(force.name)
			if not global.updateTable[force.name] then 
				Game.print_all("missing update table...")
			end
			
			if not global.Squads[force.name] then
				Game.print_all("missing squad table...")
			end
			return 
		end
		 
		--for the current tick, look at the global table for that tick (mod 60) and any squad references in there.
		local minSquadSize = getSquadHuntSize(force)
		
		local tickToProcess = (tick % 60) + 1
		--LOGGER.log(string.format("Processing AI for tick %d which is AI tick %d of 60", tick, tickToProcess))
		for i, squadref in pairs(global.updateTable[force.name][tickToProcess]) do
			
			if squadref and global.Squads[force.name][squadref] then
				local squad = global.Squads[force.name][squadref]		
				checkMembersAreInGroup(squad)
				if squad.unitGroup and squad.unitGroup.valid then  --important for basically every AI command/routine
					--LOGGER.log(string.format( "AI for squadref %d in tick table index %d is being executed now...", squadref, tickToProcess) )
				--CHECK IF SQUAD IS A GUARD SQUAD, AND CHOOSE WHICH AI FUNCTION TO CALL
					if squad.command == commands.guard then 
						checkGuardAI(squad) --remove checks in this function for command and validity
					else
						checkBattleAI(squad, minSquadSize) --remove checks in this function for validity and possibly command
					end
					
					revealChunksBySquad(squad)
					grabArtifactsBySquad(squad)
				end
			end
		end
		::ENDFORCELOOP::
	end --end for each force in game...
	
end