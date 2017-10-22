require("config.config")
require("util")
require("robolib.Squad")
require("robolib.util")
require("robolib.retreat")
require("stdlib/log/logger")
require("stdlib/game")
require("robolib.targeting")

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
        if(GRAB_ARTIFACTS == 1) then
            grabArtifactsBySquad(squad) --disabled as of 0.15 where alien artifacts are no longer dropped!
        end
    end
end


function executeBattleAI(squad)
    local attacking = isAttacking(squad)
    if attacking then
        -- squad.command.state_changed_since_last_command = true
        if not squad.command.state_changed_since_last_command then
            squad.command.state_changed_since_last_command = true
            LOGGER.log(string.format("Squad %d is attacking - once it no longer is attacking, it will need an order.", squad.squadID))
        end
    end
    if (not attacking) and (squad.command.state_changed_since_last_command or
                                squadOrderNeedsRefresh(squad))
    then
        squad, issue_command = validateSquadIntegrity(squad)
        if not squad or not issue_command then return end
        LOGGER.log(string.format("Squad %d Needs orders of some kind (last: %d) at tick %d",
                                 squad.squadID, squad.command.type, game.tick))
        if shouldHunt(squad) then
            orderSquadToHunt(squad)
        else
            orderSquadToRetreat(squad)
        end
    end
end


function orderSquadToHunt(squad)
    local target = chooseTarget(squad)
    if target then
        orderSquadToAttack(squad, target.position)
    else
        orderSquadToWander(squad, squad.unitGroup.position)
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
