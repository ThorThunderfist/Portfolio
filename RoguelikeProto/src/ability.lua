--[[
	Project: RoguelikeProto
	File: ability.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 11/1/2016
	
	Comments:
		Base script file for all abilities. Basic ability types (Attack, Aura,
		Pulse, etc.) are defined at the bottom, but individual abilities are
		defined within the script files for each character, enemy, ally, etc.
--]]

Ability = Class
{
	name = "ABILITY",
	
	animation = nil,
	
	curCooldown = 0,
	cooldown = 0,
	
	cooldownMod = 'cooldown',
	
	curDuration = 0,
	duration = nil,
	
	bActive = false,
	
	init = function( self, owner )
		self.owner = owner
		
		self.colliders = {}
		
		if self.animation and not self.duration
		then
			--self.duration = self.owner.animations[self.animation].totalDuration
		end
	end
}

	-- Pretty much just a virtual function
	function Ability:Affect( target ) end

	-- Returns true only if the ability is actually activated, false otherwise (on cooldown, otherwise disabled, etc.)
	function Ability:Use()
		if not self.owner.flags:Test( 'controlLocked' ) and not self.owner.flags:Test( 'abilityLocked' ) and self.curCooldown <= 0
		then
			-- If there is an associated animation, play it on the ability user
			if self.animation and self.owner.animations[self.animation]
			then
				self.owner.currentAnimation = self.animation
				self.owner:ApplyEffect( Effect.AnimLocked, self.owner, self.owner.animations[self.animation].totalDuration )
			end
			
			if self.duration
			then
				self.bActive = true
				self.curDuration = self.duration
			end
			
			self.curCooldown = self.cooldown
			
			return true
		end
		
		return false
	end

	function Ability:Update( dt )
		if self.bActive
		then
			self.curDuration = self.curDuration - dt
			
			if self.curDuration <= 0
			then
				self.bActive = false
				self.curCooldown = self.cooldown
				self.curDuration = 0
			end
		else
			self.curCooldown = math.max( 0, self.curCooldown - (dt * self.owner.mods:ValueMult( self.cooldownMod )) )
		end
	end
	
	-- Mostly just debug code for drawing hitboxes
	function Ability:Draw()
		if bDebug and self.bActive
		then
			local col = nil

			if self.owner.currentAnimation == self.animation
			then
				col = self.colliders[self.owner.animations[self.animation][self.owner.face].position]
			else
				col = self.collider
			end
			
			if col
			then
				col:draw( "line" )
			end
		end
	end
	
	Ability.Melee = Class
	{
		-- Melee inherits from Ability
		__includes = Ability,
	
		name = "MELEE",
		
		init = function( self, owner )
			Ability.init( self, owner )
		end
	}
		
		--TODO: implement array of colliders based on animation frames
		function Ability.Melee:Update( dt )
			if self.bActive-- and self.owner.currentAnimation == self.animation
			then
				--local col = self.colliders[self.owner.animations[self.animation][self.owner.face].position]:Clone()
				local dx = self.collider.dx or 0
				local dy = self.collider.dy or 0
				local pos = self.owner:GetPosition()
				
				self.collider:moveTo( pos.x + dx, pos.y + dy )

				local collisions = HC.collisions( self.collider )
				
				for other, _ in pairs( collisions )
				do
					if other.entity and other.entity.faction ~= self.owner.faction
					then
						if not other.entity.flags:Test( 'invulnerable' )
						then
							self:Affect( other.entity )
						end
					end
				end
				
				self.curDuration = self.curDuration - dt
				
				if self.curDuration <= 0
				then
					self.bActive = false
					self.curCooldown = self.cooldown
					self.curDuration = 0
				end
			end
		
			self.curCooldown = math.max( 0, self.curCooldown - (dt * self.owner.mods:ValueMult( self.cooldownMod )) )
		end
	
	Ability.Launcher = Class
	{
		__includes = Ability,
		
		name = "LAUNCHER",
		
		projectile = nil,
		
		init = function( self, owner )
			Ability.init( self, owner )
		end
	}
	
		function Ability.Launcher:Use()
			if self.projectile and Ability.Use( self )
			then
				self.projectile( self )
				return true
			end
			
			return false
		end