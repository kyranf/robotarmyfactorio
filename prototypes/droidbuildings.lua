
data:extend(
{
	{
		type = "assembling-machine",
		name = "droid-assembling-machine",
		icon = "__base__/graphics/icons/assembling-machine-2.png",
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
		  filename = "__base__/graphics/entity/assembling-machine-2/assembling-machine-2.png",
		  priority = "high",
		  width = 113,
		  height = 99,
		  frame_count = 32,
		  line_length = 8,
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
}
)