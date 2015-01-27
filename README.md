# Overview
A color picker for [Love Frames](https://github.com/NikolaiResokav/LoveFrames) - GUI library for [LÖVE](http://www.love2d.org).

## Installation
Option 1. Place all *.lua-files inside your LoveFrames objects directory.

Option 2. Place all *.lua-files somewhere else and require ``colorPicker.lua`` after LoveFrames.

## Usage of colorPicker
Call ``colorPicker()`` within your code. It takes 6 arguments:

1. (optional) Initial color, in the form of a {r, g, b} table. Default: ``{255, 0, 0}``.
2. (optional) A callback function. A {r, g, b} table is passed to it. Default: ``function(c) print(unpack(c)) end``.
3. (optional) Make Top, boolean. Default: ``true``.
4. (optional) Modal, boolean. Default: ``true``.
5. (optional) Screen Locked, boolean. Default: ``true``.
6. (optional) The loveframes module itself. Default: ``loveframes``.

Returns ``nil``.

![Screenshot](colorPicker.png)

## Example usage of colorPicker
	function doStuff(color)
		-- stuff
	end

	colorPicker({255, 0, 0}, doStuff)


## Usage of colorButton
Call ``colorButton()`` within your code. It takes 7 arguments:

1. (optional) Parent, LoveFrames object. Default: ``nil``.
2. (optional) Color, {r, g, b} table. Default: ``{255, 0, 0}``.
3. (optional) A callback function. A {r, g, b} table is passed to it. Default: ``nil``.
4. (optional) Width, integer. Default: ``80``.
5. (optional) Height, integer. Default: ``25``.
6. (optional) Padding, integer. Default: ``3``.
7. (optional) The loveframes module itself. Default: ``loveframes``.

Returns a modified LoveFrames button. All original methods will still work on it, plus two new: ``GetColor()`` & ``SetColor()``.

![Screenshot](colorButton.gif)

## Example usage of colorButton
	local button = colorButton(nil, {0, 255, 0}, nil, 25, 25, 4)
	button:SetPos(100, 100)
	button:GetColor() -- returns {0, 255, 0}


## Issues
Pixel manipulation is used to update the colors of the sliders, and it's slow. I might change to shaders in the future, but in the meantime you can require [this](https://github.com/slime73/love-snippets/blob/master/ImageData-FFI/imagedata-ffi.lua) in your project to get a considerable speed boost.
