local path = (...):match("(.-)[^%.]+$")
local utils = require(path .. "utils.utils")
local color_conversion = require(path .. "utils.color")
local graphics = require(path .. "utils.graphics")

---------------------------------------------------------
-- Color presets
---------------------------------------------------------
local color_presets = {
	["Black"]        	 = {   0,   0,   0 },
	["Dark Grey"]   	 = {  47,  47,  47 },
	["Grey"]        	 = { 128, 128, 128 },
	["Light grey"]   	 = { 230, 230, 230 },
	["White"]         	 = { 255, 255, 255 },
	["Water"]     	     = { 135, 206, 250 },
	["Ice"]       	     = { 210, 238, 254 },
	["Cream"]       	 = { 255, 235, 205 },
	["Beige"]         	 = { 232, 230, 197 },
	["Apple Green"] 	 = { 164, 198,  57 },
	["Light green"]   	 = { 200, 232, 197 },
	["Light blue"]    	 = { 197, 232, 229 },
	["Baby blue"] 		 = { 226, 244, 248 },
	["Red"]           	 = { 255,   0,   0 },
	["Rose Red"]    	 = { 255,   3,  62 },
}

--[[---------------------------------------------------------
	- colorPicker({})
	-
	- @param 'color' (optional) rgb table. Default: {255, 0, 0}.
	- @param 'callback' (optional) function. Default: function(c) print(unpack(c)) end.
	- @param 'makeTop' (optional) boolean. Default: true.
	- @param 'modal' (optional) boolean. Default: true.
	- @param 'screenLocked' (optional) boolean. Default: true.
	- @param 'shaders' (optional) boolean. Default: false.
	- @param 'loveframes' (optional) module. Default: loveframes.
	-
	- @returns loveframes frame.
--]]---------------------------------------------------------
function colorPicker(options)
	local options = options or {}
	local loveframes = loveframes or options.loveframes
	assert(loveframes, "LoveFrames module is nil")

	---------------------------------------------------------
	-- local functions
	---------------------------------------------------------
	local function _getColor()
		local r, g, b = color_conversion.hsv2rgb(hue, saturation, value)
		return { math.floor(r + .5), math.floor(g + .5), math.floor(b + .5) }
	end

	local function _update(ignore)
		local r, g, b = color_conversion.hsv2rgb(hue, saturation, value)
		local hex = color_conversion.rgb2hex(r, g, b)

		color_current.color = {r, g, b}
		hsv_colorspace.cursorX = hue
		hsv_colorspace.cursorY = 1 - value
		hsv_slider.cursorY = 1 - saturation
		hsv_slider.alpha = 1 - value

		if options.shaders then
			hsv_colorspace.shader:send("saturation", saturation)
			hsv_slider.shader:send("hue", hue)
			hsv_slider.shader:send("value", value)
		else
			hsv_colorspace.alpha = saturation
			hsv_slider.color = {color_conversion.hsv2rgb(hue, 1, 1)}
		end

		if input_red ~= ignore then input_red:SetText(math.floor(r + .5)) end
		if input_green ~= ignore then input_green:SetText(math.floor(g + .5)) end
		if input_blue ~= ignore then input_blue:SetText(math.floor(b + .5)) end
		if input_hue ~= ignore then input_hue:SetText(math.floor(hue*360 + .5)) end
		if input_saturation ~= ignore then input_saturation:SetText(math.floor(saturation*100 + .5)) end
		if input_value ~= ignore then input_value:SetText(math.floor(value*100 + .5)) end
		if input_HEX ~= ignore then input_HEX:SetText(hex) end
	end

	---------------------------------------------------------
	-- Local variables
	---------------------------------------------------------
	hue, saturation, value = color_conversion.rgb2hsv(unpack(options.color or {255, 0, 0}))

	---------------------------------------------------------
	-- Create window frame
	---------------------------------------------------------
	local frame = loveframes.Create("frame")
	frame:SetName("Color Picker")
	frame:SetSize(400, 250)
	frame:Center()
	frame:MakeTop(options.makeTop ~= nil and options.makeTop or true)
	frame:SetModal(options.modal ~= nil and options.modal or true)
	frame:SetScreenLocked(options.screenLocked ~= nil and options.screenLocked or true)
	frame:SetDraggable(true)

	---------------------------------------------------------
	-- Sunken relief
	---------------------------------------------------------
	local padding = 2

	local relief = loveframes.Create("image", frame)
	relief:SetImage(graphics.create_image(200+padding*2, 200+padding*2, graphics.image_functions.relief, {["size"]=padding}))
	relief:SetPos(13-padding, 37-padding)

	local relief = loveframes.Create("image", frame)
	relief:SetImage(graphics.create_image(22+padding*2, 200+padding*2, graphics.image_functions.relief, {["size"]=padding}))
	relief:SetPos(225-padding, 37-padding)

	local relief = loveframes.Create("image", frame)
	relief:SetImage(graphics.create_image(55+padding*2, 35+padding*2, graphics.image_functions.relief, {["size"]=padding}))
	relief:SetPos(260-padding, 37-padding)

	---------------------------------------------------------
	-- Create HSV color space
	---------------------------------------------------------
	local width, height = 200, 200

	hsv_colorspace = loveframes.Create("image", frame)
	hsv_colorspace:SetPos(13, 37)
	hsv_colorspace:SetSize(width, height)
	hsv_colorspace.colorImage = graphics.create_image(width, height, graphics.image_functions.hsv_colorspace)
	hsv_colorspace.alphaImage = graphics.create_image(width, height,
		graphics.image_functions.gradient, {
			["from"] = {255, 255, 255},
			["to"] = {0, 0, 0},
			["direction"] = "vertical",
		})
	hsv_colorspace.cursor = graphics.create_image(14, 14, graphics.image_functions.cursor_circle, {["size"]=5})

	hsv_colorspace.Draw = function(object)
		if object.shader then
			love.graphics.setShader(object.shader)
			love.graphics.draw(object.colorImage, object:GetX(), object:GetY())
			love.graphics.setShader()
		else
			love.graphics.setColor(255, 255, 255)
			love.graphics.draw(object.colorImage, object:GetX(), object:GetY())

			love.graphics.setColor(255, 255, 255, (1 - object.alpha)*255)
			love.graphics.draw(object.alphaImage, object:GetX(), object:GetY())
		end

		mask = function()
		   love.graphics.rectangle("fill", object:GetX(), object:GetY(), object:GetWidth(), object:GetHeight())
		end

		if object.cursorY > 0.3 then
			love.graphics.setColor(255, 255, 255)
		else
			love.graphics.setColor(0, 0, 0)
		end

		love.graphics.setStencil(mask)
		local width, height = object.cursor:getDimensions()
		love.graphics.draw(object.cursor, object:GetX()+object.width*(object.cursorX or 0)-width/2, object:GetY()+object.height*(object.cursorY or 0)-height/2)
		love.graphics.setStencil()
	end

	hsv_colorspace.Update = function(object, dt)
		if object.dragging then
			hue = utils.clamp((love.mouse.getX() - object:GetX()) / object:GetWidth(), 0, 1)
			value = 1 - utils.clamp((love.mouse.getY() - object:GetY()) / object:GetHeight(), 0, 1)
			_update()
		end
	end

	hsv_colorspace.mousepressed = function(object, x, y)
		if object.hover then
			choice_presets:SetChoice("Presets")
			object.dragging = true
		end
	end

	hsv_colorspace.mousereleased = function(object, x, y)
		if object.dragging then
			object.dragging = false
		end
	end

	---------------------------------------------------------
	-- Create satutation slider
	---------------------------------------------------------
	hsv_slider = loveframes.Create("image", frame)
	hsv_slider:SetImage(graphics.create_image(22, 200,
		graphics.image_functions.gradient, {
			["from"] = {255, 255, 255, 255},
			["to"] = {255, 255, 255, 0},
			["direction"] = "vertical",
		}))
	hsv_slider:SetPos(225, 37)

	hsv_slider.Draw = function(object)
		if object.shader then
			love.graphics.setShader(object.shader)
			love.graphics.draw(object.image, object:GetX(), object:GetY())
			love.graphics.setShader()
		else
			love.graphics.setColor(255, 255, 255)
			love.graphics.rectangle("fill", object:GetX(), object:GetY(), object:GetWidth(), object:GetHeight())

			love.graphics.setColor(unpack(object.color or {255, 0, 0}))
			love.graphics.draw(object.image, object:GetX(), object:GetY())

			love.graphics.setColor(0, 0, 0, utils.clamp(object.alpha, 0, 0.7)*255)
			love.graphics.rectangle("fill", object:GetX(), object:GetY(), object:GetWidth(), object:GetHeight())
		end

		if object.alpha > 0.3 then
			love.graphics.setColor(255, 255, 255)
		else
			love.graphics.setColor(0, 0, 0)
		end

		love.graphics.rectangle("fill", object:GetX(), object:GetY() + object.cursorY*(object:GetHeight()-1), object:GetWidth(), 1)
	end

	hsv_slider.Update = function(object, dt)
		if object.dragging then
			saturation = 1 - utils.clamp((love.mouse.getY() - object:GetY()) / object:GetHeight(), 0, 1)
			_update()
		end
	end

	hsv_slider.mousepressed = function(object, x, y)
		if object.hover then
			choice_presets:SetChoice("Presets")
			object.dragging = true
		end
	end

	hsv_slider.mousereleased = function(object, x, y)
		if object.dragging then
			object.dragging = false
		end
	end

	---------------------------------------------------------
	-- Use shaders
	---------------------------------------------------------
	if options.shaders then
		hsv_colorspace.shader = love.graphics.newShader(graphics.shaders.hsv2rgb .. graphics.shaders.hsv_colorspace)
		hsv_slider.shader = love.graphics.newShader(graphics.shaders.hsv2rgb .. graphics.shaders.hsv_slider)
	end

	---------------------------------------------------------
	-- Create input fields
	---------------------------------------------------------
	input_hue = loveframes.Create("textinput", frame)
	input_saturation = loveframes.Create("textinput", frame)
	input_value = loveframes.Create("textinput", frame)
	input_red = loveframes.Create("textinput", frame)
	input_green = loveframes.Create("textinput", frame)
	input_blue = loveframes.Create("textinput", frame)
	input_HEX = loveframes.Create("textinput", frame)

	input_hue:SetPos(335, 86)
	input_hue:SetSize(35, 22)
	input_hue:SetLimit(3)
	input_hue:SetUsable({"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"})
	input_hue.OnTextChanged = function(object)
		local text = object:GetText()
		if text ~= "" then
			if tonumber(text) > 360 or tonumber(text) < 0 then
				object:SetText(utils.clamp(tonumber(text), 0, 360))
			end
			hue = tonumber(object:GetText()) / 360
			_update(object)
		end
	end

	input_saturation:SetPos(335, 114)
	input_saturation:SetSize(35, 22)
	input_saturation:SetLimit(3)
	input_saturation:SetUsable({"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"})
	input_saturation.OnTextChanged = function(object)
		local text = object:GetText()
		if text ~= "" then
			if tonumber(text) > 100 or tonumber(text) < 0 then
				object:SetText(utils.clamp(tonumber(text), 0, 100))
			end
			saturation = tonumber(object:GetText()) / 100
			_update(object)
		end
	end

	input_value:SetPos(335, 142)
	input_value:SetSize(35, 22)
	input_value:SetLimit(3)
	input_value:SetUsable({"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"})
	input_value.OnTextChanged = function(object)
		local text = object:GetText()
		if text ~= "" then
			if tonumber(text) > 100 or tonumber(text) < 0 then
				object:SetText(utils.clamp(tonumber(text), 0, 100))
			end
			value = tonumber(object:GetText()) / 100
			_update(object)
		end
	end

	input_red:SetPos(275, 86)
	input_red:SetSize(35, 22)
	input_red:SetLimit(3)
	input_red:SetUsable({"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"})
	input_red.OnTextChanged = function(object)
		local text = object:GetText()
		if text ~= "" then
			if tonumber(text) > 255 or tonumber(text) < 0 then
				object:SetText(utils.clamp(tonumber(text), 0, 255))
			end
			local r, g, b = color_conversion.hsv2rgb(hue, saturation, value)
			hue, saturation, value = color_conversion.rgb2hsv(tonumber(object:GetText()), g, b)
			_update(object)
		end
	end

	input_green:SetPos(275, 114)
	input_green:SetSize(35, 22)
	input_green:SetLimit(3)
	input_green:SetUsable({"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"})
	input_green.OnTextChanged = function(object)
		local text = object:GetText()
		if text ~= "" then
			if tonumber(text) > 255 or tonumber(text) < 0 then
				object:SetText(utils.clamp(tonumber(text), 0, 255))
			end
			local r, g, b = color_conversion.hsv2rgb(hue, saturation, value)
			hue, saturation, value = color_conversion.rgb2hsv(r, tonumber(object:GetText()), b)
			_update(object)
		end
	end

	input_blue:SetPos(275, 142)
	input_blue:SetSize(35, 22)
	input_blue:SetLimit(3)
	input_blue:SetUsable({"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"})
	input_blue.OnTextChanged = function(object)
		local text = object:GetText()
		if text ~= "" then
			if tonumber(text) > 255 or tonumber(text) < 0 then
				object:SetText(utils.clamp(tonumber(text), 0, 255))
			end
			local r, g, b = color_conversion.hsv2rgb(hue, saturation, value)
			hue, saturation, value = color_conversion.rgb2hsv(r, g, tonumber(object:GetText()))
			_update(object)
		end
	end

	input_HEX:SetPos(290, 174)
	input_HEX:SetSize(65, 22)
	input_HEX:SetLimit(6)
	input_HEX:SetUsable({"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "a", "b", "c", "d", "e", "f", "A", "B", "C", "D", "E", "F"})
	input_HEX.OnTextChanged = function(object)
		local text = object:GetText()
		if text ~= "" and text:len() == 6 then
			hue, saturation, value = color_conversion.rgb2hsv(color_conversion.hex2rgb(text))
			_update(object)
		end
	end

	---------------------------------------------------------
	-- Create input labels
	---------------------------------------------------------
	local label_redgreenblue = loveframes.Create("text", frame)
	local label_huesatval = loveframes.Create("text", frame)
	local label_hash = loveframes.Create("text", frame)
	local label_symbols = loveframes.Create("text", frame)

	label_redgreenblue:SetPos(260, 91)
	label_redgreenblue:SetText("R:\n\nG:\n\nB:")

	label_huesatval:SetPos(320, 91)
	label_huesatval:SetText("H:\n\nS:\n\nV:")

	label_hash:SetPos(278, 178)
	label_hash:SetText("#")

	label_symbols:SetPos(374, 92)
	label_symbols:SetText("\194\176\n\n%\n\n%")

	---------------------------------------------------------
	-- Show start color and current pick
	---------------------------------------------------------
	local r, g, b = color_conversion.hsv2rgb(hue, saturation, value)
	local color_old = loveframes.Create("image", frame)
	color_old:SetPos(260, 37)
	color_old:SetSize(20, 35)
	color_old.Draw = function(object)
		love.graphics.setColor({r, g, b})
		love.graphics.rectangle("fill", object:GetX(), object:GetY(), object:GetWidth(), object:GetHeight())
	end

	color_current = loveframes.Create("image", frame)
	color_current:SetPos(280, 37)
	color_current:SetSize(35, 35)
	color_current.Draw = function(object)
		love.graphics.setColor(object.color)
		love.graphics.rectangle("fill", object:GetX(), object:GetY(), object:GetWidth(), object:GetHeight())
	end

	---------------------------------------------------------
	-- Ok button, callback
	---------------------------------------------------------
	local button_ok = loveframes.Create("button", frame)
	button_ok:SetSize(60, 35)
	button_ok:SetPos(325, 37)
	button_ok:SetText("Ok")
	button_ok.OnClick = function(object)
		frame:Remove()
		local callback = options.callback or function(c) print(unpack(c)) end
		callback(_getColor())
	end

	---------------------------------------------------------
	-- Preset box
	---------------------------------------------------------
	choice_presets = loveframes.Create("multichoice", frame)
	choice_presets:SetPos(260, 212)
	choice_presets:SetWidth(125)
	choice_presets:SetText("Presets")
	for choice in utils.ordered_pairs(color_presets) do
		choice_presets:AddChoice(choice)
	end
	choice_presets.OnChoiceSelected = function(object, choice)
		hue, saturation, value = color_conversion.rgb2hsv(unpack(color_presets[choice]))
		_update()
	end

	---------------------------------------------------------
	-- Starting values
	---------------------------------------------------------
	_update()

	return frame
end