require("robolib.util")


--which of our custom entities can be spawned by the Droid Assemblers?
spawnable = {"droid-smg", "droid-rocket", "droid-rifle", "terminator"}

--which of our custom entities can join squads? not necessarily all droids will be using the squad mechanic
squadCapable = {"droid-smg", "droid-rocket","droid-rifle", "terminator"}

-- lets pre-adjust the strings now, for fast matching in run-time, and only when we get a match do we convert back to the spawnable entity names.
for _, name in pairs(spawnable) do
	name = convertToMatchable(name)
end
for _, name in pairs(squadCapable) do
	name = convertToMatchable(name)
end
-- remember to call convertToEntityNames before referencing these entries in spawning or other related uses