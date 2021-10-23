--[[
  SQUAD_SIZE_MIN_BEFORE_HUNT = 10
  SQUAD_SIZE_MIN_BEFORE_RETREAT = 2
  SQUAD_HUNT_RADIUS = 5000
  GUARD_STATION_GARRISON_SIZE = 10
  AT_ASSEMBLER_RANGE = 20
  MERGE_RANGE = 20
  ASSEMBLER_UPDATE_TICKRATE = 120
  CONSTRUCTOR_UPDATE_TICKRATE = 60
  CONSTRUCTION_CHECK_RADIUS = 12

  AUTO_REPAIR_RANGE = 16

  ASSEMBLER_MERGE_TICKRATE = 180
  GLOBAL_TARGETING_TYPE = 3
  DEFAULT_KEEP_RADIUS_CLEAR = 500
  HEALTH_SCALAR= 1.0
  DAMAGE_SCALAR = 1.0
]]

data:extend({
  {
    type = "int-setting",
    name = "Squad Hunt Size",
    setting_type = "runtime-global",
    default_value = 10,
    minimum_value  = 1,
    maximum_value = 50,
  },
  {
    type = "int-setting",
    name = "Squad Retreat Size",
    setting_type = "runtime-global",
    default_value = 2,
    minimum_value  = 1,
    maximum_value = 50,
  },
  {
    type = "int-setting",
    name = "Squad Hunt Radius",
    setting_type = "runtime-global",
    default_value = 5000,
    minimum_value  = 1,
    maximum_value = 15000,
  },
  {
    type = "int-setting",
    name = "Guard Station Garrison Size",
    setting_type = "runtime-global",
    default_value = 10,
    minimum_value  = 1,
    maximum_value = 50,
  },
  {
    type = "int-setting",
    name = "Squad Keep Clear Radius",
    setting_type = "runtime-global",
    default_value = 500,
    minimum_value  = 1,
    maximum_value = 15000,
  },
  {
    type = "int-setting",
    name = "Attack Targeting Type",
    setting_type = "runtime-global",
    default_value = 3,
    minimum_value  = 1,
    maximum_value = 3,
    allowed_values = {1,2,3}
  },
  {
    type = "double-setting",
    name = "Droid Health Modifier",
    setting_type = "startup",
    default_value = 1.0,
    minimum_value  = 0.01,
    maximum_value = 100.0
  },
  {
    type = "double-setting",
    name = "Droid Damage Modifier",
    setting_type = "startup",
    default_value = 1.0,
    minimum_value  = 0.01,
    maximum_value = 100.0
  },
  {
    type = "int-setting",
    name = "Engineer Droid Repair Range",
    setting_type = "runtime-global",
    default_value = 16,
    minimum_value  = 1,
    maximum_value = 128
  },
  {
    type = "int-setting",
    name = "Engineer Droid Construction Check Radius",
    setting_type = "runtime-global",
    default_value = 32,
    minimum_value  = 1,
    maximum_value = 128
  },
  {
    type = "int-setting",
    name = "Counter Update Tickrate",
    setting_type = "runtime-global",
    default_value = 60,
    minimum_value  = 1,
    maximum_value = 600
  },
  {
    type = "bool-setting",
    name = "Print Squad Death Messages",
    setting_type = "runtime-global",
    default_value = true
  },
})
