--[[
	Project: RoguelikeProto
	File: callbacks.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 11/4/2016
	
	Comments:
		Script file which exists solely to be used as a mixin to add basic,
		virtual callback functions.
--]]

Callbacks = Class{}

	function Callbacks:OnDealDamage( amount, target )
		return true
	end
	
	function Callbacks:OnTakeDamage( amount, attacker )
		return true
	end
	
	function Callbacks:OnKill( target )
		return true
	end
	
	function Callbacks:OnDeath( killer )
		return true
	end