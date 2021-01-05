--[[
	Project: RoguelikeProto
	File: flags.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 8/2/2016
--]]

Flags = Class{}

	function Flags:Clear( flag, index )
		if self[flag]
		then
			self[flag][index] = nil
		end
	end
	
	function Flags:Get( flag, index )
		if self[flag]
		then
			return self[flag][index]
		end
		
		return false
	end
	
	function Flags:Set( flag, index, value )
		if not self[flag]
		then
			self[flag] = {}
		end
		
		self[flag][index] = value
	end
	
	function Flags:Test( flag )
		if self[flag]
		then
			for _, val in pairs( self[flag] )
			do
				if val
				then
					return true
				end
			end
		end
		
		return false
	end