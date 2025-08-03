require("config.config")

local a = {
  {
    type = "recipe",
    name = "droid-smg",
    enabled = false,
    category = "advanced-crafting",
    energy_required = 10,
    ingredients =
    {
      {type="item", name="steel-plate", amount=5},
      {type="item", name="electronic-circuit", amount=15},
      {type="item", name="submachine-gun", amount=1},
      {type="item", name="light-armor", amount=1}
    },
    results={ {type="item", name="droid-smg", amount=1} }
  },
  {
    type = "recipe",
    name = "droid-rifle",
    enabled = false,
    category = "advanced-crafting",
    energy_required = 5,
    ingredients =
    {
      {type="item", name="copper-plate", amount=20},
      {type="item", name="electronic-circuit", amount=5},
      {type="item", name="iron-gear-wheel", amount=10},
    },
    results={ {type="item", name="droid-rifle", amount=1} }
  },
  {
    type = "recipe",
    name = "droid-rocket",
    enabled = false,
    category = "advanced-crafting",
    energy_required = 10,
    ingredients =
    {
      {type="item", name="steel-plate", amount=5},
      {type="item", name="electronic-circuit", amount=25},
      {type="item", name="rocket-launcher", amount=1},
      {type="item", name="light-armor", amount=1}
    },
    results={ {type="item", name="droid-rocket", amount=1} }
  },
  {
    type = "recipe",
    name = "terminator",
    enabled = false,
    category = "advanced-crafting",
    energy_required = 10,
    ingredients =
    {
      {type="item", name="steel-plate", amount=10},
      {type="item", name="laser-turret", amount=2},
      {type="item", name="processing-unit", amount=10},
      {type="item", name="modular-armor", amount=1}
    },
    results={ {type="item", name="terminator", amount=1} }
  },
  {
    type = "recipe",
    name = "terminator-deploy",
    hide_from_player_crafting = true,
    enabled = false,
    category = "droids",
    energy_required = 10,
    ingredients =
    {
      {type="item", name="terminator", amount=1}
    },
    results={ {type="item", name="terminator-dummy", amount=1} }
  },
  {
    type = "recipe",
    name = "droid-assembling-machine",
    enabled = false,
    ingredients =
    {
      {type="item", name="iron-plate", amount=10},
      {type="item", name="electronic-circuit", amount=50},
      {type="item", name="iron-gear-wheel", amount=50},
      {type="item", name="assembling-machine-1", amount=1}
    },
    results={ {type="item", name="droid-assembling-machine", amount=1} }
  },
  {
    type = "recipe",
    name = "droid-guard-station",
    enabled = false,
    ingredients =
    {
      {type="item", name="iron-plate", amount=10},
      {type="item", name="electronic-circuit", amount=50},
      {type="item", name="iron-gear-wheel", amount=50},
      {type="item", name="assembling-machine-1", amount=1}
    },
    results={ {type="item", name="droid-guard-station", amount=1} }
  },
  {
    type = "recipe",
    name = "droid-smg-deploy",
    hide_from_player_crafting = true,
    enabled = false,
    category = "droids",
    energy_required = 6,
    ingredients =
    {
      {type="item", name="droid-smg", amount=1}
    },
    results={ {type="item", name="droid-smg-dummy", amount=1} }
  },
  {
    type = "recipe",
    name = "droid-rocket-deploy",
    hide_from_player_crafting = true,
    enabled = false,
    category = "droids",
    energy_required = 6,
    ingredients =
    {
      {type="item", name="droid-rocket", amount=1}
    },
    results={ {type="item", name="droid-rocket-dummy", amount=1} }
  },
  {
    type = "recipe",
    name = "droid-rifle-deploy",
    hide_from_player_crafting = true,
    enabled = false,
    category = "droids",
    energy_required = 3,
    ingredients =
    {
      {type="item", name="droid-rifle", amount=1}
    },
    results={ {type="item", name="droid-rifle-dummy", amount=1} }
  },
  {
    type = "recipe",
    name = "droid-counter",
    enabled = false,
    ingredients =
    {
      {type="item", name="constant-combinator", amount=1},
      {type="item", name="iron-plate", amount=20},
      {type="item", name="electronic-circuit", amount=25},
    },
    results={ {type="item", name="droid-counter", amount=1} },
  },
  {
    type = "recipe",
    name = "droid-settings",
    enabled = false,
    ingredients =
    {
      {type="item", name="constant-combinator", amount=1},
      {type="item", name="iron-plate", amount=20},
      {type="item", name="electronic-circuit", amount=25},
    },
    results={ {type="item", name="droid-settings", amount=1} },
  },
  {
    type = "recipe",
    name = "loot-chest",
    enabled = false,
    ingredients =
    {
      {type="item", name="steel-plate", amount=20},
      {type="item", name="electronic-circuit", amount=25},
    },
    results={ {type="item", name="loot-chest", amount=1} },
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
      {type="item", name="steel-plate", amount=10},
      {type="item", name="electronic-circuit", amount=25},
      {type="item", name="flamethrower", amount=1},
      {type="item", name="light-armor", amount=1}
    },
    results={ {type="item", name="droid-flame", amount=1} },
  },
  {
    type = "recipe",
    name = "droid-flame-deploy",
    hide_from_player_crafting = true,
    enabled = false,
    category = "droids",
    energy_required = 8,
    ingredients =
    {
      {type="item", name="droid-flame", amount=1}
    },
    results={ {type="item", name="droid-flame-dummy", amount=1} },
  },
  {
    type = "recipe",
    name = "patrol-pole",
    enabled = false,
    ingredients =
    {
      {type="item", name="steel-plate", amount=5},
      {type="item", name="electronic-circuit", amount=5},
    },
    results={ {type="item", name="patrol-pole", amount=1} },
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
      {type="item", name="piercing-rounds-magazine", amount=1},
      {type="item", name="electronic-circuit", amount=5},
      {type="item", name="iron-gear-wheel", amount=5},
    },
    results={ {type="item", name="defender-unit", amount=1} }
  },
  {
    type = "recipe",
    name = "defender-unit-deploy",
    hide_from_player_crafting = true,
    enabled = false,
    category = "droids",
    energy_required = 3,
    ingredients =
    {
      {type="item", name="defender-unit", amount=1}
    },
    results={ {type="item", name="defender-unit-dummy", amount=1} }
  },
  {
    type = "recipe",
    name = "distractor-unit",
    enabled = false,
    category = "advanced-crafting",
    energy_required = 5,
    ingredients =
    {
      {type="item", name="piercing-rounds-magazine", amount=1},
      {type="item", name="advanced-circuit", amount=3},
      {type="item", name="steel-plate", amount=5},
    },
    results={ {type="item", name="distractor-unit", amount=1} }
  },
  {
    type = "recipe",
    name = "distractor-unit-deploy",
    hide_from_player_crafting = true,
    energy_required = 3,
    enabled = false,
    category = "droids",
    ingredients =
    {
      {type="item", name="distractor-unit", amount=1}
    },
    results={ {type="item", name="distractor-unit-dummy", amount=1} }
  },
  {
    type = "recipe",
    name = "destroyer-unit",
    enabled = false,
    category = "advanced-crafting",
    energy_required = 8,
    ingredients =
    {
      {type="item", name="piercing-rounds-magazine", amount=5},
      {type="item", name="processing-unit", amount=5},
      {type="item", name="steel-plate", amount=5},
    },
    results={ {type="item", name="destroyer-unit", amount=1} }
  },
  {
    type = "recipe",
    name = "destroyer-unit-deploy",
    hide_from_player_crafting = true,
    energy_required = 8,
    enabled = false,
    category = "droids",
    ingredients =
    {
      {type="item", name="destroyer-unit", amount=1}
    },
    results={ {type="item", name="destroyer-unit-dummy", amount=1} }
  },
}
for _, a0 in pairs(a) do
	data:extend({a0});
end
