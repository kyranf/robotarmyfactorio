require("stdlib/game")
require("stdlib/log/logger")


--examines the given table, and if it finds a nil element it will remove it
--from the table.
function removeNilsFromTable(tableIN)
    for i, element in pairs(tableIN) do
        if element == nil then
            table.remove(tableIN, i)
        end
    end
end


function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end


function table.countNonNil(table)
    local count = 0
    for _, element in pairs(table) do
        if element then
            count = count + 1
        end
    end
    return count
end


function table.countValidElements(inputTable)
    local count = 0
    inputTable["size"] = nil -- we're no longer keeping size in the members table.
    for key, element in pairs(inputTable) do
        if element and element.valid then
            count = count + 1
        end
    end
    return count
end


-- from http://lua-users.org/wiki/CopyTable
function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


function setContains(set, key)
    return set[key] ~= nil
end


function stripchars(str, chrs)
    local s = str:gsub("["..chrs.."]", '')
    return s
end


function repchars(str, chrs, newchrs)
    local s = string.gsub(str, chrs, newchrs )
    return s
end


function convertToMatchable(str)
    local s =  repchars(str, "%-", "0")
    return s
end


function convertToEntityNames(str)
    local s = repchars(str, "0", "-")
    return s

end


--any new global tables we need to add, just add them in here and it will be easier to maintain. not used yet.
-- function checkGlobalTableInitStates()
--     global.Squads = global.Squads or {}
--     global.uniqueSquadId = global.uniqueSquadId or {}
--     global.DroidAssemblers = global.DroidAssemblers or {}
--     global.droidCounters = global.droidCounters or {}
--     global.lootChests = global.lootChests or {}
--     global.droidGuardStations = global.droidGuardStations or {}
--     local forceList = game.forces
--     for _, force in pairs(forceList) do
--         global.droidGuardStations[force.name] = global.droidGuardStations[force.name] or {}
--         global.Squads[force.name] = global.Squads[force.name] or {}
--         global.DroidAssemblers[force.name] = global.DroidAssemblers[force.name] or {}
--         global.droidCounters[force.name] = global.droidCounters[force.name] or {}
--         global.lootChests[force.name] = global.lootChests[force.name] or {}
--         global.uniqueSquadId[force.name] = global.uniqueSquadId[force.name] or 1
--     end
-- end


-- TODO: improve this to use zoom level and stuff
function global_canAnyPlayersSeeThisEntity(entity)
    for key, player in pairs(game.players) do
        if player and util.distance(player.position, entity.position) < PLAYER_VIEW_RADIUS then
            return true
        end
    end
    return false
end


--waypointList is a list of LuaPositions,
function getClosestEntity(position, entityList)
    local dist = 0
    local distance = 999999
    local closestEntity = nil
    for index, entity in pairs(entityList) do
        --distance between the droid assembler and the squad
        if entity and entity.valid then
            dist = util.distance(entity.position, position)
            if dist <= distance then
                closestEntity = entity
                distance = dist
            end
        end
    end
    return closestEntity
end


--input is a sub-table of global.updateTable, and is the table for a particular force
function fillTableWithTickEntries(inputTable)
    -- Game.print_all("filling update tick table")
    for i = 1, 60 do
        inputTable[i] = {}
    end
end


function global_getLeastFullTickTable(force)
    if not global.updateTable then global.updateTable = {} end
    if not global.updateTable[force.name] then global.updateTable[force.name] = {} end

    --check if the table has the 1st tick in it. if not, then go through and fill the table
    if not global.updateTable[force.name][1] then
        fillTableWithTickEntries(global.updateTable[force.name]) -- make sure it has got the 0-59 tick entries initialized
    end

    local forceTickTable = global.updateTable[force.name]
    --the forceTickTable consists of 60 entries, from 1 to 60 representing 60 ticks.
    --each entry is indexed by tick.
    --each entry is another table, which consists of any number of squad references

    local lowestCount = false
    local lowestIndex = 0
    for tick, tickTable in pairs(forceTickTable) do
        local count = table.countNonNil(tickTable)
        if not lowestCount or count < lowestCount then
            lowestCount = count
            lowestIndex = tick
        end
    end
    return lowestIndex
end
