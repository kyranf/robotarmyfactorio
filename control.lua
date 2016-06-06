require("defines")
require("util")
require("config.config") -- config for squad control mechanics - important for anyone using 
require("robolib.util") -- some utility functions not necessarily related to robot army mod
require("robolib.robotarmyhelpers") -- random helper functions related to the robot army mod
require("robolib.Squad") -- allows us to control squads, add entities to squads, etc.
require("prototypes.DroidUnitList") -- so we know what is spawnable
require("stdlib/log/logger")
LOGGER = Logger.new("robotarmy", "robot_army_logs", true )


script.on_init(function() 

  global.lastSquadUpdateTick = 0
  
  if not global.Squads then
	global.Squads = {init_state="ready"}
  end
  
  if not global.uniqueSquadId then
	global.uniqueSquadId = {init_state = "ready"}
  end
  
end)


script.on_event(defines.events.on_player_created, function(event)
  local player = game.get_player(event.player_index)
  --player.insert{name="iron-plate", count=8}
  --player.insert{name="pistol", count=1}
  --player.insert{name="basic-bullet-magazine", count=10}
  --player.insert{name="burner-mining-drill", count = 1}
  --player.insert{name="stone-furnace", count = 1}
  --player.insert{name="droid-smg", count = 5} -- debug test, spawn with bodyguards ready!
  
  
  -- put these in the on_load event too?? 
  ---------------------------------------
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

function handleDroidSpawned()

end

function testOnBuiltEntity(event)

	local entity = event.created_entity
	local player = game.get_player(event.player_index)
	
	if table.contains(squadCapable, entity.name) then --squadCapable is defined in DroidUnitList.lua
		LOGGER.log(string.format("Processing new entity %s spawned by player %s", entity.name, player.name) )
		local position = entity.position
		local distance = util.distance(position, player.position)

		
		--lets make it wander first so it doesn't just stand in the way.
		entity.set_command({type=defines.command.wander, destination= entity.position, radius=5, distraction=defines.distraction.by_anything})

		--if this is the first time we are using the player's tables, make it
		if global.Squads[player.name] == nil then 
			global.Squads[player.name] = {}
		end
		
		
		local squadref = getClosestSquad(global.Squads[player.name], player, SQUAD_CHECK_RANGE)
		
		if  not squadref then
			--if we didnt find a squad nearby, create one
			--player.print("no nearby squad found, creating new squad")
			--LOGGER.log(string.format("adding new squad to table, %s", tostring(global.Squads[player.name])))
			squadref = createNewSquad(global.Squads[player.name], player, entity)
			--LOGGER.log(string.format("New squad reference is %d", squadref) )
		else
			--player.print(string.format("index of joined squad %d", squadref))
		end
		 
		
		-- REPLACE THIS NEXT 4 LINES WITH A FUNCTION TO COUNT VALID/NON-EMPTY SQUADS IN FORCE
		local squadCount = 0
		for i, v in pairs(global.Squads[player.name]) do 
			squadCount = squadCount + 1
		end
		--LOGGER.log(string.format("squadcount = %d ", squadCount ) )
		
		
		--player.print(string.format("Squadref before adding soldier to member list: %d",squadref))

		addMember(global.Squads[player.name][squadref],entity)		
		checkMembersAreInGroup(global.Squads[player.name][squadref])
		
		--REPLACE THIS NEXT SET OF CODE WITH A FUNCTION TO COUNT VALID/NON-EMPTY SQUADMEMBERS IN SQUAD
		--LOGGER.log("Squad member read-out:")
		--for i, v in pairs(global.Squads[player.name][squadref]) do 
		--	LOGGER.log(string.format("%s, %s", tostring(i), tostring(v) ))
		--end
		
		--LOGGER.log(string.format("Squad member count = %d", global.Squads[player.name][squadref].members.size ) ) 
		
	end


end

function checkIfDroidAssembly(event)
	local entity = event.created_entity
	local player = game.get_player(event.player_index)

	if(entity.name == "droid-assembling-machine") then 
		
		--player.print("Droid Assembler placed...")
		
		if not global.DroidAssemblers then
			--player.print("Creating global droid assembler list..")
			global.DroidAssemblers = {}
			global.DroidAssemblers[player.name] = {}
			--player.print("adding droid assembler to global list..")
			table.insert(global.DroidAssemblers[player.name], entity)
		else
			--player.print("adding droid assembler to global list..")
			table.insert(global.DroidAssemblers[player.name], entity)
		end
	
		--entity.recipe = entity.force.recipes["droid-deploy"]
	end

end

script.on_event(defines.events.on_built_entity, function(event)
  --onBuiltEntityCallback(event)
  testOnBuiltEntity(event)
  checkIfDroidAssembly(event)
end)



script.on_load( function() 

	--print("Loading game..")
	global.lastSquadUpdateTick = 0
	if not global.Squads then
		global.Squads = {init_state="ready"}
	end
  
	if not global.uniqueSquadId then
		global.uniqueSquadId = {init_state = "ready"}
	end
	global.runonce = false
		
end)

function onTickHandler(event)
	
 
  -- has enough time elapsed to go through and set squad orders yet?
  if event.tick > (global.lastSquadUpdateTick + TICK_UPDATE_SQUAD_AI) then
	--onTickUpdateSquads()
	
	local players = game.players -- list of players 
	trimSquads(players) -- does some quick maintenance of the squad tables. 
	sendSquadsToBattle(players, SQUAD_SIZE_MIN_BEFORE_HUNT) -- finds all squads for all players and checks for squad size and sends to attack nearest targets

	lastSquadUpdateTick = event.tick
  end
  
  if (event.tick % ASSEMBLER_UPDATE_TICKRATE) == 0 then
	if global.DroidAssemblers then
		local players = game.players
		
		for _, player in pairs(players) do
		
			if global.DroidAssemblers[player.name] then
		--for each building in their list using name as key\
				for index, assembler in pairs(global.DroidAssemblers[player.name]) do
					
					if assembler then
						if assembler.valid then
							
							local inv = assembler.get_output_inventory() --gets us a luainventory
							local containsDroidDummies = containsSpawnableDroid(inv) -- assembler.get_item_count("droid-smg-dummy") --replace with "contains any spawnable droid"
							if(containsDroidDummies) then
								LOGGER.log(string.format("ContainsDroidDummies result = %s", containsDroidDummies))
							end
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
									
									--lets make it wander first so it doesn't just stand in the way.
									returnedEntity.set_command({type=defines.command.wander, destination= returnedEntity.position, radius=5, distraction=defines.distraction.by_anything})
									
									local eventStub = {player_index = player.index, created_entity = returnedEntity}
									testOnBuiltEntity(eventStub)
									--handleDroidProduced(assembler, player, returnedEntity)
								
								else
									player.print(string.format("There is something wrong with your droid assembler at x:%d y:%d", assember.position[1], assembler.position[2]))
									LOGGER.log(string.format("There is something wrong with your droid assembler at x:%d y:%d", assember.position[1], assembler.position[2]))
								end
								
								inv.clear() --clear output slot
							
							end

						end
					end
				end
			else
				LOGGER.log("WARNING: player does not have a list of droid assemblers")
			end --end if they have a list of droid assemblers
		end -- end for each player in players list
	else
		LOGGER.log("WARNING: global droidassemblers list does not exist!")
	end
  end
  
  
  
end

--unused needs to have global.Squads[player.name] + [squadref] or iteration count used somewhere for the squadID if we will use this again
function onTickUpdateSquads()
	local players = game.players
	
	--for each player in the game, ensure all their associated soldiers are in the player's global squad
	--then give the squad the command to go to the player's position. 
	for i, player in pairs(players) do
	
		if global.Soldiers[player.name] then
			local length = #(global.Soldiers[player.name])
			if length > 0 then
				
				-- check if unit-group is valid, then set command to move to owning player's location
				if global.Squads[player.name].valid then
					local currentState = global.Squads[player.name].state
					
					--player.print(string.format("player's squad current state: %d", currentState))
					
					
					-- get distance
					local dist = util.distance(player.position, global.Squads[player.name].position)
					
					--if close, make them wander. else check state and distance and force to move
					if (dist < 3) then
						
						if (currentState == defines.groupstate.finished) then
							global.Squads[player.name].unitGroup.set_command({type=defines.command.wander, destination= player.position, radius=15, distraction=defines.distraction.by_enemy})
							global.Squads[player.name].unitGroup.start_moving()
							--player.print("set squad to move chill out because they are nearby...")
						end
					
					elseif currentState == defines.groupstate.gathering or currentState == defines.groupstate.finished or dist > DEFAULT_SQUAD_RADIUS then
						global.Squads[player.name].unitGroup.set_command({type=defines.command.go_to_location, destination= player.position, radius=DEFAULT_SQUAD_RADIUS, distraction=defines.distraction.by_enemy})
						--player.print("set squad to move to its owning player...")
						global.Squads[player.name].start_moving()
					end
				end
			
			end
			global.lastSquadUpdateTick = event.tick
		else
				player.print("your soldier table doesn't exist (is nil) ") -- debug
				--global.Soldiers[player.name] = {}
		end
	end
  end


script.on_event(defines.events.on_tick, function( event) 
	
	--on the very first tick, do any adjustments or changes or forcing of updates. On-load doesn't have access to "game" and migration scripts don't have access to global... so just do it here
	if not global.runonce then


		for i, force in pairs(game.forces) do 
			force.reset_recipes()
		end

		for i, force in pairs(game.forces) do 
			force.reset_technologies()
		end

		global.runonce = true
	end

	onTickHandler(event)
 end)

 
 function handleDroidProduced(assembler, player, entity)
			
	LOGGER.log(string.format("handle droids function inputs %s %s %s", assembler, player, entity))


	--if this is the first time we are using the player's tables, make it
	if global.Squads[player.name] == nil then 
		--player.print("player's global squad table was nil, making an entry for them now")
		global.Squads[player.name] = {}
	end
	
	
	local squadref = getClosestSquadToPos(global.Squads[player.name], entity.position, SQUAD_CHECK_RANGE)
	local newlyCreated = false
	if not squadref then
		--if we didnt find a squad nearby, create one
		--player.print("no squad nearby to the assembler found, creating new squad")
		--LOGGER.log(string.format("adding new squad to table, %s", tostring(global.Squads[player.name])))
		squadref = createNewSquad(global.Squads[player.name], player, entity)
		newlyCreated = true
		--player.print(string.format("index of newly created squad %d", squadref))
	else
		--player.print(string.format("index of joined squad %d", squadref))
	end
	
	--debug print stuff.. doesn't seem to do anything
	 --for i, v in pairs(global.Squads[player.name]) do player.print(string.format("%s, %s", tostring(i), tostring(v))) end
	 --
	 --if (global.Squads[player.name][squadref]) then
	--	if global.Squads[player.name][squadref].members then
			--player.print(string.format("member list of squad ID %d", squadref))
			--for i, v in pairs(global.Squads[player.name][squadref].members) do player.print(string.format("%s, %s", tostring(i), tostring(v))) end
	--	end
	 --end
	 
	
	local squadCount = 0
	for i, v in pairs(global.Squads[player.name]) do 
		squadCount = squadCount + 1
	end
	--player.print(string.format("Player squadcount = %d ", squadCount ) ) 
	
	
	--player.print(string.format("Squadref before adding soldier to member list: %d",squadref))
	
	addMember(global.Squads[player.name][squadref],entity)		
	checkMembersAreInGroup(global.Squads[player.name][squadref])
	
	global.Squads[player.name][squadref].unitGroup.set_command({type=defines.command.wander, destination= entity.position, radius=10, distraction=defines.distraction.by_enemy})
	global.Squads[player.name][squadref].unitGroup.start_moving()
	
	--if newlyCreated then
	--	global.Squads[player.name][squadref].unitGroup.set_command({type=defines.command.wander, destination= entity.position, radius=20, distraction=defines.distraction.by_enemy})
	--	global.Squads[player.name][squadref].unitGroup.start_moving()
	--else
	--	if not global.Squads[player.name][squadref].command == commands.hunt then 
	--		global.Squads[player.name][squadref].unitGroup.set_command({type=defines.command.wander, destination= entity.position, radius=20, distraction=defines.distraction.by_enemy})
	--		global.Squads[player.name][squadref].unitGroup.start_moving()
	--	else
	--		--LOGGGER.log("WARNING: is in hunt mode already, when new units added to it")
	--	end
	
	--end
	
	--player.print("player's squad table readout")
	--for i, v in pairs(global.Squads[player.name][squadref]) do 
		
		--player.print(string.format("%s, %s", tostring(i), tostring(v) ))
	--end
	
	--player.print(string.format("Squad member count = %d", global.Squads[player.name][squadref].members.size ) ) 
		
end


 