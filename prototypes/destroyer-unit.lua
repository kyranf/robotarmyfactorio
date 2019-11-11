require("config.config")
data:extend({
{
    type = "unit",
    name = "destroyer-unit",
    icon_size = 32,
    icon = "__base__/graphics/icons/destroyer.png",
	flags = {"placeable-player", "player-creation", "placeable-off-grid"},
    subgroup="creatures",
    has_belt_immunity = true,
    max_health = 120 * HEALTH_SCALAR,
  minable = {hardness = 0.1, mining_time = 0.1, result = "destroyer-unit"},
  alert_when_damaged = false,
  order="b-b-c",
    resistances =
    {
      {
        type = "physical",
        decrease = 4,
      }
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
      ammo_category = "combat-robot-beam",
      cooldown = 20,
      range = 15,
      min_attack_distance = 9,
      ammo_type =
      {
        category = "combat-robot-beam",
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
      --[[sound =
      {
        {
          filename = "__base__/sound/fight/rocket-launcher.ogg",
          volume = 0.7
        }
      },]]--
      animation =
    {   
      layers =
      {
        {
          filename = "__base__/graphics/entity/destroyer-robot/destroyer-robot.png",
          priority = "high",
          line_length = 32,
          width = 45,
          height = 39,
          y = 39,
          frame_count = 1,
          direction_count = 32,
          shift = {0.078125, -0.046875},
        },
        {
          filename = "__base__/graphics/entity/destroyer-robot/destroyer-robot-mask.png",
          priority = "high",
          line_length = 32,
          width = 27,
          height = 21,
          y = 21,
          frame_count = 1,
          direction_count = 32,
          shift = {0.078125, -0.234375},
          apply_runtime_tint = true
        },
        {
      filename = "__base__/graphics/entity/destroyer-robot/destroyer-robot-shadow.png",
      priority = "high",
      line_length = 32,
      width = 48,
      height = 32,
      frame_count = 1,
      direction_count = 32,
      shift = {0.78125, 0.5}
    },
      }
     }
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
    working_sound = {
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
        filename = "__base__/sound/fight/small-explosion-1.ogg",
        volume = 0.5
      },
      {
        filename = "__base__/sound/fight/small-explosion-2.ogg",
        volume = 0.5
      }
    },
    run_animation = {
      layers =
      {
        {
          filename = "__base__/graphics/entity/destroyer-robot/destroyer-robot.png",
          priority = "high",
          line_length = 32,
          width = 45,
          height = 39,
          y = 39,
          frame_count = 1,
          direction_count = 32,
          shift = {0.078125, -0.046875},
        },
        {
          filename = "__base__/graphics/entity/destroyer-robot/destroyer-robot-mask.png",
          priority = "high",
          line_length = 32,
          width = 27,
          height = 21,
          y = 21,
          frame_count = 1,
          direction_count = 32,
          shift = {0.078125, -0.234375},
          apply_runtime_tint = true
        },
        {
      filename = "__base__/graphics/entity/destroyer-robot/destroyer-robot-shadow.png",
      priority = "high",
      line_length = 32,
      width = 48,
      height = 32,
      frame_count = 1,
      direction_count = 32,
      shift = {0.78125, 0.5}
    },
      }
    },
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
    --working_sound =    
    --{
     -- {
      --  filename = "__base__/sound/fight/electric-beam.ogg",
       -- volume = 0.7
      --}
    --}
  }
  
})