require("config.config")
require("util")
require("robolib.Squad")
require("robolib.util")
require("robolib.targeting")
require("stdlib/log/logger")
require("stdlib/game")

-- this efficient AND reliable retreat logic has gotten so large that it really deserves its own file.


function orderSquadToRetreat(squad)
	local assembler, distance = findClosestAssemblerToPosition(
		storage.DroidAssemblers[squad.force.name], squad.unitGroup.position)
    local currentPos = squad.unitGroup.position


    if not  squad.unitGroup then return end;
    if not  squad.unitGroup.valid then return end;
    
	if assembler then
        local retreatPos = getDroidSpawnLocation(assembler)
        if not retreatPos then
            LOGGER.log("ERROR: Failed to find a droid spawn position near the found assembler!")
            orderSquadToWander(squad, currentPos)
            return -- we failed to retreat, but eventually we'll get ordered to do so again..
        end
        distance = util.distance(retreatPos, currentPos)

		squad.command.type = commands.assemble -- takes us out of hunt mode until we're big enough

        if distance > AT_ASSEMBLER_RANGE then
            LOGGER.log(string.format("Ordering squad %d of size %d near (%d,%d) to retreat %d m to assembler %d near (%d,%d)",
                                     squad.squadID, squad.numMembers, currentPos.x, currentPos.y,
                                     distance, assembler.unit_number, retreatPos.x, retreatPos.y))
            -- issue an actual retreat command
            squad.command.dest = retreatPos
            squad.command.distance = distance
            debugSquadOrder(squad, "RETREAT TO ASSEMBLER", retreatPos)
            setGoThenWanderCompoundCommand(squad.unitGroup, retreatPos)
            squad.unitGroup.start_moving()
        end

        addSquadToRetreatTables(squad, assembler)
        squad.command.tick = game.tick
        squad.command.pos = currentPos
        squad.command.state_changed_since_last_command = false
    else
        local msg = string.format("There are no droid assemblers to which squad %d can retreat. You should build at least one.",
                                  squad.squadID)
        LOGGER.log(msg)
        Game.print_force(squad.force, msg)
        orderSquadToWander(squad, currentPos)
    end
end


function addSquadToRetreatTables(squad, targetAssembler)
    -- look for nearby assemblers and add squad to those tables as well
    retreatAssemblers = findNearbyAssemblers(storage.DroidAssemblers[squad.force.name],
                                             targetAssembler.position, AT_ASSEMBLER_RANGE)
    local forceRetreatTables = storage.AssemblerRetreatTables[squad.force.name]
    for i=1, #retreatAssemblers do -- cool/faster iteration syntax for list-like table
        local assembler = retreatAssemblers[i]
        LOGGER.log(string.format("Inserting squad %d into retreat table of assembler %d at (%d,%d)",
                                 squad.squadID, assembler.unit_number, assembler.position.x, assembler.position.y))
        if not forceRetreatTables[assembler.unit_number] then
            forceRetreatTables[assembler.unit_number] = {}
        end
        forceRetreatTables[assembler.unit_number][squad.squadID] = squad
    end
end


-- returns false if the assembler is invalid, or no valid squads were in the squad list.
-- false therefore indicates that this assembler may be removed from its parent list.
function checkRetreatAssemblerForMergeableSquads(assembler, squads)
    local mergeableSquad = nil
    local mergeableSquadDist = nil
    -- LOGGER.log(string.format("Trying to merge retreating squads near assembler at (%d,%d)",
    --                       assembler.position.x, assembler.position.y))
    local squadCount = 0
    local squadCloseCount = 0
    for squadID, squad in pairs(squads) do
        if not squadStillExists(squad) then
            squads[squadID] = nil
        elseif shouldHunt(squad) then
            squads[squadID] = nil
            squad.state_changed_since_last_command = true
        else
            local squadPos = getSquadPos(squad)
            squadCount = squadCount + 1
            local dist = util.distance(squadPos, assembler.position)
            if dist < MERGE_RANGE then
                -- then this squad is close enough to be merged, if it is still valid
                if validateSquadIntegrity(squad) then
                    squadCloseCount = squadCloseCount + 1
                    -- LOGGER.log(string.format(
                    --             " ---- Squad %d sz %d is near its retreating assembler.",
                    --             squad.squadID, squad.numMembers))
                    if mergeableSquad then -- we already found a mergeable squad nearby
                        -- are we close enough to this other squad to merge?
                        if util.distance(mergeableSquad.unitGroup.position,
                                         squadPos) < MERGE_RANGE
                        then
                            mergeableSquad = mergeSquads(squad, mergeableSquad)
                            if shouldHunt(mergeableSquad) then
                                squads[squadID] = nil
                                mergeableSquad = nil
                                mergeableSquadDist = nil
                            end
                        elseif mergeableSquadDist > dist then
                            -- our previous 'mergeableSquad' is a little too far away,
                            -- and may have retreated to a different, nearby assembler.
                            -- Since this merge was not okay, we will instead choose the current
                            -- squad, which is closer to the assembler, as the 'mergeableSquad' for
                            -- any future merge attempts.
                            mergeableSquad = squad
                            mergeableSquadDist = dist
                        end
                    else -- set first 'mergeable squad'
                        mergeableSquad = squad
                        mergeableSquadDist = dist
                    end
                else
                    -- squad is invalid. don't check again
                    squads[squadID] = nil
                end
            end
        end
    end

    -- LOGGER.log(string.format("Assembler merge examined %d squads, of which %d were near this assembler at (%d,%d)",
    --                       squadCount, squadCloseCount, assembler.position.x, assembler.position.y))
    if squadCount == 0 then return false else return true end
end
