--[[
	Project: RoguelikeProto
	File: room.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 8/1/2016
--]]

Room = Class
{
	width = 0,
	height = 0,
	
	init = function( self, level, layout, x, y )
		self.tiles		= {}
		self.doorTiles	= {}
		self.doors		= {}
		
		self.enemies	= {}
		
		self.level		= level
		self.layout		= layout
		self.position	= Vector( x or 0, y or 0 )
		
		self.bCleared	= false
		
		if layout
		then
			self.width, self.height = layout:getDimensions()
		end
	end
}
	
	function Room:ClearCollision()
		for y, row in ipairs( self.tiles )
		do
			for x, tile in ipairs( row )
			do
				if tile.collider
				then
					HC.remove( tile.collider )
				end
			end
		end
		
		if self.collider
		then
			HC.remove( self.collider )
		end
	end
	
	function Room:CloseDoors()
		for _, tile in ipairs( self.doors )
		do
			tile.bSolid = true
		end
	end
	
	function Room:ConnectToCorridors()
		local min, l, r, t, b
		local w = self.level.corridorWidth
		
		for y, row in ipairs( self.tiles )
		do
			for x, tile in ipairs( row )
			do
				if tile.bDoor and tile.corridors and not tile.connected
				then
					tile.connected = true
					table.insert( self.doors, tile )
					
					l = tile.corridors.l
					r = tile.corridors.r
					t = tile.corridors.t
					b = tile.corridors.b
					
					if l or r
					then
						min = (math.floor( y / w ) * w) + 1
						
						for i = min, min + w - 1
						do
							if not self.tiles[i][x].corridors
							then
								self.tiles[i][x].corridors = {}
							end
							
							if l
							then
								self.tiles[i][x].corridors.l = l
							elseif r
							then
								self.tiles[i][x].corridors.r = r
							end
							
							self.tiles[i][x].connected = true
							table.insert( self.doors, self.tiles[i][x] )
						end
					elseif t or b
					then
						min = (math.floor( x / w ) * w) + 1
						
						for i = min, min + w - 1
						do
							if not self.tiles[y][i].corridors
							then
								self.tiles[y][i].corridors = {}
							end
							
							if t
							then
								self.tiles[y][i].corridors.t = t
							elseif b
							then
								self.tiles[y][i].corridors.b = b
							end
							
							self.tiles[y][i].connected = true
							table.insert( self.doors, self.tiles[y][i] )
						end
					end
				end
			end
		end
	end
	
	function Room:CreateCollision()
		local pos
		
		for y, row in ipairs( self.tiles )
		do
			for x, tile in ipairs( row )
			do
				if tile.bSolid or tile.bDoor
				then
					pos = Level:ToWorldCoords( tile.position + self.position )
					tile.collider = HC.rectangle( pos.x - Game.TileSize, pos.y - Game.TileSize, Game.TileSize, Game.TileSize )
					tile.collider.tile = tile
				end
			end
		end
		
		pos = Level:ToWorldCoords( self.position )
		self.collider = HC.rectangle( pos.x + Game.TileSize, pos.y + Game.TileSize, (self.width - 2) * Game.TileSize, (self.height - 2 - self.level.wallHeight) * Game.TileSize )
		self.collider.room = self
	end
	
	function Room:Enter()
		self.level.activeRoom = self
		
		if not self.bCleared
		then
			self:CloseDoors()
			self:SpawnEnemies()
		end
	end
	
	function Room:Exit()
		self.level.activeRoom = nil
		self.bCleared = true
		
		self:OpenDoors()
	end
	
	function Room:ExpandWalls()
		for y, row in ipairs( self.tiles )
		do
			for x, tile in ipairs( row )
			do
				if tile.bWall
				then
					for i = self.level.wallHeight, 1, -1
					do
						if self.tiles[y-i] and self.tiles[y-i][x]
						then
							self.tiles[y-i][x].bSolid = true
						end
					end
				end
			end
		end
	end
	
	function Room:Finalize()
		self:ConnectToCorridors()
		self:SolidifyDoors()
		self:ExpandWalls()
	end
	
	function Room:GenerateTiles()
		self.tiles = {}

		for y = 1, self.height
		do
			self.tiles[y] = {} 

			for x = 1, self.width
			do
				local r, g, b, a = self.layout:getPixel( x - 1, y - 1 )
				local tile = { position = Vector( x, y ), owner = self, r = r, g = g, b = b, a = a }
				
				tile.bWall = (r == 0 and g == 0 and b == 0)
				tile.bSolid = tile.bWall
				
				self.level:SetTileFlags( tile, r, g, b, a )
				
				self.tiles[y][x] = tile
			end
		end
	end

	function Room:GetCenterPoint()
		return Vector( self.position.x + (self.width / 2), self.position.y + (self.height / 2) )
	end
	
	function Room:GetClosestDoors( other )
		local temp = 0
		local dist = math.huge
		local thisDoor = nil
		local otherDoor = nil
		
		for _, row in pairs( self:GetValidDoorTiles() )
		do
			for _, door in pairs( row )
			do
				temp = (door.position + self.position):dist( other.position )
				
				if temp < dist
				then
					dist = temp
					thisDoor = door
				end
			end
		end
		
		dist = math.huge
		
		for _, row in pairs( other:GetValidDoorTiles() )
		do
			for _, door in pairs( row )
			do
				temp = (door.position + other.position):dist( self.position )
				
				if temp < dist
				then
					dist = temp
					otherDoor = door
				end
			end
		end
		
		return thisDoor, otherDoor
	end
	
	function Room:GetDistance( other )
		local l, r, t, b
		local oL, oR, oT, oB
		local bH, bV
		
		l = self.position.x
		r = self.position.x + self.width
		t = self.position.y
		b = self.position.y + self.height
		
		oL = other.position.x
		oR = other.position.x + other.width
		oT = other.position.y
		oB = other.position.y + other.height
		
		bH = (r < oL) or (l > oR)
		bV = (b < oT) or (t > oB)
		
		if bH and bV
		then
			if r < oL
			then
				if t < oB
				then
					return Vector( r, t ):dist( Vector( oL, oB ) )
				elseif b > oT
				then
					return Vector( r, b ):dist( Vector( oL, oT ) )
				end
			elseif l > oR
			then
				if t < oB
				then
					return Vector( l, t ):dist( Vector( oR, oB ) )
				elseif b > oT
				then
					return Vector( l, b ):dist( Vector( oR, oT ) )
				end
			end
		elseif bH
		then
			return math.min( math.abs( l - oR ), math.abs( r - oL ) )
		elseif bV
		then
			return math.min( math.abs( t - oB ), math.abs( b - oT ) )
		end
	end
	
	function Room:GetValidDoorTiles()
		if self.doorTiles and #self.doorTiles > 0
		then
			return self.doorTiles
		end
	
		self.doorTiles = {}
		
		local w = self.level.corridorWidth
		
		for y, row in ipairs( self.tiles )
		do
			if y == 1 or y == self.height or y % w > 1
			then
				self.doorTiles[y] = {}
				
				for x, tile in ipairs( row )
				do
					if tile.bDoor
					then
						if x == 1 or x == self.width or x % w > 1
						then
							self.doorTiles[y][x] = tile
						end
					end
				end
			end
		end
		
		return self.doorTiles
	end
	
	function Room:OpenDoors()
		local x, y
		local w = self.level.corridorWidth
	
		for _, tile in ipairs( self.doors )
		do
			x = tile.position.x
			y = tile.position.y
			
			if x == 1 or x == self.width
			then
				if y % w > 1
				then
					tile.bSolid = false
				else
					tile.bSolid = true
				end
			elseif y == 1 or y == self.height
			then
				if x % w > 1
				then
					tile.bSolid = false
				else
					tile.bSolid = true
				end
			end			
		end
	end
	
	function Room:SolidifyDoors()
		local w = self.level.corridorWidth
	
		for y, row in ipairs( self.tiles )
		do
			for x, tile in ipairs( row )
			do
				if tile.bDoor
				then
					if not tile.connected
					then
						tile.bWall = true
						tile.bSolid = true
					else
						if x == 1 or x == self.width
						then
							if y % w <= 1
							then
								tile.bWall = true
								tile.bSolid = true
							end
						elseif y == 1 or y == self.height
						then
							if x % w <= 1
							then
								tile.bWall = true
								tile.bSolid = true
							end
						end
					end
				end
			end
		end
	end
	
	function Room:SpawnEnemies()
		local etype, position
		local num = 0
	
		for y, row in pairs( self.tiles )
		do
			for x, tile in pairs( row )
			do
				if tile.enemySpawn and self.level.enemyList[tile.enemySpawn]
				then
					num = num + 0.2
					etype = self.level.enemyList[tile.enemySpawn]:lower()
					position = (self.position + tile.position - 1) * Game.TileSize - (Game.TileSize / 2)
					
					table.insert( self.enemies,
									{
										placeholder = num * 0.25,
										position = position,
										etype = etype
									} )
				end
			end
		end
	end
	
	function Room:Update( dt )
		self:UpdateEnemies( dt )
		
		if #self.enemies <= 0
		then
			self:Exit()
		end
	end

	function Room:UpdateEnemies( dt )
		local enemy = nil
		
		for idx = #self.enemies, 1, -1
		do
			enemy = self.enemies[idx]
			
			if enemy.placeholder
			then
				enemy.placeholder = enemy.placeholder - dt
				
				if enemy.placeholder <= 0
				then
					table.remove( self.enemies, idx )
					table.insert( self.enemies, Game.Enemies[enemy.etype]( enemy.position ) )
				end
			else
				enemy:Update( dt )
				
				if enemy.bDead
				then
					HC.remove( enemy.collider )
					table.remove( self.enemies, idx )
				end
			end
		end
	end
	
	function Room:DrawEnemies()
		for _, enemy in ipairs( self.enemies )
		do
			if enemy.Draw
			then
				enemy:Draw()
			end
		end
	end
	
	function Room:DrawFloors( floorSprites, floorQuads )
		local gX, gY, dIdx

		for y, row in ipairs( self.tiles )
		do
			-- 1-based indexing makes adding positions awkward
			gY = self.position.y + y - 2
			
			for x, tile in ipairs( row )
			do
				gX = self.position.x + x - 2
			
				if not tile.bSolid
				then
					GFX.draw( floorSprites, floorQuads.floor, gX * Game.TileSize, gY * Game.TileSize )
					
					dIdx = math.random( 1, 100 )
					
					if dIdx <= #floorQuads.detail
					then
						GFX.draw( floorSprites, floorQuads.detail[dIdx], gX * Game.TileSize, gY * Game.TileSize )
					end
				end
			end
		end
		
		if bDebug and self.collider
		then
			self.collider:draw( 'line' )
		end
	end
	
	function Room:DrawWalls( wallSprites, wallQuads )
		GFX.push()
			
			GFX.translate( 0, Game.TileSize * -self.level.wallHeight )
		
			local gX, gY, idx, bFace

			for y, row in ipairs( self.tiles )
			do
				-- 1-based indexing makes adding positions awkward
				gY = self.position.y + y - 2
				
				for x, tile in ipairs( row )
				do
					gX = self.position.x + x - 2
				
					if tile.bWall
					then
						idx = 0
						bFace = false
						
						if (y > 1 and self.tiles[y-1][x] and self.tiles[y-1][x].bWall)
							or (y == 1 and tile.connected and tile.corridors.t)
						then
							idx = idx + 1
						end
						
						if (x < self.width and self.tiles[y][x+1] and self.tiles[y][x+1].bWall)
							or (x == self.width and tile.connected and tile.corridors.r)
						then
							idx = idx + 2
						end
						
						if (y < self.height and self.tiles[y+1][x] and self.tiles[y+1][x].bWall)
							or (y == self.height and tile.connected and tile.corridors.b)
						then
							idx = idx + 4
						else
							bFace = true
						end
						
						if (x > 1 and self.tiles[y][x-1] and self.tiles[y][x-1].bWall)
							or (x == 1 and tile.connected and tile.corridors.l)
						then
							idx = idx + 8
						end
						
						GFX.draw( wallSprites, wallQuads.top[idx], gX * Game.TileSize, gY * Game.TileSize )
						
						if bFace
						then
							for i = 1, self.level.wallHeight - 1
							do
								GFX.draw( wallSprites, wallQuads.face[idx], gX * Game.TileSize, (gY + i) * Game.TileSize )
							end
							
							GFX.draw( wallSprites, wallQuads.bottom[idx], gX * Game.TileSize, (gY + self.level.wallHeight) * Game.TileSize )
						end
					end
				end
			end
			
		GFX.pop()
	end

	function Room:DrawUI()	end