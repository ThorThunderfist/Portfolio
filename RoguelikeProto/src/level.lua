--[[
	Project: RoguelikeProto
	File: level.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 7/30/2016
	
	Data format: PNG!
		Pixel fields:
			
			r - enemies, npcs, entities
			g - items, interactables, misc...
			b - walls, doors, features. etc/
			a - ?
--]]

Level = Class
{
	width = 192,
	height = 192,
	
	wallHeight = 1,
	corridorWidth = 4,
	
	minBossDistance = 0,
	maxBossDistance = math.huge,
	
	roomTries = 500,
	maxRooms = 24,
	
	name = "",
	
	background = nil,
	
	canvas = nil,
	
	spawn = nil,
	exit = nil,
	
	activeRoom = nil,
	
	dungeon = nil,

	namePatterns = 
	{
		"#p #t",
		"#t of #s",
		"#p #t of #s",

		"#n #t",
		"#t of #n",
		"#p #t of #n"
	},
	
	init = function( self )
		self.typeNames		= { "TYPE" }
		self.prefixes		= { "PREFIX" }
		self.suffixes		= { "SUFFIX" }
		self.nations		= { "NATION" }
		
		self.enemyList		= {}
		
		self.interactables	= {}
		
		self.rooms			= {}
		self.corridors		= {}
		self.tiles			= {}
	end
}

	function Level:ClearCollision()
		for _, interactable in ipairs( self.interactables )
		do
			if interactable.collider
			then
				HC.remove( interactable.collider )
			end
		end	
	
		for _, room in pairs( self.rooms )
		do
			room:ClearCollision()
		end
		
		for _, corridor in pairs( self.corridors )
		do
			corridor:ClearCollision()
		end
		
		for y, row in pairs( self.tiles )
		do
			for x, tile in pairs( row )
			do
				if tile.collider
				then
					HC.remove( tile.collider )
				end
			end
		end
	end
	
	function Level:CreateCollision()
		local pos
		
		HC.resetHash()
		
		for _, room in pairs( self.rooms )
		do
			room:CreateCollision()
		end
		
		for _, corridor in pairs( self.corridors )
		do
			corridor:CreateCollision()
		end
		
		for y, row in pairs( self.tiles )
		do
			for x, tile in pairs( row )
			do
				if tile.bSolid
				then
					pos = self:ToWorldCoords( tile.position )
					tile.collider = HC.rectangle( pos.x, pos.y, Game.TileSize, Game.TileSize )
					tile.collider.tile = tile
				end
			end
		end
	end
	
	function Level:CreateFloorQuads( spriteMap )
		local floorQuads = { floor = nil, detail = {} }
		
		if spriteMap
		then
			local x = 1
			local y = 1
			local w, h = spriteMap:getDimensions()
			local ts = Game.TileSize + 1
			local rowLength = math.floor( w / ts )
			local colLength = math.floor( h / ts )
			
			floorQuads.floor = GFX.newQuad( x, y, Game.TileSize, Game.TileSize, w, h)
			
			for i = 1, colLength * rowLength
			do
				x = i % rowLength
				y = (i - x) / colLength
				table.insert( floorQuads.detail, GFX.newQuad( x * ts + 1, y * ts + 1, Game.TileSize, Game.TileSize, w, h) )
			end
		end
		
		return floorQuads
	end
	
	function Level:CreateFloorPatternQuads( spriteMap )
		local patternQuads = {}
		
		if spriteMap
		then
			local w, h = spriteMap:getDimensions()
			local ts = Game.TileSize + 1
			local rowLength = math.floor( w / ts )
			local colLength = math.floor( h / ts )
			
			local newQ = function( x, y )
				return GFX.newQuad( x * ts + 1, y * ts + 1, Game.TileSize, Game.TileSize, w, h)
			end
			
			-- "bitmask" indexing for the tops of walls
			-- 1:u, 2:r, 4:d, 8:l
			patternQuads[0] = newQ( 0, 3 )					-- standalone
				patternQuads[1] = newQ( 0, 2 )				-- bottom end
				patternQuads[2] = newQ( 1, 0 )				-- left end
					patternQuads[3] = newQ( 1, 2 )			-- sw corner
				patternQuads[4] = newQ( 0, 0 )				-- top end
					patternQuads[5] = newQ( 0, 1 )			-- vertical 
					patternQuads[6] = newQ( 1, 1 )			-- nw corner
						patternQuads[7] = newQ( 3, 1 )		-- left edge
				patternQuads[8] = newQ( 3, 0 )				-- right end
					patternQuads[9] = newQ( 2, 2 )			-- se corner
					patternQuads[10] = newQ( 2, 0 )			-- horizontal
						patternQuads[11] = newQ( 2, 3 )		-- bottom edge
					patternQuads[12] = newQ( 2, 1 )			-- ne corner
						patternQuads[13] = newQ( 3, 2 )		-- right edge
						patternQuads[14] = newQ( 1, 3 )		-- top edge
							patternQuads[15] = newQ( 3, 3 )	-- 4-way
		end
		
		return patternQuads
	end
	
	function Level:CreateWallQuads( spriteMap )
		local wallQuads = { top = {}, face = {}, bottom = {} }
		
		if spriteMap
		then
			local w, h = spriteMap:getDimensions()
			local ts = Game.TileSize + 1
			local rowLength = math.floor( w / ts )
			local colLength = math.floor( h / ts )
			
			local newQ = function( x, y )
				return GFX.newQuad( x * ts + 1, y * ts + 1, Game.TileSize, Game.TileSize, w, h)
			end
			
			-- "bitmask" indexing for the tops of walls
			-- 1:u, 2:r, 4:d, 8:l
			wallQuads.top[0] = newQ( 4, 0 )						-- standalone
				wallQuads.top[1] = newQ( 0, 2 )					-- bottom end
				wallQuads.top[2] = newQ( 1, 0 )					-- left end
					wallQuads.top[3] = newQ( 1, 2 )				-- sw corner
				wallQuads.top[4] = newQ( 0, 0 )					-- top end
					wallQuads.top[5] = newQ( 0, 1 )				-- vertical 
					wallQuads.top[6] = newQ( 1, 1 )				-- nw corner
						wallQuads.top[7] = newQ( 4, 1 )			-- left edge
				wallQuads.top[8] = newQ( 3, 0 )					-- right end
					wallQuads.top[9] = newQ( 2, 2 )				-- se corner
					wallQuads.top[10] = newQ( 2, 0 )			-- horizontal
						wallQuads.top[11] = newQ( 3, 2 )		-- bottom edge
					wallQuads.top[12] = newQ( 2, 1 )			-- ne corner
						wallQuads.top[13] = newQ( 4, 2 )		-- right edge
						wallQuads.top[14] = newQ( 3, 1 )		-- top edge
							wallQuads.top[15] = newQ( 4, 3 )	-- 4-way
			
			wallQuads.face[0] = newQ( 0, 3 )
			wallQuads.face[1] = wallQuads.face[0]
			wallQuads.face[2] = newQ( 1, 3 )
			wallQuads.face[3] = wallQuads.face[2]
			wallQuads.face[8] = newQ( 3, 3 )
			wallQuads.face[9] = wallQuads.face[8]
			wallQuads.face[10] = newQ( 2, 3 )
			wallQuads.face[11] = wallQuads.face[10]
			
			wallQuads.bottom[0] = newQ( 0, 4 )
			wallQuads.bottom[1] = wallQuads.bottom[0]
			wallQuads.bottom[2] = newQ( 1, 4 )
			wallQuads.bottom[3] = wallQuads.bottom[2]
			wallQuads.bottom[8] = newQ( 3, 4 )
			wallQuads.bottom[9] = wallQuads.bottom[8]
			wallQuads.bottom[10] = newQ( 2, 4 )
			wallQuads.bottom[11] = wallQuads.bottom[10]
		end
		
		return wallQuads
	end
	
	function Level:GetCorridor( tileX, tileY )
		local segX, segY
		
		if tileY
		then
			segX = math.ceil( tileX / self.corridorWidth )
			segY = math.ceil( tileY / self.corridorWidth )
		else
			segX = math.ceil( tileX.x / self.corridorWidth )
			segY = math.ceil( tileX.y / self.corridorWidth )
		end
		
		for idx, c in pairs( self.corridors )
		do
			if c.segments and c.segments[segY] and c.segments[segY][segX]
			then
				return c, c.segments[segY][segX]
			end
		end
		
		return nil
	end
	
	function Level:GetRoom( tileX, tileY )
		local x, y, rx, ry
		
		if tileY
		then
			x = tileX
			y = tileY
		else
			x = tileX.x
			y = tileX.y
		end
		
		for idx, r in pairs( self.rooms )
		do
			if (x >= r.position.x and x < r.position.x + r.width and
				y >= r.position.y and y < r.position.y + r.height)
			then
				rx = x - r.position.x + 1
				ry = y - r.position.y + 1

				return r, r.tiles[ry][rx]
			end
		end
		
		return nil
	end
	
	function Level:GetTile( tileX, tileY )
		local x, y
		
		if tileY
		then
			x = tileX
			y = tileY
		else
			x = tileX.x
			y = tileX.y
		end
	
		if (x > 0) and (y > 0) and (y <= self.height) and (x <= self.width)
		then
			local r, rTile = self:GetRoom( x, y )
			
			if r
			then
				return rTile
			end
			
			local c = self:GetCorridor( x, y )
			
			if c
			then
				return c:GetTile( x, y )
			end
				
			if self.tiles and self.tiles[y]
			then
				return self.tiles[y][x]
			end
		end

		return nil
	end
	
	function Level:ToTileCoords( x, y )
		if y
		then
			return Vector( math.floor( x / Game.TileSize ) + 1, math.floor( y / Game.TileSize ) + 1 )
		end
		
		return Vector( math.floor( x.x / Game.TileSize ) + 1, math.floor( x.y / Game.TileSize ) + 1 )
	end
	
	function Level:ToWorldCoords( tilePos )
		return Vector( (tilePos.x * Game.TileSize) - Game.TileSize, (tilePos.y * Game.TileSize) - Game.TileSize )
	end
	
	function Level:Finalize()
		for _, room in pairs( self.rooms )
		do
			room:Finalize()
		end
		
		for _, corridor in pairs( self.corridors )
		do
			corridor:Finalize()
		end
	end
	
	function Level:Generate()
		self.tiles = {}
		self.corridors = {}
		self.interactables = {}
	
		self:GenerateName()
		self:GenerateRooms()
		self:GenerateCorridors()
		
		self:Finalize()
		
		self:DrawCanvas()
	end
	
	-- Dijkstra's algorithm for finding paths connecting rooms
	function Level:DijkstraConnect( rooms, start, target )
		local unvisited = {}
		local dist = {}
		local prev = {}
		
		for _, r in pairs( rooms )
		do
			dist[r] = math.huge
			prev[r] = nil
			table.insert( unvisited, r )
		end
		
		dist[start] = 0
		
		local tempDist = math.huge
		local nearest, nearestIdx
		
		while #unvisited > 0
		do
			tempDist = math.huge
			nearest = nil
			nearestIdx = -1

			for i, r in ipairs( unvisited )
			do
				if dist[r] < tempDist
				then
					nearest = r
					nearestIdx = i
					tempDist = dist[nearest]
				end
			end
			
			if target and nearest == target
			then
				break
			end
			
			table.remove( unvisited, nearestIdx )
			
			local alt
			
			for _, r in ipairs( unvisited )
			do
				alt = dist[nearest] + nearest:GetDistance( r )
				
				if alt < dist[r]
				then
					dist[r] = alt
					prev[r] = nearest
				end
			end
		end
		
		return dist, prev
	end
	
	function Level:GenerateCorridors()
		local dist, prev = self:DijkstraConnect( self.rooms, self.rooms.spawn )--, self.rooms.boss )
		
		if bDebug
		then
			self.roomDist = dist	-- for debug line drawing
			self.roomPrev = prev	-- for debug line drawing
		end
		
		local connect, door, oDoor, corridor
		
		if prev
		then
			for _, r in pairs( self.rooms )
			do
				connect = prev[r]
				
				if connect
				then
					door, oDoor = r:GetClosestDoors( connect )
					
					corridor = Corridor( self )
					table.insert( self.corridors, corridor )
					corridor:Generate( door, oDoor )
				end
			end
		end
	end
	
	function Level:GenerateName()
		local levelName = self.namePatterns[math.random( #self.namePatterns )]
		
		levelName = levelName:gsub( '#t', self.typeNames[math.random( #self.typeNames )] )
		levelName = levelName:gsub( '#p', self.prefixes[math.random( #self.prefixes )] )
		levelName = levelName:gsub( '#s', self.suffixes[math.random( #self.suffixes )] )
		levelName = levelName:gsub( '#n', self.nations[math.random( #self.nations )] )
		
		self.name = levelName
	end
	
	function Level:GenerateRooms()
		self.rooms = {}
		
		if self.imgDir
		then
			self:GenerateSpawnAndBoss()
			
			local img
			local w, h
			local x, y, bHit
			local rx, ry
			
			for r = 1, self.roomTries
			do
				bHit = false
			
				img = self.imgDir.layouts.rooms[math.random( #self.imgDir.layouts.rooms )]
				w, h = img:getDimensions()
				
				x = (self.width - w - (self.corridorWidth * 2))
				x = math.floor( x / self.corridorWidth )
				x = (math.random( x ) * self.corridorWidth) + 1
				
				y = (self.height - h - (self.corridorWidth * 2))
				y = math.floor( y / self.corridorWidth )
				y = (math.random( y ) * self.corridorWidth) + 1 
				
				for _, r in pairs( self.rooms )
				do
					rx = r.position.x
					ry = r.position.y
				
					if ((x < rx + r.width + self.corridorWidth) and
						(rx < x + w + self.corridorWidth) and
						(y < ry + r.height + self.corridorWidth) and
						(ry < y + h + self.corridorWidth))
					then
						bHit = true
						break
					end
				end
				
				if not bHit
				then
					table.insert( self.rooms, Room( self, img:getData(), x, y ) )
				end
				
				if #self.rooms >= self.maxRooms
				then
					break
				end
			end
		end
		
		for _, room in pairs( self.rooms )
		do
			room:GenerateTiles()
		end
	end
	
	function Level:GenerateSpawnAndBoss()
		local img = self.imgDir.layouts.spawn
		local w, h = img:getDimensions()
		local x, y, bHit
		local minX, maxX, minY, maxY
		local r, rx, ry
		
		x = (self.width - w - (self.corridorWidth * 2))
		x = math.floor( x / self.corridorWidth )
		x = (math.random( x ) * self.corridorWidth) + 1
		
		y = (self.height - h - (self.corridorWidth * 2))
		y = math.floor( y / self.corridorWidth )
		y = (math.random( y ) * self.corridorWidth) + 1
		
		self.rooms.spawn = Room( self, img:getData(), x, y )
		
		img = self.imgDir.layouts.boss[math.random( #self.imgDir.layouts.boss )]
		w, h = img:getDimensions()
		
		minX = self.corridorWidth + 1
		minY = self.corridorWidth + 1
		maxX = self.width
		maxY = self.height
		
		if x < self.width / 2
		then
			minX = self.width / 2
		else
			maxX = self.width / 2
		end
		
		if y < self.height / 2
		then
			minY = self.height / 2
		else
			maxY = self.height / 2
		end
		
		bHit = true
		
		minX = math.floor( minX / self.corridorWidth )
		minY = math.floor( minY / self.corridorWidth )
		
		while bHit
		do
			bHit = false
			
			x = (maxX - w - (self.corridorWidth * 2))
			x = math.floor( x / self.corridorWidth )
			x = (math.random( minX, x ) * self.corridorWidth) + 1
			
			y = (maxY - h - (self.corridorWidth * 2))
			y = math.floor( y / self.corridorWidth )
			y = (math.random( minY, y ) * self.corridorWidth) + 1
			
			r = self.rooms.spawn
			rx = r.position.x
			ry = r.position.y
		
			if ((x < rx + r.width + self.corridorWidth) and
				(rx < x + w + self.corridorWidth) and
				(y < ry + r.height + self.corridorWidth) and
				(ry < y + h + self.corridorWidth))
			then
				bHit = true
			end
		end
		
		self.rooms.boss = Room( self, img:getData(), x, y )
	end
	
	function Level:SetTileFlags( tile, r, g, b, a )
		tile.bDoor = (r == 0 and g == 0 and b == 255)
		
		if r > 0 and g == 0 and b == 0
		then
			tile.enemySpawn = r
		end
	end
	
	function Level:Start()
		self:CreateCollision()
		
		self.activeRoom = self.rooms.spawn
		
		local spawnPos = self.rooms.spawn.position:clone()
		
		spawnPos.x = spawnPos.x + (self.rooms.spawn.width / 2)
		spawnPos.y = spawnPos.y + (self.rooms.spawn.height / 2)
		
		for _, player in ipairs( Game.ActivePlayers )
		do
			player:SetPosition( self:ToWorldCoords( spawnPos ) )
		end
		
		if Input.KBM
		then
			Mouse.setCursor( Game.cursor )
		end
		
		if bDebug
		then
			GFX.setCanvas( self.canvas )
				GFX.setColor( 255, 128, 128, 128 )
				GFX.setLineWidth( 5 )
				GFX.push()
					GFX.translate( 0, self.wallHeight * Game.TileSize )

					for _, cor in pairs( self.corridors )
					do
						for _, row in pairs( cor.segments )
						do
							for _, seg in pairs( row )
							do
								if seg.collider
								then
									seg.collider:draw( 'fill' )
								end
							end
						end
					end
					
					for _, room in pairs( self.rooms )
					do
						if room.collider
						then
							room.collider:draw( 'fill' )
						end
					end
					
				GFX.pop()
			GFX.setCanvas()
		end
	end

	function Level:Update( dt )
		local tile, pos
		
		if self.activeRoom
		then
			self.activeRoom:Update( dt )
		end
		
		for idx = #self.interactables, 1, -1
		do
			obj = self.interactables[idx]
			
			obj:Update( dt )
			
			if obj.bExpired
			then
				HC.remove( obj.collider )
				table.remove( self.interactables, idx )
			end
		end

	end
	
	function Level:Draw()
		GFX.setBackgroundColor( self.bgColor )
		
		if self.background
		then
			GFX.setColor( 255, 255, 255, 255 )
			GFX.draw( self.background )
		end
		
		--Draw shadows/lighting
		
		GFX.setColor( 255, 255, 255, 255 )
		
		if self.canvas
		then
			GFX.draw( self.canvas )
		end
		
		GFX.push()
			GFX.translate( 0, self.wallHeight * Game.TileSize )
	
			for _, inter in ipairs( self.interactables )
			do
				inter:Draw()
			end
			
			if self.activeRoom
			then
				self.activeRoom:DrawEnemies()
			end
			
			for _, player in ipairs( Game.ActivePlayers )
			do
				player:Draw()
			end
		GFX.pop()
	end
	
	function Level:DrawCanvas()
		--self.background = Game.Images.bg.bg
		
		self.canvas = GFX.newCanvas( self.width * Game.TileSize, (self.height + self.wallHeight) * Game.TileSize )
	
		GFX.setCanvas( self.canvas )
			GFX.clear()
			GFX.setColor( 255, 255, 255, 255 )
			GFX.push()
				GFX.translate( 0, self.wallHeight * Game.TileSize )
			
				local floorQuads = self:CreateFloorQuads( self.imgDir.sprites.floor )
				local wallQuads = self:CreateWallQuads( self.imgDir.sprites.wall )
				
				for _, r in pairs( self.rooms )
				do
					r:DrawWalls( self.imgDir.sprites.wall, wallQuads )
					r:DrawFloors( self.imgDir.sprites.floor, floorQuads )
					
					if bDebug and self.roomPrev and self.roomPrev[r]
					then
						GFX.setLineWidth( 5 )
						GFX.line( (r.position.x + r.width / 2) * Game.TileSize, (r.position.y + r.height / 2) * Game.TileSize, (self.roomPrev[r].position.x + self.roomPrev[r].width / 2) * Game.TileSize, (self.roomPrev[r].position.y + self.roomPrev[r].height / 2) * Game.TileSize )
						GFX.setLineWidth( 5 )
					end
				end
					
				for _, c in pairs( self.corridors )
				do
					c:DrawWalls( self.imgDir.sprites.wall, wallQuads )
					c:DrawFloors( self.imgDir.sprites.floor, floorQuads )
				end
				
				--self:DrawWalls( self.imgDir.sprites.wall, wallQuads )
				--self:DrawFloors( self.imgDir.sprites.floor, floorQuads )
				
				if bDebug
				then
					GFX.setLineWidth( 5 )
					GFX.rectangle( 'line', 0, 0, self.width * Game.TileSize, self.height * Game.TileSize )
					GFX.setLineWidth( 1 )
				end
			GFX.pop()
		GFX.setCanvas()
	end
	
	function Level:DrawTiles( tileBatch, tileQuads )
		local detail

		for y, row in pairs( self.tiles )
		do
			for x, _ in pairs( row )
			do
				if self.tiles[y][x].bSolid
				then
					tileBatch:add( tileQuads[8], (x - 1) * Game.TileSize, (y - 1) * Game.TileSize )
					--self.tiles[y][x].collider:draw( "line" )
				else
					tileBatch:add( tileQuads[0], (x - 1) * Game.TileSize, (y - 1) * Game.TileSize )
					
					detail = math.random( 0, 100 )
					
					if (detail > 0) and (detail < 8)
					then
						tileBatch:add( tileQuads[detail], (x - 1) * Game.TileSize, (y - 1) * Game.TileSize )
					end
				end
			end
		end
	end
	
	function Level:DrawUI()
		--GFX.setColor( 0, 0, 0, 255 )
		--GFX.setFont( Game.Fonts.default )
		--GFX.printf( self.name, GFX.getWidth() - 16 - 384, 16, 384, "right" )
	end