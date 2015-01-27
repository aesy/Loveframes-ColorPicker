function colorButton(parent, color, callback, width, height, padding, loveframesVar)
	local loveframes = loveframes or loveframesVar
	assert(loveframes, "LoveFrames module is nil")

	local button = loveframes.Create("button", parent)

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
			if callback then
				callback(c)
			end
		end
		colorPicker(object.color, func, nil, nil, nil, loveframes)
	end

	button.color = color or {255, 0, 0}
	button.padding = padding or 3
	button:SetSize(width or 80, height or 25)
	button:SetText("")
	button:SetColor(button.color)

	return button
end