---------------------------------------------------------
-- Utility functions
---------------------------------------------------------
local function clamp(val, lower, upper)
	if lower > upper then
		lower, upper = upper, lower
	end

	return math.max(lower, math.min(upper, val))
end

local function table_copy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in pairs(orig) do
			copy[orig_key] = orig_value
		end
	else
		copy = orig
	end
	return copy
end

local function _genOrderedIndex(tbl)
	local orderedIndex = {}
	for key in pairs(tbl) do
		table.insert(orderedIndex, key)
	end
	table.sort(orderedIndex)
	return orderedIndex
end

local function _orderedNext(tbl, state)
	if state == nil then
		tbl.__orderedIndex = _genOrderedIndex(tbl)
		key = tbl.__orderedIndex[1]
		return key, tbl[key]
	end
	key = nil
	for i = 1,table.getn(tbl.__orderedIndex) do
		if tbl.__orderedIndex[i] == state then
			key = tbl.__orderedIndex[i+1]
		end
	end
	if key then
		return key, tbl[key]
	end
	tbl.__orderedIndex = nil
	return
end

local function orderedPairs(tbl)
	return _orderedNext, tbl, nil
end

---------------------------------------------------------
-- Return
---------------------------------------------------------
return {
	["clamp"] = clamp,
	["table_copy"] = table_copy,
	["ordered_pairs"] = orderedPairs,
}