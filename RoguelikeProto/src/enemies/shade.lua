--[[
	Project: RoguelikeProto
	File: shade.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 8/2/2016
	
	Comments:
		TODO - CONVERT TO BOSS
	
		Script file for the creepy Shade character.
			- Melee
			- Debuffer
			- Passive: Shadow Curse (dealing damage causes enemies to deal reduced damage)
			- Attack: Touch with hand (sap lifeforce)
			- Ability 1: Shadowstep?/Shadow Pool?
			- Ability 2: Crippling Shriek (nearby enemies slowed and damaged)
			- Ability 3: Shadowsplit (summon shadow ally)
--]]

--[[
local Shade = Class
{
	-- Shade inherits from PlayerChar
	__includes = PlayerChar,

	name = "Shade",
	passiveDesc = "Each time the Shade deals damage, the target's strength is sapped, causing them to deal reduced damage for a few seconds.",
	
	width = 16,
	height = 32,
	spritesheet = Game.Images.player.berserker,
	
	init = function( self )
		self.animData = 
		{
			idle =
			{
				grid = { "1-8", 1 },
				durations = 0.1
			},
			walk =
			{
				grid = { "1-8", 2 },
				durations = 0.05
			}
		}
		
		PlayerChar.init( self )
		
		self.color = { 0, 0, 0, 192 }
	end
}

	function Shade:OnDealDamage( amount, target )
		PlayerChar.OnDealDamage( self, amount, target )
		
		target:ApplyEffect( Shade.ShadowCurse, self, 4 )
	end
	
	Shade.BasicAttack = Class
	{
		__includes = Ability.Melee,
		
		name = "Shade Basic Attack",
		
		animation = "Attack",
		
		cooldown = .5,
		damage = 5,
		
		init = function( self, owner )
			Ability.Melee.init( self, owner )
			
			self.colliders[1] = Rect( 0, -16, 24, 16 )
			self.colliders[2] = Rect( 0, -16, 24, 16 )
			self.colliders[3] = Rect( 0, 0, 24, 16 )
			self.colliders[4] = Rect( 0, 0, 24, 16 )
		end
	}
	
		function Shade.BasicAttack:Affect( target )
			target:Damage( ((self.damage + self.owner.mods:ValueAdd( 'attackDamageBase' )) * self.owner.mods:ValueMult( 'attackDamage' )) + self.owner.mods:ValueAdd( 'attackDamage' ), self.cooldown, self )
		end
	
	Shade.Ability1 = Class
	{
		__includes = Ability,
		
		name = "",
		
		animation = "",
		
		cooldown = 4,
		damage = 4,
		knockback = 512,
		
		init = function( self, owner )
			Ability.init( self, owner )
			
			self.colliders[1] = Rect( -8, -16, 16, 32 )
		end
	}
		
		function Shade.Ability1:Affect( target )
			if target:Damage( ((self.damage + self.owner.mods:ValueAdd( 'abilityDamageBase' )) * self.owner.mods:ValueMult( 'abilityDamage' )) + self.owner.mods:ValueAdd( 'abilityDamage' ), self.cooldown, self )
			then
				target:ApplyForce( self.knockback * self.owner.face, 10 * self.owner.face, 5, 1, self.owner )
			end
		end
	
		function Shade.Ability1:Use()
			if Ability.Use( self )
			then
				self.owner:ApplyEffect( Effect.Invulnerable, self.owner, self.owner.animations[self.animation].totalDuration )
				self.owner.velocity.x = self.owner.face * 768
			end
		end
	
	Shade.Ability2 = Class
	{
		__includes = Ability,
		
		name = "Crippling Shriek",
		
		cooldown = 5,
		damage = 2,
		
		init = function( self, owner )
			Ability.init( self, owner )
			
			self.colliders[0] = Rect( -72, 0, 144, 16 )
		end
	}
	
		function Shade.Ability2:Affect( target )
			if target:Damage( ((self.damage + self.owner.mods:ValueAdd( 'abilityDamageBase' )) * self.owner.mods:ValueMult( 'abilityDamage' )) + self.owner.mods:ValueAdd( 'abilityDamage' ), self.cooldown, self )
			then
				target:ApplyEffect( Effect.ControlLocked, self.owner, 0.5 )
				target:ApplyEffect( Shade.Crippled, self.owner, 5 )
			end
		end
	
	Shade.Ability3 = Class
	{
		__includes = Ability,
		
		name = "Shadowsplit",
		
		animation = "Shadowsplit",
		
		cooldown = 15,
		
		init = function( self, owner )
			Ability.init( self, owner )
		end
	}
	
		function Shade.Ability3:Use()
			if Ability.Use( self )
			then
				-- create shadow clone
			end
		end
	
	
	Shade.ShadowCurse = Class
	{
		__includes = Effect,
		
		name = "Shadow Curse",
		
		init = function( self, appliedTo, appliedBy, duration )
			Effect.init( self, appliedTo, appliedBy, duration )
			
			self.appliedTo.mods:SetAdd( 'attackDamageBase', self, 0.2 )
			self.appliedTo.mods:SetAdd( 'abilityDamageBase', self, 0.2 )
		end
	}
		
		function Shade.ShadowCurse:Stack( appliedBy, duration )
			self:DefaultStack( appliedBy, duration )
			
			self.stacks = math.min( self.stacks, 5 )
		end
	
	Shade.Crippled = Class
	{
		__includes = Effect.Slowed,
		
		name = "Crippled",
		
		power = 0.3
	}

	
return Shade
--]]