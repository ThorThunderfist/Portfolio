--[[
	Project: RoguelikeProto
	File: game.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 11/4/2016
--]]

Game =
{
	TileSize = 48,
	LevelIndex = 0,

	Difficulty = 0,
	
	Fonts =
	{
		default	= GFX.newFont( "assets/fonts/slkscr.ttf", 32 ),
		bold	= GFX.newFont( "assets/fonts/slkscrb.ttf", 32 )
	},
	
	Shaders =
	{
		rainbow = GFX.newShader( "src/shader/rainbow.glsl" ),
	},
	
	Colors =
	{
		HealText			= { 0, 255, 0 },
		PlayerDamageText	= { 255, 0, 0 },
		EnemyDamageText		= { 255, 255, 255 }
	},
	
	Audio = {},
	Images = {},
	
	Levels = {},
	World = {},
	CurLevel = nil,
	
	Input = nil,
	
	ActivePlayers = {},
	
	Characters = {},
	Enemies = {},
	
	Affixes = {},
	Items = {},
	
	PopTexts = {},
	
	Cam = nil,

	init = function( self )
		min_dt = 1/60
		next_time = love.timer.getTime()
		
		self.Time = 0
		
		self.Fonts.default:setFilter( 'nearest', 'nearest' )
		self.Fonts.bold:setFilter( 'nearest', 'nearest' )
		
		local cursorData = Game.Images.cursor:getData()
		self.cursor = Mouse.newCursor( cursorData, (cursorData:getWidth() / 2),  (cursorData:getHeight() / 2) )
		
		GFX.setBackgroundColor( 128, 128, 128 )
		GFX.setDefaultFilter( 'nearest', 'nearest', 0 )
		
		self:GenerateHub()
		
		self.CurLevel = self.World.Hub
		self.CurLevel:Start()
		
		-- Set up camera
		self.Cam = Camera( self.CurLevel.width * self.TileSize / 2, self.CurLevel.height * self.TileSize / 2, 0.75 )
	end
}

	function Game:GenerateHub()
		self.World.Hub = self.Levels.hub()
		self.World.Hub:Generate()
	end

	function Game:GenerateWorld( level )
		for i = 1,1
		do
			self.World[i] = level()
			self.World[i]:Generate()
		end
	end

	function Game:NextLevel()
		self.CurLevel:ClearCollision()
		
		self.LevelIndex = self.LevelIndex + 1
		
		if self.LevelIndex > #self.World
		then
			self.LevelIndex = 1
		end
		
		self.CurLevel = self.World[self.LevelIndex]
		self.CurLevel:Start()
	end

	function Game:PopText( text, position, color )
		table.insert( self.PopTexts, PopText( text, position, color ) )
	end

	function Game:SpawnPlayer( controller )
		local p = Player( controller )
		p.character = Game.Characters.minotaur( Vector( Game.CurLevel.width / 2, Game.CurLevel.height / 2 ) )
		
		for _, skill in ipairs( p.character.skills )
		do
			p.character:OnSkillRankUp( skill )
			p.character:OnSkillMasteryUp( skill )
		end
		
		if self.CurLevel:is_a( self.World.Hub )
		then
			local tile = self.CurLevel:GetSpawnTile()
			local pos = self.CurLevel:ToWorldCoords( tile.position )
			p:SetPosition( pos.x, pos.y )
		else
			p:SetPosition( 160, 80 )
		end
		
		table.insert( Game.ActivePlayers, p )
	end
	
	function Game:UpdatePlayers( dt )
		local midX, midY = 0, 0
	
		for idx = #Game.ActivePlayers, 1, -1
		do
			Game.ActivePlayers[idx]:Update( dt )
			
			if Game.ActivePlayers[idx].bDead
			then
				Game.ActivePlayers.Dead[idx] = p
				table.remove( Game.ActivePlayers, idx )
			else
				local position = Game.ActivePlayers[idx]:GetPosition()
				midX = midX + position.x
				midY = midY + position.y
			end
		end
		
		return midX, midY
	end
	
	function Game:update( dt )
		self.Time = self.Time + dt
		
		Timer.update( dt )
		
		Game.Shaders.rainbow:send( 'time', (self.Time % 2) / 2)
		
		Input.Update( dt )
		
		if #Game.ActivePlayers == 0
		then
			
		else
			next_time = next_time + min_dt

			local midX, midY = self:UpdatePlayers( dt )
			
			if #Game.ActivePlayers == 0
			then
				Gamestate.switch( MainMenu )
				GUI.SetState( "Main Menu" )
			end
			
			self.CurLevel:Update( dt )
			
			idx = 1
			
			for idx = #self.PopTexts, 1, -1
			do
				self.PopTexts[idx]:Update( dt )
				
				if (self.PopTexts[idx].life <= 0)
				then
					table.remove( self.PopTexts, idx )
				end
			end
			
			midX = midX / #Game.ActivePlayers
			midY = midY / #Game.ActivePlayers
			
			local dx = (midX - self.Cam.x) ^ 2
			local dy = (midY - self.Cam.y) ^ 2
			
			if midX < self.Cam.x
			then
				dx = dx * -1
			end
			
			if midY < self.Cam.y
			then
				dy = dy * -1
			end
			
			self.Cam:move( math.floor( Lerp( 0, dx, dt / 10 ) ), math.floor( Lerp( 0, dy, dt / 10 ) ) )
			
			local width, height = self.CurLevel.width * self.TileSize, self.CurLevel.height * self.TileSize
			local camW, camH = GFX.getWidth() / self.Cam.scale, GFX.getHeight() / self.Cam.scale
			
			self.Cam.x = math.max( self.Cam.x, camW / 2 )
			self.Cam.x = math.min( self.Cam.x, width - (camW / 2) )
			
			self.Cam.y = math.max( self.Cam.y, camH / 2 )
			self.Cam.y = math.min( self.Cam.y, height - (camH / 2) )
		end
	end

	function Game:draw()
		GFX.setLineWidth( 1 )
	
		self.Cam:attach()
			self.CurLevel:Draw()
		self.Cam:detach()
		
		for i = 1, #Game.ActivePlayers
		do
			if Game.ActivePlayers[i]
			then
				Game.ActivePlayers[i]:DrawUI()
			end
		end
		
		for _, text in ipairs( self.PopTexts )
		do
			text:DrawUI()
		end
		
		self.CurLevel:DrawUI()
		
		local cur_time = love.timer.getTime()
		if next_time <= cur_time then
			next_time = cur_time
			return
		end
		--love.timer.sleep(next_time - cur_time)
	end
	
	function Game:gamepadaxis( controller, axis, value )
		Input.ControllerAxis( controller, axis, value )
	end

	function Game:gamepadpressed( controller, button )
		if Input[controller]
		then
			Input.ControllerPressed( controller, button )
		else
			if button == 'start'
			then
				self:SpawnPlayer( controller )
			end
		end
	end

	function Game:gamepadreleased( controller, button )
		if Input[controller]
		then
			Input.ControllerReleased( controller, button )
		end
	end

	function Game:joystickadded( controller )
		Input.ControllerAdded( controller )
	end

	function Game:joystickremoved( controller )
		Input.ControllerRemoved( controller )
	end
	
	function Game:keypressed( key )
		if Input.KBM
		then
			Input.KeyPressed( key )
		else
			if key == 'space'
			then
				self:SpawnPlayer()
			end
		end
		
		if bDebug and Keyboard.isDown( 'lshift' ) and Keyboard.isDown( 'lctrl' )
		then
			local mx, my = Game.Cam:mousePosition()
			my = my - (Game.CurLevel.wallHeight * Game.TileSize)
			
			if key == 'f1'
			then
				print( Vector( mx, my ) )
				print( Game.CurLevel:ToTileCoords( Vector( mx, my ) ) )
			elseif key == 'f2'
			then
				for _, player in ipairs( Game.ActivePlayers )
				do
					player.character.curXP = 5000
				end
			elseif key == 'f3'
			then
				for _, player in ipairs( Game.ActivePlayers )
				do
					player:SetPosition( Vector( mx, my ) )
				end
			elseif key == 'f4'
			then

			elseif key == 'f5'
			then
				Game.CurLevel:Generate()
				Game.CurLevel:Start()
			elseif key == 'f6'
			then
				
			elseif key == 'f7'
			then
			
			elseif key == 'f8'
			then
				Game.CurLevel.activeRoom:SpawnEnemies()
			end
		end
	end

	function Game:keyreleased( key )
		if Input.KBM
		then
			Input.KeyReleased( key )
		end
	end

	function Game:mousepressed( x, y, mb )
		if Input.KBM
		then
			Input.MousePressed( x, y, mb )
		end
		
		if bDebug
		then
			if mb == 3
			then
				self.Cam.scale = 0.75
			end
		end
	end

	function Game:mousereleased( x, y, mb )
		if Input.KBM
		then
			Input.MouseReleased( x, y, mb )
		end
	end

	function Game:wheelmoved( x, y )
		if Input.KBM
		then
			Input.WheelMoved( x, y )
		end
		
		if bDebug
		then
			if y > 0
			then
				self.Cam.scale = self.Cam.scale + 0.1
				self.Cam.scale = math.min( self.Cam.scale, 3 )
			end
			
			if y < 0
			then
				self.Cam.scale = self.Cam.scale - 0.1
				--self.Cam.scale = math.max( self.Cam.scale, 1 )
			end
		end
	end
	
	
	local function recurseLoadImages( t, dir )
		local enum = FileIO.getDirectoryItems( dir )
		local idx = ''

		for _, v in ipairs( enum )
		do
			if (FileIO.isDirectory( dir .. '/' .. v ))
			then
				t[v] = {}
				recurseLoadImages( t[v], dir .. '/' .. v )
			else
				idx = string.gsub( v, "%..*$", '' )
				idx = tonumber( idx ) or idx
				t[idx] = GFX.newImage( dir .. '/' .. v )
				t[idx]:setFilter( 'nearest', 'nearest' )
			end
		end
	end

	local function recurseLoadAudio( t, dir )
		local enum = FileIO.getDirectoryItems( dir )
		local idx = ''

		for _, v in ipairs( enum )
		do
			if (FileIO.isDirectory( dir .. '/' .. v ))
			then
				t[v] = {}
				recurseLoadAudio( t[v], dir .. '/' .. v )
			else
				idx = string.gsub( v, "%..*$", '' )
				t[idx] = SFX.newSource( dir .. '/' .. v, "static" )
			end
		end
	end

	recurseLoadImages( Game.Images, "assets/img" )
	recurseLoadAudio( Game.Audio, "assets/audio" )

	Game.Affixes		= require.tree( "src/affixes" )
	Game.Characters		= require.tree( "src/characters" )
	Game.Enemies		= require.tree( "src/enemies" )
	Game.Levels			= require.tree( "src/levels" )
	Game.Interactables	= require.tree( "src/interactables" )
	Game.Items			= require.tree( "src/items" )