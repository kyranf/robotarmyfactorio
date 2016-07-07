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





