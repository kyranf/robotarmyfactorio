require("config.config")
require("util")
require("robolib.util")
require("stdlib/log/logger")
require("prototypes.DroidUnitList")


commands = { 		assemble = 1,  	-- when they spawn, this is their starting command/state/whatever
					move = 2, 		-- not really useful, don't use this much..
					follow = 3, 	-- when set, the SQUAD_AI function should command the squad/s to follow player
					guard = 4, 		-- when set, the SQUAD_AI function should command squad to stay around 
					patrol = 5, 	-- when set, SQUAD_AI will deal with moving them sequentially from patrol point A to B
					hunt = 6		-- when set, SQUD_AI will send to nearest enemy 
			}
 
global.SquadTemplate = {squadID= 0, player=true, unitGroup = true, members = {size = 0}, home = true, force = true, radius=DEFAULT_SQUAD_RADIUS, patrolPoint1 = true, patrolPoint2 = true, currentCommand = "none"} -- this is the empty squad table template


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
function checkMembersAreInGroup(tableIN)
	
	--tableIN.player.print("checking soldiers are in their squad's unitgroup")
	--does some trimming of nil members if any have died
	maintainTable(tableIN.members)

	--make sure the unitgroup is even available, if it's not there for some reason, create it.
	if not tableIN.unitGroup.valid then
		LOGGER.log("unitgroup was invalid, making a new one")
		local pos
		for key, unit in pairs(tableIN.members) do
			if key ~= "size" and unit and unit.valid then pos = unit.position end
		end
		tableIN.unitGroup = tableIN.player.surface.create_unit_group({position=pos, force=tableIN.force})
		 
	end
	
	for key, soldier in pairs(tableIN.members) do
	
		if(key ~= "size") then
			
			if not soldier then
				table.remove(tableIN.members, key)
			elseif not table.contains(tableIN.unitGroup.members, soldier) then
				if soldier.valid then
					--tableIN.player.print(string.format("adding soldier to squad ID %d's unitgroup", tableIN.squadID))
					tableIN.unitGroup.add_member(soldier)
				else
					--LOGGER.log(string.format("removing member from squad id %d member list", tableIN.squadID))
					table.remove(tableIN.members, key)
				end
			end
		end
	end
	local memberCount = 0
	for key, soldier in pairs(tableIN.members) do 
		if(key ~= "size") then
			if soldier and soldier.valid then
					memberCount = memberCount + 1
			end
			
		end
	end
	
	tableIN.members.size = memberCount -- refresh the member count in the squad to accurately reflect the number of soldiers in there.
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

--input is table of squads (global.Squads[player.force.name]), and player to find closest to
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

--input is table of squads (global.Squads[player.force.name]), and position to find closest to
function getClosestSquadToPos(tableIN, position, maxRange)
	
	local leastDist = maxRange
	local leastDistSquadID = nil
	
	for key, squad in pairs(tableIN) do
			--player.print("checking soldiers are in unitgroup...")
			checkMembersAreInGroup(squad)
			local distance = util.distance(position, squad.unitGroup.position)
			if distance <= leastDist then
				leastDistSquadID = squad.squadID
				leastDist = distance
			end
		
	end
	
	if (leastDist >= maxRange or leastDistSquadID == nil) then 
		--game.players[1].print("getClosestSquad - no squad found or squad too far away")
		return nil
	end
	
	--game.players[1].print(string.format("closest squad found: %d tiles away from given position, ID %d", leastDist, leastDistSquadID))
	return leastDistSquadID
end

function trimSquads(players)
	for _, player in pairs(players) do
		
		if global.Squads and global.Squads[player.force.name] then 
		
			for key, squad in pairs(global.Squads[player.force.name]) do	
				if squad then

					--player.print(string.format("squad %s, id %d, member size %d", squad, squad.squadID, squad.members.size))
				
					local removeThisSquad = false	
					maintainTable(squad.members);
					
					local count = table.countValidElements(squad.members)			
										
					if count == 0 then
						if(squad.unitGroup.valid) then
							squad.unitGroup.destroy()
						end
						squad.unitGroup = nil
						removeThisSquad = true
						
					end
					
					if removeThisSquad then
						if PRINT_SQUAD_DEATH_MESSAGES == 1 then
							player.print(string.format("Squad %d is no more...", squad.squadID))
							
						end
						LOGGER.log(string.format("Squad id %d from force %s has died/lost all its members...", squad.squadID, player.force.name))
						
						global.Squads[player.force.name][squad.squadID] = nil
						maintainTable(global.Squads[player.force.name])
					end
				end
			end
		end
	end
end


--sends squads for each player to nearest enemy units. will not happen until squadsize is >= SQUAD_SIZE_MIN_BEFORE_HUNT
function sendSquadsToBattle(players, minSquadSize)

	for _, player in pairs(players) do
	
		if global.Squads[player.force.name] then
		
			for id, squad in pairs(global.Squads[player.force.name]) do
				checkMembersAreInGroup(squad)
				if squad.unitGroup then
					--debug stuff
					if(squad.unitGroup.valid) then
						--player.print(string.format("squad %d id %d groupstate is %d", id, squad.squadID, squad.unitGroup.state))
					else
					
						--player.print(string.format("Squad %d is no more...", squad.squadID))
						--table.remove(global.Squads[player.force.name], key)
						global.Squads[player.force.name][squad.squadID] = nil
						maintainTable(global.Squads[player.force.name])
					end
				--end debug stuff
					if(squad.unitGroup.valid and (squad.unitGroup.state == defines.group_state.gathering or squad.unitGroup.state == defines.group_state.finished)) and squad.command ~= commands.guard then
						
						--LOGGER.log("group is gathering or finished the last task")
				
						local count = table.countValidElements(squad.members)
						if count then 
							if  count >= minSquadSize or (squad.command == commands.hunt and count > SQUAD_SIZE_MIN_BEFORE_RETREAT) then
								--get nearest enemy unit to the squad. 
								--find the nearest enemy to the squad that is an enemy of the player's force, and max radius of 2000 tiles (10k tile diameter)
								local nearestEnemy = player.surface.find_nearest_enemy({position = squad.unitGroup.position, max_distance = 5000.0, force = player.force })
								if nearestEnemy then
								-- check if they are in a charted area
									local charted = player.force.is_chunk_charted(player.surface, nearestEnemy.position)
									charted = true -- force this to true for now - we'll introduce this feature later. Requires player to have explored the spot before it can be targetted for attacks.
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
							
								if squad.unitGroup.valid and (squad.unitGroup.state == defines.group_state.finished) and squad.command == commands.hunt then
									--player.print(string.format("Sending under-strength squad id %d back to base for resupply...", squad.squadID ))
									checkMembersAreInGroup(squad)
									--player.print(string.format("squad size %d, squad state %d", squad.members.size, squad.unitGroup.state ))

									
									if squad.members.size > 0 then
										local distance = 999999
										local entity = nil
										-- for each player in the force, check every possible droid assembler entity and return the one with shortest distance
										for _, playerj in pairs(player.force.players) do
										
											if global.DroidAssemblers and global.DroidAssemblers[playerj.force.name] then
												for _, droidAss in pairs(global.DroidAssemblers[playerj.force.name]) do
												
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
										end
										
										--we should have the closest droid assembler now. but don't send new commands if they are already only 10 squads away from the rally point.
										if entity and distance > 10 then
											--player.print(string.format("Closest assembler found was at location x %d : y %d", entity.position.x, entity.position.y ))
											local location = getDroidSpawnLocation(entity)
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
	
	return nil
	end
	
	
	
end 


function revealSquadChunks()

	local players = game.players
	for _, player in pairs(players) do
	
		if global.Squads[player.force.name] then
		
			for id, squad in pairs(global.Squads[player.force.name]) do
				
				if squad and squad.unitGroup.valid then
					if squad.members.size > 0 then  --if there are troops in a valid group in a valid squad. 
						local position = squad.unitGroup.position
						local area = {left_top = {position.x-20, position.y-20}, right_bottom = {position.x+20, position.y+20}}
						
						squad.force.chart(game.surfaces[1], area) --reveal the chunk they are in. 
					end
					
				end
				
			end
		end
	end
	

end

function grabArtifacts(players)

	for _, player in pairs(players) do
		
		--if there are squads in the player's name, and the player's force has a loot chest active, scan area around droids for alien-artifact
		
		
		if global.Squads[player.force.name] and global.lootChests and global.lootChests[player.force.name] and global.lootChests[player.force.name].valid then
			
			for id, squad in pairs(global.Squads[player.force.name]) do
				
				if squad and squad.unitGroup.valid then
					
					if squad.members.size > 0 then  --if there are troops in a valid group in a valid squad. 
						local position = squad.unitGroup.position
						local areaToCheck = {left_top = {position.x-ARTIFACT_GRAB_RADIUS, position.y-ARTIFACT_GRAB_RADIUS}, right_bottom = {position.x+ARTIFACT_GRAB_RADIUS, position.y+ARTIFACT_GRAB_RADIUS}}
						
						local itemList = game.surfaces[1].find_entities_filtered{area=areaToCheck, type="item-entity"}
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
							local chest = global.lootChests[player.force.name]
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
				
			end
		end
	end
end


