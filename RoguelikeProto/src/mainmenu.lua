--[[
	Project: RoguelikeProto
	File: mainmenu.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 5/23/2016
--]]

MainMenu =
{
	MainWindow = nil,
	OptionsMenu = nil,
--	CharacterAnims = nil,

	numPlayers = 1,
	currentPlayer = 1,
}

function MainMenu:init()
	GFX.setBackgroundColor( 128, 128, 128 )
	GFX.setDefaultFilter( "nearest", "nearest", 0 )
	
	GUI.SetState( "Main Menu" )
	
	self:LoadAnims()
	
	self:CreateMainMenu()
	self:CreateCharacterSelect()
	self:CreateOptions()
end

function MainMenu:CreateMainMenu()
	local width = GFX.getWidth()

	self.MainWindow = GUI.Create( "frame" )
	self.MainWindow:SetName( "Main Menu" )
	self.MainWindow:SetSize( 256, 256 )
	self.MainWindow:Center()
	self.MainWindow:SetDraggable( false )
	self.MainWindow:ShowCloseButton( false )
	self.MainWindow:SetState( "Main Menu" )
	
	local playButton = GUI.Create( "button", self.MainWindow )
	playButton:SetSize( 246, 24 )
	playButton:CenterX()
	playButton:SetY( 30 )
	playButton:SetText( "Start Game" )
	playButton.OnClick = function()
		self.MainWindow:SetVisible( false )
		self.currentPlayer = 1
		self.CharacterSelect:UpdateName()
		self.CharacterSelect:SetVisible( true )
		self.CharacterSelect:MakeTop()
	end
	
	-- Eventually use love.joystickadded and more dynamic menu
	local numPlayerDisp = GUI.Create( "text", self.MainWindow )
	numPlayerDisp:SetY( 65 )
	numPlayerDisp.UpdateText = function( object )
		object:SetText( "Local Players: " .. self.numPlayers )
		object:CenterX()
	end
	numPlayerDisp:UpdateText()
	
	local leftButton = GUI.Create( "button", self.MainWindow )
	leftButton:SetSize( 24, 24 )
	leftButton:SetPos( 5, 60 )
	leftButton:SetText( "-" )
	leftButton.OnClick = function()
		self.numPlayers = math.max( 1, self.numPlayers - 1 )
		numPlayerDisp:UpdateText()
	end
	
	local rightButton = GUI.Create( "button", self.MainWindow )
	rightButton:SetSize( 24, 24 )
	rightButton:SetPos( 227, 60 )
	rightButton:SetText( "+" )
	rightButton.OnClick = function()
		self.numPlayers = math.min( #(Joystick.getJoysticks()) + 1, self.numPlayers + 1 )
		numPlayerDisp:UpdateText()
	end
	
	local optionsButton = GUI.Create( "button", self.MainWindow )
	optionsButton:SetSize( 246, 24 )
	optionsButton:CenterX()
	optionsButton:SetY( 90 )
	optionsButton:SetText( "Options" )
	optionsButton.OnClick = function()
		self.OptionsMenu:SetVisible( true )
		self.OptionsMenu:MakeTop()
	end
end

function MainMenu:CreateOptions()
	self.OptionsMenu = GUI.Create( "frame" )
	self.OptionsMenu:SetName( "Options" )
	self.OptionsMenu:SetSize( 512, 384 )
	self.OptionsMenu:Center()
	self.OptionsMenu:SetDraggable( false )
	self.OptionsMenu:SetVisible( false )
	self.OptionsMenu:SetState( "Main Menu" )
	self.OptionsMenu.OnClose = function()
		self.OptionsMenu:SetVisible( false )
		return false
	end
	
	local tabs = GUI.Create( "tabs", self.OptionsMenu )
	tabs:SetPos( 5, 30 )
	tabs:SetSize( 502, 349 )
	
	local gamePanel = GUI.Create( "panel" )
	--self:CreateGameTab( gamePanel )
	tabs:AddTab( "Games", gamePanel, "Games" )

	local audioPanel = GUI.Create( "panel" )
	--self:CreateAudioTab( audioPanel )
	tabs:AddTab( "Audio", audioPanel, "Audio" )
	
	local graphicsPanel = GUI.Create( "panel" )
	--self:CreateGraphicsTab( graphicsPanel )
	tabs:AddTab( "Graphics", graphicsPanel, "Graphics" )
	
	local miscPanel = GUI.Create( "panel" )
	tabs:AddTab( "Misc", miscPanel, "Misc" )
	self:CreateMiscTab( miscPanel )
end

function MainMenu:CreateMiscTab( miscPanel )
	local colors = { "HealText", "DamageText" }

	local colorsList = GUI.Create( "list", miscPanel )
	colorsList:SetPos( 0, 0 )
	colorsList:SetSize( 492, 314 )
	colorsList:SetPadding( 5 )
	colorsList:SetSpacing( 5 )
	
	for i, cName in ipairs( colors )
	do
		local colorButton = GUI.Create( "button", miscPanel )
		colorButton:SetText( cName )
		colorButton:SetSize( 445, 32 )
		colorButton.OnClick = function( self )
			
		end
		
		local colorBox = GUI.Create( "panel", miscPanel )
		colorBox:SetPos( 455, (37 * i) - 32 )
		colorBox:SetSize( 32, 32 )
		colorBox.Draw = function( object )
			GFX.setColor( Game.Colors[ cName ] )
			GFX.rectangle( "fill", object:GetX(), object:GetY(), object:GetWidth(), object:GetHeight() )
			GFX.setColor( 143, 143, 143, 255 )
			GFX.setLineWidth( 1 )
			GFX.setLineStyle( "smooth" )
			GFX.rectangle( "line", object:GetX(), object:GetY(), object:GetWidth(), object:GetHeight() )
		end
		
		colorsList:AddItem( colorButton )
	end
end

function MainMenu:CreateColorPickerWindow()

--[[
	local panel = GUI.Create( "panel" )
	panel:SetSize( 472, 128 )
	
	local colorBox = GUI.Create( "panel", panel )
	colorBox:SetPos( 472 - 64 - 5, 10 )
	colorBox:SetSize( 64, 64 )
	colorBox.Draw = function( object )
		GFX.setColor( Game.Colors[ cName ] )
		GFX.rectangle( "fill", object:GetX(), object:GetY(), object:GetWidth(), object:GetHeight() )
		GFX.setColor( 143, 143, 143, 255 )
		GFX.setLineWidth( 1 )
		GFX.setLineStyle( "smooth" )
		GFX.rectangle( "line", object:GetX(), object:GetY(), object:GetWidth(), object:GetHeight() )
	end
	
	local redSlider = GUI.Create( "slider", panel )
	redSlider:SetPos( 5, 25 )
	redSlider:SetWidth( 256 )
	redSlider:SetMax( 255 )
	redSlider:SetDecimals( 0 )
	redSlider:SetValue( color[1] )
	redSlider.OnValueChanged = function( object, value )
		color[1] = value
	end
	
	local redSliderName = GUI.Create( "text", panel )
	redSliderName:SetPos( 5, 5 )
	redSliderName:SetText( "Red" )
	
	local redSliderValue = GUI.Create( "text", panel )
	redSliderValue:SetPos( 236, 5 )
	redSliderValue.Update = function( object )
		object:SetText( redSlider:GetValue() )
	end
	
	local greenSlider = GUI.Create( "slider", panel )
	greenSlider:SetPos( 5, 180 )
	greenSlider:SetWidth( 256 )
	greenSlider:SetMax( 255 )
	greenSlider:SetDecimals( 0 )
	greenSlider:SetValue( color[2] )
	greenSlider.OnValueChanged = function( object, value )
		color[2] = value
	end
	
	local greenSliderName = GUI.Create( "text", panel )
	greenSliderName:SetPos( 5, 165 )
	greenSliderName:SetText( "Green" )
	
	local greenSliderValue = GUI.Create( "text", panel )
	greenSliderValue:SetPos( 470, 165 )
	greenSliderValue.Update = function( object )
		object:SetText( greenSlider:GetValue() )
	end
	
	local blueSlider = GUI.Create( "slider", panel )
	blueSlider:SetPos( 5, 210 )
	blueSlider:SetWidth( 256 )
	blueSlider:SetMax( 255 )
	blueSlider:SetDecimals( 0 )
	blueSlider:SetValue( color[3] )
	blueSlider.OnValueChanged = function( object, value )
		color[3] = value
	end
	
	local blueSliderName = GUI.Create( "text", panel )
	blueSliderName:SetPos( 5, 195 )
	blueSliderName:SetText( "Blue" )
	
	local blueSliderValue = GUI.Create( "text", panel )
	blueSliderValue:SetPos( 470, 195 )
	blueSliderValue.Update = function( object )
		object:SetText( blueSlider:GetValue() )
	end
	--]]
end

function MainMenu:CreateCharacterSelect()
	self.CharacterSelect = GUI.Create( "frame" )
	self.CharacterSelect:SetName( "Character Select" )
	self.CharacterSelect:SetSize( 256, 256 )
	self.CharacterSelect:Center()
	self.CharacterSelect:SetVisible( false )
	self.CharacterSelect:SetDraggable( false )
	self.CharacterSelect:ShowCloseButton( false )
	self.CharacterSelect:SetState( "Main Menu" )
	self.CharacterSelect.UpdateName = function( object )
		object:SetName( "Player " .. self.currentPlayer )
	end
	
	local list = loveframes.Create( "list", self.CharacterSelect )
	list:SetPos( 8, 30 )
	list:SetSize( 240, 190 )
	list:SetPadding( 5 )
	list:SetSpacing( 5 )
	
	for _, char in pairs( Game.Characters )
	do
		local button = loveframes.Create( "button", self.CharacterSelect )
		button:SetHeight( 25 )
		button:SetText( char.name )
		button.OnClick = function()
			local c = char()
			
			if (self.currentPlayer >= self.numPlayers)
			then
				Gamestate.switch( Game )
				GUI.SetState( "none" )
			else
				self.currentPlayer = self.currentPlayer + 1
				self.CharacterSelect:UpdateName()
			end
		end
		
		list:AddItem( button )
	end
	
	local back = GUI.Create( "button", self.CharacterSelect )
	back:SetSize( 128, 20 )
	back:CenterX()
	back:SetY( 226 )
	back:SetText( "Back" )
	back.OnClick = function()
		if (self.currentPlayer > 1)
		then
			self.currentPlayer = self.currentPlayer - 1
			self.CharacterSelect:UpdateName()
		else
			self.CharacterSelect:SetVisible( false )
			self.MainWindow:SetVisible( true )
			self.MainWindow:MakeTop()
		end
	end
end

function MainMenu:UpdateCharacterSelection( panel, dir )



end

function MainMenu:LoadAnims()
--[[
	self.CharacterAnims = {}

	for _, char in pairs( Game.Characters )
	do
		local c = char
		
		self.CharacterAnims[char] = {}
		self.CharacterAnims[char].spritesheet = c.spritesheet

		local w = c.spritesheet:getWidth()
		local h = c.spritesheet:getHeight()
		local g = Anim8.newGrid( c.width, c.height, w, h )

		local data = c.animData.idle
	
		if (data.w or data.h)
		then
			g = Anim8.newGrid( data.w or c.width, data.h or c.height, w, h )
		else
			g = Anim8.newGrid( c.width, c.height, w, h )
		end
		
		self.CharacterAnims[char].animation = Anim8.newAnimation( g( unpack( data.grid ) ), data.durations )
		
		if (data.offset)
		then
			self.CharacterAnims[char].animation.animOffset = data.offset
		end
	end
	
	collectgarbage()
--]]
end

function MainMenu:update( dt )
	--update character animations
	--self.animations[self.currentAnimation]:update( dt )
end

function MainMenu:draw()
--[[
	--draw character animations
	local animOffset = self.animations[self.currentAnimation].animOffset or Vector( 0, 0 )
	
	self.animations[self.currentAnimation]:draw( self.spritesheet, self.position.x, self.position.y, 0, self.face, 1, animOffset.x, animOffset.y )
--]]
end