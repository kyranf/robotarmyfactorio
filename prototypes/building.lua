

local droidAssembler = {
	type = "assembling-machine",
	name = "droid-assembling-machine",
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
	icon = "__robotarmy__/graphics/icons/droid-assembling-machine.png",
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
	ingredient_count = 1,
	module_specification =
	{
	  module_slots = 0
	},
	allowed_effects = {"consumption", "speed", "pollution"}
}


local rally_beacon = {
    type = "container",
    name = "rally-beacon",
    icon = "__robotarmy__/graphics/icons/loot-chest.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 1, result = "rally-beacon"},
    max_health = 400,
    corpse = "small-remnants",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
    resistances =
    {
      {
        type = "fire",
        percent = 90
      }
    },
    collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
    selection_box = {{-1, -1}, {1, 1}},
    drawing_box = {{-1, -3}, {1, 1}},
    fast_replaceable_group = "",
    inventory_size = 8,
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
	picture =
    {
      filename = "__base__/graphics/entity/substation/substation.png",
      priority = "extra-high",
      width = 132,
      height = 144,
      shift = {0.9, -1}
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
    },
    circuit_connector_sprites = get_circuit_connector_sprites({0.1875, 0.15625}, nil, 18),
    circuit_wire_max_distance = 7.5
 }
data:extend({droidAssembler,guardStation,rally_beacon})