require("config.config")
require("util")
require("robolib.util")
require("stdlib/log/logger")
require("stdlib/game")


function updateSquad(squad)
    if trimSquad(squad) then
		checkMembersAreInGroup(squad) -- if we have a squad with dudes in it, but they aren't in a unit_group, fix that.
		if squad.unitGroup and squad.unitGroup.valid then  --important for basically every AI command/routine
			--LOGGER.log(string.format( "AI for squadref %d in tick table index %d is being executed now...", squadref, tickProcessIndex) )
			--CHECK IF SQUAD IS A GUARD SQUAD, AND CHOOSE WHICH AI FUNCTION TO CALL
			if squad.command == commands.guard then
				executeGuardAI(squad) --remove checks in this function for command and validity
			elseif not squad.rally then
				executeBattleAI(squad)
			end

			revealChunksBySquad(squad)
			grabArtifactsBySquad(squad)
		end
	end
end


function orderSquadToAssembler(squad, assembler)
	-- need to keep retreating towards assembler
	--player.print(string.format("Closest assembler found was at location x %d : y %d", assembler.position.x, assembler.position.y ))
	local location = getDroidSpawnLocation(assembler)
	if location ~= -1 then
		-- RETREAT!
		-- player.print(string.format("Sending squad to assembler at location x %d : y %d", location.x, location.y ))
		squad.unitGroup.set_command({type=defines.command.go_to_location,
									 destination=location,
									 radius=DEFAULT_SQUAD_RADIUS,
									 distraction=defines.distraction.by_enemy})
		squad.unitGroup.start_moving()
	else
		-- player.print("Couldn't get location for droid spawn location!!")
	end
end


function attemptToMergeRetreatingSquadWithNearestAssemblingSquad(squad, range)
	local closest_squad = getClosestSquadToPos(global.Squads[squad.force.name],
											   squad.unitGroup.position,
											   range,
											   squad, -- ignore self
											   commands.assemble)
	if closest_squad then
		local oldsquadID = closest_squad.squadID
		if mergeSquads(squad, closest_squad) then
			Game.print_force(squad.force, string.format(
								 "Merged squad %d into squad %d",
								 oldsquadID, squad.squadID))
			if squad.members.size >= getSquadHuntSize(squad.force) then
				squad.command = commands.hunt
			else
				squad.command = squad.assemble
			end
		end
	end
end


function orderSquadToRetreat(squad)
    if squad.command == commands.hunt then
        -- player.print(string.format("Sending under-strength squad id %d back to base for resupply...", squad.squadID ))
		assembler, distance = global_findClosestForceAssemblerToPosition(
			squad.unitGroup.position, squad.force.name)
		if assembler then
			ASSEMBLER_RANGE = 10  -- this should eventually be configurable
			if distance > ASSEMBLER_RANGE then
				orderSquadToAssembler(squad, assembler)
			else
				-- squad has arrived at assembler/retreat location
				squad.command = commands.assemble
				attemptToMergeRetreatingSquadWithNearestAssemblingSquad(
					squad, ASSEMBLER_RANGE * 2)
			end
		end
    end
end


function orderSquadToHunt(squad)
    --get nearest enemy unit to the squad.
    --find the nearest enemy to the squad that is an enemy of the player's force, and max radius of 5000 tiles (10k tile diameter)
    local surface = getSquadSurface(squad)

    if not surface then
        LOGGER.log(string.format("ERROR: Surface for squad ID %d is missing or can't be determined! sendSquadsToBattle", squad.squadID))
        return
    end

    local huntRadius = getSquadHuntRange(squad.force)

    local nearestEnemy = surface.find_nearest_enemy({position = squad.unitGroup.position, max_distance = huntRadius, force = squad.force })
    if nearestEnemy then
        -- check if they are in a charted area

        local charted = true   -- = player.force.is_chunk_charted(player.surface, nearestEnemy.position)
        if charted then
            --player.print("Sending squad off to battle...")
            --make sure squad is good, then set command
            squad.command = commands.hunt -- sets the squad's high level role to hunt. not really used yet
            squad.unitGroup.set_command({type=defines.command.attack_area, destination= nearestEnemy.position, radius=50, distraction=defines.distraction.by_anything})
            squad.unitGroup.start_moving()
        else
            Game.print_force(squad.force, "enemy found but in un-charted area...") -- this is debug spam - if we see this, deal with it properly in code and remove this
        end
    else
        --Game.print_force(squad.force, "cannot find nearby target!!") -- this is debug spam - if we see this, deal with it properly in code and remove this
        -- update - I encountered this on a fresh start map and placing down units before any biters (or chunks they live in) had been generated yet.
        -- we need an "idle" behaviour I think, such as returning to the squad "home" which is set when they are first made at an assembler, or the player's position.
    end
end


function executeBattleAI(squad)
	if squad.unitGroup.state == defines.group_state.gathering
		or squad.unitGroup.state == defines.group_state.finished
	then
		local count = table.countValidElements(squad.members)
		if count then
			-- either hunt or retreat
			if (count >= getSquadHuntSize(squad.force)
				    -- large enough to start hunting
					or
					-- already hunting and not small enough to retreat
					(squad.command == commands.hunt and
						 count > getSquadRetreatSize(squad.force)))
			then
				orderSquadToHunt(squad)
			else
				orderSquadToRetreat(squad)
			end
		else
			Game.print_force(squad.force, string.format(
								 "No valid members in squad %d!", squad.squadID))
			trimSquad(squad)
		end
	end -- other states include moving, attacking, or attacking distraction.
	    -- in these cases, leave the droids alone until they 'need' to be ordered again.
end


function executeGuardAI(squad)
    if squad.command == commands.guard then
        local surface = getSquadSurface(squad)

        if not surface then
            LOGGER.log(string.format("ERROR: Surface for squad ID %d is missing or can't be determined! guardAIUpdate", squad.squadID))
            return
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
end


function doRallyBeaconUpdate()
    if global.Squads then
        trimSquads(game.forces)
        for _,force in pairs(game.forces) do
            if global.Squads[force.name] then
                --if this force has any rally beacons in its table
                if(global.rallyBeacons and global.rallyBeacons[force.name] and table.countValidElements(global.rallyBeacons[force.name]) >= 1) then
                    for _, squad in pairs(global.Squads[force.name]) do
                        if squad and squad.unitGroup and squad.unitGroup.valid then
                            if squad.command ~= commands.guard and squad.command ~= commands.patrol then

                                --find nearest rally pole to squad position and send them there.
                                local squadPos = squad.unitGroup.position
                                local closestRallyBeacon = getClosestEntity(squadPos, global.rallyBeacons[force.name]) --find closest rallyBeacon to move towards
                                local beaconPos = closestRallyBeacon.position
                                local surface = squad.unitGroup.surface
                                beaconPos.x = beaconPos.x+2
                                beaconPos.y = beaconPos.y+2
                                local dist = util.distance(beaconPos, squad.unitGroup.position)
                                if(dist >= 20) then
                                    --give them command to move.
                                    squad.rally = true
                                    squad.unitGroup.destroy()
                                    checkMembersAreInGroup(squad) --this recreates the unitgroup and re-adds the members
                                    squad.unitGroup.set_command({type=defines.command.go_to_location, destination=beaconPos, distraction=defines.distraction.none})
                                    squad.unitGroup.start_moving()
                                    --else if(dist > 20 ) then
                                    --  squad.rally = nil
                                end

                            end
                        end
                    end
                else
                    --if no rally beacons, make sure no squads are stuck with rally == true
                    for _, squad in pairs(global.Squads[force.name]) do
                        if squad then squad.rally = false end
                    end
                end
            end
        end
    end
end
