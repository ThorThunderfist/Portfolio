--[[
	Project: Dimensional Platformer
	File: enemy.lua
	Author: David "Thor Thunderfist" Hack
--]]

Enemy = Class
{
	-- Enemy inherits from Entity
	__includes = Entity,
	
	Dead = {},
	
	name = "",
	
	level = 1,
	
	aiRange = 768,
	aiTime = 0,
	targetPlayer = nil,
	
	init = function( self, position )
		self.outlineColor = { 1, 0.02, 0.02, 1 }
		
		self.aiPath = {}
		
		Entity.init( self, position )
	end
}

	function Enemy:OnDeath( killer )
		Entity.OnDeath( self, killer )
	end

	function Enemy:PathToTarget()
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
		
		local originPos = Game.Room:ToTileCoords( self:GetPosition() )
		local targetPos = Game.Room:ToTileCoords( self.targetPlayer:GetPosition() )
		
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
				self.aiPath = {}
				while prev:get( current )
				do
					table.insert( self.aiPath, current )
					current = prev:get( current )
				end
				
				table.insert( self.aiPath, current )
				return
			end
			
			table.remove( open, currentIDX )
			closed:set( current, true )
			
			local neighbor, roomCheck, tileCheck, tempScore
			
			for _, d in ipairs(	{ Vector( -1, 0 ), Vector( 0, 1 ), Vector( 1, 0 ), Vector( 0, -1 ) } )
			do
				neighbor = current + d
				roomCheck, tileCheck = Game.Room:GetRoom( neighbor )
				
				-- Check that the neighbor tile is an open space within the same room
				if roomCheck and tileCheck
				then
					if tileCheck.bSolid
					then
						tempScore = gScore:get( current ) + 100
					else
						tempScore = gScore:get( current ) + 1
					end
					
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
		
		print( "A* Search Failed!" )
	end
	
	function Enemy:SmootheAIPath()
		local walkable = function( a, b )
			self:SetPosition( a * Game.TileSize )
			
			local dir = (b - a)
			local dist = dir:len()
			local step = dir:normalized() / 4
			
			local collisions
			
			for temp = 1, dist * 4
			do
				self.collider:move( step.x * Game.TileSize, step.y * Game.TileSize )
		
				collisions = HC.collisions( self.collider )
				
				for other, _ in pairs( collisions )
				do
					if other.tile and other.tile.bSolid
					then
						return false
					end
				end
			end
			
			return true
		end
		
		local position = self:GetPosition()
		
		local idx		= #self.aiPath - 1
		local check		= self.aiPath[idx+1]
		local current	= check
		
		while idx > 1
		do
			idx = idx - 1
			if walkable( check, self.aiPath[idx] )
			then
				current = self.aiPath[idx]
				table.remove( self.aiPath, idx + 1 )
			else
				check = current
				current = self.aiPath[idx]
			end
		end
		
		self:SetPosition( position )
	end
	
	function Enemy:UpdateMovementInput()
		local distance = 0
		local closestDistance = math.huge
		local pos = self:GetPosition()
		local newTarget = nil
		
		distance = pos:dist( Game.Player:GetPosition() )
	
		if distance < closestDistance
		then
			newTarget = player
			closestDistance = distance
		end
		
		if newTarget ~= self.targetPlayer or self.aiTime > 0.5
		then
			self.targetPlayer = newTarget
			
			self:PathToTarget()
			self:SmootheAIPath()
			
			self.aiTime = 0
		end
		
		if #self.aiPath > 0
		then
			local tilePos = Game.Room:ToTileCoords( pos )
			local nextPos = self.aiPath[#self.aiPath]
			
			if tilePos ~= nextPos
			then
				self.moveVect = nextPos - tilePos
			else
				table.remove( self.aiPath )
				
				if #self.aiPath > 0
				then
					self.moveVect = self.aiPath[#self.aiPath] - tilePos
				else
					self.moveVect = Vector( 0, 0 )
				end
			end
		end
	end
	
	function Enemy:Update( dt )
		self.aiTime = self.aiTime + dt
		
		if not self.controlLocked
		then
			self:UpdateMovementInput()
		end
		
		Entity.Update( self, dt )
	end
	
	function Enemy:Draw()
		Entity.Draw( self )
	end