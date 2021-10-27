require("config.config")

local function make_light_gunshot_sounds()
  return {
    {filename = "__base__/sound/fight/light-gunshot-1.ogg", volume = 0.7},
    {filename = "__base__/sound/fight/light-gunshot-2.ogg", volume = 0.7},
    {filename = "__base__/sound/fight/light-gunshot-3.ogg", volume = 0.7}
  }
end

local defenderUnitAnim =
{
  layers =
  {
    {
      filename = "__base__/graphics/entity/defender-robot/defender-robot.png",
      priority = "high",
      line_length = 16,
      width = 32,
      height = 33,
      frame_count = 1,
      animation_speed = 1,
      direction_count = 16,
      shift = util.by_pixel(0, 0.25),
      y = 33,
      hr_version =
      {
        filename = "__base__/graphics/entity/defender-robot/hr-defender-robot.png",
        priority = "high",
        line_length = 16,
        width = 56,
        height = 59,
        frame_count = 1,
        animation_speed = 1,
        direction_count = 16,
        shift = util.by_pixel(0, 0.25),
        y = 59,
        scale = 0.5
      }
    },
    {
      filename = "__base__/graphics/entity/defender-robot/defender-robot-mask.png",
      priority = "high",
      line_length = 16,
      width = 18,
      height = 16,
      frame_count = 1,
      animation_speed = 1,
      direction_count = 16,
      shift = util.by_pixel(0, -4.75),
      apply_runtime_tint = true,
      y = 16,
      hr_version =
      {
        filename = "__base__/graphics/entity/defender-robot/hr-defender-robot-mask.png",
        priority = "high",
        line_length = 16,
        width = 28,
        height = 21,
        frame_count = 1,
        animation_speed = 1,
        direction_count = 16,
        shift = util.by_pixel(0, -4.75),
        apply_runtime_tint = true,
        y = 21,
        scale = 0.5
      }
    },
    {
      filename = "__base__/graphics/entity/defender-robot/defender-robot-shadow.png",
      priority = "high",
      line_length = 16,
      width = 45,
      height = 26,
      frame_count = 1,
      animation_speed = 1,
      direction_count = 16,
      shift = util.by_pixel(25.5, 19),
      draw_as_shadow = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/defender-robot/hr-defender-robot-shadow.png",
        priority = "high",
        line_length = 16,
        width = 88,
        height = 50,
        frame_count = 1,
        animation_speed = 1,
        direction_count = 16,
        shift = util.by_pixel(25.5, 19),
        scale = 0.5,
        draw_as_shadow = true
      }
    }
  }
}

local distractorUnitAnim =
{
  layers =
  {
    {
      filename = "__base__/graphics/entity/distractor-robot/distractor-robot.png",
      priority = "high",
      line_length = 16,
      width = 38,
      height = 33,
      frame_count = 1,
      direction_count = 16,
      shift = util.by_pixel(0, -2.5),
      y = 33,
      hr_version =
      {
        filename = "__base__/graphics/entity/distractor-robot/hr-distractor-robot.png",
        priority = "high",
        line_length = 16,
        width = 72,
        height = 62,
        frame_count = 1,
        direction_count = 16,
        shift = util.by_pixel(0, -2.5),
        y = 62,
        scale = 0.5
      }
    },
    {
      filename = "__base__/graphics/entity/distractor-robot/distractor-robot-mask.png",
      priority = "high",
      line_length = 16,
      width = 24,
      height = 21,
      frame_count = 1,
      direction_count = 16,
      shift = util.by_pixel(0, -6.25),
      apply_runtime_tint = true,
      y = 21,
      hr_version =
      {
        filename = "__base__/graphics/entity/distractor-robot/hr-distractor-robot-mask.png",
        priority = "high",
        line_length = 16,
        width = 42,
        height = 37,
        frame_count = 1,
        direction_count = 16,
        shift = util.by_pixel(0, -6.25),
        apply_runtime_tint = true,
        y = 37,
        scale = 0.5
      }
    },
    {
      filename = "__base__/graphics/entity/distractor-robot/distractor-robot-shadow.png",
      priority = "high",
      line_length = 16,
      width = 49,
      height = 30,
      frame_count = 1,
      direction_count = 16,
      shift = util.by_pixel(32.5, 19),
      draw_as_shadow = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/distractor-robot/hr-distractor-robot-shadow.png",
        priority = "high",
        line_length = 16,
        width = 96,
        height = 59,
        frame_count = 1,
        direction_count = 16,
        shift = util.by_pixel(32.5, 19.25),
        scale = 0.5,
        draw_as_shadow = true
      }
    }
  }
}

local destroyerUnitAnim =
{
  layers =
  {
    {
      filename = "__base__/graphics/entity/destroyer-robot/destroyer-robot.png",
      priority = "high",
      line_length = 32,
      width = 45,
      height = 39,
      frame_count = 1,
      direction_count = 32,
      shift = util.by_pixel(2.5, -1.25),
      hr_version =
      {
        filename = "__base__/graphics/entity/destroyer-robot/hr-destroyer-robot.png",
        priority = "high",
        line_length = 32,
        width = 88,
        height = 77,
        frame_count = 1,
        direction_count = 32,
        shift = util.by_pixel(2.5, -1.25),
        scale = 0.5
      }
    },
    {
      filename = "__base__/graphics/entity/destroyer-robot/destroyer-robot-mask.png",
      priority = "high",
      line_length = 32,
      width = 27,
      height = 21,
      frame_count = 1,
      direction_count = 32,
      shift = util.by_pixel(2.5, -7),
      apply_runtime_tint = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/destroyer-robot/hr-destroyer-robot-mask.png",
        priority = "high",
        line_length = 32,
        width = 52,
        height = 42,
        frame_count = 1,
        direction_count = 32,
        shift = util.by_pixel(2.5, -7),
        apply_runtime_tint = true,
        scale = 0.5
      }
    },
    {
      filename = "__base__/graphics/entity/destroyer-robot/destroyer-robot-shadow.png",
      priority = "high",
      line_length = 32,
      width = 55,
      height = 34,
      frame_count = 1,
      direction_count = 32,
      shift = util.by_pixel(23.5, 19),
      draw_as_shadow = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/destroyer-robot/hr-destroyer-robot-shadow.png",
        priority = "high",
        line_length = 32,
        width = 108,
        height = 66,
        frame_count = 1,
        direction_count = 32,
        shift = util.by_pixel(23.5, 19),
        scale = 0.5,
        draw_as_shadow = true
      }
    }
  }
}


-----------------------------------------------------
------------------FLYING BOTS------------------------
-----------------------------------------------------



--[[local function add_recurrent_params(bot)
  bot.icon_size = 64
  bot.type = "unit"
  bot.flags = {"placeable-player", "player-creation", "placeable-off-grid"}
  bot.subgroup = "creatures"
  bot.has_belt_immunity = true
  bot.alert_when_damaged = false

end]]

local defender_unit = {
  type = "unit",
  name = "defender-unit",
  icon_size = 64,
  icon = "__base__/graphics/icons/defender.png",
  flags = {"placeable-player", "player-creation", "placeable-off-grid"},
  subgroup = "creatures",
  has_belt_immunity = true,
  max_health = 65 * settings.startup["Droid-Health-Modifier"].value,
  minable = {hardness = 0.1, mining_time = 0.1, result = "defender-unit"},
  alert_when_damaged = false,
  order = "b-b-a",
  resistances =
  {
    {type = "physical", decrease = 4},
  },
  healing_per_tick = 0,
  collision_box = nil,
  collision_mask = { "ghost-layer"},
  selection_box = {{-0.3, -0.3}, {0.3, 0.3}},
  sticker_box = {{-0.1, -0.1}, {0.1, 0.1}},
  distraction_cooldown = 300,
  ai_settings =
  {
    do_separation = true,
    allow_destroy_when_commands_fail = false
  },
  attack_parameters = {
    type = "projectile",
    ammo_category = "bullet",
    cooldown = 20,
    projectile_center = {0, 1},
    projectile_creation_distance = 0.6,
    range = 12,
    min_attack_distance = 8,
    sound = make_light_gunshot_sounds(),
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
              damage = { amount = 5 * settings.startup["Droid-Damage-Modifier"].value, type = "physical"}
            }
          }
        }
      }
    },
    animation = defenderUnitAnim,
  },
  friendly_map_color = {r = .05, g = .70, b = .29},
  enemy_map_color = {r = .100, g = .0, b = .0},
  vision_distance = 45,
  radar_range = 1,
  can_open_gates = true,
  movement_speed = 0.2,
  distance_per_frame = 0.15,
  -- in pu
  pollution_to_join_attack = 1000,
  corpse = "robot-corpse",
  dying_explosion = "explosion",
  working_sound =
    {
    sound =
    {
      { filename = "__base__/sound/flying-robot-1.ogg", volume = 0.6 },
      { filename = "__base__/sound/flying-robot-2.ogg", volume = 0.6 },
      { filename = "__base__/sound/flying-robot-3.ogg", volume = 0.6 },
      { filename = "__base__/sound/flying-robot-4.ogg", volume = 0.6 },
      { filename = "__base__/sound/flying-robot-5.ogg", volume = 0.6 }
    },
    max_sounds_per_type = 3,
    --audible_distance_modifier = 0.5,
    probability = 1 / (3 * 60) -- average pause between the sound is 3 seconds
  },
  dying_sound =
  {
    {
      filename = "__base__/sound/fight/robot-explosion-1.ogg",
      volume = 0.5
    },
    {
      filename = "__base__/sound/fight/robot-explosion-2.ogg",
      volume = 0.5
    }
  },
  run_animation = defenderUnitAnim,
}
local distractor_unit = {
  type = "unit",
  name = "distractor-unit",
  icon_size = 64,
  icon = "__base__/graphics/icons/distractor.png",
  flags = {"placeable-player", "player-creation", "placeable-off-grid"},
  subgroup = "creatures",
  has_belt_immunity = true,
  max_health = 85 * settings.startup["Droid-Health-Modifier"].value,
  minable = {hardness = 0.1, mining_time = 0.1, result = "distractor-unit"},
  alert_when_damaged = false,
  order = "b-b-b",
  resistances =
  {
    {
      type = "physical",
      decrease = 4,
    },
  },
  healing_per_tick = 0,
  collision_box = nil,
  collision_mask = { "ghost-layer"},
  selection_box = {{-0.3, -0.3}, {0.3, 0.3}},
  sticker_box = {{-0.1, -0.1}, {0.1, 0.1}},
  distraction_cooldown = 300,
  ai_settings =
  {
    do_separation = true,
      allow_destroy_when_commands_fail = false
  },
  attack_parameters =
  {
    type = "beam",
    ammo_category = "laser",
    cooldown = 20,
    cooldown_deviation = 0.15,
    damage_modifier = 1,
    range = 14,
    sound = make_laser_sounds(),
    ammo_type =
    {
      category = "laser",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "beam",
          beam = "laser-beam",
          max_length = 15,
          duration = 10,
        }
      }
    },
    animation = distractorUnitAnim
  },
  friendly_map_color = {r = .05, g = .70, b = .29},
  enemy_map_color = {r = .100, g = .0, b = .0},
  vision_distance = 45,
  radar_range = 1,
  can_open_gates = true,
  movement_speed = 0.2,
  distance_per_frame = 0.15,
  -- in pu
  pollution_to_join_attack = 1000,
  corpse = "robot-corpse",
  dying_explosion = "explosion",
  working_sound =
  {
    sound =
    {
      { filename = "__base__/sound/flying-robot-1.ogg", volume = 0.6 },
      { filename = "__base__/sound/flying-robot-2.ogg", volume = 0.6 },
      { filename = "__base__/sound/flying-robot-3.ogg", volume = 0.6 },
      { filename = "__base__/sound/flying-robot-4.ogg", volume = 0.6 },
      { filename = "__base__/sound/flying-robot-5.ogg", volume = 0.6 }
    },
    max_sounds_per_type = 3,
    --audible_distance_modifier = 0.5,
    probability = 1 / (3 * 60) -- average pause between the sound is 3 seconds
  },
  dying_sound =
  {
    {
      filename = "__base__/sound/fight/robot-explosion-1.ogg",
      volume = 0.5
    },
    {
      filename = "__base__/sound/fight/robot-explosion-2.ogg",
      volume = 0.5
    }
  },
  run_animation = distractorUnitAnim,
}

local destroyer_unit = {
  type = "unit",
  name = "destroyer-unit",
  icon_size = 64,
  icon = "__base__/graphics/icons/destroyer.png",
  flags = {"placeable-player", "player-creation", "placeable-off-grid"},
  subgroup = "creatures",
  has_belt_immunity = true,
  max_health = 120 * settings.startup["Droid-Health-Modifier"].value,
  minable = {hardness = 0.1, mining_time = 0.1, result = "destroyer-unit"},
  alert_when_damaged = false,
  order = "b-b-c",
  resistances =
  {
    {
      type = "physical",
      decrease = 4,
    },
  },
  healing_per_tick = 0,
  collision_box = nil,
  collision_mask = { "ghost-layer"},
  selection_box = {{-0.3, -0.3}, {0.3, 0.3}},
  sticker_box = {{-0.1, -0.1}, {0.1, 0.1}},
  distraction_cooldown = 300,
  ai_settings =
  {
    do_separation = true,
    allow_destroy_when_commands_fail = false
  },
  attack_parameters =
  {
    type = "beam",
    ammo_category = "beam",
    cooldown = 20,
    range = 15,
    min_attack_distance = 9,
    ammo_type =
    {
      category = "beam",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "beam",
          beam = "robot-electric-beam",
          max_length = 20,
          duration = 20,
          source_offset = {0.15, -0.5},
        }
      }
    },
    animation = destroyerUnitAnim,
  },
  friendly_map_color = {r = .05, g = .70, b = .29},
  enemy_map_color = {r = .100, g = .0, b = .0},
  vision_distance = 45,
  radar_range = 1,
  can_open_gates = true,
  movement_speed = 0.2,
  distance_per_frame = 0.15,
  -- in pu
  pollution_to_join_attack = 1000000,
  corpse = "robot-corpse",
  dying_explosion = "explosion",
  working_sound =
  {
    sound =
    {
      { filename = "__base__/sound/flying-robot-1.ogg", volume = 0.6 },
      { filename = "__base__/sound/flying-robot-2.ogg", volume = 0.6 },
      { filename = "__base__/sound/flying-robot-3.ogg", volume = 0.6 },
      { filename = "__base__/sound/flying-robot-4.ogg", volume = 0.6 },
      { filename = "__base__/sound/flying-robot-5.ogg", volume = 0.6 }
    },
    max_sounds_per_type = 3,
    --audible_distance_modifier = 0.5,
    probability = 1 / (3 * 60) -- average pause between the sound is 3 seconds
  },
  dying_sound =
  {
    {
      filename = "__base__/sound/fight/robot-explosion-1.ogg",
      volume = 0.5
    },
    {
      filename = "__base__/sound/fight/robot-explosion-2.ogg",
      volume = 0.5
    }
  },
  run_animation = destroyerUnitAnim,
}


data:extend({defender_unit, distractor_unit, destroyer_unit})