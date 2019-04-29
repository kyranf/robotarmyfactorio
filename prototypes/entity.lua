-- use the base game's power armour animations/sprites for the droids and terminators
require("prototypes.droid-animations")
require("config.config")

-- DONT FORGET TO ADD ANY NEW LOCAL TABLE DEFINITIONS TO THE DATA:EXTEND THING AT THE BOTTOM!

droidscale = 0.8
droidSmgTint =  {r=0.8, g=1, b=1, a=1}
droidFlameTint = {r=1.0, g=0.5, b=0.5, a=1}
droidRocketTint = {r=0.8, g=0.8, b=1, a=1}
droidRifleTint = {r=0.8, g=1, b=0.8, a=1}
droidMapColour = {r = .05, g = .70, b = .29}


circuit_connector_definitions["loot_box"] = circuit_connector_definitions.create
(
  universal_connector_template,
  {
    { variation = 18,
    main_offset = util.by_pixel(2.5, 18.0),
    shadow_offset = util.by_pixel(2.0, 18.0),
    show_shadow = false },
  }
)


function make_laser_sounds(volume)
    return
    {
      {
        filename = "__base__/sound/fight/laser-1.ogg",
        volume = 0.7
      },
      {
        filename = "__base__/sound/fight/laser-2.ogg",
        volume = 0.7
      },
      {
        filename = "__base__/sound/fight/laser-3.ogg",
        volume = 0.7
      }
    }
end

function make_heavy_shot_sounds(volume)
	return
	{
	 {
        filename = "__base__/sound/fight/heavy-gunshot-1.ogg",
        volume = 0.45
      },
      {
        filename = "__base__/sound/fight/heavy-gunshot-2.ogg",
        volume = 0.45
      },
      {
        filename = "__base__/sound/fight/heavy-gunshot-3.ogg",
        volume = 0.45
      },
      {
        filename = "__base__/sound/fight/heavy-gunshot-4.ogg",
        volume = 0.45
      }
	}
end


function make_light_gunshot_sounds(volume)
    return
    {
      {
        filename = "__base__/sound/fight/light-gunshot-1.ogg",
        volume = 0.7
      },
      {
        filename = "__base__/sound/fight/light-gunshot-2.ogg",
        volume = 0.7
      },
      {
        filename = "__base__/sound/fight/light-gunshot-3.ogg",
        volume = 0.7
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
    icon_size = 32,
    icon = "__base__/graphics/icons/player.png",
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
	  animation =
		 {
		  filename = "__robotarmy__/graphics/entity/smg_idle.png",
		  priority = "high",
		  width = 80,
		  height = 80,
		  tint = droidSmgTint,
		  direction_count = 8,
		  frame_count = 1,
		  animation_speed = 0.3,
		  shift = {0, 0}
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
                damage = { amount = 8*DAMAGE_SCALAR , type = "physical"}
              }
            }
          }
        }
      }
    },
	idle =
	{
	  filename = "__robotarmy__/graphics/entity/smg_run.png",
	  priority = "high",
	  width = 80,
	  height = 80,
	  tint = droidSmgTint,
	  direction_count = 22,
	  frame_count = 1,
	  animation_speed = 0.3,
	  shift = {0, 0}	
	},
	run_animation =
	{
	  filename = "__robotarmy__/graphics/entity/smg_run.png",
	  priority = "high",
	  width = 80,
	  height = 80,
	  tint = droidSmgTint,
	  direction_count = 22,
	  frame_count = 1,
	  animation_speed = 0.3,
	  shift = {0, 0}	
	}
}


local droid_flame = 
{
    type = "unit",
    name = "droid-flame",
    icon_size = 32,
    icon = "__base__/graphics/icons/player.png",
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
      animation =
	  {
			filename = "__robotarmy__/graphics/entity/flame_run.png",
			priority = "high",
			width = 80,
			height = 80,
			tint = droidFlameTint,
			direction_count = 22,
			frame_count = 1,
			animation_speed = 0.3,
			shift = {0, 0}	
	  },
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
	idle =
	{
	  filename = "__robotarmy__/graphics/entity/flame_run.png",
	  priority = "high",
	  width = 80,
	  height = 80,
	  tint = droidFlameTint,
	  direction_count = 22,
	  frame_count = 1,
	  animation_speed = 0.3,
	  shift = {0, 0}	
	},
	run_animation =
	{
	  filename = "__robotarmy__/graphics/entity/flame_run.png",
	  priority = "high",
	  width = 80,
	  height = 80,
	  tint = droidFlameTint,
	  direction_count = 22,
	  frame_count = 1,
	  animation_speed = 0.3,
	  shift = {0, 0}	
	}
}

local droid_rifle = 
{
    type = "unit",
    name = "droid-rifle",
    icon_size = 32,
    icon = "__base__/graphics/icons/player.png",
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
	  animation =
		 {
		  filename = "__robotarmy__/graphics/entity/rifle_idle.png",
		  priority = "high",
		  scale = droidscale,
		  width = 80,
		  height = 80,
		  tint = droidRifleTint,
		  direction_count = 8,
		  frame_count = 1,
		  animation_speed = 0.3,
		  shift = {0, 0}
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
                damage = { amount = 10*DAMAGE_SCALAR , type = "physical"}
              }
            }
          }
        }
      }
    },
	idle =
	{
	  filename = "__robotarmy__/graphics/entity/rifle_run.png",
	  priority = "high",
	  width = 80,
	  height = 80,
	  scale = droidscale,
	  tint = droidRifleTint,
	  direction_count = 22,
	  frame_count = 1,
	  animation_speed = 0.3,
	  shift = {0, 0}	
	},
	run_animation =
	{
	  filename = "__robotarmy__/graphics/entity/rifle_run.png",
	  priority = "high",
	  width = 80,
	  height = 80,
	  tint = droidRifleTint,
	  direction_count = 22,
	  scale = droidscale,
	  frame_count = 1,
	  animation_speed = 0.3,
	  shift = {0, 0}	
	}
}


local droid_rocket = 
{
    type = "unit",
    name = "droid-rocket",
    icon_size = 32,
    icon = "__base__/graphics/icons/player.png",
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
      animation =
		 {
			  filename = "__robotarmy__/graphics/entity/rocket_idle.png",
			  priority = "high",
			  width = 80,
			  height = 80,
			  tint = droidRocketTint,
			  direction_count = 8,
			  frame_count = 1,
			  animation_speed = 0.15,
			  shift = {0, 0}
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
	  filename = "__robotarmy__/graphics/entity/rocket_idle.png",
	  priority = "high",
	  width = 80,
	  height = 80,
	  tint = droidRocketTint,
	  direction_count = 8,
	  frame_count = 1,
	  animation_speed = 0.3,
	  shift = {0, 0}	
	},
	run_animation =
	{
	  filename = "__robotarmy__/graphics/entity/rocket_run.png",
	  priority = "high",
	  width = 80,
	  height = 80,
	  tint = droidRocketTint,
	  direction_count = 22,
	  frame_count = 1,
	  animation_speed = 0.3,
	  shift = {0, 0}	
	}
}

local terminator = 
{
	type = "unit",
  name = "terminator",
  icon_size = 32,
  icon = "__robotarmy__/graphics/icons/terminator.png",
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
      ammo_category = "combat-robot-laser",
      cooldown = 10,
      projectile_center = {0, 0.4},
      projectile_creation_distance = 1.5,
      range = 15,
      sound = make_laser_sounds(1),
	  animation =
		 {
			  filename = "__robotarmy__/graphics/entity/terminator_idle.png",
			  priority = "high",
			  width = 80,
			  height = 80,
			  direction_count = 8,
			  frame_count = 1,
			  animation_speed = 0.15,
			  shift = {0, 0}
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
	  filename = "__robotarmy__/graphics/entity/terminator_run.png",
	  priority = "very-low",
	  width = 80,
	  height = 80,
	  direction_count = 22,
	  frame_count = 1,
	  animation_speed = 0.5,
	  shift = {0, 0}
	},
	run_animation =
	{
	  filename = "__robotarmy__/graphics/entity/terminator_run.png",
	  priority = "high",
	  width = 80,
	  height = 80,
	  direction_count = 22,
	  frame_count = 1,
	  animation_speed = 0.5,
	  shift = {0, 0}
	}
}

local droid_counter =  {
    type = "constant-combinator",
    name = "droid-counter",
    icon_size = 32,
    icon = "__robotarmy__/graphics/icons/droid-counter.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "droid-counter"},
    max_health = 50,
    corpse = "small-remnants",

    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},

    item_slot_count = 6,

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
      filename = "__base__/graphics/entity/combinator/activity-leds/arithmetic-combinator-LED-N.png",
      width = 8,
      height = 8,
      frame_count = 1,
      shift = util.by_pixel(8, -12),
      hr_version =
      {
        scale = 0.5,
        filename = "__base__/graphics/entity/combinator/activity-leds/hr-arithmetic-combinator-LED-N.png",
        width = 16,
        height = 14,
        frame_count = 1,
        shift = util.by_pixel(8.5, -12.5),
      },
    },
    east =
    {
      filename = "__base__/graphics/entity/combinator/activity-leds/arithmetic-combinator-LED-E.png",
      width = 8,
      height = 8,
      frame_count = 1,
      shift = util.by_pixel(17, -1),
      hr_version =
      {
        scale = 0.5,
        filename = "__base__/graphics/entity/combinator/activity-leds/hr-arithmetic-combinator-LED-E.png",
        width = 14,
        height = 14,
        frame_count = 1,
        shift = util.by_pixel(16.5, -1),
      },
    },
    south =
    {
      filename = "__base__/graphics/entity/combinator/activity-leds/arithmetic-combinator-LED-S.png",
      width = 8,
      height = 8,
      frame_count = 1,
      shift = util.by_pixel(-8, 7),
      hr_version =
      {
        scale = 0.5,
        filename = "__base__/graphics/entity/combinator/activity-leds/hr-arithmetic-combinator-LED-S.png",
        width = 16,
        height = 16,
        frame_count = 1,
        shift = util.by_pixel(-8, 7.5),
      },
    },
    west =
    {
      filename = "__base__/graphics/entity/combinator/activity-leds/arithmetic-combinator-LED-W.png",
      width = 8,
      height = 8,
      frame_count = 1,
      shift = util.by_pixel(-16, -12),
      hr_version =
      {
        scale = 0.5,
        filename = "__base__/graphics/entity/combinator/activity-leds/hr-arithmetic-combinator-LED-W.png",
        width = 14,
        height = 14,
        frame_count = 1,
        shift = util.by_pixel(-16, -12.5),
      },
    },
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
      {0.5, 0},
      {-0.265625, 0.140625},
      {-0.453125, -0.359375}
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

local droid_settings =  {
    type = "constant-combinator",
    name = "droid-settings",
    icon_size = 32,
    icon = "__robotarmy__/graphics/icons/droid-settings.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "droid-settings"},
    max_health = 50,
    corpse = "small-remnants",

    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},

    item_slot_count = 6,
	--Lol, i just forced them all to be the same sprite, no matter the rotation. Cheeky I know!
    sprites =
    {
      north =
      {
        filename = "__robotarmy__/graphics/entity/droid-settings.png",
		--x = 106,
     	width = 53,
	    height = 44,
		frame_count = 1,
	    shift = {0.0, 0},
      },
      east =
      {
        filename = "__robotarmy__/graphics/entity/droid-settings.png",
		--x = 159,
     	width = 53,
	    height = 44,
		frame_count = 1,
	    shift = {0.0, 0},
      },
      south =
      {
        filename = "__robotarmy__/graphics/entity/droid-settings.png",
		width = 53,
	    height = 44,
		frame_count = 1,
	    shift = {0.0, 0},
      },
      west =
      {
        filename = "__robotarmy__/graphics/entity/droid-settings.png",
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
    },
    east =
    {
      filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-E.png",
      width = 8,
      height = 8,
      frame_count = 1,
      shift = util.by_pixel(8, 0),
      hr_version =
      {
        scale = 0.5,
        filename = "__base__/graphics/entity/combinator/activity-leds/hr-constant-combinator-LED-E.png",
        width = 14,
        height = 14,
        frame_count = 1,
        shift = util.by_pixel(7.5, -0.5),
      },
    },
    south =
    {
      filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-S.png",
      width = 8,
      height = 8,
      frame_count = 1,
      shift = util.by_pixel(-9, 2),
      hr_version =
      {
        scale = 0.5,
        filename = "__base__/graphics/entity/combinator/activity-leds/hr-constant-combinator-LED-S.png",
        width = 14,
        height = 16,
        frame_count = 1,
        shift = util.by_pixel(-9, 2.5),
      },
    },
    west =
    {
      filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-W.png",
      width = 8,
      height = 8,
      frame_count = 1,
      shift = util.by_pixel(-7, -15),
      hr_version =
      {
        scale = 0.5,
        filename = "__base__/graphics/entity/combinator/activity-leds/hr-constant-combinator-LED-W.png",
        width = 14,
        height = 16,
        frame_count = 1,
        shift = util.by_pixel(-7, -15),
      },
    },
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
    icon_size = 34,
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
    circuit_wire_connection_point = circuit_connector_definitions["loot_box"].points,
    circuit_connector_sprites = circuit_connector_definitions["loot_box"].sprites,
    circuit_wire_max_distance = 7.5
 }
 
 local selection_sticker ={
  type = "sticker",
  name = "selection-sticker",
  flags = {"not-on-map"},
  icon_size = 32,
  icon = "__robotarmy__/graphics/icons/unit-selection.png",
  flags = {},
  animation =
  {
    filename = "__robotarmy__/graphics/icons/unit-selection.png",
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

  
 
