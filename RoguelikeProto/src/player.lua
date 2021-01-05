--[[
	Project: RoguelikeProto
	File: player.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 11/1/2016
--]]

Player = Class
{
	character = nil,
	
	movementInput =
	{
		left = false,
		right = false,
		up = false,
		down = false
	},

	init = function( self, controller )
		Input.RegisterPlayer( self, controller )
	end
}
	
	-------------------
	-- Movement input
	-------------------
	function Player:MoveAxis( x, y )
		if self.character
		then
			self.character.moveVect.x = x
			self.character.moveVect.y = y
		end
	end

	function Player:ButtonDownMoveDown()
		self.movementInput.down = true
	end
	
	function Player:ButtonReleaseMoveDown()
		self.movementInput.down = false
	end
	
	function Player:ButtonDownMoveLeft()
		self.movementInput.left = true
	end
	
	function Player:ButtonReleaseMoveLeft()
		self.movementInput.left = false
	end
	
	function Player:ButtonDownMoveRight()
		self.movementInput.right = true
	end
	
	function Player:ButtonReleaseMoveRight()
		self.movementInput.right = false
	end
	
	function Player:ButtonDownMoveUp()
		self.movementInput.up = true
	end
	
	function Player:ButtonReleaseMoveUp()
		self.movementInput.up = false
	end
	
	-------------------------
	-- Attack/ability input
	-------------------------
	function Player:AimAxis( x, y )
		if self.character
		then
			self.character.aimVect.x = x
			self.character.aimVect.y = y
		end
	end
	
	function Player:ButtonDownAttack()
		if self.character
		then
			self.character:ButtonDownAttack()
		end
	end
	
	function Player:ButtonHoldAttack( dt )
		if self.character
		then
			self.character:ButtonHoldAttack()
		end
	end
	
	function Player:ButtonReleaseAttack()
		if self.character
		then
			self.character:ButtonReleaseAttack()
		end
	end
	
	function Player:ButtonDownAbility1()
		if self.character
		then
			self.character:ButtonDownAbility1()
		end
	end
	
	function Player:ButtonHoldAbility1( dt )
		if self.character
		then
			self.character:ButtonHoldAbility1()
		end
	end
	
	function Player:ButtonReleaseAbility1()
		if self.character
		then
			self.character:ButtonReleaseAbility1()
		end
	end
	
	function Player:ButtonDownAbility2()
		if self.character
		then
			self.character:ButtonDownAbility2()
		end
	end
	
	function Player:ButtonHoldAbility2( dt )
		if self.character
		then
			self.character:ButtonHoldAbility2()
		end
	end
	
	function Player:ButtonReleaseAbility2()
		if self.character
		then
			self.character:ButtonReleaseAbility2()
		end
	end

	function Player:ButtonDownDodge()
		if self.character
		then
			self.character:ButtonDownDodge()
		end
	end
	
	function Player:ButtonHoldDodge( dt )
		if self.character
		then
			self.character:ButtonHoldDodge()
		end
	end
	
	function Player:ButtonReleaseDodge()
		if self.character
		then
			self.character:ButtonReleaseDodge()
		end
	end
	
	---------------
	-- Misc input
	---------------
	function Player:ButtonDownSkillRank()
		if self.character
		then
			self.character:ButtonDownSkillRank()
		end
	end
	
	function Player:ButtonHoldSkillRank( dt )
		if self.character
		then
			self.character:ButtonHoldSkillRank()
		end
	end
	
	function Player:ButtonReleaseSkillRank()
		if self.character
		then
			self.character:ButtonReleaseSkillRank()
		end
	end
	
	function Player:ButtonDownSkillMastery()
		if self.character
		then
			self.character:ButtonDownSkillMastery()
		end
	end
	
	function Player:ButtonHoldSkillMastery( dt )
		if self.character
		then
			self.character:ButtonHoldSkillMastery()
		end
	end
	
	function Player:ButtonReleaseSkillMastery()
		if self.character
		then
			self.character:ButtonReleaseSkillMastery()
		end
	end

	function Player:ButtonDownUse()
		if self.character
		then
			self.character:ButtonDownUse()
		end
	end
	
	function Player:ButtonHoldUse( dt )
		if self.character
		then
			self.character:ButtonHoldUse()
		end
	end
	
	function Player:ButtonReleaseUse()
		if self.character
		then
			self.character:ButtonReleaseUse()
		end
	end
	
	function Player:MouseAim( mx, my )
		if self.character
		then
			self.character:MouseAim( mx, my )
		end
	end
	
	function Player:GetPosition()
		if self.character
		then
			return self.character:GetPosition()
		end
	end
	
	function Player:SetPosition( x, y )
		if self.character
		then
			self.character:SetPosition( x, y )
		end
	end
	
	function Player:Update( dt )
		if self.character
		then
			--Bit of a hack
			if (Input.KBM and Input.KBM.player == self)
			then
				self.character.moveVect.x = (self.movementInput.left and -1 or 0) + (self.movementInput.right and 1 or 0)
				self.character.moveVect.y = (self.movementInput.up and -1 or 0) + (self.movementInput.down and 1 or 0)
			end
			
			self.character:Update( dt )
		end
	end
	
	function Player:Draw()
		if self.character
		then
			self.character:Draw()
		end
	end
	
	function Player:DrawUI()
		if self.character
		then
			self.character:DrawUI()
		end
	end