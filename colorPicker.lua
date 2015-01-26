--[[---------------------------------------------------------
	- colorPicker(color, callback)
	-
	- @param (optional) table color. Default: {255, 0, 0}.
	- @param (optional) function callback. Default: function(c) print(unpack(c)) end.
	- @param (optional) maketop. Default: true.
	- @param (optional) modal. Default: true.
	- @param (optional) screenlocked. Default: true.
	- @param (optional) loveframesVar. Default: loveframes.
	- @return None
--]]---------------------------------------------------------
function colorPicker(color, callback, maketop, modal, screenlocked, loveframesVar)
	local loveframes = loveframes or loveframesVar
	if not loveframes then error("LoveFrames module is nil") end

	---------------------------------------------------------
	-- Presets
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

	---------------------------------------------------------
	-- Utility functions
	---------------------------------------------------------
	local function _clamp(val, lower, upper)
		if lower > upper then
			lower, upper = upper, lower
		end

		return math.max(lower, math.min(upper, val))
	end

	function _genOrderedIndex(tbl)
		local orderedIndex = {}
		for key in pairs(tbl) do
			table.insert(orderedIndex, key)
		end
		table.sort(orderedIndex)
		return orderedIndex
	end

	function _orderedNext(tbl, state)
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

	function _orderedPairs(tbl)
		return _orderedNext, tbl, nil
	end

	---------------------------------------------------------
	-- Color conversion functions
	---------------------------------------------------------
	function _hsv2rgb(h, s, v)
		h = (h*6)%6
		local i = math.floor(h)
		local p = 255*v
		local q = p*(1-s)

		if i == 0 then
			return p, q + p*s*(h-i), q
		elseif i == 1 then
			return p*(1-s*(h-i)), p, q
		elseif i == 2 then
			return q, p, q+p*s*(h-i)
		elseif i == 3 then
			return q, p*(1-s*(h-i)), p
		elseif i == 4 then
			return q+p*s*(h-i), q, p
		elseif i == 5 then
			return p, q, p*(1-s*(h-i))
		end
	end

	function _rgb2hsv(r, g, b)
		local h
		local rgb_max = math.max(r,g,b)
		local rgb_min = math.min(r,g,b)

		if rgb_min < rgb_max then
			if rgb_max == r then
				h = (g-b)/(r-rgb_min)*60
			elseif rgb_max == g then
				h = 120+(b-r)/(g-rgb_min)*60
			else
				h = 240+(r-g)/(b-rgb_min)*60
			end

			if h < 0 then
				h = h+360
			end

			return h/360, 1-rgb_min/rgb_max, rgb_max/255
		else
			return 0, 0, rgb_max/255
		end
	end

	local function _hex2rgb(hex)
		return  tonumber("0x" .. hex:sub(1,2)), tonumber("0x" .. hex:sub(3,4)), tonumber("0x" .. hex:sub(5,6))
	end

	local function _rgb2hex(r, g, b)
		local function _dec2hex(dec)
			local b, k, out, i, d = 16, "0123456789ABCDEF", "", 0
			while dec > 0 do
				i = i + 1
				dec, d = math.floor(dec / b), math.fmod(dec, b) + 1
				out = string.sub(k, d, d) .. out
			end
			while out:len() < 2 do out = "0" .. out end
			return out
		end

		return _dec2hex(r) .. _dec2hex(g) .. _dec2hex(b)
	end

	---------------------------------------------------------
	-- Update functions
	---------------------------------------------------------
	local function _updateImage(object, val1, val2, val3, func, cursorSize, width, height)
		width = width or object:GetWidth()
		height = height or  object:GetHeight()
		local color = love.image.newImageData(width, height)
		color:mapPixel(function(x, y) return func(x, y, val1, val2, val3, cursorSize, width, height) end)
		object:SetImage(love.graphics.newImage(color))
	end

	local function _hsvcolorspace(x, y, hue, saturation, value, cursorSize, width, height)
		if math.floor(math.sqrt(math.pow(x-hue*width, 2) + math.pow(y-(1-value)*height, 2)) + .5) == cursorSize then
			if value > .7 then
				return 0, 0, 0, 255
			else
				return 255, 255, 255, 255
			end
		end
		return _hsv2rgb(x/width, saturation, 1 - y/height)
	end

	local function _hsvcolorslider(x, y, hue, saturation, value, cursorSize, width, height)
		if y >= math.floor((1-saturation)*(height-1)+.5) - cursorSize/2 and y <= math.floor((1-saturation)*(height-1)+.5) + cursorSize/2 then
			if value > .7 then
				return 0, 0, 0, 255
			else
				return 255, 255, 255, 255
			end
		end
		return _hsv2rgb(hue, 1 - y/height, _clamp(value, 0.4, 1))
	end

	local function _rgbcolor(x, y, r, g, b, cursorSize, width, height)
		return r, g, b, 255
	end

	local function _relief(x, y, val1, val2, val3, reliefSize, width, height)
		if reliefSize and x > reliefSize and x < width-reliefSize and y > reliefSize and y < height-reliefSize then
			return 0, 0, 0, 0
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

	local function _getColor()
		local r, g, b = _hsv2rgb(hue, saturation, value)
		return { math.floor(r + .5), math.floor(g + .5), math.floor(b + .5) }
	end

	function _update(ignore)
		local r, g, b = _hsv2rgb(hue, saturation, value)
		local hex = _rgb2hex(r, g, b)

		_updateImage(colorspace, hue, saturation, value, _hsvcolorspace, 6)
		_updateImage(bwSlider, hue, saturation, value, _hsvcolorslider, 1)
		_updateImage(color_current, r, g, b, _rgbcolor)

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
	hue, saturation, value = _rgb2hsv(unpack(color or {255, 0, 0}))

	---------------------------------------------------------
	-- Create window frame
	---------------------------------------------------------
	local frame = loveframes.Create("frame")
	frame:SetName("Color Picker")
	frame:SetSize(400, 250)
	frame:Center()
	frame:MakeTop(maketop or true)
	frame:SetModal(modal or true)
	frame:SetScreenLocked(screenlocked or true)
	frame:SetDraggable(true)

	---------------------------------------------------------
	-- Sunken relief
	---------------------------------------------------------
	local padding = 2

	local relief = loveframes.Create("image", frame)
	_updateImage(relief, nil, nil, nil, _relief, padding, 200+padding*2, 200+padding*2)
	relief:SetPos(13-padding, 37-padding)

	local relief = loveframes.Create("image", frame)
	_updateImage(relief, nil, nil, nil, _relief, padding, 22+padding*2, 200+padding*2)
	relief:SetPos(225-padding, 37-padding)

	local relief = loveframes.Create("image", frame)
	_updateImage(relief, nil, nil, nil, _relief, padding, 55+padding*2, 35+padding*2)
	relief:SetPos(260-padding, 37-padding)

	---------------------------------------------------------
	-- Create HSV color space
	---------------------------------------------------------
	colorspace = loveframes.Create("image", frame)
	_updateImage(colorspace, hue, saturation, value, _hsvcolorspace, 6, 200, 200)
	colorspace:SetPos(13, 37)

	colorspace.Update = function(object, dt)
		if object.dragging then
			hue = _clamp((love.mouse.getX() - object:GetX()) / object:GetWidth(), 0, 1)
			value = 1 - _clamp((love.mouse.getY() - object:GetY()) / object:GetHeight(), 0, 1)
			_update()
		end
	end

	colorspace.mousepressed = function(object, x, y)
		if object.hover then
			choice_presets:SetChoice("Presets")
			object.dragging = true
		end
	end

	colorspace.mousereleased = function(object, x, y)
		if object.dragging then
			object.dragging = false
		end
	end

	---------------------------------------------------------
	-- Create satutation slider
	---------------------------------------------------------
	bwSlider = loveframes.Create("image", frame)
	_updateImage(bwSlider, hue, saturation, value, _hsvcolorslider, 1, 22, 200)
	bwSlider:SetPos(225, 37)

	bwSlider.Update = function(object, dt)
		if object.dragging then
			saturation = 1 - _clamp((love.mouse.getY() - object:GetY()) / object:GetHeight(), 0, 1)
			_update()
		end
	end

	bwSlider.mousepressed = function(object, x, y)
		if object.hover then
			choice_presets:SetChoice("Presets")
			object.dragging = true
		end
	end

	bwSlider.mousereleased = function(object, x, y)
		if object.dragging then
			object.dragging = false
		end
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
				object:SetText(_clamp(tonumber(text), 0, 360))
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
				object:SetText(_clamp(tonumber(text), 0, 100))
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
				object:SetText(_clamp(tonumber(text), 0, 100))
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
				object:SetText(_clamp(tonumber(text), 0, 255))
			end
			local r, g, b = _hsv2rgb(hue, saturation, value)
			hue, saturation, value = _rgb2hsv(tonumber(object:GetText()), g, b)
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
				object:SetText(_clamp(tonumber(text), 0, 255))
			end
			local r, g, b = _hsv2rgb(hue, saturation, value)
			hue, saturation, value = _rgb2hsv(r, tonumber(object:GetText()), b)
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
				object:SetText(_clamp(tonumber(text), 0, 255))
			end
			local r, g, b = _hsv2rgb(hue, saturation, value)
			hue, saturation, value = _rgb2hsv(r, g, tonumber(object:GetText()))
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
			local r, g, b = _hex2rgb(text)
			hue, saturation, value = _rgb2hsv(r, g, b)
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
	local r, g, b = _hsv2rgb(hue, saturation, value)
	local color_old = loveframes.Create("image", frame)
	color_current = loveframes.Create("image", frame)

	color_old:SetPos(260, 37)
	_updateImage(color_old, r, g, b, _rgbcolor, nil, 20, 35)

	color_current:SetPos(280, 37)
	_updateImage(color_current, r, g, b, _rgbcolor, nil, 35, 35)

	---------------------------------------------------------
	-- Ok button, callback
	---------------------------------------------------------
	local button_ok = loveframes.Create("button", frame)
	button_ok:SetSize(60, 35)
	button_ok:SetPos(325, 37)
	button_ok:SetText("Ok")
	button_ok.OnClick = function(object)
		frame:Remove()
		local callback = callback or function(c) print(unpack(c)) end
		callback(_getColor())
	end

	---------------------------------------------------------
	-- Preset box
	---------------------------------------------------------
	choice_presets = loveframes.Create("multichoice", frame)
	choice_presets:SetPos(260, 212)
	choice_presets:SetWidth(125)
	choice_presets:SetText("Presets")
	for choice in _orderedPairs(color_presets) do
		choice_presets:AddChoice(choice)
	end
	choice_presets.OnChoiceSelected = function(object, choice)
		hue, saturation, value = _rgb2hsv(unpack(color_presets[choice]))
		_update()
	end

	---------------------------------------------------------
	-- Starting values
	---------------------------------------------------------
	_update()
end