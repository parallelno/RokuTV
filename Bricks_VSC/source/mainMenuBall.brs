function CreateMainMenuBall(_globalVars as object) as object
	obj = {
		type	: "mainMenuBall"
		globalVars	: _globalVars
		level		: invalid
		initialPosY : 0
		amplitudeY  : 20.0
		jumpTime	: 0.0
		speed		: 6.0

		Init			: MainMenuBallInit
		Update    		: MainMenuBallUpdate
	}
	return obj
end function

function MainMenuBallUpdate(_deltatime=0 as float, _position=invalid as object) as void
	if (m.active = false) return
	if _position <> invalid
		m.position.x = _position.x
		m.position.y = _position.y
	end if

	m.jumpTime += _deltatime * m.speed
	m.position.y = m.initialPosY - Abs(Sin(m.jumpTime)) * m.amplitudeY
	m.OriginalUpdate(_deltatime)
end function

function MainMenuBallInit(_level as object) as void
	m.level = _level
	m.initialPosY = m.position.y
	m.jumpTime = 0
end function