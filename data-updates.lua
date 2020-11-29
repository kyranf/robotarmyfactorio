if _G.bobmods and data.raw.item["basic-circuit-board"] then
--bobmods is present so lets just make use of his lib function
_G.bobmods.lib.recipe.replace_ingredient("droid-rifle","electronic-circuit" , "basic-circuit-board")
end

-- The base game acid splashes are OP.
-- Just turn off the damage and sticker on ground effect.

for k, fire in pairs (data.raw.fire) do
  if fire.name:find("acid%-splash%-fire") then
    fire.on_damage_tick_effect = nil
  end
end