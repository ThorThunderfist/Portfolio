--[[
	Project: Dimensional Platformer
	File: interactable.lua
	Author: David "Thor Thunderfist" Hack
--]]

Interactable = Class
{
	name = "",
	
	radius = 7,
	
	spritesheet = nil,
	animData = nil,
	currentAnimation = "idle",
	
	init = function( self, position )
		position = position or Vector( 0, 0 )
		
		self.collider = HC.circle( position.x + self.width / 2, position.y + self.height / 2, self.radius )
		self.collider.interactable = self
		
		self.outline = GFX.newShader( "src/shader/outline.glsl" )
		self.outline:send( "stepSize", {
			3 / self.animData[self.currentAnimation].spritesheet:getWidth(),
			3 / self.animData[self.currentAnimation].spritesheet:getHeight()
		} )
		self.outline:sendColor( "color", self.outlineColor or { 1, 1, 1, 1 } )
		
		self.sounds			= {}
		self.animations		= {}
		self.color			= { 1, 1, 1, 1 }
		
		if self.animData then self:InitAnims() end
	end
}
	
	function Interactable:InitAnims()
		local wSheet, hSheet, g
		
		for name, data in pairs( self.animData )
		do
			wSheet = data.spritesheet:getWidth()
			hSheet = data.spritesheet:getHeight()
			
			self.animations[name] = {}
			
			g = Anim8.newGrid( self.width, self.height, wSheet, hSheet, 0, 0, 1 )
			
			self.animations[name] = Anim8.newAnimation( g( "1-" .. data.frames, 1 ), data.durations, function() self:OnAnimLoop( name ) end )
		end
	end
	
	function Interactable:OnAnimLoop( animName ) end
	
	function Interactable:GetPosition()
		local x, y = self.collider:center()
		
		return Vector( x, y )
	end
	
	function Interactable:SetPosition( x, y )
		if y
		then
			self.collider:moveTo( x, y )
		else
			self.collider:moveTo( x.x, x.y )
		end
	end
	
	function Interactable:UpdateAnimations( dt )
		self.currentAnimation = "idle"
		self.animations[self.currentAnimation]:update( dt )
	end
	
	function Interactable:Update( dt )
		self:UpdateAnimations( dt )
	end
	
	function Interactable:Use() end
	
	function Interactable:Draw()
		GFX.setColor( self.color )
		
		local position = self:GetPosition()
		local animOffset = self.animations[self.currentAnimation].animOffset or Vector( self.width / 2, self.height / 2 )
		
		self:DrawSelf( position, animOffset )
		
		if bOutline
		then
			self:DrawOutline( position, animOffset )
		end
		
		if bDebug
		then
			GFX.setColor( 0.75, 0.75, 0.75, 1 )
			self.collider:draw( "line" )
		end
	end
	
	function Interactable:DrawSelf( position, animOffset )
		self.animations[self.currentAnimation]:draw( self.animData[self.currentAnimation].spritesheet, position.x, position.y, 0, 1, 1, animOffset.x, animOffset.y )
	end
	
	function Interactable:DrawOutline( position, animOffset )
		GFX.setShader( self.outline )
		self.animations[self.currentAnimation]:draw( self.animData[self.currentAnimation].spritesheet, position.x, position.y, 0, 1, 1, animOffset.x, animOffset.y )
		GFX.setShader()
	end