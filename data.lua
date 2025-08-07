data:extend({
  {
    type = "int-setting",
    name = "robotarmy-qrf-distance",
    setting_type = "startup",
    default_value = 0,
    minimum_value = 0,
    maximum_value = 500,
    order = "a[qrf]"
  }
})
require("config.config")
require("prototypes.technology")
require("prototypes.item") -- any buildable or placable object/entity needs this
require("prototypes.building")
require("prototypes.entity") -- any buildable or placable object/entity needs this
require("prototypes.recipe")
require("prototypes.signals")
require("prototypes.projectiles.projectiles")
require("prototypes.corpses")
require("prototypes.destroyer-unit")
require("prototypes.distractor-unit")
require("prototypes.defender-unit")
require("prototypes.inputs")
