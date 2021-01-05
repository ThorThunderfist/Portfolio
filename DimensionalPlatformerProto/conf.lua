--[[
	Project: Dimensional Platformer
	File: conf.lua
	Author: David "Thor Thunderfist" Hack
	
	Comments:
		Config file for LÖVE initialization
--]]

function love.conf(t)
	t.version = "11.2"
	t.console = true
	
	t.window.title = "Dimensional Platformer"
	t.window.icon = "assets/img/cursor.png"
	t.window.width = 1280
	t.window.height = 1024
	t.window.borderless = false
	t.window.resizable = false
	t.window.fullscreen = false
	t.window.vsync = false
	
	bDebug = true
	
	t.modules.physics = false
	t.modules.thread = false
	t.modules.touch = false
	t.modules.video = false
end
