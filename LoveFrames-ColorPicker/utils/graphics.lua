local path = (...):match("(.-)[^%.]+$")
local color_conversion = require(path .. "color")

---------------------------------------------------------
-- Image functions
---------------------------------------------------------
local function create_image(func, cursorSize, width, height)
	local image = love.image.newImageData(width, height)
	image:mapPixel(function(x, y) return func(x, y, cursorSize, width, height) end)
	return love.graphics.newImage(image)
end

local image_functions = {}

image_functions.hsv_colorspace = function(x, y, cursorSize, width, height)
	return color_conversion.hsv2rgb(x/width, 1, 1 - y/height)
end

image_functions.gradient = function(x, y, cursorSize, width, height)
	return (1-y/height)*255, (1-y/height)*255, (1-y/height)*255
end

image_functions.fade_gradient = function(x, y, cursorSize, width, height)
	return 255, 255, 255, (1-y/height)*255
end

image_functions.relief = function(x, y, reliefSize, width, height)
	if reliefSize and x > reliefSize and x < width-reliefSize and y > reliefSize and y < height-reliefSize then
		return 0, 0, 0, 0			-- center
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

image_functions.border = function(object, width, height, textOffset, textWidth)
	if x > (textOffset or 0) and x < (textOffset or 0)+(textWidth or 0) and y < height-2 then
		return 0, 0, 0, 0
	elseif (x == 1 and y > 0 and y < height-2) or (y == 1 and x > 0) or (x == width-1 and y > 0) or (y == height-1) then
		return 255, 255, 255, 255
	elseif x == 0 or y == 0 or x == width-2 or y == height-2 then
		return 150, 150, 150, 255
	else
		return 0, 0, 0, 0
	end
end

image_functions.cursor_circle = function(x, y, cursorSize, width, height)
	if math.floor(math.sqrt(math.pow(x - width/2, 2) + math.pow(y - height/2, 2)) + 0.5) == cursorSize then
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