require("config.config")

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

data:extend({
{
  type = "unit",
  name = "distractor-unit",
  icon_size = 64,
  icon = "__base__/graphics/icons/distractor.png",
  flags = {"placeable-player", "player-creation", "placeable-off-grid"},
  subgroup = "creatures",
  has_belt_immunity = true,
  max_health = 85 * HEALTH_SCALAR,
  minable = {hardness = 0.1, mining_time = 0.1, result = "distractor-unit"},
  alert_when_damaged = false,
  order = "b-b-b",
  resistances =
  {
    {
      type = "physical",
      decrease = 4,
    },
    {
      type = "acid",
      decrease = 1,
      percent = 30
    },
  },
  healing_per_tick = 0,
  collision_box = {{0, 0}, {0, 0}},
  selection_box = {{-0.3, -0.3}, {0.3, 0.3}},
  sticker_box = {{-0.1, -0.1}, {0.1, 0.1}},
  distraction_cooldown = 300,
  ai_settings =
  {
    allow_destroy_when_commands_fail = false,
    do_separation = true
  },
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "laser",
    cooldown = 20,
    damage_modifier = 0.7,
    projectile_center = {0, 0.6},
    projectile_creation_distance = 0.6,
    range = 18,
    min_attack_distance = 12,
    sound = make_laser_sounds(),
    ammo_type =
    {
      category = "laser",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "projectile",
          projectile = "laser",
          starting_speed = 1
        }
      }
    },
    animation = distractorUnitAnim
  },
  vision_distance = 45,
  radar_range = 1,
  can_open_gates = true,
  movement_speed = 0.2,
  distance_per_frame = 0.15,
  -- in pu
  absorptions_to_join_attack={},
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
},
})