
TICK_UPDATE_SQUAD_AI = 60 -- 60 ticks per second, how many ticks between updating squad AI (finding new targets, moving back into position, etc)
DEFAULT_SQUAD_RADIUS = 2 -- how wide their attack_area radius is. not really used honestly..
SOLDIER_MAX_AMMO = 100 -- unused, might be used later to simulate having to come back and resupply.
SQUAD_SIZE_MIN_BEFORE_HUNT = 10 -- how many droids are required in a squad before they are commanded to attack nearest target.
								-- override-able from settings combinator
SQUAD_SIZE_MIN_BEFORE_RETREAT = 2 -- if a squad has been hunting and is down to this amount of guys left, head to nearest droid assembler for backup.
								  -- override-able from settings combinator
SQUAD_CHECK_RANGE = 20 -- range in tiles when a droid is spawned to check for existing squad to join, else creates its own squad
SQUAD_HUNT_RADIUS = 5000 -- range in tiles, as a radius from squad. override-able from settings combinator
AT_ASSEMBLER_RANGE = 20 -- range in tiles where we consider a droid or squad to be 'at' an assembler.
MERGE_RANGE = 20

ASSEMBLER_UPDATE_TICKRATE = 120 -- how often does the droid assembler building check for spawnable droid items in the output inv.
								-- how fast to spawn a droid once it's been actually assembled.

BOT_COUNTERS_UPDATE_TICKRATE = 60 -- how often does the robot army combinator count droids and update combinator signals?
LONE_WOLF_CLEANUP_SCRIPT_PERIOD = 18000 -- how often to find and deal with droids that are "wanderers" and not in a squad. NOT USED YET
GUARD_STATION_GARRISON_SIZE = 10 -- limit to how many a guard station will spawn based on counting nearby droids

USE_TELEPORTATION_FIX = 1
SANITY_CHECK_PERIOD_SECONDS = 120
SANITY_CHECK_PATH_DISTANCE_DIV_FACTOR = 500 -- every extra 500 tiles should give us an extra SANITY_CHECK_PERIOD_SECONDS
PRINT_SQUAD_DEATH_MESSAGES = 1
-- PRINT_SQUAD_MERGE_MESSAGES = 0
ASSEMBLER_MERGE_TICKRATE = 180

SQUAD_UNITGROUP_FAILURE_DISTANCE_ESTIMATE = 40
MAX_CONSECUTIVE_UNITGROUP_FAILURES_BEFORE_RETREAT = 2

ASSEMBLER_CENTRIC_TARGETING = 1

--CONFIG SETTINGS FOR THOSE WHO WANT TO SCALE THE DAMAGE AND HEALTH OF DROIDS
HEALTH_SCALAR = 1.0 -- scales health by this value, default 1.0. 0.5 gives 50% health, 2.0 doubles their health etc.

DAMAGE_SCALAR = 1.0 -- scales base damage by this value. default is 1.0. 0.5 makes 50% less base damage.
					-- 1.5 gives 50% more base damage. remember, technologies apply multipliers to the base damage so this value should take
					-- that into consideration.

ARTIFACT_GRAB_RADIUS = 30
GUARD_POLE_CONNECTION_RANGE = 30 -- this is for electrical connection range and therefore spacing of patrol poles, checking range is.

PLAYER_VIEW_RADIUS = 60  -- this is very simplistic, but it's a start.
