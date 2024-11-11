--require the config file for damage scalar
require("config.config")

local dual_laser =
{
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
          damage = {amount = 30*DAMAGE_SCALAR, type = "laser"}
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

local droid_rocket =
{
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
          type = "damage",
          damage = {amount = 275*DAMAGE_SCALAR, type = "explosion"}
        },
        {
          type = "create-entity",
          entity_name = "small-scorchmark",
          check_buildability = true
        }
      }
    }
  },
  light = {intensity = 0.5, size = 4},
  animation = require("__base__.prototypes.entity.rocket-projectile-pictures").animation({0.5, 1.0, 0.05}),
  shadow = require("__base__.prototypes.entity.rocket-projectile-pictures").shadow,
  smoke = require("__base__.prototypes.entity.rocket-projectile-pictures").smoke
}


data:extend({dual_laser, droid_rocket})