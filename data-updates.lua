if _G.bobmods and data.raw.item["basic-circuit-board"] then
--bobmods is present so lets just make use of his lib function
_G.bobmods.lib.recipe.replace_ingredient("droid-rifle","electronic-circuit" , "basic-circuit-board")
end