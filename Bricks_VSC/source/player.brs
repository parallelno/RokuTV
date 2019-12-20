function PlayerUpdate(_deltatime=0 as float, _position=invalid as object) as void
    if (m.active = false) return
	if _position <> invalid
    	m.position.x = _position.x
    	m.position.y = _position.y
    end if
	
	m.position.y = m.time * 5 + 200
	m.position.x = 500

	m.SpriteUpdate(_deltatime)
end function

function PlayerControlListener(_key as integer, _codes as object) as void
    if (m.active = false) return
	
    if (_key = _codes.BUTTON_LEFT_PRESSED)
'		player.Move(GAME_VARS.PLAYER_MOVE_CODE_LEFT)
		print "BUTTON_LEFT_PRESSED"
    endif
	if (id = codes.BUTTON_RIGHT_PRESSED)
'		player.Move(GAME_VARS.PLAYER_MOVE_CODE_RIGHT)
		print "PLAYER_MOVE_CODE_RIGHT"
	endif	
	
	m.position.y = m.time * 5 + 200
	m.position.x = 500
end function