require("defines")
require("util")
require("prototypes.army-management")
local class = require("lib.30log")


TICK_UPDATE_FOLLOW = 20

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end


script.on_init(function() 

  global.lastTick = 0
  
  if not global.Squads then
	global.Squads = {}
  end
  
  if not global.Soldiers then
	global.Soldiers = {}
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
	global.Squads = {}
  end
  
  if not global.Soldiers then
	--player.print("Creating soldiers table") -- DEBUG
	global.Soldiers = {}
  end
  --------------------------------------
  
  --player.print("Setting up player's squad and soldier table")
  global.Squads[player.name] = player.surface.create_unit_group({position=player.position})
  global.Soldiers[player.name] = {}
end)


function onBuiltEntityCallback(event)
	local entity = event.created_entity
	local player = game.get_player(event.player_index)
	if entity.name == "droid" then
		if not global.Squads[player.name] then
			if not global.Squads[player.name].valid then
				global.Squads[player.name] = player.surface.create_unit_group({position=player.position}) -- if it is not already there, create the first squad
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


script.on_event(defines.events.on_built_entity, function(event)
  onBuiltEntityCallback(event)
end)



script.on_load( function() 

	print("Loading game..")
	global.lastTick = 0
	
		
end)

function onTickHandler(event)
	
  if event.tick  < 500 then
	global.lastTick = event.tick
	return 
	
  end
 
  -- has enough time elapsed to go through and set squad orders yet?
  if event.tick > (global.lastTick + TICK_UPDATE_FOLLOW) then
	
	local players = game.players
	
	--for each player in the game, ensure all their associated soldiers are in the player's global squad
	--then give the squad the command to go to the player's position. 
	for i, player in pairs(players) do
	
		if global.Soldiers[player.name] then
			local length = #(global.Soldiers[player.name])
			if length > 0 then
				--make a squad if it doesn't exist yet.. this ensures we can dump all the existing soldiers into it. 
				if not global.Squads[player.name] then
					global.Squads[player.name] = {}
				else
					if not global.Squads[player.name].valid then
						--player.print("creating unit group...")
						global.Squads[player.name] = player.surface.create_unit_group({position = player.position}) 
					end
				end
			
				-- for each soldier, check if soldier is valid, and if it is not already in the global squad, add it to squad. 
				for index, soldier in pairs(global.Soldiers[player.name]) do
					if soldier.valid and global.Squads[player.name].valid then
						if not table.contains(global.Squads[player.name].members, soldier) then
							global.Squads[player.name].add_member(soldier)
						end
					else
						--player.print("soldier in your soldier's table or the squads table in general is invalid for some reason") -- debug
					end 
				end
				
				-- check if unit-group is valid, then set command to move to owning player's location
				if global.Squads[player.name].valid then
					local currentState = global.Squads[player.name].state
					
					--player.print(string.format("player's squad current state: %d", currentState))
					
					
					-- get distance
					local dist = util.distance(player.position, global.Squads[player.name].position)
					
					--if close, make them wander. else check state and distance and force to move
					if (dist < 3) then
						
						if (currentState == defines.groupstate.finished) then
							global.Squads[player.name].set_command({type=defines.command.wander, destination= player.position, radius=5, distraction=defines.distraction.by_enemy})
							--player.print("set squad to move chill out because they are nearby...")
						end
					
					elseif currentState == defines.groupstate.gathering or currentState == defines.groupstate.finished or dist > 10 then
						global.Squads[player.name].set_command({type=defines.command.go_to_location, destination= player.position, radius=10, distraction=defines.distraction.by_enemy})
						--player.print("set squad to move to its owning player...")
						global.Squads[player.name].start_moving()
					end
				end
			
			end
			global.lastTick = event.tick
		else
				--player.print("your soldier table doesn't exist (is nil) ") -- debug
				global.Soldiers[player.name] = {}
		end
	end
  end
end

script.on_event(defines.events.on_tick, function( event) 
	onTickHandler(event)
 end)