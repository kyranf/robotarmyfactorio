game.reload_script()

for i, force in pairs(game.forces) do 
	force.reset_recipes()
	force.reset_technologies()
	
	--force all of the known recipes to be enabled if the appropriate research is already done. 
	if force.technologies["military"].researched then
		force.recipes["droid-rifle"].enabled=true
		force.recipes["droid-rifle-deploy"].enabled=true
		force.recipes["loot-chest"].enabled=true
	end

	if force.technologies["electronics"].researched then
		force.recipes["droid-counter"].enabled=true
	end

	if force.technologies["military-2"].researched then
		force.recipes["droid-smg"].enabled=true
		force.recipes["droid-smg-deploy"].enabled=true
		force.recipes["droid-rocket"].enabled=true
		force.recipes["droid-rocket-deploy"].enabled=true
	end
  
	if force.technologies["military-3"].researched then
		force.recipes["terminator"].enabled=true
		force.recipes["terminator-deploy"].enabled=true
	end
end

--this is when I transition everything from using player.name to player.force.name

--LOGGER.log("Robot Army major version transition point - dealing with large global table migrations")
local forces = game.forces

global.DroidAssemblers = global.DroidAssemblers or {}
global.Squads = global.Squads or {}
global.uniqueSquadId = global.uniqueSquadId or {}
global.lootChests = global.lootChests or {}
global.droidCounters = global.droidCounters or {}

for _, force in pairs(forces) do

	--set up all the tables for the force name, if they don't exist
	global.DroidAssemblers[force.name] = global.DroidAssemblers[force.name] or {}
	global.Squads[force.name] = global.Squads[force.name] or {}
	global.uniqueSquadId[force.name] = global.uniqueSquadId[force.name] or {}
	global.lootChests[force.name] = global.lootChests[force.name] or {}
	global.droidCounters[force.name] = global.droidCounters[force.name] or {}

	-- if this table is empty ( means it is == {} )
	if next(global.DroidAssemblers[force.name]) == nil then
	
		--fill with player.name table info if there is any.
		for _, player in pairs(force.players) do
	
			-- if the player is in this force we are iterating over, and player.name version of this table exists
			if global.DroidAssemblers[player.name] then 
				--for each element in it... check if valid and insert into the force.name table version.
				for _, element in pairs(global.DroidAssemblers[player.name]) do
					if(element and element.valid) then table.insert(global.DroidAssemblers[force.name], element) end
				end
			
			end
	
		end
	
	end
	
	if next(global.Squads[force.name]) == nil then
		
		--fill with player.name table info if there is any.
		for _, player in pairs(force.players) do
	
			-- if the player is in this force we are iterating over, and player.name version of this table exists
			if global.Squads[player.name] then 
				--for each element in it... check if valid and insert into the force.name table version.
				for _, element in pairs(global.Squads[player.name]) do
					if(element and element.valid) then table.insert(global.Squads[force.name], element) end
				end
			
			end
	
		end
	
	
	end
	--this isnt a table, rather it's an integer unique to the force name
	if global.uniqueSquadId[force.name] == nil then
	
		local sum = 0
		--fill with player.name table info if there is any.
		for _, player in pairs(force.players) do
	
			-- if the player is in this force we are iterating over, and player.name version of this table exists
			if global.uniqueSquadId[player.name] then 
				
				sum = sum + global.uniqueSquadId[player.name]
			
			end
	
		end
		
		global.uniqueSquadId[force.name] = sum + 1 --force it to be the sum of all player squadIDs, + 1, to ensure no squad-ref migration will conflict.
	
	
	end
	
	if next(global.lootChests[force.name]) == nil then
	
		
		--fill with player.name table info if there is any.
		for _, player in pairs(force.players) do
	
			-- if the player is in this force we are iterating over, and player.name version of this table exists
			if global.lootChests[player.name] then 
				--for each element in it... check if valid and insert into the force.name table version.
				for _, element in pairs(global.lootChests[player.name]) do
					if(element and element.valid) then table.insert(global.lootChests[force.name], element) end
				end
			
			end
	
		end				
	
	end
	
	if next(global.droidCounters[force.name]) == nil then
	
		
		--fill with player.name table info if there is any.
		for _, player in pairs(force.players) do
	
			-- if the player is in this force we are iterating over, and player.name version of this table exists
			if global.droidCounters[player.name] then 
				--for each element in it... check if valid and insert into the force.name table version.
				for _, element in pairs(global.droidCounters[player.name]) do
					if(element and element.valid) then table.insert(global.droidCounters[force.name], element) end
				end
			
			end
	
		end				
	
	end
				
end
--LOGGER.log("Dealing with large global table migrations completed...")





