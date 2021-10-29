local ICONPATH = "__robotarmy__/graphics/icons/"
local BOTPATH = "__robotarmy__/graphics/entity/bots/"

-- use the base game's power armour animations/sprites for the droids and terminators
--require("prototypes.droid-animations")
require("config.config")

-- DONT FORGET TO ADD ANY NEW LOCAL TABLE DEFINITIONS TO THE DATA:EXTEND THING AT THE BOTTOM!

local function robotAnimation(sheet, scale)
  return {
    layers = {
      {
        filename = BOTPATH .. sheet .. ".png",
        width = 80,
        height = 80,
        direction_count = 22,
        frame_count = 1,
        animation_speed = 0.01,
        shift = {0, -0.5},
        scale = scale,
        hr_version = {
          filename = BOTPATH .. "hr-" .. sheet .. ".png",
          width = 160,
          height = 160,
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

function make_laser_sounds()
  return {
    {filename = "__base__/sound/fight/laser-1.ogg", volume = 0.7},
    {filename = "__base__/sound/fight/laser-2.ogg", volume = 0.7},
    {filename = "__base__/sound/fight/laser-3.ogg", volume = 0.7}
  }
end

local function make_heavy_shot_sounds()
  return {
    {filename = "__base__/sound/fight/heavy-gunshot-1.ogg", volume = 0.45},
    {filename = "__base__/sound/fight/heavy-gunshot-2.ogg", volume = 0.45},
    {filename = "__base__/sound/fight/heavy-gunshot-3.ogg", volume = 0.45},
    {filename = "__base__/sound/fight/heavy-gunshot-4.ogg", volume = 0.45}
  }
end

local function make_rifle_gunshot_sounds()
  return {
    {filename = "__base__/sound/fight/light-gunshot-1.ogg", volume = 1},
    {filename = "__base__/sound/fight/light-gunshot-2.ogg", volume = 1},
    {filename = "__base__/sound/fight/light-gunshot-3.ogg", volume = 1}
  }
end

local function add_recurrent_params(bot)
  bot.icon_size = 64
  bot.subgroup = "creatures"
  bot.order = "e-a-b-d"
  bot.collision_box = {{-(0.7), -(0.7)}, {0.7, 0.7}}
  bot.selection_box = {{-(0.7), -(0.7)}, {0.7, 0.7}}
  bot.sticker_box = {{-(0.5), -(0.5)}, {0.5, 0.5}}
  bot.ai_settings = {do_separation = true, allow_destroy_when_commands_fail = false}
  bot.vision_distance = 30
  bot.pollution_to_join_attack = 0
  bot.distraction_cooldown = 0
  bot.distance_per_frame = 0.05
  bot.dying_explosion = "medium-explosion"
  bot.flags = {"placeable-player", "player-creation", "placeable-off-grid"}
  bot.enemy_map_color = {r = 1, g = 0, b = 0}
  bot.friendly_map_color = {r = 0.05, g = 0.7, b = 0.29}
  bot.has_belt_immunity = true
  bot.can_open_gates = true
  bot.alert_when_damaged = false
end

local basic_constructor = {
  type = "unit",
  name = "basic-constructor",
  icon = ICONPATH .. "droid_repair.png",
  move_while_shooting = true, -- note this makes them kite backwards when heavily engaged as of v0.17.76
  max_health = 120,
  healing_per_tick = 0.001,
  movement_speed = 0.11,
  minable = { hardness = 0.1, mining_time = 0.1, result = "basic-constructor" },
  resistances =
  {
    {type = "physical", decrease = 1, percent = 40},
    {type = "explosion", decrease = 5, percent = 70},
    {type = "acid", decrease = 1, percent = 30},
    {type = "fire", decrease = 5, percent = 95}
  },
  destroy_action = {
    type = "direct",
    action_delivery = {
      type = "instant",
      source_effects = {
        {
          type = "nested-result",
          affects_target = true,
          action = {
            type = "area",
            perimeter = 6,
            collision_mask = {"player-layer"},
            action_delivery = {
              type = "instant",
              target_effects = {
                type = "damage",
                damage = { amount = 40, type = "explosion" }
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
          damage = { amount = 100, type = "explosion" }
        }
      }
    }
  },
  attack_parameters = {
    type = "projectile",
    ammo_category = "bullet",
    shell_particle = {
      name = "shell-particle",
      direction_deviation = 0.1,
      speed = 0.1,
      speed_deviation = 0.03,
      center = { 0, 0.1 },
      creation_distance = -0.5,
      starting_frame_speed = 0.4,
      starting_frame_speed_deviation = 0.1
    },
    cooldown = 2,
    projectile_center = { 0, 0.5 },
    projectile_creation_distance = 0.5,
    range = 8,
    min_range = 0,
    sound = make_heavy_shot_sounds(),
    animation = robotAnimation("droid_repair_run", 1),
    ammo_type = {
      category = "bullet",
      action = {
        type = "direct",
        action_delivery = {
          type = "instant",
          source_effects = {
            type = "create-explosion",
            entity_name = "explosion-gunshot-small"
          },
          target_effects = {
            {
              type = "create-entity",
              entity_name = "explosion-hit"
            },
            {
              type = "damage",
              damage = { amount = 1*settings.startup["Droid-Damage-Modifier"].value, type = "physical" }
    } } } } }
  },
  idle = robotAnimation("droid_repair_run", 1),
  run_animation = robotAnimation("droid_repair_run", 1),
}

local droid_rifle =
{
  type = "unit",
  name = "droid-rifle",
  icon = ICONPATH .. "droid_rifle.png",
  max_health = 50 * settings.startup["Droid-Health-Modifier"].value,
  move_while_shooting = false,
  healing_per_tick = 0.00,
  radar_range = 1,
  movement_speed = 0.08,
  minable = {hardness = 0.1, mining_time = 0.1, result = "droid-rifle"},
  resistances = {
    {type = "physical", decrease = 1, percent = 30},
    {type = "explosion", decrease = 5, percent = 50},
    {type = "acid", decrease = 1, percent = 25},
    {type = "fire", decrease = 5, percent = 95}
  },
  destroy_action = {
    type = "direct",
    action_delivery = {
      type = "instant",
      source_effects = {
        {
          type = "nested-result",
          affects_target = true,
          action = {
            type = "area",
            perimeter = 6,
            collision_mask = { "player-layer" },
            action_delivery = {
              type = "instant",
              target_effects = {
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
  attack_parameters = {
    type = "projectile",
    ammo_category = "bullet",
    shell_particle = {
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
    animation = robotAnimation("rifle_run", 0.8),
    ammo_type = {
      category = "bullet",
      action = {
        type = "direct",
        action_delivery = {
          type = "instant",
          source_effects = {
            type = "create-explosion",
            entity_name = "explosion-gunshot-small"
          },
          target_effects = {
            {
              type = "create-entity",
              entity_name = "explosion-hit"
            },
            {
              type = "damage",
              damage = { amount = 10*settings.startup["Droid-Damage-Modifier"].value, type = "physical"}
    } } } } }
  },
  idle = robotAnimation("rifle_run", 0.8),
  run_animation = robotAnimation("rifle_run", 0.8),
}

local droid_smg =
{
  type = "unit",
  name = "droid-smg",
  icon = ICONPATH .. "droid_smg.png",
  max_health = 120 * settings.startup["Droid-Health-Modifier"].value,
  move_while_shooting = false,
  healing_per_tick = 0.001,
  radar_range = 1,
  movement_speed = 0.11,
  minable = {hardness = 0.1, mining_time = 0.1, result = "droid-smg"},
  resistances = {
    {type = "physical", decrease = 1, percent = 40},
    {type = "explosion", decrease = 5, percent = 70},
    {type = "acid", decrease = 1, percent = 30},
    {type = "fire", decrease = 5, percent = 95}
  },
  destroy_action = {
    type = "direct",
    action_delivery = {
      type = "instant",
      source_effects = {
        {
          type = "nested-result",
          affects_target = true,
          action = {
            type = "area",
            perimeter = 6,
            collision_mask = { "player-layer" },
            action_delivery = {
              type = "instant",
              target_effects = {
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
  attack_parameters = {
    type = "projectile",
    ammo_category = "bullet",
    shell_particle = {
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
    sound = make_heavy_shot_sounds(),
    animation = robotAnimation("smg_run", 1),
    ammo_type = {
      category = "bullet",
      action = {
        type = "direct",
        action_delivery = {
          type = "instant",
          source_effects = {
            type = "create-explosion",
            entity_name = "explosion-gunshot-small"
          },
          target_effects = {
            {
              type = "create-entity",
              entity_name = "explosion-hit"
            },
            {
              type = "damage",
              damage = { amount = 8*settings.startup["Droid-Damage-Modifier"].value, type = "physical"}
    } } } } }
  },
  idle = robotAnimation("smg_run", 1),
  run_animation = robotAnimation("smg_run", 1),
}

local droid_rocket =
{
  type = "unit",
  name = "droid-rocket",
  icon = ICONPATH .. "droid_rocket.png",
  max_health = 85 * settings.startup["Droid-Health-Modifier"].value,
  move_while_shooting = false,
  healing_per_tick = 0.01,
  radar_range = 1,
  movement_speed = 0.11,
  minable = {hardness = 0.1, mining_time = 0.1, result = "droid-rocket"},
  resistances = {
    {type = "physical", decrease = 1, percent = 40},
    {type = "explosion", decrease = 5, percent = 30},
    {type = "acid", decrease = 1, percent = 30},
    {type = "fire", decrease = 5, percent = 95}
  },
  destroy_action = {
    type = "direct",
    action_delivery = {
      type = "instant",
      source_effects = {
        {
          type = "nested-result",
          affects_target = true,
          action = {
            type = "area",
            perimeter = 6,
            collision_mask = { "player-layer" },
            action_delivery = {
              type = "instant",
              target_effects = {
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
  attack_parameters = {
    type = "projectile",
    ammo_category = "rocket",
    movement_slow_down_factor = 0.8,
    cooldown = 180,
    projectile_creation_distance = 1,
    range = 22,
    projectile_center = {0.6, 1},
    animation = robotAnimation("rocket_run", 1),
    sound = {{filename = "__base__/sound/fight/rocket-launcher.ogg", volume = 0.7}},
    ammo_type = {
      category = "rocket",
      action = {
        type = "direct",
        action_delivery = {
          type = "projectile",
          projectile = "droid-explosive-rocket",
          starting_speed = 0.9,
          source_effects = {
            type = "create-entity",
            entity_name = "explosion-hit"
    } } } }
  },
  idle = robotAnimation("rocket_run", 1),
  run_animation = robotAnimation("rocket_run", 1),
}

local droid_flame =
{
  type = "unit",
  name = "droid-flame",
  icon = ICONPATH .. "droid_flame.png",
  max_health = 200 * settings.startup["Droid-Health-Modifier"].value,
  move_while_shooting = false,
  healing_per_tick = 0.001,
  radar_range = 1,
  movement_speed = 0.09,
  minable = {hardness = 0.1, mining_time = 0.1, result = "droid-flame"},
  resistances = {
    {type = "physical", decrease = 5, percent = 40},
    {type = "explosion", decrease = 5, percent = 70},
    {type = "acid", decrease = 1, percent = 30},
    {type = "fire", percent = 100}
  },
  destroy_action = {
    type = "direct",
    action_delivery = {
      type = "instant",
      source_effects = {
        {
          type = "nested-result",
          affects_target = true,
          action = {
            type = "area",
            perimeter = 6,
            collision_mask = { "player-layer" },
            action_delivery = {
              type = "instant",
              target_effects = {
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
  attack_parameters = {
    type = "stream",
    ammo_category = "flamethrower",
    movement_slow_down_factor = 0.6,
    cooldown = 30,
    projectile_creation_distance = 0.6,
    range = 10,
    min_range = 0,
    projectile_center = {-0.17, 0.2},
    animation = robotAnimation("flame_run", 1),
    cyclic_sound = {
      begin_sound = {{filename = "__base__/sound/fight/flamethrower-start.ogg", volume = 0.7}},
      middle_sound = {{filename = "__base__/sound/fight/flamethrower-mid.ogg", volume = 0.7}},
      end_sound = {{filename = "__base__/sound/fight/flamethrower-end.ogg", volume = 0.7}}},
    ammo_type = {
      category = "flamethrower",
      action = {
        type = "direct",
        action_delivery = {
          type = "stream",
          stream = "flamethrower-fire-stream",
          duration = 60,
          source_offset = {0.15, -0.5},
          target_effects = {
            {
              type = "damage",
              damage = { amount = 1*settings.startup["Droid-Damage-Modifier"].value , type = "physical"}
    } } } } }
  },
  idle = robotAnimation("flame_run", 1),
  run_animation = robotAnimation("flame_run", 1),
}

local terminator =
{
  type = "unit",
  name = "terminator",
  icon = ICONPATH .. "droid_terminator.png",
  max_health = 300 * settings.startup["Droid-Health-Modifier"].value,
  move_while_shooting = false,
  healing_per_tick = 0.005,
  radar_range = 1,
  movement_speed = 0.18,
  minable = {hardness = 0.1, mining_time = 0.1, result = "terminator"},
  resistances = {
    {type = "physical", decrease = 1, percent = 80},
    {type = "explosion", decrease = 20, percent = 90},
    {type = "acid", decrease = 5, percent = 85},
    {type = "laser", decrease = 5, percent = 35},
    {type = "fire", decrease = 5, percent = 95}
  },
  destroy_action = {
    type = "direct",
    action_delivery = {
      type = "instant",
      source_effects = {
        {
          type = "create-entity",
          entity_name = "explosion"
        },
        {
          type = "nested-result",
          action = {
            type = "area",
            perimeter = 50,
            action_delivery = {
              type = "instant",
              target_effects = {
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
    } } } } } } }
  },
  attack_parameters = {
    type = "projectile",
    ammo_category = "laser",
    cooldown = 10,
    projectile_center = {0, 0.4},
    projectile_creation_distance = 1.5,
    range = 15,
    sound = make_laser_sounds(),
    animation = robotAnimation("terminator_run", 1),
    ammo_type = {
      type = "projectile",
      category = "laser",
      energy_consumption = "0W",
      projectile = "laser-dual",
      speed = 2,
      action = {
        {
          type = "direct",
          action_delivery = {
            {
              type = "projectile",
              projectile = "laser-dual",
              starting_speed = 1
    } } } } }
  },
  idle = robotAnimation("terminator_run", 1),
  run_animation = robotAnimation("terminator_run", 1),
}

add_recurrent_params(basic_constructor)
add_recurrent_params(droid_smg)
add_recurrent_params(droid_flame)
add_recurrent_params(droid_rifle)
add_recurrent_params(droid_rocket)
add_recurrent_params(terminator)

 -- extend the game data with the new entity definitions
data:extend({basic_constructor, droid_rifle, droid_smg, droid_rocket, droid_flame, terminator})
