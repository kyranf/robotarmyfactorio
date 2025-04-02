require("config.config")
require("util")
require("robolib.Squad")
require("robolib.util")
require("robolib.retreat")
require("stdlib/log/logger")
require("stdlib/game")
require("robolib.targeting")

function updateSquad(squad)
    if squadStillExists(squad) then -- if not, that means this squad has been deleted
        --LOGGER.log(string.format( "AI for squadref %d in tick table index %d is being executed now...", squadref, tickProcessIndex) )
        --CHECK IF SQUAD IS A GUARD SQUAD, AND CHOOSE WHICH AI FUNCTION TO CALL
        if squad.command.type == commands.guard then
            executeGuardAI(squad)
        elseif not squad.rally then
            if not script.active_mods["Unit_Control"] then
                executeBattleAI(squad)
            end
        else
            squad = validateSquadIntegrity(squad)
        end

        --revealChunksBySquad(squad)   -- NOW HANDLED BY UNIT PROTOTYPES WITH radar_range = 1.
        if (GRAB_ARTIFACTS == 1) then
            grabArtifactsBySquad(squad) --disabled as of 0.15 where alien artifacts are no longer dropped!
        end
    end
end

function executeBattleAI(squad)
    local attacking = isAttacking(squad)
    if attacking then
        -- squad.command.state_changed_since_last_command = true
        if not squad.command.state_changed_since_last_command then
            squad.command.state_changed_since_last_command = true
            LOGGER.log(string.format("Squad %d is attacking - once it no longer is attacking, it will need an order.", squad.squadID))
        end
    end
    if (not attacking) and (squad.command.state_changed_since_last_command or squadOrderNeedsRefresh(squad)) then
        squad, issue_command = validateSquadIntegrity(squad)
        if not squad or not issue_command then return end
        LOGGER.log(string.format("Squad %d Needs orders of some kind (last: %d) at tick %d",
                                 squad.squadID, squad.command.type, game.tick))
        if shouldHunt(squad) then
            orderSquadToHunt(squad)
        else
            orderSquadToRetreat(squad)
        end
    end
end

function orderSquadToHunt(squad)
    local target = chooseTarget(squad)
    if target then
        orderSquadToAttack(squad, target.position)
    else
        orderSquadToWander(squad, squad.unitGroup.position)
    end
end

function executeGuardAI(squad)
    local surface = getSquadSurface(squad)

    if not surface then
        --LOGGER.log(string.format("ERROR: Surface for squad ID %d is missing or can't be determined! guardAIUpdate", squad.squadID))
        return
    end

    if squad.command.tick + SANITY_CHECK_PERIOD_SECONDS * 60 < game.tick then
        -- validate, but then wait a while before validating again
        squad.command.tick = game.tick
        validateSquadIntegrity(squad)
    end
    
end
