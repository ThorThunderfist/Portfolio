--[[
	Project: RoguelikeProto
	File: fireseeds.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 6/9/2016
	
	Comments:
		Script file for the Fire Seeds item.  When the user is hit, there is a
		chance the seeds will launch out at the attacker.
--]]

FireSeeds = Class
{
	__includes = Item,

	name = "Fire Seeds",
	
	curCooldown = 0,
	cooldown = 15,
	
	init = function( self, owner )
		Item.init( self, owner )
	end
}

	function FireSeeds:OnTakeDamage( amount, attacker )
		if ((math.random( 5 ) < 2 ) and self:Use())
		then
			local seed
		
			for i = -1, 1
			do
				seed = FireSeeds.FireSeed( self, attacker )
				seed.velocity = Vector( 0, -512 ):rotated( math.rad( i * 30 ) )
			end
		end
	end

	
	FireSeeds.FireSeed = Class
	{
		__includes = Projectile,
		
		name = "Fire Seed",
		
		width = 16,
		height = 16,
		
		spritesheet = Game.Images.proj.missile,
		fireFrames = 2,
		idleFrames = 2,
		hitFrames = 2,
		
		init = function( self, source, target )
			Projectile.init( self, source )
			
			local position = source.owner:GetPosition()
			
			self.target = target
			self.position = Vector( position.x, position.y - source.owner.height )
			
			self.flags:Set( 'ethereal', self, true )
		end
	}

		function FireSeeds.FireSeed:Update( dt )
			Projectile.Update( self, dt )
			
			if (not self.target or self.target.bDead)
			then
				local dist = 0
				local closestDist = math.huge
				local closest = nil
				
				for _, e in ipairs( Enemy )
				do
					dist = self:GetPosition():dist( e:GetPosition() )
					
					if (dist < closestDist)
					then
						closestDist = dist
						closest = e
					end
				end
				
				self.target = closest
			end
		end

		function FireSeeds.FireSeed:OnHit( target )
			target:Damage( 3, 0.5, self.source )
		end