--[[
	Project: RoguelikeProto
	File: den.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 6/9/2016
	
	Comments:
		Script file for the Den of Thieves (Master Thief/Spy)
--]]

local Den = Class
{
	-- Den inherits from Level
	__includes = Level,

	imgDir = Game.Images.level.den,
	
	name = "Thieves' Den",
	
	init = function( self )
		Level.init( self )
		
		self.bgColor		= { 0,0,0 }
		
		self.typeNames		= { "Mountains", "Cliffs", "Range", "Peaks", "Teeth" }
		self.prefixes		= { "Frigid", "Desolate", "Barren", "Overgrown", "Dreaded", "Bright", "Ancient" }
		self.suffixes		= { "Doom", "Death" }
		
		self.enemyList		= { "Knight" }
	end
}

return Den