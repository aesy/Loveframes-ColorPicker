---------------------------------------------------------
-- Mathematics
---------------------------------------------------------
local function round(n)
	return math.floor(n + 0.5)
end

local function magnitude(x, y, z)
	assert(x and y, "Required argument missing")

	local z = z or 0

	return math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2))
end

local function transformY(x, from, to)
	assert(x and from and to, "Required argument missing")

	return from + x*(to - from)
end

---------------------------------------------------------
-- Transitions
---------------------------------------------------------
local function multi_transition(from, to, ...)
	-- ... = {
	-- 	{
	-- 		["breakpoint"] = {x, y},
	-- 		[""]
	-- 	}
	-- }
end

local transition = {}

transition.ease_in = function(x, exp, from, to)
	assert(x, "Required argument missing")

	local from = from or 0
	local to = to or 1
	local exp = exp or 2

	return transformY(1 - math.sqrt(1 - math.pow(x, exp)), from, to)
end

transition.ease_in_out = function(x, exp, from, to)
	assert(x, "Required argument missing")

	local from = from or 0
	local to = to or 1
	local exp = exp or 2

	return transformY(math.pow(x, exp) / (math.pow(x, exp) + math.pow(1 - x, exp)), from, to)
end


-- local breakpoint = {0.6, 10}
-- if smoothness <= breakpoint[1] then
-- 	smoothness = breakpoint[2]/amplitude - breakpoint[2]/amplitude*(1 - smoothness/breakpoint[1])
-- else
-- 	smoothness = breakpoint[2]/amplitude + (1 - breakpoint[2]/amplitude)*math.pow((smoothness - breakpoint[1])/(1 - breakpoint[1]), 3)
-- end


---------------------------------------------------------
-- Return
---------------------------------------------------------
return {
	["transition"] = transition,
	["magnitude"] = magnitude,
	["round"] = round,
}