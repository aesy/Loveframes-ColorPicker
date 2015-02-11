local path = (...):match("(.-)[^%.]+$")
local graphics = require(path .. "utils.graphics")
local utils = require(path .. "utils.utils")

-- TODO in order of priority
-- Add step to left or right
-- Reset & Save button + name field
-- Selection & step markers
-- Shader creation

---------------------------------------------------------
-- Gradient presets
---------------------------------------------------------
local gradient_presets = {
	{
		settings = {
				["name"] = "Greyscale",
				["smoothness"] = 1
			},
		data = {{
				["color"] = {255, 255, 255},
				["position"] = 0
			},{
				["color"] = {0, 0, 0},
				["position"] = 1
			}}
	},{
		settings = {
				["name"] = "Steel Bar",
				["smoothness"] = 0.6
			},
		data = {{
				["color"] = {0, 0, 0},
				["position"] = 0
			},{
				["color"] = {255, 255, 255},
				["position"] = 0.7
			},{
				["color"] = {0, 0, 0},
				["position"] = 1
			}}
	},{
		settings = {
				["name"] = "Silver",
				["smoothness"] = 0.6
			},
		data = {{
				["color"] = {83, 91, 94},
				["position"] = 0
			},{
				["color"] = {253, 253, 253},
				["position"] = 0.25
			},{
				["color"] = {83, 91, 94},
				["position"] = 0.5
			},{
				["color"] = {253, 253, 253},
				["position"] = 0.75
			},{
				["color"] = {83, 91, 94},
				["position"] = 1
			}}
	},{
		settings = {
				["name"] = "FadeOut",
				["smoothness"] = 1
			},
		data = {{
				["color"] = {255, 255, 255, 255},
				["position"] = 0
			},{
				["color"] = {255, 255, 255, 0},
				["position"] = 1
			}}
	},{
		settings = {
				["name"] = "RedBlue",
				["smoothness"] = 1
			},
		data = {{
				["color"] = {255, 0, 0},
				["position"] = 0
			},{
				["color"] = {0, 0, 255},
				["position"] = 1
			}}
	},{
		settings = {
				["name"] = "RdYlGn",
				["smoothness"] = 0.6
			},
		data = {{
				["color"] = {165, 0, 38},
				["position"] = 0
			},{
				["color"] = {244, 109, 67},
				["position"] = 0.25
			},{
				["color"] = {255, 255, 191},
				["position"] = 0.5
			},{
				["color"] = {102, 189, 99},
				["position"] = 0.75
			},{
				["color"] = {0, 104, 55},
				["position"] = 1
			}}
	},{
		settings = {
				["name"] = "Glossy",
				["smoothness"] = 1
			},
		data = {{
				["color"] = {66, 66, 66},
				["position"] = 0
			},{
				["color"] = {63, 63, 63},
				["position"] = 0.5
			},{
				["color"] = {86, 86, 86},
				["position"] = 0.49999999
			},{
				["color"] = {149, 149, 149},
				["position"] = 1
			}}
	},{
		settings = {
				["name"] = "Rainbow",
				["smoothness"] = 0.6
			},
		data = {{
				["color"] = {255, 0, 0, 0},
				["position"] = 0
			},{
				["color"] = {255, 0, 0, 204},
				["position"] = 0.07
			},{
				["color"] = {255, 0, 0},
				["position"] = 0.12
			},{
				["color"] = {255, 252, 0},
				["position"] = 0.28
			},{
				["color"] = {1, 180, 57},
				["position"] = 0.45
			},{
				["color"] = {0, 234, 255},
				["position"] = 0.60
			},{
				["color"] = {0, 3, 144},
				["position"] = 0.75
			},{
				["color"] = {255, 0, 198},
				["position"] = 0.88
			},{
				["color"] = {255, 0, 198, 204},
				["position"] = 0.92
			},{
				["color"] = {255, 0, 198, 0},
				["position"] = 1
			}}
	},{
		settings = {
				["name"] = "Horizon",
				["smoothness"] = 1
			},
		data = {{
				["color"] = {255, 255, 255},
				["position"] = 0
			},{
				["color"] = {217, 159, 0},
				["position"] = 0.36
			},{
				["color"] = {144, 106, 0},
				["position"] = 0.48
			},{
				["color"] = {255, 255, 255},
				["position"] = 0.50
			},{
				["color"] = {41, 137, 204},
				["position"] = 1
			}}
	},{
		settings = {
				["name"] = "Landscape",
				["smoothness"] = 1
			},
		data = {{
				["color"] = {0, 0, 0},
				["position"] = 0
			},{
				["color"] = {87, 178, 53},
				["position"] = 0.30
			},{
				["color"] = {163, 235, 8},
				["position"] = 0.49
			},{
				["color"] = {227, 233, 252},
				["position"] = 0.50
			},{
				["color"] = {205, 219, 234},
				["position"] = 0.60
			},{
				["color"] = {146, 179, 253},
				["position"] = 0.80
			},{
				["color"] = {39, 107, 228},
				["position"] = 1
			}}
	},{
		settings = {
				["name"] = "Atmosphere",
				["smoothness"] = 1
			},
		data = {{
				["color"] = {196, 187, 178},
				["position"] = 0
			},{
				["color"] = {235, 226, 227},
				["position"] = 0.30
			},{
				["color"] = {86, 143, 252},
				["position"] = 0.45
			},{
				["color"] = {4, 57, 153},
				["position"] = 0.70
			},{
				["color"] = {1, 25, 71},
				["position"] = 1
			}}
	}
}

--[[---------------------------------------------------------
	- gradientEditor({})
	-
	- @param any parameter of colorPicker({}).
	-
	- @returns loveframes frame.
--]]---------------------------------------------------------
function gradientEditor(options)
	local options = options or {}
	local loveframes = loveframes or options.loveframes
	assert(loveframes, "LoveFrames module is nil")

	---------------------------------------------------------
	-- local functions
	---------------------------------------------------------
	local function _update()
		selection:SetMax(#colors)
		-- colors_sorted = utils.sort_by_value(colors, "position")

		gradient:SetImage(graphics.create_image(gradient:GetWidth(), gradient:GetHeight(),
			graphics.image_functions.multi_gradient, {
				["direction"] = "horizontal",
				["colors"] = utils.shallow_copy(colors),
				["smoothness"] = smoothness:GetValue(),
			})
		)

		if #colors == 1 then
			delete:SetEnabled(false)
		else
			delete:SetEnabled(true)
		end
	end

	---------------------------------------------------------
	-- Load local presets
	---------------------------------------------------------
	-- print(love.filesystem.write("gradient_presets", utils.serialize(gradient_presets)))
	local load_colors = loadstring(love.filesystem.read("gradient_presets") or "")()
	if load_colors then
		gradient_presets = load_colors
	end

	---------------------------------------------------------
	-- Local variables
	---------------------------------------------------------
	colors = options.color or utils.deep_copy(gradient_presets[1].data)

	---------------------------------------------------------
	-- Create window frame
	---------------------------------------------------------
	local frame = loveframes.Create("frame")
	frame:SetName("Gradient Editor")
	frame:SetSize(450, 370)
	frame:Center()
	frame:MakeTop(options.makeTop ~= nil and options.makeTop or true)
	frame:SetModal(options.modal ~= nil and options.modal or true)
	frame:SetScreenLocked(options.screenLocked ~= nil and options.screenLocked or true)
	frame:SetDraggable(true)

	---------------------------------------------------------
	-- Ok/cancel button, callback
	---------------------------------------------------------
	local button_ok = loveframes.Create("button", frame)
	button_ok:SetSize(105, 39)
	button_ok:SetPos(330, 40)
	button_ok:SetText("Ok")
	button_ok.OnClick = function(object)
		frame:Remove()

		if options.callback then
			local c = {
				settings = {
						["name"] = "",
						["smoothness"] = smoothness:GetValue()
					},
				data = utils.deep_copy(colors)
			}

			local function func(width, height, direction)
				direction = direction == "vertical" and "vertical" or "horizontal"

				return graphics.create_image(width, height,
					graphics.image_functions.multi_gradient, {
						["direction"] = direction,
						["colors"] = utils.shallow_copy(c.data),
						["smoothness"] = c.settings.smoothness,
					}
				)
			end

			c.createImage = func

			options.callback(c)
		end
	end

	local button_cancel = loveframes.Create("button", frame)
	button_cancel:SetSize(105, 25)
	button_cancel:SetPos(330, 94)
	button_cancel:SetText("Cancel")
	button_cancel.OnClick = function(object)
		frame:Remove()
	end

	---------------------------------------------------------
	-- Presets border/relief
	---------------------------------------------------------
	local border = loveframes.Create("image", frame)
	border:SetImage(graphics.create_image(300, 100,
		graphics.image_functions.border, {
			["text_offset"] = 20,
			["text_width"] = 80
		})
	)
	border:SetPos(15, 40)

	local text = loveframes.Create("text", frame)
	text:SetPos(50, 33)
	text:SetText("Presets")

	local padding = 2
	local margin = 12

	local relief = loveframes.Create("image", frame)
	relief:SetImage(graphics.create_image(border:GetWidth()-margin*2+padding*2, border:GetHeight()-margin*2+padding*2,
		graphics.image_functions.relief, {
			["size"] = padding
		})
	)
	relief:SetPos(border:GetStaticX()+margin-padding, border:GetStaticY()+margin-padding)

	local list = loveframes.Create("list", frame)
	list:SetDisplayType("vertical")
	list:EnableHorizontalStacking(true)
	list:SetPos(relief:GetStaticX()+padding, relief:GetStaticY()+padding)
	list:SetSize(relief:GetWidth()-padding*2, relief:GetHeight()-padding*2)
	list:SetPadding(3)
	list:SetSpacing(3)

	---------------------------------------------------------
	-- Presets
	---------------------------------------------------------
	for index, preset in ipairs(gradient_presets) do
		local cell_width = 35

		local image = loveframes.Create("image", frame)
		image.index = index
		image:SetImage(graphics.create_image(cell_width, cell_width,
			graphics.image_functions.multi_gradient, {
				["direction"] = "horizontal",
				["colors"] = preset.data,
				["smoothness"] = preset.settings.smoothness,
			})
		)

		image.mousepressed = function(object)
			if object.hover then
				object.dragging = true
			end
		end

		image.mousereleased = function(object)
			if object.hover and object.dragging then
				colors = utils.deep_copy(gradient_presets[object.index].data)
				_update()
				smoothness:SetValue(gradient_presets[object.index].settings.smoothness)
				selection:SetValue(1)
				selection.OnValueChanged(selection, selection:GetValue())
			end

			if object.dragging then
				object.dragging = false
			end
		end

		local tooltip = loveframes.Create("tooltip")
		tooltip:SetObject(image)
		tooltip:SetPadding(10)
		tooltip:SetText(preset.settings.name)
		tooltip:SetOffsets(0, cell_width + 1)
		tooltip:SetFollowCursor(false)
		tooltip:SetFollowObject(true)

		list:AddItem(image)
	end

	---------------------------------------------------------
	-- Smoothness setting
	---------------------------------------------------------
	local border = loveframes.Create("image", frame)
	border:SetImage(graphics.create_image(420, 195,
		graphics.image_functions.border, {
			["text_offset"] = 20,
			["text_width"] = 195
		})
	)
	border:SetPos(15, 160)

	local text = loveframes.Create("text", frame)
	text:SetPos(50, 153)
	text:SetText("Smoothness:")

	smoothness = loveframes.Create("slider", frame)
	smoothness:SetPos(137, 150)
	smoothness:SetWidth(80)
	smoothness:SetMinMax(0, 1)
	smoothness:SetValue(1)
	smoothness:SetDecimals(2)

	smoothness.OnValueChanged = function(object, value)
		_update()
	end

	---------------------------------------------------------
	-- Sunken relief
	---------------------------------------------------------
	local padding = 1

	local relief = loveframes.Create("image", frame)
	relief:SetImage(graphics.create_image(390+padding*2, 25+padding*2,
		graphics.image_functions.relief, {
			["size"]=padding,
			["background"] = {220, 220, 220}
		})
	)
	relief:SetPos(30-padding, 190-padding)

	---------------------------------------------------------
	-- Create gradient
	---------------------------------------------------------
	gradient = loveframes.Create("image", frame)
	gradient:SetSize(390, 25)
	gradient:SetPos(30, 190)

	---------------------------------------------------------
	-- Edit area
	---------------------------------------------------------
	local border = loveframes.Create("image", frame)
	border:SetImage(graphics.create_image(400, 85,
		graphics.image_functions.border, {
			["text_offset"] = 15,
			["text_width"] = 55
		})
	)
	border:SetPos(25, 260)

	local text = loveframes.Create("text", frame)
	text:SetPos(50, 253)
	text:SetText("Stops")

	---------------------------------------------------------
	-- Edit first row
	---------------------------------------------------------
	local text = loveframes.Create("text", frame)
	text:SetPos(40, 280)
	text:SetText("Selection:")

	selection = loveframes.Create("numberbox", frame)
	selection:SetPos(110, 274)
	selection:SetSize(60, 25)
	selection:SetMinMax(1, #colors)
	selection:SetValue(1)
	selection.OnValueChanged = function(object, value)
		location:SetValue(colors[value]["position"]*100)
		alpha:SetValue((colors[value]["color"][4] or 255) / 2.55)
		color_button:SetColor(colors[value]["color"])
	end

	local text = loveframes.Create("text", frame)
	text:SetPos(185, 280)
	text:SetText("Location:")

	location = loveframes.Create("numberbox", frame)
	location:SetMinMax(0, 100)
	location:SetPos(250, 274)
	location:SetSize(60, 25)
	location:SetValue(colors[1]["position"])
	location.OnValueChanged = function(object, value)
		local i = selection:GetValue()
		colors[i]["position"] = value/100
		_update()
	end

	delete = loveframes.Create("button", frame)
	delete:SetSize(80, 25)
	delete:SetPos(330, 274)
	delete:SetText("Delete")
	delete.OnClick = function(object)
		local i = selection:GetValue()
		table.remove(colors, i)
		_update()
		selection.OnValueChanged(selection, selection:GetValue())
	end

	---------------------------------------------------------
	-- Edit second row
	---------------------------------------------------------
	local text = loveframes.Create("text", frame)
	text:SetPos(65, 315)
	text:SetText("Color:")

	color_button = colorButton({
			parent = frame,
			color = colors[1]["color"],
			width = 60,
			height = 25,
			padding = 3,
			callback = function(color)
				local i = selection:GetValue()
				colors[i]["color"] = color
				colors[i]["color"][4] = alpha:GetValue()*2.55
				_update()
			end
		})
	color_button:SetPos(110, 309)

	local text = loveframes.Create("text", frame)
	text:SetPos(205, 315)
	text:SetText("Alpha:")

	alpha = loveframes.Create("numberbox", frame)
	alpha:SetMinMax(0, 100)
	alpha:SetPos(250, 309)
	alpha:SetSize(60, 25)
	alpha:SetValue(colors[1]["color"][4] or 100)
	alpha.OnValueChanged = function(object, value)
		local i = selection:GetValue()
		colors[i]["color"][4] = value*2.55
		_update()
	end

	---------------------------------------------------------
	-- Starting values
	---------------------------------------------------------
	_update()

	return frame
end