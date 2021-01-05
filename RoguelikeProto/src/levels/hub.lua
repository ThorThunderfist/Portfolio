--[[
	Project: RoguelikeProto
	File: hub.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 10/31/2016
	
	Comments:
		Script file for the Hub level
--]]

local Hub = Class
{
	-- Hub inherits from Level
	__includes = Level,
	
	name = "HUB",

	width = 128,
	height = 128,
	
	imgDir = Game.Images.level.hub,
	
	init = function( self )
		Level.init( self )
		
		self.bgColor = { 0,0,0 }
		self.portals = {}
		self.spawnTiles = {}
		
		self.colorMap =
		{
			[204] = Game.Levels.keep,		-- Knight's Keep
			[221] = Game.Levels.den,		-- Rogue's Den
			[238] = Game.Levels.temple,		-- High Priest's Temple
			[255] = Game.Levels.tower,		-- Archmage's Tower
		}
	end
}
	
	function Hub:Generate()
		self:GenerateRooms()
		
		self:Finalize()
		
		self:DrawCanvas()
	end

	function Hub:GenerateRooms()
		self.rooms = {}
		
		if self.imgDir
		then
			local img = self.imgDir.layouts.hub
			local w, h = img:getDimensions()
			
			self.rooms.spawn = Room( self, img:getData(), 1, 1 )
		end
		
		self.rooms.spawn:GenerateTiles()
	end
	
	function Hub:GetSpawnTile()
		return self.spawnTiles[math.random( #self.spawnTiles )]
	end
	
	function Hub:SetTileFlags( tile, r, g, b, a )
		tile.bSolid	= (r == 0 and g == 0 and b == 0)
		
		if (r == 0 and g == 255 and b == 0)
		then
			table.insert( self.spawnTiles, tile )
		end
		
		if (r == 0 and g == 0 and b > 0) and self.colorMap[b]
		then
			local portal = Game.Interactables.hubportal( self:ToWorldCoords( tile.position + tile.owner.position - Vector( 1, 1 ) ), self.colorMap[b] )
			table.insert( self.portals, portal )
			table.insert( self.interactables, portal )
		end
	end

	function Hub:Draw()
		Level.Draw( self )
		
		GFX.push()
			GFX.translate( 0, self.wallHeight * Game.TileSize )
			
			local position
			
			GFX.setColor( 0, 0, 0, 255 )
			
			for _, portal in ipairs( self.portals )
			do
				position = portal:GetPosition()
				GFX.draw( portal.label, position.x - portal.label:getWidth() / 4, position.y - (portal.height / 2) - portal.label:getHeight(), 0, 0.5, 0.5 )
			end
		GFX.pop()
	end
	
return Hub