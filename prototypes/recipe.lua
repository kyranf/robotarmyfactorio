data:extend(
{
  {
    type = "recipe",
    name = "droid-smg",
    enabled = false,
	category = "advanced-crafting",
    energy_required = 10,
    ingredients =
    {
      {"steel-plate", 5},
	  {"electronic-circuit", 15},
	  {"submachine-gun", 1},
	  {"light-armor", 1}
    },
    result = "droid-smg"
  },
  {
    type = "recipe",
    name = "droid-rifle",
    enabled = false,
	category = "advanced-crafting",
    energy_required = 5,
    ingredients =
    {
      {"copper-plate", 20},
	  {"electronic-circuit", 5},
	  {"iron-gear-wheel", 10},
    },
    result = "droid-rifle"
  },
  {
    type = "recipe",
    name = "droid-rocket",
    enabled = false,
	category = "advanced-crafting",
    energy_required = 5,
    ingredients =
    {
      {"steel-plate", 5},
	  {"electronic-circuit", 25},
	  {"rocket-launcher", 1},
	  {"light-armor", 1}
    },
    result = "droid-rocket"
  },
  {
    type = "recipe",
    name = "terminator",
    enabled = false,
	category = "advanced-crafting",
    energy_required = 10,
    ingredients =
    {
      {"steel-plate", 10},
	  {"laser-turret", 2},
	  {"processing-unit", 10},
	  {"modular-armor", 1}
    },
    result = "terminator"
  },
    {
    type = "recipe",
    name = "terminator-deploy",
    enabled = false,
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
      {"electronic-circuit", 100},
      {"iron-gear-wheel", 50},
      {"assembling-machine-1", 1}
    },
    result = "droid-assembling-machine"
  },
  {
    type = "recipe",
    name = "droid-guard-station",
    enabled = true,
    ingredients =
    {
      {"iron-plate", 10},
      {"electronic-circuit", 100},
      {"iron-gear-wheel", 50},
      {"assembling-machine-1", 1}
    },
    result = "droid-guard-station"
  },
  {
    type = "recipe",
    name = "droid-smg-deploy",
    enabled = false,
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
    enabled = false,
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
    enabled = false,
	category = "droids",
    ingredients =
    {
      {"droid-rifle", 1}
      
    },
    result = "droid-rifle-dummy"
  },   
 {
    type = "recipe",
    name = "droid-counter",
    enabled = "false",
    ingredients =
    {
      {"constant-combinator", 1},
      {"iron-plate",20},
      {"electronic-circuit", 25},
    },
    result="droid-counter",
  },
  {
    type = "recipe",
    name = "loot-chest",
    enabled = false,
	ingredients =
	{
	  {"steel-plate",20},
	  {"electronic-circuit", 25},
	},	
    result = "loot-chest",
	requester_paste_multiplier = 1
  },
  {  
    type = "recipe",
    name = "rally-beacon",
    enabled = true,
	ingredients =
	{
	  {"steel-plate",20},
	  {"electronic-circuit", 25},
	},	
    result = "rally-beacon",
	requester_paste_multiplier = 1
  }
})


  
 -- deal with unlocking the recipes just piggy-backing on military research for now. most droids need more advanced research to build them anyway.
table.insert(data.raw["technology"]["military"].effects,{type="unlock-recipe",recipe="droid-rifle"})
table.insert(data.raw["technology"]["military"].effects,{type="unlock-recipe",recipe="droid-rifle-deploy"})
table.insert(data.raw["technology"]["military"].effects,{type="unlock-recipe",recipe="loot-chest"})
table.insert(data.raw["technology"]["military-2"].effects,{type="unlock-recipe",recipe="droid-smg-deploy"})
table.insert(data.raw["technology"]["military-2"].effects,{type="unlock-recipe",recipe="droid-smg"})
table.insert(data.raw["technology"]["military-2"].effects,{type="unlock-recipe",recipe="droid-rocket-deploy"})
table.insert(data.raw["technology"]["military-2"].effects,{type="unlock-recipe",recipe="droid-rocket"})
table.insert(data.raw["technology"]["military-3"].effects,{type="unlock-recipe",recipe="terminator-deploy"})
table.insert(data.raw["technology"]["military-3"].effects,{type="unlock-recipe",recipe="terminator"})  
table.insert(data.raw["technology"]["electronics"].effects,{type="unlock-recipe",recipe="droid-counter"})  