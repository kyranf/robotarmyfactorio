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


function table.countValidElements(table)
	local count = 0
	for key, element in pairs(table) do
		if element and key ~= "size" then
			
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