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

LOGGER = Logger.new("robotarmy", "robot_army_logs", true, {log_ticks = true})

global.runOnce = false

function init_robotarmy()
    LOGGER.log("Robot Army mod Init script running...")

    if not global.Squads then
        global.Squads = {}
    end

    if not global.uniqueSquadId then
        global.uniqueSquadId = {}
    end

    if not global.DroidAssemblers then
        global.DroidAssemblers = {}
    end

    if not global.droidCounters then
        global.droidCounters = {}
    end

    if not global.lootChests then
        global.lootChests = {}
    end

    if not global.rallyBeacons then
        global.rallyBeacons = {}
    end

    if not global.droidGuardStations then
        global.droidGuardStations = {}
    end

    if not global.updateTable then
        global.updateTable = {}
    end

    --deal with player force as default set-up process

    handleForceCreated(game.forces["player"])
    handleForceCreated(game.forces["enemy"])
    handleForceCreated(game.forces["neutral"])
    LOGGER.log("Robot Army mod Init script finished...")
end


script.on_init(init_robotarmy)

script.on_event(defines.events.on_force_created, handleForceCreated)
script.on_event(defines.events.on_built_entity, handleOnBuiltEntity)
script.on_event(defines.events.on_robot_built_entity, handleOnRobotBuiltEntity)

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
