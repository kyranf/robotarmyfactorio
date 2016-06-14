-- need to put transition from "droid" to "droid-smg" here.


game.reload_script()

for i, force in pairs(game.forces) do 
 force.reset_recipes()
end

for i, force in pairs(game.forces) do 
 force.reset_technologies()
end

{
 "entity":
 [
  ["droid", "droid-smg"],
  ["droid-deploy", "droid-smg-deploy"]  
 ]
}

