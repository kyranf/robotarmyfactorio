--session statistics
ses_statistics = {
    sessionStartTick = 0,
    squadsCreated = 0,
    squadsDeleted = 0,
    createUnitGroupSuccesses = 0,
    createUnitGroupFailures = 0,
    soldierUnitGroupDepartures = 0,
    soldierUnitGroupReadds = 0,
    soldierSquadDepartures = 0,
    teleports = 0,
    failedTeleports = 0,
    disbands = 0,
    merges = 0,
    wanders = 0,
    enemySearches = 0,
    commandsIssued = 0,
    unitGroupFailures = 0,
}


function log_session_statistics(force)
    local seconds = (game.tick - ses_statistics.sessionStartTick) / 60 + 1
    local minutes = (game.tick - ses_statistics.sessionStartTick) / 3600 + 1
    local totals_msg = string.format(
        "TOTALS: sc %d, sd %d, cugf %d, sugd %d, sugr %d, ssd %d, t %d, ft %d, d %d, m %d, w %d, ES %d, cmds %d, F %d, secs %d",
        ses_statistics.squadsCreated,
        ses_statistics.squadsDeleted,
        ses_statistics.createUnitGroupFailures,
        ses_statistics.soldierUnitGroupDepartures,
        ses_statistics.soldierUnitGroupReadds,
        ses_statistics.soldierSquadDepartures,
        ses_statistics.teleports,
        ses_statistics.failedTeleports,
        ses_statistics.disbands,
        ses_statistics.merges,
        ses_statistics.wanders,
        ses_statistics.enemySearches,
        ses_statistics.commandsIssued,
        ses_statistics.unitGroupFailures,
        seconds)
    local rates_msg = string.format(
        "RATE/M: sc %d, sd %d, cugf %d, sugd %d, sugr %d, ssd %d, t %d, ft %d, d %d, m %d, w %d, ES %d, cmds %d, F %d, mins %d",
        ses_statistics.squadsCreated/minutes,
        ses_statistics.squadsDeleted/minutes,
        ses_statistics.createUnitGroupFailures/minutes,
        ses_statistics.soldierUnitGroupDepartures/minutes,
        ses_statistics.soldierUnitGroupReadds/minutes,
        ses_statistics.soldierSquadDepartures/minutes,
        ses_statistics.teleports/minutes,
        ses_statistics.failedTeleports/minutes,
        ses_statistics.disbands/minutes,
        ses_statistics.merges/minutes,
        ses_statistics.wanders/minutes,
        ses_statistics.enemySearches/minutes,
        ses_statistics.commandsIssued/minutes,
        ses_statistics.unitGroupFailures/minutes,
        minutes)
    LOGGER.log(totals_msg)
    LOGGER.log(rates_msg)
    if DEBUG then
        Game.print_force(force, totals_msg)
        Game.print_force(force, rates_msg)
    end
end
