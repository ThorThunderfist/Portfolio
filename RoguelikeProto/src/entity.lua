--[[
	Project: RoguelikeProto
	File: entity.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 11/3/2016
--]]

Entity = Class
{
	name = "",
	
	mass = 64,
	friction = 512,
	moveSpeed = 128,
	radius = 7,
	face = 1,
	
	curHP = 10,
	maxHP = 10,
	
	faction = nil,
	
	outlineColor = { 255, 255, 255, 255 },
	
	bDead = false,
	
	spritesheet = nil,
	animData = nil,
	currentAnimation = "idle",
	
	init = function( self, position )
		position = position or Vector( 0, 0 )
		
		self.collider = HC.circle( position.x, position.y, self.radius )
		self.collider.entity = self
		
		self.outline = GFX.newShader( "src/shader/outline.glsl" )
		self.outline:send( "stepSize", {
			1 / self.animData[self.currentAnimation].spritesheet:getWidth(),
			1 / self.animData[self.currentAnimation].spritesheet:getHeight()
		} )
		self.outline:sendColor( "color", self.outlineColor )
		
		self.sounds			= {}
		self.animations		= {}
		self.color			= { 255, 255, 255, 255 }
		self.velocity		= Vector( 0, 0 )
		self.acceleration	= Vector( 0, 0 )
		self.moveVect		= Vector( 0, 0 )
		self.aimVect		= Vector( 0, 0 )
		
		self.abilities		= {}
		self.affixes		= {}
		self.damageSources	= {}
		self.effects		= {}
		self.items			= {}
		self.projectiles	= {}

		self.allies			= {}
		
		self.flags = Flags()
		self.mods = Modifiers()
		
		self.mods:SetAdd( 'hpBase', self, self.maxHP )
		self.mods:SetAdd( 'moveSpeedBase', self, self.moveSpeed )
		
		if self.animData then self:InitAnims() end
		
		self:InitAbilities()
		
		self.curHP = self:GetMaxHP()
	end
}

	Entity:include( Callbacks )

	function Entity:InitAbilities()
		if self.BasicAttack
		then
			self.abilities.attack = self.BasicAttack( self )
		end
		
		if self.Ability1
		then
			self.abilities[1] = self.Ability1( self )
		end
		
		if self.Ability2
		then
			self.abilities[2] = self.Ability2( self )
		end
	end
	
	function Entity:InitAnims()
		local wSheet, hSheet, w, h, g, dir
		
		for name, data in pairs( self.animData )
		do
			wSheet = data.spritesheet:getWidth()
			hSheet = data.spritesheet:getHeight()
			
			self.animations[name] = {}
			
			for angle=1,6
			do
				dir = data[angle]
				
				if dir
				then
					w = dir.w or self.width
					h = dir.h or self.height
				else
					w = data.w or self.width
					h = data.h or self.height
				end
				
				g = Anim8.newGrid( w, h, wSheet, hSheet, 0, 0, 1 )
				
				self.animations[name][angle] = Anim8.newAnimation( g( "1-" .. data.frames, angle ), data.durations, function() self:OnAnimLoop( name ) end )
				
				if dir and dir.offset
				then
					self.animations[name][angle].animOffset = dir.offset
				end
			end
			
			self.animations[name].totalDuration = self.animations[name][1].totalDuration
		end
	end
	
	function Entity:UpdateAbilities( dt )
		for _, ability in pairs( self.abilities )
		do
			ability:Update( dt )
		end
	end
	
	function Entity:UpdateAffixes( dt )
		for _, affix in pairs( self.affixes )
		do
			affix:Update( dt )
		end
	end
	
	function Entity:UpdateAllies( dt )
		local ally
		
		for idx = #self.allies, 1, -1
		do
			ally = self.allies[idx]
			
			ally:Update( dt )
			
			if ally.bDead or (ally.lifetime <= 0)
			then
				HC.remove( ally.collider )
				table.remove( self.allies, idx )
			end
		end
	end
	
	function Entity:ApplyEffect( effectType, source, duration, ... )
		if self.effects[effectType]
		then
			self.effects[effectType]:Stack( source, duration, ... )
		else
			self.effects[effectType] = effectType( self, source, duration, ... )
		end
	end
	
	function Entity:UpdateEffects( dt )
		local expired = {}
		
		for idx, effect in pairs( self.effects )
		do
			effect:Update( dt )
			
			if effect.curTime <= 0
			then
				expired[effect] = idx
			end
		end
		
		for _, idx in pairs( expired )
		do
			self.effects[idx]:Expire()
			self.effects[idx] = nil
		end
	end
	
	function Entity:UpdateItems( dt )
		for _, item in pairs( self.items )
		do
			item:Update( dt )
		end
	end
	
	function Entity:DirectDamage( amount, source )
		self.curHP = self.curHP - amount
		
		if (self.curHP <= 0) and not self.bDead
		then
			self:Die( source.owner or source )
		end
	end
	
	function Entity:Dodge()
		if self.moveVect ~= Vector.zero
		then
			if not self.flags:Test( 'dodgeCooldown' ) and not self.flags:Test( 'controlLocked' )
			then
				self:ApplyEffect( Effect.Dodging, self, 0.35, 0.025, 0.7 )
				
				self.currentAnimation = "dodge"
				self.velocity = self.moveVect:normalized() * self:GetMoveSpeed() * 3
			end
		end
	end
	
	function Entity:Damage( amount, dmgSleep, source )
		if self.flags:Test( 'invulnerable' )
		then
			return
		end
		
		local attacker
		
		if source
		then
			if self.damageSources[source]
			then
				return
			end
			
			self.damageSources[source] = dmgSleep
			attacker = source.owner or source
		end
		
		if not self:OnTakeDamage( amount, attacker )
		then
			return false
		end
		
		local realDmg = amount * ((1 + self.mods:ValueAdd( 'armor' )) * self.mods:ValueMult( 'armor' ))
		
		self.curHP = self.curHP - realDmg
		
		if self.faction == "player"
		then
			local position = self:GetPosition()
		
			Game:PopText( string.format( "%d", realDmg ), position, Game.Colors.PlayerDamageText )
		elseif self.faction == "enemy"
		then
			local position = self:GetPosition()
		
			Game:PopText( string.format( "%d", realDmg ), position, Game.Colors.EnemyDamageText )
		end
		
		if attacker
		then
			attacker:OnDealDamage( realDmg, self )
		end
		
		if (self.curHP <= 0) and not self.bDead
		then
			self:Die( attacker )
		end
		
		return true
	end
	
	function Entity:GetMaxHP()
		return (self.mods:ValueAdd( 'hpBase' ) * self.mods:ValueMult( 'hp' )) + self.mods:ValueAdd( 'hp' )
	end
	
	function Entity:GetMoveSpeed()
		return (self.mods:ValueAdd( 'moveSpeedBase' ) * self.mods:ValueMult( 'moveSpeed' )) + self.mods:ValueAdd( 'moveSpeed' )
	end
	
	function Entity:OnAnimLoop( animName ) end
	
	function Entity:OnDealDamage( amount, target )
		for _, effect in pairs( self.effects )
		do
			effect:OnDealDamage( amount, target )
		end
		
		for _, item in pairs( self.items )
		do
			item:OnDealDamage( amount, target )
		end
	end
	
	function Entity:OnTakeDamage( amount, attacker )
		for _, effect in pairs( self.effects )
		do
			if not effect:OnTakeDamage( amount, attacker )
			then
				return false
			end
		end
		
		for _, item in pairs( self.items )
		do
			if not item:OnTakeDamage( amount, attacker )
			then
				return false
			end
		end
		
		return true
	end
	
	function Entity:OnKill( target )
		for _, effect in pairs( self.effects )
		do
			effect:OnKill( target )
		end
		
		for _, item in pairs( self.items )
		do
			item:OnKill( target )
		end
	end
	
	function Entity:OnDeath( killer )
		for _, effect in pairs( self.effects )
		do
			if not effect:OnDeath( killer )
			then
				return
			end
		end
		
		for _, item in pairs( self.items )
		do
			if not item:OnDeath( killer )
			then
				return
			end
		end
	end
	
	function Entity:Die( killer )
		self:OnDeath( killer )
		
		if self.curHP <= 0
		then
			if killer
			then
				killer:OnKill( self )
			end
		
			-- Do something on death
			self.bDead = true
		end
	end
	
	function Entity:ApplyForce( strength, angle, duration, source )
		angle = angle or 0
	
		local force = Vector( 1, 0 ):rotated( angle )
		force = force * strength
		
		self.velocity = self.velocity + force
		
		if duration
		then
			self:ApplyEffect( Effect.ControlLocked, source, duration )
		end
	end
	
	function Entity:GetAim()
		if self.aimVect.x ~= 0 or self.aimVect.y ~= 0
		then
			return self.aimVect
		else
			return self.moveVect
		end
	end
	
	function Entity:GetPosition()
		if self.collider
		then
			local x, y = self.collider:center()
			
			return Vector( x, y )
		end
		
		return Vector( 0, 0 )
	end

	function Entity:SetPosition( x, y )
		if not self.collider
		then
			self.collider = HC.circle( 0, 0, self.radius )
			self.collider.entity = self
		end
		
		if y
		then
			self.collider:moveTo( x, y )
		else
			self.collider:moveTo( x.x, x.y )
		end
	end
	
	function Entity:Move( dx, dy, sources )
		self.collider:move( dx, dy )
		
		local collisions = HC.collisions( self.collider )
		local bHit = false
		local closest = nil
		
		for other, sepVec in pairs( collisions )
		do
			if other.tile
			then
				if other.tile.bSolid
				then
					self.collider:move( sepVec.x, sepVec.y )
					bHit = true
				end
				
				if other.tile.Collide
				then
					other.tile.Collide( self )
				end				
			elseif other.entity
			then
			
				if sources and not table.contains( sources, other.entity )
				then
					local rDiv = self.mass + other.entity.mass
					self.collider:move( sepVec.x * (other.entity.mass / rDiv), sepVec.y * (other.entity.mass / rDiv) )
					other.entity:Move( sepVec.x * (-self.mass / rDiv), sepVec.y * (-self.mass / rDiv), table.insert( sources, self ) )
				else
					self.collider:move( sepVec.x, sepVec.y )
				end
				bHit = true
			elseif other.interactable
			then
				if closest 
				then
					local dist1 = self:GetPosition():dist( closest:GetPosition() )
					local dist2 = self:GetPosition():dist( other.interactable:GetPosition() )
					
					if dist2 < dist1
					then
						closest = other.interactable
					end
				else
					closest = other.interactable
				end
			end
		end
		
		self:CollideInteractable( closest )
		
		if bHit
		then
			return false
		end		
		
		return true
	end
	
	function Entity:CollideInteractable( interactable ) end
	
	function Entity:UpdateMovementInput() end
	
	function Entity:UpdateMovement( dt )
		if not self.flags:Test( 'controlLocked' )
		then
			local angle, move

			if self.aimVect:len() > 0.1
			then
				angle = VectorLight.angleTo( self.aimVect.x, -self.aimVect.y )
			else
				angle = VectorLight.angleTo( self.moveVect.x, -self.moveVect.y )
			end
			
			if self.moveVect:len() > 1
			then
				move = self.moveVect:normalized()
			else
				move = self.moveVect
			end
			
			self.face = math.floor( ( 3 * angle / math.pi ) + 6 ) % 6 + 1

			self.acceleration.x = 0
			self.acceleration.y = 0
			self.velocity = move * self:GetMoveSpeed()
		elseif not self.flags:Test( 'dodging' )
		then
			self.acceleration.x = math.sign( self.velocity.x ) * self.friction
			self.acceleration.y = math.sign( self.velocity.y ) * self.friction
		end
		
		local halfdt = dt / 2
		
		self.velocity = self.velocity + (self.acceleration * halfdt)
		self:CalculatePosition( dt )
		self.velocity = self.velocity + (self.acceleration * halfdt)
	end

	function Entity:CalculatePosition( dt )
		local numSteps, step
		
		numSteps = math.ceil( self.velocity:len() * dt / Game.TileSize )
		step = (self.velocity * dt) / numSteps
		
		-- Perform collision checks
		for i = 1, numSteps
		do
			if not self:Move( step.x, step.y, { self } )
			then
				break
			end
		end
	end
	
	function Entity:UpdateAnimations( dt )
		if not self.flags:Test( 'animLocked' )
		then
			if (self.moveVect.x == 0) and (self.moveVect.y == 0)
			then
				self.currentAnimation = "idle"
			else
				self.currentAnimation = "walk"
			end
		end
		
		if self.animations[self.currentAnimation] == nil
		then
			self.currentAnimation = "idle"
		end
		
		self.animations[self.currentAnimation][self.face]:update( dt )
	end
	
	function Entity:UpdateProjectiles( dt )
		local proj = nil
		
		for idx = #self.projectiles, 1, -1
		do
			proj = self.projectiles[idx]
			
			proj:Update( dt )
			
			if proj.bExpired
			then
				HC.remove( proj.collider )
				table.remove( self.projectiles, idx )
			end
		end
		
	end
	
	function Entity:Update( dt )
		self:UpdateAffixes( dt )
		self:UpdateItems( dt )
		self:UpdateEffects( dt )
		self:UpdateAbilities( dt )
		self:UpdateProjectiles( dt )
		
		if not self.flags:Test( 'controlLocked' )
		then
			self:UpdateMovementInput()
		end

		self:UpdateMovement( dt )
		self:UpdateAnimations( dt )
		
		for src, sleep in pairs( self.damageSources )
		do
			sleep = sleep - dt
			
			if sleep <= 0
			then
				sleep = nil
			end

			self.damageSources[src] = sleep
		end
	
		self:UpdateAllies( dt )
	end

	function Entity:Draw()
		GFX.setColor( self.color )
		
		local position, animOffset
		
		position = self:GetPosition()
		
		animOffset = self.animations[self.currentAnimation][self.face].animOffset or Vector( self.radius, self.radius )
		self.animations[self.currentAnimation][self.face]:draw( self.animData[self.currentAnimation].spritesheet, position.x, position.y, 0, 1, 1, animOffset.x, animOffset.y )
		
		if self.flags:Test( 'outline' )
		then
			GFX.setShader( self.outline )
			self.animations[self.currentAnimation][self.face]:draw( self.animData[self.currentAnimation].spritesheet, position.x, position.y, 0, 1, 1, animOffset.x, animOffset.y )
			GFX.setShader()
		end
		
		for _, ab in pairs( self.abilities )
		do
			ab:Draw()
		end
		
		for _, af in pairs( self.affixes )
		do
			af:Draw()
		end
		
		for _, eff in pairs( self.effects )
		do
			eff:Draw()
		end
		
		for _, item in pairs( self.items )
		do
			item:Draw()
		end
		
		for _, proj in ipairs( self.projectiles )
		do
			proj:Draw()
		end
		
		for _, ally in ipairs( self.allies )
		do
			ally:Draw()
		end
		
		if bDebug
		then
			GFX.setColor( 192, 192, 192, 255 )
			self.collider:draw( "line" )
		end
	end