--[[
	Project: Dimensional Platformer
	File: room.lua
	Author: David "Thor Thunderfist" Hack
	
	Data format: Lua object
--]]

TileObject = Class
{
	init = function( self, x, y, w, h, ... )
		self.x = x
		self.y = y
		self.w = w
		self.h = h
		
		self.data = {}
		
		self.center =
		{
			x = x + w / 2,
			y = y + h / 2
		}
		
		for _, key in ipairs( {...} )
		do
			self.data[key] = {}
		end
	end
}

DoorData = Class
{
	init = function( self, zone, room, link, camStart, playerStart, playerRestart )
		self.zone = zone
		self.room = room
		self.link = link
		
		self.onEnter = function()
			Game.Cam.x = camStart.x
			Game.Cam.y = camStart.y
			Game.Player.velocity.x = 0
			Game.Player.velocity.y = 0
			Game.Player:SetPosition( playerStart )
		end
		
		self.onRestart = function()
			Game.Player.velocity.x = 0
			Game.Player.velocity.y = 0
			Game.Player:SetPosition( playerRestart or playerStart )
		end
	end
}

Room = Class
{
	width = 0,
	height = 0,
	
	gravity = 3000,
	
	entrance = 1,
	
	init = function( self )
		self.tileObjects	= {}
		self.doors			= {}
		self.interactables	= {}
		
		self.bgColor =
		{
			prime	= { 0.35, 0.5, 0.625 },
			astral	= { 1, 1, 1 },
			shadow	= { 0, 0, 0 }
		}
		
		self.tileColor =
		{
			prime	= { 0.5, 0.5, 0.5 },
			astral	= { 0.0625, 0.0625, 0.0625 },
			shadow	= { 0.9375, 0.9375, 0.9375 }
		}
		
		self.primeParticle = IMG.newImageData( 1, 1 )
		self.primeParticle:setPixel( 0, 0, 0, 1, 0, 0.25 )
		self.primeParticle = GFX.newImage( self.primeParticle )
		
		self.shadowParticle = IMG.newImageData( 1, 1 )
		self.shadowParticle:setPixel( 0, 0, 0, 0, 1, 0.25 )
		self.shadowParticle = GFX.newImage( self.shadowParticle )
		
		self.astralParticle = IMG.newImageData( 1, 1 )
		self.astralParticle:setPixel( 0, 0, 1, 1, 0, 0.25 )
		self.astralParticle = GFX.newImage( self.astralParticle )
	end
}
	
	function Room:GenerateWalls()
		local w, h = self.width, self.height
		
		local walls = {
			TileObject( 0,0,	2,h,	'prime', 'astral', 'shadow' ),
			TileObject( w-2,0,	2,h,	'prime', 'astral', 'shadow' )
		}
			
		local ceilFloor = {
			TileObject( 0,0,	w,2,	'prime', 'astral', 'shadow' ),
			TileObject( 0,h-2,	w,2,	'prime', 'astral', 'shadow' )
		}
		
		for _, t in ipairs( self.doors )
		do
			for _, wall in pairs( walls )
			do
				if AABB(t, wall)
				then
					local newH = t.y - wall.y
					local newTileObj = TileObject( wall.x, t.y + t.h,	2, wall.h - t.h - newH )
					newTileObj.data = wall.data
					table.insert( walls, newTileObj )
					wall.h = newH
				end
			end
			
			for i = #walls, 1, -1
			do
				if walls[i].h <= 0
				then
					table.remove( walls, i )
				end
			end
			
			for _, surf in pairs( ceilFloor )
			do
				if AABB(t, surf)
				then
					local newW = t.x - surf.x
					local newTileObj = TileObject( t.x + t.w, surf.y,	surf.w - t.w - newW, 2 )
					newTileObj.data = surf.data
					table.insert( ceilFloor, newTileObj )
					surf.h = newH
				end
			end
			
			for i = #ceilFloor, 1, -1
			do
				if ceilFloor[i].w <= 0
				then
					table.remove( ceilFloor, i )
				end
			end
		end
		
		for _, wall in pairs( walls )
		do
			if wall.h > 0
			then
				table.insert(self.tileObjects, wall )
			end
		end
		
		for _, surf in pairs( ceilFloor )
		do
			if surf.w > 0
			then
				table.insert(self.tileObjects, surf )
			end
		end
	end
	
	function Room:ClearCollision()
		for _, tileObj in ipairs( self.tileObjects )
		do
			Game.Collision:remove( tileObj )
		end
		
		for _, door in ipairs( self.doors )
		do
			Game.Collision:remove( door )
		end
	end
	
	local createPlanarParticles = function( particle, x, y, w, h )
		local system = GFX.newParticleSystem( particle, 64 )
		
		system:setPosition( x, y )
		system:setEmissionArea( 'uniform', w / 2, h / 2 )
		
		system:setParticleLifetime( 2, 4 )
		system:setEmissionRate( 10 )
		
		system:setSizes( 0.5, 1.0, 1.2, 1.5, 1.8, 2.0 )
		
		system:setLinearAcceleration( -1, -1, 1, 1 )
		system:setSpin( 20, 50 )
		
		system:emit(50)
		
		return system
	end
	
	function Room:CreateCollision()
		for _, tileObj in ipairs( self.tileObjects )
		do
			if tileObj.data and (tileObj.data.prime or tileObj.data.astral or tileObj.data.shadow)
			then
				local x = tileObj.x * Game.TileSize
				local y = tileObj.y * Game.TileSize
				local w = tileObj.w * Game.TileSize
				local h = tileObj.h * Game.TileSize
				
				Game.Collision:add( tileObj, x, y, w, h )
				
				if tileObj.data.particles
				then
					local cx = x + w / 2
					local cy = y + h / 2
				
					if tileObj.data.prime
					then
						tileObj.data.particles.prime = createPlanarParticles( self.primeParticle, cx, cy, w, h )
					end
					
					if tileObj.data.astral
					then
						tileObj.data.particles.astral =  createPlanarParticles( self.astralParticle, cx, cy, w, h )
					end
					
					if tileObj.data.shadow
					then
						tileObj.data.particles.shadow = createPlanarParticles( self.shadowParticle, cx, cy, w, h )
					end
				end
			end
		end
		
		for _, door in ipairs( self.doors )
		do
			local x = door.x * Game.TileSize
			local y = door.y * Game.TileSize
			local w = door.w * Game.TileSize
			local h = door.h * Game.TileSize
			
			Game.Collision:add( door, x, y, w, h )
		end
	end
	
	function Room:Enter( entrance )
		self:CreateCollision()
		self:DrawCanvas()
		self.doors[entrance or self.entrance].data.door.onEnter()
	end
	
	function Room:Exit()
		self:ClearCollision()
		self:ClearCanvas()
	end
	
	function Room:Restart()
		self.doors[entrance or self.entrance].data.door.onRestart()
	end
	
	function Room:Update( dt )
		for _, tileObj in ipairs( self.tileObjects )
		do
			if tileObj.data.particles
			then
				for plane, particles in pairs( tileObj.data.particles )
				do
					if plane ~= Game.Plane
					then
						particles:update( dt )
					end
				end
			end
		end
	end

	function Room:DrawCanvas()
		--self.background = Game.Images.bg.bg
		
		self.canvas =
		{
			prime	= GFX.newCanvas( self.width * Game.TileSize, self.height * Game.TileSize ),
			astral	= GFX.newCanvas( self.width * Game.TileSize, self.height * Game.TileSize ),
			shadow	= GFX.newCanvas( self.width * Game.TileSize, self.height * Game.TileSize )
		}
	
		GFX.setCanvas( self.canvas.prime )
			GFX.clear()
			self:DrawTileObjs( 'prime' )
		GFX.setCanvas( self.canvas.astral )
			GFX.clear()
			self:DrawTileObjs( 'astral' )
		GFX.setCanvas( self.canvas.shadow )
			GFX.clear()
			self:DrawTileObjs( 'shadow' )
		GFX.setCanvas()
	end
	
	function Room:ClearCanvas()
		self.canvas = {}
	end
	
	function Room:DrawTileObjs( plane )
		for _, tileObj in ipairs( self.tileObjects )
		do
			local x = tileObj.x * Game.TileSize
			local y = tileObj.y * Game.TileSize
			local w = tileObj.w * Game.TileSize
			local h = tileObj.h * Game.TileSize
		
			if tileObj.data and tileObj.data[plane]
			then
				if tileObj.data.hazard
				then
					GFX.setColor( 1, 0, 0 )
				else
					GFX.setColor( self.tileColor[plane] )
				end

				GFX.rectangle('fill', x, y, w, h)
			end
			
			if bDebug
			then
				GFX.setColor( 1, 1, 1, 0.25 )
			
				GFX.rectangle('line', x, y, w, h)
			end
		end
		
		for _, door in ipairs( self.doors )
		do
			local x = door.x * Game.TileSize
			local y = door.y * Game.TileSize
			local w = door.w * Game.TileSize
			local h = door.h * Game.TileSize
		
			if bDebug
			then
				GFX.setColor( 1, 1, 1, 0.25 )
			
				GFX.rectangle('line', x, y, w, h)
			end
		end
	end
	
	function Room:Draw()
		GFX.setBackgroundColor( self.bgColor[Game.Plane] )
		
		if self.background
		then
			GFX.setColor( 1, 1, 1, 1 )
			GFX.draw( self.background )
		end
		
		--Draw shadows/lighting
		
		GFX.setColor( 1, 1, 1, 1 )
		
		if self.canvas and self.canvas[Game.Plane]
		then
			GFX.draw( self.canvas[Game.Plane] )
		end
		
		for _, inter in ipairs( self.interactables )
		do
			inter:Draw()
		end
		
		for _, tileObj in ipairs( self.tileObjects )
		do
			if tileObj.data.particles
			then
				for plane, particles in pairs( tileObj.data.particles )
				do
					if plane ~= Game.Plane
					then
						GFX.draw( particles )
					end
				end
			end
		end
		
		Game.Player:Draw()
	end
	
	function Room:DrawUI()	end