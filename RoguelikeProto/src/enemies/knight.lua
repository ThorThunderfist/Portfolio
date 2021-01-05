--[[
	Project: RoguelikeProto
	File: knight.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 10/28/2016
	
	Comments:
		Script file for knight enemy type.
--]]

local Knight = Class
{
	-- Knight inherits from Enemy
	__includes = Enemy,

	name = "Knight",
	
	maxHP = 30,
	
	xpValue = 1,
	
	width = 48,
	height = 48,
	radius = 24,
	
	mass = 16,
	moveSpeed = 128,
	
	init = function( self, position )
		self.animData = 
		{
			idle =
			{
				spritesheet = Game.Images.enemy.walk,
				frames = 1,
				durations = math.huge
			},
			walk =
			{
				spritesheet = Game.Images.enemy.walk,
				frames = 8,
				durations = 0.10
			},
			--[[
			Attack =
			{
				spritesheet = Game.Images.enemy.knight.idle,
				--w = self.width * 2,
				frames = 8,
				durations = 0.05
			}--]]
		}
		
		Enemy.init( self, position )
		
		self.color = { 255, 0, 0, 255 }
	end
}

	function Knight:Update( dt )
		Enemy.Update( self, dt )
		
		if self.targetPlayer
		then
			local pos = self:GetPosition()
			local targetPos = self.targetPlayer:GetPosition()
			
			-- TODO: Update to use HC collider detection
			local dx = math.abs( targetPos.x - pos.x )
			local dy = math.abs( targetPos.y - pos.y )
			
			if self.abilities.attack
			then
				self.abilities.attack:Use()
			end
		end
	end

	Knight.BasicAttack = Class
	{
		__includes = Ability.Launcher,
		
		name = "Knight Basic Attack",
		
		cooldown = 7,
		damage = 1,
		
		bFrenzyTriggered = false,
		
		init = function( self, owner )
			Ability.Launcher.init( self, owner )
			
			self.projectile = Knight.Sword
		end
	}
	
		function Knight.BasicAttack:Affect( target )
			target:Damage( ((self.damage + self.owner.mods:ValueAdd( 'attackDamageBase' )) * self.owner.mods:ValueMult( 'attackDamage' )) + self.owner.mods:ValueAdd( 'attackDamage' ), self.cooldown, self )
		end
	
	Knight.Sword = Class
	{
		__includes = Projectile,
		
		name = "Sword",
		
		width = 16,
		height = 16,
		radius = 8,
		range = 1024,
		
		swordSpeed = 768,
		
		spritesheet = Game.Images.proj.sword,
		idleFrames = 1,
		hitFrames = 1,

		init = function( self, source )
			local position = source.owner:GetPosition()
			local aim = source.owner:GetAim():normalized()
			local velocity = aim * self.swordSpeed
			
			position = position + (aim * source.owner.radius)
			
			Projectile.init( self, source, position, velocity )
		end
	}
		
		function Knight.Sword:OnHit( target )
			self.source:Affect( target )
		end
		
		function Knight.Sword:Update( dt )
			Projectile.Update( self, dt )
			
			self.rotation = self.rotation + dt * 10
		end

return Knight