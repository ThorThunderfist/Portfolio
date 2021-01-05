--[[
	Project: RoguelikeProto
	File: main.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 8/3/2016
--]]

require "src/utils/utils"
require "src/utils/require"

Camera		= require "src/utils/hump/camera"
Class		= require "src/utils/hump/class"
Gamestate	= require "src/utils/hump/gamestate"
Timer		= require "src/utils/hump/timer"
Vector		= require "src/utils/hump/vector"
VectorLight	= require "src/utils/hump/vector-light"

HC 		= require "src/utils/hc"
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
require "src/flags"
require "src/modifiers"
require "src/projectile"
require "src/ability"
require "src/affix"
require "src/effect"
require "src/item"

require "src/entity"
require "src/playerchar"
require "src/player"
require "src/ally"
require "src/enemy"

require "src/interactable"

require "src/level"
require "src/room"
require "src/corridor"

require "src/poptext"

require "src/game"


-- Initialize the rng with current time as the seed
math.randomseed( os.time() )

math.random() math.random() math.random()

function love.load()
	Gamestate.registerEvents()
	Gamestate.switch( Game )
end