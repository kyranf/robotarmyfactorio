
--this file contains the logical code for constructor units on a generic basis
--simple constructor units will simply look around them for buildable ghosts, that meet a simple criteria.
--simple constructor units will also automatically try to repair nearby structures.

require("util")
require("config.config")
require("stdlib/game")

function basicConstructorCheck(constructor)

    --  BUILD LOGIC --

    --look around the nearby area for ghosts.
    --if there's one there, and it's buildable, try to 'revive' it. this is where we'd check if we have the item in the global storage as well, until we get another method.

    if not global.ConstructionWarehouses then goto heal_logic end
    if not global.ConstructionWarehouses[constructor.force.name] then goto heal_logic end
    for _, ghost in pairs( constructor.surface.find_entities_filtered{name = "entity-ghost", position = constructor.position, radius = settings.global["Engineer Droid Construction Check Radius"].value, force = constructor.force} ) do

        --sort by distance..
        --starting from nearest... for each ghost, do the following.
            --check if buildable.  (check if the ghost-entity type is in our constructor unit's unique buildable list.. and check if we have the item in global stockpiles)
            -- if buildable check build range -
                    --if in range - try to build it and remove item from global storage.
                        -- return
                    -- if too far away, set move command to move within range..
                        -- return, let it try to get there..

        if constructor.surface.can_place_entity {name = ghost.ghost_name, position = ghost.position, direction = ghost.direction, force = ghost.force} then

            local hasInStorage = false
             --check inventory for food
            local itemCount = 0
            local warehouseUsed = 0
            for _, storageWarehouse in pairs(global.ConstructionWarehouses[constructor.force.name]) do
                local buildingInventory = storageWarehouse.get_inventory(defines.inventory.chest)
                if not buildingInventory.is_empty() then
                    itemCount = storageWarehouse.get_item_count(ghost.ghost_name)
                    if itemCount > 0 then
                        hasInStorage = true
                        warehouseUsed = storageWarehouse
                        break
                    end
                end
            end

            if hasInStorage then
                if util.distance(ghost.position, constructor.position) <= settings.global["Engineer Droid Build Range"].value then
                    constructor.set_command({type=defines.command.go_to_location, destination=constructor.position, radius=1, distraction=defines.distraction.by_nothing}) --stop where they are, to build.
                    local revived, entity, requests = ghost.revive({return_item_request_proxy = true, raise_revive = true})
                    if revived then
                        local beamEntity = constructor.surface.create_entity( {name = "constructor-beam", position = constructor.position, source = constructor,
                                                                            target = entity.position, force = constructor.force, duration = 15 })

                        handleOnRobotBuiltEntity( {created_entity = entity, player_index = entity.force.players[0] }) --might be a better way to pass through optional table params to indicate that

                        --remove item after successful reviving
                        local buildingInventory = warehouseUsed.get_inventory(defines.inventory.chest)
                        buildingInventory.remove({name=entity.name, count=1})  --returns how many actually were removed, dw about that.
                        return
                    end
                else
                    --get unit vector between constructor and ghost, find position of (settings.global["Engineer Droid Build Range"].value-1) away from ghost position, and move to that.

                    constructor.set_command({type=defines.command.go_to_location, destination=ghost.position, radius = 1, distraction=defines.distraction.by_nothing})
                end
            end
        end
    end

    ::heal_logic::

    local HEAL_AMOUNT = (10.0/60.0)  * CONSTRUCTOR_UPDATE_TICKRATE  --10 hp/second, at 60 tick/sec, by the tick rate of constructor updates.
    -- REPAIR LOGIC --
    for _, entity in pairs( constructor.surface.find_entities_filtered{name = nil, position = constructor.position, radius = settings.global["Engineer Droid Repair Range"].value, force = constructor.force} ) do
        if entity.unit_number ~= constructor.unit_number then  -- can't heal yourself!! cheater! wtfbbqsauce!
            if ( entity.health and entity.health > 0 and entity.health < entity.prototype.max_health) and not (entity.has_flag("breaths-air") or (entity.type == "car" or entity.type == "train")) then

                    if entity.health + HEAL_AMOUNT > entity.prototype.max_health then
                        entity.health = entity.prototype.max_health
                    else
                        entity.health  = entity.health + HEAL_AMOUNT
                    end

            end
        end

    end

end