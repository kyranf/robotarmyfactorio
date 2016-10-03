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


function processSquadUpdatesForTick(force_name, tickProcessIndex)
    --for the current tick, look at the global table for that tick (mod 60) and any squad references in there.
    --LOGGER.log(string.format("Processing AI for AI tick %d of 60", tickProcessIndex))
    local forceTickTable = global.updateTable[force_name]
    local squadTable = global.Squads[force_name]
    for i, squadref in pairs(forceTickTable[tickProcessIndex]) do
        if squadref and squadTable[squadref] then
            -- local squad = global.Squads[force_name][squadref]
            -- if not squad.force then squad.force = force
            updateSquad(squadTable[squadref])
        else
            -- the squad has been deleted at some point, so let's stop looping over it here.
            LOGGER.log(string.format("Removing nil squad %d from tick table", squadref))
            global.updateTable[force_name][tickProcessIndex][i] = nil
        end
    end
end


function processSpawnedDroid(droid, guard, guardPos, manuallyPlaced)
    local force = droid.force
    --player.print(string.format("Processing new entity %s spawned by player %s", droid.name, player.name) )
    local position = droid.position

    --if this is the first time we are using the player's tables, make it
    if not global.Squads[force.name] then
        global.Squads[force.name] = {}
    end

    local squad = getClosestSquadToPos(global.Squads[force.name], droid.position, SQUAD_CHECK_RANGE)
    if squad and getSquadSurface(squad) ~= droid.surface then
        squad = nil  --we cannot allow a squad to be joined if it's on the wrong surface
    end

    if not squad then
        --if we didnt find a squad nearby, create one
        squad = createNewSquad(global.Squads[force.name], droid)
        if not squad then
            Game.print_force(force, "Failed to create squad for newly spawned droid!!")
        end
    end

    addMemberToSquad(squad, droid)
    if manuallyPlaced then
        LOGGER.log(string.format("Manually placed droid causing squad %d to request new orders.",
                                 squad.squadID))
        squad.command.state_changed_since_last_command = true
    end

    -- code to handle adding new member to a squad that is guarding/patrolling
    if guard == true or squad.command.type == commands.guard then
        if squad.command.type ~= commands.guard then
            squad.command.type = commands.guard
            squad.home = guardPos
            --game.players[1].print(string.format("Setting guard squad to wander around %s", event.guardPos))

            --check if the squad it just joined is patrolling,
            -- if it is, don't force any more move commands because it will be disruptive!
            if not squad.patrolState or
                (squad.patrolState and squad.patrolState.currentWaypoint == -1)
            then
                --Game.print_force(droid.force, "Setting move command to squad home..." )
                orderSquadToWander(squad, squad.home, true)
            end
        end
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
                            processSpawnedDroid(returnedEntity)
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
                            processSpawnedDroid(returnedEntity, true, station.position)
                        end
                        inv.clear() --clear output slot
                    end
                end
            end
        end
    end
end


function tickForces(forces, tick)
    for _, force in pairs(forces) do
        if force.name ~= "enemy" and force.name ~= "neutral" then
            if tick % ASSEMBLER_UPDATE_TICKRATE == 0 then
                processDroidAssemblers(force)
                processDroidGuardStations(force)
            end
            processRetreatChecksForTick(force, tick)
            processSquadUpdatesForTick(force.name, tick % 60 + 1)
            if tick % 1200 == 0 then
                log_session_statistics(force)
            end
        end
    end
end


function processRetreatChecksForTick(force, tick)
    local forceAssemblerRetreatTable = global.AssemblerRetreatTables[force.name]
    for assemblerIdx, squads in pairs(forceAssemblerRetreatTable) do
        if assemblerIdx % ASSEMBLER_MERGE_TICKRATE == tick % ASSEMBLER_MERGE_TICKRATE then
            local assembler = global.DroidAssemblers[force.name][assemblerIdx]
            if not assembler.valid or not checkRetreatAssemblerForMergeableSquads(assembler, squads) then
                -- don't iterate over this assembler again until it is 'recreated'
                -- by a squad trying to retreat to it
                forceAssemblerRetreatTable[assemblerIdx] = nil
            end
        end
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
        processSpawnedDroid(entity, false, nil, true) --this deals with droids spawning
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

    tickForces(forces, event.tick)

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
