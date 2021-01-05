--[[
	Project: RoguelikeProto
	File: keep.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 7/21/2016
	
	Comments:
		Script file for the Knight's Keep (Lord Knight)
--]]

local Keep = Class
{
	-- Keep inherits from Level
	__includes = Level,
	
	imgDir = Game.Images.level.keep,
	
	name = "Fortified Keep",
	
	init = function( self )
		Level.init( self )
		
		self.bgColor		= { 0,0,0 }
		
		self.typeNames		= { "Plains", "Fields" }
		self.prefixes		= { "Haunting", "Haunted", "Desolate", "Gloomy", "Bright", "Ancient" }
		self.suffixes		= { "Joy", "Freedom" }
		
		self.enemyList		= { [255] = "Knight" }
	end
}

return Keep