-- This file is for logic dealing with how 'Hunter' squads choose their targets

targetingTypes = {
    searchAndDestroy = 1,
    defendAssembler = 2,
    hybridKeepRadiusClear = 3,
}


function chooseTarget(squad)
    local targetPos = nil
    -- get targeting type
    local targetingType = getTargetingType(squad)
    if targetingType == targetingTypes.defendAssembler then
        targetPos = findDefendAssemblerTarget(squad)
    elseif targetingType == targetingTypes.hybridKeepRadiusClear then
        targetPos = findHybridKeepRadiusClearTarget(squad)
    else -- search and destroy
        targetPos = findSearchAndDestroyTarget(squad)
    end
    return targetPos
end


function getTargetingType(squad)
    -- for now, it's a global
    return GLOBAL_TARGETING_TYPE
    -- later, it might be per-squad
end


-- look for the enemy closest to the nearest assembler, if any
function findDefendAssemblerTarget(squad)
    local huntRadius = getSquadHuntRange(squad.force)
    local assembler, distance = findClosestAssemblerToPosition(
        global.DroidAssemblers[squad.force.name],
        squad.unitGroup.position)
    local huntOrigin = squad.unitGroup.position
    if assembler then
        huntOrigin = assembler.position
    end
    return squad.unitGroup.surface.find_nearest_enemy({position=huntOrigin,
                                                       max_distance=huntRadius,
                                                       force=squad.force})
end


-- basically, find the nearest enemy and go get it
function findSearchAndDestroyTarget(squad)
    local huntRadius = getSquadHuntRange(squad.force)
    local nearestEnemy = squad.unitGroup.surface.find_nearest_enemy(
        {position=squad.unitGroup.position,
         max_distance=huntRadius,
         force=squad.force})
    return nearestEnemy
end


-- find the nearest enemy, unless there's a nearby assembler being threatened!
function findHybridKeepRadiusClearTarget(squad)
    local msg = string.format("Looking for hybrid target for squad %d", squad.squadID)
    LOGGER.log(msg)
    local huntRadius = getSquadHuntRange(squad.force)
    local assembler, distance = findClosestAssemblerToPosition(
        global.DroidAssemblers[squad.force.name],
        squad.unitGroup.position)
    if assembler then
        local ANEtable = global.AssemblerNearestEnemies[squad.force.name][assembler.unit_number]
        local nearestEnemyToAssembler = ANEtable.enemy
        if nearestEnemyToAssembler and nearestEnemyToAssembler.valid then
            return nearestEnemyToAssembler
        end
    end
    return findSearchAndDestroyTarget(squad)
end


CHECK_FOR_ENEMIES_EVERY = 3600 -- in ticks

function findNearestEnemies(assembler)
    ANEtable = global.AssemblerNearestEnemies[assembler.force.name][assembler.unit_number]
    if ANEtable.lastChecked + CHECK_FOR_ENEMIES_EVERY < game.tick then
        local msg = string.format("Looking for nearest enemies for assembler %d...",
                                  assembler.unit_number)
        LOGGER.log(msg)
        ANEtable.enemy = assembler.surface.find_nearest_enemy(
            {position=assembler.position,
             max_distance=getAssemblerKeepRadiusClear(assembler),
             force=assembler.force})
        ANEtable.lastChecked = game.tick
    end
    return ANEtable
end
