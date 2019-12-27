function CollisionManagerCreate() as object
	obj = {
		activate	: true
		dynamicColliders : []
		staticColliders : [] ' they can't initiate collision
		ids : 0 'used for giving unique id for every new collider
		staticGridObjectsLayer	: 2 'Int. [0-31]. Represent collision layer which this object belong
		staticGridObjectHandlers: [
			[
				{
					active	: false
					obj			: invalid 'static objects collision. its CollisionHandler function will be called when this static grid object are collided
				}
			]
		]
		staticGridOrigin		: {x: 30, y: 30}
		staticGridSize			: {x: 13, y: 17}

		STATIC 		: false
		DINAMIC		: true

		Update	: CollisionManagerUpdate
		AddObject : CollisionManagerAddObject
		CollideBoxBox	: CollisionManagerBoxBoxCollide
		MoveOutOfCollision : CollisionManagerMoveOutOfCollision
		ReflectSpeed : CollisionManagerReflectSpeed
	}
	return obj
end function

function CollisionManagerUpdate(_deltatime=0 as float) as void
	for each collider in m.dynamicColliders
		collider.isCollided = false
		collider.collidedList = []
	end for
	for each staticCollider in m.staticColliders
		staticCollider.isCollided = false
		staticCollider.collidedList = []
	end for
	
	for each collider in m.dynamicColliders
		for each colliderOther in m.dynamicColliders
			isTheyCollided = false
			for each collidedCollider in collider.collidedList
				if (collidedCollider.id = colliderOther.id)
					isTheyCollided = true
					exit for
				end if
			end for
			if isTheyCollided = false AND collider.id<>colliderOther.id
				isCollided = m.CollideBoxBox(collider, colliderOther)
				if isCollided = true
					collider.collidedList.Push(colliderOther)
					colliderOther.collidedList.Push(collider)
					collider.isCollided = true
					colliderOther.isCollided = true
				end if
			end if
		end for
	end for
	for each staticCollider in m.staticColliders
		for each collider in m.dynamicColliders
			isCollided = m.CollideBoxBox(collider, staticCollider)
			if isCollided = true
				collider.collidedList.Push(staticCollider)
				staticCollider.collidedList.Push(collider)
				collider.isCollided = true
				staticCollider.isCollided = true
			end if
		end for
	end for
	for each collider in m.dynamicColliders
		if (collider.isCollided = true) 
			collider.obj.CollisionHandler(collider, collider.collidedList)
		end if
	end for
	for each staticCollider in m.staticColliders
		if (staticCollider.isCollided = true) 
			staticCollider.obj.CollisionHandler(staticCollider, staticCollider.collidedList)
		end if
	end for
end function

function CollisionManagerBoxBoxCollide(_collider1 as object, _collider2 as object) as boolean
	colliderLeft1 = _collider1.position.x - _collider1.collisionSize.x * _collider1.scale.x
	colliderRight1 = _collider1.position.x + _collider1.collisionSize.x * _collider1.scale.x
	colliderUp1 = _collider1.position.y - _collider1.collisionSize.y * _collider1.scale.y
	colliderDown1 = _collider1.position.y + _collider1.collisionSize.y * _collider1.scale.y

	colliderLeft2 = _collider2.position.x - _collider2.collisionSize.x * _collider2.scale.x
	colliderRight2 = _collider2.position.x + _collider2.collisionSize.x * _collider2.scale.x
	colliderUp2 = _collider2.position.y - _collider2.collisionSize.y * _collider2.scale.y
	colliderDown2 = _collider2.position.y + _collider2.collisionSize.y * _collider2.scale.y

	if colliderLeft1 < colliderRight2 AND colliderRight1 > colliderLeft2 AND colliderUp1 < colliderDown2 AND colliderDown1 > colliderUp2
		return true
	end if

	return false
end function

function CollisionManagerAddObject(_object as object, isDinamic=true as boolean) as void
	if (_object.collisionSize = invalid) _object.collisionSize = {x: 1.0, y: 1.0}
	if (_object.collisionLayers = invalid) _object.collisionLayers = 1<<0
	if (_object.collisionRadius = invalid) _object.collisionRadius = 1.0
	
	collisionData = {
		collisionLayer	: _object.collisionLayer 'Int. [0-31]. Represent collision layer which this object belong
		collisionLayers : _object.collisionLayers
		collisionType	: _object.collisionType
		position		: _object.position
		speed 			: _object.speed
		collisionSize	: _object.collisionSize 'it is half of each side
		scale			: _object.scale
		collisionRadius	: _object.collisionRadius
		isCollided		: false
		obj : _object
		id	: m.ids
		collidedList	: []
	}
	m.ids++
	if (isDinamic = true)
		m.dynamicColliders.Push(collisionData)
	else
		m.staticColliders.Push(collisionData)
	end if
end function

function CollisionManagerMoveOutOfCollision(_collider as object, _colliderOther as object) as void
	backwardSpeedVectorX = 1.0
	if (_collider.position.x - _colliderOther.position.x < 0.0 ) backwardSpeedVectorX = -1.0
	backwardSpeedVectorY = 1.0
	if (_collider.position.y - _colliderOther.position.y < 0.0 ) backwardSpeedVectorY = -1.0

	backwardPosX = _colliderOther.position.x + (_collider.collisionSize.x * _collider.scale.x + _colliderOther.collisionSize.x * _colliderOther.scale.x) * backwardSpeedVectorX
	backwardPosY = _colliderOther.position.y + (_collider.collisionSize.y * _collider.scale.y + _colliderOther.collisionSize.y * _colliderOther.scale.y) * backwardSpeedVectorY

	backwardMoveX = Abs(_collider.position.x - backwardPosX)
	backwardMoveY = Abs(_collider.position.y - backwardPosY)

	if backwardMoveX < backwardMoveY
		_collider.position.x = backwardPosX
	else
		_collider.position.y = backwardPosY
	end if
end function

function CollisionManagerReflectSpeed(_collider as object, _colliderOther as object) as void
	backwardSpeedVectorX = 1.0
	if (_collider.position.x - _colliderOther.position.x < 0.0 ) backwardSpeedVectorX = -1.0
	backwardSpeedVectorY = 1.0
	if (_collider.position.y - _colliderOther.position.y < 0.0 ) backwardSpeedVectorY = -1.0

	backwardPosX = _colliderOther.position.x + (_collider.collisionSize.x * _collider.scale.x + _colliderOther.collisionSize.x * _colliderOther.scale.x) * backwardSpeedVectorX
	backwardPosY = _colliderOther.position.y + (_collider.collisionSize.y * _collider.scale.y + _colliderOther.collisionSize.y * _colliderOther.scale.y) * backwardSpeedVectorY

	backwardMoveX = Abs(_collider.position.x - backwardPosX)
	backwardMoveY = Abs(_collider.position.y - backwardPosY)

	if backwardMoveX < backwardMoveY
		_collider.speed.x = Abs(_collider.speed.x) * backwardSpeedVectorX
	else
		_collider.speed.y = Abs(_collider.speed.y) * backwardSpeedVectorY
	end if
end function