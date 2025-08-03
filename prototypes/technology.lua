local TECHPATH = "__robotarmy__/graphics/technology/"

data:extend({

  --[[
  {
    type = "technology",
    name = "robotarmy-tech-",
    icon_size = 256, icon_mipmaps = 4,
    icon = TECHPATH .. ".png",
    prerequisites = {""},
    unit =
    {
      count = 100,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"utility-science-pack", 1}
      },
      time = 30
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = ""
      },
    },
    order = "c-c-c"
  },
  ]]

----------------------------------------------------------
-----------------------BASE TECH--------------------------
----------------------------------------------------------

  {
    type = "technology",
    name = "robotarmy-tech-robotics",
    icon_size = 256, icon_mipmaps = 4,
    icon = TECHPATH .. "robotarmy-tech-robotics.png",
    prerequisites = {"military"},
    unit =
    {
      count = 20,
      ingredients = {{"automation-science-pack", 1}},
      time = 30
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "droid-guard-station"
      },
      {
        type = "unlock-recipe",
        recipe = "droid-assembling-machine"
      },
      {
        type = "unlock-recipe",
        recipe = "droid-counter"
      },
      {
        type = "unlock-recipe",
        recipe = "droid-settings"
      },
    },
    order = "c-c-a"
  },

----------------------------------------------------------
----------------------DROID TECH--------------------------
----------------------------------------------------------

  {
    type = "technology",
    name = "robotarmy-tech-droid-rifle",
    icon_size = 256, icon_mipmaps = 4,
    icon = TECHPATH .. "robotarmy-tech-droid-rifle.png",
    prerequisites = {"robotarmy-tech-robotics"},
    unit =
    {
      count = 40,
      ingredients = {{"automation-science-pack", 1}},
      time = 30
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "droid-rifle"
      },
      {
        type = "unlock-recipe",
        recipe = "droid-rifle-deploy"
      },
    },
    order = "c-c-b"
  },
  {
    type = "technology",
    name = "robotarmy-tech-droid-smg",
    icon_size = 256, icon_mipmaps = 4,
    icon = TECHPATH .. "robotarmy-tech-droid-smg.png",
    prerequisites = {"military-2", "robotarmy-tech-robotics"},
    unit =
    {
      count = 40,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 30
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "droid-smg"
      },
      {
        type = "unlock-recipe",
        recipe = "droid-smg-deploy"
      },
    },
    order = "c-c-c"
  },
  {
    type = "technology",
    name = "robotarmy-tech-droid-rocket",
    icon_size = 256, icon_mipmaps = 4,
    icon = TECHPATH .. "robotarmy-tech-droid-rocket.png",
    prerequisites = {"military-2", "robotarmy-tech-robotics"},
    unit =
    {
      count = 60,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 30
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "droid-rocket"
      },
      {
        type = "unlock-recipe",
        recipe = "droid-rocket-deploy"
      },
    },
    order = "c-c-d"
  },
  {
    type = "technology",
    name = "robotarmy-tech-droid-flame",
    icon_size = 256, icon_mipmaps = 4,
    icon = TECHPATH .. "robotarmy-tech-droid-flame.png",
    prerequisites = {"flamethrower", "robotarmy-tech-robotics"},
    unit =
    {
      count = 80,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1}
      },
      time = 30
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "droid-flame"
      },
      {
        type = "unlock-recipe",
        recipe = "droid-flame-deploy"
      },
    },
    order = "c-c-e"
  },

  {
    type = "technology",
    name = "robotarmy-tech-droid-terminator",
    icon_size = 256, icon_mipmaps = 4,
    icon = TECHPATH .. "robotarmy-tech-droid-terminator.png",
    prerequisites = {"military-3", "robotarmy-tech-robotics"},
    unit =
    {
      count = 150,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1}
      },
      time = 45
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "terminator"
      },
      {
        type = "unlock-recipe",
        recipe = "terminator-deploy"
      },
    },
    order = "c-c-f"
  },

----------------------------------------------------------
------------------FLYING DROID TECH-----------------------
----------------------------------------------------------

  {
    type = "technology",
    name = "robotarmy-tech-defender-unit",
    icon_size = 256, icon_mipmaps = 4,
    icon = TECHPATH .. "robotarmy-tech-defender-unit.png",
    prerequisites = {"robotarmy-tech-robotics", "defender"},
    unit =
    {
      count = 150,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1}
      },
      time = 45
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "defender-unit"
      },
      {
        type = "unlock-recipe",
        recipe = "defender-unit-deploy"
      },
    },
    order = "c-c-g"
  },
  {
    type = "technology",
    name = "robotarmy-tech-distractor-unit",
    icon_size = 256, icon_mipmaps = 4,
    icon = TECHPATH .. "robotarmy-tech-distractor-unit.png",
    prerequisites = {"robotarmy-tech-robotics", "distractor"},
    unit =
    {
      count = 250,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1}
      },
      time = 45
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "distractor-unit"
      },
      {
        type = "unlock-recipe",
        recipe = "distractor-unit-deploy"
      },
    },
    order = "c-c-h"
  },
  {
    type = "technology",
    name = "robotarmy-tech-destroyer-unit",
    icon_size = 256, icon_mipmaps = 4,
    icon = TECHPATH .. "robotarmy-tech-destroyer-unit.png",
    prerequisites = {"robotarmy-tech-robotics", "destroyer"},
    unit =
    {
      count = 400,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"utility-science-pack", 1}
      },
      time = 45
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "destroyer-unit"
      },
      {
        type = "unlock-recipe",
        recipe = "destroyer-unit-deploy"
      },
    },
    order = "c-c-i"
  },

})


if (GRAB_ARTIFACTS == 1) then
    table.insert(data.raw.technology["robotarmy-tech-robotics"].effects, {type = "unlock-recipe", recipe = "loot-chest"} )
end