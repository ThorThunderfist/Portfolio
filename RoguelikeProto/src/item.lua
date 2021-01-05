--[[
	Project: RoguelikeProto
	File: item.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 5/9/2014
	
	Comments:
		Base script file for all items. Individual items are defined within
		their own files.
--]]

Item = Class
{
	name = "ITEM",
	
	curCooldown = 0,
	cooldown = 0,
	
	init = function( self, owner )
		self.owner = owner
	end
}

	Item:include( Callbacks )

	function Item:Use()
		if (self.curCooldown <= 0)
		then
			self.curCooldown = self.cooldown
			return true
		else
			return false
		end
	end

	function Item:Update( dt )
		self.curCooldown = math.max( 0, self.curCooldown - dt )
	end
	
	function Item:Draw() end