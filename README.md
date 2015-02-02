# Overview
A color picker for [Love Frames](https://github.com/NikolaiResokav/LoveFrames) - GUI library for [LÖVE](http://www.love2d.org).

## Installation
Place the ``LoveFrames-ColorPicker`` folder in your working directory, or in a sub-folder, and require it.

	require("LoveFrames-ColorPicker")


## Usage of colorPicker
Call ``colorPicker()`` within your code. It takes a table of parameters:

* @param ``color`` (optional) rgb table. Default: ``{255, 0, 0}``.
* @param ``callback`` (optional) function. Default: ``function(c) print(unpack(c)) end``.
* @param ``makeTop`` (optional) boolean. Default: ``true``.
* @param ``modal`` (optional) boolean. Default: ``true``.
* @param ``screenLocked`` (optional) boolean. Default: ``true``.
* @param ``loveframes`` (optional) module. Default: ``loveframes``.
* @param ``shaders`` (optional) boolean. Default: ``true``. *``Only work with LÖVE past version 0.9.0.``*
* @returns a loveframes frame instance.

Performance difference between shaders/imagedata:

| ``Avg FPS`` | shaders false | shaders false with [imagedata-ffi](https://github.com/slime73/love-snippets/blob/master/ImageData-FFI/imagedata-ffi.lua) | shaders true |
|:------------|----:|----:|----:|
| idle        | 478 | 478 | 479 |
| used        | 124 | 193 | 480 |

Reference System - Intel Core i7 4770K @ 3.50 GHz | AMD Radeon HD 7790 | Windows 8.1

## Example usage of colorPicker
	function doStuff(color)
		-- stuff
	end

	colorPicker({
		color = {164, 198, 57},
		callback = doStuff
	})

![Screenshot](colorPicker.png)


## Usage of colorButton
Call ``colorButton()`` within your code. It takes a table of parameters:

* @param ``parent`` (optional) loveframes object. Default: ``nil``.
* @param ``width`` (optional) integer. Default: ``25``.
* @param ``height`` (optional) integer. Default: ``25``.
* @param ``padding`` (optional) integer. Default: ``3``.
* @returns a modified instance of loveframes button.

Any parameters of ``colorPicker()`` are also accepted.

The returned object has all methods of a loveframes button, plus two more: ``GetColor()``, and ``SetColor({r, g, b})``.

## Example usage of colorButton
	local button = colorButton({
			color = {107, 218, 20},
			padding = 4
		})
	button:SetPos(100, 100)
	button:GetColor() -- returns {107, 218, 20}

![Screenshot](colorButton.gif)


## Issues
~~Pixel manipulation is used to update the colors of the sliders, and it's slow.~~