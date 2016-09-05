data:extend({
	{
        type = "corpse",
        name = "robot-corpse",
        icon = "__base__/graphics/icons/medium-biter-corpse.png",
        selectable_in_game = false,
        selection_box = {{-1, -1}, {1, 1}},
        flags = {"placeable-neutral", "placeable-off-grid", "building-direction-8-way", "not-on-map"},
        subgroup="corpses",
        order = "c[corpse]-a[biter]-b[medium]",
        dying_speed = 0.04,
        time_before_removed = 15 * 60 * 60,
        final_render_layer = "corpse",
        animation = {
			layers =
			{
			  {
				filename = "__base__/graphics/entity/defender-robot/defender-robot.png",
				width = 1,
				height = 1,
				frame_count = 16,
				direction_count = 16,
				--shift = {scale * 0.546875, scale * 0.21875},
				priority = "very-low",
				--scale = scale,
				
			  }
			}
		}
	}
})  
