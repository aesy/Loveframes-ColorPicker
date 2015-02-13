local path = (...):match("(.-)[^%.]+$")
local utils = require(path .. "utils")

---------------------------------------------------------
-- Mathematics
---------------------------------------------------------
local function round(n)
	return math.floor(n + 0.5)
end

local function sum(...)
	local s = 0

	for _, x in ipairs({...}) do
		s = s + x
	end

	return s
end

local function magnitude(...)
	local s = 0

	for _, x in ipairs({...}) do
		s = s + math.pow(x, 2)
	end

	return math.sqrt(s)
end

local function translate(point, translation)
	assert(point and translation, "Required argument missing")

	for k, v in pairs(translation) do
		point[k] = point[k] + v
	end

	return point
end

local function rotate_point(point, rot_point, angle)
	assert(point and rot_point and angle, "Required argument missing")

	point = translate(point, {x=-rot_point.x, y=-rot_point.y})

	local x = point.x*math.cos(angle) - point.y*math.sin(angle)
	local y = point.x*math.sin(angle) + point.y*math.cos(angle)

	return translate({x=x, y=y}, {x=rot_point.x, y=rot_point.y})
end

local function distance_from_point(a, b)
	local tbl = {}

	for k, x in pairs(a) do
		table.insert(tbl, a[k] - (b[k] or a[k]))
	end

	return magnitude(unpack(tbl))
end

local function distance_from_line(point, l1, l2)
	local a = l2.y - l1.y
	local b = l2.x - l1.x
	local c = l2.x*l1.y - l2.y*l1.x

	return (a*point.x - b*point.y + c) / magnitude(a, b)
end

local function center_of_line(a, b)
	local tbl = {}
	local i = 0

	for _, p in ipairs({a, b}) do
		for k, v in pairs(p) do
			if not tbl[k] then
				tbl[k] = 0
				i = i + 1
			end
			tbl[k] = tbl[k] + v
		end
	end

	for k, v in pairs(tbl) do
		tbl[k] = tbl[k] / i
	end

	return tbl
end

local function interpolate(i, start, ending)
	assert(i and start and ending, "Required argument missing")

	return start + i*(ending - start)
end

---------------------------------------------------------
-- Transitions
---------------------------------------------------------
local transition = {}

transition.ease_in = function(x, exp, from, to)
	assert(x, "Required argument missing")

	local from = from or 0
	local to = to or 1
	local exp = exp or 2

	return interpolate(1 - math.sqrt(1 - math.pow(x, exp)), from, to)
end

transition.ease_in_out = function(x, exp, from, to)
	assert(x, "Required argument missing")

	local from = from or 0
	local to = to or 1
	local exp = exp or 2

	return interpolate(math.pow(x, exp) / (math.pow(x, exp) + math.pow(1 - x, exp)), from, to)
end

---------------------------------------------------------
-- Return
---------------------------------------------------------
return {
	["transition"] = transition,
	["magnitude"] = magnitude,
	["round"] = round,
	["sum"] = sum,
	["distance_from_point"] = distance_from_point,
	["distance_from_line"] = distance_from_line,
	["center_of_line"] = center_of_line,
	["rotate_point"] = rotate_point,
	["interpolate"] = interpolate,
}