--[[
	Project: RoguelikeProto
	File: opotext.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 5/25/2016
--]]

PopText = Class
{
	text = "",
	life = 0,
	
	color = {},
	
	init = function( self, text, position, color )
		self.text = text or ""
		self.position = position or Vector( 0, 0 )
		self.color = color or { 255, 255, 255 }
		self.color[4] = 255
		
		self.velocity = Vector( math.random( -64, 64 ), math.random( -512, -256 ) )
		
		self.life = 1
	end
}


function PopText:Update( dt )
	self.velocity.y = self.velocity.y + (32 * dt / 2)

	self.velocity.y = math.min( self.velocity.y, 32 )
	
	self.position = self.position + (self.velocity * dt)
	
	self.life = self.life - dt
end

function PopText:DrawUI()
	local cx, cy = Game.Cam:cameraCoords( self.position.x, self.position.y )

	GFX.setColor( self.color )
	GFX.setFont( Game.Fonts.default )
	GFX.printf( self.text, cx, cy, 10000 )
end