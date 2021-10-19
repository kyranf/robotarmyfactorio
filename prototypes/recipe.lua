require("config.config")

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
    energy_required = 10,
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
    enabled = false,
    ingredients =
    {
      {"iron-plate", 10},
      {"electronic-circuit", 50},
      {"iron-gear-wheel", 50},
      {"assembling-machine-1", 1}
    },
    result = "droid-assembling-machine"
  },
  {
    type = "recipe",
    name = "droid-guard-station",
    enabled = false,
    ingredients =
    {
      {"iron-plate", 10},
      {"electronic-circuit", 50},
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
    energy_required = 6,
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
    energy_required = 6,
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
    energy_required = 3,
    ingredients =
    {
      {"droid-rifle", 1}

    },
    result = "droid-rifle-dummy"
  },
 {
    type = "recipe",
    name = "droid-counter",
    enabled = false,
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
    name = "droid-settings",
    enabled = false,
    ingredients =
    {
      {"constant-combinator", 1},
      {"iron-plate",20},
      {"electronic-circuit", 25},
    },
    result="droid-settings",
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
    name = "droid-selection-tool",
    enabled = false,
	ingredients =
	{
	  {"electronic-circuit", 1}
	},
    result = "droid-selection-tool",
	requester_paste_multiplier = 1
  },
  {
    type = "recipe",
    name = "droid-pickup-tool",
    enabled = false,
	ingredients =
	{
	  {"electronic-circuit", 1}
	},
    result = "droid-pickup-tool",
	requester_paste_multiplier = 1
  },

   {
    type = "recipe",
    name = "droid-flame",
    enabled = false,
	category = "advanced-crafting",
    energy_required = 10,
	ingredients =
	{
      {"steel-plate", 5},
	  {"electronic-circuit", 25},
	  {"flamethrower", 1},
	  {"light-armor", 2}

	},
    result = "droid-flame",

  },
  {
    type = "recipe",
    name = "droid-flame-deploy",
    enabled = false,
	category = "droids",
    energy_required = 8,
	ingredients =
	{
	  {"droid-flame",1}
	},
    result = "droid-flame-dummy",

  },
  {
    type = "recipe",
    name = "patrol-pole",
    enabled = false,
	ingredients =
	{
	  {"steel-plate",5},
	  {"electronic-circuit", 5},
	},
    result = "patrol-pole",
	requester_paste_multiplier = 1
  },
  -- adding in support for Klonan's Combat Units
  	{
		type = "recipe",
		name = "defender-unit",
		enabled = false,
		category = "advanced-crafting",
		energy_required = 5,
		ingredients =
		{
		  {"piercing-rounds-magazine", 1},
		  {"electronic-circuit", 5},
		  {"iron-gear-wheel", 5},
		},
		result = "defender-unit"
	},
	{
		type = "recipe",
		name = "defender-unit-deploy",
		enabled = false,
		category = "droids",
        energy_required = 3,
		ingredients =
		{
		  {"defender-unit", 1}

		},
		result = "defender-unit-dummy"
	},

  	{
		type = "recipe",
		name = "distractor-unit",
		enabled = false,
		category = "advanced-crafting",
		energy_required = 5,
		ingredients =
		{
		  {"piercing-rounds-magazine", 1},
		  {"advanced-circuit", 3},
		  {"steel-plate", 5},
		},
		result = "distractor-unit"
	},
	{
		type = "recipe",
		name = "distractor-unit-deploy",
        energy_required = 3,
		enabled = false,
		category = "droids",
		ingredients =
		{
		  {"distractor-unit", 1}

		},
		result = "distractor-unit-dummy"
	},

	{
		type = "recipe",
		name = "destroyer-unit",
		enabled = false,
		category = "advanced-crafting",
		energy_required = 8,
		ingredients =
		{
		  {"piercing-rounds-magazine", 5},
		  {"processing-unit", 5},
		  {"steel-plate", 5},
		},
		result = "destroyer-unit"
	},
	{
		type = "recipe",
		name = "destroyer-unit-deploy",
        energy_required = 8,
		enabled = false,
		category = "droids",
		ingredients =
		{
		  {"destroyer-unit", 1}

		},
		result = "destroyer-unit-dummy"
	},

})



 -- deal with unlocking the recipes just piggy-backing on military research for now. most droids need more advanced research to build them anyway.
table.insert(data.raw["technology"]["military"].effects,{type="unlock-recipe",recipe="droid-rifle"})
table.insert(data.raw["technology"]["military"].effects,{type="unlock-recipe",recipe="droid-rifle-deploy"})
if(GRAB_ARTIFACTS == 1) then
    table.insert(data.raw["technology"]["military"].effects,{type="unlock-recipe",recipe="loot-chest"})
end
table.insert(data.raw["technology"]["military"].effects,{type="unlock-recipe",recipe="patrol-pole"})
-- DISABLED DUE TO BUGGY BEHAVIOUR table.insert(data.raw["technology"]["military"].effects,{type="unlock-recipe",recipe="rally-beacon"})
table.insert(data.raw["technology"]["military"].effects,{type="unlock-recipe",recipe="droid-assembling-machine"})
table.insert(data.raw["technology"]["military"].effects,{type="unlock-recipe",recipe="droid-guard-station"})
table.insert(data.raw["technology"]["military"].effects,{type="unlock-recipe",recipe="droid-selection-tool"})
table.insert(data.raw["technology"]["military"].effects,{type="unlock-recipe",recipe="droid-pickup-tool"})
table.insert(data.raw["technology"]["military"].effects,{type="unlock-recipe",recipe="droid-counter"})
table.insert(data.raw["technology"]["military"].effects,{type="unlock-recipe",recipe="droid-settings"})

table.insert(data.raw["technology"]["military-2"].effects,{type="unlock-recipe",recipe="droid-smg-deploy"})
table.insert(data.raw["technology"]["military-2"].effects,{type="unlock-recipe",recipe="droid-smg"})
table.insert(data.raw["technology"]["military-2"].effects,{type="unlock-recipe",recipe="droid-rocket-deploy"})
table.insert(data.raw["technology"]["military-2"].effects,{type="unlock-recipe",recipe="droid-rocket"})
table.insert(data.raw["technology"]["military-2"].effects,{type="unlock-recipe",recipe="droid-flame-deploy"})
table.insert(data.raw["technology"]["military-2"].effects,{type="unlock-recipe",recipe="droid-flame"})

table.insert(data.raw["technology"]["military-3"].effects,{type="unlock-recipe",recipe="terminator-deploy"})
table.insert(data.raw["technology"]["military-3"].effects,{type="unlock-recipe",recipe="terminator"})



table.insert(data.raw["technology"]["defender"].effects,{type="unlock-recipe", recipe="defender-unit"})
table.insert(data.raw["technology"]["defender"].effects,{type="unlock-recipe", recipe="defender-unit-deploy"})
table.insert(data.raw["technology"]["distractor"].effects,{type="unlock-recipe", recipe="distractor-unit"})
table.insert(data.raw["technology"]["distractor"].effects,{type="unlock-recipe", recipe="distractor-unit-deploy"})
table.insert(data.raw["technology"]["destroyer"].effects,{type="unlock-recipe", recipe="destroyer-unit"})
table.insert(data.raw["technology"]["destroyer"].effects,{type="unlock-recipe", recipe="destroyer-unit-deploy"})