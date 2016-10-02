require("config.config")
require("util")
require("robolib.Squad")
require("robolib.util")
require("robolib.retreat")
require("stdlib/log/logger")
require("stdlib/game")

function updateSquad(squad)
    if squadStillExists(squad) then -- if not, that means this squad has been deleted
        --LOGGER.log(string.format( "AI for squadref %d in tick table index %d is being executed now...", squadref, tickProcessIndex) )
        --CHECK IF SQUAD IS A GUARD SQUAD, AND CHOOSE WHICH AI FUNCTION TO CALL
        if squad.command.type == commands.guard then
            executeGuardAI(squad)
        elseif not squad.rally then
            executeBattleAI(squad)
        else
            squad = validateSquadIntegrity(squad)
        end

        revealChunksBySquad(squad)
        grabArtifactsBySquad(squad)
    end
end


function executeBattleAI(squad)
    -- DEBUG COMMAND SUCCESS
    if squad.command.tick + 60 == game.tick then
        -- just finished receiving an order
        local ugstate = nil
        local pos = getSquadPos(squad)
        if squad.unitGroup then ugstate = squad.unitGroup.state end
        LOGGER.log(string.format("Squad %d received cmd type %d recently. Current UG state is %s, dist %d",
                                 squad.squadID, squad.command.type, tostring(ugstate),
                                 util.distance(pos, squad.command.pos)))
        if (ugstate ~= defines.group_state.gathering and
                ugstate ~= defines.group_state.finished)
            or (squad.command.type == commands.assemble and squad.unitGroup.valid)
        then
            ses_statistics.commandSuccess = ses_statistics.commandSuccess + 1
            LOGGER.log(string.format("COMMAND SUCCESS for Squad %d", squad.squadID))
        else
            ses_statistics.commandFailure = ses_statistics.commandFailure + 1
            LOGGER.log(string.format("COMMAND FAILURE for Squad %d", squad.squadID))
        end
    end
    -- DEBUG

    local attacking = isAttacking(squad)
    if attacking then squad.command.state_changed_since_last_command = true end
    if (not attacking) and (squad.command.state_changed_since_last_command or
                              squadOrderNeedsRefresh(squad))
    then
        if not validateSquadIntegrity(squad) then return end
        LOGGER.log(string.format("Squad %d Needs orders of some kind %d at %d",
                                 squad.squadID, squad.command.type, game.tick))
        if shouldHunt(squad) then
            orderSquadToHunt(squad)
        else
            orderSquadToRetreat(squad)
        end
        squad.command.state_changed_since_last_command = false
    end
end


function orderSquadToHunt(squad)
    local surface = getSquadSurface(squad)
    if not surface then
        LOGGER.log(string.format("ERROR: Surface for squad ID %d is missing or can't be determined!", squad.squadID))
        return
    end


    local huntOrigin = squad.unitGroup.position
    if usesAssemblerCentricTargeting(squad.force) then
        local assembler, distance = findClosestAssemblerToPosition(global.DroidAssemblers[squad.force.name],
                                                                   squad.unitGroup.position)
        if assembler then huntOrigin = assembler.position end
    end

    local huntRadius =  500 -- experiment to see if this is any faster
    local nearestEnemy = surface.find_nearest_enemy({position = huntOrigin,
                                                     max_distance = huntRadius,
                                                     force = squad.force })
    if not nearestEnemy then
        Game.print_force(squad.force, "searching a second time")
        huntRadius = getSquadHuntRange(squad.force)
        nearestEnemy = surface.find_nearest_enemy({position = huntOrigin,
                                                   max_distance = huntRadius,
                                                   force = squad.force })
    end

    if nearestEnemy then
        -- check if they are in a charted area
        local charted = true   -- = player.force.is_chunk_charted(player.surface, nearestEnemy.position)
        if charted then
            orderSquadToAttack(squad, nearestEnemy.position)
        else
            LOGGER.log("enemy found but in un-charted area...") -- this is debug spam - if we see this, deal with it properly in code and remove this
        end
    else
        --Game.print_force(squad.force, "cannot find nearby target!!") -- this is debug spam - if we see this, deal with it properly in code and remove this
        -- update - I encountered this on a fresh start map and placing down units before any biters (or chunks they live in) had been generated yet.
        -- we need an "idle" behaviour I think, such as returning to the squad "home" which is set when they are first made at an assembler, or the player's position.
    end
end


function executeGuardAI(squad)
    local surface = getSquadSurface(squad)

    if not surface then
        --LOGGER.log(string.format("ERROR: Surface for squad ID %d is missing or can't be determined! guardAIUpdate", squad.squadID))
        return
    end

    local areaTopLeft = {x=squad.unitGroup.position.x-32, y=squad.unitGroup.position.y-32}
    local areaBottomRight = {x=squad.unitGroup.position.x+32, y=squad.unitGroup.position.y+32}
    local areaCheck = {areaTopLeft, areaBottomRight}

    local poleList = surface.find_entities_filtered{area = {areaTopLeft, areaBottomRight}, squad.unitGroup.position, name="patrol-pole"}
    local poleCount = table.countValidElements(poleList)
    if poleCount > 1 then
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

                    if validateSquadIntegrity(squad) then
                        squad.unitGroup.set_command(
                            {type=defines.command.go_to_location,
                             destination=position, radius=DEFAULT_SQUAD_RADIUS,
                             distraction=defines.distraction.by_enemy})
                    end
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

                if validateSquadIntegrity(squad) then
                    squad.unitGroup.set_command(
                        {type=defines.command.go_to_location, destination=position,
                         radius=DEFAULT_SQUAD_RADIUS,
                         distraction=defines.distraction.by_enemy})
                end
                --squad.unitGroup.start_moving()
            end
        end
    elseif squad.command.tick + SANITY_CHECK_PERIOD_SECONDS * 60 < game.tick then
        -- validate, but then wait a while before validating again
        squad.command.tick = game.tick
        validateSquadIntegrity(squad)
    end
end


function doRallyBeaconUpdate()
    if global.Squads then
        for _,force in pairs(game.forces) do
            local forceName = force.name
            if global.Squads[forceName] then
                --if this force has any rally beacons in its table
                if(global.rallyBeacons and global.rallyBeacons[forceName] and table.countValidElements(global.rallyBeacons[forceName]) >= 1) then

                    local forceBeacons = global.rallyBeacons[forceName]
                    local forceSquads = global.Squads[forceName]
                    for _, squad in pairs(forceSquads) do
                        if squad and squad.unitGroup and squad.unitGroup.valid then
                            if squad.command.type ~= commands.guard
                                and squad.command.type ~= commands.patrol
                            then
                                --find nearest rally pole to squad position and send them there.
                                local squadPos = squad.unitGroup.position
                                local closestRallyBeacon = getClosestEntity(squadPos, forceBeacons) --find closest rallyBeacon to move towards
                                local beaconPos = closestRallyBeacon.position
                                local surface = squad.unitGroup.surface
                                beaconPos.x = beaconPos.x+2
                                beaconPos.y = beaconPos.y+2
                                local dist = util.distance(beaconPos, squad.unitGroup.position)
                                if(dist >= 20) then
                                    --give them command to move.
                                    squad.rally = true
                                    squad.unitGroup.destroy()
                                    if validateSquadIntegrity(squad) then --this recreates the unitgroup and re-adds the members
                                        squad.unitGroup.set_command({type=defines.command.go_to_location, destination=beaconPos, distraction=defines.distraction.none})
                                        squad.unitGroup.start_moving()
                                    end
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
