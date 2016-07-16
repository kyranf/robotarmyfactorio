local dual_laser = {
    type = "projectile",
    name = "laser-dual",
    flags = {"not-on-map"},
    acceleration = 0.01,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "create-entity",
            entity_name = "laser-bubble"
          },
          {
            type = "damage",
            damage = { amount = 30, type = "laser"}
          }
        }
      }
    },
    light = {intensity = 0.7, size = 20},
    animation =
    {
      filename = "__robotarmy__/graphics/entity/laser/dual-laser.png",
      tint = {r=1.0, g=0.0, b=0.0},
      frame_count = 1,
      width = 24,
      height = 33,
      priority = "high",
      blend_mode = "additive"
    },
    speed = 0.3
  }

 local droid_rocket = {
    type = "projectile",
    name = "droid-explosive-rocket",
    flags = {"not-on-map"},
    acceleration = 0.035,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
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
              perimeter = 0,
              action_delivery =
              {
                type = "instant",
                target_effects =
                {
                  {
                    type = "damage",
                    damage = {amount = 300, type = "explosion"}
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
            },
          }
        }
      }
    },
    light = {intensity = 0.5, size = 4},
    animation =
    {
      filename = "__base__/graphics/entity/rocket/rocket.png",
      frame_count = 8,
      line_length = 8,
      width = 9,
      height = 35,
      shift = {0, 0},
      priority = "high"
    },
    shadow =
    {
      filename = "__base__/graphics/entity/rocket/rocket-shadow.png",
      frame_count = 1,
      width = 7,
      height = 24,
      priority = "high",
      shift = {0, 0}
    },
    smoke =
    {
      {
        name = "smoke-fast",
        deviation = {0.15, 0.15},
        frequency = 1,
        position = {0, -1},
        slow_down_factor = 1,
        starting_frame = 3,
        starting_frame_deviation = 5,
        starting_frame_speed = 0,
        starting_frame_speed_deviation = 5
      }
    }
  }
  
  
  data:extend({dual_laser, droid_rocket})