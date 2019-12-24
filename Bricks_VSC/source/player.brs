function CreatePlayer(_globalVars as object) as object
	obj = {
		type	: "player"
		globalVars	: _globalVars
		id			: "" 'unique number (as a string) in scope of level. it will be assiged by LevelLoader and LevelAddGameObject
		level		: invalid

		speed		: {x: 0.0, y: 0.0}
		collisionLayer	: 0
		collisionLayers : 1<<1 'Int32. Bits represent collision layers which this object can collides
		collisionType	: 0
		collisionSize	: {x: 0.0, y: 0.0} 'it is half of each side
		
		collisionSizeCode	: 0
		COLLISION_SIZES	: [  'it is half of each side
			{x: 59.0, y: 14.0},
			{x: 74.0, y: 14.0},
			{x: 113.0, y: 14.0}]

		MOVE_CODE_RIGHT	: 1
		MOVE_CODE_LEFT	: 2
		START_SPEED		: 10.0
		
		COLLISION_PLATO_HALF_SIZES : [39.0, 57.0, 95.0] 'the plato is an inner flat part of the platform


		Init			: PlayerInit
		Update    		: PlayerUpdate
		LateUpdate    	: PlayerLateUpdate
		ControlListener	: PlayerControlListener
		Move			: PlayerMove
		CollisionHandler: PlayerCollisionHandler
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
end function

function PlayerLateUpdate(_deltatime=0 as float, _position=invalid as object) as void
	if (m.active = false) return
	if _position <> invalid
		m.position.x = _position.x
		m.position.y = _position.y
	end if
	m.OriginalUpdate(_deltatime)
end function

function PlayerInit(_level as object) as void
	m.level = _level
	m.level.ControlListenerSet(m)

	m.position.x = m.globalVars.GAME_FIELD_MIN_X + m.globalVars.GAME_FIELD_WIDTH * 0.5
	m.collisionSize = m.COLLISION_SIZES[m.collisionSizeCode]	
	m.level.CollisionManager.AddObject(m)
end function

function PlayerControlListener(_key as integer, _codes as object) as void
	if (m.active = false) return
	
	if (_key = _codes.BUTTON_LEFT_PRESSED)
		m.Move(m.MOVE_CODE_LEFT)
	endif
	if (_key = _codes.BUTTON_RIGHT_PRESSED)
		m.Move(m.MOVE_CODE_RIGHT)
	endif
end function

function PlayerMove(_playerMoveCode as Integer) as void
	if (_playerMoveCode = m.MOVE_CODE_RIGHT)
		m.speed.x = m.START_SPEED
	end if
		if (_playerMoveCode = m.MOVE_CODE_LEFT)
		m.speed.x = -m.START_SPEED
	end if
end function

function PlayerCollisionHandler(_collider as object, _collidedList as object)
	for each colliderOther in _collidedList
		if colliderOther.collisionLayer = 2
			m.level.CollisionManager.MoveOutOfCollision(_collider, colliderOther)
		end if
	end for
end function