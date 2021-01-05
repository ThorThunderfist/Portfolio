--[[
	Project: RoguelikeProto
	File: succubus.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 6/7/2016
	
	Comments:
		Script file for the seductive Succubus character (unlocked after defeating the (Human) High Priest).
			- Mobile, very low HP
			- Passive: 
			- Attack: Lifesteal magic
			- Ability 1: 
			- Ability 2: 
--]]

local Succubus = Class
{
	-- Succubus inherits from PlayerChar
	__includes = PlayerChar,

	name = "Succubus",
	passiveDesc = "Succubus passive...",
	
	width = 16,
	height = 32,
	spritesheet = Game.Images.player.stick,
	
	init = function( self )
		self.animData = 
		{
			idle =
			{
				grid = { "1-8", 1 },
				durations = 0.1
			},
			walk =
			{
				grid = { "1-8", 2 },
				durations = 0.05
			}
		}
		
		PlayerChar.init( self )
		
		self.color = { 128, 128, 0, 255 }
	end
}

	function Succubus:Update( dt )
		PlayerChar.Update( self, dt )
	end

return Succubus