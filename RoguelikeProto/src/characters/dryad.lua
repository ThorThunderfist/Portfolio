--[[
	Project: RoguelikeProto
	File: dryad.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 6/7/2016
	
	Comments:
		Script file for the twisted Corrupt Dryad character (unlocked after defeating the (Elf) Grand Archer).
			- Curses/debuffs
			- Passive: 
			- Attack: 
			- Ability 1: 
			- Ability 2: 
--]]

local Dryad = Class
{
	-- Dryad inherits from PlayerChar
	__includes = PlayerChar,

	name = "Corrupt Dryad",
	passiveDesc = "Corrupt Dryad passive...",
	
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

	function Dryad:Update( dt )
		PlayerChar.Update( self, dt )
	end

return Dryad