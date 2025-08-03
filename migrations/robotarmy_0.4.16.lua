require("config.config")
game.reload_script()


--ensure all force-specific tables and researches are handled/created
for i, force in pairs(game.forces) do
    force.reset_recipes()
    force.reset_technologies()

    force.recipes["droid-rifle"].enabled = false
    force.recipes["droid-rifle-deploy"].enabled = false
    force.recipes["droid-guard-station"].enabled = false
    force.recipes["droid-assembling-machine"].enabled = false
    force.recipes["droid-counter"].enabled = false
    force.recipes["droid-settings"].enabled = false
    force.recipes["droid-smg"].enabled = false
    force.recipes["droid-smg-deploy"].enabled = false
    force.recipes["droid-rocket"].enabled = false
    force.recipes["droid-rocket-deploy"].enabled = false
    force.recipes["droid-flame"].enabled = false
    force.recipes["droid-flame-deploy"].enabled = false
    force.recipes["terminator"].enabled = false
    force.recipes["terminator-deploy"].enabled = false
    force.recipes["defender-unit"].enabled = false
    force.recipes["defender-unit-deploy"].enabled = false
    force.recipes["distractor-unit"].enabled = false
    force.recipes["distractor-unit-deploy"].enabled = false
    force.recipes["destroyer-unit"].enabled = false
    force.recipes["destroyer-unit-deploy"].enabled = false
    if (GRAB_ARTIFACTS == 1) then
        force.recipes["loot-chest"].enabled = false
    end
end