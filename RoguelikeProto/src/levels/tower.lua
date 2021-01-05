--[[
	Project: RoguelikeProto
	File: tower.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 6/9/2016
	
	Comments:
		Script file for the Mage Tower (Archmage)
--]]

local Tower = Class
{
	-- Tower inherits from Level
	__includes = Level,

	imgDir = Game.Images.level.tower,
	
	name = "Archmage Tower",
	
	init = function( self )
		Level.init( self )
		
		self.bgColor		= { 0,0,0 }
		
		self.typeNames		= { "Forest", "Wood", "Woods", "Woodlands", "Weald", "Holt" }
		self.prefixes		= { "Haunting", "Haunted", "Desolate", "Gloomy", "Overgrown", "Bright", "Ancient" }
		self.suffixes		= { "Dread", "Dreams" }
		
		self.enemyList		= { "Knight" }
	end
}

return Tower