require("config.config")


circuit_connector_definitions["droid_assem"] = circuit_connector_definitions.create
(
  universal_connector_template,
  {
    { variation = 18,
    main_offset = util.by_pixel(2.5, 18.0),
    shadow_offset = util.by_pixel(2.0, 18.0),
    show_shadow = false },
  }
)

local droidAssembler = {
	type = "container",
	name = "droid-assembling-machine",
	icon_size = 32,
	is_deployer = true,
	icon = "__robotarmy__/graphics/icons/droid-assembling-machine.png",
	flags = {"placeable-neutral", "placeable-player", "player-creation"},
	minable = {hardness = 0.2, mining_time = 0.5, result = "droid-assembling-machine"},
	max_health = 400,
	corpse = "big-remnants",
	dying_explosion = "medium-explosion",
	resistances =
	{
	  {
		type = "fire",
		percent = 70
	  },
	  {
		type = "acid",
		percent = 70
	  }
	},
	collision_box = {{-2.8, -2.8}, {2.8, 2.8}},
	selection_box = {{-3, -3}, {3, 3}},
	fast_replaceable_group = "",
	inventory_size = 4,
	picture =
  {
		filename = "__robotarmy__/graphics/entity/droid_assembler_hr.png",
	  priority = "high",
	  width = 246,
		height = 221,
		shift = {0.4, -0.06}
	},
	
	open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
	close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
	vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
	circuit_wire_connection_point =
	{
		shadow =
		{
			red = {0.734375, 0.453125},
			green = {0.609375, 0.515625},
		},
		wire =
		{
			red = {0.40625, 0.21875},
			green = {0.40625, 0.375},
		}
	},
	circuit_wire_connection_point = circuit_connector_definitions["droid_assem"].points,
	circuit_connector_sprites = circuit_connector_definitions["droid_assem"].sprites,
	circuit_wire_max_distance = 7.5
}

local guardStation = {
	type = "container",
	name = "droid-guard-station",
	icon_size = 32,
	icon = "__robotarmy__/graphics/icons/droid-guard-station.png",
	flags = {"placeable-neutral", "placeable-player", "player-creation"},
	minable = {hardness = 0.2, mining_time = 0.5, result = "droid-guard-station"},
	max_health = 400,
	corpse = "big-remnants",
	dying_explosion = "medium-explosion",
	resistances =
	{
	  {
		type = "fire",
		percent = 70
	  },
	  {
		type = "acid",
		percent = 70
	  }
	},
	collision_box = {{-2.8, -2.0}, {2.8, 2.8}},
	selection_box = {{-3, -3}, {3, 3}},
	picture =
  {
		filename = "__robotarmy__/graphics/entity/guard_station_hr.png",
	  priority = "high",
	  width = 246,
	  height = 215,
	  shift = {0.25, 0.0}
	},
	fast_replaceable_group = "",
	inventory_size = 4,
	open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
	close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
	vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
	circuit_wire_connection_point =
	{
		shadow =
		{
			red = {0.734375, 0.453125},
			green = {0.609375, 0.515625},
		},
		wire =
		{
			red = {0.40625, 0.21875},
			green = {0.40625, 0.375},
		}
	},
	circuit_wire_connection_point = circuit_connector_definitions["droid_assem"].points,
	circuit_connector_sprites = circuit_connector_definitions["droid_assem"].sprites,
	circuit_wire_max_distance = 7.5
}



local patrolPole = {
	type = "electric-pole",
	name = "patrol-pole",
    icon_size = 32,
	icon = "__base__/graphics/icons/medium-electric-pole.png",
	flags = {"placeable-neutral", "player-creation"},
	minable = {hardness = 0.2, mining_time = 0.5, result = "patrol-pole"},
	max_health = 1000,
	corpse = "small-remnants",
	resistances =
	{
	  {
		type = "fire",
		percent = 100
	  }
	},
	collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	drawing_box = {{-0.5, -2.8}, {0.5, 0.5}},
	maximum_wire_distance = GUARD_POLE_CONNECTION_RANGE,
	supply_area_distance = 0,
	vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
	pictures =
	{
	  filename = "__robotarmy__/graphics/entity/patrol-pole.png",
	  priority = "high",
	  width = 136,
	  height = 122,
	  tint = {r=1.0, g=0.5, b=0.5, a=1},
	  direction_count = 1,
	  shift = {1.4, -1.0}
	},
	connection_points =
	{
	  {
		shadow =
		{
		  copper = {2.55, 0.4},
		  green = {2.0, 0.4},
		  red = {3.05, 0.4}
		},
		wire =
		{
		  copper = {-0.03125, -2.46875},
		  green = {-0.34375, -2.46875},
		  red = {0.25, -2.46875}
		}
	  }
	},
	radius_visualisation_picture =
	{
	  filename = "__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png",
	  width = 12,
	  height = 12,
	  priority = "extra-high-no-scale"
	},
} 

local construction_warehouse = {
  type = "container",
  name = "construction-warehouse",
  icon_size = 32,
  icon = "__robotarmy__/graphics/icons/construction_warehouse.png",
  flags = {"placeable-neutral", "placeable-player", "player-creation"},
  minable = {hardness = 0.2, mining_time = 1, result = "construction-warehouse"},
  max_health = 400,
  corpse = "big-remnants",
  open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
  close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
  resistances =
  {
    {
      type = "fire",
      percent = 90
    },
    {
  type = "acid",
  percent = 70
  }
  },
  collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
  selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
  fast_replaceable_group = "",
  inventory_size = 40,
  vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
  picture =
  {
    filename = "__robotarmy__/graphics/entity/construction_warehouse.png",
    priority = "extra-high",
    width = 111,
    height = 99,
    shift = {0.0, 0}
  },
  circuit_wire_connection_point =
  {
    shadow =
    {
      red = {0.734375, 0.453125},
      green = {0.609375, 0.515625},
    },
    wire =
    {
      red = {0.40625, 0.21875},
      green = {0.40625, 0.375},
    }
  }
  
}
 
 
 data:extend({droidAssembler,guardStation, patrolPole, construction_warehouse})