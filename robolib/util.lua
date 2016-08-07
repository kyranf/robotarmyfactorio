function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end	


function table.countNonNil(table)
	local count = 0
	for _, element in pairs(table) do
		if element then
			count = count + 1
		end
	end
	return count
end

--specifically useful for squad member table counting, because it avoids the key = 'size' as a valid countable element.
function table.countValidElements(inputTable)
	local count = 0
	for key, element in pairs(inputTable) do
		if element and key ~= "size" then --avoids issue of squad member table contains an additional entry for size
			
			if element.valid then
				count = count + 1
			end
		end
	end
	return count
end

-- from http://lua-users.org/wiki/CopyTable
function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function setContains(set, key)
    return set[key] ~= nil
end

function stripchars(str, chrs)
  local s = str:gsub("["..chrs.."]", '')
  return s
end

function repchars(str, chrs, newchrs)
	local s = string.gsub(str, chrs, newchrs )
	return s
end
	
	
function convertToMatchable(str)

 local s =  repchars(str, "%-", "0")
 return s

end

function convertToEntityNames(str)
 local s = repchars(str, "0", "-")
 return s

end


--any new global tables we need to add, just add them in here and it will be easier to maintain. not used yet.
function checkGlobalTableInitStates()
	global.Squads = global.Squads or {}
	global.uniqueSquadId = global.uniqueSquadId or {}
	global.DroidAssemblers = global.DroidAssemblers or {}
	global.droidCounters = global.droidCounters or {}
	global.lootChests = global.lootChests or {}
	global.droidGuardStations = global.droidGuardStations or {}
	local forceList = game.forces
	for _, force in pairs(forceList) do
		global.droidGuardStations[force.name] = global.droidGuardStations[force.name] or {}	
		global.Squads[force.name] = global.Squads[force.name] or {}
		global.DroidAssemblers[force.name] = global.DroidAssemblers[force.name] or {}
		global.droidCounters[force.name] = global.droidCounters[force.name] or {}
		global.lootChests[force.name] = global.lootChests[force.name] or {}
		global.uniqueSquadId[force.name] = global.uniqueSquadId[force.name] or 1

	end

end
