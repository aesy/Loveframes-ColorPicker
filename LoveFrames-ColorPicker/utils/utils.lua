---------------------------------------------------------
-- Utility functions
---------------------------------------------------------
local function clamp(val, first, second)
	assert(val and first, "Required argument missing")

	if first and not second then
		if val > first then
			return math.min(val, first)
		else
			return math.max(val, first)
		end
	else
		if first > second then
			first, second = second, first
		end

		return math.max(first, math.min(second, val))
	end
end

local function ternary(cond, a, b)
    if cond then
    	return a
    else
    	return b
    end
end

local function deep_copy(t)
	assert(t, "Required argument missing")

	local c = {}
	if type(t) == "table" then
		for k, v in pairs(t) do
			c[k] = deep_copy(v)
		end
	else
		c = t
	end
	return c
end

function shallow_copy(t)
	assert(t, "Required argument missing")

	local c = {}
	if type(t) == "table" then
		for k,v in pairs(t) do
			c[k] = v
		end
	else
		c = t
	end
	return c
end

local function sort_by_value(tbl, key)
	assert(tbl, "Required argument missing")

	table.sort(tbl, function(a, b)
		if key then
			return a[key] < b[key]
		else
			return a < b
		end
	end)

	return tbl
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
	assert(tbl, "Required argument missing")

	return _orderedNext, tbl, nil
end

local function grid(index, width, height, cell_width, cell_height, padding)
	assert(index and width and height and cell_width and cell_height, "Required argument missing")
	assert(index ~= 0, "Index must start at 1 (for Lua consistency)")

	local padding = padding or 0
	local index = index - 1
	local cell_width = cell_width + padding
	local items_per_row = math.floor(width / cell_width)
	local row = math.floor(index / items_per_row)
	local cell_height = cell_height + padding
	local items_per_column = math.floor(height / cell_height)
	local column = math.fmod(index, items_per_row)

	if row > items_per_column then
		return nil, nil
	else
		return column*cell_width + padding, row*cell_height + padding
	end
end

function serialize(tbl, name)
	local data = name and name .. " = " or "return "

	local function add(value, name, indent)
		indent = indent or ""
		data = data .. indent

		if name and type(name) ~= "number" then
			data = data .. name .. " = "
		end

		if type(value) ~= "table" then
			data = data .. value .. ",\n"
		else
			data = data .. "{\n"

			for k, v in pairs(value) do
				if type(k) == "string" then
					k = string.format("[\"%s\"]", k)
				end
				if type(v) == "string" then
					v = string.format("\"%s\"", v)
				end
				add(v, k, indent .. "\t")
			end

			data = data .. indent .. "}"
			if name then
				data = data .. ",\n"
			end
		end
	end

	add(tbl)
	return data
end

---------------------------------------------------------
-- Return
---------------------------------------------------------
return {
	["clamp"] = clamp,
	["deep_copy"] = deep_copy,
	["shallow_copy"] = shallow_copy,
	["ordered_pairs"] = orderedPairs,
	["sort_by_value"] = sort_by_value,
	["grid"] = grid,
	["serialize"] = serialize,
	["ternary"] = ternary,
}