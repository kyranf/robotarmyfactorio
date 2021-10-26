local ICONPATH = "__robotarmy__/graphics/icons/"
local BUILPATH = "__robotarmy__/graphics/entity/buildings/"

require("config.config")


circuit_connector_definitions["droid_assem"] = circuit_connector_definitions.create
(
  universal_connector_template,
  {
    {
      variation = 18,
      main_offset = util.by_pixel(2.5, 18.0),
      shadow_offset = util.by_pixel(2.0, 18.0),
      show_shadow = false
    },
  }
)


circuit_connector_definitions["loot_box"] = circuit_connector_definitions.create
(
  universal_connector_template,
  {
    {
      variation = 18,
      main_offset = util.by_pixel(2.5, 18.0),
      shadow_offset = util.by_pixel(2.0, 18.0),
      show_shadow = false
    }
  }
)

local droidAssembler = {
  type = "container",
  name = "droid-assembling-machine",
  icon_size = 64,
  is_deployer = true,
  icon = ICONPATH .. "droid-assembling-machine.png",
  flags = {"placeable-neutral", "placeable-player", "player-creation"},
  minable = {hardness = 0.2, mining_time = 0.5, result = "droid-assembling-machine"},
  max_health = 400,
  corpse = "big-remnants",
  dying_explosion = "medium-explosion",
  resistances =
  {
    {type = "fire", percent = 70},
    {type = "acid", percent = 70}
  },
  collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
  selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
  fast_replaceable_group = "",
  inventory_size = 4,
  picture =
  {
    layers =
    {
      {
        filename = BUILPATH .. "droid-assembler.png",
        width = 156,
        height = 139,
        hr_version = {
          filename = BUILPATH .. "hr-droid-assembler.png",
          width = 312,
          height = 278,
          scale = 0.5,
        }
      },
      {
        filename = BUILPATH .. "droid-assembler-shadow.png",
        width = 156,
        height = 139,
        draw_as_shadow = true,
        hr_version = {
          filename = BUILPATH .. "hr-droid-assembler-shadow.png",
          width = 312,
          height = 278,
          draw_as_shadow = true,
          scale = 0.5,
        }
      }
    }
  },
  open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
  close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
  vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
  circuit_wire_connection_point =
  {
    shadow =
    {
      red = {0.734375, 0.453125},
      green = {0.609375, 0.515625},
    },
    wire =
    {
      red = {0.40625, 0.21875},
      green = {0.40625, 0.375},
    }
  },
  circuit_wire_connection_point = circuit_connector_definitions["droid_assem"].points,
  circuit_connector_sprites = circuit_connector_definitions["droid_assem"].sprites,
  circuit_wire_max_distance = 7.5
}

local guardStation = {
  type = "container",
  name = "droid-guard-station",
  icon_size = 64,
  icon = ICONPATH .. "droid-guard-station.png",
  flags = {"placeable-neutral", "placeable-player", "player-creation"},
  minable = {hardness = 0.2, mining_time = 0.5, result = "droid-guard-station"},
  max_health = 400,
  is_deployer = true,
  corpse = "big-remnants",
  dying_explosion = "medium-explosion",
  resistances =
  {
    {
      type = "fire",
      percent = 70
    },
    {
      type = "acid",
      percent = 70
    }
  },
  collision_box = {{-1.7, -1.7}, {1.7, 1.7}},
  selection_box = {{-2, -2}, {2, 2}},
  picture =
  {
    layers =
    {
      {
        filename = BUILPATH .. "guard-station.png",
        width = 208,
        height = 228,
        hr_version = {
          filename = BUILPATH .. "hr-guard-station.png",
          width = 416,
          height = 456,
          scale = 0.5,
        }
      },
      {
        filename = BUILPATH .. "guard-station-shadow.png",
        width = 208,
        height = 228,
        draw_as_shadow = true,
        hr_version = {
          filename = BUILPATH .. "hr-guard-station-shadow.png",
          width = 416,
          height = 456,
          draw_as_shadow = true,
          scale = 0.5,
        }
      }
    }
  },
  fast_replaceable_group = "",
  inventory_size = 4,
  open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
  close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
  vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
  circuit_wire_connection_point =
  {
    shadow =
    {
      red = {0.734375, 0.453125},
      green = {0.609375, 0.515625},
    },
    wire =
    {
      red = {0.40625, 0.21875},
      green = {0.40625, 0.375},
    }
  },
  circuit_wire_connection_point = circuit_connector_definitions["droid_assem"].points,
  circuit_connector_sprites = circuit_connector_definitions["droid_assem"].sprites,
  circuit_wire_max_distance = 7.5
}

local patrolPole = {
  type = "electric-pole",
  name = "patrol-pole",
  icon_size = 64,
  icon = ICONPATH .. "patrol-pole.png",
  flags = {"placeable-neutral", "player-creation"},
  minable = {hardness = 0.2, mining_time = 0.5, result = "patrol-pole"},
  max_health = 1000,
  corpse = "small-remnants",
  resistances =
  {
    {
      type = "fire",
      percent = 100
    }
  },
  collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
  drawing_box = {{-0.5, -2.8}, {0.5, 0.5}},
  maximum_wire_distance = GUARD_POLE_CONNECTION_RANGE,
  supply_area_distance = 0,
  vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
  pictures =
  {
    layers = {
      {
        filename = BUILPATH .. "patrol-pole.png",
        priority = "high",
        width = 136,
        height = 122,
        tint = {r=1.0, g=0.9, b=0.9, a=0.8},
        direction_count = 1,
        shift = {1.4, -1.0},
        hr_version = {
          filename = BUILPATH .. "hr-patrol-pole.png",
          priority = "high",
          width = 272,
          height = 244,
          tint = {r=1.0, g=0.9, b=0.9, a=1},
          direction_count = 1,
          shift = {1.4, -1.0},
          scale = 0.5,
        }
      },
      {
        filename = BUILPATH .. "patrol-pole-shadow.png",
        priority = "high",
        width = 136,
        height = 122,
        direction_count = 1,
        shift = {1.4, -1.0},
        draw_as_shadow = true,
        hr_version = {
          filename = BUILPATH .. "hr-patrol-pole-shadow.png",
          priority = "high",
          width = 272,
          height = 244,
          direction_count = 1,
          shift = {1.4, -1.0},
          draw_as_shadow = true,
          scale = 0.5,
        }
      },
    }
  },
  connection_points =
  {
    {
      shadow =
      {
        copper = {2.55, 0.4},
        green = {2.0, 0.4},
        red = {3.05, 0.4}
      },
      wire =
      {
        copper = {-0.03125, -2.46875},
        green = {-0.34375, -2.46875},
        red = {0.25, -2.46875}
      }
    }
  },
  radius_visualisation_picture =
  {
    filename = "__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png",
    width = 12,
    height = 12,
    priority = "extra-high-no-scale"
  },
}

local construction_warehouse = {
  type = "container",
  name = "construction-warehouse",
  icon_size = 64,
  icon = ICONPATH .. "droid-construction_warehouse.png",
  flags = {"placeable-neutral", "placeable-player", "player-creation"},
  minable = {hardness = 0.2, mining_time = 1, result = "construction-warehouse"},
  max_health = 400,
  corpse = "big-remnants",
  open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.65 },
  close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
  resistances =
  {
    {
      type = "fire",
      percent = 90
    },
    {
      type = "acid",
      percent = 70
    }
  },
  collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
  selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
  fast_replaceable_group = "",
  inventory_size = 40,
  vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
  picture =
  {
    layers =
    {
      {
        filename = BUILPATH .. "construction_warehouse.png",
        width = 156,
        height = 139,
        shift = {0, 0},
        hr_version = {
          filename = BUILPATH .. "hr-construction_warehouse.png",
          width = 312,
          height = 278,
          shift = {0, 0},
          scale = 0.5,
        }
      },
      {
        filename = BUILPATH .. "construction_warehouse-shadow.png",
        width = 156,
        height = 139,
        shift = {0, 0},
        draw_as_shadow = true,
        hr_version = {
          filename = BUILPATH .. "hr-construction_warehouse-shadow.png",
          width = 312,
          height = 278,
          shift = {0, 0},
          draw_as_shadow = true,
          scale = 0.5,
        }
      },
    }
  },
  circuit_wire_connection_point =
  {
    shadow =
    {
      red = {0.734375, 0.453125},
      green = {0.609375, 0.515625},
    },
    wire =
    {
      red = {0.40625, 0.21875},
      green = {0.40625, 0.375},
    }
  }
}

local ledsprites =
{
  filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-N.png",
  width = 8,
  height = 6,
  frame_count = 1,
  shift = util.by_pixel(9, -12),
  hr_version =
  {
    scale = 0.5,
    filename = "__base__/graphics/entity/combinator/activity-leds/hr-constant-combinator-LED-N.png",
    width = 14,
    height = 12,
    frame_count = 1,
    shift = util.by_pixel(9, -11.5),
  },
}

local circuit_wire_connection_points =
{
  shadow =
  {
    red = {0.15625, -0.28125},
    green = {0.65625, -0.25}
  },
  wire =
  {
    red = {-0.28125, -0.5625},
    green = {0.21875, -0.5625},
  }
}

local droid_counter = {
  type = "constant-combinator",
  name = "droid-counter",
  icon_size = 64,
  icon = ICONPATH .. "droid-counter.png",
  flags = {"placeable-neutral", "player-creation"},
  minable = {hardness = 0.2, mining_time = 0.5, result = "droid-counter"},
  max_health = 50,
  corpse = "small-remnants",
  collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
  item_slot_count = 7,
  sprites =
  {
    layers =
    {
      {
        filename = BUILPATH .. "droid-counter.png",
        width = 64,
        height = 64,
        hr_version =
        {
          filename = BUILPATH .. "hr-droid-counter.png",
          width = 128,
          height = 128,
          scale = 0.5,
        }
      },
      {
        filename = BUILPATH .. "droid-counter-shadow.png",
        width = 64,
        height = 64,
        draw_as_shadow = true,
        hr_version =
        {
          filename = BUILPATH .. "hr-droid-counter-shadow.png",
          width = 128,
          height = 128,
          draw_as_shadow = true,
          scale = 0.5,
        }
      },
    },
  },
  activity_led_sprites =
  {
    north = ledsprites,
    east = ledsprites,
    south = ledsprites,
    west = ledsprites,
  },
  activity_led_light =
  {
    intensity = 0.8,
    size = 1,
    color = {r = 1.0, g = 1.0, b = 1.0}
  },
  activity_led_light_offsets =
  {
    {0.234375, -0.484375},
    {0.234375, -0.484375},
    {0.234375, -0.484375},
    {0.234375, -0.484375},
  },
  circuit_wire_connection_points =
  {
    circuit_wire_connection_points,
    circuit_wire_connection_points,
    circuit_wire_connection_points,
    circuit_wire_connection_points,
  },
  circuit_wire_max_distance = 10
}

local droid_settings = {
  type = "constant-combinator",
  name = "droid-settings",
  icon_size = 64,
  icon = ICONPATH .. "droid-settings.png",
  flags = {"placeable-neutral", "player-creation"},
  minable = {hardness = 0.2, mining_time = 0.5, result = "droid-settings"},
  max_health = 50,
  corpse = "small-remnants",
  collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
  item_slot_count = 6,
  sprites =
  {
    layers =
    {
      {
        filename = BUILPATH .. "droid-settings.png",
        width = 64,
        height = 64,
        hr_version =
        {
          filename = BUILPATH .. "hr-droid-settings.png",
          width = 128,
          height = 128,
          scale = 0.5,
        }
      },
      {
        filename = BUILPATH .. "droid-settings-shadow.png",
        width = 64,
        height = 64,
        draw_as_shadow = true,
        hr_version =
        {
          filename = BUILPATH .. "hr-droid-settings-shadow.png",
          width = 128,
          height = 128,
          draw_as_shadow = true,
          scale = 0.5,
        }
      },
    },
  },
  activity_led_sprites =
  {
    north = ledsprites,
    east = ledsprites,
    south = ledsprites,
    west = ledsprites,
  },
  activity_led_light =
  {
    intensity = 0.8,
    size = 1,
  },
  activity_led_light_offsets =
  {
    {0.296875, -0.40625},
    {0.296875, -0.40625},
    {0.296875, -0.40625},
    {0.296875, -0.40625},
  },
  circuit_wire_connection_points =
  {
    circuit_wire_connection_points,
    circuit_wire_connection_points,
    circuit_wire_connection_points,
    circuit_wire_connection_points,
  },
  circuit_wire_max_distance = 10
}

local loot_chest = {
  type = "container",
  name = "loot-chest",
  icon_size = 64,
  icon = ICONPATH .. "loot-chest.png",
  flags = {"placeable-neutral", "player-creation"},
  minable = {mining_time = 1, result = "loot-chest"},
  max_health = 400,
  corpse = "small-remnants",
  open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.65 },
  close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
  resistances =
  {
    {type = "fire", percent = 90}
  },
  collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
  fast_replaceable_group = "",
  inventory_size = 48,
  vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
  picture =
  {
    layers =
    {
      {
        filename = BUILPATH .. "loot-chest.png",
        width = 33,
        height = 38,
        shift = util.by_pixel(0, 0),
        hr_version =
        {
          filename = BUILPATH .. "hr-loot-chest.png",
          width = 66,
          height = 76,
          shift = util.by_pixel(-0.5, -0.5),
          scale = 0.5,
        }
      },
      {
        filename = BUILPATH .. "loot-chest-shadow.png",
        width = 55,
        height = 25,
        draw_as_shadow = true,
        shift = util.by_pixel(12, 8),
        hr_version =
        {
          filename = BUILPATH .. "hr-loot-chest-shadow.png",
          width = 110,
          height = 50,
          draw_as_shadow = true,
          shift = util.by_pixel(12.5, 8),
          scale = 0.5,
        }
      },
    },
  },
  circuit_wire_connection_point =
  {
    shadow =
    {
      red = {0.734375, 0.453125},
      green = {0.609375, 0.515625},
    },
    wire =
    {
      red = {0.40625, 0.21875},
      green = {0.40625, 0.375},
    }
  },
  circuit_wire_connection_point = circuit_connector_definitions["loot_box"].points,
  circuit_connector_sprites = circuit_connector_definitions["loot_box"].sprites,
  circuit_wire_max_distance = 7.5
}

local selection_sticker = {
  type = "sticker",
  name = "selection-sticker",
  flags = {"not-on-map"},
  icon_size = 64,
  icon = ICONPATH .. "unit-selection.png",
  animation =
  {
    filename = ICONPATH .. "unit-selection.png",
    priority = "extra-high",
    width = 32,
    height = 32,
    frame_count = 1,
    animation_speed = 1
  },
  duration_in_ticks = 3000 * 60,
  target_movement_modifier = 0.9999
}


 data:extend({droidAssembler, guardStation, patrolPole, construction_warehouse, droid_counter, droid_settings, loot_chest, selection_sticker})