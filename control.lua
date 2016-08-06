require("util")
require("config.config") -- config for squad control mechanics - important for anyone using 
require("robolib.util") -- some utility functions not necessarily related to robot army mod
require("robolib.robotarmyhelpers") -- random helper functions related to the robot army mod
require("robolib.Squad") -- allows us to control squads, add entities to squads, etc.
require("prototypes.DroidUnitList") -- so we know what is spawnable
require("stdlib/log/logger")
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
	
	if not global.droidGuardStations then
		global.droidGuardStations = {}
	end		
	LOGGER.log("Robot Army mod Init script finished...")
end)

script.on_event(defines.events.on_force_created, function(event)
	handleForceCreated(event)
 end)
function handleForceCreated(event)

    local force = event.force
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


	--not needed as of factorio 0.13.10 which removes friendly fire issue.
	force.set_cease_fire(force, true) --set ceasefire on your own force. maybe this will prevent friendlyfire stuff?
    LOGGER.log("New force handler finished...")

end


script.on_configuration_changed(function(data) 
 
	 if data.mod_changes ~= nil and data.mod_changes["robotarmy"] ~= nil and data.mod_changes["robotarmy"].old_version == nil then  -- Mod was added
		LOGGER.log("Robot Army mod added - setting up research and recipe unlocks...")
		for _,force in pairs(game.forces) do

			--Tech Additions for droids and droid counter combinator
			if force.technologies["military"].researched then
				force.recipes["droid-rifle"].enabled=true
				force.recipes["droid-rifle-deploy"].enabled=true
				force.recipes["loot-chest"].enabled=true
			end

			if force.technologies["electronics"].researched then
				force.recipes["droid-counter"].enabled=true
			end

			if force.technologies["military-2"].researched then
				force.recipes["droid-smg"].enabled=true
				force.recipes["droid-smg-deploy"].enabled=true
				force.recipes["droid-rocket"].enabled=true
				force.recipes["droid-rocket-deploy"].enabled=true
			end
		  
			if force.technologies["military-3"].researched then
				force.recipes["terminator"].enabled=true
				force.recipes["terminator-deploy"].enabled=true
			end
		end     
	 end
	if data.mod_changes ~= nil and data.mod_changes["robotarmy"] ~= nil and data.mod_changes["robotarmy"].old_version ~= nil then  -- Mod was changed
		LOGGER.log("Robot Army mod changed version - checking research and recipe unlocks...")
		for _,force in pairs(game.forces) do
			Game.print_force(force, "Robot Army mod changed version - checking research and recipe unlocks...")
			force.reset_recipes()
			force.reset_technologies()
				
			--force all of the known recipes to be enabled if the appropriate research is already done. 
			if force.technologies["military"].researched then
				force.recipes["droid-rifle"].enabled=true
				force.recipes["droid-rifle-deploy"].enabled=true
				force.recipes["loot-chest"].enabled=true
				force.recipes["patrol-pole"].enabled=true
				force.recipes["rally-beacon"].enabled=true
				force.recipes["droid-guard-station"].enabled=true
				force.recipes["droid-assembling-machine"].enabled=true
			end

			if force.technologies["electronics"].researched then
				force.recipes["droid-counter"].enabled=true
				force.recipes["droid-settings"].enabled = true
			end

			if force.technologies["military-2"].researched then
				force.recipes["droid-smg"].enabled=true
				force.recipes["droid-smg-deploy"].enabled=true
				force.recipes["droid-rocket"].enabled=true
				force.recipes["droid-rocket-deploy"].enabled=true
				force.recipes["droid-flame"].enabled=true
				force.recipes["droid-flame-deploy"].enabled=true
			end
		  
			if force.technologies["military-3"].researched then
				force.recipes["terminator"].enabled=true
				force.recipes["terminator-deploy"].enabled=true
			end
			
			--adding a guard staion table entry for each force in the game.

			global.droidGuardStations[force.name] = global.droidGuardStations[force.name] or {}	
			global.Squads[force.name] = global.Squads[force.name] or {}
			global.DroidAssemblers[force.name] = global.DroidAssemblers[force.name] or {}
			global.droidCounters[force.name] = global.droidCounters[force.name] or {}
			global.lootChests[force.name] = global.lootChests[force.name] or {}
			global.uniqueSquadId[force.name] = global.uniqueSquadId[force.name] or 1
		end 
		
	end
	
end)

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
	
	sendSquadsToBattle(forces) -- finds all squads for all players and checks for squad size and sends to attack nearest targets
	guardAIUpdate()
	revealSquadChunks()
	grabArtifacts(forces)
	global.lastTick = event.tick
	
  end
  
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
 

  if(event.tick % LONE_WOLF_CLEANUP_SCRIPT_PERIOD == 0) then
  
	--begin lone-wolf cleanup process. finds and removes units who are not in a unitGroup
	--this is unfinished, will be in next release
  
  end
 
end


script.on_event(defines.events.on_tick, function( event) 
	onTickHandler(event)
 end)
