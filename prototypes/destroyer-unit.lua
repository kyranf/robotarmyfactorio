require("config.config")

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

data:extend({
{
  type = "unit",
  name = "destroyer-unit",
  icon_size = 64,
  icon = "__base__/graphics/icons/destroyer.png",
  flags = {"placeable-player", "player-creation", "placeable-off-grid"},
  subgroup = "creatures",
  has_belt_immunity = true,
  max_health = 120 * HEALTH_SCALAR,
  alert_when_damaged = false,
  order = "b-b-c",
  minable = {hardness = 0.1, mining_time = 0.1, result = "destroyer-unit"},
  resistances =
  {
    {
      type = "physical",
      decrease = 8,
    },
    {
      type = "acid",
      decrease = 5,
      percent = 70
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
  run_animation = destroyerUnitAnim,
},

{
  type = "beam",
  name = "robot-electric-beam",
  working_sound =
  {
    filename = "__base__/sound/fight/electric-beam.ogg",
    volume = 0.7
  },
  flags = {"not-on-map"},
  width = 0.5,
  damage_interval = 20,
  action =
  {
    type = "direct",
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        {
          type = "damage",
          damage = { amount = 15*DAMAGE_SCALAR, type = "electric"}
        }
      }
    }
  },
  graphics_set = { beam={
  start =
  {
    filename = "__base__/graphics/entity/beam/tileable-beam-START.png",
    line_length = 4,
    width = 52,
    height = 40,
    frame_count = 16,
    axially_symmetrical = false,
    direction_count = 1,
    shift = {-0.03125, 0},
    hr_version = {
      filename = "__base__/graphics/entity/beam/hr-tileable-beam-START.png",
      line_length = 4,
      width = 94,
      height = 66,
      frame_count = 16,
      axially_symmetrical = false,
      direction_count = 1,
      shift = {0.53125, 0},
      scale = 0.5,
    }
  },
  ending =
  {
    filename = "__base__/graphics/entity/beam/tileable-beam-END.png",
    line_length = 4,
    width = 49,
    height = 54,
    frame_count = 16,
    axially_symmetrical = false,
    direction_count = 1,
    shift = {-0.046875, 0},
    hr_version = {
      filename = "__base__/graphics/entity/beam/hr-tileable-beam-END.png",
      line_length = 4,
      width = 91,
      height = 93,
      frame_count = 16,
      axially_symmetrical = false,
      direction_count = 1,
      shift = {-0.078125, -0.046875},
      scale = 0.5,
    }
  },
  head =
  {
    filename = "__base__/graphics/entity/beam/beam-head.png",
    line_length = 16,
    width = 45,
    height = 39,
    frame_count = 16,
    animation_speed = 0.5,
    blend_mode = beam_blend_mode,
  },
  tail =
  {
    filename = "__base__/graphics/entity/beam/beam-tail.png",
    line_length = 16,
    width = 45,
    height = 39,
    frame_count = 16,
    blend_mode = beam_blend_mode,
  },
  body =
  {
    {
      filename = "__base__/graphics/entity/beam/beam-body-1.png",
      line_length = 16,
      width = 45,
      height = 39,
      frame_count = 16,
      blend_mode = beam_blend_mode,
    },
    {
      filename = "__base__/graphics/entity/beam/beam-body-2.png",
      line_length = 16,
      width = 45,
      height = 39,
      frame_count = 16,
      blend_mode = beam_blend_mode,
    },
    {
      filename = "__base__/graphics/entity/beam/beam-body-3.png",
      line_length = 16,
      width = 45,
      height = 39,
      frame_count = 16,
      blend_mode = beam_blend_mode,
    },
    {
      filename = "__base__/graphics/entity/beam/beam-body-4.png",
      line_length = 16,
      width = 45,
      height = 39,
      frame_count = 16,
      blend_mode = beam_blend_mode,
    },
    {
      filename = "__base__/graphics/entity/beam/beam-body-5.png",
      line_length = 16,
      width = 45,
      height = 39,
      frame_count = 16,
      blend_mode = beam_blend_mode,
    },
    {
      filename = "__base__/graphics/entity/beam/beam-body-6.png",
      line_length = 16,
      width = 45,
      height = 39,
      frame_count = 16,
      blend_mode = beam_blend_mode,
    },
  }
  }}
}

})