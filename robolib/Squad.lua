require("config.config")
require("util")
require("robolib.util")
require("stdlib/log/logger")
require("stdlib/game")
require("prototypes.DroidUnitList")


commands = {
    assemble = 1,   -- starting state, and post-retreat/pre-hunt state
    move = 2,       -- not really useful, don't use this much..
    follow = 3,     -- when set, the SQUAD_AI function should command the squad/s to follow player
    guard = 4,      -- when set, the SQUAD_AI function should command squad to stay around
    patrol = 5,     -- when set, SQUAD_AI will deal with moving them sequentially from patrol point A to B
    hunt = 6,       -- when set, SQUAD_AI will send to nearest enemy
}

global.SquadTemplate = {squadID= 0, player=true, unitGroup = true, members = {size = 0}, home = true, force = true, surface = true, radius=DEFAULT_SQUAD_RADIUS, patrolPoint1 = true, patrolPoint2 = true, currentCommand = "none"} -- this is the empty squad table template

global.patrolState = {lastPole = nil,currentPole = nil,nextPole = nil,movingToNext = false}


function makeCommandTable(cmd_type, pos, dest)
    local command = {}
    command.type = cmd_type
    command.tick = 0
    command.pos = pos or {x = 0, y = 0}
    command.dest = dest or {x = 0, y = 0}
    command.distance = util.distance(command.pos, command.dest)
    command.state_changed_since_last_command = true
    return command
end


function createNewSquad(forceSquadsTable, entity)
    if not global.uniqueSquadId then
        global.uniqueSquadId = {}
    end

    if not (global.uniqueSquadId[entity.force.name])  then
        global.uniqueSquadId[entity.force.name] = 1
    end

    --get next unique ID number and increment it
    local squadID = global.uniqueSquadId[entity.force.name]
    global.uniqueSquadId[entity.force.name] = global.uniqueSquadId[entity.force.name] + 1

    local newsquad = shallowcopy(global.SquadTemplate)

    newsquad.force = entity.force
    newsquad.home = entity.position
    newsquad.surface = entity.surface
    newsquad.unitGroup = entity.surface.create_unit_group({position=entity.position, force=entity.force}) --use the entity who is causing the new squad to be formed, for position.
    newsquad.squadID = squadID
    newsquad.patrolPoint1 = newsquad.home
    newsquad.patrolPoint2 = newsquad.home

    newsquad.members = {}
    newsquad.memberUnitGroupErrors = {}
    newsquad.numMembers = 0

    newsquad.unitGroupFailures = 0
    newsquad.command = makeCommandTable(commands.assemble,
                                        newsquad.unitGroup.position,
                                        newsquad.unitGroup.position)
    forceSquadsTable[squadID] = newsquad

    local tick = global_getLeastFullTickTable(entity.force) --get the least utilised tick in the tick table
    table.insert(global.updateTable[entity.force.name][tick], squadID) --insert this squad reference to the least used tick for running its AI
    LOGGER.log(string.format("CREATING squad %d", squadID))
    return newsquad
end


function deleteSquad(squad, suppress_msg)
    local print_msg = not suppress_msg and PRINT_SQUAD_DEATH_MESSAGES

    -- remove all members!
    if squad.members then
        for key, member in pairs(squad.members) do
            squad.members[key] = nil
        end
        squad.members = nil -- get rid of members table first
    end
    squad.numMembers = 0

    if squad.unitGroup and squad.unitGroup.valid then
        squad.unitGroup.destroy()
    end
    if squad.unitGroup then squad.unitGroup = nil end

    if global.Squads[squad.force.name][squad.squadID] then
        if print_msg == 1 then
            -- using stdlib, print message to entire force
            Game.print_force(squad.force, string.format("Squad %d is no more...", squad.squadID))
        end
        LOGGER.log(string.format("Squad id %d from force %s has died/lost all its members...", squad.squadID, squad.force.name))

        global.Squads[squad.force.name][squad.squadID] = nil  --set the entire squad itself to nil
    end
    global.RetreatingSquads[squad.force.name][squad.squadID] = nil
    squad.deleted = true
end


function squadOrderNeedsRefresh(squad)
    -- if our last order was given a while ago, then it's time to give another order.
    -- However, for orders which requested that the squad path a very long distance,
    -- we want to make sure we gave the pather plenty of time to make that calculation.
    local sanity_check_period = SANITY_CHECK_PERIOD_SECONDS * 60 *
        (squad.command.distance / SANITY_CHECK_PATH_DISTANCE_DIV_FACTOR + 1)
    local its_been_awhile = game.tick > (squad.command.tick + sanity_check_period)
    return its_been_awhile
end


-- add member using the appropriate squad table reference
-- probably obtained by them being the nearest squad to the player,
-- or when a fresh squad is spawned
function addMemberToSquad(squad, soldier)
    if squad and soldier then
        local msg = string.format("Adding soldier (%s) to squad %d of size %d", tostring(soldier), squad.squadID, squad.numMembers)
        LOGGER.log(msg)

        table.insert(squad.members, soldier)
        table.insert(squad.memberUnitGroupErrors, 0)
        squad.unitGroup.add_member(soldier)

        local bigEnoughToHunt = shouldHunt(squad)
        squad.numMembers = squad.numMembers + 1
        if not bigEnoughToHunt and shouldHunt(squad) then
            LOGGER.log(string.format("State of squad %d changed because of size difference", squad.squadID))
            squad.command.state_changed_since_last_command = true
        end

        LOGGER.log(string.format( "Adding soldier to squad %d, squad size is now %d", squad.squadID, squad.numMembers))
    else
        Game.print_force(Game.forces[1], "Tried to addMember to invalid table!")
    end
    return squad
end


function removeMemberFromSquad(squad, soldier_key)
    if squad and soldier_key then
        local msg = string.format("Removing member %d from squad %d of size %d!", soldier_key, squad.squadID, squad.numMembers)
        LOGGER.log(msg)

        squad.members[soldier_key] = nil
        squad.memberUnitGroupErrors[soldier_key] = nil
        squad.numMembers = squad.numMembers - 1
    end
    return squad
end


function mergeSquads(squadA, squadB)
    -- confirm that these can reasonably be merged
    if squadA.force ~= squadB.force or
        squadA.unitGroup.surface ~= squadB.unitGroup.surface
    then return nil end -- then it can't be merged!

    -- this helps us keep things sane as far as keeping the unitGroup in a more reasonable position
    if squadA.numMembers < squadB.numMembers then
        local tempS = squadB
        squadB = squadA
        squadA = tempS
    end

    LOGGER.log(string.format("MERGING squad %d sz %d (%d,%d) into squad %d sz %d (%d,%d) cmd %d!",
                             squadB.squadID, squadB.numMembers,
                             squadB.unitGroup.position.x, squadB.unitGroup.position.y,
                             squadA.squadID, squadA.numMembers,
                             squadA.unitGroup.position.x, squadA.unitGroup.position.y,
                             squadA.command.type))

    for key, soldier in pairs(squadB.members) do
        if soldier and soldier.valid then
            addMemberToSquad(squadA, soldier)
        end
    end
    deleteSquad(squadB, true)

    local mergedSquad = validateSquadIntegrity(squadA)
    if mergedSquad then
        mergedSquad.unitGroupFailures = 0
        local msg = string.format("Merged squad %d into squad %d, now of size %d",
                                  squadB.squadID, squadA.squadID, mergedSquad.numMembers)
        LOGGER.log(msg)
        if PRINT_SQUAD_MERGE_MESSAGES then Game.print_force(mergedSquad.force, msg) end
    else
        local msg = string.format("Merge of squad %d into squad %d resulted in an empty/invalid squad.",
                                  squadB.squadID, squadB.squadID)
        LOGGER.log(msg)
    end
    return mergedSquad
end


function shouldHunt(squad)
    return squad.numMembers >= getSquadHuntSize(squad.force)
        or
        (squad.command.type == commands.hunt and
             squad.numMembers > getSquadRetreatSize(squad.force))
end


function isAttacking(squad)
    return squad.unitGroup.state == defines.group_state.attacking_target or
        squad.unitGroup.state == defines.group_state.attacking_distraction
end


function getSquadPos(squad)
    if squad.unitGroup and squad.unitGroup.valid then
        return squad.unitGroup.position
    else
        return getSquadAvgPosition(squad)
    end
end


function getSquadAvgPosition(squad)
    local pos = {x = 0, y = 0}
    local totx = 0
    local toty = 0
    local count = 0
    for key, unit in pairs(squad.members) do
        if unit and unit.valid then
            totx = totx + unit.position.x
            toty = toty + unit.position.y
            count = count + 1
        end
    end
    if count then
        pos = { x = totx / count, y = toty / count }
    end
    return pos
end


--input is table of squads (global.Squads[force.name]), and position to find closest to
function getClosestSquadToPos(forceSquads, position, maxRange, ignore_squad,
                              only_with_squad_commands)
    local leastDist = maxRange
    local closest_squad = nil

    for key, squad in pairs(forceSquads) do
        if ignore_squad and squad == ignore_squad then
            goto continue
        end
        if not squad.unitGroup or not squad.unitGroup.valid then
            squad = validateSquadIntegrity(squad)
        end
        if squad then
            if only_with_squad_commands and not table.contains(only_with_squad_commands, squad.command.type) then
                goto continue -- we're not interested in a squad with this active command
            end
            local distance = util.distance(position, squad.unitGroup.position)
            if distance <= leastDist then
                closest_squad = squad
                leastDist = distance
            end
        end
        ::continue::
    end

    if (leastDist >= maxRange or closest_squad == nil) then
        --LOGGER.log("getClosestSquadToPos - no squad found or squad too far away")
        return nil
    end

    --game.players[1].print(string.format("closest squad found: %d tiles away from given position, ID %d", leastDist, leastDistSquadID))
    return closest_squad
end


-- on avg twice as fast if you don't actually care about it being *the nearest* squad
function getCloseEnoughSquadToSquad(forceSquads, squad, closeEnough, only_with_commands)
    for key, otherSquad in pairs(forceSquads) do
        if squad == otherSquad then goto continue end
        if only_with_commands and not table.contains(only_with_commands, otherSquad.command.type) then
            goto continue
        end
        otherSquad = validateSquadIntegrity(otherSquad)
        if otherSquad then
            local distance = util.distance(squad.unitGroup.position,
                                           otherSquad.unitGroup.position)
            if distance <= closeEnough then
                LOGGER.log(string.format("Choosing close-enough squad %d at distance %d from squad %d",
                                         otherSquad.squadID, distance, squad.squadID))
                return otherSquad
            end
        end
        ::continue::
    end
    return nil
end


function teleportSoldierToUnitGroup(soldier, unitGroup)
    -- naive teleport to unitgroup location
    local teleport_pos = soldier.surface.find_non_colliding_position(
        soldier.name, unitGroup.position, SQUAD_UNITGROUP_FAILURE_DISTANCE_ESTIMATE/2, 1)
    if teleport_pos then
        if not soldier.teleport(teleport_pos) then
            local msg = "Failed to teleport soldier to squad!!!"
            LOGGER.log(msg)
        else
            return true
        end
    else
        local msg = "Failed to find teleport position!!"
        LOGGER.log(msg)
    end
    return false
end


function recreateUnitGroupForSquad(squad, pos)
    local unitGroup = nil
    if pos ~= nil then
        local surface = getSquadSurface(squad)
        unitGroup = surface.create_unit_group({position=pos, force=squad.force})
        if not squad.unitGroup then
            local msg = string.format("Very bad -- cannot create unit group for squad %d", squad.squadID)
            LOGGER.log(msg)
        else
            squad.command.state_changed_since_last_command = true
        end
    else
        local msg = string.format("Bad error -- cannot find position for any unit in squad %d.", squad.squadID)
        LOGGER.log(msg)
    end
    return unitGroup
end


-- this function is sufficient for basic operations, but does not always fully validate the squad
function squadStillExists(squad)
    if not squad or squad.deleted then
        return nil
    else
        if not squad.unitGroup or not squad.unitGroup.valid then
            squad = validateSquadIntegrity(squad)
        elseif not squad.members or not squad.numMembers or squad.numMembers < 2 or
            not global.Squads[squad.force.name][squad.squadID]
        then
            squad = trimSquad(squad)
        end
    end
    return squad
end


function trimSquad(squad, suppress_msg)
    if not squad or squad.deleted then return nil end
    if squad then
        --player.print(string.format("trimming squad %s, id %d, member size %d", squad, squad.squadID, squad.numMembers))
        squad.numMembers = 0
        if squad.members then
            for key, droid in pairs(squad.members) do
                if droid and droid.valid then
                    squad.numMembers = squad.numMembers + 1
                else
                    -- Game.print_force(squad.force, "trimSquad: removing invalid droid from squad.")
                    squad.members[key] = nil
                    if squad.memberUnitGroupErrors then
                        squad.memberUnitGroupErrors[key] = nil
                    end
                end
            end
        end
        if squad.numMembers == 0 then
            deleteSquad(squad, suppress_msg)
            return nil
        end
    end
    return squad
end


function isSquadNearAssembler(squad, squad_position)
    local nearestAssembler, distance = findClosestAssemblerToPosition(
        global.DroidAssemblers[squad.force.name], squad_position)
    if nearestAssembler and distance < AT_ASSEMBLER_RANGE then
        return true
    else
        return false
    end
end


function retreatMisbehavingLoneWolf(soldier)
    -- we've failed to 'fix' the soldier - remove it from the group
    -- attempt to retreat to a nearby assembler
    local assembler, distance = findClosestAssemblerToPosition(
        global.DroidAssemblers[soldier.force.name], soldier.position)
    if assembler then
        local loneWolfSquad = createNewSquad(global.Squads[soldier.force.name], soldier)
        if loneWolfSquad then
            LOGGER.log(string.format("About to order lone wolf squad %d to retreat...", loneWolfSquad.squadID))
            addMemberToSquad(loneWolfSquad, soldier)
            orderSquadToRetreat(loneWolfSquad)
        end
    end
end


-- this function won't print a squad death message. do your own printing.
function disbandAndRetreatEntireSquad(squad, current_pos)
    if squad.numMembers == 1 and squad.unitGroup and squad.unitGroup.valid then
        orderSquadToRetreat(squad)
    elseif not isSquadNearAssembler(squad, current_pos) then
        -- if we're already very close to a retreat location, this could cause basically an infinite loop.
        -- so only do it if we're far enough away that there will be a chance to do something about the issue eventually.
        local retreatSquadSize = getSquadRetreatSize(squad.force)
        if retreatSquadSize >= squad.numMembers then
            retreatSquadSize = squad.numMembers / 2 + 1
        elseif retreatSquadSize * 2 > squad.numMembers then
            retreatSquadSize = squad.numMembers / 2
        end
        local counter = 0
        local retreatSquad = nil
        for key, soldier in pairs(squad.members) do
            if not retreatSquad then
                retreatSquad = createNewSquad(global.Squads[squad.force.name], soldier)
            end
            removeMemberFromSquad(squad, key)
            addMemberToSquad(retreatSquad, soldier)
            counter = counter + 1
            if counter >= retreatSquadSize then
                orderSquadToRetreat(retreatSquad)
                retreatSquad = nil
                counter = 0
            end
        end
    else
        LOGGER.log(string.format("Can't retreat individual members of squad %d because it's already near an assembler.", squad.squadID))
    end
    deleteSquad(squad, true) -- don't print a message, because we already should have
end


-- checks that all entities in the "members" sub table are present in the unitgroup and that the unit group exists
-- this function is fairly expensive, so don't call it unless necessary.
function validateSquadIntegrity(squad)
    if not squad or squad.deleted then
        return nil
    else
        squad = trimSquad(squad)
        if not squad then return nil end
    end

    local pos = getSquadPos(squad)
    local wander = false
    local recreatedUG = false

     -- validate the unit group
    if not squad.unitGroup or not squad.unitGroup.valid then
        squad.unitGroupFailures = squad.unitGroupFailures + 1
        LOGGER.log(string.format("--- WARNING: squad %d size %d at (%d,%d) has now had %d UnitGroup failures.",
                                 squad.squadID, squad.numMembers, pos.x, pos.y, squad.unitGroupFailures))
        if squad.unitGroupFailures > MAX_UNITGROUP_FAILURES then
            -- this probably means that we're trying to attack a location that can't be attacked
            if not isSquadNearAssembler(squad, pos) and squad.numMembers > 1 then
                local msg = string.format("ERROR: Squad %d of size %d at position (%d,%d) has failed to follow its last order to (%d,%d) and is being disbanded.",
                                          squad.squadID, squad.numMembers,
                                          pos.x, pos.y, squad.command.dest.x, squad.command.dest.y)
                LOGGER.log(msg)
                Game.print_force(squad.force, msg)

                disbandAndRetreatEntireSquad(squad, pos)
                return nil
            else
                -- otherwise reset all individual soldier problems, and recreate unitGroup
                -- we'll just hang out at the assembler for a while until the problems are solved
                for key, soldier in pairs(squad.members) do
                    squad.memberUnitGroupErrors[key] = 0
                end
                wander = true
            end
        end
        squad.unitGroup = recreateUnitGroupForSquad(squad, pos) -- do this
        if not squad.unitGroup or not squad.unitGroup.valid then
            -- apparently we can't even create a unit group. This is pretty bad.
            local msg = string.format("ERROR: Squad %d of size %d near (%d,%d) has lost cohesion and is being disbanded.",
                                      squad.squadID, squad.numMembers, pos.x, pos.y)
            LOGGER.log(msg)
            Game.print_force(squad.force, msg)

            disbandAndRetreatEntireSquad(squad, pos)
            return nil
        end
        recreatedUG = true
    end

    -- check each droid individually to confirm that it is part of the unitGroup
    ::retryCheckMembership::
    for key, soldier in pairs(squad.members) do
        if not soldier or not soldier.valid then
            removeMemberFromSquad(squad, key) -- this should never happen since we've already trimmed the squad
        elseif not table.contains(squad.unitGroup.members, soldier) then
            if soldier.surface == squad.unitGroup.surface then
                local soldier_group_distance = util.distance(pos, soldier.position)
                if not recreatedUG then
                    -- we increment by 2 and decrement by 1 so that a squad has to essentially pass two
                    -- consecutive checks in order to get back down where it was before it failed one.
                    squad.memberUnitGroupErrors[key] = squad.memberUnitGroupErrors[key] + 2
                end
                if squad.memberUnitGroupErrors[key] <= 6 then -- 3 consecutive failed checks will result in failure.
                    if soldier_group_distance > SQUAD_UNITGROUP_FAILURE_DISTANCE_ESTIMATE and
                        USE_TELEPORTATION_FIX and
                        not global_canAnyPlayersSeeThisEntity(soldier) and
                        not global_canAnyPlayersSeeThisEntity(squad.unitGroup)
                    then
                        local msg = string.format(
                            "   >>>>>  Teleporting wayward soldier %d about %d m to location of its squad %d at (%d,%d)",
                            key, soldier_group_distance,
                            squad.squadID, squad.unitGroup.position.x,
                            squad.unitGroup.position.y)
                        LOGGER.log(msg)
                        if teleportSoldierToUnitGroup(soldier, squad.unitGroup) then
							squad.memberUnitGroupErrors[key] = squad.memberUnitGroupErrors[key] - 1
						end
                        squad.unitGroup.add_member(soldier)
                    else
                        local msg = string.format("Re-add soldier %d of squad %d sz %d to unitGroup, attempt %d",
                                                  key, squad.squadID, squad.numMembers, squad.memberUnitGroupErrors[key])
                        LOGGER.log(msg)
                        squad.unitGroup.add_member(soldier)
                    end
                else -- tried teleporting a few times, or couldn't because player present
                    -- no point in disbanding a single-soldier squad, or one that is already at an assembler
                    if not isSquadNearAssembler(squad, pos) and squad.numMembers > 1 then
                        local msg = string.format(
                            "!*!*!*!*! ERROR: After many attempts, failed to reintegrate soldier %d at (%d,%d) %d m from squad %d sz %d. " ..
                                "Therefore the soldier is being asked to retreat on its own.",
                            key, soldier.position.x, soldier.position.y, soldier_group_distance, squad.squadID, squad.numMembers)
                        LOGGER.log(msg)
                        removeMemberFromSquad(squad, key)
                        retreatMisbehavingLoneWolf(soldier)
                    else
                        local msg = string.format("WARNING: Can't remove misbehaving soldier at distance %d " ..
                                                      "from squad %d size %d at (%d,%d) and ask it to retreat " ..
                                                      "because it's already at the nearest assembler or is too small. " ..
                                                      "This will probably result in the unit group losing cohesion and being disbanded.",
                                                  util.distance(soldier.position, squad.unitGroup.position),
                                                  squad.squadID, squad.numMembers, pos.x, pos.y)
                        LOGGER.log(msg)
                        squad.memberUnitGroupErrors[key] = 0
                        squad.unitGroup.add_member(soldier)
                        wander = true
                    end
                end
            else -- the unit group and the soldier are on different surfaces. very odd, but let's try to fix it.
                local msg = string.format("Destroying unit group for squad ID %d because a soldier is on the wrong surface.", squad.squadID)
                LOGGER.log(msg)
                squad.unitGroup.destroy()
                squad.unitGroup = recreateUnitGroupForSquad(squad, pos)
                if not squad.unitGroup then return nil end
            end
        elseif squad.memberUnitGroupErrors[key] > 0 then
            squad.memberUnitGroupErrors[key] = squad.memberUnitGroupErrors[key] - 1
        end
    end

    -- this is our alternative to situations where disbanding and retreating a broken squad
    -- is undesireable - either because the squad is a single member (which means it can't benefit
    -- from being split from other members) or because the squad is already at the 'safe space'
    -- of an assembler, so the order is it undoubtedly failing is just as likely to
    -- be the same retreat order we're about to give.
    if wander then
        local msg = string.format("Squad %d of size %d is unable to complete its orders to go to (%d,%d). It will wander near (%d,%d).",
                                  squad.squadID, squad.numMembers, squad.command.dest.x, squad.command.dest.y, pos.x, pos.y)
        LOGGER.log(msg)
        Game.print_force(squad.force, msg)
        orderSquadToWander(squad, pos)
        squad.unitGroupFailures = 0
        return nil
    end

    return squad
end


function revealChunksBySquad(squad)
    if squad and squad.unitGroup and squad.unitGroup.valid then
        if squadOrderNeedsRefresh(squad) then squad = trimSquad(squad) end
        if not squad then return end
        if squad.numMembers > 0 then  --if there are troops in a valid group in a valid squad.
            local position = squad.unitGroup.position
            --this area should give approx 3x3 chunks revealed
            local area = {left_top = {position.x-32, position.y-32}, right_bottom = {position.x+32, position.y+32}}
            local surface = getSquadSurface(squad)

            if not surface then
                LOGGER.log(string.format("ERROR: Surface for squad ID %d is missing or can't be determined! revealSquadChunks",
                                         squad.squadID))
                return
            end
            squad.force.chart(surface, area) --reveal the chunk they are in.
        end
    end
end


function grabArtifactsBySquad(squad)
    local force = squad.force
    local chest = global.lootChests[force.name]
    if not chest or not chest.valid then return end

    if squad and squad.unitGroup and squad.unitGroup.valid then
        if squad.numMembers > 0 then  --if there are troops in a valid group in a valid squad.
            local surface = getSquadSurface(squad)
            if not surface then
                --LOGGER.log(string.format("ERROR: Surface for squad ID %d is missing or can't be determined! grabArtifacts", squad.squadID))
                return
            end

            local position = squad.unitGroup.position
            local areaToCheck = {left_top = {position.x-ARTIFACT_GRAB_RADIUS, position.y-ARTIFACT_GRAB_RADIUS}, right_bottom = {position.x+ARTIFACT_GRAB_RADIUS, position.y+ARTIFACT_GRAB_RADIUS}}
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
                local cannotInsert = false
                for _, itemStack in pairs(artifactList) do
                    if(chest.can_insert(itemStack)) then
                        chest.insert(itemStack)
                    else
                        cannotInsert = true
                    end
                end
                if cannotInsert then
                    Game.print_force(force, "Your loot chest is too full! Cannot add more until there is room!")
                end
            end
        end
    end
end


-- wander and guard are different, but only in the way they will
-- be interpreted at future game ticks. both result in a command
-- to 'wander' at the location specified.
function orderSquadToWander(squad, position, guard)
    squad.command.pos = squad.unitGroup.position
    local COMMAND_NAME = "WANDER"
    squad.command.type = commands.assemble
    if guard then
        squad.command.type = commands.guard
        COMMAND_NAME = "GUARD"
    end
    squad.command.dest = position
    squad.command.distance = util.distance(position, squad.command.pos)

    debugSquadOrder(squad, COMMAND_NAME, position)
    squad.unitGroup.set_command({type=defines.command.wander,
                                 destination = position,
                                 distraction=defines.distraction.by_enemy})
    squad.command.tick = game.tick
    squad.command.state_changed_since_last_command = false
    squad.unitGroup.start_moving()
end


function orderSquadToAttack(squad, position)
    --make sure squad is good, then set command
    squad.command.type = commands.hunt -- sets the squad's high level role to hunt.
    squad.command.pos = squad.unitGroup.position
    squad.command.dest = position
    squad.command.distance = util.distance(position, squad.command.pos)

    squad.retreatAssembler = nil
    global.RetreatingSquads[squad.force.name][squad.squadID] = nil

    debugSquadOrder(squad, "*ATTACK*", position)
    squad.unitGroup.set_command({type=defines.command.attack_area,
                                 destination=position,
                                 radius=50, distraction=defines.distraction.by_anything})
    squad.command.state_changed_since_last_command = false
    squad.command.tick = game.tick
    squad.unitGroup.start_moving()
end


function debugPrintSquad(squad)
    local ug_state = -1
    if squad.unitGroup then ug_state = squad.unitGroup.state end
    local msg = string.format("sqd %d, sz %d, ug? %s, ugst %s, cmd %s, tick %d",
                              squad.squadID, squad.numMembers, tostring(squad.unitGroup ~= nil),
                              tostring(ug_state), tostring(squad.command.type), game.tick)
    Game.print_force(squad.force, msg)
    LOGGER.log(msg)
end


function debugSquadOrder(squad, orderName, position)
    local msg = string.format("Ordering squad %d sz %d at (%d,%d) to %s at (%d,%d), a distance of %d; last order was %d ticks ago",
                              squad.squadID, squad.numMembers,
                              squad.unitGroup.position.x, squad.unitGroup.position.y,
                              orderName, position.x, position.y, squad.command.distance,
                              game.tick - squad.command.tick)
    LOGGER.log(msg)
end
