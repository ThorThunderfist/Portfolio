--[[
	Project: RoguelikeProto
	File: watcher.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 6/7/2016
	
	Comments:
		Script file for the mysterious, super secret Watcher character (unlocked after ???).
			- 
			- 
			- Passive: 
			- Attack: 
			- Ability 1: 
			- Ability 2: 
			- Ability 3: 
--]]

local Watcher = Class
{
	-- Watcher inherits from PlayerChar
	__includes = PlayerChar,

	name = "Watcher",
	passiveDesc = "Watcher passive...",
	
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

	function Watcher:Update( dt )
		PlayerChar.Update( self, dt )
	end

return Watcher