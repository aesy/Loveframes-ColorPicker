# Overview
A color picker for [Love Frames](https://github.com/NikolaiResokav/LoveFrames) - GUI library for [LÖVE](http://www.love2d.org).

## Installation
Option 1. Place ``colorPicker.lua`` inside your LoveFrames objects directory.
Option 2. Place ``colorPicker.lua`` anywhere and require it after LoveFrames.

## Usage
Call ``colorPicker()`` within your code. It takes 2 arguments, initial color (rgb table) to display and a callback function.

## Example usage

	local button = loveframes.Create("button", frame)
	button:SetWidth(200)
	button:SetText("Color Picker")
	button.OnClick = function(object, x, y)
		colorPicker({255, 0, 0}, function(color) print(unpack(color)) end)
	end