local path = (...):match("(.-)[^%.]+$")
local graphics = require(path .. "utils.graphics")
local utils = require(path .. "utils.utils")

-- TODO in order of priority
-- Add step to left or right
-- Reset & Save button + name field
-- Selection & step markers
-- Shader creation

--[[---------------------------------------------------------
	- gradientEditor
	-
	- @method gradientEditor:Open({})
	- @param any parameter of colorPicker({}).
	-
	-
	- @returns loveframes frame.
--]]---------------------------------------------------------
gradientEditor = {}

function gradientEditor:Open(options)
	self.options = options or {}

	self.loveframes = loveframes or self.options.loveframes
	assert(self.loveframes, "LoveFrames module is nil")

	-- print(love.filesystem.write("gradient_presets", utils.serialize(gradient_presets)))
	local load_colors = loadstring(love.filesystem.read("gradient_presets.sav") or "")()
	if load_colors then
		self.gradient_presets = load_colors
	end

	self.gradient = self.options.gradient or utils.deep_copy(self.gradient_presets[1])

	self:_CreateInterface()

	self:_Update()
end

setmetatable(gradientEditor, { __call = gradientEditor.Open })


function gradientEditor:CreateImage(gradient, width, height, rotate)
	return graphics.create_image(width, height,
		graphics.image_functions.gradient, {
			["rotate"] = rotate,
			["colors"] = utils.shallow_copy(gradient.data),
			["smoothness"] = gradient.settings.smoothness,
		}
	)
end


function gradientEditor:_GetGradient()
	return {
		settings = {
				["name"] = "", -- Add name here
				["smoothness"] = self.smoothness:GetValue()
			},
		data = utils.deep_copy(self.gradient.data)
	}
end


function gradientEditor:_Update()
	self.selection:SetMax(#self.gradient.data)
	-- colors_sorted = utils.sort_by_value(self.gradient.data, "position")

	local image = self:CreateImage(self:_GetGradient(), self.gradientImage:GetWidth(), self.gradientImage:GetHeight(), 0)
	self.gradientImage:SetImage(image)

	if #self.gradient.data == 1 then
		self.delete:SetEnabled(false)
	else
		self.delete:SetEnabled(true)
	end
end


function gradientEditor:_Callback()
	if self.options.callback then
		local gradient = self:_GetGradient()

		function gradient:CreateImage(width, height, rotate)
			return graphics.create_image(width, height,
				graphics.image_functions.gradient, {
					["rotate"] = rotate,
					["colors"] = self.data,
					["smoothness"] = self.settings.smoothness,
				}
			)
		end

		function gradient:Open(options)
			options.gradient = self
			self:Open(options)
		end

		self.options.callback(gradient)
	end
end


function gradientEditor:_CreateInterface()
	self.frame = self.loveframes.Create("frame")
	self.frame:SetName("Gradient Editor")
	self.frame:SetSize(450, 370)
	self.frame:Center()
	self.frame:MakeTop(utils.ternary(self.options.makeTop ~= nil, self.options.makeTop, true))
	self.frame:SetModal(utils.ternary(self.options.modal ~= nil, self.options.modal, true))
	self.frame:SetScreenLocked(utils.ternary(self.options.screenLocked ~= nil, self.options.screenLocked, true))
	self.frame:SetDraggable(true)

	local button = self.loveframes.Create("button", self.frame)
	button:SetSize(105, 39)
	button:SetPos(330, 40)
	button:SetText("Ok")
	button.OnClick = function(object)
		self.frame:Remove()
		self:_Callback()
	end

	local button = self.loveframes.Create("button", self.frame)
	button:SetSize(105, 25)
	button:SetPos(330, 94)
	button:SetText("Cancel")
	button.OnClick = function(object)
		self.frame:Remove()
	end

	self:_CreatePresets()
	self:_CreateEditor(0)
end


function gradientEditor:_CreateEditor(offsetY)
	---------------------------------------------------------
	-- Smoothness setting
	---------------------------------------------------------
	local border = self.loveframes.Create("image", self.frame)
	border:SetImage(graphics.create_image(420, 195,
		graphics.image_functions.border, {
			["text_offset"] = 20,
			["text_width"] = 195
		})
	)
	border:SetPos(15, 160)

	local text = self.loveframes.Create("text", self.frame)
	text:SetPos(50, 153)
	text:SetText("Smoothness:")

	self.smoothness = self.loveframes.Create("slider", self.frame)
	self.smoothness:SetPos(137, 150)
	self.smoothness:SetWidth(80)
	self.smoothness:SetMinMax(0, 1)
	self.smoothness:SetValue(1)
	self.smoothness:SetDecimals(2)
	self.smoothness.OnValueChanged = function()
		self:_Update()
	end

	---------------------------------------------------------
	-- Sunken relief
	---------------------------------------------------------
	local padding = 2

	local relief = self.loveframes.Create("image", self.frame)
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
	self.gradientImage = self.loveframes.Create("image", self.frame)
	self.gradientImage:SetSize(390, 25)
	self.gradientImage:SetPos(30, 190)

	---------------------------------------------------------
	-- Edit area
	---------------------------------------------------------
	local border = self.loveframes.Create("image", self.frame)
	border:SetImage(graphics.create_image(400, 85,
		graphics.image_functions.border, {
			["text_offset"] = 15,
			["text_width"] = 55
		})
	)
	border:SetPos(25, 260)

	local text = self.loveframes.Create("text", self.frame)
	text:SetPos(50, 253)
	text:SetText("Stops")

	---------------------------------------------------------
	-- First row
	---------------------------------------------------------
	local text = self.loveframes.Create("text", self.frame)
	text:SetPos(40, 280)
	text:SetText("Selection:")

	self.selection = self.loveframes.Create("numberbox", self.frame)
	self.selection:SetPos(110, 274)
	self.selection:SetSize(60, 25)
	self.selection:SetMinMax(1, #self.gradient.data)
	self.selection:SetValue(1)
	self.selection.OnValueChanged = function(object, value)
		self.location:SetValue(self.gradient.data[value]["position"]*100)
		self.alpha:SetValue((self.gradient.data[value]["color"][4] or 255) / 2.55)
		self.color_button:SetColor(self.gradient.data[value]["color"])
	end

	local text = self.loveframes.Create("text", self.frame)
	text:SetPos(185, 280)
	text:SetText("Location:")

	self.location = self.loveframes.Create("numberbox", self.frame)
	self.location:SetMinMax(0, 100)
	self.location:SetPos(250, 274)
	self.location:SetSize(60, 25)
	self.location:SetValue(self.gradient.data[1]["position"])
	self.location.OnValueChanged = function(object, value)
		local i = self.selection:GetValue()
		self.gradient.data[i]["position"] = value/100
		self:_Update()
	end

	self.delete = self.loveframes.Create("button", self.frame)
	self.delete:SetSize(80, 25)
	self.delete:SetPos(330, 274)
	self.delete:SetText("Delete")
	self.delete.OnClick = function(object)
		local i = self.selection:GetValue()
		table.remove(self.gradient.data, i)
		self:_Update()
		self.selection.OnValueChanged(self.selection, self.selection:GetValue())
	end

	---------------------------------------------------------
	-- Second row
	---------------------------------------------------------
	local text = self.loveframes.Create("text", self.frame)
	text:SetPos(65, 315)
	text:SetText("Color:")

	self.color_button = colorButton({
			parent = self.frame,
			color = self.gradient.data[1]["color"],
			width = 60,
			height = 25,
			padding = 3,
			callback = function(color)
				local i = self.selection:GetValue()
				self.gradient.data[i]["color"] = color
				self.gradient.data[i]["color"][4] = self.alpha:GetValue()*2.55
				self:_Update()
			end
		})
	self.color_button:SetPos(110, 309)

	local text = self.loveframes.Create("text", self.frame)
	text:SetPos(205, 315)
	text:SetText("Alpha:")

	self.alpha = self.loveframes.Create("numberbox", self.frame)
	self.alpha:SetMinMax(0, 100)
	self.alpha:SetPos(250, 309)
	self.alpha:SetSize(60, 25)
	self.alpha:SetValue(self.gradient.data[1]["color"][4] or 100)
	self.alpha.OnValueChanged = function(object, value)
		local i = self.selection:GetValue()
		self.gradient.data[i]["color"][4] = value*2.55
		self:_Update()
	end

end


function gradientEditor:_CreatePresets()
	local border = self.loveframes.Create("image", self.frame)
	border:SetImage(graphics.create_image(300, 100,
		graphics.image_functions.border, {
			["text_offset"] = 20,
			["text_width"] = 80
		})
	)
	border:SetPos(15, 40)

	local text = self.loveframes.Create("text", self.frame)
	text:SetPos(50, 33)
	text:SetText("Presets")

	local padding = 2
	local margin = 12

	local relief = self.loveframes.Create("image", self.frame)
	relief:SetImage(graphics.create_image(border:GetWidth()-margin*2+padding*2, border:GetHeight()-margin*2+padding*2,
		graphics.image_functions.relief, {
			["size"] = padding
		})
	)
	relief:SetPos(border:GetStaticX()+margin-padding, border:GetStaticY()+margin-padding)

	self.preset_list = self.loveframes.Create("list", self.frame)
	self.preset_list:SetDisplayType("vertical")
	self.preset_list:EnableHorizontalStacking(true)
	self.preset_list:SetPos(relief:GetStaticX()+padding, relief:GetStaticY()+padding)
	self.preset_list:SetSize(relief:GetWidth()-padding*2, relief:GetHeight()-padding*2)
	self.preset_list:SetPadding(3)
	self.preset_list:SetSpacing(3)

	self:_PopulatePresets()
end


function gradientEditor:_PopulatePresets()
	for index, preset in ipairs(self.gradient_presets) do
		local cell_width = 35

		local image = self.loveframes.Create("image", self.frame)
		image.index = index
		image:SetImage(graphics.create_image(cell_width, cell_width,
			graphics.image_functions.gradient, {
				["rotate"] = math.pi*(7/4),
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
				self.gradient.data = utils.deep_copy(self.gradient_presets[object.index].data)
				self:_Update()
				self.smoothness:SetValue(self.gradient_presets[object.index].settings.smoothness)
				self.selection:SetValue(1)
				self.selection.OnValueChanged(self.selection, self.selection:GetValue())
			end

			if object.dragging then
				object.dragging = false
			end
		end

		local tooltip = self.loveframes.Create("tooltip")
		tooltip:SetObject(image)
		tooltip:SetPadding(10)
		tooltip:SetText(preset.settings.name)
		tooltip:SetOffsets(0, cell_width + 1)
		tooltip:SetFollowCursor(false)
		tooltip:SetFollowObject(true)

		self.preset_list:AddItem(image)
	end
end


gradientEditor.gradient_presets = {
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

