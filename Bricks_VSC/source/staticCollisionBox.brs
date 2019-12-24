function CreateStaticCollisionBox(_globalVars as object) as object
	obj = {
		type	: "staticCollisionBox"
		visible		: false
		globalVars	: _globalVars
		id			: "" 'unique number (as a string) in scope of level. it will be assiged by LevelLoader and LevelAddGameObject
		level		: invalid
		color		: &hFF000060

		collisionLayer	: 2
		collisionType	: 0
		collisionSize	: {x: 0.5, y: 0.5}
		
		Init			: StaticCollisionBoxInit
		Update    		: StaticCollisionBoxUpdate
		ControlListener	: StaticCollisionBoxControlListener
		CollisionHandler: StaticCollisionBoxCollisionHandler
	}
	return obj
end function

function StaticCollisionBoxUpdate(_deltatime=0 as float, _position=invalid as object) as void
	if (m.active = false) return
	if _position <> invalid
		m.position.x = _position.x
		m.position.y = _position.y
	end if

	m.OriginalUpdate(_deltatime)
end function

function StaticCollisionBoxInit(_level)
	m.level = _level
	m.level.ControlListenerSet(m)
	m.level.CollisionManager.AddObject(m, m.level.CollisionManager.STATIC)
end function

function StaticCollisionBoxControlListener(_key as integer, _codes as object) as void
	if (m.active = false) return
	
	if (_key = _codes.BUTTON_UP_PRESSED)
		if m.visible = true
            m.visible = false
        else
            m.visible = true
        end if
	endif
end function

function StaticCollisionBoxCollisionHandler(_collider as object, _collidedList as object)
'	print "StaticCollisionBox is collided"
end function