--[[
	Project: Dimensional Platformer
	File: game.lua
	Author: David "Thor Thunderfist" Hack
--]]

Game =
{
	TileSize = 16,
	
	Fonts =
	{
		default	= GFX.newFont( "assets/fonts/slkscr.ttf", 32 ),
		bold	= GFX.newFont( "assets/fonts/slkscrb.ttf", 32 )
	},
	
	Shaders = {},
	
	Colors = {},
	Audio = {},
	Images = {},
	
	Rooms = {},
	Room = nil,
	
	Input = nil,
	
	Player = nil,
	
	Characters = {},
	Enemies = {},
	
	Cam = nil,

	init = function( self )
		self.FrameTime = 1/60
		self.AccumTime = 0
		self.Frame = 0
		
		self.Fonts.default:setFilter( 'nearest', 'nearest' )
		self.Fonts.bold:setFilter( 'nearest', 'nearest' )
		
		local cursorData = Game.Images.cursor
		self.cursor = Mouse.newCursor( cursorData, (cursorData:getWidth() / 2),  (cursorData:getHeight() / 2) )
		Mouse.setCursor( self.cursor )
		
		GFX.setBackgroundColor( 0.5, 0.5, 0.5 )
		GFX.setDefaultFilter( 'nearest', 'nearest', 0 )
		
		-- Set up camera
		self.Cam = Camera( 0, 0 )
		self.Cam:zoomTo(1)
		self.Cam.smoother = Camera.smooth.damped( 30 )

		self.Plane = 'prime'
		
		self.Collision = Bump.newWorld(64)
		
		Game.Player = PlayerChar()
		
		self.Room = self.Rooms.hub.hub_0_0()
		self.Room:Enter(1)
		self.Cam.x = self.Room.width * Game.TileSize / 2
		self.Cam.y = self.Room.height * Game.TileSize / 2
	end
}

	function Game:NextRoom( room, entrance )
		self.Room:Exit()
		self.Room = room
		self.Room:Enter( entrance )
	end

	function Game:UpdatePlayer( dt )
		local x, y = 0, 0
	
		Game.Player:Update( dt )
		
		if Game.Player.dead
		then
			self.Room:Restart()
			Game.Player.dead = false
		else
			local position = Game.Player:GetCenter()
			self.Cam:lockPosition( self.Room.width * Game.TileSize / 2, self.Room.height * Game.TileSize / 2 )
		end
	end
	
	function Game:update( dt )
		self.AccumTime = self.AccumTime + dt
		
		Timer.update( dt )
		Input.Update( dt )
		
		while self.AccumTime > self.FrameTime
		do
			self.Frame = self.Frame + 1
			self.AccumTime = self.AccumTime - self.FrameTime
			
			self:UpdatePlayer( self.FrameTime )
			self.Room:Update( self.FrameTime )
		end
	end

	function Game:draw()
		GFX.setLineWidth( 1 )
	
		self.Cam:attach()
			self.Room:Draw()
		self.Cam:detach()
		
		Game.Player:DrawUI()
		
		self.Room:DrawUI()
	end
	
	function Game:gamepadaxis( controller, axis, value )
		Input.ControllerAxis( axis, value )
	end

	function Game:gamepadpressed( controller, button )
		Input.ControllerPressed( button )
	end

	function Game:gamepadreleased( controller, button )
		Input.ControllerReleased( button )
	end

	function Game:joystickadded( controller )
		Input.ControllerAdded( controller )
	end

	function Game:joystickremoved( controller )
		Input.ControllerRemoved( controller )
	end
	
	function Game:keypressed( key )
		Input.KeyPressed( key )
		
		if bDebug and Keyboard.isDown( 'lshift' ) and Keyboard.isDown( 'lctrl' )
		then
			local mx, my = Game.Cam:mousePosition()
			
			if key == 'f1'
			then
				print( Vector( mx, my ) )
				print( Game.Room:ToTileCoords( Vector( mx, my ) ) )
			elseif key == 'f2'
			then
			elseif key == 'f3'
			then
				print( Vector( mx, my ) )
				Game.Player:SetPosition( Vector( mx, my ) )
			elseif key == 'f4'
			then

			elseif key == 'f5'
			then
				Game.Room:Generate()
				Game.Room:Start()
			elseif key == 'f6'
			then
				
			elseif key == 'f7'
			then
			
			elseif key == 'f8'
			then
				Game.Room.SpawnEnemies()
			end
		end
	end

	function Game:keyreleased( key )
		Input.KeyReleased( key )
	end

	function Game:mousepressed( x, y, mb )
		Input.MousePressed( x, y, mb )
		
		if bDebug
		then
			if mb == 3
			then
				self.Cam:zoomTo( 1 )
			end
		end
	end

	function Game:mousereleased( x, y, mb )
		Input.MouseReleased( x, y, mb )
	end

	function Game:wheelmoved( x, y )
		Input.WheelMoved( x, y )
		
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
			local info = FileIO.getInfo( dir .. '/' .. v )
			
			if info and info.type == 'directory'
			then
				t[v] = {}
				recurseLoadImages( t[v], dir .. '/' .. v )
			else
				idx = string.gsub( v, "%..*$", '' )
				idx = tonumber( idx ) or idx
				t[idx] = IMG.newImageData( dir .. '/' .. v )
				--t[idx]:setFilter( 'nearest', 'nearest' )
			end
		end
	end

	local function recurseLoadAudio( t, dir )
		local enum = FileIO.getDirectoryItems( dir )
		local idx = ''

		for _, v in ipairs( enum )
		do
			local info = FileIO.getInfo( dir .. '/' .. v )
			
			if info and info.type == 'directory'
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

	Game.Characters		= require.tree( "src/characters" )
	Game.Enemies		= require.tree( "src/enemies" )
	Game.Rooms			= require.tree( "src/rooms" )
	Game.Interactables	= require.tree( "src/interactables" )