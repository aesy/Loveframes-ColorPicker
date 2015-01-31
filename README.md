# Overview
A color picker for [Love Frames](https://github.com/NikolaiResokav/LoveFrames) - GUI library for [LÖVE](http://www.love2d.org).

## Installation
Place the ``LoveFrames-ColorPicker`` folder in your working directory, or in a sub-folder, and require it.

	require("LoveFrames-ColorPicker")


## Usage of colorPicker
Call ``colorPicker()`` within your code. It takes a table of arguments:

@param ``color`` (optional) rgb table. Default: ``{255, 0, 0}``.
@param ``callback`` (optional) function. Default: ``function(c) print(unpack(c)) end``.
@param ``makeTop`` (optional) boolean. Default: ``true``.
@param ``modal`` (optional) boolean. Default: ``true``.
@param ``screenLocked`` (optional) boolean. Default: ``true``.
@param ``shaders`` (optional) boolean. Default: ``false``. Only works with a LÖVE past version 0.9.0. Using it yields a big speed boost. Only reason it's off by default is because i'm still tweaking it.
@param ``loveframes`` (optional) module. Default: ``loveframes``.

@return nil


## Example usage of colorPicker
	function doStuff(color)
		-- stuff
	end

	colorPicker({
		color = {10, 20, 30},
		callback = doStuff,
		shaders = true
	})

![Screenshot](colorPicker.png)


## Usage of colorButton
Call ``colorButton()`` within your code. It takes a table of arguments:

@param ``parent`` (optional) loveframes object. Default: ``nil``.
@param ``color`` (optional) rgb table. Default: ``{255, 0, 0}``.
@param ``callback`` (optional) function. Default: ``nil``.
@param ``width`` (optional) integer. Default: ``25``.
@param ``height`` (optional) integer. Default: ``25``.
@param ``padding`` (optional) integer. Default: ``3``.
@param ``shaders`` (optional) boolean. Default: ``false``.
@param ``loveframes`` (optional) module. Default: ``loveframes``.

@return modified instance of loveframes button

## Example usage of colorButton
	local button = colorButton({
			color = {0, 255, 0},
			padding = 4,
			shaders = true
		})
	button:SetPos(100, 100)
	button:GetColor() -- returns {0, 255, 0}

![Screenshot](colorButton.gif)


## Issues
~~Pixel manipulation is used to update the colors of the sliders, and it's slow.~~