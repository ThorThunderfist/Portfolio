--[[
	Project: RoguelikeProto
	File: ally.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 7/29/2016
--]]

Ally = Class
{
	-- Ally inherits from Entity
	__includes = Entity,
	
	name = "",
	
	bAlly = true,
	
	lifetime = math.huge,
	
	init = function( self )
		Entity.init( self )
	end
}

	function Ally:UpdateMovementInput()
		Entity.UpdateMovement( self )
		
		-- TODO: Implement AI
	end
	
	function Ally:Update( dt )
		Entity.Update( self, dt )
		
		self.lifetime = self.lifetime - dt
	end
	
	function Ally:Draw()
		Entity.Draw( self )
	end