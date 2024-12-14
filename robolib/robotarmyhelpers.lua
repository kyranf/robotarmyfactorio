require("util")
require("robolib.util")
require("prototypes.DroidUnitList")
require("stdlib/game")
require("stdlib/log/logger")
require("robolib.Squad")


--gets an offset spawning location for an entity (droid assembler)
-- uses surface.find_non_colliding_position() API call here, to check for a small square around entPos and return the result of that function instead.
-- this will help avoid getting units stuck in stuff. If that function returns nil, then we have problems so try to mention that to whoever call by ret -1
function getDroidSpawnLocation(entity)
    local entPos = entity.position
    local direction = entity.direction

    -- based on direction of building, set offset for spawn location
    if direction == defines.direction.east then
        entPos = ({x = entPos.x - 5,y = entPos.y })
    end
    if direction == defines.direction.north then
        entPos = ({x = entPos.x,y = entPos.y + 5 })
    end
    if direction == defines.direction.south then
        entPos = ({x = entPos.x,y = entPos.y - 5 })
    end
    if direction == defines.direction.west then
        entPos = ({x = entPos.x + 5,y = entPos.y })
    end
    if direction == defines.direction.east  then
        randX = math.random() - math.random(0, 4)
    else
        randX = math.random() + math.random(0, 4)
    end

    if direction == defines.direction.north then
        randY = math.random() + math.random(0, 4)
    else
        randY = math.random() - math.random(0, 4)
    end

    entPos.x = entPos.x + randX
    entPos.y = entPos.y + randY
    --final check, let the game find us a good spot if we've failed by now.
    local finalPos = entity.surface.find_non_colliding_position(entity.name, entPos, 10, 1)
    if not finalPos then
        return nil --we can catch this later
    else
        return finalPos
    end
end


function getAssemblerRetreatLocation(assembler)
    local retreatPos = assembler.position
    local direction = assembler.direction

    -- based on direction of building, set offset for spawn location
    if direction == defines.direction.east then
        retreatPos = ({x = retreatPos.x - 5,y = retreatPos.y })
    end
    if direction == defines.direction.north then
        retreatPos = ({x = retreatPos.x,y = retreatPos.y + 5 })
    end
    if direction == defines.direction.south then
        retreatPos = ({x = retreatPos.x,y = retreatPos.y - 5 })
    end
    if direction == defines.direction.west then
        retreatPos = ({x = retreatPos.x + 5,y = retreatPos.y })
    end

    return retreatPos
end


--entity is the guard station
function getGuardSpawnLocation(entity)
    local entPos = entity.position
    local direction = entity.direction

    --final check, let the game find us a good spot if we've failed by now.
    local finalPos = game.surfaces[1].find_non_colliding_position(entity.name, entPos, 20, 1)
    if not finalPos then
        --LOGGER.log("ERROR: getGuardSpawnLocation failed to find a suitable spawn location!")
        return -1 --an error we can catch later
    end
    return finalPos
end


--function to count nearby droids. counts in a 32 tile radius, which is 1 chunk.
--inputs are position, force, and radius
function countNearbyDroids(position, force, radius)
    local sum = 0
    local surface = game.surfaces[1] --hardcoded for surface 1. this means underground/space whatever surfaces are not handled.
    for _, droid in pairs(spawnable) do
        sum = sum + surface.count_entities_filtered{area = {{position.x - 16, position.y - 16}, {position.x + 16, position.y + 16}}, name = droid, force = force}
    end

    return sum
end


function getSquadHuntSize(force)
    if storage.settings and storage.settings[force.name] and storage.settings[force.name].huntSizeOverride then
        return storage.settings[force.name].huntSizeOverride --overriden value from settings combinator for that force
    else
        return SQUAD_SIZE_MIN_BEFORE_HUNT --default one set in config.lua
    end
end


function getSquadGuardSize(force)
    if storage.settings and storage.settings[force.name] and storage.settings[force.name].guardSizeOverride then
        return storage.settings[force.name].guardSizeOverride    --overriden value from settings combinator for that force
    else
        return GUARD_STATION_GARRISON_SIZE --default one set in config.lua
    end
end


function getSquadRetreatSize(force)
    if storage.settings and storage.settings[force.name] and storage.settings[force.name].retreatSizeOverride then
        return storage.settings[force.name].retreatSizeOverride  --overriden value from settings combinator for that force
    else
        return SQUAD_SIZE_MIN_BEFORE_RETREAT --default one set in config.lua
    end
end


function getForceHuntRange(force)
    if storage.settings and storage.settings[force.name] and storage.settings[force.name].huntRangeOverride then
        return storage.settings[force.name].huntRangeOverride    --overriden value from settings combinator for that force
    else
        return SQUAD_HUNT_RADIUS --default one set in config.lua
    end
end


function getAssemblerKeepRadiusClear(assembler)
    return DEFAULT_KEEP_RADIUS_CLEAR
end


function checkSettingsModules()
    if not storage.settingsModule then storage.settingsModule = {} end
    if not storage.settings then storage.settings = {} end

    for _, gameForce in pairs(game.forces) do
        local settingsModule = storage.settingsModule[gameForce.name]
        if settingsModule and settingsModule.valid then
            if not storage.settings[gameForce.name] then storage.settings[gameForce.name] = {} end

            local settingsCtlBehaviour = settingsModule.get_or_create_control_behavior()
            if settingsCtlBehaviour and settingsCtlBehaviour.valid then
                -- Access the single logistic section
                local section = settingsCtlBehaviour.get_section(1)
                if section and section.valid then
                    -- Iterate through the filters to retrieve signal names and values
                    for slot_filter_index = 1, section.filters_count do
                        local filter = section.filters[slot_filter_index]
                        if filter and filter.value and filter.value.name and filter.min then
                            local sigName = filter.value.name
                            local sigCount = filter.min

                            -- Update settings based on signal names and values
                            if sigName == "signal-squad-size" then
                                if storage.settings[gameForce.name].huntSizeOverride ~= sigCount and checkValidSignalSetting(gameForce, sigName, sigCount) then
                                    storage.settings[gameForce.name].huntSizeOverride = sigCount
                                    Game.print_force(gameForce, string.format("Setting hunt squad size override value to %d for force %s", sigCount, gameForce.name))
                                end
                            elseif sigName == "signal-guard-size" then
                                if storage.settings[gameForce.name].guardSizeOverride ~= sigCount and checkValidSignalSetting(gameForce, sigName, sigCount) then
                                    storage.settings[gameForce.name].guardSizeOverride = sigCount
                                    Game.print_force(gameForce, string.format("Setting guard squad size override value to %d for force %s", sigCount, gameForce.name))
                                end
                            elseif sigName == "signal-retreat-size" then
                                if storage.settings[gameForce.name].retreatSizeOverride ~= sigCount and checkValidSignalSetting(gameForce, sigName, sigCount) then
                                    storage.settings[gameForce.name].retreatSizeOverride = sigCount
                                    Game.print_force(gameForce, string.format("Setting retreat squad size override value to %d for force %s", sigCount, gameForce.name))
                                end
                            elseif sigName == "signal-hunt-radius" then
                                if storage.settings[gameForce.name].huntRangeOverride ~= sigCount and checkValidSignalSetting(gameForce, sigName, sigCount) then
                                    storage.settings[gameForce.name].huntRangeOverride = sigCount
                                    Game.print_force(gameForce, string.format("Setting hunt radius override value to %d for force %s", sigCount, gameForce.name))
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end


function checkValidSignalSetting(force, signal, count)
    if signal == "signal-squad-size" then
        if count > 0 then  --all we care about is positive numbers here
            return true
        else
            Game.print_force(force, string.format("WARNING: The droid settings signal %s must be positive and non-zero!", signal))
            return false
        end
    elseif signal == "signal-guard-size" then
        if count > 0 then  --all we care about is positive numbers here
            return true
        else
            Game.print_force(force, string.format("WARNING: The droid settings signal %s must be positive and non-zero!", signal))
            return false
        end
    elseif signal == "signal-retreat-size" then
        -- we care about retreat size being smaller than the current huntSizeOverride if there is one, otherwise just less than the default hunt squad size.
        if storage.settings[force.name].huntSizeOverride then
            if count > 0 and count < storage.settings[force.name].huntSizeOverride then
                return true
            end
        elseif count > 0 and count < SQUAD_SIZE_MIN_BEFORE_HUNT then
            return true
        else
            Game.print_force(force, string.format("WARNING: The droid settings signal %s must be positive and less than current squad hunt size setting!", signal))
            return false
        end
    elseif signal == "signal-hunt-radius" then
        -- Change the 10000 at your own risk. Don't come whining to me if you change this to something silly like 5000000 and then let the slider get that high
        -- because each squad will the seach a massive radius, and even though the game has optimised this call well, I fear the FPS will be so bad you won't be able to change
        -- the slider and you'll have to load from a recent save.
        if count > 10000 then
            Game.print_force(force, string.format("WARNING: The droid settings signal %s must be less than 10,000 for performance reasons!", signal))
            return false
        elseif count >= 0 then  --all we care about is positive numbers here, and 0 is also okay (nobody will hunt, ever.)
            return true
        else
            Game.print_force(force, string.format("WARNING: The droid settings signal %s must be positive!", signal))
            return false
        end
    end
end


function doCounterUpdate()
    -- For each force in the game, sum droids, then find/update droid-counters
    for _, gameForce in pairs(game.forces) do
        local sum = 0
        local rifleDroids = gameForce.get_entity_count("droid-rifle")
        local battleDroids = gameForce.get_entity_count("droid-smg")
        local rocketDroids = gameForce.get_entity_count("droid-rocket")
        local fireBots = gameForce.get_entity_count("droid-flame")
        local terminators = gameForce.get_entity_count("terminator")

        -- Sum all droids named in the spawnable list
        for _, droidName in pairs(spawnable) do
            sum = sum + gameForce.get_entity_count(droidName)
        end

        -- Define the signals and their corresponding counts
        local signals = {
            {index = 1, count = sum,          name = "signal-droid-alive-count"},
            {index = 2, count = rifleDroids,  name = "signal-droid-rifle-count"},
            {index = 3, count = battleDroids, name = "signal-droid-smg-count"},
            {index = 4, count = rocketDroids, name = "signal-droid-rocket-count"},
            {index = 5, count = fireBots,     name = "signal-droid-flame-count"},
            {index = 6, count = terminators,  name = "signal-droid-terminator-count"}
        }

        -- Ensure the droidCounters storage is initialized
        if storage.droidCounters and storage.droidCounters[gameForce.name] then
            removeNilsFromTable(storage.droidCounters[gameForce.name])

            for _, counter in pairs(storage.droidCounters[gameForce.name]) do
                if counter.valid then
                    local behavior = counter.get_or_create_control_behavior()
                    if behavior and behavior.valid then
                        -- Ensure the combinator has at least one section
                        if behavior.sections_count == 0 then
                            behavior.add_section()
                        end

                        local section = behavior.get_section(1)
                        if section and section.valid then
                             -- Clear all existing slots to prevent duplicates
                            for slot_index = 1, section.filters_count do
                                section.clear_slot(slot_index)
                            end
                            -- Set each slot with the corresponding signal and count
                            for _, signal in pairs(signals) do
                                local filter = {
                                    value = {
                                        name = signal.name,
                                        type = "virtual",
                                        quality = "normal"
                                    },
                                    min = signal.count,
                                    max = signal.count
                                }
                                section.set_slot(signal.index, filter)
                            end
                        end
                    end
                end
            end
        end
    end
end


function sendSquadHome(squad)
    local distFromHome = util.distance(squad.unitGroup.position, squad.home)
    if distFromHome > 15 then
        --Game.print_force(force, "Moving squad back to guard station, they strayed too far!")
        squad.unitGroup.set_command({type=defines.command.go_to_location, destination=squad.home,
                                     radius=DEFAULT_SQUAD_RADIUS, distraction=defines.distraction.by_anything})
        squad.unitGroup.start_moving()
    end
end


-- inputs are the squad table, and the list of patrol-pole entities found by find_entities_filtered
-- returns true if it removed a pole from the pole list, or false if nothing was removed
function removeCurrentPole(squad, poleList)
    if table.countValidElements(poleList) == 0 then return false end
    --if the squad has a table entry for lastPole, then remove it from the pole list
    if squad.currentPole and squad.currentPole.valid then
        for _, pole in pairs(poleList) do
            if squad.currentPole == pole then
                Game.print_force(pole.force, "Removed current pole from polelist")
                pole = nil
                return true
            end
        end
    end
    return false
end


-- inputs are the squad table, and the list of patrol-pole entities found by find_entities_filtered
-- returns true if it removed a pole from the pole list, or false if nothing was removed
function removeLastPole(squad, poleList)
    if table.countValidElements(poleList) == 0 then return false end

    --if the squad has a table entry for lastPole, then remove it from the pole list
    if squad.lastPole and squad.lastPole.valid then
        for _, pole in pairs(poleList) do
            if squad.lastPole == pole then
                Game.print_force(pole.force, "Removed last pole from polelist")
                pole = nil
                return true
            end
        end
    end
    return false
end


function getClosestPole(poleList, position)
    local dist = 0
    local distance = 999999
    local closestPole = nil
    for _, pole in pairs(poleList) do
        --distance between the droid assembler and the squad
        if pole and pole.valid then
            dist = util.distance(pole.position, position)
            if dist <= distance then
                closestPole = pole
                distance = dist
            end
        end
    end

    Game.print_all(string.format("closest pole fount at %d:%d", closestPole.position.x, closestPole.position.y) )
    return closestPole
end


--waypointList is a list of LuaPositions,
function getClosestWayPoint(waypointList, position)
    local dist = 0
    local distance = 999999
    local closestIndex = nil
    for index, waypoint in pairs(waypointList) do
        --distance between the droid assembler and the squad
        dist = util.distance(waypoint, position)
        if dist <= distance then
            closestIndex = index
            distance = dist
        end
    end

    --Game.print_all(string.format("closest waypoint fount at index %d", closestIndex) )
    return closestIndex
end


function buildWaypointList(waypointList, surface, poleArea, squad, force)
    local squadPosition = squad.unitGroup.position
    local poleList = surface.find_entities_filtered({area = poleArea, squadPosition, name = "patrol-pole"})
    local poleCount = table.countValidElements(poleList)
    local masterPoleList = {}

    --Game.print_all(string.format("Waypoint building pole count %d", poleCount))
    for _, pole in pairs(poleList) do
        local connected = pole.circuit_connected_entities.green
        for _,  entity in pairs(connected) do
            if entity.name == "patrol-pole" and (table.contains(masterPoleList, entity) == false) then
                table.insert(masterPoleList, entity)
            end
        end
    end

    local masterPoleCount = table.countValidElements(masterPoleList)
    --Game.print_all(string.format("first iteration of master pole list count %d", masterPoleCount))

    local recursiveSearch = true
    while recursiveSearch do
        local sizeBefore = table.countValidElements(masterPoleList)
        local sizeAfter = recursiveAdd(masterPoleList)
        --Game.print_all(string.format("Recursive search - list size before %d, size after %d", sizeBefore, sizeAfter ))
        if sizeBefore == sizeAfter then
            recursiveSearch = false
            --Game.print_all("ending recursive search!")
        end
    end

    for index, pole in pairs(masterPoleList) do
        local waypoint = pole.position
        waypoint.x = waypoint.x+3
        waypoint.y = waypoint.y+3
        --Game.print_all(string.format("Adding waypoint to list, (%d,%d)", waypoint.x, waypoint.y))
        table.insert(waypointList, waypoint )
    end
end


function recursiveAdd(poleList)
    for _, pole in pairs(poleList) do
        local connected = pole.circuit_connected_entities.green
        for _,  entity in pairs(connected) do
            if entity.name == "patrol-pole" and (table.contains(poleList, entity) == false) then
                table.insert(poleList, entity)
            end
        end
    end
    local newPoleCount = table.countValidElements(poleList)
    return newPoleCount
end


function getFirstValidSoldier(squad)
    for _, soldier in pairs(squad.members) do
        if soldier and soldier.valid then
            return soldier
        end
    end
end


--this function handles the possibility that the squad table might be old and won't have the surface defined.
--using this wrapper we can catch this issue and deal with it at the same time while keeping other code cleaner.
function getSquadSurface(squad)
    if not squad then
        return nil  --barf if the input was empty
    end
    if not squad.surface then
        -- new code to support getting surface from the squad's unit_group itself, if it currently exists
        if squad.unitGroup and squad.unitGroup.valid then
            squad.surface = squad.unitGroup.surface
            return squad.surface
        else
            local unit = getFirstValidSoldier(squad)
            squad.surface = unit.surface -- save this shit for next time!
            return unit.surface
        end
    else
        return squad.surface
    end
end


--logic for handling loot chest spawning, cannot have more than one per force.
function handleBuiltLootChest(event)
    --check if there is a global table entry for loot chests yet, make one if not.
    if not storage.lootChests then
        storage.lootChests = {}
    end

    local chest = event.entity
    local force = chest.force
    --LOGGER.log( string.format("Adding loot chest to force %s", force.name) )
    if not storage.lootChests[force.name] or not storage.lootChests[force.name].valid  then
        storage.lootChests[force.name] = chest   --this is now the force's chest.
    else
        Game.print_force(force,"Error: Can only place one loot chest!")
        chest.surface.spill_item_stack(chest.position, {name = "loot-chest", count = 1})
        chest.destroy()
        --LOGGER.log("WARNING: Can only place one loot chest!")
    end
end


--logic for handling settings module spawning, cannot have more than one per force.
function handleBuiltDroidSettings(event)
    --check if there is a global table entry for settings modules yet, make one if not.
    if not storage.settingsModule then
        storage.settingsModule = {}
    end

    local entity = event.entity
    local force = entity.force

    if not storage.settingsModule[force.name] or not storage.settingsModule[force.name].valid  then
        --LOGGER.log( string.format("Adding settings module to force %s", force.name) )
        storage.settingsModule[force.name] = entity   --this is now the force's settings module.
    else

        Game.print_force(force,"Error: Can only place one settings module!")
        entity.surface.spill_item_stack(entity.position, {name = "droid-settings", count = 1})
        entity.destroy()
        --LOGGER.log("WARNING: Can only place one settings module!")

    end
end


function handleBuiltDroidCounter(event)
    local entity = event.entity
    local entityForce = entity.force.name
    --LOGGER.log( string.format("Adding droid counter to force %s", entityForce) )
    if not storage.droidCounters then
        storage.droidCounters = {}
        storage.droidCounters[entityForce] = {}
        table.insert(storage.droidCounters[entityForce], entity )
    elseif not storage.droidCounters[entityForce] then
        storage.droidCounters[entityForce] = {}
        table.insert(storage.droidCounters[entityForce], entity)
    else
        table.insert(storage.droidCounters[entityForce], entity)
    end
end

function handleGuardStationPlaced(event)
    local entity = event.entity
    local force = entity.force
    --LOGGER.log( string.format("Adding guard station to force %s", force.name) )

    --check for droid guard station global tables first.
    if not storage.droidGuardStations then
        storage.droidGuardStations = {}
    end
    if not storage.droidGuardStations[force.name] then
        storage.droidGuardStations[force.name] = {}
    end

    table.insert(storage.droidGuardStations[force.name], entity)
    removeNilsFromTable(storage.droidGuardStations[force.name]) -- helps remove old invalid/nil entries.
end


function handleDroidAssemblerPlaced(event)
    local entity = event.entity
    local force = entity.force

    --check for droid guard station global tables first.
    if not storage.DroidAssemblers then
        storage.DroidAssemblers = {}
    end
    if not storage.DroidAssemblers[force.name] then
        storage.DroidAssemblers[force.name] = {}
    end

    if not storage.AssemblerNearestEnemies then
        storage.AssemblerNearestEnemies = {}
    end

    if not storage.AssemblerNearestEnemies[force.name] then
        storage.AssemblerNearestEnemies[force.name] = {}
    end

    LOGGER.log(string.format("Adding assembler to force %s", force.name))
    storage.DroidAssemblers[force.name][entity.unit_number] = entity
    storage.AssemblerNearestEnemies[force.name][entity.unit_number] = {lastChecked = 0,
                                                                      enemy = nil,
                                                                      distance = 0}
end


function findClosestAssemblerToPosition(assemblers, position)
    local distance = 999999
    local closestAssembler = nil
    --check every possible droid assembler in that force and return the one with shortest distance

    if assemblers then
        for dkey, droidAss in pairs(assemblers) do
            --distance between the droid assembler and the squad
            if droidAss.valid then
                local dist = util.distance(droidAss.position, position)
                if dist <= distance then
                    closestAssembler = droidAss
                    distance = dist
                end
            else
                assemblers[dkey] = nil
            end
        end
    else
        LOGGER.log("There are no droid assemblers to retreat to.")
    end
    return closestAssembler, distance
end


--- This function should always been used when giving any kind of
--- 'move' command.
--- This is because otherwise units/unitGroups sometimes decide
--- to arrive at their location and then do something really random,
--- like running towards and nesting inside your factory or mining facilities,
--- since they have no active command anymore. This avoids that,
--- since the 'wander' command doesn't ever 'expire'.
function setGoThenWanderCompoundCommand(commandable, position, radius, distraction_type)
    local d_type = distraction_type or defines.distraction.by_damage
    commandable.set_command(
        {
            type = defines.command.compound,
            structure_type = defines.compound_command.return_last,
            commands =
            {
                {
                    type = defines.command.go_to_location,
                    destination = position,
                    distraction = d_type
                },
                {
                    type = defines.command.wander,
                    destination = position,
                    distraction = d_type
                },
            }
        }
    )
end


function isEntityNearAssembler(entity, entity_position)
    local nearestAssembler, distance = findClosestAssemblerToPosition(
        storage.DroidAssemblers[entity.force.name], entity_position)
    if nearestAssembler then
        local spawnPos = getDroidSpawnLocation(nearestAssembler)
        if spawnPos then
            distance = util.distance(spawnPos, entity_position)
        end
    end

    if nearestAssembler and distance < AT_ASSEMBLER_RANGE then
        return true
    else
        return false
    end
end


function findNearbyAssemblers(assemblers, position, range)
    local tempTable = {}
    for dkey, assembler in pairs(assemblers) do
        if assembler.valid and util.distance(position, assembler.position) < range then
            tempTable[#tempTable + 1] = assembler
        end
    end
    return tempTable
end


--checks if the inventory passed contains a spawnable droid item type listed in DroidUnitList.lua
function containsSpawnableDroid(inv)
    --LOGGER.log("checking spawnable droid")
    local itemList = inv.get_contents()

    if itemList then
        for _, i in pairs(itemList) do
			local item = i.name
			local count = i.count
            --LOGGER.log(string.format("item inv list %s , %s", item, count))
            local itemName = convertToMatchable(item)
            --LOGGER.log(item)

            for i, j in pairs(spawnable) do
                --LOGGER.log(string.format("spawnable list %s , %s", i, j))
                local spawnable = convertToMatchable(j)
                --LOGGER.log(spawnable)
                if (string.find(itemName, spawnable)) then --example, in "droid-smg-dummy" find "droid-smg", but the names have been adjusted to replace '-' with '0' to allow string.find to work. turns out hyphens are an escape charater, THANKS LUA!!
                    --convert to spawnable entity name
                    local realName = convertToEntityNames(spawnable)
                    return realName -- should return the name of the item as a string which is then spawnable. eg "droid-smg"
                end
                -- if the entry 'j' is found in the item name for example droid-smg is found in droid-smg-dummy
            end
        end
    else
        return nil -- we failed to get the contents
    end
end
