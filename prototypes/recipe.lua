data:extend(
{
  {
    type = "recipe",
    name = "droid-smg",
    enabled = true,
	category = "advanced-crafting",
    energy_required = 10,
    ingredients =
    {
      {"steel-plate", 5},
	  {"electronic-circuit", 5},
	  {"submachine-gun", 1},
	  {"basic-armor", 1}
    },
    result = "droid-smg"
  },
  {
    type = "recipe",
    name = "droid-rifle",
    enabled = true,
	category = "advanced-crafting",
    energy_required = 5,
    ingredients =
    {
      {"copper-plate", 10},
	  {"electronic-circuit", 5},
	  {"iron-gear-wheel", 10},
    },
    result = "droid-rifle"
  },
  {
    type = "recipe",
    name = "droid-rocket",
    enabled = true,
	category = "advanced-crafting",
    energy_required = 5,
    ingredients =
    {
      {"steel-plate", 5},
	  {"electronic-circuit", 5},
	  {"rocket-launcher", 1},
	  {"basic-armor", 1}
    },
    result = "droid-rocket"
  },
  {
    type = "recipe",
    name = "terminator",
    enabled = true,
	category = "advanced-crafting",
    energy_required = 10,
    ingredients =
    {
      {"steel-plate", 10},
	  {"laser-turret", 2},
	  {"processing-unit", 10},
	  {"basic-modular-armor", 1}
    },
    result = "terminator"
  },
    {
    type = "recipe",
    name = "terminator-deploy",
    enabled = true,
	category = "droids",
    energy_required = 10,
    ingredients =
    {
      {"terminator", 1}
    },
    result = "terminator-dummy"
  },
  {
    type = "recipe",
    name = "droid-assembling-machine",
    enabled = true,
    ingredients =
    {
      {"iron-plate", 10},
      {"electronic-circuit", 10},
      {"iron-gear-wheel", 10},
      {"assembling-machine-1", 1}
    },
    result = "droid-assembling-machine"
  },
  {
    type = "recipe",
    name = "droid-smg-deploy",
    enabled = true,
	category = "droids",
    ingredients =
    {
      {"droid-smg", 1}
      
    },
    result = "droid-smg-dummy"
  },
  {
    type = "recipe",
    name = "droid-rocket-deploy",
    enabled = true,
	category = "droids",
    ingredients =
    {
      {"droid-rocket", 1}
      
    },
    result = "droid-rocket-dummy"
  }, 
  {
    type = "recipe",
    name = "droid-rifle-deploy",
    enabled = true,
	category = "droids",
    ingredients =
    {
      {"droid-rifle", 1}
      
    },
    result = "droid-rifle-dummy"
  },   
}
)