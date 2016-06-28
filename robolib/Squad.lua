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

if not global.uniqueSquadId then			

	global.uniqueSquadId = {}

end

function createNewSquad(tableIN, player, entity)

	if not global.uniqueSquadId then			
		global.uniqueSquadId = {}
	end
	
	if not (global.uniqueSquadId[player.name]) then
			global.uniqueSquadId[player.name] = 1
	end
	--get next unique ID number.
	local squadRef = global.uniqueSquadId[player.name]
	global.uniqueSquadId[player.name] = global.uniqueSquadId[player.name] + 1
	
	local newsquad = shallowcopy(global.SquadTemplate)

	newsquad.player = player
	newsquad.force = player.force
	newsquad.home = entity.position
	newsquad.unitGroup = player.surface.create_unit_group({position=entity.position, force=player.force}) --use the entity who is causing the new squad to be formed, for position.
	newsquad.squadID = squadRef
	newsquad.patrolPoint1 = newsquad.home
	newsquad.patrolPoint2 = newsquad.home
	newsquad.members = {size = -1}
	newsquad.command = commands.assemble
	
	tableIN[squadRef] = newsquad
	--for i, v in pairs(tableIN) do 
		--player.print("player's squad list")
		--player.print(string.format("%s, %s", tostring(i), tostring(v) ))
	--end
	--player.print(string.format("Created new squad for %s with unique ID %d", player.name, squadRef))
	--LOGGER.log(string.format("Created squad for player %s", player.name))
	tableIN[squadRef].unitGroup.set_command({type=defines.command.wander, destination= tableIN[squadRef].home, radius=tableIN[squadRef].radius, distraction=defines.distraction.by_anything})
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
	--local soldierCount = table.countValidElements(tableIN.members)
	--tableIN.player.print(string.format("Valid squad member count %d", soldierCount))
	--tableIN.player.print(string.format("added guy to squad belonging to %s, membercount is %d", tableIN.player.name, tableIN.members.size))
	--LOGGER.log(string.format("added guy to squad belonging to %s, membercount is %d", tableIN.player.name, tableIN.members.size))
end



-- checks that all entities in the "members" sub table are present in the unitgroup
function checkMembersAreInGroup(tableIN)
	
	--tableIN.player.print("checking soldiers are in their squad's unitgroup")
	--does some trimming of nil members if any have died
	--maintainTable(tableIN.members)
	if not tableIN then
		return
	end
	if not tableIN.unitGroup then
		return
	end
--make sure the unitgroup is even available
	if not tableIN.unitGroup.valid then
		tableIN.unitGroup = tableIN.player.surface.create_unit_group({position=tableIN.home, force=tableIN.force})
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
					table.remove(tableIN.members, key)
				end
			end
		end
	end
	local memberCount = 0
	for key, soldier in pairs(tableIN.members) do 
		if(key ~= "size") then
			if soldier then
				if soldier.valid then
					memberCount = memberCount + 1
				end
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

--input is table of squads (global.Squads[player.name]), and player to find closest to
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

--input is table of squads (global.Squads[player.name]), and position to find closest to
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
		
		if not global.Squads then return end
		if not global.Squads[player.name] then return end
		
		
		for key, squad in pairs(global.Squads[player.name]) do	
			if squad then	
				local removeThisSquad = false			
				if table.countValidElements(squad.members) == 0 then
					squad.unitGroup = nil
					
					removeThisSquad = true
					
				end	
				
				if removeThisSquad then
					player.print(string.format("Squad %d is no more...", squad.squadID))
					--table.remove(global.Squads[player.name], key)
					global.Squads[player.name][squad.squadID] = nil
					maintainTable(global.Squads[player.name])
				end
			end
		end
	end
end

--sends squads for each player to nearest enemy units. will not happen until squadsize is >= SQUAD_SIZE_MIN_BEFORE_HUNT
function sendSquadsToBattle(players, minSquadSize)

	for _, player in pairs(players) do
	
		if global.Squads[player.name] then
		
			for id, squad in pairs(global.Squads[player.name]) do
				
				if squad then
					checkMembersAreInGroup(squad)				
					
					if squad.unitGroup then
						local state = squad.unitGroup.state
						--LOGGER.log("Checking group state and other info")
						--LOGGER.log(state)
						
						if(squad.unitGroup.valid and (state == defines.group_state.gathering or state == defines.group_state.finished)) then
							
							--LOGGER.log("group is gathering or finished the last task")
					
							local count = table.countValidElements(squad.members)
							if count then 
								if  count >= minSquadSize then
									--get nearest enemy unit to the squad. 
									--find the nearest enemy to the squad that is an enemy of the player's force, and max radius of 5000 tiles (10k tile diameter)
									local nearestEnemy = player.surface.find_nearest_enemy({position = squad.unitGroup.position, max_distance = 5000.0, force = player.force })
									if nearestEnemy then
									-- check if they are in a charted area
										local charted = player.force.is_chunk_charted(player.surface, nearestEnemy.position)
										charted = true -- force this to true for now - we'll introduce this feature later. Requires player to have explored the spot before it can be targetted for attacks.
										if charted then
											--player.print("Sending squad off to battle...")
											--make sure squad is good, then set command
											--checkMembersAreInGroup(squad)
											squad.command = commands.hunt -- sets the squad's high level role to hunt. not really used yet
											squad.unitGroup.set_command({type=defines.command.attack_area, destination= nearestEnemy.position, radius=50, distraction=defines.distraction.by_anything})
											squad.unitGroup.start_moving()
										else
											--player.print("enemy found but in un-charted area...")								
										end
									else
										LOGGER.log("nearest enemy is nil, out of range?")
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
	
		if global.Squads[player.name] then
		
			for id, squad in pairs(global.Squads[player.name]) do
				
				if squad then
					if squad.unitGroup.valid then
						local count = table.countValidElements(squad.members)
						if count > 0 then  --if there are troops in a valid group in a valid squad. 
							local position = squad.unitGroup.position
							local area = {left_top = {position.x-2, position.y-2}, right_bottom = {position.x+2, position.y+2}}
							
							squad.force.chart(game.surfaces[1], area) --reveal the chunk they are in. 
						end
					end
				end
				
			end
		end
	end
	

end
