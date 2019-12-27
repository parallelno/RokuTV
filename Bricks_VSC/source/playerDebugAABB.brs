function CreatePlayerDebugAABB(_globalVars as object) as object
	obj = {
		type	: "playerDebugAABB"
		visible		: false
		globalVars	: _globalVars
		id			: "" 'unique number (as a string) in scope of level. it will be assiged by LevelLoader and LevelAddGameObject
		level		: invalid
		color		: &hFF000060

		collisionLayer	: 2
		collisionType	: 0
		collisionSize	: {x: 0.5, y: 0.5} 'it is half of each side

		status			: 0
		STATUS_INIT		: 0
		STATUS_RUN		: 1
		
		Init			: PlayerDebugAABBInit
		Update    		: PlayerDebugAABBUpdate
		ControlListener	: PlayerDebugAABBControlListener
		LateUpdate		: PlayerDebugAABBLateUpdate
'custom
		player      : invalid
	}
	return obj
end function

function PlayerDebugAABBUpdate(_deltatime=0 as float, _position=invalid as object) as void
	if (m.active = false) return
	if _position <> invalid
		m.position.x = _position.x
		m.position.y = _position.y
	end if
end function

function PlayerDebugAABBLateUpdate(_deltatime=0 as float, _position=invalid as object) as void
	if (m.active = false) return
	if _position <> invalid
		m.position.x = _position.x
		m.position.y = _position.y
	end if

	if m.status = m.STATUS_INIT
		m.status = m.STATUS_RUN
		players = m.level.GetObjsByType("player")
		m.player = players[0]
	end if
	m.position.x = m.player.position.x
	m.position.y = m.player.position.y
	m.scale.x = m.player.scale.x * m.player.collisionSize.x * 2.0
	m.scale.y = m.player.scale.y * m.player.collisionSize.y * 2.0

	m.OriginalUpdate(_deltatime)
end function

function PlayerDebugAABBInit(_level as object) as void
	m.level = _level
	m.level.ControlListenerSet(m)
	m.status = m.STATUS_INIT
end function

function PlayerDebugAABBControlListener(_key as integer, _codes as object) as void
	if (m.active = false) return
	
	if (_key = _codes.BUTTON_UP_PRESSED)
		if m.visible = true
			m.visible = false
		else
			m.visible = true
		end if
	endif
end function