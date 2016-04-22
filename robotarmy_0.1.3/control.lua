require("defines")
require("util")
require("config.config")
require("lib.util")
require("prototypes.Squad")
require("stdlib/log/logger")
LOGGER = Logger.new('robotarmy')


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
  player.insert{name="iron-plate", count=8}
  player.insert{name="pistol", count=1}
  player.insert{name="basic-bullet-magazine", count=10}
  player.insert{name="burner-mining-drill", count = 1}
  player.insert{name="stone-furnace", count = 1}
  player.insert{name="droid", count = 5} -- debug test, spawn with bodyguards ready!
  
  
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

-- unused 
function onBuiltEntityCallback(event)
	
	local entity = event.created_entity
	local player = game.get_player(event.player_index)
	if entity.name == "droid" then
		if not global.Squads[player.name] then
			if not global.Squads[player.name].unitGroup.valid then
				global.Squads[player.name].unitGroup = player.surface.create_unit_group({position=player.position, force=player.force}) -- if it is not already there, create the first squad
				--player.print("creating squad...")
			end
		end

		--player.print("adding soldier to squad table")
		table.insert(global.Soldiers[player.name], entity)


		local soldierCount = 0
		for _, soldier in pairs(global.Soldiers[player.name]) do
			if soldier.valid then
				soldierCount = soldierCount + 1
			end
		end
	
		local out = string.format("soldier count %d", soldierCount)

		--player.print(out) --print a debug string with squad Size
	end
end

function testOnBuiltEntity(event)

	local entity = event.created_entity
	local player = game.get_player(event.player_index)
	
	if(entity.name == "droid") then 
		
		local position = entity.position
		local distance = util.distance(position, player.position)


		--if this is the first time we are using the player's tables, make it
		if global.Squads[player.name] == nil then 
			global.Squads[player.name] = {}
		end
		
		
		local squadref = getClosestSquad(global.Squads[player.name], player, SQUAD_CHECK_RANGE)
		
		if  not squadref then
			--if we didnt find a squad nearby, create one
			--player.print("no nearby squad found, creating new squad")
			LOGGER.log(string.format("adding new squad to table, %s", tostring(global.Squads[player.name])))
			squadref = createNewSquad(global.Squads[player.name], player)
			--player.print(string.format("index of newly created squad %d", squadref))
		else
			--player.print(string.format("index of joined squad %d", squadref))
		end
		
		
		
		--debug print stuff.. doesn't seem to do anything
		 --for i, v in pairs(global.Squads[player.name]) do player.print(string.format("%s, %s", tostring(i), tostring(v))) end
		 
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
		--player.print("player's squad table readout")
		for i, v in pairs(global.Squads[player.name][squadref]) do 
			
			--player.print(string.format("%s, %s", tostring(i), tostring(v) ))
		end
		
		--player.print(string.format("Squad member count = %d", global.Squads[player.name][squadref].members.size ) ) 
		
	end


end

function checkIfDroidAssembly(event)
	local entity = event.created_entity
	local player = game.get_player(event.player_index)

	if(entity.name == "droid-assembling-machine") then 
		
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
	
		entity.recipe = entity.force.recipes["droid-deploy"]
	end

end

script.on_event(defines.events.on_built_entity, function(event)
  --onBuiltEntityCallback(event)
  testOnBuiltEntity(event)
  checkIfDroidAssembly(event)
end)



script.on_load( function() 

	print("Loading game..")
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
	
  if event.tick  < 100 then
	global.lastSquadUpdateTick = event.tick
	return 
	
  end
 
  -- has enough time elapsed to go through and set squad orders yet?
  if event.tick > (global.lastSquadUpdateTick + TICK_UPDATE_SQUAD_AI) then
	--onTickUpdateSquads()
	
	local players = game.players
	trimSquads(players)
	sendSquadsToBattle(players, SQUAD_SIZE_MIN_BEFORE_HUNT)

	
  end
  
  if (event.tick % 100) == 0 then
	if global.DroidAssemblers then
		local players = game.players
		
		for _, player in pairs(players) do
		
			if global.DroidAssemblers[player.name] then
		--for each building in their list using name as key\
				for index, assembler in pairs(global.DroidAssemblers[player.name]) do
					
					if assembler then
						if assembler.valid then
							
							local inv = assembler.get_output_inventory() --gets us a luainventory
							local countDroidDummies = assembler.get_item_count("droid-dummy")
							
							if (countDroidDummies >= 1) then
							
								--spawn a droid!
								local assPos = assembler.position
								local droidPos = ({x = assPos.x + 5,y = assPos.y }) -- off to the side of the building
								
								randX = math.random() + math.random(1, 4) - 2
								randY = math.random() + math.random(1, 4) - 2
								droidPos.x = droidPos.x + randX
								droidPos.y = droidPos.y + randY
								local assForce = assembler.force -- haha, ass force!
								local returnedEntity = player.surface.create_entity({name = "droid", position = droidPos, direction = defines.direction.east, force = assForce })

								if returnedEntity then
									
									handleDroidProduced(assembler, player, returnedEntity)
								
								else
									player.print(string.format("There is something wrong with your droid assembler at x:%d y:%d", assember.position[1], assembler.position[2]))
								end
								
								inv.clear() --clear output slot
							
							end

						end
					end
				end
			end
		end
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

 
 function handleDroidProduced(assembler, player, returnedEntity)
			
	--if this is the first time we are using the player's tables, make it
	if global.Squads[player.name] == nil then 
		--player.print("player's global squad table was nil, making an entry for them now")
		global.Squads[player.name] = {}
	end
	
	
	local squadref = getClosestSquadToPos(global.Squads[player.name], returnedEntity.position,  player, SQUAD_CHECK_RANGE)
	local newlyCreated = false
	if not squadref then
		--if we didnt find a squad nearby, create one
		--player.print("no squad nearby to the assembler found, creating new squad")
		LOGGER.log(string.format("adding new squad to table, %s", tostring(global.Squads[player.name])))
		squadref = createNewSquad(global.Squads[player.name], player)
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
	
	addMember(global.Squads[player.name][squadref],returnedEntity)		
	checkMembersAreInGroup(global.Squads[player.name][squadref])
	if newlyCreated then
		global.Squads[player.name][squadref].unitGroup.set_command({type=defines.command.wander, destination= returnedEntity.position, radius=30, distraction=defines.distraction.by_enemy})
		global.Squads[player.name][squadref].unitGroup.start_moving()
	else
		if not global.Squads[player.name][squadref].command == commands.hunt then 
			global.Squads[player.name][squadref].unitGroup.set_command({type=defines.command.wander, destination= returnedEntity.position, radius=30, distraction=defines.distraction.by_enemy})
			global.Squads[player.name][squadref].unitGroup.start_moving()
		
		
		end
	
	end
	
	--player.print("player's squad table readout")
	for i, v in pairs(global.Squads[player.name][squadref]) do 
		
		--player.print(string.format("%s, %s", tostring(i), tostring(v) ))
	end
	
	--player.print(string.format("Squad member count = %d", global.Squads[player.name][squadref].members.size ) ) 
		
end


 