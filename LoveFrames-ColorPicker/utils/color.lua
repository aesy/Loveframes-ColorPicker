---------------------------------------------------------
-- Color conversion functions
---------------------------------------------------------
local function hsv2rgb(h, s, v)
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

local function rgb2hsv(r, g, b)
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

local function hex2rgb(hex)
	return  tonumber("0x" .. hex:sub(1,2)), tonumber("0x" .. hex:sub(3,4)), tonumber("0x" .. hex:sub(5,6))
end

local function rgb2hex(r, g, b)
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
-- Return
---------------------------------------------------------
return {
	["hsv2rgb"]	= hsv2rgb,
	["rgb2hsv"]	= rgb2hsv,
	["hex2rgb"]	= hex2rgb,
	["rgb2hex"]	= rgb2hex,
}