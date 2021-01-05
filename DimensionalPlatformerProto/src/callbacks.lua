--[[
	Project: Dimensional Platformer
	File: callbacks.lua
	Author: David "Thor Thunderfist" Hack
	
	Comments:
		Script file which exists solely to be used as a mixin to add basic,
		virtual callback functions.
--]]

Callbacks = Class{}
--[[
	function Callbacks:OnKill( target )
		return true
	end
	
	function Callbacks:OnDeath( killer )
		return true
--]]