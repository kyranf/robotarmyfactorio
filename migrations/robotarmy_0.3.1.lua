
game.reload_script()

game.print("Running migration script for Robot Army 0.3.1")


for i, force in pairs(game.forces) do
    game.print(string.format("Processing force: %s", force.name ))
    force.reset_recipes()
    force.reset_technologies()
    force.recipes["loot-chest"].enabled=false
    force.recipes["rally-beacon"].enabled=false
    game.print("Disabling Loot Chest and Rally Post/Beacon until further notice. Please do not use them.")
 
end


