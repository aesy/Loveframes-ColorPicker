local path = (...):match("(.-)[^%.]+$")
local color_conversion = require(path .. "color")
local utils = require(path .. "utils")

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

image_functions.gradient = function(x, y, width, height, options)
	assert(options.from, "Color table is nil!")
	local from = options.from or false
	local to = options.to or from
	local dir = (options.direction == "horizontal") and {x, width} or {y, height}
	to[4] = to[4] or 255
	from[4] = from[4] or 255

	local i = 1-dir[1]/dir[2]
	local r = to[1] + i*(from[1] - to[1])
	local g = to[2] + i*(from[2] - to[2])
	local b = to[3] + i*(from[3] - to[3])
	local a = to[4] + i*(from[4] - to[4])

	return r, g, b, a
end

image_functions.multi_gradient = function(x, y, width, height, options)
	assert(options.colors, "Color table is nil!")
	local dir = (options.direction == "horizontal") and {x, width} or {y, height}
	local tbl = utils.sort_by_value(options.colors, "position")
	local smoothness = options.smoothness and utils.clamp(1 - options.smoothness, 0, 1) or 0

	local amplitude = 500
	smoothness = 1 - math.sqrt(1 - math.pow(smoothness, 6))
	-- local breakpoint = {0.6, 10}
	-- if smoothness <= breakpoint[1] then
	-- 	smoothness = breakpoint[2]/amplitude - breakpoint[2]/amplitude*(1 - smoothness/breakpoint[1])
	-- else
	-- 	smoothness = breakpoint[2]/amplitude + (1 - breakpoint[2]/amplitude)*math.pow((smoothness - breakpoint[1])/(1 - breakpoint[1]), 3)
	-- end
	smoothness = 1 + smoothness*(amplitude - 1)


	if tbl[1]["position"] ~= 0 then
		table.insert(tbl, 1, {
			color = tbl[1]["color"],
			position = 0
		})
	end

	for index, from in ipairs(tbl) do
		local to = tbl[index+1] or {}
		local pos = dir[1]/dir[2]

		if pos <= (to.position or 1) and pos >= from.position then
			local i = (pos - from.position)*dir[2]
			local length = ((to.position or 1) - from.position)*dir[2]
			i = math.pow(i/length, smoothness) / (math.pow(i/length, smoothness) + math.pow(1 - i/length, smoothness))*length

			return image_functions.gradient(i, i, length, length, {
				from = from.color,
				to  = to.color or from.color,
				direction = options.direction
			})
		end
	end
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

	if math.floor(math.sqrt(math.pow(x - width/2, 2) + math.pow(y - height/2, 2)) + 0.5) == size then
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