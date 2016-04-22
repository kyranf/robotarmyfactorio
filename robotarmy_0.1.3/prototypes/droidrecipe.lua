data:extend(
{
  {
    type = "recipe",
    name = "droid",
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
    result = "droid"
  },
  {
    type = "recipe",
    name = "droid-assembling-machine",
    enabled = true,
    ingredients =
    {
      {"iron-plate", 9},
      {"electronic-circuit", 3},
      {"iron-gear-wheel", 5},
      {"assembling-machine-1", 1}
    },
    result = "droid-assembling-machine"
  },
  {
    type = "recipe",
    name = "droid-deploy",
    enabled = true,
	category = "droids",
    ingredients =
    {
      {"droid", 1}
      
    },
    result = "droid-dummy"
  },
  
  
  
}
)