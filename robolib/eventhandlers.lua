require("util")
require("config.config") -- config for squad control mechanics - important for anyone using
require("robolib.util") -- some utility functions not necessarily related to robot army mod
require("robolib.robotarmyhelpers") -- random helper functions related to the robot army mod
require("robolib.SquadControl") -- allows us to control squads, add entities to squads, etc.
require("prototypes.DroidUnitList") -- so we know what is spawnable
require("framework/constructor_functions")
require("stdlib/log/logger")
require("stdlib/game")


function runOnceCheck(game_forces)
    if not global.runOnce then
        LOGGER.log("Running the runOnce function to reset recipes and tech to ensure all are correct...")
        --force reset every force's recipes and techs. I'm sick of it not doing this for me!
        for _, force in pairs(game_forces) do
            force.reset_recipes()
            force.reset_technologies()
        end
        global.runOnce = true
    end
end


function processSquadUpdatesForTick(force_name, tickProcessIndex)
    --for the current tick, look at the global table for that tick (mod 60) and any squad references in there.
    --LOGGER.log(string.format("Processing AI for AI tick %d of 60", tickProcessIndex))

    if not global.updateTable[force_name] then return end
    if not global.Squads[force_name] then return end

    local forceTickTable = global.updateTable[force_name]
    local squadTable = global.Squads[force_name]

    if(forceTickTable and squadTable) then

        for i, squadref in pairs(forceTickTable[tickProcessIndex]) do
            if squadref and squadTable[squadref] then
                -- local squad = global.Squads[force_name][squadref]
                -- if not squad.force then squad.force = force
                updateSquad(squadTable[squadref])
            else
                -- the squad has been deleted at some point, so let's stop looping over it here.
                LOGGER.log(string.format("Removing nil squad %d from tick table", squadref))
                global.updateTable[force_name][tickProcessIndex][i] = nil
            end
        end
    end
end



function reportSelectedUnits(event, alt)
	if (event.item == "droid-selection-tool") then
		local player = game.players[event.player_index]
		local area = event.area;

		-- ensure the area is non-zero
		area.left_top.x = area.left_top.x - 0.1
		area.left_top.y = area.left_top.y - 0.1
		area.right_bottom.x = area.right_bottom.x + 0.1
		area.right_bottom.y = area.right_bottom.y + 0.1

		local clickPosition = {x = (area.right_bottom.x + area.left_top.x) / 2 , y = (area.right_bottom.y + area.left_top.y)/ 2}
		--Game.print_all(string.format("point %d,%d, middle of box %d,%d and %d,%d", clickPosition.x, clickPosition.y, area.left_top.x, area.left_top.y, area.right_bottom.x, area.right_bottom.y))
		if not alt then -- add units to selection table

			--local select_entities = player.surface.find_entities_filtered{ area = area, type = "unit", force = player.force}
			--local numberOfSelected = table.countNonNil(select_entities)

			local squad = getClosestSquadToPos(global.Squads[player.force.name], clickPosition, SQUAD_CHECK_RANGE) --get nearest squad within SQUAD_CHECK_RANGE amount of tiles radius from click point.

			if squad then

                -- if there's a currently selected squad, deselect them!
                --DESELECT LOGIC
				if global.selected_squad and global.selected_squad[player.index] and global.selected_squad[player.index] ~= nil then
					if global.Squads[player.force.name][global.selected_squad[player.index]] then  --if the squad still exists, even though we have the ID still in selection
						Game.print_all(string.format("De-selected Squad ID %d", global.selected_squad[player.index]) )
						for _, member in pairs(global.Squads[player.force.name][global.selected_squad[player.index]].unitGroup.members) do
							local unitBox = member.bounding_box
							unitBox.left_top.x = unitBox.left_top.x - 0.1
							unitBox.left_top.y = unitBox.left_top.y - 0.1
							unitBox.right_bottom.x = unitBox.right_bottom.x + 0.1
							unitBox.right_bottom.y = unitBox.right_bottom.y + 0.1

							for _,e in pairs(member.surface.find_entities_filtered{type="sticker", area=unitBox}) do
							  e.destroy()
							end
						end
					end
				end


				Game.print_all(string.format("Squad ID %d selected! Droids in squad: %d", squad.squadID, squad.numMembers) )
				--Game.print_all(string.format("Tool %s Selected area! Player ID %d, box %d,%d and %d,%d, droids in squad %d ",  event.item , event.player_index, area.left_top.x, area.left_top.y, area.right_bottom.x, area.right_bottom.y, squad.numMembers ) )


				--make sure we have the global table..
				if not global.selected_squad then global.selected_squad = {} end

				global.selected_squad[player.index] = {}
				global.selected_squad[player.index] = squad.squadID

				for _, member in pairs(global.Squads[player.force.name][squad.squadID].unitGroup.members) do

					 global.Squads[player.force.name][squad.squadID].unitGroup.surface.create_entity{name = "selection-sticker", position = member.position , target = member}

				end

			else
				--no squad was nearby the click point!
				--make sure we have the global table..
				if not global.selected_squad then global.selected_squad = {} end

				--DESELECT LOGIC
                if global.selected_squad[player.index] ~= nil then
                    local squadRef = global.Squads[player.force.name][global.selected_squad[player.index]]
					if squadRef and squadRef.unitGroup.valid then  --if the squad still exists, even though we have the ID still in selection
						player.print(string.format("De-selected Squad ID %d", global.selected_squad[player.index]) )
						for _, member in pairs(squadRef.unitGroup.members) do
							local unitBox = member.bounding_box
							unitBox.left_top.x = unitBox.left_top.x - 0.1
							unitBox.left_top.y = unitBox.left_top.y - 0.1
							unitBox.right_bottom.x = unitBox.right_bottom.x + 0.1
							unitBox.right_bottom.y = unitBox.right_bottom.y + 0.1

							for _,e in pairs(member.surface.find_entities_filtered{type="sticker", area=unitBox}) do
							  e.destroy({raise_destroy = true})
							end
						end
                    end
                    global.selected_squad[player.index] = nil
				else

					global.selected_squad[player.index] = nil
				end

			end



		else --command selected units to move to position clicked.
			if global.selected_squad and global.selected_squad[event.player_index] then
			local squad = global.Squads[player.force.name][(global.selected_squad[event.player_index])]
				if(squad) then
					--Game.print_all(string.format("Tool %s Selected alt-selected-area! Player ID %d, box %d,%d and %d,%d, droids in squad %d ", event.item, event.player_index, area.left_top.x,area.left_top.y, area.right_bottom.x, area.right_bottom.y, squad.numMembers ) )
					--Game.print_all(string.format("Commanding Squad ID %d ...", global.selected_squad[event.player_index]))
					squad.command.type = commands.guard
					orderSquadToAttack(squad, clickPosition)
				end
			end

		end

	else --if it's a pickup tool maybe?

		if (event.item == "droid-pickup-tool") then

			local player = game.players[event.player_index]
			local area = event.area;

			-- ensure the area is non-zero
			area.left_top.x = area.left_top.x - 0.01
			area.left_top.y = area.left_top.y - 0.01
			area.right_bottom.x = area.right_bottom.x + 0.01
			area.right_bottom.y = area.right_bottom.y + 0.01

			local unitList = player.surface.find_entities_filtered{	area = area, type = "unit",	force = player.force }

			--Game.print_all(string.format( "number of units in area selected %d", #unitList) )

			for _ , unit in pairs(unitList) do

				--Game.print_all(string.format( "Trying to pick up unit type %s, unit name %s" , unit.type, unit.name ) )
				local nameOfUnit = convertToMatchable(unit.name)
				--if it's one of our droids, kill it!  Note, the spawnable table comes from DroidUnitList.lua in prototypes folder.
				local removed = false
				for _, droidname in pairs(spawnable) do
					local comparableDroidName = convertToMatchable(droidname)
					--Game.print_all(string.format( "Trying to compare names: unit name  %s, spawnable droid list name %s" , nameOfUnit, comparableDroidName ) )
					if not removed and (string.find(nameOfUnit, comparableDroidName)) then
						removed = true

						if player.insert{name= unit.name, count=1} == 0 then
                            player.print("Not enough inventory space to pick up droid!")
                        else
                            unit.destroy({raise_destroy = true})
                        end
					end
				end

			end

		end

	end
end


function processSpawnedDroid(droid, guard, guardPos, manuallyPlaced)
    local force = droid.force
    --player.print(string.format("Processing new entity %s spawned by player %s", droid.name, player.name) )
    local position = droid.position

    --if this is the first time we are using the player's tables, make it
    if not global.Squads[force.name] then
        global.Squads[force.name] = {}
    end

    local squad = getClosestSquadToPos(global.Squads[force.name], droid.position, SQUAD_CHECK_RANGE)
    if squad and getSquadSurface(squad) ~= droid.surface then
        squad = nil  --we cannot allow a squad to be joined if it's on the wrong surface
    end

    if not squad then
        --if we didnt find a squad nearby, create one
        squad = createNewSquad(global.Squads[force.name], droid)
        if not squad then
            Game.print_force(force, "Failed to create squad for newly spawned droid!!")
        end
    end

    addMemberToSquad(squad, droid)

    -- code to handle adding new member to a squad that is guarding/patrolling
    if guard == true or squad.command.type == commands.guard then
        if squad.command.type ~= commands.guard then
            squad.command.type = commands.guard
            squad.home = guardPos
            --game.players[1].print(string.format("Setting guard squad to wander around %s", event.guardPos))

            --check if the squad it just joined is patrolling,
            -- if it is, don't force any more move commands because it will be disruptive!
            if not squad.patrolState or
                (squad.patrolState and squad.patrolState.currentWaypoint == -1)
            then
                --Game.print_force(droid.force, "Setting move command to squad home..." )
                orderSquadToWander(squad, squad.home, true)
            end
        end
    end
end

function onPlayerJoined(event)
    local playerIndex = event.player_index
    if game.active_mods["Unit_Control"] then
        game.players[playerIndex].print("Robot Army: Unit Control Mod is active! Please use Unit Control selection and command method. Automated behaviours disabled.")
    else
        game.players[playerIndex].print("Robot Army: Unit Control Mod is NOT active! Use Squad Selection tool like normal. Automated behaviours enabled.")
    end
end

function processDroidAssemblers(force)
    if global.DroidAssemblers and global.DroidAssemblers[force.name] then
        --for each building in their list using name as key
        for index, assembler in pairs(global.DroidAssemblers[force.name]) do
            if assembler and assembler.valid and assembler.force == force then

                --see if there is a wire-attached settings module. if there is, that will dictate some of the logic used.
                local settingsModule = checkAttachedSettingsModule(assembler)

                --set the various spawn and attack settings to default values
                local huntSize = settings.global["Squad Hunt Size"].value
                local huntRadius = settings.global["Squad Hunt Radius"].value
                local retreatSize = settings.global["Squad Retreat Size"].value
                local garrisonSize =  settings.global["Guard Station Garrison Size"].value

                --if we found the settings module, overwrite the above values.
                if settingsModule and settingsModule.valid then

                    huntSize, huntRadius, retreatSize, garrisonSize = getSettingsOverrides(settingsModule, huntSize, huntRadius, retreatSize, garrisonSize)

                end

                checkSpawn(assembler, garrisonSize)

                --prototyping stuff - find nearest enemy within hunt radius, iterate through member list and set to attack-move.
                if global.assemblerSquad and global.assemblerSquad[assembler.unit_number] and global.assemblerSquad[assembler.unit_number].members then
                    local memberTable = global.assemblerSquad[assembler.unit_number].members
                    local commandTable = global.assemblerSquad[assembler.unit_number].commands

                    if(global.assemblerSquad[assembler.unit_number].numMembers >= huntSize) then

                        local enemy = assembler.surface.find_nearest_enemy({position= assembler.position, max_distance = huntRadius, force=assembler.force})

                        if (enemy and enemy.valid ) then

                            for index, unit in pairs(memberTable) do

                                if unit.valid then
                                    local command =  commandTable[unit.unit_number]
                                    if command then
                                        if command ~= defines.command.attack_area then
                                            commandTable[unit.unit_number] = defines.command.attack_area

                                            unit.set_command({type=defines.command.attack_area,
                                                                    destination=enemy.position,
                                                                    radius=32,
                                                                    distraction=defines.distraction.by_enemy})
                                            end
                                    else

                                        commandTable[unit.unit_number] = defines.command.attack_area

                                        unit.set_command({type=defines.command.attack_area,
                                                                destination=enemy.position,
                                                                radius=32,
                                                                distraction=defines.distraction.by_enemy})


                                    end
                                end

                            end --end for each unit in the member table

                        end --end if the enemy target is found, and is valid.
                    else
                        --we might be needing to retreat
                        if(global.assemblerSquad[assembler.unit_number].numMembers <= retreatSize ) then

                            for index, unit in pairs(memberTable) do
                                if(unit.valid) then
                                    if util.distance(assembler.position, unit.position) > 100 then
                                        --game.print("Setting retreat command, retreat size is "..retreatSize.." squad size is: "..global.assemblerSquad[assembler.unit_number].numMembers)
                                        unit.set_command({type=defines.command.attack_area,
                                                                        destination=assembler.position,
                                                                        radius=32,
                                                                        distraction=defines.distraction.by_damage})
                                    end
                                else
                                    memberTable[index] = nil
                                end
                            end

                        end
                    end --end we have enough members in the squad to start hunting.
                end -- end if assembler squad and related tables are non-nil

                --update attached counter module, if there is one.
                local counterAttached = getConnectedCounterModule(assembler)
                if counterAttached and counterAttached.valid then
                    updateCountsFromDroidAssembler(assembler, counterAttached)
                end
            end -- end if assembler is valid and same force as the force being processed.
        end -- end for eac assembler in force's droid assembler table..
    end -- end if droid assemblers table and force's table is there
end --end processDroidAssemblers function

--handler for the on_ai_command_completed event.
function handleTaskCompleted(event)
    if not global.assemblerAssignment or not global.assemblerAssignment[event.unit_number] then return end
--use the unit number to find which unit/squad the unit belonged to, and set its appropriate command state for new commands from the master (assembler)
    local assembler = global.assemblerAssignment[event.unit_number]
    if not assembler then return end
    if not assembler.valid then return end


    local squadTable = global.assemblerSquad[assembler.unit_number]
    if not squadTable then return end

    squadTable.commands[event.unit_number] = defines.command.stop
    local unit = squadTable.members[event.unit_number]
    if unit and unit.valid then
        unit.set_command({type=defines.command.stop})
    end
end

function checkSpawn(assembler, squadHuntSize)
    local inv = assembler.get_inventory(defines.inventory.chest) --gets us a LuaInventory
    -- checks list of spawnable droid names, returns nil if none found. otherwise we get a spawnable entity name
    local spawnableDroidName, itemNameUsed = containsSpawnableDroid(inv)
    if (spawnableDroidName ~= nil and type(spawnableDroidName) == "string") then
        -- uses assmbler pos, direction, and spawns droid at an offset +- random amount. Does a final "find_non_colliding_position" before returning

        --maintain the assembler squad list with only living units.
        if not global.assemblerSquad then global.assemblerSquad = {} end
        if not global.assemblerSquad[assembler.unit_number] then global.assemblerSquad[assembler.unit_number] = {} end

        if not global.assemblerSquad[assembler.unit_number].members then global.assemblerSquad[assembler.unit_number].members = {} end
        if not global.assemblerSquad[assembler.unit_number].commands then global.assemblerSquad[assembler.unit_number].commands = {} end

        for index , unit in pairs(global.assemblerSquad[assembler.unit_number].members) do
            if not unit.valid then global.assemblerSquad[assembler.unit_number].members[index] = nil end
        end

        global.assemblerSquad[assembler.unit_number].numMembers = table_size(global.assemblerSquad[assembler.unit_number].members)
        local squadTable = global.assemblerSquad[assembler.unit_number]
        --maintain the unit -> assembler association tables.
        if not global.assemblerAssignment then global.assemblerAssignment = {} end


        -- check surrounding area to see if we have reached a limit of spawned droids, to prevent a constantly spawning situation
        --if (squadTable.numMembers < getSquadHuntSize(assembler.force) )  then
        if (squadTable.numMembers < squadHuntSize) then
            local droidPos =  getDroidSpawnLocation(assembler, true)
            if droidPos then
                local returnedEntity = assembler.surface.create_entity(
                    {name = spawnableDroidName,
                     position = droidPos,
                     direction = defines.direction.east,
                     force = assembler.force,
                     raise_built=true })

                if returnedEntity then

                    --check if it's a constructor.
                    checkIfConstructor(returnedEntity)

                    inv.remove({name=returnedEntity.name, count=1}) --clear output slot
                    table.insert(squadTable.members, returnedEntity)
                    squadTable.numMembers = squadTable.numMembers + 1
                    --game.forces[assembler.force.name].print("assembler unit list size: " .. #global.assemblerSquad[assembler.unit_number].members)

                     --put the assembler's reference in table key'd by the unit's unique number. allows us to work backwards and find the assembler the unit belongs to, and get the the whole squad.
                    global.assemblerAssignment[returnedEntity.unit_number] = assembler

                    if not game.active_mods["Unit_Control"] then
                        --processSpawnedDroid(returnedEntity)
                    else
                        --script.raise_event(defines.events.on_entity_spawned, {entity = returnedEntity, spawner = assembler})
                    end
                end

            end
        else
            --Game.print_force(force, "Cannot spawn droid, too many droids or obstructions around droid assembler!")
        end
    end

end

function processDroidGuardStations(force)
    --handle guard station spawning here
    if global.droidGuardStations and global.droidGuardStations[force.name] then
        for _, station in pairs(global.droidGuardStations[force.name]) do
            if station and station.valid and station.force == force then

                local inv = station.get_inventory(defines.inventory.chest) --gets us a LuaInventory
                -- checks list of spawnable droid names, returns nil if none found. otherwise we get a spawnable entity name
                local spawnableDroidName, itemNameUsed = containsSpawnableDroid(inv)

                --maintain the guard squad list with only living units.
                if not global.guardSquadMembers then global.guardSquadMembers = {} end
                if not global.guardSquadMembers[station.unit_number] then global.guardSquadMembers[station.unit_number] = {} end
                for index , unit in pairs(global.guardSquadMembers[station.unit_number] ) do
                    if not unit.valid then global.guardSquadMembers[station.unit_number][index] = nil end
                end
                local squadsize = table_size(global.guardSquadMembers[station.unit_number] )
                local memberTable = global.guardSquadMembers[station.unit_number]


                 --see if there is a wire-attached settings module. if there is, that will dictate some of the logic used.
                 local settingsModule = checkAttachedSettingsModule(station)

                 --set the various spawn and attack settings to default values
                 local huntSize = settings.global["Squad Hunt Size"].value
                 local huntRadius = settings.global["Squad Keep Clear Radius"].value    -- NOTE THIS IS DIFFERENT, IT IS KEEP CLEAR NOT HUNT RADIUS
                 local retreatSize = settings.global["Squad Retreat Size"].value
                 local garrisonSize =  settings.global["Guard Station Garrison Size"].value
                 --if we found the settings module, overwrite the above values.
                 if settingsModule and settingsModule.valid then

                     huntSize, huntRadius, retreatSize, garrisonSize = getSettingsOverrides(settingsModule, huntSize, huntRadius, retreatSize, garrisonSize)

                 end

                --check inventory for spawnable droids, spawn if we are below-capacity of garrison size.
                if (spawnableDroidName ~= nil and type(spawnableDroidName) == "string")  and squadsize < garrisonSize  then
                    -- uses assmbler pos, direction, and spawns droid at an offset +- random amount. Does a final "find_non_colliding_position" before returning

                    local droidPos =  getDroidSpawnLocation(station, true)
                    if droidPos and droidPos ~= -1 then
                        local returnedEntity = station.surface.create_entity(
                            {name = spawnableDroidName,
                                position = droidPos,
                                direction = defines.direction.east,
                                force = station.force })
                        if returnedEntity then
                            inv.remove({name=returnedEntity.name, count=1}) --clear output slot

                            table.insert(global.guardSquadMembers[station.unit_number], returnedEntity)


                            if not game.active_mods["Unit_Control"] then
                                processSpawnedDroid(returnedEntity, true, station.position)
                            else
                                script.raise_event(defines.events.on_entity_spawned, {entity = returnedEntity, spawner = station})
                            end
                        end
                    end
                end

                --look for enemies to actively respond to within keep-clear range. note uses keep-clear radius, or modified hunt radius from connected settings module.
                local enemy = station.surface.find_nearest_enemy({position= station.position, max_distance = huntRadius, force=station.force})

                if (enemy and enemy.valid ) then

                    for index, unit in pairs(memberTable) do

                        if unit.valid then
                            local command =  unit.has_command()
                            if not command or command == false then


                                    local attackCommand = {type=defines.command.attack_area, destination=enemy.position, radius=32, distraction=defines.distraction.by_damage}
                                    local stopCommand = {type=defines.command.stop}
                                    local commandList = {attackCommand, stopCommand}

                                    unit.set_command({type= defines.command.compound, structure_type = defines.compound_command.logical_and, commands = commandList })

                            end
                        end

                    end --end for each unit in the member table

                end --end if the enemy target is found, and is valid.

                -- if we have no enemy in sight, then try to recall wandering/straying units.
                if not enemy or not enemy.valid then
                    for index, unit in pairs(memberTable) do

                        if unit.valid then
                            local command =  unit.has_command()
                            if not command or command == false then

                                    unit.set_command({type=defines.command.attack_area,
                                                            destination=station.position,
                                                            radius=32,
                                                            distraction=defines.distraction.by_damage})

                            end
                        end

                    end --end for each unit in the member table


                end


            end
        end --end for each station in the guard station table for the force..
    end --end if checking global guard stations table exists
end -- end processDroidGuardStations()

function updateSelectionCircles(force)
	global.selection_circles = global.selection_circles or {}
	global.selection_circles[force.name] = global.selection_circles[force.name] or {}

	if not global.selected_squad or global.selected_squad[force.name] then return end

	local squad_id = global.selected_squad[force.name]
	if(squad_id) then
		local squad = global.Squads[force.name][squad_id]
		for _, unit in pairs(squad.unitGroup.members) do
			if unit and unit.valid then
				if not global.selection_circles[force.name][unit.unit_number] then
				   -- make it
				   --unit.surface.create_entity( name = "selection-sticker", position = unit.position , target= unit)
				end
			else
			 --remove the sticker
				for _,e in pairs(unit.surface.find_entities_filtered{type="sticker", area=unit.bounding_box}) do
					e.destroy()
				end

			end

		end

	end

end

function tickForces(tick)
    local forces = game.forces
    for _, force in pairs(forces) do
        if force.name ~= "enemy" and force.name ~= "neutral" then
            if tick % ASSEMBLER_UPDATE_TICKRATE == 0 then
                processDroidAssemblers(force)
                processDroidGuardStations(force)
            end
            processDroidAssemblersForTick(force, tick)
            processSquadUpdatesForTick(force.name, tick % 60 + 1)

            if tick % 1200 == 0 then
                log_session_statistics(force)
            end

            if( tick % 5 == 0) then
                updateSelectionCircles(force)
            end

        end
    end
end


CHECK_FOR_NEAREST_ENEMY_TO_ASSEMBLER_EVERY = 600 -- in ticks

function processDroidAssemblersForTick(force, tick)
    local forceAssemblerRetreatTable = global.AssemblerRetreatTables[force.name]
    if not forceAssemblerRetreatTable then return end -- Checks if the assembler retreat table for that force actually exists
    for assemblerIdx, squads in pairs(forceAssemblerRetreatTable) do
        if assemblerIdx % ASSEMBLER_MERGE_TICKRATE == tick % ASSEMBLER_MERGE_TICKRATE then
            local assembler = global.DroidAssemblers[force.name][assemblerIdx]
            if assembler then
                if (not assembler.valid or not checkRetreatAssemblerForMergeableSquads(assembler, squads)) then
                    -- don't iterate over this assembler again until it is 'recreated'
                    -- by a squad trying to retreat to it
                    forceAssemblerRetreatTable[assemblerIdx] = nil
                end
                if settings.global["Attack Targeting Type"].value == targetingTypes.hybridKeepRadiusClear then
                    if assembler.valid then
                        local ANEtable = global.AssemblerNearestEnemies[force.name][assemblerIdx]
                        if game.tick > ANEtable.lastChecked + CHECK_FOR_NEAREST_ENEMY_TO_ASSEMBLER_EVERY then
                            findAssemblerNearestEnemies(assembler, ANEtable)
                        end
                    else
                        global.AssemblerNearestEnemies[force.name][assemblerIdx] = nil
                    end
                end
            else
                -- clean up assembler that no longer exists
                global.DroidAssemblers[force.name][assemblerIdx] = nil
                forceAssemblerRetreatTable[assemblerIdx] = nil
            end
        end
    end
end

-- ACTUAL HANDLERS START HERE   vvvvv


function handleOnBuiltEntity(event)
    local entity = event.created_entity

    if(entity.name == "droid-assembling-machine") then
        handleDroidAssemblerPlaced(event)
    elseif(entity.name == "droid-guard-station") then
        handleGuardStationPlaced(event)
    elseif(entity.name == "droid-counter") then
        handleBuiltDroidCounter(event)
    elseif(entity.name == "droid-settings") then
        handleBuiltDroidSettings(event)
    elseif entity.name == "loot-chest" then
        handleBuiltLootChest(event)
    elseif entity.name == "rally-beacon" then
        handleBuiltRallyBeacon(event)
    elseif entity.name == "construction-warehouse" then
        if not global.ConstructionWarehouses then global.ConstructionWarehouses = {} end
        if not global.ConstructionWarehouses[entity.force.name] then global.ConstructionWarehouses[entity.force.name] = {} end
        table.insert(global.ConstructionWarehouses[entity.force.name], entity)
    elseif entity.type == "unit" then --squadCapable is defined in DroidUnitList.

        local entity = event.created_entity
		local player = game.players[event.player_index]
        handleUnitBuilt(event, entity, player)

    end
end -- handleOnBuiltEntity


function handleOnRobotBuiltEntity(event)
    local entity = event.created_entity
    if(entity.name == "droid-assembling-machine") then
        handleDroidAssemblerPlaced(event)
    elseif(entity.name == "droid-guard-station") then
        handleGuardStationPlaced(event)
    elseif(entity.name == "droid-counter") then
        handleBuiltDroidCounter(event)
    elseif(entity.name == "droid-settings") then
        handleBuiltDroidSettings(event)
    elseif entity.name == "rally-beacon" then
        handleBuiltRallyBeacon(event)
    elseif entity.name == "loot-chest" then
        handleBuiltLootChest(event)
    end
end -- handleOnRobotBuiltEntity


-- MAIN ENTRY POINT IN-GAME
-- during the on-tick event, lets check if we need to update squad AI, spawn droids from assemblers, or update bot counters, etc
function handleTick(event)
    tickForces(event.tick)
end -- handleTick

function botCounterUpdates(event)
       -- doCounterUpdate()
       -- checkSettingsModules()
end

function handleForceCreated(event)
    force = event.force
    LOGGER.log(string.format("New force detected... %s",force.name) )
    global.DroidAssemblers = global.DroidAssemblers or {}
    global.DroidAssemblers[force.name] = {}

    global.AssemblerNearestEnemies = global.AssemblerNearestEnemies or {}
    global.AssemblerNearestEnemies[force.name] = {}

    global.Squads = global.Squads or {}
    global.Squads[force.name] = {}

    global.uniqueSquadId = global.uniqueSquadId or {}
    global.uniqueSquadId[force.name] = 1

    global.lootChests = global.lootChests or {}
    global.lootChests[force.name] = {}

    global.droidCounters = global.droidCounters or {}
    global.droidCounters[force.name] = {}

    global.droidGuardStations = global.droidGuardStations or {}
    global.droidGuardStations[force.name] = {}

    global.rallyBeacons = global.rallyBeacons or {}
    global.rallyBeacons[force.name] = {}

     --set up the tick tables for this new force
    global.updateTable = global.updateTable or {}
    if not global.updateTable[force.name] then global.updateTable[force.name] = {} end

       --check if the table has the 1st tick in it. if not, then go through and fill the table
    if not global.updateTable[force.name][1] then
        fillTableWithTickEntries(global.updateTable[force.name]) -- make sure it has got the 1-60 tick entries initialized
    end
    global_ensureTablesExist()
    global_fixupTickTablesForForceName(force.name) -- run this at the end just to make sure all other tables I missed are added properly.. mostly for tick and retreat handling

    LOGGER.log("New force handler finished...")
end

--registered to script.on_configuration_changed
function handleModChanges()

    LOGGER.log("Running first tick migrations... config changed!")

    local forces = game.forces



    runOnceCheck(forces)
    global_ensureTablesExist()
    ses_statistics.sessionStartTick = game.tick

    for fkey, force in pairs(forces) do
        if force.name ~= "enemy" and force.name ~= "neutral" then
            migrateForce(fkey, force)
        end
    end

    --check if we have grab artifacts enabled - if we do, but it was added after the game started, and the force has military 1 researched
    --then lets force the recipe to be enabled (because they have missed the usual trigger)
    if(GRAB_ARTIFACTS == 1) then
        for fkey, force in pairs(forces) do
            if(force.technologies["military"].researched == true) then
                force.recipes["loot-chest"].enabled = true
            end
        end
    else  -- else force-disable it if it's been disabled part-way through a game.
        for fkey, force in pairs(forces) do
            force.recipes["loot-chest"].enabled = false
        end

    end

end


--each force has this function called on it. process force's list of construction units.
function processConstructionUnits(force)

    if global.Constructors and global.Constructors[force.name] then
        --for each constructor in the force's list.. process
        for index, constructor in pairs(global.Constructors[force.name]) do
            if constructor and constructor.valid and constructor.force == force then

                --go through the list of constructors and process each one's unique logic function.
                if constructor.name == "basic-constructor" then
                    basicConstructorCheck(constructor)
                end

                --any new constructor units with unique construction logic, run them here.


            end --end if valid, process each constructor for their unique functions.
        end --end for each constructor in force's constructor  list.
    end  --end if global tables exist
end -- end of process construction units


--put any useful logic in here, for checking player spawned units.
function handleUnitBuilt(event, entity, player)
    if not event or not entity or not player then
        game.print("error in RA:handleunitbuilt!")
        return
    end
    --add any list management here for newly spawned units
    -- check if it's an event. if event is nil, then it was a script spawned unit.
    checkIfConstructor(entity)

end

function checkIfConstructor(entity)
    if not entity or entity.valid == false then return end
    if entity.name == "basic-constructor" then
        if not global.Constructors then global.Constructors = {} end
        if not global.Constructors[entity.force.name] then global.Constructors[entity.force.name] = {} end

        table.insert(global.Constructors[entity.force.name], entity)
    end

end


function constructorTickUpdates()  --registered for nth tick in control.lua
    local forces = game.forces
    for _, force in pairs(forces) do

        processConstructionUnits(force)
        --add other construction unit processing functions as required here.

    end
end
