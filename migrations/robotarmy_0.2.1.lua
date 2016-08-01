game.reload_script()

if not global.Squads then
	global.Squads = {}
end

if not global.uniqueSquadId then
	global.uniqueSquadId = {}
end

if not global.DroidAssemblers then 
	global.DroidAssemblers = {}
end

if not global.droidCounters then
	global.droidCounters = {}
end

if not global.lootChests then
	global.lootChests = {}
end

if not global.droidGuardStations then
	global.droidGuardStations = {}
end		

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
	
	--adding a guard staion table entry for each force in the game.

	global.droidGuardStations[force.name] = global.droidGuardStations[force.name] or {}	
	global.Squads[force.name] = global.Squads[force.name] or {}
	global.DroidAssemblers[force.name] = global.DroidAssemblers[force.name] or {}
	global.droidCounters[force.name] = global.droidCounters[force.name] or {}
	global.lootChests[force.name] = global.lootChests[force.name] or {}
	global.uniqueSquadId[force.name] = global.uniqueSquadId[force.name] or 1
end





