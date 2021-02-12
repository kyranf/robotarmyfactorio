-- This file is for logic dealing with how 'Hunter' squads choose their targets
require("robolib.statistics")

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
        targetPos = findNearestTarget(squad)
    end
    return targetPos
end


function getTargetingType(squad)
    -- for now, it's a global
    return settings.global["Attack Targeting Type"].value
    -- later, it might be per-squad
end


-- look for the enemy closest to the nearest assembler, if any
function findDefendAssemblerTarget(squad)
    local huntRadius = getForceHuntRange(squad.force)
    local assembler, distance = findClosestAssemblerToPosition(
        global.DroidAssemblers[squad.force.name],
        squad.unitGroup.position)
    local huntOrigin = squad.unitGroup.position
    if assembler then
        huntOrigin = assembler.position
    end
    ses_statistics.enemySearches = ses_statistics.enemySearches + 1
    return squad.unitGroup.surface.find_nearest_enemy({position=huntOrigin,
                                                       max_distance=huntRadius,
                                                       force=squad.force})
end


-- basically, find the nearest enemy and go get it
function findNearestTarget(squad)
    local huntRadius = getForceHuntRange(squad.force)
    local nearestEnemy = squad.unitGroup.surface.find_nearest_enemy(
        {position= getForceMapTarget(squad.force) or squad.unitGroup.position,
         max_distance=huntRadius,
         force=squad.force})
    ses_statistics.enemySearches = ses_statistics.enemySearches + 1
    return nearestEnemy
end


HYBRID_BACKTRACK_FACTOR = 2

-- find the nearest enemy, unless there's a nearby assembler being threatened!
function findHybridKeepRadiusClearTarget(squad)
    local msg = string.format("Looking for hybrid target for squad %d", squad.squadID)
    LOGGER.log(msg)
    local assembler, distance = findClosestAssemblerToPosition(
        global.DroidAssemblers[squad.force.name],
        squad.unitGroup.position)
    if assembler then
        local ANEtable = global.AssemblerNearestEnemies[squad.force.name][assembler.unit_number]
        
        if not ANEtable.enemy then
            findAssemblerNearestEnemies(assembler, ANEtable) -- we have never found an enemy.. so lets find the first one. 
        elseif ANEtable.enemy and not ANEtable.enemy.valid then
            findAssemblerNearestEnemies(assembler, ANEtable)
        end
        local nearestEnemyToAssembler = ANEtable.enemy
        if (nearestEnemyToAssembler and nearestEnemyToAssembler.valid) then
            local keepRadiusClear = getAssemblerKeepRadiusClear(assembler)
            if ANEtable.distance < keepRadiusClear then
                msg = string.format("Squad %d targeting assembler target at (%d,%d) to keep radius %d clear",
                                    squad.squadID, nearestEnemyToAssembler.position.x,
                                    nearestEnemyToAssembler.position.y, keepRadiusClear)
                LOGGER.log(msg)
                return nearestEnemyToAssembler
            else
                local nearestEnemyToSquad = findNearestTarget(squad)
                if not nearestEnemyToSquad then
                    msg = string.format("Squad %d targeting assembler target at (%d,%d) because " ..
                                            "there is no nearby alternative target.", squad.squadID,
                                        nearestEnemyToAssembler.position.x,
                                        nearestEnemyToAssembler.position.y)
                    LOGGER.log(msg)
                    return nearestEnemyToAssembler
                else
                    -- if the squad's nearest enemy is more than HYBRID_BACKTRACK_FACTOR times as far
                    -- from the assembler as its target, we should backtrack to attack the assembler's target.
                    local squadEnemyDist = util.distance(nearestEnemyToSquad.position, assembler.position)
                    if ANEtable.distance * HYBRID_BACKTRACK_FACTOR < squadEnemyDist then
                        msg = string.format("Squad %d targeting assembler target at (%d,%d), distances %d and %d",
                                        squad.squadID, nearestEnemyToAssembler.position.x,
                                        nearestEnemyToAssembler.position.y,
                                        squadEnemyDist, ANEtable.distance)
                        LOGGER.log(msg)
                        return nearestEnemyToAssembler
                    else
                        msg = string.format("Squad %d targeting nearest squad target at (%d,%d)",
                                            squad.squadID, nearestEnemyToSquad.position.x,
                                            nearestEnemyToSquad.position.y)
                        LOGGER.log(msg)
                        return nearestEnemyToSquad
                    end
                end
            end
        end
    end
    return findNearestTarget(squad)
end


function findAssemblerNearestEnemies(assembler, ANEtable)
    local msg = string.format("Looking for nearest enemy for assembler %d...",
                              assembler.unit_number)
    LOGGER.log(msg)
    ANEtable.enemy = assembler.surface.find_nearest_enemy(
        {position=assembler.position,
         max_distance=getAssemblerKeepRadiusClear(assembler),
         force=assembler.force})
    ses_statistics.enemySearches = ses_statistics.enemySearches + 1
    ANEtable.lastChecked = game.tick
    if ANEtable.enemy then
        ANEtable.distance = util.distance(assembler.position, ANEtable.enemy.position)
        msg = string.format("Found enemy %d at (%d,%d), distance %d",
                            ANEtable.enemy.unit_number,
                            ANEtable.enemy.position.x, ANEtable.enemy.position.y,
                            ANEtable.distance)
        LOGGER.log(msg)
    end
end



-- Global targeting ----------------------------------------------------------------------------------------

function addForceMapTarget(tag)
	if not global.mapTargets then
		global.mapTargets = {}
	end
	global.mapTargets[tag.force.name] = tag.position
end

function removeForceMapTarget(tag)
	if not global.mapTargets then
		global.mapTargets = {}
	end
	global.mapTargets[tag.force.name] = nil
end

function getForceMapTarget(force)
	return global.mapTargets[force.name]
end

function onChantTagAdded(event)
	if event.tag.icon then 
		if event.tag.icon.name == "droid-selection-tool" then 
			addForceMapTarget(event.tag)
		end
	end 
end


function onChantTagModified(event)
	if event.tag.icon then 
		if event.old_icon.name == "droid-selection-tool" then 
			removeForceMapTarget(event.tag)
		end
		if event.tag.icon.name == "droid-selection-tool" then 
			addForceMapTarget(event.tag)
		end
	end
end

function onChantTagRemoved(event)
	if event.tag.icon then 
		if event.tag.icon.name == "droid-selection-tool" then 
			removeForceMapTarget(event.tag)
		end
	end
end
