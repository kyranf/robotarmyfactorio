require("robolib.Squad")
require("stdlib/log/logger")
require("stdlib/game")


function bootstrap_migration_on_first_tick(event)
    LOGGER.log("Running first tick migrations...")
    local forces = game.forces

    runOnceCheck(forces)
    global_ensureTablesExist()
    ses_statistics.sessionStartTick = game.tick

    for fkey, force in pairs(forces) do
        if force.name ~= "enemy" and force.name ~= "neutral" then
            migrateForce(fkey, force)
        end
    end

    -- substitute the 'normal' tick handler, and run it manually this time
    script.on_event(defines.events.on_tick, handleTick)
    handleTick(event)
end


function global_ensureTablesExist()
    if not global.updateTable then global.updateTable = {} end
    if not global.Squads then global.Squads = {} end
    if not global.AssemblerRetreatTables then global.AssemblerRetreatTables = {} end
    if not global.RetreatingSquads then global.RetreatingSquads = {} end
    if not global.DroidAssemblers then global.DroidAssemblers = {} end
    if not global.droidGuardStations then global.droidGuardStations = {} end
end


function migrateForce(fkey, force)
    LOGGER.log(string.format("Migrating force %s...", force.name))
    global_fixupTickTablesForForceName(force.name)
    for skey, squad in pairs(global.Squads[force.name]) do
        migrateSquad(skey, squad)
    end

    migrateDroidAssemblersTo_0_2_4(force)
end


function migrateSquad(skey, squad)
    migrateSquadTo_0_2_4(squad)
end


function migrateSquadTo_0_2_4(squad)
    squad.members.size = nil -- removing old 'size' table entry

    if not squad.command then
        -- this shouldn't happen, but just in case...
        squad.command = makeCommandTable(commands.hunt)
    elseif type(squad.command) ~= "table" then
        -- this is the normal migration path
        LOGGER.log(string.format("Migrating squad %d command table", squad.squadID))
        local pos = getSquadPos(squad)
        squad.command = makeCommandTable(squad.command, pos, pos)
    end

    squad.unitGroupFailures = squad.unitGroupFailures or 0
    squad.numMembers = squad.numMembers or 0

    if not squad.mostRecentUnitGroupRemovalTick then
        squad.mostRecentUnitGroupRemovalTick = {}
        for key, soldier in pairs(squad.members) do
            squad.mostRecentUnitGroupRemovalTick[key] = 1
        end
    end

    -- put squad in tick tables if not there already
    local found = false
    for tkey, tickTable in pairs(global.updateTable[squad.force.name]) do
        if table.contains(tickTable, squad.squadID) then
            found = true
            break
        end
    end
    if not found then
        squad = validateSquadIntegrity(squad)
        if squad then
            LOGGER.log(string.format("Inserting squad %d of size %d into tickTables", squad.squadID, squad.numMembers))
            table.insert(global.updateTable[squad.force.name][squad.squadID % 60 + 1], squad.squadID)
        end
    end
end


function migrateDroidAssemblersTo_0_2_4(force)
    -- index these by their globally unique "unit_number" instead.
    local forceAssemblers = global.DroidAssemblers[force.name]
    for dkey, assembler in pairs(forceAssemblers) do
        if not assembler or not assembler.valid then
            forceAssemblers[dkey] = nil
        elseif dkey ~= assembler.unit_number then
            forceAssemblers[dkey] = nil
            LOGGER.log(string.format("Moving assembler to new index %d from %d", assembler.unit_number, dkey))
            forceAssemblers[assembler.unit_number] = assembler
        end
    end
end


function global_fixupTickTablesForForceName(force_name)
    if not global.updateTable[force_name] then global.updateTable[force_name] = {} end

    --check if the table has the 1st tick in it. if not, then go through and fill the table
    if not global.updateTable[force_name][1] then
        fillTableWithTickEntries(global.updateTable[force_name]) -- make sure it has got the 1-60 tick entries initialized
    end

    if not global.DroidAssemblers[force_name] then
        global.DroidAssemblers[force_name] = {}
    end
    if not global.AssemblerRetreatTables[force_name] then
        global.AssemblerRetreatTables[force_name] = {}
    end
    if not global.RetreatingSquads[force_name] then
        global.RetreatingSquads[force_name] = {}
    end
    if not global.droidGuardStations[force_name] then
        global.droidGuardStations[force_name] = {}
    end
    if not global.droidCounters[force_name] then
        global.droidCounters[force_name] = {}
    end
    if not global.lootChests[force_name] then
        global.lootChests[force_name] = {}
    end
    if not global.uniqueSquadId[force_name] then
        global.uniqueSquadId[force_name] = {}
    end

    if not global.updateTable[force_name] or not global.Squads[force_name]  then
        -- this is a more-or-less fatal error
        -- in the condition of a new game, and you haven't placed a squad yet, can have issues with player force not having the squad table init yet.
        global.Squads[force_name] = {}
        return false

        --disabling below code for now
        --[[Game.print_all("Update Table or squad table for force is missing! Can't run update functions - force name:")
        Game.print_all(force_name)
        if not global.updateTable[force_name] then
            Game.print_all("missing update table...")
        end

        if not global.Squads[force_name] then
            Game.print_all("missing squad table...")
        end
        return false]]--
    end
    return true
end
