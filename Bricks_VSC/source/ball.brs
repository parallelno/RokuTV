function CreateBall(_globalVars as object) as object
    obj = {
		type	: "ball"
		globalVars	: _globalVars
        id			: "" 'unique number (as a string) in scope of level. it will be assiged by LevelLoader and LevelAddGameObject
		level		: invalid
		speed		: {x: 0.0, y: 0.0}
        ballRadiusCode	: 0
        ballRadius  : invalid
        status      : invalid
        STATUS_RUN     : 0
        STATUS_STICK   : 1
        STATUS_RELEASED: 2
        STICK_POSITION_OFFSET_Y : -25
        BALL_START_SPEED	: 5.0
        BALL_RADIUSES		: [10.0, 20.0, 40.0]

        player         : invalid

		Init			: BallInit
		Update    		: BallUpdate
        ControlListener	: BallControlListener
	}
	return obj
end function

function BallUpdate(_deltatime=0 as float, _position=invalid as object) as void
    if (m.active = false) return
	if _position <> invalid
    	m.position.x = _position.x
    	m.position.y = _position.y
    end if

    if m.status = m.STATUS_RUN
	    m.position.x += m.speed.x
	    m.position.y += m.speed.y
    end if

    if m.status = m.STATUS_STICK
        m.position.x = m.player.position.x
        m.position.y = m.player.position.y + m.STICK_POSITION_OFFSET_Y
    end if

    if m.status = m.STATUS_RELEASED
        m.status = m.STATUS_RUN
        if m.player.speed.x <> 0
            m.speed.x = Sgn(m.player.speed.x) * m.BALL_START_SPEED
        else
            m.speed.x = Sgn(Rnd(10000)-5000) * m.BALL_START_SPEED
        end if
        m.speed.y = -m.BALL_START_SPEED
        m.position.y = m.player.position.y + m.STICK_POSITION_OFFSET_Y
    end if

' START. move it to collision manager		
	if ((m.position.x > m.globalVars.GAME_FIELD_MAX_X - m.ballRadius) OR (m.position.x < m.globalVars.GAME_FIELD_MIN_X + m.ballRadius)) 
		m.position.x -= m.speed.x
		m.speed.x *= -1.0
	end if
	
	if ((m.position.y > m.globalVars.screenHeight - m.ballRadius) OR (m.position.y < m.globalVars.GAME_FIELD_MIN_Y + m.ballRadius))
		m.position.y -= m.speed.y
		m.speed.y *= -1.0
	end if
' END. move it to collision manager

	m.SpriteUpdate(_deltatime)
end function

function BallInit(_level)
	m.level = _level
    m.level.ControlListenerSet(m)
    m.speed.x = m.BALL_START_SPEED
    m.speed.y = -m.BALL_START_SPEED
    m.ballRadius = m.BALL_RADIUSES[m.ballRadiusCode]
    m.status = m.STATUS_STICK
    players = m.level.GetObjsByType("player")
    m.player = players[0]
    m.STICK_POSITION_OFFSET_Y = -m.ballRadius - m.player.playerHeight / 2
end function

function BallControlListener(_key as integer, _codes as object) as void
    if (m.active = false) return
    if m.status = m.STATUS_STICK
        if _key = _codes.BUTTON_SELECT_PRESSED
            m.status = m.STATUS_RELEASED
        endif
    endif
end function