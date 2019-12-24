function CreateBall(_globalVars as object) as object
	obj = {
		type	: "ball"
		globalVars	: _globalVars
		id			: "" 'unique number (as a string) in scope of level. it will be assiged by LevelLoader and LevelAddGameObject
		level		: invalid

		speed		: {x: 0.0, y: 0.0}
		collisionRadius  : invalid
		collisionLayer	: 1
		collisionLayers : 1<<0 'Int32. Bits represent collision layers which this object can collides
		collisionType	: 0
		collisionSize	: {x: 10.0, y: 10.0} 'it is half of each side

		collisionRadiusCode	: 0
		COLLISION_RADIUSES : [10.0, 20.0, 40.0]

		status		: invalid
		STATUS_RUN     : 0
		STATUS_STICK   : 1
		STATUS_RELEASED: 2
		STICK_POSITION_OFFSET_Y : -25.0
		START_SPEED	: 5.0

		player         : invalid

		Init			: BallInit
		Update    		: BallUpdate
		LateUpdate    		: BallLateUpdate
		ControlListener	: BallControlListener
		CollisionHandler : BallCollisionHandler
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
			m.speed.x = Sgn(m.player.speed.x) * m.START_SPEED
		else
			m.speed.x = Sgn(Rnd(10000)-5000) * m.START_SPEED
		end if
		m.speed.y = -m.START_SPEED
		m.position.y = m.player.position.y + m.STICK_POSITION_OFFSET_Y
	end if
end function

function BallLateUpdate(_deltatime=0 as float, _position=invalid as object) as void
	m.OriginalUpdate(_deltatime)
end function


function BallInit(_level as object) as void
	m.level = _level
	m.level.ControlListenerSet(m)
	m.speed.x = m.START_SPEED
	m.speed.y = -m.START_SPEED
	m.collisionRadius = m.COLLISION_RADIUSES[m.collisionRadiusCode]
	m.status = m.STATUS_STICK
	players = m.level.GetObjsByType("player")
	m.player = players[0]
	m.STICK_POSITION_OFFSET_Y = -m.collisionRadius - m.player.collisionSize.y
	m.level.CollisionManager.AddObject(m)
end function

function BallControlListener(_key as integer, _codes as object) as void
	if (m.active = false) return
	if m.status = m.STATUS_STICK
		if _key = _codes.BUTTON_SELECT_PRESSED
			m.status = m.STATUS_RELEASED
		endif
	endif
end function

function BallCollisionHandler(_collider as object, _collidedList as object)
	for each colliderOther in _collidedList
		if colliderOther.collisionLayer = 2
			m.level.CollisionManager.ReflectSpeed(_collider, colliderOther)
		end if
		if colliderOther.collisionLayer = 0
			ballPlatfomPosDiffX = _collider.position.x - colliderOther.position.x
			if Abs(ballPlatfomPosDiffX) < m.player.COLLISION_PLATO_HALF_SIZES[m.player.collisionSizeCode]
				m.level.CollisionManager.ReflectSpeed(_collider, colliderOther)
				m.speed.y = -Abs(m.speed.y)
			else
				if (_collider.speed.y > 0.0)
					ballSpeedLength = VectorLength(_collider.speed)
					_collider.speed.x = 0.7071 * ballSpeedLength * Sgn(ballPlatfomPosDiffX)
					_collider.speed.y = -0.7071 * ballSpeedLength
				end if				
			end if
		end if
	end for	
end function