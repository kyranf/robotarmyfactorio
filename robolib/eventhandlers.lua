require("util")
require("config.config") -- config for squad control mechanics - important for anyone using
require("robolib.util") -- some utility functions not necessarily related to robot army mod
require("robolib.robotarmyhelpers") -- random helper functions related to the robot army mod
require("robolib.SquadControl") -- allows us to control squads, add entities to squads, etc.
require("prototypes.DroidUnitList") -- so we know what is spawnable
require("stdlib/log/logger")
require("stdlib/game")




function runOnceCheck(game_forces)
    if not global.runOnce then
        LOGGER.log("Running the runOnce function to reset recipes and tech to ensure all are correct...")
        --force reset every force's recipes and techs. I'm sick of it not doing this for me!
        for _, force in pairs(game_forces) do
            force.reset_recipes()
            force.reset_technologies()
        end
        global.runOnce = true
    end

end


function runForceSquadUpdatesForTick(forces, tickProcessIndex)
    global_ensureTablesExist()

    for i, force in pairs(forces) do
        -- ignore enemy and neutral forces. process all others.
        if not (force.name == "enemy" or force.name == "neutral") then
            if not global_fixupTickTablesForForceName(force.name) then return end

            --for the current tick, look at the global table for that tick (mod 60) and any squad references in there.
            --LOGGER.log(string.format("Processing AI for AI tick %d of 60", tickProcessIndex))
            local forceTickTable = global.updateTable[force.name]
            local squadTable = global.Squads[force.name]
            for i, squadref in pairs(forceTickTable[tickProcessIndex]) do
                if squadref and squadTable[squadref] then
                    -- local squad = global.Squads[force.name][squadref]
                    -- if not squad.force then squad.force = force
                    updateSquad(squadTable[squadref])
				else
					-- the squad has been deleted at some point, so let's stop looping over it here.
					global.updateTable[force.name][tickProcessIndex][i] = nil
                end
            end
        end -- if enemy or neutral, do nothing for this force
    end
end


function processDroidAssemblers(force)
    if global.DroidAssemblers and global.DroidAssemblers[force.name] then
        --for each building in their list using name as key
        for index, assembler in pairs(global.DroidAssemblers[force.name]) do
            if assembler and assembler.valid and assembler.force == force then
                local player = assembler.last_user
                local inv = assembler.get_output_inventory() --gets us a LuaInventory
                -- checks list of spawnable droid names, returns nil if none found. otherwise we get a spawnable entity name
                local spawnableDroidName = containsSpawnableDroid(inv)
                if (spawnableDroidName ~= nil and type(spawnableDroidName) == "string") then
                    -- uses assmbler pos, direction, and spawns droid at an offset +- random amount. Does a final "find_non_colliding_position" before returning
                    local droidPos =  getDroidSpawnLocation(assembler)
                    if droidPos ~= -1 then
                        local returnedEntity = assembler.surface.create_entity(
                            {name = spawnableDroidName,
                             position = droidPos,
                             direction = defines.direction.east,
                             force = assembler.force })
                        if returnedEntity then
                            local eventStub = {player_index = player.index, created_entity = returnedEntity}
                            handleDroidSpawned(eventStub)
                        end
                        inv.clear() --clear output slot
                    end
                end
            end
        end
    end
end


function processDroidGuardStations(force)
    --handle guard station spawning here
    if global.droidGuardStations and global.droidGuardStations[force.name] then
        for _, station in pairs(global.droidGuardStations[force.name]) do
            if station and station.valid and station.force == force then
                local inv = station.get_output_inventory() --gets us a luainventory
                local player = station.last_user
                local spawnableDroidName = containsSpawnableDroid(inv)
                local nearby = countNearbyDroids(station.position, station.force, 30) --inputs are position, force, and radius
                --if we have a spawnable droid ready, and there is not too many droids nearby, lets spawn one!
                if (spawnableDroidName ~= nil and type(spawnableDroidName) == "string") and nearby < getSquadGuardSize(station.force) then
                    local droidPos =  getGuardSpawnLocation(station) -- uses station pos
                    if droidPos ~= -1 then
                        local returnedEntity = station.surface.create_entity({name = spawnableDroidName , position = droidPos, direction = defines.direction.east, force = station.force })
                        if returnedEntity then
                            local eventStub = {player_index = player.index, created_entity = returnedEntity, guard = true, guardPos = station.position}
                            handleDroidSpawned(eventStub)
                        end
                        inv.clear() --clear output slot
                    end
                end
            end
        end
    end
end


function processAssemblers(forces)
    for _, force in pairs(forces) do
        processDroidAssemblers(force)
        processDroidGuardStations(force)
    end
end


-- ACTUAL HANDLERS START HERE   vvvvv


function handleOnBuiltEntity(event)
    local entity = event.created_entity

    if(entity.name == "droid-assembling-machine") then
        handleDroidAssemblerPlaced(event)
    elseif(entity.name == "droid-guard-station") then
        handleGuardStationPlaced(event)
    elseif(entity.name == "droid-counter") then
        handleBuiltDroidCounter(event)
    elseif(entity.name == "droid-settings") then
        handleBuiltDroidSettings(event)
    elseif entity.name == "loot-chest" then
        handleBuiltLootChest(event)
    elseif entity.name == "rally-beacon" then
        handleBuiltRallyBeacon(event)
    elseif entity.type == "unit" and table.contains(squadCapable, entity.name) then --squadCapable is defined in DroidUnitList.
        handleDroidSpawned(event) --this deals with droids spawning
    end
end -- handleOnBuiltEntity


function handleOnRobotBuiltEntity(event)
    local entity = event.created_entity
    if(entity.name == "droid-assembling-machine") then
        handleDroidAssemblerPlaced(event)
    elseif(entity.name == "droid-guard-station") then
        handleGuardStationPlaced(event)
    elseif(entity.name == "droid-counter") then
        handleBuiltDroidCounter(event)
    elseif(entity.name == "droid-settings") then
        handleBuiltDroidSettings(event)
    elseif entity.name == "rally-beacon" then
        handleBuiltRallyBeacon(event)
    elseif entity.name == "loot-chest" then
        handleBuiltLootChest(event)
    end
end -- handleOnRobotBuiltEntity


-- MAIN ENTRY POINT IN-GAME
-- during the on-tick event, lets check if we need to update squad AI, spawn droids from assemblers, or update bot counters, etc
function handleTick(event)
    local forces = game.forces
    runOnceCheck(forces)  -- sanity checks

    runForceSquadUpdatesForTick(forces, event.tick % 60 + 1)  -- updates AI for squads; spreads load across all 60 ticks per game second

    if (event.tick % ASSEMBLER_UPDATE_TICKRATE == 0) then
        processAssemblers(forces)
    end

    if (event.tick % BOT_COUNTERS_UPDATE_TICKRATE == 0) then
        doCounterUpdate()
        checkSettingsModules()
    end

    --once every 3 seconds on the 5th tick, run the rally pole command for each force that has them active.
    if (event.tick % 180 == 5) then
        doRallyBeaconUpdate()
    end

end -- handleTick


function handleForceCreated(force)
    LOGGER.log(string.format("New force detected... %s",force.name) )
    global.DroidAssemblers = global.DroidAssemblers or {}
    global.DroidAssemblers[force.name] = global.DroidAssemblers[force.name] or {}

    global.Squads = global.Squads or {}
    global.Squads[force.name] = global.Squads[force.name] or {}

    global.uniqueSquadId = global.uniqueSquadId or {}
    global.uniqueSquadId[force.name] = global.uniqueSquadId[force.name] or 1

    global.lootChests = global.lootChests or {}
    global.lootChests[force.name] = global.lootChests[force.name] or {}

    global.droidCounters = global.droidCounters or {}
    global.droidCounters[force.name] = global.droidCounters[force.name] or {}

    global.droidGuardStations = global.droidGuardStations or {}
    global.droidGuardStations[force.name] = global.droidGuardStations[force.name] or {}

    global.rallyBeacons = global.rallyBeacons or {}
    global.rallyBeacons[force.name] = global.rallyBeacons[force.name] or {}

    global.updateTable = global.updateTable or {}
    global.updateTable[force.name] = global.updateTable[force.name] or {}


    LOGGER.log("New force handler finished...")
end
