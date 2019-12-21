function CreateBall(_globalVars as object) as object
    obj = {
		type	: "ball"
		globalVars	: _globalVars
		level		: invalid
		speed		: {x: 0.0, y: 0.0}
        ballRadiusCode	: 0
        ballRadius  : invalid
        status      : invalid
        STATUS_RUN     : 0
        STATUS_STICK   : 1
        STICK_POSITION_OFFSET_Y : -25
        player         : invalid

		Update    		: BallUpdate
		Init			: BallInit
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
    m.speed.x = m.globalVars.BALL_START_SPEED
    m.speed.y = -m.globalVars.BALL_START_SPEED
    m.ballRadius = m.globalVars.BALL_RADIUSES[m.ballRadiusCode]
    m.status = m.STATUS_STICK
    players = m.level.GetObjsByType("player")
    m.player = players[0]
    m.STICK_POSITION_OFFSET_Y = -m.ballRadius - m.player.playerHeight / 2
end function