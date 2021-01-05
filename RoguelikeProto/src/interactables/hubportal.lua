--[[
	Project: RoguelikeProto
	File: hubportal.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 6/9/2016
	
	Comments:
		Script file for the world-generation/run-starting portals in the hub.
--]]

local HubPortal = Class
{
	-- Knight inherits from Interactable
	__includes = Interactable,
	
	name = "HubPortal",
	
	width = 144,
	height = 144,
	radius = math.sqrt( 2*(72*72) ),
	
	destination = nil,
	
	init = function( self, position, destination )
		self.animData = 
		{
			idle =
			{
				spritesheet = Game.Images.level.hub.sprites.portal,
				frames = 1,
				durations = math.huge
			}
		}
		
		self.label = GFX.newText( Game.Fonts.default, destination.name )
		self.destination = destination
		
		Interactable.init( self, position )
	end
}
	
	function HubPortal:Update( dt )
		Interactable.Update( self, dt )
	end
	
	function HubPortal:Use()
		Interactable.Use( self )
		
		if self.destination
		then
			Game:GenerateWorld( self.destination )
			Game:NextLevel()
		end
	end
	
	function HubPortal:DrawSelf( position, animOffset )
		GFX.setShader( Game.Shaders.rainbow )
		Interactable.DrawSelf( self, position, animOffset )
		GFX.setShader()
	end
	
return HubPortal