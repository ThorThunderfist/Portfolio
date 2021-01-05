--[[
	Project: RoguelikeProto
	File: lich.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 6/7/2016
	
	Comments:
		Script file for the powerful Lich character (unlocked after defeating the (Elf) Archmage).
			- Spellcaster
			- Passive: Chilling Death Aura (move speed debuff)
			- Attack: Mystic Bolt
			- Ability 1: Arc Lightning
			- Ability 2: 
--]]

local Lich = Class
{
	-- Lich inherits from PlayerChar
	__includes = PlayerChar,

	name = "Lich",
	passiveDesc = "Lich passive...",
	
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

	function Lich:Update( dt )
		PlayerChar.Update( self, dt )
	end

return Lich