
droidscale = 1.0
droidtint =  {r=0.8, g=0.2, b=0.2, a=1}

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


data:extend(
{
 {
    type = "unit",
    name = "droid",
    icon = "__base__/graphics/icons/player.png",
    flags = {"placeable-player", "player-creation","placeable-enemy", "placeable-off-grid"},
    subgroup="creatures",
    order="e-a-b-d",
    max_health = 65,
    alert_when_damaged = false,
    healing_per_tick = 0.01,
    collision_box = {{-0.3, -0.3}, {0.3, 0.3}},
    selection_box = {{-0.4, -0.4}, {0.4, 0.4}},
    sticker_box = {{-0.3, -0.5}, {0.3, 0.1}},
	vision_distance = 30,
    movement_speed = 0.1,
	pollution_to_join_attack = 0.0,
	distraction_cooldown = 0,
    distance_per_frame = 0.04,
	dying_explosion = "medium-explosion",
    follows_player = true,
    range_from_player = 3.0,
    speed = 0.01,
	tint = droidtint,
	scale = droidscale,
	resistances =
    {
      {
        type = "physical",
        decrease = 1,
        percent = 30
      },
      {
        type = "explosion",
        decrease = 10,
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
            damage = { amount = 1000, type = "explosion"}
          }
        }
      }
 
    },
    attack_parameters =
    {
      type = "projectile",
      ammo_category = "bullet",
      cooldown = 20,
      projectile_center = {0, 1},
      projectile_creation_distance = 0.6,
      range = 13,
      sound = make_light_gunshot_sounds(),
	  animation =
		 {
			filename = "__base__/graphics/entity/player/player-basic-idle-gun.png",
			  priority = "very-low",
			  width = 65,
			  height = 74,
			  tint = droidtint,
			  direction_count = 8,
			  frame_count = 22,
			  animation_speed = 0.15,
			  shift = {-0.015625, -0.53125}
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
			  tint = droidtint,
			  animation_speed = 0.15,
			  shift = {-0.015625, -0.53125}
			},
			{
			  filename = "__base__/graphics/entity/player/player-basic-idle-gun-color.png",
			  priority = "very-low",
			  width = 35,
			  height = 43,
			  direction_count = 8,
			  frame_count = 22,
			  tint = droidtint,
			  apply_runtime_tint = true,
			  animation_speed = 0.15,
			  shift = {-0.046875, -0.703125},
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
			  tint = droidtint,
			  shift = {0.140625, -0.4375 + 0.109375},
			  distance_per_frame = 0.35,
			  animation_speed = 0.60
			},
			{
			  filename = "__base__/graphics/entity/player/player-basic-run-gun-color.png",
			  priority = "very-low",
			  width = 34,
			  height = 50,
			  frame_count = 22,
			  tint = droidtint,
			  direction_count = 18,
			  apply_runtime_tint = true,
			  shift = {0.015625,  -0.625}
			},
		  }
		},
    
	light =
    {
      {
        minimum_darkness = 0.3,
        intensity = 0.4,
        size = 25,
      },
      {
        type = "oriented",
        minimum_darkness = 0.3,
        picture =
        {
          filename = "__core__/graphics/light-cone.png",
          priority = "medium",
          scale = 2,
          width = 200,
          height = 200
        },
        shift = {0, -13},
        size = 2,
        intensity = 0.6
      },
    },
  }
}
  )