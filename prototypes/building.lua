require("config.config")

local droidAssembler = {
	type = "assembling-machine",
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
	fluid_boxes =
	{
	  {
		production_type = "input",
		pipe_picture = assembler2pipepictures(),
		pipe_covers = pipecoverspictures(),
		base_area = 10,
		base_level = -1,
		pipe_connections = {{ type="input", position = {0, -2} }}
	  },
	  {
		production_type = "output",
		pipe_picture = assembler2pipepictures(),
		pipe_covers = pipecoverspictures(),
		base_area = 10,
		base_level = 1,
		pipe_connections = {{ type="output", position = {0, 2} }}
	  },
	  off_when_no_fluid_recipe = false
	},
	collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
	selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
	animation =
	{
	  filename = "__robotarmy__/graphics/entity/droid-assembler.png",
	  priority = "high",
	  width = 111,
	  height = 99,
	  frame_count = 1,
	  line_length = 1,
	  shift = {0.4, -0.06}
	},
	open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
	close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
	vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
	working_sound =
	{
	  sound = {
		{
		  filename = "__base__/sound/assembling-machine-t2-1.ogg",
		  volume = 0.8
		},
		{
		  filename = "__base__/sound/assembling-machine-t2-2.ogg",
		  volume = 0.8
		},
	  },
	  idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
	  apparent_volume = 1.5,
	},
	crafting_categories = {"droids"},
	crafting_speed = 1.0,
	energy_source =
	{
	  type = "electric",
	  usage_priority = "secondary-input",
	  emissions = 0.04 / 2.5
	},
	energy_usage = "300kW",
	ingredient_count = 3,
	module_specification =
	{
	  module_slots = 3
	},
	allowed_effects = {"consumption", "speed", "pollution"}
}

local guardStation = {
	type = "assembling-machine",
	name = "droid-guard-station",
    icon_size = 32,
	is_deployer = true,
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
	collision_box = {{-1.7, -1.7}, {1.7, 1.7}},
	  selection_box = {{-2, -2}, {2, 2}},
	animation =
	{
	  filename = "__robotarmy__/graphics/entity/guard-station.png",
	  priority = "high",
	  width = 143,
	  height = 190,
	  frame_count = 1,
	  line_length = 1,
	  shift = {0.5, -0.5}
	},
	open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
	close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
	vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
	working_sound =
	{
	  sound = {
		{
		  filename = "__base__/sound/assembling-machine-t2-1.ogg",
		  volume = 0.8
		},
		{
		  filename = "__base__/sound/assembling-machine-t2-2.ogg",
		  volume = 0.8
		},
	  },
	  idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
	  apparent_volume = 1.5,
	},
	crafting_categories = {"droids"},
	crafting_speed = 1.0,
	energy_source =
	{
	  type = "electric",
	  usage_priority = "secondary-input",
	  emissions = 0.04 / 2.5
	},
	energy_usage = "300kW",
	ingredient_count = 1,
	module_specification =
	{
	  module_slots = 0
	},
	allowed_effects = {"consumption", "speed", "pollution"}
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


 data:extend({droidAssembler,guardStation, patrolPole})