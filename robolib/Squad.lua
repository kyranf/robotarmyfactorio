require("config.config")
require("util")
require("robolib.util")
require("stdlib/log/logger")
require("stdlib/game")
require("prototypes.DroidUnitList")


commands = { 		assemble = 1,  	-- when they spawn, this is their starting command/state/whatever
					move = 2, 		-- not really useful, don't use this much..
					follow = 3, 	-- when set, the SQUAD_AI function should command the squad/s to follow player
					guard = 4, 		-- when set, the SQUAD_AI function should command squad to stay around 
					patrol = 5, 	-- when set, SQUAD_AI will deal with moving them sequentially from patrol point A to B
					hunt = 6		-- when set, SQUD_AI will send to nearest enemy 
			}
 
global.SquadTemplate = {squadID= 0, player=true, unitGroup = true, members = {size = 0}, home = true, force = true, surface = true, radius=DEFAULT_SQUAD_RADIUS, patrolPoint1 = true, patrolPoint2 = true, currentCommand = "none"} -- this is the empty squad table template


global.patrolState = {lastPole = nil,currentPole = nil,nextPole = nil,movingToNext = false}


function createNewSquad(tableIN, player, entity)

	if not global.uniqueSquadId then			
		global.uniqueSquadId = {}
	end
	
	if not (global.uniqueSquadId[entity.force.name])  then
			global.uniqueSquadId[entity.force.name] = 1
	end
	
	--get next unique ID number and increment it
	local squadRef = global.uniqueSquadId[entity.force.name]
	global.uniqueSquadId[entity.force.name] = global.uniqueSquadId[entity.force.name] + 1
	
	local newsquad = shallowcopy(global.SquadTemplate)

	newsquad.player = player
	newsquad.force = entity.force
	newsquad.home = entity.position
	newsquad.surface = entity.surface
	newsquad.unitGroup = entity.surface.create_unit_group({position=entity.position, force=entity.force}) --use the entity who is causing the new squad to be formed, for position.
	newsquad.squadID = squadRef
	newsquad.patrolPoint1 = newsquad.home
	newsquad.patrolPoint2 = newsquad.home
	newsquad.members = {size = -1}
	newsquad.command = commands.assemble
	
	tableIN[squadRef] = newsquad
	
	return squadRef
end

-- add member using the appropriate squad table reference 
-- probably obtained by them being the nearest squad to the player,
-- or when a fresh squad is spawned
function addMember(tableIN, entity)

	table.insert(tableIN.members, entity)
	
	--catch for initial condition
	if (tableIN.members.size == -1) then
		tableIN.members.size = 0
	end 
	
	tableIN.members.size = tableIN.members.size + 1
	
end



-- checks that all entities in the "members" sub table are present in the unitgroup
function checkMembersAreInGroup(squad)
	
	--tableIN.player.print("checking soldiers are in their squad's unitgroup")
	--does some trimming of nil members if any have died
	maintainTable(squad.members)

	--make sure the unitgroup is even available, if it's not there for some reason, create it.
	if not squad.unitGroup.valid then
		LOGGER.log("unitgroup was invalid, making a new one")
		local pos
		for key, unit in pairs(squad.members) do
			if key ~= "size" and unit and unit.valid then 
				pos = unit.position 
			end
		end
		
		local surface = getSquadSurface(squad)
		squad.unitGroup = surface.create_unit_group({position=pos, force=squad.force})
		
	end
	
	::retryCheckMembership::
	for key, soldier in pairs(squad.members) do
	
		if(key ~= "size") then
			
			if not soldier then
				table.remove(squad.members, key)
			elseif not table.contains(squad.unitGroup.members, soldier) then
				if soldier.valid then
				
					if soldier.surface == squad.unitGroup.surface then
					--tableIN.player.print(string.format("adding soldier to squad ID %d's unitgroup", tableIN.squadID))
						squad.unitGroup.add_member(soldier)
					else
						LOGGER.log("Destroying unit group, and creating a replacement on the correct surface")
						squad.unitGroup.destroy()
						soldier.surface.create_unit_group({position=soldier.position, force=soldier.force})
						--goto retryCheckMembership
					end
				else
					--LOGGER.log(string.format("removing member from squad id %d member list", tableIN.squadID))
					table.remove(squad.members, key)
				end
			end
		end
	end
	
	--now that we've been removing and adding members, lets do a re-count of squad members.
	squad.members.size = table.countValidElements(squad.members) -- refresh the member count in the squad to accurately reflect the number of soldiers in there.
end

--examines the given table, and if it finds a nil element it will remove it
--from the table.
function maintainTable(tableIN)

	for i, element in pairs(tableIN) do
		
		
		if element == nil then 
			table.remove(tableIN, i) 
		end
	end

end

--input is table of squads (global.Squads[force.name]), and player to find closest to
function getClosestSquad(tableIN, player, maxRange)
	
	local leastDist = maxRange
	local leastDistSquadID = nil
	
	for key, squad in pairs(tableIN) do
			--player.print("checking soldiers are in unitgroup...")
			checkMembersAreInGroup(squad)
			local distance = util.distance(player.position, squad.unitGroup.position)
			if distance <= leastDist then
				leastDistSquadID = squad.squadID
				leastDist = distance
			end
		
	end
	
	if (leastDist == maxRange or leastDistSquadID == nil) then 
		--player.print("getClosestSquad - no squad found or squad too far away")
		return nil
	end
	
	--player.print(string.format("closest squad found: %d tiles away from player", leastDist))
	return leastDistSquadID
end

--input is table of squads (global.Squads[force.name]), and position to find closest to
function getClosestSquadToPos(tableIN, position, maxRange)
	
	local leastDist = maxRange
	local leastDistSquadID = nil
	
	for key, squad in pairs(tableIN) do
		if squad and squad.unitGroup.valid then
			local distance = util.distance(position, squad.unitGroup.position)
			if distance <= leastDist then
				leastDistSquadID = squad.squadID
				leastDist = distance
			end
		end
		
	end
	
	if (leastDist >= maxRange or leastDistSquadID == nil) then 
		LOGGER.log("getClosestSquad - no squad found or squad too far away")
		return nil
	end
	
	--game.players[1].print(string.format("closest squad found: %d tiles away from given position, ID %d", leastDist, leastDistSquadID))
	return leastDistSquadID
end

function trimSquads(forces)
	for _, force in pairs(forces) do
		
		if global.Squads and global.Squads[force.name] then 
		
			for key, squad in pairs(global.Squads[force.name]) do	
				if squad then

					--player.print(string.format("squad %s, id %d, member size %d", squad, squad.squadID, squad.members.size))
				
					local removeThisSquad = false	
					maintainTable(squad.members);
					
					local count = table.countValidElements(squad.members)			
										
					if count == 0 then
						if squad.unitGroup.valid then
							squad.unitGroup.destroy()
						end
						if squad.unitGroup then squad.unitGroup = nil end
						removeThisSquad = true
						
					end
					
					if removeThisSquad then
						if PRINT_SQUAD_DEATH_MESSAGES == 1 then
						-- using stdlib, print message to entire force
							Game.print_force(force, string.format("Squad %d is no more...", squad.squadID))

						end
						LOGGER.log(string.format("Squad id %d from force %s has died/lost all its members...", squad.squadID, force.name))
						
						global.Squads[force.name][squad.squadID] = nil  --set the entire squad itself to nil
						maintainTable(global.Squads[force.name])
					end
				end
			end
		end
	end
end


--sends squads for each player to nearest enemy units. will not happen until squadsize is >= SQUAD_SIZE_MIN_BEFORE_HUNT
function sendSquadsToBattle(forces)

	for _, force in pairs(forces) do
	
		if global.Squads[force.name] then
		
			local minSquadSize = getSquadHuntSize(force)
		
			for id, squad in pairs(global.Squads[force.name]) do
				checkMembersAreInGroup(squad)
				if squad.unitGroup then
					
					if(squad.unitGroup.valid and (squad.unitGroup.state == defines.group_state.gathering or squad.unitGroup.state == defines.group_state.finished)) 	and squad.command ~= commands.guard then
						
				
						local count = table.countValidElements(squad.members)
						if count then 
							if  count >= minSquadSize or (squad.command == commands.hunt and count > SQUAD_SIZE_MIN_BEFORE_RETREAT) then
								--get nearest enemy unit to the squad. 
								--find the nearest enemy to the squad that is an enemy of the player's force, and max radius of 5000 tiles (10k tile diameter)
								local surface = getSquadSurface(squad)
								
								if not surface then 
									LOGGER.log(string.format("ERROR: Surface for squad ID %d is missing or can't be determined! sendSquadsToBattle", squad.squadID))
									goto continueSquadLoop --filthy use of goto, but there's no other way to do "continue". Not even guilty, thanks Lua.		
								end 
											
								local huntRadius = getSquadHuntRange(force)
								
								local nearestEnemy = surface.find_nearest_enemy({position = squad.unitGroup.position, max_distance = huntRadius, force = force })
								if nearestEnemy then
								-- check if they are in a charted area
									
									local charted = true   -- = player.force.is_chunk_charted(player.surface, nearestEnemy.position)
									if charted then
										--player.print("Sending squad off to battle...")
										--make sure squad is good, then set command
										checkMembersAreInGroup(squad)
										squad.command = commands.hunt -- sets the squad's high level role to hunt. not really used yet
										squad.unitGroup.set_command({type=defines.command.attack_area, destination= nearestEnemy.position, radius=50, distraction=defines.distraction.by_anything})
										squad.unitGroup.start_moving()
									else
										--player.print("enemy found but in un-charted area...")								
									end
								else
									--player.print("cannot find nearby target!!")
								end
							else
							
							-- THIS IS THE RETREAT BEHAVIOUR
								if squad.unitGroup.valid and (squad.unitGroup.state == defines.group_state.finished) and squad.command == commands.hunt then
									--player.print(string.format("Sending under-strength squad id %d back to base for resupply...", squad.squadID ))
									checkMembersAreInGroup(squad) -- maybe don't need to call this, we did this earlier on.
									--player.print(string.format("squad size %d, squad state %d", squad.members.size, squad.unitGroup.state ))

									
									if squad.members.size > 0 then
										local distance = 999999
										local entity = nil
										--check every possible droid assembler in that force and return the one with shortest distance
								
										if global.DroidAssemblers and global.DroidAssemblers[force.name] then
											for _, droidAss in pairs(global.DroidAssemblers[force.name]) do
											
											--distance between the droid assembler and the squad
												if droidAss.valid then
													local dist = util.distance(droidAss.position, squad.unitGroup.position)
													if dist <= distance then
														entity = droidAss
														distance = dist
													end	
												end												
											end
										end
										
										
										--we should have the closest droid assembler now. but don't send new commands if they are already only 10 squads away from the rally point.
										if entity and distance > 10 then
											--player.print(string.format("Closest assembler found was at location x %d : y %d", entity.position.x, entity.position.y ))
											local location = getDroidSpawnLocation(entity)
											
											if location ~= -1 then
												--player.print(string.format("Sending squad to assembler at location x %d : y %d", location.x, location.y ))
												squad.unitGroup.set_command({type=defines.command.go_to_location, destination= location, radius=DEFAULT_SQUAD_RADIUS, distraction=defines.distraction.by_anything})
												squad.unitGroup.start_moving()
											end
										end
									end
								end
								
							end
						end
					end
				end
				::continueSquadLoop::
			end
		end
	end
end




function guardAIUpdate()

	local forces = game.forces
	for _, force in pairs(forces) do
		--Game.print_force(force, "processing guard AI Update...")
		if global.Squads and global.Squads[force.name] then
			--Game.print_force(force, "squads tables exist...")
			-- for each squad in force, if squad is "guard" command, check positin of squad against their squad home position
			-- and if it's too far away (15 tiles?) set them to move back to home. 
			for _, squad in pairs(global.Squads[force.name]) do
				--Game.print_force(force, "squads tables exist...")
				
				if squad.unitGroup and squad.unitGroup.valid and squad.command == commands.guard --[[and 
					(squad.unitGroup.state == defines.group_state.finished or squad.unitGroup.state == defines.group_state.gathering) ]]-- 
					then 
					
					local surface = getSquadSurface(squad)
								
					if not surface then 
						LOGGER.log(string.format("ERROR: Surface for squad ID %d is missing or can't be determined! guardAIUpdate", squad.squadID))
						goto continueGuardAiLoop --filthy use of goto, but there's no other way to do "continue". Not even guilty, thanks Lua.		
					end 
					
					local areaTopLeft = {x=squad.unitGroup.position.x-32, y=squad.unitGroup.position.y-32}
					local areaBottomRight = {x=squad.unitGroup.position.x+32, y=squad.unitGroup.position.y+32}
					local areaCheck = {areaTopLeft, areaBottomRight}	

					local poleList = surface.find_entities_filtered{area = {areaTopLeft, areaBottomRight}, squad.unitGroup.position, name="patrol-pole"}
					local poleCount = table.countValidElements(poleList)
					if(poleCount > 1) then
						if not squad.patrolState then
							--Game.print_all("Making patrolstate table...")
							squad.patrolState = {}

							squad.patrolState.nextPole = nil
							squad.patrolState.currentPole = nil
							squad.patrolState.lastPole = nil
							squad.patrolState.movingToNext = false
							squad.patrolState.waypointList = {}
							squad.patrolState.currentWaypoint = -1
							squad.patrolState.arrived = false
							squad.patrolState.waypointDirection = 1
						end
						
							
						if not next(squad.patrolState.waypointList) then
							--from the squad's current position, build a waypoint list using patrol poles found in sequence.
													
							--Game.print_all(string.format("polecount %d", poleCount))
							buildWaypointList(squad.patrolState.waypointList, surface, areaCheck, squad, force)
						
						end
						
						local waypointCount = table.countNonNil(squad.patrolState.waypointList)
						--Game.print_all(string.format("Squad's waypoint count: %d", waypointCount))
						if(waypointCount >= 2) then
							if(squad.patrolState.currentWaypoint == -1) then
								--Game.print_all("Setting up initial conditions...")
								squad.patrolState.currentWaypoint = 0
								squad.patrolState.movingToNext = false
								squad.patrolState.arrived = true
							end
							--check if we are going to a waypoint, if we are, check if we are close yet 
							if(squad.patrolState.movingToNext == true) then
								
								--get distance from squad position to the current waypoint
								local dist = util.distance(squad.unitGroup.position, squad.patrolState.waypointList[squad.patrolState.currentWaypoint])
								--Game.print_all("Checking if squad is near waypoint...")
								if dist < 5 then
									squad.patrolState.movingToNext = false
									squad.patrolState.arrived = true
									--Game.print_all("Squad has arrived at waypoint!")
								else
									
									local position = squad.patrolState.waypointList[squad.patrolState.currentWaypoint]
								
									squad.unitGroup.set_command({type=defines.command.go_to_location, destination=position, radius=DEFAULT_SQUAD_RADIUS, 
																distraction=defines.distraction.by_enemy})
								
								end
							
							end
							
							if(squad.patrolState.movingToNext == false and squad.patrolState.arrived == true) then
								--Game.print_all("Setting new waypoint and giving orders!")
								--adjust current waypoint, check for min/max issues, then issue command to move.
								squad.patrolState.currentWaypoint = squad.patrolState.currentWaypoint + squad.patrolState.waypointDirection
								
								if squad.patrolState.currentWaypoint > waypointCount then 
									squad.patrolState.waypointDirection = -1 --reverse the waypoint iteration direction
									squad.patrolState.currentWaypoint = squad.patrolState.currentWaypoint - 2  --set it to the second last waypoint
								end
								
								--from the direction value being negative
								if(squad.patrolState.currentWaypoint == 0) then
								
									squad.patrolState.waypointDirection = 1 --reverse the waypoint iteration direction
									squad.patrolState.currentWaypoint = squad.patrolState.currentWaypoint + 2 --set it to the second waypoint
								
								end
								
								squad.patrolState.movingToNext = true
								squad.patrolState.arrived = false
								
								local position = squad.patrolState.waypointList[squad.patrolState.currentWaypoint]
								
								squad.unitGroup.set_command({type=defines.command.go_to_location, destination=position, radius=DEFAULT_SQUAD_RADIUS, 
																distraction=defines.distraction.by_enemy})
								--squad.unitGroup.start_moving()
							
							end
						end
					end
				end
				::continueGuardAiLoop::
			end
		end
	end
end


 --checks if the inventory passed contains a spawnable droid item type listed in DroidUnitList.lua
function containsSpawnableDroid(inv) 
	--LOGGER.log("checking spawnable droid")
	local itemList = inv.get_contents()

	if itemList then
	
		for item, count in pairs(itemList) do
			--LOGGER.log(string.format("item inv list %s , %s", item, count))
			local itemName = convertToMatchable(item)
			--LOGGER.log(item)
			
			for i, j in pairs(spawnable) do
				
				--LOGGER.log(string.format("spawnable list %s , %s", i, j))
				local spawnable = convertToMatchable(j)
				--LOGGER.log(spawnable)
				if(string.find(itemName, spawnable)) then --example, in "droid-smg-dummy" find "droid-smg", but the names have been adjusted to replace '-' with '0' to allow string.find to work. turns out hyphens are an escape charater, THANKS LUA!!
					 --convert to spawnable entity name
					local realName = convertToEntityNames(spawnable)
					return realName -- should return the name of the item as a string which is then spawnable. eg "droid-smg"
				
				end
			
				-- if the entry 'j' is found in the item name for example droid-smg is found in droid-smg-dummy
			
			end
		end
		
	else
		return nil -- we failed to get the contents
	end
end 


function revealSquadChunks()

	local forces = game.forces
	for _, force in pairs(forces) do
	
		if global.Squads[force.name] then
		
			for id, squad in pairs(global.Squads[force.name]) do
				
				if squad and squad.unitGroup.valid then
					if squad.members.size > 0 then  --if there are troops in a valid group in a valid squad. 
						local position = squad.unitGroup.position
						
						--this area should give approx 3x3 chunks revealed
						local area = {left_top = {position.x-32, position.y-32}, right_bottom = {position.x+32, position.y+32}} 
						
						local surface = getSquadSurface(squad)
								
						if not surface then 
							LOGGER.log(string.format("ERROR: Surface for squad ID %d is missing or can't be determined! revealSquadChunks", squad.squadID))
							goto continueChunkLoop --filthy use of goto, but there's no other way to do "continue". Not even guilty, thanks Lua.		
						end 
						squad.force.chart(surface, area) --reveal the chunk they are in. 
					end
					
				end
				::continueChunkLoop::
			end
		end
	end
	

end

function grabArtifacts(force)

	for _, force in pairs(force) do
		
		--if there are squads in the player's name, and the player's force has a loot chest active, scan area around droids for alien-artifact
		
		
		if global.Squads[force.name] and global.lootChests and global.lootChests[force.name] and global.lootChests[force.name].valid then
			
			for id, squad in pairs(global.Squads[force.name]) do
				
				if squad and squad.unitGroup.valid then
					
					if squad.members.size > 0 then  --if there are troops in a valid group in a valid squad. 
						local position = squad.unitGroup.position
						local areaToCheck = {left_top = {position.x-ARTIFACT_GRAB_RADIUS, position.y-ARTIFACT_GRAB_RADIUS}, right_bottom = {position.x+ARTIFACT_GRAB_RADIUS, position.y+ARTIFACT_GRAB_RADIUS}}
						
						local surface = getSquadSurface(squad)
								
						if not surface then 
							LOGGER.log(string.format("ERROR: Surface for squad ID %d is missing or can't be determined! grabArtifacts", squad.squadID))
							goto continueGrabArtifacts --filthy use of goto, but there's no other way to do "continue". Not even guilty, thanks Lua.		
						end 
						
						local itemList = surface.find_entities_filtered{area=areaToCheck, type="item-entity"}
						local artifactList = {}
						for _, item in pairs(itemList) do
							if item.valid and item.stack.valid then
							
								if string.find(item.stack.name,"artifact") then
									table.insert(artifactList, {name = item.stack.name, count = item.stack.count}) --inserts the LuaSimpleStack table (of name and count) to the artifacts list for later use
									
									item.destroy()
								
								end
							end
						end
						
						
						if artifactList ~= {} then
							--player.print(string.format("Squad ID %d found %d artifacts!", squad.squadID , artifactCount))
							--player.insert({name="alien-artifact", count = artifactCount})
							local chest = global.lootChests[force.name]
							local cannotInsert = false
							for _, itemStack in pairs(artifactList) do
								if(chest.can_insert(itemStack)) then 
									chest.insert(itemStack)
								else
									cannotInsert = true
								end								
							end
							if cannotInsert then
																
								for _, plr in pairs(chest.force.players) do
									plr.print("Your loot chest is too full! Cannot add more until there is room!")
								end
								
							end
							
						end
					end
					
				end
				::continueGrabArtifacts::
			end
		end
	end
end


