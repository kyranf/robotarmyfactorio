require("config.config")
game.reload_script()


--ensure all force-specific tables and researches are handled/created
for i, force in pairs(game.forces) do
    force.reset_recipes()
    force.reset_technologies()

    --force all of the known recipes to be enabled if the appropriate research is already done.
    if force.technologies["military"].researched then
        force.recipes["droid-rifle"].enabled = true
        force.recipes["droid-rifle-deploy"].enabled = true
        if(GRAB_ARTIFACTS == 1) then
            force.recipes["loot-chest"].enabled = true
        end
        force.recipes["patrol-pole"].enabled = true
        force.recipes["droid-guard-station"].enabled = true
        force.recipes["droid-assembling-machine"].enabled = true
        force.recipes["droid-pickup-tool"].enabled = true
        force.recipes["droid-selection-tool"].enabled = true
        force.recipes["droid-counter"].enabled = true
        force.recipes["droid-settings"].enabled = true
    end


    if force.technologies["military-2"].researched then
        force.recipes["droid-smg"].enabled = true
        force.recipes["droid-smg-deploy"].enabled = true
        force.recipes["droid-rocket"].enabled = true
        force.recipes["droid-rocket-deploy"].enabled = true
        force.recipes["droid-flame"].enabled = true
        force.recipes["droid-flame-deploy"].enabled = true
    end

    if force.technologies["military-3"].researched then
        force.recipes["terminator"].enabled = true
        force.recipes["terminator-deploy"].enabled = true
    end

    if force.technologies["defender"].researched then
        force.recipes["defender-unit"].enabled = true
        force.recipes["defender-unit-deploy"].enabled = true
    end

    if force.technologies["distractor"].researched then
        force.recipes["distractor-unit"].enabled = true
        force.recipes["distractor-unit-deploy"].enabled = true
    end

    if force.technologies["destroyer"].researched then
        force.recipes["destroyer-unit"].enabled = true
        force.recipes["destroyer-unit-deploy"].enabled = true
    end

end