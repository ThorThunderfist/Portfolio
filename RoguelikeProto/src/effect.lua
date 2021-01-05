--[[
	Project: RoguelikeProto
	File: effect.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 11/3/2016
	
	Comments:
		Base script file for all effects. Basic effects are defined within this
		file, whereas more specific effects are defined in the appropriate
		character or item files.
--]]

Effect = Class
{
	name = "EFFECT",
	
	baseDuration = 0,
	curTime = 0,
	tickCounter = 0,
	
	stacks = 1,
	
	appliedTo = nil,
	appliedBy = nil,
	
	init = function( self, appliedTo, appliedBy, duration )
		self.appliedTo = appliedTo
		self.appliedBy = appliedBy
		
		self.baseDuration = duration
		self.curTime = duration
	end
}

	Effect:include( Callbacks )

	function Effect:DefaultStack( appliedBy, duration )
		if duration > self.curTime
		then
			self.appliedBy = appliedBy
			self.curTime = duration
			self.baseDuration = duration
			
			Effect.Stack( self, appliedBy, duration )
		end
	end
	
	function Effect:Expire()
		curTime = 0
	end
	
	function Effect:Refresh()
		self.curTime = self.baseDuration
	end
	
	function Effect:Stack( appliedBy, duration )
		self.stacks = self.stacks + 1
	end
	
	function Effect:Tick() end
	
	function Effect:Update( dt )
		self.curTime = self.curTime - dt
		
		if self.curTime < 0
		then
			dt = dt + self.curTime
		end
		
		self.tickCounter = self.tickCounter + dt
		
		while (self.tickCounter >= 0.25)
		do
			self:Tick()
			self.tickCounter = self.tickCounter - 0.25
		end
	end
	
	function Effect:Draw() end
	
	
	
	Effect.AbilityLocked = Class
	{
		__includes = Effect,
		
		name = "Ability Locked",
		
		Stack = Effect.DefaultStack,
		
		init = function( self, appliedTo, appliedBy, duration )
			Effect.init( self, appliedTo, appliedBy, duration )
			
			self.appliedTo.flags:Set( 'abilityLocked', self, true )
		end
	}
	
		function Effect.AbilityLocked:Expire()
			Effect.Expire( self )
			
			self.appliedTo.flags:Clear( 'abilityLocked', self )
		end
	
	
	Effect.ControlLocked = Class
	{
		__includes = Effect,
		
		name = "Control Locked",
		
		Stack = Effect.DefaultStack,
		
		init = function( self, appliedTo, appliedBy, duration )
			Effect.init( self, appliedTo, appliedBy, duration )
			
			self.appliedTo.flags:Set( 'controlLocked', self, true )
		end
	}
		
		function Effect.ControlLocked:Expire()
			Effect.Expire( self )
			
			self.appliedTo.flags:Clear( 'controlLocked', self )
		end
		
		
		Effect.AnimLocked = Class
		{
			__includes = Effect.ControlLocked,
			
			name = "Animation Locked",
			
			init = function( self, appliedTo, appliedBy, duration )
				Effect.ControlLocked.init( self, appliedTo, appliedBy, duration )
				
				self.appliedTo.flags:Set( 'animLocked', self, true )
			end
		}
			
			function Effect.AnimLocked:Expire()
				Effect.ControlLocked.Expire( self )
				
				self.appliedTo.flags:Clear( 'animLocked', self )
			end
		
		
		Effect.Dodging = Class
		{
			__includes = Effect.AnimLocked,
			
			name = "Dodging",
			
			invulnEase = 0,
			
			init = function( self, appliedTo, appliedBy, duration, invulnEase, cooldown )
				Effect.AnimLocked.init( self, appliedTo, appliedBy, duration )
				
				self.invulnEase = invulnEase or (duration / 10)
				self.cooldown = cooldown or 0.5
				
				self.appliedTo.flags:Set( 'dodging', self, true )
			end
		}
			
			function Effect.Dodging:Expire()
				Effect.AnimLocked.Expire( self )
				
				self.appliedTo.flags:Clear( 'dodging', self )
				
				if self.cooldown > 0
				then
					self.appliedTo:ApplyEffect( Effect.DodgeCooldown, self, self.cooldown )
				end
			end
			
			function Effect.Dodging:Update( dt )
				Effect.AnimLocked.Update( self, dt )
				
				if self.baseDuration - self.curTime >= self.invulnEase and self.curTime > self.invulnEase and not self.appliedTo.flags:Get( 'invulnerable', self )
				then
					self.appliedTo.flags:Set( 'invulnerable', self, true )
				elseif self.curTime <= self.invulnEase
				then
					self.appliedTo.flags:Clear( 'invulnerable', self )
				end
				
				self.appliedTo.flags:Clear( 'dodging', self )
			end
	
	
	Effect.DodgeCooldown = Class
	{
		__includes = Effect,
		
		name = "Dodge Cooldown",
		
		Stack = Effect.DefaultStack,
		
		init = function( self, appliedTo, appliedBy, duration )
			Effect.init( self, appliedTo, appliedBy, duration )
			
			self.appliedTo.flags:Set( 'dodgeCooldown', self, true )
		end
	}
		
		function Effect.DodgeCooldown:Expire()
			Effect.Expire( self )
			
			self.appliedTo.flags:Clear( 'dodgeCooldown', self )
		end
	
	
	Effect.Invulnerable = Class
	{
		__includes = Effect,
		
		name = "Invulnerable",
		
		Stack = Effect.DefaultStack,
		
		init = function( self, appliedTo, appliedBy, duration )
			Effect.init( self, appliedTo, appliedBy, duration )
			
			self.appliedTo.flags:Set( 'invulnerable', self, true )
		end
	}
	
		function Effect.Invulnerable:Expire()
			Effect.Expire( self )
			
			self.appliedTo.flags:Clear( 'invulnerable', self )
		end
	
	
	Effect.DamageOverTime = Class
	{
		__includes = Effect,
		
		name = "Damage Over Time",
		
		dps = 0,
		dpt = 0,
		
		init = function( self, appliedTo, appliedBy, duration, dps )
			Effect.init( self, appliedTo, appliedBy, duration )
			
			self.dps = dps
			self.dpt = dps / 4
		end
	}
	
		function Effect.DamageOverTime:Stack( appliedBy, duration, dps )
			if (dps * duration) > (self.dps * self.duration)
			then
				self.dps = dps
				self.dpt = dps / 4
				self.appliedBy = appliedBy
				self.curTime = duration
				self.baseDuration = duration
			end
		end
		
		function Effect.DamageOverTime:Tick()
			Effect.Tick( self )
			
			if not self.appliedTo.flags:Test( 'invulnerable' )
			then
				self.appliedTo:DirectDamage( self.dpt, self.appliedBy )
			end
		end
		
		
		Effect.Bleeding = Class
		{
			__includes = Effect.DamageOverTime,
			
			name = "Bleeding",
			
			particles = nil,
			
			init = function( self, appliedTo, appliedBy, duration, dps )
				Effect.DamageOverTime.init( self, appliedTo, appliedBy, duration, dps )
				
				local blood = love.image.newImageData( 2, 2 )
				
				for i = 0, 1
				do
					for j = 0, 1
					do
						blood:setPixel( i, j, 255, 0, 0, 255 )
					end
				end
				
				local bloodPart = GFX.newImage( blood )
				
				local buffer = (appliedTo.width * appliedTo.height) / 16
				
				self.particles = GFX.newParticleSystem( bloodPart, buffer )
				
				self.particles:setAreaSpread( "uniform", self.appliedTo.width / 2, self.appliedTo.height / 2 )
				self.particles:setDirection( math.rad( -90 ) )
				self.particles:setEmissionRate( 16 )
				self.particles:setEmitterLifetime( duration )
				self.particles:setLinearAcceleration( 0, 0 )
				self.particles:setParticleLifetime( 2, 4 )
				self.particles:setRadialAcceleration( 0 )
				self.particles:setRotation( math.rad( -180 ), math.rad( 180 ) )
				self.particles:setSizeVariation( 0 )
				self.particles:setSizes( 1 )
				self.particles:setSpeed( 128, 256 )
				self.particles:setSpin( -1, 1 )
				self.particles:setSpinVariation( 0 )
				self.particles:setSpread( math.rad( 30 ) )
				self.particles:setTangentialAcceleration( -50, 50 )
				self.particles:setTexture( bloodPart )
				
				self.particles:start()
				self.particles:emit( 4 )
			end
		}

			function Effect.Bleeding:Update( dt )
				Effect.DamageOverTime.Update( self, dt )
				
				self.particles:update( dt )
			end
		
			function Effect.Bleeding:Draw()
				local position = self.appliedTo:GetPosition()
				GFX.draw( self.particles, position.x, position.y )
			end
	
	
	-- Slow can be used as a basic effect or can be inherited from to produce separate, stackable
	-- effects with varying intensities
	Effect.Slowed = Class
	{
		__includes = Effect,
		
		name = "Slowed",
		
		Stack = Effect.DefaultStack,
		
		power = 0.5,
		
		init = function( self, appliedTo, appliedBy, duration )
			Effect.init( self, appliedTo, appliedBy, duration )
			
			self.appliedTo.mods:SetMult( 'moveSpeed', self, self.power )
		end
	}
	
		function Effect.Slowed:Expire()
			Effect.Expire( self )
			
			self.appliedTo.mods:ClearMult( 'moveSpeed', self )
		end