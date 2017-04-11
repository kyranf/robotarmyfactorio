data:extend(
{
  {
    type = "recipe-category",
    name = "droids"
  },
  {
    type = "item-group",
    name = "droids",
    order = "dr",
    inventory_order = "dr",
    icon = "__base__/graphics/item-group/military.png"
  },
  {
    type = "item",
    name = "droid-smg",
    icon = "__robotarmy__/graphics/icons/droid_smg_undep.png",
    flags = {"goes-to-quickbar"},
    order = "z[droid]",
	subgroup = "capsule",
    place_result = "droid-smg",
    stack_size = 25
  },
  {
	type = "item",
    name = "droid-smg-dummy",
    icon = "__robotarmy__/graphics/icons/droid_smg.png",
    flags = {"hidden"},
    order = "z-z",
	subgroup = "capsule",
    place_result = "",
    stack_size = 1  
  },
  {
    type = "item",
    name = "droid-flame",
    icon = "__robotarmy__/graphics/icons/droid_flame_undep.png",
    flags = {"goes-to-quickbar"},
    order = "z[droid]",
	subgroup = "capsule",
    place_result = "droid-flame",
    stack_size = 25
  },
  {
	type = "item",
    name = "droid-flame-dummy",
    icon = "__robotarmy__/graphics/icons/droid_flame.png",
    flags = {"hidden"},
    order = "z-z",
	subgroup = "capsule",
    place_result = "",
    stack_size = 1  
  },
  {
    type = "item",
    name = "droid-rifle",
    icon = "__robotarmy__/graphics/icons/droid_rifle_undep.png",
    flags = {"goes-to-quickbar"},
    order = "z[droid]",
	subgroup = "capsule",
    place_result = "droid-rifle",
    stack_size = 25
  },
  {
	type = "item",
    name = "droid-rifle-dummy",
    icon = "__robotarmy__/graphics/icons/droid_rifle.png",
    flags = {"hidden"},
    order = "z-z",
	subgroup = "capsule",
    place_result = "",
    stack_size = 1  
  },
  {
    type = "item",
    name = "droid-rocket",
    icon = "__robotarmy__/graphics/icons/droid_rocket_undep.png",
    flags = {"goes-to-quickbar"},
    order = "z[droid]",
	subgroup = "capsule",
    place_result = "droid-rocket",
    stack_size = 25
  },
  {
	type = "item",
    name = "droid-rocket-dummy",
    icon = "__robotarmy__/graphics/icons/droid_rocket.png",
    flags = {"hidden"},
    order = "z-z",
	subgroup = "capsule",
    place_result = "",
    stack_size = 1  
  },
  {
    type = "item",
    name = "terminator",
    icon = "__robotarmy__/graphics/icons/terminator_undep.png",
    flags = {"goes-to-quickbar"},
    order = "z[droid]",
	subgroup = "capsule",
    place_result = "terminator",
    stack_size = 25
  },
	{
	type = "item",
	name = "terminator-dummy",
	icon = "__robotarmy__/graphics/icons/terminator.png",
	flags = {"hidden"},
	order = "z-z",
	subgroup = "capsule",
	place_result = "",
	stack_size = 1  
	},
	
	{
		type = "item",
		name = "defender-unit",
		icon = "__robotarmy__/graphics/icons/defender_unit_undep.png",
		flags = {"goes-to-quickbar"},
		order = "x[combatrobot]",
		subgroup = "capsule",
		place_result = "defender-unit",
		stack_size = 25
	},
	{
		type = "item",
		name = "defender-unit-dummy",
		icon = "__robotarmy__/graphics/icons/defender.png",
		flags = {"hidden"},
		order = "z-z",
		subgroup = "capsule",
		place_result = "",
		stack_size = 1  
	},
	
	{
		type = "item",
		name = "distractor-unit",
		icon = "__robotarmy__/graphics/icons/distractor_unit_undep.png",
		flags = {"goes-to-quickbar"},
		order = "y[combatrobot]",
		subgroup = "capsule",
		place_result = "distractor-unit",
		stack_size = 25
	},
	{
		type = "item",
		name = "distractor-unit-dummy",
		icon = "__robotarmy__/graphics/icons/distractor.png",
		flags = {"hidden"},
		order = "z-z",
		subgroup = "capsule",
		place_result = "",
		stack_size = 1  
	},
	{
		type = "item",
		name = "destroyer-unit",
		icon = "__robotarmy__/graphics/icons/destroyer_unit_undep.png",
		flags = {"goes-to-quickbar"},
		order = "z[combatrobot]",
		subgroup = "capsule",
		place_result = "destroyer-unit",
		stack_size = 25
	},
	{
		type = "item",
		name = "destroyer-unit-dummy",
		icon = "__robotarmy__/graphics/icons/destroyer.png",
		flags = {"hidden"},
		order = "z-z",
		subgroup = "capsule",
		place_result = "",
		stack_size = 1  
	},
  {
    type = "item",
    name = "droid-assembling-machine",
    icon = "__robotarmy__/graphics/icons/droid-assembling-machine.png",
    flags = {"goes-to-quickbar"},
    subgroup = "production-machine",
    order = "b[droid-assembling-machine]",
    place_result = "droid-assembling-machine",
    stack_size = 50
  },
	{
	type = "item",
	name = "droid-guard-station",
    icon = "__robotarmy__/graphics/icons/droid-guard-station.png",
    flags = {"goes-to-quickbar"},
    subgroup = "production-machine",
    order = "b[droid-guard-station]",
    place_result = "droid-guard-station",
    stack_size = 50
  },
  {
    type = "item",
    name = "droid-counter",
    icon = "__robotarmy__/graphics/icons/droid-counter.png",
    flags = {"goes-to-quickbar"},
    subgroup = "circuit-network",
    place_result="droid-counter",
    order = "b[combinators]-e[droid-counter]",
    stack_size = 50,
  },
  {
    type = "item",
    name = "droid-settings",
    icon = "__robotarmy__/graphics/icons/droid-settings.png",
    flags = {"goes-to-quickbar"},
    subgroup = "circuit-network",
    place_result="droid-settings",
    order = "b[combinators]-e[droid-settings]",
    stack_size = 50,
  },
  {
	type = "item",
	name = "loot-chest",
	icon = "__robotarmy__/graphics/icons/loot-chest.png",
	flags = {"goes-to-quickbar"},
	subgroup = "storage",
	place_result="loot-chest",
	order = "a[items]-c[loot-chest]",
	stack_size = 50,
  },
  {
    type = "item",
    name = "rally-beacon",
    icon = "__robotarmy__/graphics/icons/rally-beacon.png",
    flags = {"goes-to-quickbar"},
    subgroup = "capsule",
    place_result="rally-beacon",
    order = "a[items]-c[rally-beacon]",
    stack_size = 5,
  },
  {
    type = "item",
    name = "patrol-pole",
    icon = "__robotarmy__/graphics/icons/patrol-pole.png",
    flags = {"goes-to-quickbar"},
    subgroup = "capsule",
    place_result="patrol-pole",
    order = "a[items]-d[patrol-pole]",
    stack_size = 50,
  },
	{
	-- This allows loading the selection-tool type item when mods are removed
	type = "selection-tool",
	name = "droid-selection-tool",
	icon = "__base__/graphics/icons/blueprint.png",
	flags = {"goes-to-quickbar", "hidden"},
	subgroup = "tool",
	order = "d[droid-control]-s[selection]",
	stack_size = 1,
	stackable = false,
	selection_color = { r = 0, g = 1, b = 0 },
	alt_selection_color = { r = 0, g = 1, b = 0 },
	selection_mode = {"matches-force"},
	alt_selection_mode = {"matches-force"},
	selection_cursor_box_type = "not-allowed",
	alt_selection_cursor_box_type = "not-allowed"
	},
  	{
	-- This allows loading the selection-tool type item when mods are removed
	type = "selection-tool",
	name = "droid-pickup-tool",
	icon = "__base__/graphics/icons/deconstruction-planner.png",
	flags = {"goes-to-quickbar", "hidden"},
	subgroup = "tool",
	order = "d[droid-control]-p[pickup]",
	stack_size = 1,
	stackable = false,
	selection_color = { r = 1, g = 0, b = 0 },
	alt_selection_color = { r = 1, g = 0, b = 0 },
	selection_mode = {"blueprint"},
	alt_selection_mode = {"blueprint"},
	selection_cursor_box_type = "not-allowed",
	alt_selection_cursor_box_type = "not-allowed"
	},
  
})