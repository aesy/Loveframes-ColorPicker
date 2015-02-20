local path = (...):match("(.-)[^%.]+$")
local color_conversion = require(path .. "color")
local utils = require(path .. "utils")
local calc = require(path .. "calc")

---------------------------------------------------------
-- Image functions
---------------------------------------------------------
local function create_image(width, height, func, options)
	local options = options or {}

	local image = love.image.newImageData(width, height)
	image:mapPixel(function(x, y) return func(x, y, width, height, options) end)
	return love.graphics.newImage(image)
end

local image_functions = {}

image_functions.hsv_colorspace = function(x, y, width, height)
	return color_conversion.hsv2rgb(x/width, 1, 1 - y/height)
end

image_functions._gradient = function(x, y, width, height, options)
	assert(options.from, "Color table is nil!")

	local start = options.from or false
	local ending = options.to or from
	start[4] = start[4] or 255
	ending[4] = ending[4] or 255

	local i = 1-x/width
	local r = calc.interpolate(i, ending[1], start[1])
	local g = calc.interpolate(i, ending[2], start[2])
	local b = calc.interpolate(i, ending[3], start[3])
	local a = calc.interpolate(i, ending[4], start[4])

	return r, g, b, a
end

image_functions.gradient = function(x, y, width, height, options)
	assert(options.colors, "Color table is nil!")

	local tbl = utils.sort_by_value(options.colors, "position")
	local smoothness = 0
	if options.smoothness then
		smoothness = 1 - options.smoothness
	end
	smoothness = calc.transition.ease_in(smoothness, 6, 1, 500)

	local theta = options.rotate or 0
	local scale = options.scale or 1
	local pos

	if options.type == "radial" then
		local center = calc.center_of_line({x=0, y=0}, {x=width, y=height})
		pos = calc.distance_from_point({x=x, y=y}, center) / calc.magnitude(center.x, center.y)*math.abs(2 - scale/2)
	elseif options.type == "reflected" then
		local center = calc.center_of_line({x=0, y=0}, {x=width, y=height})
		local origin = calc.rotate_point({x=0, y=0}, center, theta + math.pi/2)
		local ending = calc.rotate_point({x=width, y=0}, center, theta + math.pi/2)
		local line_distance = calc.distance_from_line({x=x, y=y}, origin, ending)*2
		pos = math.abs(width + line_distance) / width

		if line_distance < -width*2 or line_distance > 0 then
			return unpack(tbl[#tbl].color)
		end
	elseif theta ~= 0 or options.type == "linear" then
		local center = calc.center_of_line({x=0, y=0}, {x=width, y=height})
		local origin = calc.rotate_point({x=0, y=0}, center, -theta - math.pi/2)
		local ending = calc.rotate_point({x=width, y=0}, center, -theta - math.pi/2)
		local line_distance = calc.distance_from_line({x=x, y=y}, origin, ending)
		pos = math.abs(line_distance) / calc.magnitude(math.max(width, height), 0)

		if pos > 1 then
			return unpack(tbl[#tbl].color)
		elseif line_distance > 0 then
			return unpack(tbl[1].color)
		end
	else
		pos = x / width
	end

	for index, from in ipairs(tbl) do
		local to = tbl[index+1] or {}

		if pos <= (to.position or 1) and pos >= from.position then
			local length = ((to.position or 1) - from.position)
			local i = pos - from.position
			i = calc.transition.ease_in_out(i / length, smoothness, 0, length)

			return image_functions._gradient(i, i, length, length, {
				from = from.color,
				to  = to.color or from.color,
				direction = options.direction
			})
		end
	end
	return unpack(tbl[1].color)
end

image_functions.relief = function(x, y, width, height, options)
	local size = options.size or 0

	if size and x >= size and x < width-size and y >= size and y < height-size then
		return unpack(options.background or {0, 0, 0, 0}) -- center
	elseif x < width/2 and x < y and x < height-y then
		return 100, 100, 100, 255	-- left
	elseif x >= width/2 and width-x <= y and width-x <= height-y then
		return 255, 255, 255, 255	-- right
	elseif y < height/2 then
		return 100, 100, 100, 255	-- up
	elseif y >= height/2 then
		return 255, 255, 255, 255	-- down
	end
end

image_functions.border = function(x, y, width, height, options)
	local text_offset = options.text_offset or 0
	local text_width = options.text_width or 0

	if x > text_offset and x < text_offset+text_width and y < height-2 then
		return unpack(options.background or {0, 0, 0, 0})
	elseif (x == 1 and y > 0 and y < height-2) or (y == 1 and x > 0) or (x == width-1 and y > 0) or (y == height-1) then
		return 255, 255, 255, 255
	elseif x == 0 or y == 0 or x == width-2 or y == height-2 then
		return 150, 150, 150, 255
	else
		return unpack(options.background or {0, 0, 0, 0})
	end
end

image_functions.cursor_circle = function(x, y, width, height, options)
	local size = options.size or 0

	if math.floor(calc.magnitude(x - width/2, y - height/2) + 0.5) == size then
		return 255, 255, 255, 255
	else
		return 0, 0, 0, 0
	end
end

---------------------------------------------------------
-- Shaders
---------------------------------------------------------
local shaders = {}

shaders.hsv2rgb = [[
	vec3 hsv2rgb(float h, float s, float v) {
		return mix(vec3(1.),clamp((abs(fract(h+vec3(3.,2.,1.)/3.)*6.-3.)-1.),0.,1.),s)*v;
	}
]]

shaders.hsv_colorspace = [[
	extern float saturation;

	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
		return vec4(hsv2rgb(texture_coords.x, saturation, 1 - texture_coords.y), 1.0);
	}
]]

shaders.hsv_slider = [[
	extern float hue;
	extern float value;

	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
		return vec4(hsv2rgb(hue, 1 - texture_coords.y, clamp(value, 0.4, 1.)), 1.0);
	}
]]

---------------------------------------------------------
-- Return
---------------------------------------------------------
return {
	["create_image"] 	= create_image,
	["image_functions"] = image_functions,
	["shaders"] 		= shaders,
}