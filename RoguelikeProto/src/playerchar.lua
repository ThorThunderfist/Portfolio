--[[
	Project: RoguelikeProto
	File: playerchar.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 11/4/2016
--]]

PlayerChar = Class
{
	-- PlayerChar inherits from Entity
	__includes = Entity,
	
	Dead = {},

	name = "CHARACTER NAME",
	passiveDesc = "PASSIVE ABILITY",
	
	faction = "player",
	
	curXP = 0,
	
	bSkillRankKey = false,
	bSkillMasteryKey = false,
	
	activeInteractable = nil,
	
	init = function( self, position )
		Entity.init( self, position )
		
		self.skills = {}
		
		self.label = GFX.newText( Game.Fonts.default, #Game.ActivePlayers + 1 )
		
		self.quads = {}

		self.quads[1] = GFX.newQuad( 1, 1, 16, 16, 35, 35 )
		self.quads[2] = GFX.newQuad( 18, 1, 16, 16, 35, 35 )
		self.quads[3] = GFX.newQuad( 1, 18, 16, 16, 35, 35 )
		self.quads[4] = GFX.newQuad( 18, 18, 16, 16, 35, 35 )
	end
}

	function PlayerChar:ButtonDownAttack()
		if self.abilities.attack
		then
			if self.bSkillRankKey
			then
				self:SkillRankUp( self.skills[1] )
			elseif self.bSkillMasteryKey
			then
				self:SkillMasteryUp( self.skills[1] )
			else
				self.abilities.attack:Use()
			end
		end
	end
	
	function PlayerChar:ButtonHoldAttack( dt )
		if self.abilities.attack
		then
			self.abilities.attack:Use()
		end
	end
	
	function PlayerChar:ButtonReleaseAttack()
	
	end
	
	function PlayerChar:ButtonDownAbility1()
		if self.abilities[1]
		then
			if self.bSkillRankKey
			then
				self:SkillRankUp( self.skills[2] )
			elseif self.bSkillMasteryKey
			then
				self:SkillMasteryUp( self.skills[2] )
			else
				self.abilities[1]:Use()
			end
		end
	end
	
	function PlayerChar:ButtonHoldAbility1( dt )
	
	end
	
	function PlayerChar:ButtonReleaseAbility1()
	
	end
	
	function PlayerChar:ButtonDownAbility2()
		if self.abilities[2]
		then
			if self.bSkillRankKey
			then
				self:SkillRankUp( self.skills[3] )
			elseif self.bSkillMasteryKey
			then
				self:SkillMasteryUp( self.skills[3] )
			else
				self.abilities[2]:Use()
			end
		end
	end
	
	function PlayerChar:ButtonHoldAbility2( dt )
	
	end
	
	function PlayerChar:ButtonReleaseAbility2()
	
	end

	function PlayerChar:ButtonDownDodge()
		self:Dodge()
	end
	
	function PlayerChar:ButtonHoldDodge( dt )
		self:Dodge()
	end
	
	function PlayerChar:ButtonReleaseDodge()
	
	end
	
	function PlayerChar:ButtonDownUse()
		if self.activeInteractable
		then
			self.activeInteractable:Use()
		end
	end
	
	function PlayerChar:ButtonHoldUse( dt )
	
	end
	
	function PlayerChar:ButtonReleaseUse()
	
	end
	
	function PlayerChar:MouseAim( mx, my )
		self.aimVect = (Vector( mx, my ) - self:GetPosition()):normalized()
	end
	
	function PlayerChar:ButtonDownSkillRank()
		self.bSkillRankKey = true
	end
	
	function PlayerChar:ButtonHoldSkillRank( dt )
		self.bSkillRankKey = true
	end
	
	function PlayerChar:ButtonReleaseSkillRank()
		self.bSkillRankKey = false
	end
	
	function PlayerChar:ButtonDownSkillMastery()
		self.bSkillMasteryKey = true
	end
	
	function PlayerChar:ButtonHoldSkillMastery( dt )
		self.bSkillMasteryKey = true
	end
	
	function PlayerChar:ButtonReleaseSkillMastery()
		self.bSkillMasteryKey = false
	end
	
	
	function PlayerChar:CollideInteractable( interactable )
		if interactable ~= self.activeInteractable
		then
			if self.activeInteractable
			then
				self.activeInteractable.flags:Set( 'outline', self, false )
			end
			
			if interactable
			then
				interactable.flags:Set( 'outline', self, true )
			end
			
			self.activeInteractable = interactable
		end
	end
	
	function PlayerChar:OnDeath( killer )
		Entity.OnDeath( self, killer )
	end
	
	function PlayerChar:OnSkillMasteryUp( skill ) end
	
	function PlayerChar:OnSkillRankUp( skill ) end
	
	function PlayerChar:SkillMasteryUp( skill )
		if skill and self.curXP
		then
			if skill.mastery < 2 and skill.rank >= 4 and self.curXP >= 100
			then
				self.curXP = self.curXP - 100
				skill.mastery = 2
				self:OnSkillMasteryUp( skill )
			elseif skill.mastery < 3 and skill.rank >= 7 and self.curXP >= 200
			then
				self.curXP = self.curXP - 200
				skill.mastery = 3
				self:OnSkillMasteryUp( skill )
			elseif skill.mastery < 5 and skill.rank >= 10 and self.curXP >= 400
			then
				self.curXP = self.curXP - 400
				skill.mastery = 5
				self:OnSkillMasteryUp( skill )
			end
		end
	end
	
	function PlayerChar:SkillRankUp( skill )
		if skill and self.curXP and self.curXP >= (skill.rank + 1) * 10
		then
			self.curXP = self.curXP - ((skill.rank + 1) * 10)
			skill.rank = skill.rank + 1
			self:OnSkillRankUp( skill )
		end
	end
	
	function PlayerChar:Update( dt )
		Entity.Update( self, dt )
		
		local collisions = HC.collisions( self.collider )
		local pos = self:GetPosition()
		
		for other, sepVec in pairs( collisions )
		do
			if other.room and Game.CurLevel.activeRoom ~= other.room
			then
				if	(pos.x - self.radius >= other.room.position.x * Game.TileSize) and
					(pos.x + self.radius <= (other.room.position.x + other.room.width) * Game.TileSize) and
					(pos.y - self.radius >= other.room.position.y * Game.TileSize) and
					(pos.y + self.radius <= (other.room.position.y + other.room.height) * Game.TileSize)
				then
					other.room:Enter()
				end
			elseif other.corridor and Game.CurLevel.activeRoom
			then
				--Game.CurLevel.activeRoom:Exit()
			end
		end
	end
	
	function PlayerChar:Draw()
		Entity.Draw( self )
		
		local x, y = self.collider:center()
		GFX.setColor( 0, 0, 0, 192 )
		GFX.draw( self.label, x - 4, y - 20, 0, 0.4, 0.4 )
		
		if (not Input.KBM or Input.KBM.player.character ~= self) and
			(self.aimVect.x ~= 0 or self.aimVect.y ~= 0)
		then
			local aim = self.aimVect:normalized() * Game.TileSize * 5
			GFX.draw( Game.Images.cursor, x + aim.x - (Game.Images.cursor:getWidth() / 2), y + aim.y - (Game.Images.cursor:getHeight() / 2) )
		end
		
		--Attack/ability icons
		GFX.draw( Game.Images.player.icons, self.quads[1], x - 26, y + self.radius + 2 )
		GFX.draw( Game.Images.player.icons, self.quads[2], x - 8, y + self.radius + 2 )
		GFX.draw( Game.Images.player.icons, self.quads[3], x + 10, y + self.radius + 2 )
		
		
		-- Attack/ability cooldown animation
		GFX.setColor( 0, 0, 0, 96 )
		GFX.rectangle( 'fill', x - 26, y + self.radius + 18, 16, -16 * (self.abilities.attack.curCooldown / self.abilities.attack.cooldown) )
		GFX.rectangle( 'fill', x - 8, y + self.radius + 18, 16, -16 * (self.abilities[1].curCooldown / self.abilities[1].cooldown) )
		GFX.rectangle( 'fill', x + 10, y + self.radius + 18, 16, -16 * (self.abilities[2].curCooldown / self.abilities[2].cooldown) )
		
		local hpRatio = self.curHP / self:GetMaxHP()
		
		if hpRatio > 0.5
		then
			GFX.setColor( 255 * (2 + (hpRatio * -2)), 255, 0, 255 )
		else
			GFX.setColor( 255, 255 * hpRatio * 2, 0, 255 )
		end
		
		GFX.rectangle( "fill", x - self.radius, y - self.radius - 6, (self.curHP / self:GetMaxHP()) * self.radius * 2, 4 )
	end
	
	function PlayerChar:DrawUI()
		GFX.print( "HP: " .. self.curHP .. '/' .. self:GetMaxHP(), 16, 16 )
	
		GFX.print( "XP: " .. self.curXP, 16, 48 )
		GFX.print( "Skill Points: " .. ((self.curXP - (self.curXP % 10)) / 10), 16, 80 )
		
		local y = 116
		
		for idx, skill in ipairs( self.skills )
		do
			GFX.print( idx .. ': ' .. skill.name .. " -- " .. skill.rank .. '|' .. skill.mastery, 16, y )
			y = y + 32
		end

	end