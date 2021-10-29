require("stdlib.game")
require("prototypes.DroidUnitList")
require("robolib.util")
game.reload_script()

if not global.units then global.units = {} end

--prep list of names to check against for unit checking

local names = {}
for _, name in pairs(spawnable) do
 local entityName = convertToEntityNames(name)
 names[entityName] = 1 --put something in the names table at this key.
end


local numUnitsAdded = 0;


Game.print_all(string.format("Robot army processing %d forces, in %d surfaces", #game.forces, #game.surfaces))

--ensure all force-specific tables and researches are handled/created
for i, force_ in pairs(game.forces) do
    -- for each force
    for j, surface_ in pairs(game.surfaces) do

        -- get the list of units
        -- for each unit in the list, check the type and name is what we want, add to the list.
        local units = surface_.find_units({area = {{-500, -500}, {500, 500}}, force = force_.name, condition = "same"})
        for _, unitFound in pairs(units) do
            if names[unitFound.name] then
                if unitFound.valid then
                    if not global.units[unitFound.unit_number] then

                        global.units[unitFound.unit_number] = unitFound  -- reference to the LuaEntity with a lookup via the unit number.
                        numUnitsAdded = numUnitsAdded + 1
                    end
                end
            end
        end
    end
end

Game.print_all(string.format("units added in robot army migration script: %d", numUnitsAdded))
Game.print_all("Note that any units away from starting area (+-500 tiles) should be re-deployed for improved AI behaviours.")