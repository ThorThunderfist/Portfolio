--[[
	Project: Dimensional Platformer
	File: main.lua
	Author: David "Thor Thunderfist" Hack
--]]

require "src/utils/utils"
require "src/utils/require"

Camera		= require "src/utils/hump/camera"
Class		= require "src/utils/hump/class"
Gamestate	= require "src/utils/hump/gamestate"
Timer		= require "src/utils/hump/timer"
Vector		= require "src/utils/hump/vector"
VectorLight	= require "src/utils/hump/vector-light"

Bump	= require "src/utils/bump"
Anim8	= require "src/utils/anim8"

IMG		= love.image
GFX		= love.graphics
SFX		= love.audio
FileIO	= love.filesystem

Mouse		= love.mouse
Keyboard	= love.keyboard
Joystick	= love.joystick

require "src/inputmanager"

require "src/callbacks"

require "src/playerchar"
require "src/enemy"

require "src/interactable"

require "src/room"

require "src/game"


-- Initialize the rng with current time as the seed
math.randomseed( os.time() )

math.random() math.random() math.random()

function love.load(arg)
	Gamestate.registerEvents()
	Gamestate.switch( Game )
end