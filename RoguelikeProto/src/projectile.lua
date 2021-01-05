--[[
	Project: RoguelikeProto
	File: projectile.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 6/10/2016
--]]

Projectile = Class
{
	name = "",
	width = 16,
	height = 16,
	radius = 7,
	face = 1,
	angle = 0,
	rotation = 0,
	maxSpeed = 512,
	accel = 1024,

	range = 512,
	lifetime = 0,
	bExpired = nil,
	
	source = nil,
	faction = nil,
	
	spritesheet = nil,
	currentAnimation = "idle",
	
	target = nil,
	
	init = function( self, source, position, velocity )
		self:CreateCollision( position )
	
		self.sounds			= {}
		self.animations		= {}
		self.color			= { 255, 255, 255, 255 }
		self.velocity		= velocity or Vector( 0, 0 )
		self.acceleration	= Vector( 0, 0 )

		self.flags = Flags()
		
		self.source = source
		
		if self.spritesheet
		then
			self.grid = Anim8.newGrid( self.width, self.height, self.spritesheet:getWidth(), self.spritesheet:getHeight(), 0, 0, 1 )
			
			self.animations["idle"]	= Anim8.newAnimation( self.grid( "1-" .. self.idleFrames, 1 ), 0.05 )
			self.animations["hit"]	= Anim8.newAnimation( self.grid( "1-" .. self.hitFrames, 2 ), 0.05, function()
				self.bExpired = true
			end)
		end
		
		if self.source
		then
			self.face = self.source.owner.face
			self.faction = self.source.owner.faction
			
			table.insert( self.source.owner.projectiles, self )
		end
	end
}
	
	function Projectile:CreateCollision( position )
		position = position or Vector( 0, 0 )
	
		self.collider = HC.circle( position.x, position.y, self.radius )
		self.collider.projectile = self
	end
	
	function Projectile:OnHit( target, sepVec )
		print( "Projectile " .. self.name .. " hit " .. target.name .. " from " .. tostring( sepVec ) )
	end

	function Projectile:Destroy()
		self.velocity = Vector( 0, 0 )
		self.currentAnimation = "hit"
		self.bExpired = false
	end
	
	function Projectile:GetPosition()
		local x, y = self.collider:center()
		
		return Vector( x, y )
	end
	
	function Projectile:Move( dx, dy )
		self.collider:move( dx, dy )
		
		local bHit = false
		local collisions = HC.collisions( self.collider )
		
		for other, sepVec in pairs( collisions )
		do
			if other.tile and not self.flags:Test( 'ethereal' )
			then
				self:Destroy()
				return false
			elseif other.entity and other.entity.faction ~= self.faction
			then
				if not other.entity.flags:Test( 'invulnerable' )
				then
					self:OnHit( other.entity, sepVec )
					
					if not self.flags:Test( 'pierce' )
					then
						self:Destroy()
						return false
					end
				end
			end
		end
		
		self.lifetime = self.lifetime + VectorLight.len( dx, dy )
		
		if self.lifetime >= self.range
		then
			self:Destroy()
			return false
		end
		
		return true
	end
	
	function Projectile:SetPosition( x, y )
		if y
		then
			self.collider:moveTo( x, y )
		else
			self.collider:moveTo( x.x, x.y )
		end
	end
	
	function Projectile:UpdateMovement( dt )
		self.acceleration = Vector( 0, 0 )
	
		if self.target
		then
			local position = self:GetPosition()
		
			local targetDist = position:dist( self.target:GetPosition() )
			local vel = self.velocity - self.target.velocity
			local speed = vel * (self.target:GetPosition() - position)
			local eta = (speed / (-self.accel)) + math.sqrt( ((speed * speed) / (self.accel * self.accel)) + (2 * targetDist / self.accel) )
			local targetPos = self.target:GetPosition() - (eta * vel)
			
			self.acceleration = (targetPos - position):normalized() * self.accel
		end

		local halfdt = dt / 2
	
		self.velocity = self.velocity + (self.acceleration * halfdt)
		self:CalculatePosition( dt )
		self.velocity = self.velocity + (self.acceleration * halfdt)
		
		if not self.bExpired
		then
			self.angle = self.velocity:angleTo()
		end
	end
	
	function Projectile:CalculatePosition( dt )
		local numSteps, step
		
		numSteps = math.ceil( self.velocity:len() * dt / Game.TileSize )
		step = (self.velocity * dt) / numSteps
		
		-- Perform collision checks
		for i = 1, numSteps
		do
			if not self:Move( step.x, step.y )
			then
				break
			end
		end	
	end
	
	function Projectile:Update( dt )
		self:UpdateMovement( dt )

		self.animations[self.currentAnimation]:update( dt )
	end
	
	function Projectile:Draw()
		local position = self:GetPosition()
	
		GFX.setColor( self.color )
		self.animations[self.currentAnimation]:draw( self.spritesheet, position.x, position.y, self.angle + self.rotation, 1, 1, self.width / 2, self.height / 2 )
	end
	
return Projectile