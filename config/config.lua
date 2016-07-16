
TICK_UPDATE_SQUAD_AI = 60 -- 60 ticks per second, how many ticks between updating squad AI (finding new targets, moving back into position, etc)
DEFAULT_SQUAD_RADIUS = 2 -- how wide their attack_area radius is. not really used honestly..
SOLDIER_MAX_AMMO = 100 -- unused, might be used later to simulate having to come back and resupply.
SQUAD_SIZE_MIN_BEFORE_HUNT = 5 -- how many droids are required in a squad before they are commanded to attack nearest target
SQUAD_SIZE_MIN_BEFORE_RETREAT = 2 -- if a squad has been hunting and is down to this amount of guys left, head to nearest droid assembler to get reinforcements.
SQUAD_CHECK_RANGE = 15 -- range in tiles when a droid is spawned to check for existing squad to join, else creates its own squad
ASSEMBLER_UPDATE_TICKRATE = 120 -- how often does the droid assembler building check for spawnable droid items in the output inv. how fast to spawn a droid once it's been assembled.
BOT_COUNTERS_UPDATE_TICKRATE = 60 -- how often does the robot army combinator count droids and update combinator signals?
LONE_WOLF_CLEANUP_SCRIPT_PERIOD = 18000 -- how often to find and deal with droids that are "wanderers" and not in a squad. NOT USED YET
GUARD_STATION_GARRISON_SIZE = 10 -- limit to how many a guard station will spawn based on counting nearby droids

PRINT_SQUAD_DEATH_MESSAGES = 1

--CONFIG SETTINGS FOR THOSE WHO WANT TO SCALE THE DAMAGE AND HEALTH OF DROIDS
HEALTH_SCALAR = 1.0 -- scales health by this value, default 1.0. 0.5 gives 50% health, 2.0 doubles their health etc.

DAMAGE_SCALAR = 1.0 -- scales base damage by this value. default is 1.0. 0.5 makes 50% less base damage. 
					-- 1.5 gives 50% more base damage. remember, technologies apply multipliers to the base damage so this value should take 
					-- that into consideration.
					
ARTIFACT_GRAB_RADIUS = 30