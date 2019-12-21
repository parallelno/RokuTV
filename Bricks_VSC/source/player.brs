function CreatePlayer(_globalVars as object) as object
    obj = {
		type	: "player"
		globalVars	: _globalVars
		level		: invalid
		speed		: {x: 0.0, y: 0.0}
        playerWidth 		: invalid
        playerHeight 		: _globalVars.PLAYER_HEIGHT		
		playerWidthCode		: 0

        PLAYER_MOVE_CODE_RIGHT	: 1
        PLAYER_MOVE_CODE_LEFT	: 2

		Update    		: PlayerUpdate
		ControlListener	: PlayerControlListener
		Init			: PlayerInit
		Move			: PlayerMove
	}
	return obj
end function

function PlayerUpdate(_deltatime=0 as float, _position=invalid as object) as void
    if (m.active = false) return
	if _position <> invalid
    	m.position.x = _position.x
    	m.position.y = _position.y
    end if

	m.position.x += m.speed.x
	m.position.y += m.speed.y

' START. move it to collision manager		
	if (m.position.x > m.globalVars.GAME_FIELD_MAX_X - m.playerWidth * 0.5)
		m.position.x = m.globalVars.GAME_FIELD_MAX_X - m.playerWidth * 0.5
	end if

	if (m.position.x < m.globalVars.GAME_FIELD_MIN_X + m.playerWidth * 0.5)
		m.position.x = m.globalVars.GAME_FIELD_MIN_X + m.playerWidth * 0.5 
	end if
' END. move it to collision manager

	m.SpriteUpdate(_deltatime)
end function

function PlayerInit(_level)
	m.level = _level
	m.level.ControlListenerSet(m)

	m.playerWidth = m.globalVars.PLAYER_WIDTHS[m.playerWidthCode]
	m.position.x = m.globalVars.GAME_FIELD_MIN_X + m.globalVars.GAME_FIELD_WIDTH * 0.5
end function

function PlayerControlListener(_key as integer, _codes as object) as void
    if (m.active = false) return
	
    if (_key = _codes.BUTTON_LEFT_PRESSED)
		m.Move(m.PLAYER_MOVE_CODE_LEFT)
    endif
	if (_key = _codes.BUTTON_RIGHT_PRESSED)
		m.Move(m.PLAYER_MOVE_CODE_RIGHT)
	endif
end function

function PlayerMove(_playerMoveCode as Integer) as void
	if (_playerMoveCode = m.PLAYER_MOVE_CODE_RIGHT)
		m.speed.x = m.globalVars.PLAYER_START_SPEED
	end if
		if (_playerMoveCode = m.PLAYER_MOVE_CODE_LEFT)
		m.speed.x = -m.globalVars.PLAYER_START_SPEED
	end if
end function