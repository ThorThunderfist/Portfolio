--[[
	Project: Dimensional Platformer
	File: hub_0_0.lua
	Author: David "Thor Thunderfist" Hack
--]]

return Class
{
	__includes = Room,
	
	name = "HUB",
	
	width = 80,
	height = 64,

	imgDir = Game.Images.room.hub,
	
	init = function( self )
		Room.init( self )
		
		
		self.tileObjects =
		{
			TileObject( 10,28,		2,1,		'prime', 'particles' ),
			TileObject( 15,25,		2,1,		'prime', 'particles' ),
			TileObject( 20,22,		2,1,		'prime', 'shadow', 'particles' ),
			TileObject( 24,19,		2,1,		'shadow', 'particles' ),
			TileObject( 28,16,		2,1,		'shadow', 'particles' ),
			
			TileObject( 20,60,		2,2,		'prime', 'hazard' ),
		}
		
		local t = TileObject( 0,57, 2,5, 'door' )
		t.data.door = DoorData( 'hub', 'hub_-1_0', 1,
			Vector( 0, self.height * Game.TileSize / 2 ),
			Vector( -(Game.Player.width / 2) + 1, 57 * Game.TileSize + 5 * Game.TileSize - Game.Player.height ) )
		table.insert( self.doors, t )
		
		t = TileObject( 78,57, 2,5, 'door' )
		t.data.door = DoorData( 'hub', 'hub_1_0', 1,
			Vector( 80 * Game.TileSize, self.height * Game.TileSize / 2 ),
			Vector( 80 * Game.TileSize - (Game.Player.width / 2), 57 * Game.TileSize + 5 * Game.TileSize - Game.Player.height ) )
		table.insert( self.doors, t )
		
		Room.GenerateWalls( self )
		
		self:DrawCanvas()
	end
}