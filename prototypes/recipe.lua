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
    name = "terminator",
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
    result = "terminator"
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
}
)