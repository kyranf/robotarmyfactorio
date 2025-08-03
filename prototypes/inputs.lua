
-- Puts selection tool into player's cursor
give_selection_tool = {
    type = "custom-input",
    name = "droid-selection-tool",
    localised_name = {"controls.selection-tool-control"},
    localised_description = {"controls-description.selection-tool-control"},
    order = "a",
    key_sequence = "",
    consuming = "none",
    action = "lua",
}

-- Puts pickup tool into player's cursor
give_pickup_tool = {
    type = "custom-input",
    name = "droid-pick-up-tool",
    localised_name = {"controls.pick-up-tool-control"},
    localised_description = {"controls-description.pick-up-tool-control"},
    order = "b",
    key_sequence = "",
    consuming = "none",
    action = "lua",
}

data:extend({give_pickup_tool, give_selection_tool})