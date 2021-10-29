local ICONPATH = "__robotarmy__/graphics/icons/"
local BOTPATH = "__robotarmy__/graphics/entity/bots/"
local BUILPATH = "__robotarmy__/graphics/entity/buildings/"

-- use the base game's power armour animations/sprites for the droids and terminators
--require("prototypes.droid-animations")
require("config.config")

-- DONT FORGET TO ADD ANY NEW LOCAL TABLE DEFINITIONS TO THE DATA:EXTEND THING AT THE BOTTOM!

droidscale = 0.8 -- droid_rifle

droidSmgTint =  {r=1, g=1, b=1, a=1}
droidFlameTint = {r=1, g=1, b=1, a=1}
droidRocketTint = {r=1, g=1, b=1, a=1}
droidRifleTint = {r=1, g=1, b=1, a=1}

droidMapColour = {r = .05, g = .70, b = .29}


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

local function robotAnimation(sheet, tint, scale)
  return {
    layers = {
      {
        filename = BOTPATH .. sheet .. ".png",
        width = 80,
        height = 80,
        --tint = tint,
        direction_count = 22,
        frame_count = 1,
        animation_speed = 0.01,
        shift = {0, -0.5},
        scale = scale,
        hr_version = {
          filename = BOTPATH .. "hr-" .. sheet .. ".png",
          width = 160,
          height = 160,
          --tint = tint,
          direction_count = 22,
          frame_count = 1,
          animation_speed = 0.01,
          shift = {0, -0.5},
          scale = (scale / 2),
        }
      },
      {
        filename = BOTPATH .. sheet .. "-shadow.png",
        width = 160,
        height = 80,
        direction_count = 22,
        frame_count = 1,
        animation_speed = 0.01,
        shift = {0, -0.5},
        scale = scale,
        draw_as_shadow = true,
        hr_version = {
          filename = BOTPATH .. "hr-" .. sheet .. "-shadow.png",
          width = 320,
          height = 160,
          direction_count = 22,
          frame_count = 1,
          animation_speed = 0.01,
          shift = {0, -0.5},
          scale = (scale / 2),
          draw_as_shadow = true,
        }
      }
    }
  }
end

function make_laser_sounds(volume)
  return {
    {filename = "__base__/sound/fight/laser-1.ogg", volume = 0.7},
    {filename = "__base__/sound/fight/laser-2.ogg", volume = 0.7},
    {filename = "__base__/sound/fight/laser-3.ogg", volume = 0.7}
  }
end

function make_heavy_shot_sounds(volume)
  return {
    {filename = "__base__/sound/fight/heavy-gunshot-1.ogg", volume = 0.45},
    {filename = "__base__/sound/fight/heavy-gunshot-2.ogg", volume = 0.45},
    {filename = "__base__/sound/fight/heavy-gunshot-3.ogg", volume = 0.45},
    {filename = "__base__/sound/fight/heavy-gunshot-4.ogg", volume = 0.45}
  }
end

function make_light_gunshot_sounds(volume)
  return {
    {filename = "__base__/sound/fight/light-gunshot-1.ogg", volume = 0.7},
    {filename = "__base__/sound/fight/light-gunshot-2.ogg", volume = 0.7},
    {filename = "__base__/sound/fight/light-gunshot-3.ogg", volume = 0.7}
  }
end

function make_rifle_gunshot_sounds(volume)
  return {
    {filename = "__base__/sound/fight/light-gunshot-1.ogg", volume = 1},
    {filename = "__base__/sound/fight/light-gunshot-2.ogg", volume = 1},
    {filename = "__base__/sound/fight/light-gunshot-3.ogg", volume = 1}
  }
end

local droid_smg =
{
  type = "unit",
  name = "droid-smg",
  icon_size = 64,
  icon = ICONPATH .. "droid_smg_undep.png",
  flags = {"placeable-player", "player-creation", "placeable-off-grid"},
  subgroup="creatures",
  order="e-a-b-d",
  max_health = 120 * HEALTH_SCALAR,
  has_belt_immunity = true,
  alert_when_damaged = false,
  healing_per_tick = 0.01,
  collision_box = {{-0.8*droidscale, -0.8*droidscale}, {0.8*droidscale, 0.8*droidscale}},
  selection_box = {{-0.8*droidscale, -0.8*droidscale}, {0.8, 0.8*droidscale}},
  sticker_box = {{-0.5, -0.5}, {0.5, 0.5}},
  vision_distance = 30,
  radar_range = 1,
  can_open_gates = true,
  ai_settings =
  {
    allow_destroy_when_commands_fail = false,
    do_separation = true
  },
  movement_speed = 0.11,
  minable = {hardness = 0.1, mining_time = 0.1, result = "droid-smg"},
  pollution_to_join_attack = 0.0,
  distraction_cooldown = 0,
  distance_per_frame =  0.05,
  friendly_map_color = droidMapColour,
  dying_explosion = "medium-explosion",
  resistances =
  {
    {
      type = "physical",
      decrease = 1,
      percent = 40
    },
    {
      type = "explosion",
      decrease = 5,
      percent = 70
    },
    {
      type = "acid",
      decrease = 1,
      percent = 30
    },
    {
      type = "fire",
      decrease = 5,
      percent = 95
    }
  },
  destroy_action =
  {
    type = "direct",
    action_delivery =
    {
      type = "instant",
      source_effects =
      {
        {
          type = "nested-result",
          affects_target = true,
          action =
          {
            type = "area",
            perimeter = 6,
            collision_mask = { "player-layer" },
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                type = "damage",
                damage = { amount = 40, type = "explosion"}
              }
            }
          },
        },
        {
          type = "create-entity",
          entity_name = "explosion"
        },
        {
          type = "damage",
          damage = { amount = 100, type = "explosion"}
        }
      }
    }
  },
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "bullet",
    shell_particle =
    {
      name = "shell-particle",
      direction_deviation = 0.1,
      speed = 0.1,
      speed_deviation = 0.03,
      center = {0, 0.1},
      creation_distance = -0.5,
      starting_frame_speed = 0.4,
      starting_frame_speed_deviation = 0.1
    },
    cooldown = 20,
    projectile_center = {0, 0.5},
    projectile_creation_distance = 0.6,
    range = 13,
    sound = make_heavy_shot_sounds(1.0),
    animation = robotAnimation("smg_run", droidSmgTint, 1),
    ammo_type =
    {
      category = "bullet",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          source_effects =
          {
            type = "create-explosion",
            entity_name = "explosion-gunshot-small"
          },
          target_effects =
          {
            {
              type = "create-entity",
              entity_name = "explosion-hit"
            },
            {
              type = "damage",
              damage = { amount = 8*DAMAGE_SCALAR , type = "physical"}
            }
          }
        }
      }
    }
  },
  idle = robotAnimation("smg_run", droidSmgTint, 1),
  run_animation = robotAnimation("smg_run", droidSmgTint, 1),
}


local droid_flame =
{
  type = "unit",
  name = "droid-flame",
  icon_size = 64,
  icon = ICONPATH .. "droid_flame_undep.png",
  flags = {"placeable-player", "player-creation", "placeable-off-grid"},
  subgroup="creatures",
  order="e-a-b-d",
  has_belt_immunity = true,
  max_health = 200 * HEALTH_SCALAR,
  alert_when_damaged = false,
  healing_per_tick = 0.01,
  collision_box = {{-0.8*droidscale, -0.8*droidscale}, {0.8*droidscale, 0.8*droidscale}},
  selection_box = {{-0.8*droidscale, -0.8*droidscale}, {0.8, 0.8*droidscale}},
  sticker_box = {{-0.5, -0.5}, {0.5, 0.5}},
  vision_distance = 30,
  radar_range = 1,
  can_open_gates = true,
  ai_settings =
  {
    allow_destroy_when_commands_fail = false,
    do_separation = true
  },
  movement_speed = 0.09,
  minable = {hardness = 0.1, mining_time = 0.1, result = "droid-flame"},
  pollution_to_join_attack = 0.0,
  distraction_cooldown = 0,
  distance_per_frame =  0.05,
  friendly_map_color = droidMapColour,
  dying_explosion = "medium-explosion",
  resistances =
  {
    {
      type = "physical",
      decrease = 5,
      percent = 40
    },
    {
      type = "explosion",
      decrease = 5,
      percent = 70
    },
    {
      type = "acid",
      decrease = 1,
      percent = 30
    },
  {
      type = "fire",
      percent = 100
    }
  },
  destroy_action =
  {
    type = "direct",
    action_delivery =
    {
      type = "instant",
      source_effects =
      {
        {
          type = "nested-result",
          affects_target = true,
          action =
          {
            type = "area",
            perimeter = 6,
            collision_mask = { "player-layer" },
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                type = "damage",
                damage = { amount = 40, type = "explosion"}
              }
            }
          },
        },
        {
          type = "create-entity",
          entity_name = "explosion"
        },
        {
          type = "damage",
          damage = { amount = 100, type = "explosion"}
        }
      }
    }

  },
  attack_parameters =
  {
    type = "stream",
    ammo_category = "flamethrower",
    movement_slow_down_factor = 0.6,
    cooldown = 30,
    projectile_creation_distance = 0.6,
    range = 10,
    min_range = 0,
    projectile_center = {-0.17, 0.2},
    animation = robotAnimation("flame_run", droidFlameTint, 1),
    cyclic_sound =
    {
      begin_sound =
      {
        {
          filename = "__base__/sound/fight/flamethrower-start.ogg",
          volume = 0.7
        }
      },
      middle_sound =
      {
        {
          filename = "__base__/sound/fight/flamethrower-mid.ogg",
          volume = 0.7
        }
      },
      end_sound =
      {
        {
          filename = "__base__/sound/fight/flamethrower-end.ogg",
          volume = 0.7
        }
      }
    },
    ammo_type =
    {
      category = "flamethrower",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "stream",
          stream = "flamethrower-fire-stream",
          duration = 60,
          source_offset = {0.15, -0.5},
          target_effects =
          {
            {
              type = "damage",
              damage = { amount = 1 , type = "physical"}
            }
          }
        }
      }
    }
  },
  idle = robotAnimation("flame_run", droidFlameTint, 1),
  run_animation = robotAnimation("flame_run", droidFlameTint, 1),
}

local droid_rifle =
{
  type = "unit",
  name = "droid-rifle",
  icon_size = 64,
  icon = ICONPATH .. "droid_rifle_undep.png",
  flags = {"placeable-player", "player-creation", "placeable-off-grid"},
  subgroup="creatures",
  order="e-a-b-d",
  has_belt_immunity = true,
  max_health = 40 * HEALTH_SCALAR,
  alert_when_damaged = false,
  healing_per_tick = 0.00,
  collision_box = {{-0.8*droidscale, -0.8*droidscale}, {0.8*droidscale, 0.8*droidscale}},
  selection_box = {{-0.8*droidscale, -0.8*droidscale}, {0.8*droidscale, 0.8*droidscale}},
  sticker_box = {{-0.5, -0.5}, {0.5, 0.5}},
  vision_distance = 30,
  radar_range = 1,
  can_open_gates = true,
  ai_settings =
  {
    allow_destroy_when_commands_fail = false,
    do_separation = true
  },
  movement_speed = 0.08,
  friendly_map_color = droidMapColour,
  minable = {hardness = 0.1, mining_time = 0.1, result = "droid-rifle"},
  pollution_to_join_attack = 0.0,
  distraction_cooldown = 0,
  distance_per_frame =  0.05,
  dying_explosion = "medium-explosion",
  resistances =
  {
    {
      type = "physical",
      decrease = 1,
      percent = 30
    },
    {
      type = "explosion",
      decrease = 5,
      percent = 50
    },
    {
      type = "acid",
      decrease = 1,
      percent = 25
    },
    {
      type = "fire",
      decrease = 5,
      percent = 95
    }
  },
  destroy_action =
  {
    type = "direct",
    action_delivery =
    {
      type = "instant",
      source_effects =
      {
        {
          type = "nested-result",
          affects_target = true,
          action =
          {
            type = "area",
            perimeter = 6,
            collision_mask = { "player-layer" },
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                type = "damage",
                damage = { amount = 40, type = "explosion"}
              }
            }
          },
        },
        {
          type = "create-entity",
          entity_name = "explosion"
        },
        {
          type = "damage",
          damage = { amount = 100, type = "explosion"}
        }
      }
    }
  },
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "bullet",
    shell_particle =
    {
      name = "shell-particle",
      direction_deviation = 0.1,
      speed = 0.1,
      speed_deviation = 0.03,
      center = {0, 0.1},
      creation_distance = -0.5,
      starting_frame_speed = 0.4,
      starting_frame_speed_deviation = 0.1
    },
    cooldown = 120,
    projectile_center = {-0.6, 1},
    projectile_creation_distance = 0.8,
    range = 15,
    sound = make_rifle_gunshot_sounds(1),
    animation = robotAnimation("rifle_run", droidRifleTint, droidscale),
    ammo_type =
    {
      category = "bullet",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          source_effects =
          {
            type = "create-explosion",
            entity_name = "explosion-gunshot-small"
          },
          target_effects =
          {
            {
              type = "create-entity",
              entity_name = "explosion-hit"
            },
            {
              type = "damage",
              damage = { amount = 10*DAMAGE_SCALAR , type = "physical"}
            }
          }
        }
      }
    }
  },
  idle = robotAnimation("rifle_run", droidRifleTint, droidscale),
  run_animation = robotAnimation("rifle_run", droidRifleTint, droidscale),
}


local droid_rocket =
{
  type = "unit",
  name = "droid-rocket",
  icon_size = 64,
  icon = ICONPATH .. "droid_rocket_undep.png",
  flags = {"placeable-player", "player-creation", "placeable-off-grid"},
  subgroup="creatures",
  order="e-a-b-d",
  has_belt_immunity = true,
  max_health = 85 * HEALTH_SCALAR,
  alert_when_damaged = false,
  healing_per_tick = 0.01,
  collision_box = {{-0.8*droidscale, -0.8*droidscale}, {0.8*droidscale, 0.8*droidscale}},
  selection_box = {{-0.8*droidscale, -0.8*droidscale}, {0.8, 0.8*droidscale}},
  sticker_box = {{-0.5, -0.5}, {0.5, 0.5}},
  vision_distance = 30,
  radar_range = 1,
  can_open_gates = true,
  ai_settings =
  {
    allow_destroy_when_commands_fail = false,
    do_separation = true
  },
  friendly_map_color = droidMapColour,
  movement_speed = 0.11,
  minable = {hardness = 0.1, mining_time = 0.1, result = "droid-rocket"},
  pollution_to_join_attack = 0.0,
  distraction_cooldown = 0,
  distance_per_frame =  0.05,
  dying_explosion = "medium-explosion",
  resistances =
  {
    {
      type = "physical",
      decrease = 1,
      percent = 40
    },
    {
      type = "explosion",
      decrease = 5,
      percent = 30
    },
    {
      type = "acid",
      decrease = 1,
      percent = 30
    },
    {
      type = "fire",
      decrease = 5,
      percent = 95
    }
  },
  destroy_action =
  {
    type = "direct",
    action_delivery =
    {
      type = "instant",
      source_effects =
      {
        {
          type = "nested-result",
          affects_target = true,
          action =
          {
            type = "area",
            perimeter = 6,
            collision_mask = { "player-layer" },
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                type = "damage",
                damage = { amount = 50, type = "explosion"}
              }
            }
          },
        },
        {
          type = "create-entity",
          entity_name = "explosion"
        },
        {
          type = "damage",
          damage = { amount = 100, type = "explosion"}
        }
      }
    }
  },
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "rocket",
    movement_slow_down_factor = 0.8,
    cooldown = 180,
    projectile_creation_distance = 1,
    range = 22,
    projectile_center = {0.6, 1},
    animation = robotAnimation("rocket_run", droidRocketTint, 1),
    sound =
    {
      {
        filename = "__base__/sound/fight/rocket-launcher.ogg",
        volume = 0.7
      }
    },
    ammo_type =
    {
      category = "rocket",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "projectile",
          projectile = "droid-explosive-rocket",
          starting_speed = 0.9,
          source_effects =
          {
            type = "create-entity",
            entity_name = "explosion-hit"
          }
        }
      }
    }
  },
  idle = robotAnimation("rocket_run", droidRocketTint, 1),
  run_animation = robotAnimation("rocket_run", droidRocketTint, 1),
}

local terminator =
{
  type = "unit",
  name = "terminator",
  icon_size = 64,
  icon = ICONPATH .. "terminator.png",
  flags = {"placeable-player", "player-creation", "placeable-off-grid"},
  subgroup="creatures",
  order="e-a-b-d",
  has_belt_immunity = true,
  max_health = 300 * HEALTH_SCALAR,
  alert_when_damaged = false,
  healing_per_tick = 0.02,
  friendly_map_color = droidMapColour,
  collision_box = {{-0.8*droidscale, -0.8*droidscale}, {0.8*droidscale, 0.8*droidscale}},
  selection_box = {{-0.8*droidscale, -0.8*droidscale}, {0.8, 0.8*droidscale}},
  sticker_box = {{-0.5, -0.5}, {0.5, 0.5}},
  vision_distance = 30,
  radar_range = 1,
  can_open_gates = true,
  ai_settings =
  {
    allow_destroy_when_commands_fail = false,
    do_separation = true
  },
  movement_speed = 0.18,
  minable = {hardness = 0.1, mining_time = 0.1, result = "terminator"},
  pollution_to_join_attack = 0.0,
  distraction_cooldown = 0,
  distance_per_frame =  0.05,
  dying_explosion = "medium-explosion",
  resistances =
  {
    {
      type = "physical",
      decrease = 1,
      percent = 80
    },
    {
      type = "explosion",
      decrease = 20,
      percent = 90
    },
    {
      type = "acid",
      decrease = 5,
      percent = 85
    },
  {
      type = "laser",
      decrease = 5,
      percent = 35
    },
  {
      type = "fire",
  decrease = 5,
      percent = 95
    }
  },
  destroy_action =
  {
     type = "direct",
    action_delivery =
    {
      type = "instant",
      source_effects =
      {
    {
          type = "create-entity",
          entity_name = "explosion"
        },
        {
          type = "nested-result",
          action =
          {
            type = "area",
            perimeter = 50,
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                {
                  type = "damage",
                  damage = {amount = 100, type = "explosion"}
                },
                {
                  type = "create-entity",
                  entity_name = "explosion"
                },
        {
        type = "create-entity",
        entity_name = "small-scorchmark",
        check_buildability = true
        }
              }
            }
          }
    },
    }
  }

  },
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "laser",
    cooldown = 10,
    projectile_center = {0, 0.4},
    projectile_creation_distance = 1.5,
    range = 15,
    sound = make_laser_sounds(1),
    animation = robotAnimation("terminator_run", {r=1, g=1, b=1, a=1}, 1),
    ammo_type =
    {
      type = "projectile",
      category = "laser",
      energy_consumption = "0W",
      projectile = "laser-dual",
      speed = 2,
      action =
      {
        {
          type = "direct",
          action_delivery =
          {
            {
              type = "projectile",
              projectile = "laser-dual",
              starting_speed = 1
            }
          }
        }
      }
    }
  },
  idle = robotAnimation("terminator_run", {r=1, g=1, b=1, a=1}, 1),
  run_animation = robotAnimation("terminator_run", {r=1, g=1, b=1, a=1}, 1),
}

------------------------------------------------------------------------
------------------------------- BUILDINGS ------------------------------
------------------------------------------------------------------------

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
  item_slot_count = 6,
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

local droid_settings =  {
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
    {
      type = "fire",
      percent = 90
    }
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
  flags = {},
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

 -- extend the game data with the new entity definitions
data:extend({droid_smg, droid_rocket, droid_rifle, terminator, droid_counter, loot_chest, droid_flame, droid_settings, selection_sticker})



