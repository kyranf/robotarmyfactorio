require("defines")
require("util")
local class = require("lib.30log")
local SOLDIER_MAX_AMMO = 100 -- this doesn't really mean much for now.

local Soldier = {} -- the table representing the class, which will double as the metatable for the instances
Soldier.__index = Soldier -- failed table lookups on the instances should fallback to the class table, to get methods

setmetatable(Soldier, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

-- constructor, takes in a LuaEntity object as init parameter
function Soldier.new(init)
  local self = setmetatable({}, Soldier)
  self.entity = init
  self.ammo = SOLDIER_MAX_AMMO
  return self
end

--getters and setters
function Soldier:set_ammo(ammoval)
  self.ammo = ammoval
end

function Soldier:get_ammo()
  return self.ammo
end

function Soldier:get_entity()
  return self.entity
end

