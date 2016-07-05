game.reload_script()

for i, force in pairs(game.forces) do 
	force.reset_recipes()
	force.reset_technologies()
end

