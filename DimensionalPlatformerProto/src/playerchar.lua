--[[
	Project: Dimensional Platformer
	File: playerchar.lua
	Author: David "Thor Thunderfist" Hack
--]]

local PlayerInput =
{
	-------------------
	-- Movement input
	-------------------
	ButtonDownDown = function( self )
		self.movementInput.down = true
	end,
	
	ButtonReleaseDown = function( self )
		self.movementInput.down = false
	end,
	
	ButtonDownLeft = function( self )
		self.movementInput.left = true
	end,
	
	ButtonReleaseLeft = function( self )
		self.movementInput.left = false
	end,
	
	ButtonDownRight = function( self )
		self.movementInput.right = true
	end,
	
	ButtonReleaseRight = function( self )
		self.movementInput.right = false
	end,
	
	ButtonDownUp = function( self )
		self.movementInput.up = true
	end,
	
	ButtonReleaseUp = function( self )
		self.movementInput.up = false
	end,
	
	ButtonDownJump = function( self )
		self:Jump()
	end,
	
	ButtonHoldJump = function( self, dt )
		self:HoldJump()
	end,
	
	ButtonReleaseJump = function( self )
		self:EndJump()
	end,

	ButtonDownDash = function( self )
		self:Dash()
	end,
	
	ButtonHoldDash = function( self, dt )	end,
	ButtonReleaseDash = function( self )	end,
	
	AxisUpdateLeftX = function( self, newValue, oldValue )
		if oldValue < 0.5 and newValue >= 0.5
		then
			self:ButtonDownRight()
		elseif oldValue > -0.5 and newValue <= -0.5
		then
			self:ButtonDownLeft()
		end
		
		if oldValue >= 0.5 and newValue < 0.5
		then
			self:ButtonReleaseRight()
		elseif oldValue <= -0.5 and newValue > -0.5
		then
			self:ButtonReleaseLeft()
		end
	end,
	
	AxisUpdateLeftY = function( self, newValue, oldValue )
		if oldValue < 0.5 and newValue >= 0.5
		then
			self:ButtonDownDown()
		elseif oldValue > -0.5 and newValue <= -0.5
		then
			self:ButtonDownUp()
		end
		
		if oldValue >= 0.5 and newValue < 0.5
		then
			self:ButtonReleaseDown()
		elseif oldValue <= -0.5 and newValue > -0.5
		then
			self:ButtonReleaseUp()
		end
	end,
	
	AxisUpdateRightX = function( self, newValue, oldValue )	end,
	AxisUpdateRightY = function( self, newValue, oldValue )	end,
	
	-------------------------
	-- Ability input
	-------------------------
	ButtonDownToggleAstral = function( self )
		if Game.Plane == 'astral'
		then
			Game.Plane = 'prime'
		else
			Game.Plane = 'astral'
		end
	end,
	
	ButtonHoldToggleAstral = function( self )	end,
	ButtonReleaseToggleAstral = function( self )	end,
	
	ButtonDownToggleShadow = function( self )
		if Game.Plane == 'shadow'
		then
			Game.Plane = 'prime'
		else
			Game.Plane = 'shadow'
		end
	end,
	
	ButtonHoldToggleShadow = function( self )	end,
	ButtonReleaseToggleShadow = function( self )	end,
	AxisUpdateMap = function( self, newValue, oldValue )	end,

	---------------
	-- Misc input
	---------------
	ButtonDownUse = function( self )
		if self.activeInteractable
		then
			self.activeInteractable:Use()
		end
	end,
	
	ButtonHoldUse = function( self, dt )	end,
	ButtonReleaseUse = function( self )	end
}

PlayerChar = Class
{
	runAccel = 3500,
	friction = 2500,
	drag = 1500,
	
	jumpSpeed = -750,
	doubleJumpSpeed = -650,
	wallJumpYSpeed = -650,
	wallJumpXSpeed = -750,
	endJumpSpeedLimit = -300,

	dashSpeed = 1500,
	dashDrag = 15000,
	dashFrames = 10,
	dashRecoveryFrames = 3,
	currentDashFrame = 0,
	dashCooldown = 12,
	currentDashCooldown = 0,
	
	glideFrames = 60 * 5, -- 60 fps, 5 seconds
	glideStamina = 0,
	glideAccelX = 1500,
	glideAccelY = 500,
	glideDrag = 250,
	glideTerminalVelocity = Vector( 450, 150 ),
	
	wallMod = 1/6,
	
	velocity = Vector( 0, 0 ),
	terminalVelocity = Vector( 450, 1000 ),
	acceleration = Vector( 0, 0 ),
	
	moveVect = Vector( 0, 0 ),
	
	x = 0,
	y = 0,
	width = 48,
	height = 72,
	face = 1, -- x sign
	
	onGround = false,
	onWall = 0,

	jumping = false,
	jumpHeld = false,
	doubleJumpReady = false,
	dashReady = false,
	
	dead = false,
	
	spritesheet = nil,
	animData = nil,
	currentAnimation = "idle",
	animations = {},

	outlineColor = { 1, 1, 1, 1 },
	color =
	{
		prime = { 0.5, 0.5, 0.5, 1 },
		astral = { 0.25, 0.25, 0.25, 1 },
		shadow = { 0.75, 0.75, 0.75, 1 }
	},
	
	sounds = {},
	
	activeInteractable = nil,
	
	movementInput =
	{
		left = false,
		right = false,
		up = false,
		down = false
	},
	
	init = function( self, position )
		Input.RegisterPlayer( self )
	
		position = position or Vector( 0, 0 )
		
		self.x, self.y = position.x, position.y
		Game.Collision:add( self, self.x, self.y, self.width, self.height )
		
		self.label = GFX.newText( Game.Fonts.default, "@" )
		
		if self.animData then self:InitAnims() end
	end
}

	PlayerChar:include( PlayerInput )

	function PlayerChar:InitAnims()
		local wSheet, hSheet, w, h, g, dir
		
		for name, data in pairs( self.animData )
		do
			wSheet = data.spritesheet:getWidth()
			hSheet = data.spritesheet:getHeight()
			
			self.animations[name] = {}
			
			for angle=1,4
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
				
				self.animations[name][angle] = Anim8.newAnimation( g( "3-8", (angle * 2) - 1,  "3-8", angle * 2 ), data.durations, function() self:OnAnimLoop( name ) end )
				
				if dir and dir.offset
				then
					self.animations[name][angle].animOffset = dir.offset
				end
			end
			
			self.animations[name].totalDuration = self.animations[name][1].totalDuration
		end
	end
	
	function PlayerChar:Jump()
		if self.onGround
		then
			self.velocity.y = self.jumpSpeed
			self.jumping = true
			self.jumpHeld = true
		elseif self.onWall ~= 0
		then
			self.velocity.y = self.wallJumpYSpeed
			self.velocity.x = self.wallJumpXSpeed * self.onWall
			self.jumping = true
			self.jumpHeld = true
		elseif self.doubleJumpReady
		then
			self.velocity.y = self.doubleJumpSpeed
			self.doubleJumpReady = false
			self.jumping = true
			self.jumpHeld = true
		end
		
		self.currentDashFrame = 0
	end
	
	function PlayerChar:HoldJump( dt )
		self.jumpHeld = true
	end
	
	function PlayerChar:EndJump()
		self.jumpHeld = false
	end
	
	function PlayerChar:Dash()
		if self.dashReady and self.currentDashCooldown == 0 and self.moveVect.x ~= 0
		then
			self.velocity.x = self.face * self.dashSpeed
			self.velocity.y = 0
			self.currentDashFrame = self.dashFrames
			self.currentDashCooldown = self.dashCooldown
			self.dashReady = false
		end
	end
	
	function PlayerChar:OnAnimLoop( animName ) end
	
	function PlayerChar:Die()
		self.dead = true
	end
	
	function PlayerChar:ApplyForce( strength, angle, duration, source )
		angle = angle or 0
	
		local force = Vector( 1, 0 ):rotated( angle )
		force = force * strength
		
		self.velocity = self.velocity + force
	end
	
	function PlayerChar:GetPosition()
		return Vector( self.x, self.y )
	end
	
	function PlayerChar:GetCenter()
		return Vector( self.x + self.width / 2, self.y + self.height / 2)
	end

	function PlayerChar:SetPosition( x, y )
		if y
		then
			self.x = x
			self.y = y
		else
			self.x = x.x
			self.y = x.y
		end
		
		Game.Collision:update( self, self.x, self.y )
	end
	
	function PlayerChar:CollideInteractable( interactable )
		if interactable ~= self.activeInteractable
		then
			if self.activeInteractable
			then
				self.activeInteractable.bOutline = false
			end
			
			if interactable
			then
				interactable.bOutline = true
			end
			
			self.activeInteractable = interactable
		end
	end
	
	local detectionFilter = function( item, other )
		if other.data
		then
			if other.data[Game.Plane]
			then
				return 'slide'
			end
		end
	end
	
	local collisionFilter = function( item, other )
		if other.data
		then
			if other.data.door
			then
				return 'cross'
			elseif other.data[Game.Plane]
			then
				if other.data.hazard
				then
					return 'touch'
				else
					return 'slide'
				end
			end
		end
	end

	function PlayerChar:UpdateMovement( dt )
		self.moveVect.x = (self.movementInput.left and -1 or 0) + (self.movementInput.right and 1 or 0)
		self.moveVect.y = (self.movementInput.up and -1 or 0) + (self.movementInput.down and 1 or 0)
	
		if self.currentDashFrame > 0
		then
			self.currentDashFrame = self.currentDashFrame - 1
			
			if self.currentDashFrame <= self.dashRecoveryFrames
			then
				self.velocity.x = math.approach( self.velocity.x, 0, self.dashDrag * dt)
				self.velocity.y = math.approach( self.velocity.y, 0, self.dashDrag * dt)
			end
		else
			self.currentDashCooldown = math.max(self.currentDashCooldown - 1, 0)
		
			local _, _, _, hits = Game.Collision:check(self, self.x, self.y + 1, detectionFilter)
			
			if not self.onGround and hits > 0
			then
				self.doubleJumpReady = true
				self.glideStamina = self.glideFrames
			end
			
			self.onGround = hits > 0
			
			if not self.onGround
			then
				if self.velocity.y >= 0
				then
					self.jumping = false
				end
			
				local dirs = { -1, 1 }
				local wall = 0
				
				for _, dir in ipairs( dirs )
				do
					_, _, _, hits = Game.Collision:check(self, self.x + dir, self.y, detectionFilter)
					
					if self.onWall == 0 and hits > 0 and self.velocity.y > 0
					then
						self.velocity.y = 0
					end
					
					wall = wall + (hits > 0 and dir or 0)
				end
				
				self.onWall = wall
			else
				self.onWall = 0
				self.dashReady = true
			end
			
			if self.onWall == 0 and self.jumpHeld and self.glideStamina > 0
			then
				self.glideStamina = self.glideStamina - 1
			end
			
			local moveX = self.moveVect.x
			self.face = math.sign( moveX )
			
			if self.onWall ~= 0 and not self.onGround
			then
				self.acceleration.x = 0
			elseif self.velocity.y > 0 and self.jumpHeld and self.glideStamina > 0
			then
				self.acceleration.x = moveX ~= 0 and self.glideAccelX or self.glideDrag
				
				self.velocity.x = math.approach( self.velocity.x, moveX * self.glideTerminalVelocity.x, self.acceleration.x * dt)
			else
				self.acceleration.x = moveX ~= 0 and self.runAccel or (self.onGround and self.friction or self.drag)
				
				self.velocity.x = math.approach( self.velocity.x, moveX * self.terminalVelocity.x, self.acceleration.x * dt)
			end
			
			if not self.onGround
			then
				moveY = self.moveVect.y
			
				if self.onWall ~= 0
				then
					if self.velocity.y < 0
					then
						self.acceleration.y = Game.Room.gravity
					else
						self.acceleration.y = Game.Room.gravity * self.wallMod
					end
					
					self.velocity.y = math.approach( self.velocity.y, self.terminalVelocity.y, self.acceleration.y * dt )
				else
					if self.velocity.y > 0 and self.jumpHeld and self.glideStamina > 0
					then
						self.acceleration.y = self.velocity.y > self.glideTerminalVelocity.y and self.glideAccelY * 4 or self.glideAccelY
						
						self.velocity.y = math.approach( self.velocity.y, self.glideTerminalVelocity.y, self.acceleration.y * dt )
					else
						self.acceleration.y = moveY > 0 and Game.Room.gravity * 2 or Game.Room.gravity
						
						if self.jumping and not self.jumpHeld and self.velocity.y < self.endJumpSpeedLimit
						then
							self.velocity.y = self.endJumpSpeedLimit
						else
							self.velocity.y = math.approach( self.velocity.y, self.terminalVelocity.y, self.acceleration.y * dt )
						end
					end
				end
			else
				self.acceleration.y = 0
			end
		end
		
		local hits, numHits
		
		self.x, self.y, hits, numHits = Game.Collision:move(self, self.x + self.velocity.x * dt, self.y + self.velocity.y * dt, collisionFilter )
		
		for i = 1, numHits
		do
			local other = hits[i].other
			
			if other and other.data
			then
				if other.data.door
				then
					local otherRect = hits[i].otherRect
					local center = self:GetCenter()
					
					if	center.x > Game.Room.width * Game.TileSize or
						center.x < 0 or
						center.y > Game.Room.height * Game.TileSize or
						center.y < 0
					then
						Game:NextRoom( Game.Rooms[other.data.door.zone][other.data.door.room](), other.data.door.link )
						return
					end
				elseif other.data[Game.Plane]
				then
					if other.data.hazard
					then
						self.velocity.x = 0
						self.velocity.y = 0
						self:Die()
					else
						if hits[i].normal.x ~= 0
						then
							self.velocity.x = 0
						end
						
						if hits[i].normal.y ~= 0
						then
							self.velocity.y = 0
						end
					end
				end
				
				if other.Collide
				then
					other.Collide( self )
				end		
			end
		end
	end
	
	function PlayerChar:UpdateAnimations( dt )
		if not self.animLocked
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
		
		--self.animations[self.currentAnimation][self.face]:update( dt )
	end
	
	function PlayerChar:Update( dt )
		self:UpdateMovement( dt )
		self:UpdateAnimations( dt )
	end

	function PlayerChar:Draw()
		GFX.setColor( self.color[Game.Plane] )
		
		local position, animOffset
		
		position = self:GetPosition()
		
		--animOffset = self.animations[self.currentAnimation][self.face].animOffset or Vector( self.radius, self.radius )
		--self.animations[self.currentAnimation][self.face]:draw( self.animData[self.currentAnimation].spritesheet, position.x, position.y, 0, 1, 1, animOffset.x, animOffset.y )
		GFX.rectangle('fill', position.x, position.y, self.width, self.height)
		
		if self.bOutline
		then
			GFX.setShader( self.outline )
			self.animations[self.currentAnimation][self.face]:draw( self.animData[self.currentAnimation].spritesheet, position.x, position.y, 0, 1, 1, animOffset.x, animOffset.y )
			GFX.setShader()
		end
		
		if bDebug
		then
			--GFX.setColor( 0, 0, 0, 0.75 )
			--GFX.draw( self.label, x - 4, y - 20, 0, 0.4, 0.4 )
		end
	end
	
	function PlayerChar:DrawUI()	end