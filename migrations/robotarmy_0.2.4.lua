
game.reload_script()

game.print("RUNNING ROBOT ARMY MIGRATION SCRIPT FOR 0.2.4")
global.Squads = global.Squads or {}
global.uniqueSquadId = global.uniqueSquadId or {}
global.DroidAssemblers = global.DroidAssemblers or {}
global.droidCounters = global.droidCounters or {}
global.lootChests = global.lootChests or {}
global.droidGuardStations = global.droidGuardStations or {}
global.rallyBeacons = global.rallyBeacons or {}
global.updateTable = global.updateTable or {}


for i, force in pairs(game.forces) do 
	force.reset_recipes()
	force.reset_technologies()
	
	--force all of the known recipes to be enabled if the appropriate research is already done. 
	if force.technologies["military"].researched then
		force.recipes["droid-rifle"].enabled=true
		force.recipes["droid-rifle-deploy"].enabled=true
		force.recipes["loot-chest"].enabled=true
		force.recipes["patrol-pole"].enabled=true
		force.recipes["rally-beacon"].enabled=true
		force.recipes["droid-guard-station"].enabled=true
		force.recipes["droid-assembling-machine"].enabled=true
	end

	if force.technologies["electronics"].researched then
		force.recipes["droid-counter"].enabled=true
		force.recipes["droid-settings"].enabled = true
	end

	if force.technologies["military-2"].researched then
		force.recipes["droid-smg"].enabled=true
		force.recipes["droid-smg-deploy"].enabled=true
		force.recipes["droid-rocket"].enabled=true
		force.recipes["droid-rocket-deploy"].enabled=true
		force.recipes["droid-flame"].enabled=true
		force.recipes["droid-flame-deploy"].enabled=true
	end
  
	if force.technologies["military-3"].researched then
		force.recipes["terminator"].enabled=true
		force.recipes["terminator-deploy"].enabled=true
	end
	
	if force.technologies["combat-robotics"].researched then
		force.recipes["defender-unit"].enabled=true
		force.recipes["defender-unit-deploy"].enabled=true
		force.recipes["distractor-unit"].enabled=true
		force.recipes["distractor-unit-deploy"].enabled=true
		force.recipes["destroyer-unit"].enabled=true
		force.recipes["destroyer-unit-deploy"].enabled=true
	end
	

	--adding a guard staion table entry for each force in the game.

	global.droidGuardStations[force.name] = global.droidGuardStations[force.name] or {}	
	global.Squads[force.name] = global.Squads[force.name] or {}
	global.DroidAssemblers[force.name] = global.DroidAssemblers[force.name] or {}
	global.droidCounters[force.name] = global.droidCounters[force.name] or {}
	global.lootChests[force.name] = global.lootChests[force.name] or {}
	global.uniqueSquadId[force.name] = global.uniqueSquadId[force.name] or 1
	global.rallyBeacons[force.name] = global.rallyBeacons[force.name] or {}
	global.updateTable[force.name] = global.updateTable[force.name] or {}
	
	for _,squad in pairs(global.Squads[force.name]) do

		if squad then
			local found = false		
			
			--for tick table 1-60, check if the table contains this squad's ID 
			for _, tickTable in pairs(global.updateTable[force.name]) do 
				
				if(not found and table.contains(tickTable, squad.squadID)) then 
					found = true
					game.print("Found squad already in AI tables")
				end
				
			end
			if(not found) then
				game.print("Adding squad to AI tick table...")
				local tick = getLeastFullTickTable(force) --get the least utilised tick in the tick table
				table.insert(global.updateTable[force.name][tick], squad.squadID) --insert this squad reference to the least used tick for running its AI
			end
		end
	end
end

-- add code here to migrate squads into new updates tick table format




