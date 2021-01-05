--[[
	Project: RoguelikeProto
	File: modifiers.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 6/9/2016
--]]

Modifiers = Class{}
	
	function Modifiers:ClearAdd( mod, index )
		if self[mod] and self[mod].add
		then
			self[mod].add[index] = nil
		end
	end
	
	function Modifiers:ClearMult( mod, index )
		if self[mod] and self[mod].mult
		then
			self[mod].mult[index] = nil
		end
	end
	
	function Modifiers:GetAdd( mod, index )
		if self[mod] and self[mod].add
		then
			return self[mod].add[index]
		end
	end
	
	function Modifiers:GetMult( mod, index )
		if self[mod] and self[mod].mult
		then
			return self[mod].mult[index]
		end
	end
	
	function Modifiers:SetAdd( mod, index, value )
		if not self[mod]
		then
			self[mod] = { mult = {}, add = {} }
		end
		
		self[mod].add[index] = value
	end
	
	function Modifiers:SetMult( mod, index, value )
		if not self[mod]
		then
			self[mod] = { mult = {}, add = {} }
		end
		
		self[mod].mult[index] = value
	end
	
	function Modifiers:ValueAdd( mod )
		local val = 0
		
		if self[mod] and self[mod].add
		then
			for _, v in pairs( self[mod].add )
			do
				val = val + v
			end
		end
		
		return val
	end
	
	function Modifiers:ValueMult( mod )
		local val = 1
		
		if self[mod] and self[mod].mult
		then
			for _, v in pairs( self[mod].mult )
			do
				val = val * v
			end
		end
		
		return val
	end