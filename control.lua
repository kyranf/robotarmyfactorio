require("util")
require("config.config") -- config for squad control mechanics - important for anyone using 
require("robolib.util") -- some utility functions not necessarily related to robot army mod
require("robolib.robotarmyhelpers") -- random helper functions related to the robot army mod
require("robolib.Squad") -- allows us to control squads, add entities to squads, etc.
require("prototypes.DroidUnitList") -- so we know what is spawnable
require("stdlib/log/logger")
LOGGER = Logger.new("robotarmy", "robot_army_logs", true )

local runonce = false

script.on_init(function() 

  global.lastSquadUpdateTick = 0
  
  if not global.Squads then
	global.Squads = {init_state="ready"}
  end
  
  if not global.uniqueSquadId then
	global.uniqueSquadId = {init_state = "ready"}
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
	
end)


script.on_configuration_changed(function(data) 
 
	 if data.mod_changes ~= nil and data.mod_changes["robotarmy"] ~= nil and data.mod_changes["robotarmy"].old_version == nil then  -- Mod was added
		 
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
	
end)



script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]

  if not global.Squads then
	--player.print("Creating squads table") -- DEBUG
	global.Squads = {state="ready"}
  end
  
  	if not global.uniqueSquadId then			
		global.uniqueSquadId = {}
	end
	
  
  if not global.uniqueSquadId[player.name] then 
	global.uniqueSquadId[player.name] = 1
  end
  
end)


function handleDroidSpawned(event)

	local entity = event.created_entity

	local player = game.players[event.player_index]
	--player.print(string.format("Processing new entity %s spawned by player %s", entity.name, player.name) )
	local position = entity.position
	
	--if this is the first time we are using the player's tables, make it
	if not global.Squads[player.name] then 
		global.Squads[player.name] = {}
	end

	trimSquads(game.players) -- maintain squad tables before checking for distance to nearest squad
	
	local squadref = getClosestSquadToPos(global.Squads[player.name], entity.position, SQUAD_CHECK_RANGE)
	
	if  not squadref then
		--if we didnt find a squad nearby, create one
		--player.print("no nearby squad found, creating new squad")
		--player.print(string.format("adding new squad to table, %s", tostring(global.Squads[player.name])))
		squadref = createNewSquad(global.Squads[player.name], player, entity)
		--player.print(string.format("New squad reference is %d", squadref) )
	else
		--player.print(string.format("index of joined squad %d", squadref))
	end
	 

	addMember(global.Squads[player.name][squadref],entity)		
	checkMembersAreInGroup(global.Squads[player.name][squadref])
	
	--set entity to do what the group wants
	--event.created_entity.set_command({type=defines.command.group})
	
	--set group to wander 
	--global.Squads[player.name][squadref].unitGroup.set_command({type=defines.command.wander, destination= global.Squads[player.name][squadref].unitGroup.position, radius=DEFAULT_SQUAD_RADIUS, distraction=defines.distraction.by_anything})
	global.Squads[player.name][squadref].unitGroup.start_moving()	

end

function handleDroidAssemblerPlaced(event)
	local entity = event.created_entity

	local player
	if(event.player_index) then
		player = game.players[event.player_index]
	else
		player = entity.force.players[1] --just default to the first player in that force for the owning player .. this is just a workaround until all spawning happens by force only.
	end
	--player.print("Droid Assembler placed... for player: ")
	--player.print(player.name)
	if not global.DroidAssemblers then
		--player.print("Creating global droid assembler list..")
		global.DroidAssemblers = {}
		global.DroidAssemblers[player.name] = {}
		--player.print("adding droid assembler to global list..")
		table.insert(global.DroidAssemblers[player.name], entity)
	elseif not global.DroidAssemblers[player.name] then
		--player.print("adding droid assembler to global list..")
		--LOGGER.log(string.format("Player name building droid assembler is %s", player.name))
		global.DroidAssemblers[player.name] = {}
		table.insert(global.DroidAssemblers[player.name], entity)
	else
		table.insert(global.DroidAssemblers[player.name], entity)
	end


end

script.on_event(defines.events.on_built_entity, function(event)
  --onBuiltEntityCallback(event)
   
   local entity = event.created_entity
  
	if(entity.name == "droid-assembling-machine") then 
		handleDroidAssemblerPlaced(event)
	elseif(entity.name == "droid-counter") then
		handleBuiltDroidCounter(event)
	elseif entity.name == "loot-chest" then
		handleBuiltLootChest(event)
	elseif table.contains(squadCapable, entity.name) then --squadCapable is defined in DroidUnitList.l
		handleDroidSpawned(event) --this deals with droids spawning
	end
	
  
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
	local entity = event.created_entity
	if(entity.name == "droid-assembling-machine") then 
		handleDroidAssemblerPlaced(event)
	elseif(entity.name == "droid-counter") then
		handleBuiltDroidCounter(event)
	elseif entity.name == "loot-chest" then
		handleBuiltLootChest(event)
	end

end)

--logic for handling loot chest spawning, cannot have more than one per force.
function handleBuiltLootChest(event)

	--check if there is a global table entry for loot chests yet, make one if not.
	if not global.lootChests then
		global.lootChests = {}
	end
	
	local chest = event.created_entity
	local force = chest.force
	if not global.lootChests[force.name] or not global.lootChests[force.name].valid  then
		global.lootChests[force.name] = chest   --this is now the force's chest. 
	else
	
		force.players[1].print("Error: Can only place one loot chest!")	
		chest.destroy()
		--global.lootChests[force.name] = nil
	end



end

function handleBuiltDroidCounter(event)
	
	local entity = event.created_entity 
	local entityForce = entity.force.name

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


script.on_load( function() 

	--print("Loading game..")
	global.lastSquadUpdateTick = 0
	if not global.Squads then
		global.Squads = {init_state="ready"}
	end
  
	if not global.uniqueSquadId then
		global.uniqueSquadId = {init_state = "ready"}
	end
	
	if not global.droidCounters then
		global.droidCounters = {}
	end
	
	
	global.runonce = false
		
end)

-- during the on-tick event, lets check if we need to update squad AI, spawn droids from assemblers, or update bot counters, etc
function onTickHandler(event)
	
  -- has enough time elapsed to go through and set squad orders yet?
  if event.tick > (global.lastSquadUpdateTick + TICK_UPDATE_SQUAD_AI) then
	
	local players = game.players -- list of players 
	trimSquads(game.players) -- does some quick maintenance of the squad tables. 
	
	sendSquadsToBattle(players, SQUAD_SIZE_MIN_BEFORE_HUNT) -- finds all squads for all players and checks for squad size and sends to attack nearest targets
	revealSquadChunks()
	grabArtifacts(players)
	lastSquadUpdateTick = event.tick
	
  end
  
  if (event.tick % ASSEMBLER_UPDATE_TICKRATE == 0) then
	if global.DroidAssemblers then
		local players = game.players
		
		for _, player in pairs(players) do
		
			if global.DroidAssemblers[player.name] then
		--for each building in their list using name as key\
				for index, assembler in pairs(global.DroidAssemblers[player.name]) do
					
					if assembler and assembler.valid and assembler.force == player.force then

						local inv = assembler.get_output_inventory() --gets us a luainventory
						local containsDroidDummies = containsSpawnableDroid(inv) -- assembler.get_item_count("droid-smg-dummy") --replace with "contains any spawnable droid"
						--if(containsDroidDummies) then
						--	LOGGER.log(string.format("ContainsDroidDummies result = %s", containsDroidDummies))
						--end
						--containsDroidDummies is either nil (none there) or is the name of the spawnable entity prototype used in create_entity later on.
						if (containsDroidDummies ~= nil and type(containsDroidDummies) == "string") then
							
							--spawn a droid!
							-- debug code
							--player.print(string.format("Found a spawnable droid, named: %s", containsDroidDummies))
							
							local droidPos =  getDroidSpawnLocation(assembler) -- uses assmbler pos, direction, and spawns droid at an offset +- random amount
							
							local assForce = assembler.force -- haha, ass force!
							local returnedEntity = player.surface.create_entity({name = containsDroidDummies , position = droidPos, direction = defines.direction.east, force = assForce })

							if returnedEntity then
								--player.print("running droid produced handler... printing owning player's name...")
								--player.print(player.name)
								
								local eventStub = {player_index = player.index, created_entity = returnedEntity}
								handleDroidSpawned(eventStub)
								
							
							else
								--player.print(string.format("There is something wrong with your droid assembler at x:%d y:%d", assember.position[1], assembler.position[2]))
								--LOGGER.log(string.format("There is something wrong with your droid assembler at x:%d y:%d", assember.position[1], assembler.position[2]))
							end
							
							inv.clear() --clear output slot
						
						end

					end
					
				end
			else
				--LOGGER.log("WARNING: player does not have a list of droid assemblers")
			end --end if they have a list of droid assemblers
		end -- end for each player in players list
	else
		--LOGGER.log("WARNING: global droidassemblers list does not exist!")
		global.DroidAssemblers = {}
	end
  end
  
  
  if( event.tick % BOT_COUNTERS_UPDATE_TICKRATE == 0) then
  
	
	--for each force in game, sum droids, then find/update droid-counters
	for _, gameForce in pairs(game.forces) do
		local sum = 0	
		if global.droidCounters and global.droidCounters[gameForce.name] then
			--sum all droids named in the spawnable list
			for _, droidName in pairs(spawnable) do
			
				sum = sum + gameForce.get_entity_count(droidName)
			
			end
					
			local circuitParams = {parameters={  {index=1, count = sum, signal={type="virtual",name="signal-droid-alive-count"}} } }
		
		
			maintainTable(global.droidCounters[gameForce.name])
			
			for _, counter in pairs(global.droidCounters[gameForce.name]) do
				
				if(counter.valid) then
					counter.get_or_create_control_behavior().parameters = circuitParams
				end
			end
		
		end
		
	end
	
  
  end
 


  if(event.tick % LONE_WOLF_CLEANUP_SCRIPT_PERIOD == 0) then
  
	--begin lone-wolf cleanup process. finds and removes units who are not in a unitGroup
	--this is unfinished, will be in next release
  
  end
 
end


script.on_event(defines.events.on_tick, function( event) 
	
	--on the very first tick, do any adjustments or changes or forcing of updates. On-load doesn't have access to "game" and migration scripts don't have access to global... so just do it here
	if not runonce then
		runonce = false
	end

	onTickHandler(event)
 end)

 
 function handleDroidProduced(assembler, player, entity)
			
	--game.player.print(string.format("handle droids function inputs %s %s %s", assembler, player, entity))


	--if this is the first time we are using the player's tables, make it
	if global.Squads[player.name] == nil then 
		--player.print("player's global squad table was nil, making an entry for them now")
		global.Squads[player.name] = {}
	end
	
	
	local squadref = getClosestSquadToPos(global.Squads[player.name], entity.position, SQUAD_CHECK_RANGE)
	
	if not squadref then
		--if we didnt find a squad nearby, create one
		--player.print("no squad nearby to the assembler found, creating new squad")
		--game.player.print(string.format("adding new squad to table, %s", tostring(global.Squads[player.name])))
		squadref = createNewSquad(global.Squads[player.name], player, entity)
		
		--player.print(string.format("index of newly created squad %d", squadref))
	else
		--player.print(string.format("index of joined squad %d", squadref))
	end
	
	addMember(global.Squads[player.name][squadref],entity)		
	checkMembersAreInGroup(global.Squads[player.name][squadref])	
		
end


 
