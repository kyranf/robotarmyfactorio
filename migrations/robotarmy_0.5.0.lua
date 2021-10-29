game.reload_script()

--ensure all global tables are present
global.Squads = global.Squads or {}
global.uniqueSquadId = global.uniqueSquadId or {}
global.DroidAssemblers = global.DroidAssemblers or {}
global.droidCounters = global.droidCounters or {}
global.lootChests = global.lootChests or {}
global.droidGuardStations = global.droidGuardStations or {}
global.updateTable = global.updateTable or {}

--ensure all force-specific tables and researches are handled/created
for i, force in pairs(game.forces) do
    force.reset_recipes()

    --adding a guard station table entry for each force in the game.
    global.droidGuardStations[force.name] = global.droidGuardStations[force.name] or {}
    global.Squads[force.name] = global.Squads[force.name] or {}
    global.DroidAssemblers[force.name] = global.DroidAssemblers[force.name] or {}
    global.droidCounters[force.name] = global.droidCounters[force.name] or {}
    global.lootChests[force.name] = global.lootChests[force.name] or {}
    global.uniqueSquadId[force.name] = global.uniqueSquadId[force.name] or 1
    global.updateTable[force.name] = global.updateTable[force.name] or {}
end
