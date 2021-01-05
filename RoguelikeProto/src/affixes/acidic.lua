--[[
	Project: RoguelikeProto
	File: acidic.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 5/29/2014
--]]

local Acidic = Class
{
	__includes = Affix,
	
	name = "Acidic",
	
	init =  function( self )
		Affix.init( self )
	end
}

	function Acidic:Update( dt ) end

	function Acidic:Draw() end
	
return Acidic