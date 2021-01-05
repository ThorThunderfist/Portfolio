--[[
	Project: RoguelikeProto
	File: harpy.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 6/7/2016
	
	Comments:
		Script file for the Harpy character.
			- Highly mobile, low hp, medium attack rate
			- Passive: Flight
			- Attack: Feather shot/throwing dagger
			- Ability 1: Cursed shot
			- Ability 2: Bolas (root)
--]]

local Harpy = Class
{
	-- Harpy inherits from PlayerChar
	__includes = PlayerChar,

	name = "Harpy",
	passiveDesc = "Harpy passive...",
	
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
		
		self.color = { 0, 128, 0, 255 }
	end
}

	function Harpy:Update( dt )
		PlayerChar.Update( self, dt )
	end

return Harpy