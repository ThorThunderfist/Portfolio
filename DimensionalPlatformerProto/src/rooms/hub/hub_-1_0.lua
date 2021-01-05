--[[
	Project: Dimensional Platformer
	File: hub_-1_0.lua
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
		}
		
		local t = TileObject( 78,57, 2,5, 'door' )
		t.data.door = DoorData( 'hub', 'hub_0_0', 1,
			Vector( 80 * Game.TileSize, self.height * Game.TileSize / 2 ),
			Vector( 80 * Game.TileSize - (Game.Player.width / 2), 57 * Game.TileSize + 5 * Game.TileSize - Game.Player.height ) )
		table.insert( self.doors, t )
		
		Room.GenerateWalls( self )
		
		self:DrawCanvas()
	end
}