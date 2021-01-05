--[[
	Project: RoguelikeProto
	File: wolf.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 6/7/2016
	
	Comments:
		Script file for the dryad's wolf summon.
--]]

Wolf = Class
{
	-- Wolf inherits from Ally
	__includes = Ally,

	name = "Wolf",
	
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
		
		Ally.init( self )
		
		self.color = { 128, 128, 128, 255 }
	end
}

	function Wolf:Update( dt )
		Ally.Update( self, dt )
	end

return Wolf