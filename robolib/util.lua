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

	if not table then return 0 end

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
--     storage.Squads = storage.Squads or {}
--     storage.uniqueSquadId = storage.uniqueSquadId or {}
--     storage.DroidAssemblers = storage.DroidAssemblers or {}
--     storage.droidCounters = storage.droidCounters or {}
--     storage.lootChests = storage.lootChests or {}
--     storage.droidGuardStations = storage.droidGuardStations or {}
--     local forceList = game.forces
--     for _, force in pairs(forceList) do
--         storage.droidGuardStations[force.name] = storage.droidGuardStations[force.name] or {}
--         storage.Squads[force.name] = storage.Squads[force.name] or {}
--         storage.DroidAssemblers[force.name] = storage.DroidAssemblers[force.name] or {}
--         storage.droidCounters[force.name] = storage.droidCounters[force.name] or {}
--         storage.lootChests[force.name] = storage.lootChests[force.name] or {}
--         storage.uniqueSquadId[force.name] = storage.uniqueSquadId[force.name] or 1
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


--input is a sub-table of storage.updateTable, and is the table for a particular force
function fillTableWithTickEntries(inputTable)
    -- Game.print_all("filling update tick table")
    for i = 1, 60 do
        inputTable[i] = {}
    end
end


function global_getLeastFullTickTable(force)
    if not storage.updateTable then storage.updateTable = {} end
    if not storage.updateTable[force.name] then storage.updateTable[force.name] = {} end

    --check if the table has the 1st tick in it. if not, then go through and fill the table
    if not storage.updateTable[force.name][1] then
        fillTableWithTickEntries(storage.updateTable[force.name]) -- make sure it has got the 0-59 tick entries initialized
    end

    local forceTickTable = storage.updateTable[force.name]
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
