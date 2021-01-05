--[[
	Project: RoguelikeProto
	File: conf.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 10/31/2016
	
	Comments:
		Config file for LÖVE initialization
--]]

function love.conf(t)
	t.version = "0.10.1"
	t.console = true
	
	t.window.title = "RoguelikeProto"
	t.window.icon = "assets/img/proj/part.png"
	t.window.width = 1280
	t.window.height = 1024
	t.window.borderless = false
	t.window.resizable = false
	t.window.fullscreen = false
	t.window.vsync = false
	
	bDebug = false
	
	t.modules.physics = false
end
