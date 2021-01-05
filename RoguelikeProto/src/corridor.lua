--[[
	Project: RoguelikeProto
	File: corridor.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 7/22/2016
--]]

Corridor = Class
{
	level = nil,

	init = function( self, level, origin, target )
		self.segments = {}
		self.tiles = {}
		
		self.level = level
	end
}
	
	function Corridor:ClearCollision()
		for y, row in pairs( self.segments )
		do
			for x, segment in pairs( row )
			do
				segment:ClearCollision()
			end
		end
	end
	
	-- A* algorithm to path between 2 corridor segments
	function Corridor:ConnectSegments( origin, target )
		local heuristic = function( a, b )
			return math.abs( b.x - a.x ) + math.abs( b.y - a.y )
		end
		
		local get = function( t, k )
			if t[k.y] and t[k.y][k.x] then return t[k.y][k.x] end
			
			return t.default
		end
		
		local set = function( t, k, v )
			if not t[k.y] then t[k.y] = {} end
				
			t[k.y][k.x] = v
		end
		
		local open		= {}
		local closed	= { default = false,		get = get, set = set }
		local prev		= { default = nil,			get = get, set = set }
		local gScore	= { default = math.huge,	get = get, set = set }
		local fScore	= { default = math.huge,	get = get, set = set }
		
		local originPos = origin.position
		local targetPos = target.position
		
		table.insert( open, originPos )
		gScore:set( originPos, 0 )
		fScore:set( originPos, heuristic( originPos, targetPos ) )
		
		local lowScore, seg, current, currentIDX
		
		while #open > 0
		do
			current = open[1]
			currentIDX = 1
			lowScore = fScore:get( current )
			
			for idx, seg in ipairs( open )
			do
				if seg and fScore:get( seg ) < lowScore
				then
					lowScore = fScore:get( seg )
					current = seg
					currentIDX = idx
				end
			end
			
			if current == targetPos
			then
				local oldSeg = target
				local newSeg = nil
				local otherCorridor = nil
				
				while prev:get( current )
				do
					current = prev:get( current )
					otherCorridor = self.level:GetCorridor( current * self.level.corridorWidth )
					
					if otherCorridor
					then
						newSeg = otherCorridor.segments[current.y][current.x]
					else
						newSeg = self:GenerateSegment( current.x, current.y )
					end
					
					if newSeg.position.x < oldSeg.position.x
					then
						newSeg.neighbors.r = oldSeg
						oldSeg.neighbors.l = newSeg
					elseif newSeg.position.x > oldSeg.position.x
					then
						newSeg.neighbors.l = oldSeg
						oldSeg.neighbors.r = newSeg
					elseif newSeg.position.y < oldSeg.position.y
					then
						newSeg.neighbors.b = oldSeg
						oldSeg.neighbors.t = newSeg
					elseif newSeg.position.y > oldSeg.position.y
					then
						newSeg.neighbors.t = oldSeg
						oldSeg.neighbors.b = newSeg
					end
					
					oldSeg = newSeg
				end
				
				return
			end
			
			table.remove( open, currentIDX )
			closed:set( current, true )
			
			local neighbor, roomCheck, tempScore
			
			for _, d in ipairs( { Vector( -1, 0 ), Vector( 1, 0 ), Vector( 0, -1 ), Vector( 0, 1 ) } )
			do
				neighbor = current + d
				
				-- Check that the target space is not part of a room or another corridor
				if (neighbor.x > 0 and neighbor.x <= self.level.width / self.level.corridorWidth and neighbor.y > 0 and neighbor.y <= self.level.height / self.level.corridorWidth)
				then
					roomCheck = self.level:GetRoom( neighbor * self.level.corridorWidth )
					
					if not roomCheck
					then
						tempScore = gScore:get( current ) + 1
						
						if table.contains( open, neighbor ) and tempScore < gScore:get( neighbor )
						then
							local _, idx = table.contains( open, neighbor )
							table.remove( open, idx )
						end
						
						if not table.contains( open, neighbor ) and not closed:get( neighbor )
						then
							table.insert( open, neighbor )
							
							prev:set( neighbor, current )
							gScore:set( neighbor, tempScore )
							fScore:set( neighbor, tempScore + heuristic( neighbor, targetPos ) )
						end
					end
				end
			end
		end
		
		print( "A* Search Failed!" )
	end

	function Corridor:CreateCollision()
		for y, row in pairs( self.segments )
		do
			for x, segment in pairs( row )
			do
				segment:CreateCollision()
			end
		end
	end

	function Corridor:Finalize()
		for y, row in pairs( self.segments )
		do
			for x, segment in pairs( row )
			do
				segment:ConnectToNeighbors()
			end
		end
		
		for y, row in pairs( self.segments )
		do
			for x, segment in pairs( row )
			do
				segment:ExpandWalls()
			end
		end
	end
	
	function Corridor:Generate( origin, target )
		self.segments = {}
		self.tiles = {}
		
		local oSegment = self:GenerateSegmentFromDoor( origin )
		local tSegment = self:GenerateSegmentFromDoor( target )
		
		if oSegment ~= tSegment
		then
			self:ConnectSegments( oSegment, tSegment )
		end
	end
	
	function Corridor:GenerateSegment( segX, segY )
		local segment
		
		-- Create a new segment at this position
		segment = Segment( segX, segY, self )
		segment:Generate()
		
		if not self.segments[segY]
		then
			self.segments[segY] = {}
		end
		
		self.segments[segY][segX] = segment
		
		return segment
	end
	
	function Corridor:GenerateSegmentFromDoor( door )
		local tileX, tileY, segX, segY, seg
		local dir = nil
		
		if door.position.x == 1
		then
			dir = 'r'
			tileX = door.owner.position.x - 2
			tileY = door.owner.position.y + door.position.y - 2
		elseif door.position.x == door.owner.width
		then
			dir = 'l'
			tileX = door.owner.position.x + door.owner.width
			tileY = door.owner.position.y + door.position.y - 2
		elseif door.position.y == 1
		then
			dir = 'b'
			tileX = door.owner.position.x + door.position.x - 2
			tileY = door.owner.position.y - 2
		elseif door.position.y == door.owner.height
		then
			dir = 't'
			tileX = door.owner.position.x + door.position.x - 2
			tileY = door.owner.position.y + door.owner.height
		end
		
		segX, segY = self:GetSegmentCoords( tileX, tileY )
		
		_, seg = self.level:GetCorridor( tileX, tileY )
		
		if seg
		then
			if not self.segments[segY]
			then
				self.segments[segY] = {}
			end
			
			self.segments[segY][segX] = seg
		else
			seg = self:GenerateSegment( segX, segY )
		end
		
		seg.doors[dir] = door
		
		if not door.corridors
		then
			door.corridors = {}
		end
		
		if dir == 'l'
		then
			door.corridors.r = self
		elseif dir == 'r'
		then
			door.corridors.l = self
		elseif dir == 't'
		then
			door.corridors.b = self
		elseif dir == 'b'
		then
			door.corridors.t = self
		end
		
		return seg
	end
	
	function Corridor:GetSegment( tileX, tileY )
		local segX, segY = self:GetSegmentCoords( tileX, tileY )
		
		if self.segments and self.segments[segY]
		then
			return self.segments[segY][segY]
		end
		
		return nil
	end
	
	function Corridor:GetSegmentCoords( tileX, tileY )
		local segX, segY
		
		if tileY
		then
			segX = math.ceil( tileX / self.level.corridorWidth )
			segY = math.ceil( tileY / self.level.corridorWidth )
		else
			segX = math.ceil( tileX.x / self.level.corridorWidth )
			segY = math.ceil( tileX.y / self.level.corridorWidth )
		end
		
		return segX, segY
	end
	
	function Corridor:GetTile( tileX, tileY )
		local segX, segY = self:GetSegmentCoords( tileX, tileY )
		
		if self.segments and self.segments[segY] and self.segments[segY][segX]
		then
			return self.segments[segY][segX]:GetTile( tileX, tileY )
		end
		
		return nil
	end
	
	function Corridor:DrawFloors( floorSprites, floorQuads )
		for y, row in pairs( self.segments )
		do
			for x, segment in pairs( row )
			do
				segment:DrawFloors( floorSprites, floorQuads )
			end
		end
	end
	
	function Corridor:DrawWalls( wallSprites, wallQuads )
		for y, row in pairs( self.segments )
		do
			for x, segment in pairs( row )
			do
				segment:DrawWalls( wallSprites, wallQuads )
			end
		end
	end
	


Segment = Class
{
	init = function( self, x, y, owner )
		self.neighbors	= {}
		self.doors		= {}
		self.tiles		= {}
		self.position	= Vector( x or 0, y or 0 )
		self.owner		= owner
	end
}

	function Segment:ClearCollision()
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

	function Segment:ConnectToNeighbors()
		local w = self.owner.level.corridorWidth
		
		-- Remove walls between this and neighbor segments
		if self.neighbors.l or self.doors.l
		then
			for y = 2, w - 1
			do
				self.tiles[y][1].bSolid = false
				self.tiles[y][1].bWall = false
			end
		end
		
		if self.neighbors.r or self.doors.r
		then
			for y = 2, w - 1
			do
				self.tiles[y][w].bSolid = false
				self.tiles[y][w].bWall = false
			end
		end
		
		if self.neighbors.t or self.doors.t
		then
			for x = 2, w - 1
			do
				self.tiles[1][x].bSolid = false
				self.tiles[1][x].bWall = false
			end
		end
		
		if self.neighbors.b or self.doors.b
		then
			for x = 2, w - 1
			do
				self.tiles[w][x].bSolid = false
				self.tiles[w][x].bWall = false
			end
		end
	end

	function Segment:CreateCollision()
		local thisPos = (self.position - 1) * self.owner.level.corridorWidth
		local pos
		
		for y, row in ipairs( self.tiles )
		do
			for x, tile in ipairs( row )
			do
				if tile.bSolid
				then
					pos = Level:ToWorldCoords( tile.position + thisPos )
					tile.collider = HC.rectangle( pos.x, pos.y, Game.TileSize, Game.TileSize )
					tile.collider.tile = tile
				end
			end
		end
		
		pos = Level:ToWorldCoords( thisPos + 1 )
		self.collider = HC.rectangle( pos.x + Game.TileSize, pos.y + Game.TileSize, (self.owner.level.corridorWidth - 2) * Game.TileSize, (self.owner.level.corridorWidth - 2) * Game.TileSize )
		self.collider.corridor = self.owner
	end

	function Segment:ExpandWalls()
		local h = self.owner.level.wallHeight
	
		for y, row in pairs( self.tiles )
		do
			for x, tile in pairs( row )
			do
				if tile.bWall
				then
					for i = h, 1, -1
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
	
	function Segment:Generate()
		self.tiles = {}
	
		local w = self.owner.level.corridorWidth
	
		-- Generate standalone corridor segment
		for y = 1, w
		do
			self.tiles[y] = {}
			
			for x = 1, w
			do
				tile = { position = Vector( x, y ), owner = self }
				tile.bWall = (x == 1 or x == w or y == 1 or y == w)
				tile.bSolid = tile.bWall
				
				self.tiles[y][x] = tile
			end
		end
	end
	
	function Segment:GetTile( tileX, tileY )
		local x, y
		
		if tileY
		then
			x = tileX
			y = tileY
		else
			x = tileX.x
			y = tileX.y
		end
		
		x = ((x - 1) % self.owner.level.corridorWidth) + 1
		y = ((y - 1) % self.owner.level.corridorWidth) + 1
		
		if self.tiles and self.tiles[y]
		then
			return self.tiles[y][x]
		end
		
		return nil
	end
	
	function Segment:DrawFloors( floorSprites, floorQuads )
		local gX, gY, dIdx, w
		
		w = self.owner.level.corridorWidth
		
		for y, row in ipairs( self.tiles )
		do
			-- 1-based indexing makes adding positions awkward
			gY = (self.position.y * w - (w + 1)) + y
			
			for x, tile in ipairs( row )
			do
				gX = (self.position.x * w - (w + 1)) + x
			
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
	end
	
	function Segment:DrawWalls( wallSprites, wallQuads )
		GFX.push()
			
			local h = self.owner.level.wallHeight
			
			GFX.translate( 0, Game.TileSize * -h )
		
			local gX, gY, idx, bFace
			local w = self.owner.level.corridorWidth
			
			for y, row in ipairs( self.tiles )
			do
				-- 1-based indexing makes adding positions awkward
				gY = (self.position.y * w - (w + 1)) + y
				
				for x, tile in ipairs( row )
				do
					gX = (self.position.x * w - (w + 1)) + x
					
					if tile.bWall
					then
						idx = 0
						bFace = false
						
						if (y > 1 and self.tiles[y-1][x] and self.tiles[y-1][x].bWall) or (y == 1 and (self.neighbors.t or self.doors.t))
						then
							idx = idx + 1
						end
						
						if (x < w and self.tiles[y][x+1] and self.tiles[y][x+1].bWall) or (x == w and (self.neighbors.r or self.doors.r))
						then
							idx = idx + 2
						end
						
						if (y < w and self.tiles[y+1][x] and self.tiles[y+1][x].bWall) or (y == w and (self.neighbors.b or self.doors.b))
						then
							idx = idx + 4
						else
							bFace = true
						end
						
						if (x > 1 and self.tiles[y][x-1] and self.tiles[y][x-1].bWall) or (x == 1 and (self.neighbors.l or self.doors.l))
						then
							idx = idx + 8
						end
						
						GFX.draw( wallSprites, wallQuads.top[idx], gX * Game.TileSize, gY * Game.TileSize )
						
						if bFace
						then
							for i = 1, h - 1
							do
								GFX.draw( wallSprites, wallQuads.face[idx], gX * Game.TileSize, (gY + i) * Game.TileSize )
							end
							
							GFX.draw( wallSprites, wallQuads.bottom[idx], gX * Game.TileSize, (gY + h) * Game.TileSize )
						end
					end
				end
			end
			
		GFX.pop()
	end