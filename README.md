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
* @param ``shaders`` (optional) boolean. Default: ``false``. *``Only work with LÖVE past version 0.9.0. Yields a speed boost. Only reason it's off by default is because it's still tweaked.``*
* @returns nil

## Example usage of colorPicker
	function doStuff(color)
		-- stuff
	end

	colorPicker({
		color = {255, 0, 0},
		callback = doStuff,
		shaders = true
	})

![Screenshot](colorPicker.png)


## Usage of colorButton
Call ``colorButton()`` within your code. It takes a table of parameters:

* @param ``parent`` (optional) loveframes object. Default: ``nil``.
* @param ``width`` (optional) integer. Default: ``25``.
* @param ``height`` (optional) integer. Default: ``25``.
* @param ``padding`` (optional) integer. Default: ``3``.
* @returns a modified instance of loveframes button

Any parameter of ``colorPicker()`` is also accepted.

The returned object has all methods of a loveframes button, plus two more: ``GetColor()``, and ``SetColor({r, g, b})``.

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