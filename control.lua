require("util")
require("config.config") -- config for squad control mechanics - important for anyone using
require("robolib.util") -- some utility functions not necessarily related to robot army mod
require("robolib.robotarmyhelpers") -- random helper functions related to the robot army mod
require("robolib.Squad") -- allows us to control squads, add entities to squads, etc.
require("robolib.eventhandlers")
require("robolib.onload")
require("prototypes.DroidUnitList") -- so we know what is spawnable
require("stdlib/log/logger")
require("stdlib/game")

LOGGER = Logger.new("robotarmy", "robot_army_logs", false, {log_ticks = false})

storage.runOnce = false

function init_robotarmy()
    LOGGER.log("Robot Army mod Init script running...")

    if not storage.Squads then
        storage.Squads = {}
    end

    if not storage.uniqueSquadId then
        storage.uniqueSquadId = {}
    end

    if not storage.DroidAssemblers then
        storage.DroidAssemblers = {}
    end

    if not storage.droidCounters then
        storage.droidCounters = {}
    end

    if not storage.lootChests then
        storage.lootChests = {}
    end

    if storage.rallyBeacons then
        storage.rallyBeacons = nil
    end

    if not storage.droidGuardStations then
        storage.droidGuardStations = {}
    end

    if not storage.updateTable then
        storage.updateTable = {}
    end

    if not storage.units then
        storage.units = {}
    end

    --deal with player force as default set-up process
    event = {} --event stub, to match function inputs
    for _, v in pairs(game.forces) do
        event.force = v
        handleForceCreated(event)
    end
    LOGGER.log("Robot Army mod Init script finished...")
    game.print("Robot Army mod Init completed!")
end


script.on_init(init_robotarmy)

script.on_event(defines.events.on_force_created, handleForceCreated)
script.on_event(defines.events.on_built_entity, handleOnBuiltEntity)
script.on_event(defines.events.on_robot_built_entity, handleOnRobotBuiltEntity)
script.on_event(defines.events.script_raised_built, handleOnScriptRaisedBuilt)

-- QRF: Listen for entity death events
script.on_event(defines.events.on_entity_died, handleOnEntityDied)
script.on_event(defines.events.on_ai_command_completed, AiCommandCompleteHandler)

function playerSelectedArea(event)
    reportSelectedUnits(event, false)
end

function playerAltSelectedArea(event)
    reportSelectedUnits(event, true)
end

script.on_event(defines.events.on_player_selected_area, playerSelectedArea)
script.on_event(defines.events.on_player_alt_selected_area, playerAltSelectedArea)

-- this on tick handler will get replaced on the first tick after 'live' migrations have run
script.on_event(defines.events.on_tick, bootstrap_migration_on_first_tick)
script.on_event(defines.events.on_player_joined_game, onPlayerJoined)
script.on_configuration_changed(handleModChanges)