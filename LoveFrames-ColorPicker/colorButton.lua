local path = (...):match("(.-)[^%.]+$")
local utils = require(path .. "utils.utils")

--[[---------------------------------------------------------
	- colorButton({})
	-
	- @param 'parent' (optional) loveframes object. Default: nil.
	- @param 'width' (optional) integer. Default: 25.
	- @param 'height' (optional) integer. Default: 25.
	- @param 'padding' (optional) integer. Default: 3.
	- @param any parameter of colorPicker({}).
	-
	- @returns modified instance of loveframes button.
--]]---------------------------------------------------------
function colorButton(options)
	local options = options or {}
	local loveframes = loveframes or options.loveframes
	assert(loveframes, "LoveFrames module is nil")

	local button = loveframes.Create("button", options.parent or parent)

	function button:SetColor(color)
		self.color = color
	end

	function button:GetColor(color)
		return self.color
	end

	function button:draw()
		local state = loveframes.state
		local selfstate = self.state
		if state ~= selfstate then
			return
		end
		local visible = self.visible
		if not visible then
			return
		end
		local skins = loveframes.skins.available
		local skinindex = loveframes.config["ACTIVESKIN"]
		local defaultskin = loveframes.config["DEFAULTSKIN"]
		local selfskin = self.skin
		local skin = skins[selfskin] or skins[skinindex]
		local drawfunc = skin.DrawButton or skins[defaultskin].DrawButton
		local draw = self.Draw
		local drawcount = loveframes.drawcount
		self:SetDrawOrder()
		if draw then
			draw(self)
		else
			drawfunc(self)
		end
		love.graphics.setColor(self.color)
		love.graphics.rectangle("fill", self.x + self.padding, self.y + self.padding, self.width - self.padding*2, self.height - self.padding*2)
	end

	button.OnClick = function(object)
		local function func(c)
			object:SetColor(c)
			if options.callback then
				options.callback(c)
			end
		end

		local parameters = utils.table_copy(options)
		parameters.callback = func
		parameters.color = object.color
		colorPicker(parameters)
	end

	button.color = options.color or {255, 0, 0}
	button.padding = options.padding or 3
	button:SetSize(options.width or 25, options.height or 25)
	button:SetText("")
	button:SetColor(button.color)

	return button
end