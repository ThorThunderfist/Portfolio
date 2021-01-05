--[[
	Project: RoguelikeProto
	File: minotaur.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 11/5/2016
	
	Comments:
		Script file for the ferocious Minotaur Berserker character (unlocked after defeating the (Dwarf) xxx).
			- Tanky DPS
			- Passive: Berserker Frenzy (basic attacks increased move and attack speed)
			- Attack: Dual axes
			- Ability 1: Bull Rush (charge forward, knocking back and damaging enemies)
			- Ability 2: Carnage (nearby enemies bleed)
--]]

local Minotaur = Class
{
	-- Minotaur inherits from PlayerChar
	__includes = PlayerChar,

	name = "Minotaur Berserker",
	passiveDesc = "Every hit the Minotaur lands increases his battle fury, increasing his movement speed and attack rate.",
	
	width = 48,
	height = 48,
	radius = 24,
	
	mass = 256,
	moveSpeed = 256,
	
	init = function( self, position )
		self.animData = 
		{
			idle =
			{
				spritesheet = Game.Images.player.walk,
				frames = 1,
				durations = math.huge
			},
			walk =
			{
				spritesheet = Game.Images.player.walk,
				frames = 8,
				durations = 0.10
			},
			dodge =
			{
				spritesheet = Game.Images.player.dodge,
				frames = 8,
				durations = { [1] = 0.025, ['2-7'] = 0.05, [8] = 0.025 }
			},
			--[[
			Attack =
			{
				spritesheet = Game.Images.player.minotaur.idle,
				--w = self.width * 2,
				frames = 1,
				durations = 0.05,
				--onLoop = function() self.abilities.attack.bFrenzyTriggered = false end
			},

			BullRush =
			{
				spritesheet = Game.Images.player.minotaur.walk,
				frames = 1,
				durations = 0.5
			},
			
			Carnage =
			{
				spritesheet = Game.Images.player.minotaur.idle,
				--w = self.width * 3,
				frames = 1,
				durations = 0.05,
				--offset = Vector( 3 * self.width / 2, self.height / 2 )
			}
			--]]
		}
		
		self.outlineColor = { 5, 255, 5, 255 }
		
		PlayerChar.init( self, position )
		
		self.skills =
		{
			{ name = "Axe",				rank = 1,	mastery = 1 },
			{ name = "Armsmaster",		rank = 1,	mastery = 1 },
			{ name = "Body Building",	rank = 1,	mastery = 1 }
		}
		
		self.color = { 255, 128, 0, 255 }
	end
}
	
	Minotaur.BasicAttack = Class
	{
		__includes = Ability.Launcher,
		
		name = "Minotaur Basic Attack",
		
		cooldown = .5,
		damage = 5,
		knockback = 128,
		
		cooldownMod = 'attackSpeed',
		
		init = function( self, owner )
			Ability.Launcher.init( self, owner )
			
			self.projectile = Minotaur.Axe
		end
	}
	
		function Minotaur.BasicAttack:Affect( target, aim )
			local dmg = ((self.owner.skills[1].rank + self.owner.mods:ValueAdd( 'attackDamageBase' )) * self.owner.mods:ValueMult( 'attackDamage' )) + self.owner.mods:ValueAdd( 'attackDamage' )
			
			if math.random( 1, 50 ) < self.owner.skills[1].rank
			then
				dmg = dmg * self.owner.skills[1].mastery
			end
			
			if target:Damage( dmg, 0.1, self )
			then
				target:ApplyForce( self.knockback, aim, 0.1, self )
				
				self.owner:ApplyEffect( Minotaur.Frenzy, self, 3 )
			end
		end
	
	Minotaur.Ability1 = Class
	{
		__includes = Ability.Melee,
		
		name = "Bull Rush",
		
		animation = "BullRush",
		
		duration = 0.5,
		cooldown = 4,
		damage = 4,
		knockback = 512,
		
		init = function( self, owner )
			Ability.Melee.init( self, owner )
			
			self.collider = HC.circle( 0, 0, owner.radius + 3 )
			self.collider.ability = self
		end
	}
		
		function Minotaur.Ability1:Affect( target )
			if target:Damage( ((self.damage + self.owner.mods:ValueAdd( 'abilityDamageBase' )) * self.owner.mods:ValueMult( 'abilityDamage' )) + self.owner.mods:ValueAdd( 'abilityDamage' ), self.duration, self )
			then
				target:ApplyForce( self.knockback, (target:GetPosition() - self.owner:GetPosition()):angleTo(), 0.2, self.owner )
			end
		end
	
		function Minotaur.Ability1:Use()
			if Ability.Melee.Use( self )
			then
				self.owner:ApplyEffect( Effect.Dodging, self.owner, self.duration, 0, 0 )
				--self.owner:ApplyEffect( Effect.Immovable, self.owner, self.duration ) --set mass = math.huge
				self.owner.currentAnimation = "dodge"
				self.owner.velocity = self.owner.aimVect:normalized() * self.owner:GetMoveSpeed() * 3
			end
		end
	
	Minotaur.Ability2 = Class
	{
		__includes = Ability.Melee,
		
		name = "Carnage",
		
		--animation = "Carnage",
		
		cooldown = 5,
		duration = 0.5,
		damage = 1,
		knockback = 256,
		
		init = function( self, owner )
			Ability.Melee.init( self, owner )

			self.collider = HC.circle( 0, 0, owner.radius * 3 )
			self.collider.ability = self
		end
	}
		
		function Minotaur.Ability2:Affect( target )
			if target:Damage( ((self.damage + self.owner.mods:ValueAdd( 'abilityDamageBase' )) * self.owner.mods:ValueMult( 'abilityDamage' )) + self.owner.mods:ValueAdd( 'abilityDamage' ), self.duration, self )
			then
				target:ApplyForce( self.knockback, (target:GetPosition() - self.owner:GetPosition()):angleTo(), 0.2, self )
				target:ApplyEffect( Effect.Bleeding, self, 5, self.owner.skills[1].mastery * 2 )
				target:ApplyEffect( Effect.Slowed, self, 5 )
			end
		end
	
	Minotaur.Axe = Class
	{
		__includes = Projectile,
		
		name = "Axe",
		
		width = 16,
		height = 16,
		radius = 8,
		range = 1024,
		
		axeSpeed = 768,
		
		spritesheet = Game.Images.proj.axe,
		idleFrames = 1,
		hitFrames = 1,

		init = function( self, source )
			local position = source.owner:GetPosition()
			local aim = source.owner:GetAim():normalized()
			local velocity = aim * self.axeSpeed
			
			position = position + (aim * source.owner.radius)
			
			Projectile.init( self, source, position, velocity )
		end
	}
		
		function Minotaur.Axe:OnHit( target )
			self.source:Affect( target, self.velocity:angleTo() )
		end
		
		function Minotaur.Axe:Update( dt )
			Projectile.Update( self, dt )
			
			self.rotation = self.rotation + dt * 10
		end
		
	Minotaur.Frenzy = Class
	{
		__includes = Effect,
		
		name = "Berserker Frenzy",
		
		init = function( self, appliedTo, appliedBy, duration )
			Effect.init( self, appliedTo, appliedBy, duration )
			
			self.appliedTo.mods:SetMult( 'moveSpeed', self, 1.1 ^ self.stacks )
			self.appliedTo.mods:SetMult( 'attackSpeed', self, 1.1 ^ self.stacks )
		end
	}
		
		function Minotaur.Frenzy:Expire()
			Effect.Expire()
			
			self.stacks = 0
			
			self.appliedTo.mods:ClearMult( 'moveSpeed', self )
			self.appliedTo.mods:ClearMult( 'attackSpeed', self )
		end
		
		function Minotaur.Frenzy:Stack( appliedBy, duration )
			self:DefaultStack( appliedBy, duration )
			
			self.stacks = math.min( self.stacks, 5 )
			
			self.appliedTo.mods:SetMult( 'moveSpeed', self, 1.1 ^ self.stacks )
			self.appliedTo.mods:SetMult( 'attackSpeed', self, 1.1 ^ self.stacks )
		end
	
	
	function Minotaur:OnAnimLoop( animName ) end
	
	function Minotaur:OnSkillMasteryUp( skill )
		if skill.name == "Axe"
		then
			
		elseif skill.name == "Armsmaster"
		then
			self.mods:SetMult( 'attackSpeed', skill, 1 + (skill.mastery / 10) + (skill.rank / 50) )
			self.mods:SetMult( 'cooldown', skill, 1 + (skill.mastery / 10) + (skill.rank / 50) )
		elseif skill.name == "Body Building"
		then
			self.mods:SetMult( 'hp', skill, skill.mastery )
			self.curHP = self:GetMaxHP()
		end
	end
	
	function Minotaur:OnSkillRankUp( skill )
		if skill.name == "Axe"
		then
			
		elseif skill.name == "Armsmaster"
		then
			self.mods:SetMult( 'attackSpeed', skill, 1 + (skill.mastery / 10) + (skill.rank / 50) )
			self.mods:SetMult( 'cooldown', skill, 1 + (skill.mastery / 10) + (skill.rank / 50) )
		elseif skill.name == "Body Building"
		then
			self.mods:SetAdd( 'hpBase', skill, skill.rank )
			self.curHP = self.curHP + skill.mastery
		end
	end
	
	
return Minotaur