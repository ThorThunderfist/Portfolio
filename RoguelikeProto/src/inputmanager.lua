--[[
	Project: RoguelikeProto
	File: inputmanager.lua
	Author: David "Thor Thunderfist" Hack
	Last Edited: 11/1/2016
	
	"controller" parameters come in as Love Joystick objects
	Controller "axis" and "button" parameters use Love Gamepad implementation
--]]

Input = {}
	
	function Input.RegisterPlayer( player, controller )
		local playerMap = { player = player }
	
		if controller
		then
			playerMap['left']			= { x = 0, y = 0 }
			playerMap['move']			= playerMap['left']
			
			playerMap['right']			= { x = 0, y = 0 }
			playerMap['aim']			= playerMap['right']
			
			playerMap['a']				= { ButtonPress = player.ButtonDownUse,			ButtonRelease = player.ButtonReleaseUse,		Hold = player.ButtonHoldUse }
			
			playerMap['rightshoulder']	= { ButtonPress = player.ButtonDownAttack,		ButtonRelease = player.ButtonReleaseAttack,		Hold = player.ButtonHoldAttack }
			
			playerMap['back']			= { ButtonPress = player.ButtonDownSkillUp,		ButtonRelease = player.ButtonReleaseSkillUp,	Hold = player.ButtonHoldSkillUp }
			
			Input[controller] = playerMap
		else
			playerMap['w']		= { KeyPress = player.ButtonDownMoveUp,			KeyRelease = player.ButtonReleaseMoveUp }
			playerMap['a']		= { KeyPress = player.ButtonDownMoveLeft,		KeyRelease = player.ButtonReleaseMoveLeft }
			playerMap['s']		= { KeyPress = player.ButtonDownMoveDown,		KeyRelease = player.ButtonReleaseMoveDown }
			playerMap['d']		= { KeyPress = player.ButtonDownMoveRight,		KeyRelease = player.ButtonReleaseMoveRight }
			
			playerMap['e']		= { KeyPress = player.ButtonDownUse,			KeyRelease = player.ButtonReleaseUse,			Hold = player.ButtonHoldUse }
			
			playerMap[1]		= { MousePress = player.ButtonDownAttack,		MouseRelease = player.ButtonReleaseAttack,		Hold = player.ButtonHoldAttack }
			playerMap['1']		= { KeyPress = player.ButtonDownAbility1,		KeyRelease = player.ButtonReleaseAbility1,		Hold = player.ButtonHoldAbility1 }
			playerMap['2']		= { KeyPress = player.ButtonDownAbility2,		KeyRelease = player.ButtonReleaseAbility2,		Hold = player.ButtonHoldAbility2 }
			
			playerMap['space']	= { KeyPress = player.ButtonDownDodge,			KeyRelease = player.ButtonReleaseDodge,			Hold = player.ButtonHoldDodge }
			
			playerMap['lctrl']	= { KeyPress = player.ButtonDownSkillRank,		KeyRelease = player.ButtonReleaseSkillRank,		Hold = player.ButtonHoldSkillRank }
			playerMap['lshift']	= { KeyPress = player.ButtonDownSkillMastery,	KeyRelease = player.ButtonReleaseSkillMastery,	Hold = player.ButtonHoldSkillMastery }
			
			Input.KBM = playerMap
		end
	end
	
	function Input.Update( dt )
		local x, y
	
		if Input.KBM and Input.KBM.player
		then
			x, y = Game.Cam:mousePosition()
			Input.KBM.player:MouseAim( x, y - (Game.CurLevel.wallHeight * Game.TileSize) )
		end
		
		for _, map in pairs( Input )
		do
			if type( map ) == 'table' and map.player
			then
				if map ~= Input.KBM
				then
					x, y = Input.DeadzoneCorrection( map.move.x, map.move.y )
					map.player:MoveAxis( x, y )
					
					x, y = Input.DeadzoneCorrection( map.aim.x, map.aim.y )
					map.player:AimAxis( x, y )
				end
			
				for _, button in pairs( map )
				do
					if button.down and button.Hold
					then
						button.Hold( map.player, dt )
					end
				end
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
	function Input.ControllerAdded( controller )
		Input[controller] = {}
	end

	function Input.ControllerAxis( controller, axis, value )
		if Input[controller]
		then
			if axis == "leftx"
			then
				Input[controller].left.x = value
			elseif axis == "lefty"
			then
				Input[controller].left.y = value
			elseif axis == "rightx"
			then
				Input[controller].right.x = value
			elseif axis == "righty"
			then
				Input[controller].right.y = value
			end
		end
	end

	function Input.ControllerPressed( controller, button )
		if Input[controller] and Input[controller][button] and Input[controller][button].ButtonPress
		then
			Input[controller][button].down = true
			Input[controller][button].ButtonPress( Input[controller].player )
		end
	end

	function Input.ControllerReleased( controller, button )
		if Input[controller] and Input[controller][button] and Input[controller][button].ButtonRelease
		then
			Input[controller][button].down = false
			Input[controller][button].ButtonRelease( Input[controller].player )
		end
	end

	function Input.ControllerRemoved( controller )
		Input[controller] = nil
	end

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