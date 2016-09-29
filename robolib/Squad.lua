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
    newsquad.command = commands.assemble

    newsquad.members = {}
    newsquad.memberUnitGroupErrors = {}
    newsquad.numMembers = 0

    newsquad.lastBattleOrderFailures = 0
    newsquad.lastBattleOrderTick = nil -- we use this to periodically sanity check the squad
    newsquad.lastBattleOrderPos = nil

    forceSquadsTable[squadID] = newsquad

    local tick = global_getLeastFullTickTable(entity.force) --get the least utilised tick in the tick table
    table.insert(global.updateTable[entity.force.name][tick], squadID) --insert this squad reference to the least used tick for running its AI
    return newsquad
end


function deleteSquad(squad, suppress_msg)
    local print_msg = not suppress_msg and PRINT_SQUAD_DEATH_MESSAGES

    squad.members = nil -- get rid of members table first
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


function isOldBattleOrder(squad)
    return not squad.lastBattleOrderTick or not squad.lastBattleOrderPos or
        (squad.lastBattleOrderTick + SANITY_CHECK_PERIOD_SECONDS * 60 < game.tick and
             util.distance(getSquadPos(squad), squad.lastBattleOrderPos)
             < SANITY_CHECK_PROGRESS_DISTANCE)
end


function isTimeForMergeCheck(squad)
    return not squad.lastBattleOrderTick or
        squad.lastBattleOrderTick + MERGE_CHECK_PERIOD_SECONDS * 60 < game.tick
end


function markSquadReadyForOrder(squad)
    squad.lastBattleOrderTick = 0
end


-- add member using the appropriate squad table reference
-- probably obtained by them being the nearest squad to the player,
-- or when a fresh squad is spawned
function addMemberToSquad(squad, soldier)
    if squad and soldier then
        local msg = string.format("Adding member %s to squad %d of size %d", tostring(soldier), squad.squadID, squad.numMembers)
        LOGGER.log(msg)

        table.insert(squad.members, soldier)
        table.insert(squad.memberUnitGroupErrors, 0)
        squad.unitGroup.add_member(soldier)
        squad.numMembers = squad.numMembers + 1
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

    LOGGER.log(string.format("MERGING squad %d sz %d (%d,%d) into squad %d sz %d (%d,%d)!",
                             squadB.squadID, squadB.numMembers,
                             squadB.unitGroup.position.x, squadB.unitGroup.position.y,
                             squadA.squadID, squadA.numMembers,
                             squadA.unitGroup.position.x, squadA.unitGroup.position.y))

    for key, soldier in pairs(squadB.members) do
        if soldier and soldier.valid then
            addMemberToSquad(squadA, soldier)
        end
    end
    deleteSquad(squadB, true)

    local mergedSquad = validateSquadIntegrity(squadA)
    if mergedSquad then
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
        (squad.command == commands.hunt and
             squad.numMembers > getSquadRetreatSize(squad.force))
end


function isAttacking(squad)
    return squad.unitGroup.state == defines.group_state.attacking_target or
        squad.unitGroup.state == defines.group_state.attacking_distraction
end


function getSquadPos(squad)
	if squad.unitGroup then return squad.unitGroup.position else return getSquadAvgPosition(squad) end
end


function getSquadAvgPosition(squad)
    local pos = nil
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
            if only_with_squad_commands and not table.contains(only_with_squad_commands, squad.command) then
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
        if only_with_commands and not table.contains(only_with_commands, otherSquad.command) then
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
        soldier.name, unitGroup.position, 5, 1)
    if teleport_pos then
        if not soldier.teleport(teleport_pos) then
            local msg = "Failed to teleport soldier to squad!!!"
            LOGGER.log(msg)
        else
            unitGroup.add_member(soldier)
        end
    else
        local msg = "Failed to find teleport position!!"
        LOGGER.log(msg)
    end
end


function recreateUnitGroupForSquad(squad, pos)
    squad.lastBattleOrderTick = 0 -- needs a new command

    local unitGroup = nil
    if pos ~= nil then
		local surface = getSquadSurface(squad)
		unitGroup = surface.create_unit_group({position=pos, force=squad.force})
		if not squad.unitGroup then
			local msg = string.format("Very bad -- cannot create unit group for squad %d", squad.squadID)
			LOGGER.log(msg)
        end
    else
        local msg = string.format("Bad error -- cannot find position for any unit in squad %d.", squad.squadID)
        LOGGER.log(msg)
    end
    return unitGroup
end


-- this function is sufficient for basic operations, but does not validate that the squad has members.
function squadStillExists(squad)
    if squad and squad.members and global.Squads[squad.force.name][squad.squadID] then
        if not squad.numMembers then
            squad = trimSquad(squad)
        end
        if not squad.unitGroup or not squad.unitGroup.valid then -- it very likely doesn't have members
            squad = validateSquadIntegrity(squad)
        end
        return squad
    else
		if not (squad.unitGroup and squad.unitGroup.valid) then
			 --  squad is missing major components; do a full check
			return validateSquadIntegrity(squad)
		else
			-- looks like it just needs a sanity check
			return trimSquad(squad)
		end
    end
end


function trimSquad(squad, suppress_msg)
    if squad.deleted then return nil end
    if squad then
        --player.print(string.format("trimming squad %s, id %d, member size %d", squad, squad.squadID, squad.numMembers))
        squad.numMembers = 0
        if squad.members then
            squad.members.size = nil -- removing old 'size' table entry
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
            addMemberToSquad(loneWolfSquad, soldier)
            orderSquadToRetreat(loneWolfSquad)
        end
    end
end


function disbandAndRetreatEntireSquad(squad, current_pos)
	if not isSquadNearAssembler(squad, current_pos) then
		-- if we're already very close to a retreat location, this could cause basically an infinite loop.
		-- so only do it if we're far enough away that there will be a chance to do something about the issue eventually.
		for key, soldier in pairs(squad.members) do
			removeMemberFromSquad(squad, key)
			retreatMisbehavingLoneWolf(soldier)
		end
	else
		LOGGER.log(string.format("Can't retreat individual members of squad %d because it's already near an assembler.", squad.squadID))
	end
	deleteSquad(squad)
end


function squadFailedTooManyOrders(squad, current_pos)
	local msg = string.format("ERROR: Squad %d of size %d at position (%d,%d) has failed to follow orders and is being disbanded.",
							  squad.squadID, squad.numMembers,
							  current_pos.x, current_pos.y, squad.lastBattleOrderFailures)
	LOGGER.log(msg)
	Game.print_force(squad.force, msg)

	disbandAndRetreatEntireSquad(squad, current_pos)
end


function cantCreateUnitGroup(squad, current_pos)
	local msg = string.format("ERROR: Squad %d of size %d near (%d,%d) has lost cohesion and is being disbanded.",
							  squad.squadID, squad.numMembers, current_pos.x, current_pos.y)
	LOGGER.log(msg)
	Game.print_force(squad.force, msg)

	disbandAndRetreatEntireSquad(squad, current_pos)
end


-- checks that all entities in the "members" sub table are present in the unitgroup and that the unit group exists
-- this function is fairly expensive, so don't call it unless necessary.
function validateSquadIntegrity(squad)
    if squad then squad = trimSquad(squad) end
    if not squad then return nil end --LOGGER.log("tried to validate a squad that doesn't exist!")

    squad = inGameSquadMigration(squad)

     -- validate the unit group
    if not squad.unitGroup or not squad.unitGroup.valid then
        squad.lastBattleOrderFailures = squad.lastBattleOrderFailures + 3
        LOGGER.log(string.format("--- WARNING: squad %d at +++ order failures %d", squad.squadID,
                                 squad.lastBattleOrderFailures))
		local pos = getSquadAvgPosition(squad)
		if squad.lastBattleOrderFailures >= 10 then
			-- this probably means that we're trying to attack a location that can't be attacked
			squadFailedTooManyOrders(squad, pos)
			return nil
		end
		squad.unitGroup = recreateUnitGroupForSquad(squad, pos)
		if not squad.unitGroup or not squad.unitGroup.valid then
			-- apparently we can't even create a unit group. This is pretty bad.
			cantCreateUnitGroup(squad, pos)
			return nil
		end
    elseif squad.lastBattleOrderFailures > 0 and squad.lastBattleOrderTick + 60 < game.tick then
        squad.lastBattleOrderFailures = squad.lastBattleOrderFailures - 1
        LOGGER.log(string.format("squad %d at - order failures %d", squad.squadID, squad.lastBattleOrderFailures))
    end

    -- check each droid individually to confirm that it is part of the unitGroup
    ::retryCheckMembership::
    for key, soldier in pairs(squad.members) do
        if not soldier or not soldier.valid then
            removeMemberFromSquad(squad, key)
        elseif not table.contains(squad.unitGroup.members, soldier) then
            if soldier.surface == squad.unitGroup.surface then
                squad.memberUnitGroupErrors[key] = squad.memberUnitGroupErrors[key] + 1
                if squad.memberUnitGroupErrors[key] < 3 then
                    local msg = string.format("Re-adding soldier %d of squad %d to unitGroup, attempt %d",
                                              key, squad.squadID, squad.memberUnitGroupErrors[key])
                    LOGGER.log(msg)
                    squad.unitGroup.add_member(soldier)
                elseif squad.memberUnitGroupErrors[key] < 5 and USE_TELEPORTATION_FIX and
                    not global_canAnyPlayersSeeThisEntity(soldier) and
                    not global_canAnyPlayersSeeThisEntity(squad.unitGroup)
                then -- we can cheat by teleporting the entity :/
                    local msg = string.format(
                        "   >>>>>  Teleporting wayward soldier %d about %d to its squad's (%d) location (%d,%d)",
                        key, util.distance(soldier.position,
                                           squad.unitGroup.position),
                        squad.squadID, squad.unitGroup.position.x,
                        squad.unitGroup.position.y)
                    LOGGER.log(msg)
                    teleportSoldierToUnitGroup(soldier, squad.unitGroup) -- if the teleport succeeds, this will add the soldier to the unit group
                else -- tried teleporting a few times, or didn't because player present
                    if not isSquadNearAssembler(squad) then
                        local msg = string.format(
                            "!*!*!*!*! ERROR: After many attempts, failed to reintegrate soldier %d at (%d,%d) with squad %d. " ..
                                "Therefore the soldier is being asked to retreat on its own.",
                            key, soldier.position.x, soldier.position.y, squad.squadID)
                        LOGGER.log(msg)
                        removeMemberFromSquad(squad, soldier_key)
                        retreatMisbehavingLoneWolf(soldier)
                    else
                        local msg = string.format("WARNING: Can't remove misbehaving soldier at distance %d " ..
                                                      "from squad %d and ask it to retreat " ..
                                                      "because it's already at the nearest assembler. " ..
													  "This will eventually result in the unit group losing cohesion and being disbanded.",
                                                  util.distance(soldier.position, squad.unitGroup.position),
                                                  squad.squadID)
                        LOGGER.log(msg)
                    end
                end
            else -- the unit group and the soldier are on different surfaces. very odd, but let's try to fix it.
                local msg = string.format("Destroying unit group for squad ID %d because a soldier is on the wrong surface.", squad.squadID)
                LOGGER.log(msg)
                squad.unitGroup.destroy()
                soldier.surface.create_unit_group({position=soldier.position, force=soldier.force})
                squad.lastBattleOrderTick = 0 -- needs a new command
                --goto retryCheckMembership
            end
        elseif squad.memberUnitGroupErrors[key] > 0 then
            squad.memberUnitGroupErrors[key] = squad.memberUnitGroupErrors[key] - 1
        end
    end

    return squad
end


function isSquadMovingAwayFromLastPosition(squad)
    if not squad.lastBattleOrderPos then return true end
    return util.distance(squad.unitGroup.position, squad.lastBattleOrderPos) > SANITY_CHECK_PROGRESS_DISTANCE
end


function orderToAssembler(orderable, assembler, ignore_distractions)
    local position = getDroidSpawnLocation(assembler)
    if position ~= -1 then
        -- RETREAT!
        local distraction_type = defines.distraction.by_damage
        if ignore_distractions then
            LOGGER.log(string.format("Ignoring all distractions on the way to assembler at %d,%d",
                                     assembler.position.x, assembler.position.y))
            distraction_type = defines.distraction.none
        end
        orderable.set_command({type=defines.command.compound,
                               structure_type=defines.compound_command.return_last,
                               commands={
                                   {type=defines.command.go_to_location,
                                    destination=position,
                                    distraction=distraction_type},
                                   {type=defines.command.wander,
                                    destination=position,
                                    distraction=distraction_type},
        }})
    else
        LOGGER.log("Failed to find a droid spawn position near the requested assembler!")
    end
end


function revealChunksBySquad(squad)
    if squad and squad.unitGroup and squad.unitGroup.valid then
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


function orderSquadToWander(squad, position)
    squad.lastBattleOrderTick = game.tick
    squad.lastBattleOrderPos = squad.unitGroup.position
    debugSquadOrder(squad, "WANDER", position)
    squad.unitGroup.set_command({type=defines.command.wander,
                                 destination = position,
                                 distraction=defines.distraction.by_enemy})
    squad.unitGroup.start_moving()
end


function orderSquadToAttack(squad, position)
    --make sure squad is good, then set command
    squad.command = commands.hunt -- sets the squad's high level role to hunt.
    if squad.lastBattleOrderTick + 60 >= game.tick then
        -- we may be trying to issue bad attack orders...
        squad.lastBattleOrderFailures = squad.lastBattleOrderFailures + 2
        LOGGER.log(string.format("--- WARNING: Squad %d at ++ order failures %d", squad.squadID, squad.lastBattleOrderFailures))
    end
    squad.lastBattleOrderTick = game.tick
    squad.lastBattleOrderPos = squad.unitGroup.position

    squad.retreatAssembler = nil
	global.RetreatingSquads[squad.force.name][squad.squadID] = nil

    debugSquadOrder(squad, "*ATTACK*", position)
    squad.unitGroup.set_command({type=defines.command.attack_area,
                                 destination=position,
                                 radius=50, distraction=defines.distraction.by_anything})
    squad.unitGroup.start_moving()
end


function debugPrintSquad(squad)
    local ug_state = -1
    if squad.unitGroup then ug_state = squad.unitGroup.state end
    local msg = string.format("sqd %d, sz %d, ug? %s, ugst %s, cmd %s, tick %d",
                              squad.squadID, squad.numMembers, tostring(squad.unitGroup ~= nil),
                              tostring(ug_state), tostring(squad.command), game.tick)
    Game.print_force(squad.force, msg)
    LOGGER.log(msg)
end


function debugSquadOrder(squad, orderName, position)
    local msg = string.format("Ordering squad %d (%d: %d,%d) to %s at (%d,%d).",
                              squad.squadID, squad.numMembers,
                              squad.unitGroup.position.x, squad.unitGroup.position.y,
                              orderName, position.x, position.y)
    LOGGER.log(msg)
end


function inGameSquadMigration(squad)
    -- missed migration to 0.2.4
    squad.members.size = nil -- removing old 'size' table entry
    if not squad.memberUnitGroupErrors then
        squad.memberUnitGroupErrors = {}
        for key, soldier in pairs(squad.members) do
            squad.memberUnitGroupErrors[key] = 0
        end
    end
    if not squad.lastBattleOrderFailures then
        squad.lastBattleOrderFailures = 0
        LOGGER.log(string.format("squad %d at 0 failures %d", squad.squadID, squad.lastBattleOrderFailures))
    end
    if not squad.lastBattleOrderTick then squad.lastBattleOrderTick = 0 end
    return squad
end


function trimSquads(forces)
    for _, force in pairs(forces) do
        if global.Squads and global.Squads[force.name] then
            for key, squad in pairs(global.Squads[force.name]) do
                trimSquad(squad)
            end
        end
    end
end
