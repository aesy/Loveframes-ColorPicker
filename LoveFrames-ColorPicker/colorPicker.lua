local path = (...):match("(.-)[^%.]+$")
local utils = require(path .. "utils.utils")
local color_conversion = require(path .. "utils.color")
local graphics = require(path .. "utils.graphics")
local calc = require(path .. "utils.calc")

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
colorPicker = {}

function colorPicker:Open(options)
	self.options = options or {}

	self.loveframes = loveframes or self.options.loveframes
	assert(self.loveframes, "LoveFrames module is nil")

	self.hue, self.saturation, self.value = color_conversion.rgb2hsv(unpack(self.options.color or {255, 0, 0}))

	self:_CreateInterface()

	self:_Update()
end

setmetatable(colorPicker, { __call = colorPicker.Open })


function colorPicker:_GetColor()
	local r, g, b = color_conversion.hsv2rgb(self.hue, self.saturation, self.value)
	return { calc.round(r), calc.round(g), calc.round(b) }
end


function colorPicker:_Update(ignore)
	local r, g, b = color_conversion.hsv2rgb(self.hue, self.saturation, self.value)
	local hex = color_conversion.rgb2hex(r, g, b)

	self.color_current.color = {r, g, b}
	self.hsv_colorspace.cursorX = self.hue
	self.hsv_colorspace.cursorY = 1 - self.value
	self.hsv_slider.cursorY = 1 - self.saturation
	self.hsv_slider.alpha = 1 - self.value

	if self.options.shaders then
		self.hsv_colorspace.shader:send("saturation", self.saturation)
		self.hsv_slider.shader:send("hue", self.hue)
		self.hsv_slider.shader:send("value", self.value)
	else
		self.hsv_colorspace.alpha = self.saturation
		self.hsv_slider.color = {color_conversion.hsv2rgb(self.hue, 1, 1)}
	end

	local update = {
		{ self.input_red, 			r 					},
		{ self.input_green, 		g 					},
		{ self.input_blue, 			b 					},
		{ self.input_hue, 			self.hue*360 		},
		{ self.input_saturation, 	self.saturation*100 },
		{ self.input_value, 		self.value*100 		},
		{ self.input_HEX, 			hex					}
	}

	for _, v in pairs(update) do
		if v[1] ~= ignore then
			if type(v[2]) == "number" then
				v[2] = calc.round(v[2])
			end
			v[1]:SetText(v[2])
		end
	end
end


function colorPicker:_Callback()
	local callback = self.options.callback or function(c) print(unpack(c)) end
	callback(self:_GetColor())
end


function colorPicker:_CreateInterface()
	self.frame = self.loveframes.Create("frame")
	self.frame:SetName("Color Picker")
	self.frame:SetSize(400, 250)
	self.frame:Center()
	self.frame:MakeTop(utils.ternary(self.options.makeTop ~= nil, self.options.makeTop, true))
	self.frame:SetModal(utils.ternary(self.options.modal ~= nil, self.options.modal, true))
	self.frame:SetScreenLocked(utils.ternary(self.options.screenLocked ~= nil, self.options.screenLocked, true))
	self.frame:SetDraggable(true)

	self:_CreateColorspace()
	self:_CreateInputFields()
	self:_CreatePreview()
	self:_CreatePresets()

	local button = self.loveframes.Create("button", self.frame)
	button:SetSize(60, 35)
	button:SetPos(325, 37)
	button:SetText("Ok")
	button.OnClick = function(object)
		self.frame:Remove()
		self:_Callback()
	end
end


function colorPicker:_CreateColorspace()
	local padding = 2

	local relief = self.loveframes.Create("image", self.frame)
	relief:SetImage(graphics.create_image(200+padding*2, 200+padding*2, graphics.image_functions.relief, {["size"]=padding}))
	relief:SetPos(13-padding, 37-padding)

	local relief = self.loveframes.Create("image", self.frame)
	relief:SetImage(graphics.create_image(22+padding*2, 200+padding*2, graphics.image_functions.relief, {["size"]=padding}))
	relief:SetPos(225-padding, 37-padding)

	local width, height = 200, 200

	self.hsv_colorspace = self.loveframes.Create("image", self.frame)
	self.hsv_colorspace:SetPos(13, 37)
	self.hsv_colorspace:SetSize(width, height)
	self.hsv_colorspace.colorImage = graphics.create_image(width, height, graphics.image_functions.hsv_colorspace)
	self.hsv_colorspace.alphaImage = graphics.create_image(width, height,
		graphics.image_functions.gradient, {
			["from"] = {255, 255, 255},
			["to"] = {0, 0, 0},
			["direction"] = "vertical",
		})
	self.hsv_colorspace.cursor = graphics.create_image(14, 14, graphics.image_functions.cursor_circle, {["size"]=5})

	self.hsv_colorspace.Draw = function(object)
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

	self.hsv_colorspace.Update = function(object, dt)
		if object.dragging then
			self.hue = utils.clamp((love.mouse.getX() - object:GetX()) / object:GetWidth(), 0, 1)
			self.value = 1 - utils.clamp((love.mouse.getY() - object:GetY()) / object:GetHeight(), 0, 1)
			self:_Update()
		end
	end

	self.hsv_colorspace.mousepressed = function(object, x, y)
		if object.hover then
			self.choice_presets:SetChoice("Presets")
			object.dragging = true
		end
	end

	self.hsv_colorspace.mousereleased = function(object, x, y)
		if object.dragging then
			object.dragging = false
		end
	end

	---------------------------------------------------------
	-- Create satutation slider
	---------------------------------------------------------
	self.hsv_slider = self.loveframes.Create("image", self.frame)
	self.hsv_slider:SetImage(graphics.create_image(22, 200,
		graphics.image_functions.gradient, {
			["from"] = {255, 255, 255, 255},
			["to"] = {255, 255, 255, 0},
			["direction"] = "vertical",
		}))
	self.hsv_slider:SetPos(225, 37)

	self.hsv_slider.Draw = function(object)
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

	self.hsv_slider.Update = function(object, dt)
		if object.dragging then
			self.saturation = 1 - utils.clamp((love.mouse.getY() - object:GetY()) / object:GetHeight(), 0, 1)
			self:_Update()
		end
	end

	self.hsv_slider.mousepressed = function(object, x, y)
		if object.hover then
			self.choice_presets:SetChoice("Presets")
			object.dragging = true
		end
	end

	self.hsv_slider.mousereleased = function(object, x, y)
		if object.dragging then
			object.dragging = false
		end
	end

	---------------------------------------------------------
	-- Use shaders
	---------------------------------------------------------
	if self.options.shaders then
		self.hsv_colorspace.shader = love.graphics.newShader(graphics.shaders.hsv2rgb .. graphics.shaders.self.hsv_colorspace)
		self.hsv_slider.shader = love.graphics.newShader(graphics.shaders.hsv2rgb .. graphics.shaders.self.hsv_slider)
	end
end


function colorPicker:_CreatePreview()
	local padding = 2

	local relief = self.loveframes.Create("image", self.frame)
	relief:SetImage(graphics.create_image(55+padding*2, 35+padding*2, graphics.image_functions.relief, {["size"]=padding}))
	relief:SetPos(260-padding, 37-padding)

	local r, g, b = color_conversion.hsv2rgb(self.hue, self.saturation, self.value)
	local image = self.loveframes.Create("image", self.frame)
	image:SetPos(260, 37)
	image:SetSize(20, 35)
	image.Draw = function(object)
		love.graphics.setColor({r, g, b})
		love.graphics.rectangle("fill", object:GetX(), object:GetY(), object:GetWidth(), object:GetHeight())
	end

	self.color_current = self.loveframes.Create("image", self.frame)
	self.color_current:SetPos(280, 37)
	self.color_current:SetSize(35, 35)
	self.color_current.Draw = function(object)
		love.graphics.setColor(object.color)
		love.graphics.rectangle("fill", object:GetX(), object:GetY(), object:GetWidth(), object:GetHeight())
	end
end


function colorPicker:_CreateInputFields()
	self.input_hue = self.loveframes.Create("textinput", self.frame)
	self.input_saturation = self.loveframes.Create("textinput", self.frame)
	self.input_value = self.loveframes.Create("textinput", self.frame)
	self.input_red = self.loveframes.Create("textinput", self.frame)
	self.input_green = self.loveframes.Create("textinput", self.frame)
	self.input_blue = self.loveframes.Create("textinput", self.frame)
	self.input_HEX = self.loveframes.Create("textinput", self.frame)

	self.input_hue:SetPos(335, 86)
	self.input_hue:SetSize(35, 22)
	self.input_hue:SetLimit(3)
	self.input_hue:SetUsable({"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"})
	self.input_hue.OnTextChanged = function(object)
		local text = object:GetText()
		if text ~= "" then
			if tonumber(text) > 360 or tonumber(text) < 0 then
				object:SetText(utils.clamp(tonumber(text), 0, 360))
			end
			self.hue = tonumber(object:GetText()) / 360
			self:_Update(object)
		end
	end

	self.input_saturation:SetPos(335, 114)
	self.input_saturation:SetSize(35, 22)
	self.input_saturation:SetLimit(3)
	self.input_saturation:SetUsable({"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"})
	self.input_saturation.OnTextChanged = function(object)
		local text = object:GetText()
		if text ~= "" then
			if tonumber(text) > 100 or tonumber(text) < 0 then
				object:SetText(utils.clamp(tonumber(text), 0, 100))
			end
			self.saturation = tonumber(object:GetText()) / 100
			self:_Update(object)
		end
	end

	self.input_value:SetPos(335, 142)
	self.input_value:SetSize(35, 22)
	self.input_value:SetLimit(3)
	self.input_value:SetUsable({"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"})
	self.input_value.OnTextChanged = function(object)
		local text = object:GetText()
		if text ~= "" then
			if tonumber(text) > 100 or tonumber(text) < 0 then
				object:SetText(utils.clamp(tonumber(text), 0, 100))
			end
			self.value = tonumber(object:GetText()) / 100
			self:_Update(object)
		end
	end

	self.input_red:SetPos(275, 86)
	self.input_red:SetSize(35, 22)
	self.input_red:SetLimit(3)
	self.input_red:SetUsable({"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"})
	self.input_red.OnTextChanged = function(object)
		local text = object:GetText()
		if text ~= "" then
			if tonumber(text) > 255 or tonumber(text) < 0 then
				object:SetText(utils.clamp(tonumber(text), 0, 255))
			end
			local r, g, b = color_conversion.hsv2rgb(self.hue, self.saturation, self.value)
			self.hue, self.saturation, self.value = color_conversion.rgb2hsv(tonumber(object:GetText()), g, b)
			self:_Update(object)
		end
	end

	self.input_green:SetPos(275, 114)
	self.input_green:SetSize(35, 22)
	self.input_green:SetLimit(3)
	self.input_green:SetUsable({"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"})
	self.input_green.OnTextChanged = function(object)
		local text = object:GetText()
		if text ~= "" then
			if tonumber(text) > 255 or tonumber(text) < 0 then
				object:SetText(utils.clamp(tonumber(text), 0, 255))
			end
			local r, g, b = color_conversion.hsv2rgb(self.hue, self.saturation, self.value)
			self.hue, self.saturation, self.value = color_conversion.rgb2hsv(r, tonumber(object:GetText()), b)
			self:_Update(object)
		end
	end

	self.input_blue:SetPos(275, 142)
	self.input_blue:SetSize(35, 22)
	self.input_blue:SetLimit(3)
	self.input_blue:SetUsable({"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"})
	self.input_blue.OnTextChanged = function(object)
		local text = object:GetText()
		if text ~= "" then
			if tonumber(text) > 255 or tonumber(text) < 0 then
				object:SetText(utils.clamp(tonumber(text), 0, 255))
			end
			local r, g, b = color_conversion.hsv2rgb(self.hue, self.saturation, self.value)
			self.hue, self.saturation, self.value = color_conversion.rgb2hsv(r, g, tonumber(object:GetText()))
			self:_Update(object)
		end
	end

	self.input_HEX:SetPos(290, 174)
	self.input_HEX:SetSize(65, 22)
	self.input_HEX:SetLimit(6)
	self.input_HEX:SetUsable({"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "a", "b", "c", "d", "e", "f", "A", "B", "C", "D", "E", "F"})
	self.input_HEX.OnTextChanged = function(object)
		local text = object:GetText()
		if text ~= "" and text:len() == 6 then
			self.hue, self.saturation, self.value = color_conversion.rgb2hsv(color_conversion.hex2rgb(text))
			self:_Update(object)
		end
	end

	local text = self.loveframes.Create("text", self.frame)
	text:SetPos(260, 91)
	text:SetText("R:\n\nG:\n\nB:")

	local text = self.loveframes.Create("text", self.frame)
	text:SetPos(320, 91)
	text:SetText("H:\n\nS:\n\nV:")

	local text = self.loveframes.Create("text", self.frame)
	text:SetPos(278, 178)
	text:SetText("#")

	local text = self.loveframes.Create("text", self.frame)
	text:SetPos(374, 92)
	text:SetText("\194\176\n\n%\n\n%")
end


function colorPicker:_CreatePresets()
	self.choice_presets = self.loveframes.Create("multichoice", self.frame)
	self.choice_presets:SetPos(260, 212)
	self.choice_presets:SetWidth(125)
	self.choice_presets:SetText("Presets")
	for choice in utils.ordered_pairs(self.color_presets) do
		self.choice_presets:AddChoice(choice)
	end
	self.choice_presets.OnChoiceSelected = function(object, choice)
		self.hue, self.saturation, self.value = color_conversion.rgb2hsv(unpack(self.color_presets[choice]))
		self:_Update()
	end
end


colorPicker.color_presets = {
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