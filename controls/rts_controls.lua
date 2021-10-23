
require("stdlib/game")
require("util")


function handleSelection(event, alt)
	if (event.item == "unit-selection-tool") then
		local player = game.players[event.player_index]
		local area = event.area;

		-- ensure the area is non-zero
		area.left_top.x = area.left_top.x - 0.1
		area.left_top.y = area.left_top.y - 0.1
		area.right_bottom.x = area.right_bottom.x + 0.1
		area.right_bottom.y = area.right_bottom.y + 0.1

		local clickPosition = {x = (area.right_bottom.x + area.left_top.x) / 2 , y = (area.right_bottom.y + area.left_top.y)/ 2}


        local select_entities = player.surface.find_entities_filtered{ area = area, type = "unit", force = player.force}
        local numberOfSelected = table.countNonNil(select_entities)

        if not global.Selections then global.Selections = {} end
        if not global.Selections[player.name] then global.Selections[player.name] = {} end

        deselect(player) --deselect whatever is selected, if anything.
        if numberOfSelected >= 1 then

            Game.print_all(string.format("Units selected! number selected: %d", numberOfSelected) )


            for _, unit in pairs(select_entities) do
                table.insert(global.Selections[player.name], unit)
            end

            --update stickers for selected units
            for _, unit in pairs(global.Selections[player.name]) do
                if unit and unit.valid then
                    player.surface.create_entity{name = "selection-sticker", position = unit.position , target = unit}
                end
            end
        end

	else --if it's a pickup tool maybe?
        --stub. can handle other tool types by adding logic here.
	end
end

function deselect(player)
     --DESELECT LOGIC
     if global.Selections[player.name] ~= nil then
        Game.print_all(string.format("De-selecting units!"))
        for key, member in pairs(global.Selections[player.name]) do
            if member and member.valid then
                local unitBox = member.bounding_box
                unitBox.left_top.x = unitBox.left_top.x - 0.1
                unitBox.left_top.y = unitBox.left_top.y - 0.1
                unitBox.right_bottom.x = unitBox.right_bottom.x + 0.1
                unitBox.right_bottom.y = unitBox.right_bottom.y + 0.1

                for _, stickerfound in pairs(member.surface.find_entities_filtered{type="sticker", area=unitBox}) do
                    stickerfound.destroy()
                end --end for each sticker found on/attached to unit.

                global.Selections[player.name][key] = nil  --remove unit from selection it


            end --end if member is not nil and is still a valid game entity
        end --end for each member in selection list
    end -- end if selections table is not nil.
end -- END DESELECT FUNCTION


--if the selection tool was triggered with alt-mode, which by default is shift+left click.
function handleAltSelection(event)

    --command selected units to move to position clicked.
    if (event.item == "unit-selection-tool") then
        local player = game.players[event.player_index]
        local area = event.area;

		-- ensure the area is non-zero
		area.left_top.x = area.left_top.x - 0.1
		area.left_top.y = area.left_top.y - 0.1
		area.right_bottom.x = area.right_bottom.x + 0.1
		area.right_bottom.y = area.right_bottom.y + 0.1

		local clickPosition = {x = (area.right_bottom.x + area.left_top.x) / 2 , y = (area.right_bottom.y + area.left_top.y)/ 2}
        if global.Selections and global.Selections[player.name] then
            for _, unit in pairs(global.Selections[player.name]) do
                if unit and unit.valid then
                    unit.set_command({type=defines.command.attack_area, destination=clickPosition, radius=20, distraction=defines.distraction.by_anything})
                end -- end if unit is valid, send to attack
            end --end for each unit in selection table
        end --end if selections table is valid
    else
         --stub. can handle other tool types by adding logic here.

    end


end


--based on hotkey press, zooms player  view over to the construction unit which is first on list that has no command.
function findIdleConstructor(event)
    Game.print_all("finding idle constructors..")
    local player = game.players[event.player_index]
    local force = player.force
    if not global.Constructors or not global.Constructors[force.name] then
        return -- no constructors list at all, or for this force, so just return.
    end

    local count = 0
    for _, unit in pairs(global.Constructors[force.name]) do
        count = count + 1

        if unit.valid and unit.type == "unit" then
            Game.print_all(string.format("looking at unit %d", count))
            if true then
                --zoom the player to view the unit if god controller. maybe also run deselect, and select unit immediately?
                if player.controller_type == defines.controllers.god then
                    player.teleport(unit.position, unit.surface)
                    Game.print_all("teleporting god..")
                    return
                else --if player is not god controller, place a blinking icon alert on the map for idle constructor.

                    --another way to do this, is ALL idle constructors are periodically checked and have alerts/markers put on them.
                    player.add_custom_alert(unit, {type="item", name="basic-constructor"}, "Idle Constructor", true)
                    Game.print_all("adding alert..")
                end
            end
        end
    end
end

