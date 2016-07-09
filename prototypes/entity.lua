-- use the base game's power armour animations/sprites for the droids and terminators
require("prototypes.droid-animations")
require("config.config")

-- DONT FORGET TO ADD ANY NEW LOCAL TABLE DEFINITIONS TO THE DATA:EXTEND THING AT THE BOTTOM!

droidscale = 1.0
droidSmgTint =  {r=0.9, g=0.9, b=0.1, a=1}
droidRocketTint = {r=0.2, g=0.2, b=0.8, a=1}
droidRifleTint = {r=0.2, g=0.8, b=0.2, a=1}

function make_laser_sounds(volume)
    return
    {
      {
        filename = "__base__/sound/fight/laser-1.ogg",
        volume = 0.5
      },
      {
        filename = "__base__/sound/fight/laser-2.ogg",
        volume = 0.5
      },
      {
        filename = "__base__/sound/fight/laser-3.ogg",
        volume = 0.5
      }
    }
end


function make_light_gunshot_sounds(volume)
    return
    {
      {
        filename = "__base__/sound/fight/light-gunshot-1.ogg",
        volume = 0.3
      },
      {
        filename = "__base__/sound/fight/light-gunshot-2.ogg",
        volume = 0.3
      },
      {
        filename = "__base__/sound/fight/light-gunshot-3.ogg",
        volume = 0.3
      }
    }
end

function make_rifle_gunshot_sounds(volume)
    return
    {
      {
        filename = "__base__/sound/fight/light-gunshot-1.ogg",
        volume = 1
      },
      {
        filename = "__base__/sound/fight/light-gunshot-2.ogg",
        volume = 1
      },
      {
        filename = "__base__/sound/fight/light-gunshot-3.ogg",
        volume = 1
      }
    }
end

local droid_smg = 
{
    type = "unit",
    name = "droid-smg",
    icon = "__base__/graphics/icons/player.png",
    flags = {"placeable-player", "player-creation", "placeable-off-grid"},
    subgroup="creatures",
    order="e-a-b-d",
    max_health = 120 * HEALTH_SCALAR,
    alert_when_damaged = false,
    healing_per_tick = 0.01,
    collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
    selection_box = {{-0.4, -1.4}, {0.4, 0.2}},
    sticker_box = {{-0.3, -0.5}, {0.3, 0.1}},
	vision_distance = 30,
    movement_speed = 0.11,
	minable = {hardness = 0.1, mining_time = 0.1, result = "droid-smg"},
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
        percent = 70
      },
      {
        type = "acid",
        decrease = 1,
        percent = 30
      },
	  {
        type = "fire",
        percent = 75
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
      cooldown = 10,
      projectile_center = {0, 0.5},
      projectile_creation_distance = 0.6,
      range = 13,
      sound = make_light_gunshot_sounds(),
	  animation =
		 {
			filename = "__base__/graphics/entity/player/player-basic-idle-gun.png",
			  priority = "very-low",
			  width = 65,
			  height = 74,
			  tint = droidSmgTint,
			  direction_count = 8,
			  frame_count = 22,
			  animation_speed = 0.15,
			  --shift = {-0.015625-.4, -0.53125+.8}
		 },
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
                damage = { amount = 5 , type = "physical"}
              }
            }
          }
        }
      }
    },
	idle =
	{
	  layers =
	  {
		{
		  filename = "__base__/graphics/entity/player/player-basic-idle-gun.png",
		  priority = "very-low",
		  width = 65,
		  height = 74,
		  direction_count = 8,
		  frame_count = 22,
		  tint = droidSmgTint,
		  animation_speed = 0.15,
		  --shift = {-0.015625-.4, -0.53125+.8}
		},
		{
		  filename = "__base__/graphics/entity/player/player-basic-idle-gun-color.png",
		  priority = "very-low",
		  width = 35,
		  height = 43,
		  direction_count = 8,
		  frame_count = 22,
		  tint = droidSmgTint,
		  apply_runtime_tint = true,
		  animation_speed = 0.15,
		  --shift = {-0.046875-.4, -0.703125+.8},
		  apply_runtime_tint = true
		},
	  }
	},
	run_animation =
	{
	  layers =
	  {
		{
		  filename = "__base__/graphics/entity/player/player-basic-run-gun.png",
		  priority = "very-low",
		  width = 61,
		  height = 78,
		  frame_count = 22,
		  direction_count = 18,
		  tint = droidSmgTint,
		  --shift = {0.140625 -.4 , -0.4375 + 0.109375 + .8},
		  distance_per_frame = 0.35,
		  animation_speed = 0.60
		},
		{
		  filename = "__base__/graphics/entity/player/player-basic-run-gun-color.png",
		  priority = "very-low",
		  width = 34,
		  height = 50,
		  frame_count = 22,
		  tint = droidSmgTint,
		  direction_count = 18,
		  apply_runtime_tint = true,
		  --shift = {0.015625-.4,  -0.625 + .8}
		},
	  }
	}
}

local droid_rifle = 
{
    type = "unit",
    name = "droid-rifle",
    icon = "__base__/graphics/icons/player.png",
    flags = {"placeable-player", "player-creation", "placeable-off-grid"},
    subgroup="creatures",
    order="e-a-b-d",
    max_health = 40 * HEALTH_SCALAR,
    alert_when_damaged = false,
    healing_per_tick = 0.00,
    collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
    selection_box = {{-0.4, -1.4}, {0.4, 0.2}},
    sticker_box = {{-0.3, -0.5}, {0.3, 0.1}},
	vision_distance = 30,
    movement_speed = 0.08,
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
        percent = 50
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
      cooldown = 120,
      projectile_center = {0, 0.5},
      projectile_creation_distance = 0.6,
      range = 15,
      sound = make_rifle_gunshot_sounds(1),
	  animation =
		 {
			filename = "__base__/graphics/entity/player/player-basic-idle-gun.png",
			  priority = "very-low",
			  width = 65,
			  height = 74,
			  tint = droidRifleTint,
			  direction_count = 8,
			  frame_count = 22,
			  animation_speed = 0.15,
			  --shift = {-0.015625-.4, -0.53125+.8}
		 },
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
                damage = { amount = 10 , type = "physical"}
              }
            }
          }
        }
      }
    },
	idle =
	{
	  layers =
	  {
		{
		  filename = "__base__/graphics/entity/player/player-basic-idle-gun.png",
		  priority = "very-low",
		  width = 65,
		  height = 74,
		  direction_count = 8,
		  frame_count = 22,
		  tint = droidRifleTint,
		  animation_speed = 0.15,
		  --shift = {-0.015625-.4, -0.53125+.8}
		},
		{
		  filename = "__base__/graphics/entity/player/player-basic-idle-gun-color.png",
		  priority = "very-low",
		  width = 35,
		  height = 43,
		  direction_count = 8,
		  frame_count = 22,
		  tint = droidRifleTint,
		  apply_runtime_tint = true,
		  animation_speed = 0.15,
		  --shift = {-0.046875-.4, -0.703125+.8},
		  apply_runtime_tint = true
		},
	  }
	},
	run_animation =
	{
	  layers =
	  {
		{
		  filename = "__base__/graphics/entity/player/player-basic-run-gun.png",
		  priority = "very-low",
		  width = 61,
		  height = 78,
		  frame_count = 22,
		  direction_count = 18,
		  tint = droidRifleTint,
		  --shift = {0.140625 -.4 , -0.4375 + 0.109375 + .8},
		  distance_per_frame = 0.35,
		  animation_speed = 0.60
		},
		{
		  filename = "__base__/graphics/entity/player/player-basic-run-gun-color.png",
		  priority = "very-low",
		  width = 34,
		  height = 50,
		  frame_count = 22,
		  tint = droidRifleTint,
		  direction_count = 18,
		  apply_runtime_tint = true,
		  --shift = {0.015625-.4,  -0.625 + .8}
		},
	  }
	}
}


local droid_rocket = 
{
    type = "unit",
    name = "droid-rocket",
    icon = "__base__/graphics/icons/player.png",
    flags = {"placeable-player", "player-creation", "placeable-off-grid"},
    subgroup="creatures",
    order="e-a-b-d",
    max_health = 85 * HEALTH_SCALAR,
    alert_when_damaged = false,
    healing_per_tick = 0.01,
    collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
    selection_box = {{-0.4, -1.4}, {0.4, 0.2}},
    sticker_box = {{-0.3, -0.5}, {0.3, 0.1}},
	vision_distance = 30,
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
        percent = 75
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
      projectile_creation_distance = 0.6,
      range = 22,
      projectile_center = {-0.17, 0.2},
      animation =
	  {
			filename = "__base__/graphics/entity/player/player-basic-idle-gun.png",
			  priority = "very-low",
			  width = 65,
			  height = 74,
			  tint = droidRocketTint,
			  direction_count = 8,
			  frame_count = 22,
			  animation_speed = 0.15,
			  --shift = {-0.015625-.4, -0.53125+.8}
	  },
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
	idle =
	{
	  layers =
	  {
		{
		  filename = "__base__/graphics/entity/player/player-basic-idle-gun.png",
		  priority = "very-low",
		  width = 65,
		  height = 74,
		  direction_count = 8,
		  frame_count = 22,
		  tint = droidRocketTint,
		  animation_speed = 0.15,
		  --shift = {-0.015625-.4, -0.53125+.8}
		},
		{
		  filename = "__base__/graphics/entity/player/player-basic-idle-gun-color.png",
		  priority = "very-low",
		  width = 35,
		  height = 43,
		  direction_count = 8,
		  frame_count = 22,
		  tint = droidRocketTint,
		  apply_runtime_tint = true,
		  animation_speed = 0.15,
		  --shift = {-0.046875-.4, -0.703125+.8},
		  apply_runtime_tint = true
		},
	  }
	},
	run_animation =
	{
	  layers =
	  {
		{
		  filename = "__base__/graphics/entity/player/player-basic-run-gun.png",
		  priority = "very-low",
		  width = 61,
		  height = 78,
		  frame_count = 22,
		  direction_count = 18,
		  tint = droidRocketTint,
		  --shift = {0.140625 -.4 , -0.4375 + 0.109375 + .8},
		  distance_per_frame = 0.35,
		  animation_speed = 0.60
		},
		{
		  filename = "__base__/graphics/entity/player/player-basic-run-gun-color.png",
		  priority = "very-low",
		  width = 34,
		  height = 50,
		  frame_count = 22,
		  tint = droidRocketTint,
		  direction_count = 18,
		  apply_runtime_tint = true,
		  --shift = {0.015625-.4,  -0.625 + .8}
		},
	  }
	}
}

local terminator = 
{
	type = "unit",
    name = "terminator",
    icon = "__base__/graphics/icons/player.png",
    flags = {"placeable-player", "player-creation", "placeable-off-grid"},
    subgroup="creatures",
    order="e-a-b-d",
    max_health = 300 * HEALTH_SCALAR,
    alert_when_damaged = false,
    healing_per_tick = 0.02,
    collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
    selection_box = {{-0.4, -1.4}, {0.4, 0.2}},
    sticker_box = {{-0.3, -0.5}, {0.3, 0.1}},
	vision_distance = 30,
    movement_speed = 0.20,
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
        type = "fire",
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
      ammo_category = "combat-robot-laser",
      cooldown = 10,
      projectile_center = {0, 0.2},
      projectile_creation_distance = 0.8,
      range = 16,
      sound = make_laser_sounds(1),
	  animation =
		 {
			layers =
			  {
				droidanimations.level1.idle,
				droidanimations.level1.idlemask,
				droidanimations.level3addon.idle,
				droidanimations.level3addon.idlewmask,
			  }
		 },
      ammo_type =
      {
        type = "projectile",
        category = "combat-robot-laser",
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
	idle =
	{
	  layers =
	  {
		droidanimations.level1.idle,
		droidanimations.level1.idlemask,
		droidanimations.level3addon.idle,
		droidanimations.level3addon.idlewmask,
	  }
	},
	run_animation =
	{
	  layers =
	  {
		droidanimations.level1.running,
		droidanimations.level1.runningmask,
		droidanimations.level3addon.running,
		droidanimations.level3addon.runningmask,
	  }
	}
}

local droid_counter =  {
    type = "constant-combinator",
    name = "droid-counter",
    icon = "__robotarmy__/graphics/icons/droid-counter.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "droid-counter"},
    max_health = 50,
    corpse = "small-remnants",

    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},

    item_slot_count = 2,

    sprites =
    {
      north =
      {
        filename = "__robotarmy__/graphics/entity/droid-counter.png",
		--x = 106,
     	width = 53,
	    height = 44,
		frame_count = 1,
	    shift = {0.0, 0},
      },
      east =
      {
        filename = "__robotarmy__/graphics/entity/droid-counter.png",
		--x = 159,
     	width = 53,
	    height = 44,
		frame_count = 1,
	    shift = {0.0, 0},
      },
      south =
      {
        filename = "__robotarmy__/graphics/entity/droid-counter.png",
		width = 53,
	    height = 44,
		frame_count = 1,
	    shift = {0.0, 0},
      },
      west =
      {
        filename = "__robotarmy__/graphics/entity/droid-counter.png",
		--x = 106,
     	width = 53,
	    height = 44,
		frame_count = 1,
	    shift = {0.0, 0},
      }
    },
	 activity_led_sprites =
    {
      north =
      {
        filename = "__base__/graphics/entity/combinator/activity-leds/combinator-led-constant-north.png",
        width = 11,
        height = 10,
        frame_count = 1,
        shift = {0.296875, -0.40625},
      },
      east =
      {
        filename = "__base__/graphics/entity/combinator/activity-leds/combinator-led-constant-east.png",
        width = 14,
        height = 12,
        frame_count = 1,
        shift = {0.25, -0.03125},
      },
      south =
      {
        filename = "__base__/graphics/entity/combinator/activity-leds/combinator-led-constant-south.png",
        width = 11,
        height = 11,
        frame_count = 1,
        shift = {-0.296875, -0.078125},
      },
      west =
      {
        filename = "__base__/graphics/entity/combinator/activity-leds/combinator-led-constant-west.png",
        width = 12,
        height = 12,
        frame_count = 1,
        shift = {-0.21875, -0.46875},
      }
    },

    activity_led_light =
    {
      intensity = 0.8,
      size = 1,
    },

    activity_led_light_offsets =
    {
      {0.296875, -0.40625},
      {0.25, -0.03125},
      {-0.296875, -0.078125},
      {-0.21875, -0.46875}
    },
    circuit_wire_connection_points =
    {
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
      },
      {
        shadow =
        {
          red = {0.75, -0.15625},
          green = {0.75, 0.25},
        },
        wire =
        {
          red = {0.46875, -0.5},
          green = {0.46875, -0.09375},
        }
      },
      {
        shadow =
        {
          red = {0.75, 0.5625},
          green = {0.21875, 0.5625}
        },
        wire =
        {
          red = {0.28125, 0.15625},
          green = {-0.21875, 0.15625}
        }
      },
      {
        shadow =
        {
          red = {-0.03125, 0.28125},
          green = {-0.03125, -0.125},
        },
        wire =
        {
          red = {-0.46875, 0},
          green = {-0.46875, -0.40625},
        }
      }
	},
    circuit_wire_max_distance = 10
  
}


local loot_chest = {
    type = "container",
    name = "loot-chest",
    icon = "__robotarmy__/graphics/icons/loot-chest.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 1, result = "loot-chest"},
    max_health = 400,
    corpse = "small-remnants",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
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
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    picture =
    {
      filename = "__robotarmy__/graphics/entity/loot-chest.png",
      priority = "extra-high",
      width = 48,
      height = 34,
      shift = {0.1875, 0}
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
    circuit_connector_sprites = get_circuit_connector_sprites({0.1875, 0.15625}, nil, 18),
    circuit_wire_max_distance = 7.5
 }

 -- extend the game data with the new entity definitions
data:extend({droid_smg, droid_rocket, droid_rifle, terminator, droid_counter, loot_chest})

  
 
