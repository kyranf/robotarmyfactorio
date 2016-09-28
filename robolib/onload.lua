require("robolib.Squad")
require("stdlib/log/logger")
require("stdlib/game")

function global_ensureTablesExist()
    if not global.updateTable then global.updateTable = {} end
    if not global.Squads then global.Squads = {} end
	if not global.AssemblerRetreatTables then global.AssemblerRetreatTables = {} end
	if not global.RetreatingSquads then global.RetreatingSquads = {} end
	if not global.DroidAssemblers then global.DroidAssemblers = {} end
end


function global_migrateSquadsToTickTable(forces)
	LOGGER.log("verifying tick tables...")
	-- ensure all squads are actually in the tick Tables
	for fkey, force in pairs(forces) do
		if force.name ~= "enemy" and force.name ~= "neutral" then
			global_fixupTickTablesForForceName(force.name)
			if not global.Squads[force.name] then goto continue end
			for skey, squad in pairs(global.Squads[force.name]) do
				local found = false
				for tkey, tickTable in pairs(global.updateTable[force.name]) do
					if table.contains(tickTable, squad.squadID) then
						found = true
						break
					end
				end
				if not found then
					squad = validateSquadIntegrity(squad)
					if squad then
						LOGGER.log(string.format("Inserting squad %d of size %d into tickTables", squad.squadID, squad.numMembers))
						table.insert(global.updateTable[force.name][squad.squadID % 60 + 1], squad.squadID)
					end
				end
			end
		end
		::continue::
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
