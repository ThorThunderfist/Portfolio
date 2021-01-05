--[[
	Project: Dimensional Platformer
	File: inputmanager.lua
	Author: David "Thor Thunderfist" Hack
	
	"controller" parameters come in as Love Joystick objects
	Controller "axis" and "button" parameters use Love Gamepad implementation
--]]

Input = {}
	
	function Input.RegisterPlayer( player )
		Input.Gamepad = { player = player }
		
		Input.Gamepad['leftx']			= { AxisUpdate = player.AxisUpdateLeftX, value = 0 }
		Input.Gamepad['lefty']			= { AxisUpdate = player.AxisUpdateLeftY, value = 0 }
		
		Input.Gamepad['rightx']			= { AxisUpdate = player.AxisUpdateRightX, value = 0 }
		Input.Gamepad['righty']			= { AxisUpdate = player.AxisUpdateRightY, value = 0 }
		
		Input.Gamepad['triggerleft']	= { AxisUpdate = player.AxisUpdateMap, value = 0 }
		
		Input.Gamepad['dpup']			= { ButtonPress = player.ButtonDownUp,				ButtonRelease = player.ButtonReleaseUp,				Hold = player.ButtonHoldUp }
		Input.Gamepad['dpleft']			= { ButtonPress = player.ButtonDownLeft,			ButtonRelease = player.ButtonReleaseLeft,			Hold = player.ButtonHoldLeft }
		Input.Gamepad['dpdown']			= { ButtonPress = player.ButtonDownDown,			ButtonRelease = player.ButtonReleaseDown,			Hold = player.ButtonHoldDown }
		Input.Gamepad['dpright']		= { ButtonPress = player.ButtonDownRight,			ButtonRelease = player.ButtonReleaseRight,			Hold = player.ButtonHoldRight }
		
		Input.Gamepad['a']				= { ButtonPress = player.ButtonDownJump,			ButtonRelease = player.ButtonReleaseJump,			Hold = player.ButtonHoldJump }
		Input.Gamepad['x']				= { ButtonPress = player.ButtonDownDash,			ButtonRelease = player.ButtonReleaseDash,			Hold = player.ButtonHoldDash }
		Input.Gamepad['y']				= { ButtonPress = player.ButtonDownUse,				ButtonRelease = player.ButtonReleaseUse,			Hold = player.ButtonHoldUse }
		
		Input.Gamepad['leftshoulder']	= { ButtonPress = player.ButtonDownToggleAstral,	ButtonRelease = player.ButtonReleaseToggleAstral,	Hold = player.ButtonHoldToggleAstral }
		Input.Gamepad['rightshoulder']	= { ButtonPress = player.ButtonDownToggleShadow,	ButtonRelease = player.ButtonReleaseToggleShadow,	Hold = player.ButtonHoldToggleShadow }
		
		
		Input.KBM = { player = player }
		
		Input.KBM['up']				= { KeyPress = player.ButtonDownUp,				KeyRelease = player.ButtonReleaseUp,			Hold = player.ButtonHoldUp }
		Input.KBM['w'] = Input.KBM['up']
		
		Input.KBM['left']			= { KeyPress = player.ButtonDownLeft,			KeyRelease = player.ButtonReleaseLeft,			Hold = player.ButtonHoldLeft }
		Input.KBM['a'] = Input.KBM['left']
		
		Input.KBM['down']			= { KeyPress = player.ButtonDownDown,			KeyRelease = player.ButtonReleaseDown,			Hold = player.ButtonHoldDown }
		Input.KBM['s'] = Input.KBM['down']
		
		Input.KBM['right']			= { KeyPress = player.ButtonDownRight,			KeyRelease = player.ButtonReleaseRight,			Hold = player.ButtonHoldRight }
		Input.KBM['d'] = Input.KBM['right']
		
		Input.KBM['space']			= { KeyPress = player.ButtonDownUse,			KeyRelease = player.ButtonReleaseUse,			Hold = player.ButtonHoldUse }
		
		Input.KBM['z']				= { KeyPress = player.ButtonDownJump,			KeyRelease = player.ButtonReleaseJump,			Hold = player.ButtonHoldJump }
		Input.KBM['x']				= { KeyPress = player.ButtonDownDash,			KeyRelease = player.ButtonReleaseDash,			Hold = player.ButtonHoldDash }
		
		Input.KBM['1']				= { KeyPress = player.ButtonDownToggleAstral,	KeyRelease = player.ButtonReleaseToggleAstral,	Hold = player.ButtonHoldToggleAstral }
		Input.KBM['2']				= { KeyPress = player.ButtonDownToggleShadow,	KeyRelease = player.ButtonReleaseToggleShadow,	Hold = player.ButtonHoldToggleShadow }
	end
	
	function Input.Update( dt )
		for _, button in pairs( Input.Gamepad )
		do
			if button.down and button.Hold
			then
				button.Hold( Input.Gamepad.player, dt )
			end
		end
		
		for _, button in pairs( Input.KBM )
		do
			if button.down and button.Hold
			then
				button.Hold( Input.KBM.player, dt )
			end
		end
	end
	
	function Input.DeadzoneCorrection( x, y )
		-- deadzone calculation (let players set this?)
		local inDZ = 0.25
		local outDZ = 0.1
		local l = math.sqrt( x * x + y * y )
		
		if l <= inDZ
		then
			x, y = 0, 0
		elseif l + outDZ >= 1
		then
			x, y = x / l, y / l
		else
			l = (l - inDZ) / (1 - inDZ - outDZ)
			x, y = x * l, y * l
		end
		
		return x, y
	end
	
	--------------------------
	-- Input Event Callbacks
	--------------------------
	function Input.ControllerAdded( controller )	end

	function Input.ControllerAxis( axis, value )
		if Input.Gamepad and Input.Gamepad[axis] and Input.Gamepad[axis].AxisUpdate
		then
			local oldValue = Input.Gamepad[axis].value
			Input.Gamepad[axis].value = value
			Input.Gamepad[axis].AxisUpdate( Input.Gamepad.player, value, oldValue )
		end
	end

	function Input.ControllerPressed( button )
		if Input.Gamepad and Input.Gamepad[button] and Input.Gamepad[button].ButtonPress
		then
			Input.Gamepad[button].down = true
			Input.Gamepad[button].ButtonPress( Input.Gamepad.player )
		end
	end

	function Input.ControllerReleased( button )
		if Input.Gamepad and Input.Gamepad[button] and Input.Gamepad[button].ButtonRelease
		then
			Input.Gamepad[button].down = false
			Input.Gamepad[button].ButtonRelease( Input.Gamepad.player )
		end
	end

	function Input.ControllerRemoved( controller )	end

	function Input.KeyPressed( key )
		if Input.KBM and Input.KBM[key] and Input.KBM[key].KeyPress
		then
			Input.KBM[key].down = true
			Input.KBM[key].KeyPress( Input.KBM.player )
		end
	end

	function Input.KeyReleased( key )
		if Input.KBM and Input.KBM[key] and Input.KBM[key].KeyRelease
		then
			Input.KBM[key].down = false
			Input.KBM[key].KeyRelease( Input.KBM.player )
		end

	end

	function Input.MousePressed( x, y, mb )
		if Input.KBM and Input.KBM[mb] and Input.KBM[mb].MousePress
		then
			Input.KBM[mb].down = true
			Input.KBM[mb].MousePress( Input.KBM.player, x, y )
		end
	end

	function Input.MouseReleased( x, y, mb )
		if Input.KBM and Input.KBM[mb] and Input.KBM[mb].MouseRelease
		then
			Input.KBM[mb].down = false
			Input.KBM[mb].MouseRelease( Input.KBM.player, x, y )
		end
	end
	
	function Input.WheelMoved( x, y )	end