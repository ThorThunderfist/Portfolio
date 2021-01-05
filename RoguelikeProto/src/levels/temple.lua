--[[
	Project: RoguelikeProto
	File: temple.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 6/9/2016
	
	Comments:
		Script file for the High Temple (High Priest)
--]]

local Temple = Class
{
	-- Temple inherits from Level
	__includes = Level,

	imgDir = Game.Images.level.temple,
	
	name = "High Temple",
	
	init = function( self )
		Level.init( self )
		
		self.bgColor		= { 0,0,0 }
		
		self.typeNames		= { "Desert", "Wasteland", "Wastes" }
		self.prefixes		= { "Haunting", "Haunted", "Desolate", "Gloomy", "Bright", "Ancient" }
		self.suffixes		= { "Dread", "Dreams" }
		
		self.enemyList		= { "Knight" }
	end
}

return Temple