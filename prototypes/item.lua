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
    subgroup = "storage",
    place_result="rally-beacon",
    order = "a[items]-c[rally-beacon]",
    stack_size = 5,
  },
  {
    type = "item",
    name = "patrol-pole",
    icon = "__base__/graphics/icons/medium-electric-pole.png",
    flags = {"goes-to-quickbar"},
    subgroup = "capsule",
    place_result="patrol-pole",
    order = "a[items]-c[patrol-pole]",
    stack_size = 50,
  },
  
})