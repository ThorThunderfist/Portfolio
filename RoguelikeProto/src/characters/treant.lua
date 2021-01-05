--[[
	Project: RoguelikeProto
	File: treant.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 8/3/2016
	
	Comments:
		Script file for the Treant character.
			- Lumbering, high hp, absurd attack rate
			- Passive: Regeneration
			- Attack: Insect Swarm
			- Ability 1: Root Strike (roots launch nearby enemies into the air, stunning them briefly)
			- Ability 2: Draining Sapling (sapling inflicts AoE debuffs)
--]]

local Treant = Class
{
	-- Treant inherits from PlayerChar
	__includes = PlayerChar,

	name = "Treant",
	passiveDesc = "Treant passive...",
	
	width = 80,
	height = 128,
	spritesheet = Game.Images.player.basicchar,
	
	moveSpeed = 192,

	init = function( self )
		self.animData = 
		{
			idle =
			{
				grid = { "1-4", 1 },
				durations = 0.1
			},
			walk =
			{
				grid = { "5-8", 1 },
				durations = 0.05
			},
			
			Attack =
			{
				w = self.width * 2,
				grid = { "1-4", 3 },
				durations = 0.05
			},

			RootStrike =
			{
				w = self.width * 3,
				grid = { "1-2", "4-5" },
				durations = 0.05,
				offset = Vector( 3 * self.width / 2, self.height / 2 )
			},
			
			DrainingSapling =
			{
				grid = { "7-8", "4-5" },
				durations = 0.05
			}
		}
		
		PlayerChar.init( self )
		
		self.color = { 64, 192, 64, 255 }
	end
}
	
	Treant.BasicAttack = Class
	{
		__includes = Ability.Melee,
		
		name = "Treant Basic Attack",
		
		animation = "Attack",
		
		cooldown = .75,
		damage = 8,
		knockback = 192,
		
		init = function( self, owner )
			Ability.Melee.init( self, owner )
			
			--[[
			self.colliders[1] = Rect( Treant.width, 0, 120, 64 )
			self.colliders[2] = Rect( Treant.width, 0, 120, 64 )
			self.colliders[3] = Rect( Treant.width, Treant.height / 2, 120, 64 )
			self.colliders[4] = Rect( Treant.width, Treant.height / 2, 120, 64 )--]]
		end
	}
	
		function Treant.BasicAttack:Affect( target )
			if target:Damage( ((self.damage + self.owner.mods:ValueAdd( 'attackDamageBase' )) * self.owner.mods:ValueMult( 'attackDamage' )) + self.owner.mods:ValueAdd( 'attackDamage' ), self.cooldown, self )
			then
				target:ApplyForce( self.knockback * self.owner.face, 10 * self.owner.face, 5, 0.1, self.owner )
			end
		end
	
	Treant.Ability1 = Class
	{
		__includes = Ability,
		
		name = "Root Strike",
		
		animation = "RootStrike",
		
		cooldown = 5,
		damage = 3,
		force = 768,
		
		init = function( self, owner )
			Ability.init( self, owner )
			
			--self.colliders[1] = Rect( -360, 0, 720, 64 )
		end
	}
		
		function Treant.Ability1:Affect( target )
			if target:Damage( ((self.damage + self.owner.mods:ValueAdd( 'abilityDamageBase' )) * self.owner.mods:ValueMult( 'abilityDamage' )) + self.owner.mods:ValueAdd( 'abilityDamage' ), self.cooldown, self )
			then
				target:ApplyForce( self.force, -90, 15, 1.5, self.owner )
			end
		end
	
	
	Treant.Ability2 = Class
	{
		__includes = Ability.Launcher,
		
		name = "Draining Sapling",
		
		animation = "DrainingSapling",
		
		cooldown = 3,
		launchFrame = 2,
		
		init = function( self, owner )
			Ability.Launcher.init( self, owner )
		
			self.projectile = Treant.Sapling
		end
	}
	
	Treant.Sapling = Class
	{
		__includes = Projectile,
		
		name = "Sapling",
		
		width = 16,
		height = 16,
		
		saplingSpeed = 256,
		
		spritesheet = Game.Images.proj.missile,
		fireFrames = 2,
		idleFrames = 2,
		hitFrames = 2,

		init = function( self, source )
			Projectile.init( self, source )
			
			local position = source.owner:GetPosition()
			
			-- TODO: Old platformer code should be updated
			self:SetPosition( position.x + (source.owner.width * source.owner.face), position.y )
			self.velocity = Vector( source.owner.face * self.saplingSpeed, 0 )
		end
	}
		
		function Treant.Sapling:OnHit( target )
			if target:Damage( 3, 0.5, self.source )
			then
				target:ApplyForce( 128 * self.face, 10 * self.face, 5, 0.1, self.source.owner )
				target:ApplyEffect( Treant.Leech, self.source.owner, 5, 3 )
			end
		end
	
	
return Treant