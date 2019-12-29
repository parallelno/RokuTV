function CollisionManagerCreate(_globalVars as object) as object
	obj = {
		active	: true
		visible		: false
		dynamicColliders : []
		globalVars : _globalVars
		staticColliders : [] ' they can't initiate collision
		ids : 0 'used for giving unique id for every new collider
		
		staticGridCellSize		: {x: 0, y: 0}
		staticGridPositionOffset: {x: 0, y: 0}
		staticGridDimension		: {x: 0, y: 0}
		staticGridCollisionLayer: 2 'Int. [0-31]. Represent collision layer which this object belong
		staticGridColliders		: [] 'array of ByteArrays with brick codes (0-9). zero is empty block and not active
		staticGridObj			: invalid

		STATIC 		: false
		DINAMIC		: true
		
		color		: &hFF000060

		Update				: CollisionManagerUpdate
		AddObject			: CollisionManagerAddObject
		AddStaticGridObjects: CollisionManagerAddStaticGridObjects
		CollideBoxBox		: CollisionManagerBoxBoxCollide
		MoveOutOfCollision	: CollisionManagerMoveOutOfCollision
		ReflectSpeed		: CollisionManagerReflectSpeed
		CollideStaticGridCellRing: CollisionManagerCollideStaticGridCellRing
		ControlListener		: CollisionManagerControlListener
		Draw    			: CollisionManagerDraw
	}
	return obj
end function

function CollisionManagerControlListener(_key as integer, _codes as object) as void
	if (m.active = false) return
	if (_key = _codes.BUTTON_UP_PRESSED) m.visible = NOT m.visible
end function

function CollisionManagerDraw() as void
	if (m.visible = false) return

	'draw dynamic collision
	for each obj in m.dynamicColliders
		x = obj.position.x - obj.collisionSize.x * obj.scale.x
		y = obj.position.y - obj.collisionSize.y * obj.scale.y
		w = obj.collisionSize.x * obj.scale.x * 2.0
		h = obj.collisionSize.y * obj.scale.y * 2.0
		m.globalVars.screen.DrawRect(x, y, w, h, m.color)
	end for
	'draw static collision
	for each obj in m.staticColliders
		x = obj.position.x - obj.collisionSize.x * obj.scale.x
		y = obj.position.y - obj.collisionSize.y * obj.scale.y
		w = obj.collisionSize.x * obj.scale.x * 2.0
		h = obj.collisionSize.y * obj.scale.y * 2.0
		m.globalVars.screen.DrawRect(x, y, w, h, m.color)
	end for

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

function CollisionManagerAddStaticGridObjects(_obj as object, _bricks as object, _positionOffset as object, _cellSize as object, _collisionLayer as integer) as void
	m.staticGridColliders = _bricks
	m.staticGridDimension.y = _bricks.Count()
	m.staticGridDimension.x = _bricks[0].Count()
	m.staticGridPositionOffset = _positionOffset
	m.staticGridCellSize = _cellSize
	m.staticGridCollisionLayer = _collisionLayer
	m.staticGridObj = _obj
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
' static grid collision
	for each collider in m.dynamicColliders
		leftCollidedStaticGridCell = (collider.position.x - collider.collisionSize.x * collider.scale.x - m.staticGridPositionOffset.x) \ m.staticGridCellSize.x
		topCollidedStaticGridCell = (collider.position.y - collider.collisionSize.y * collider.scale.y - m.staticGridPositionOffset.y) \ m.staticGridCellSize.y
		rightCollidedStaticGridCell = (collider.position.x + collider.collisionSize.x * collider.scale.x - m.staticGridPositionOffset.x) \ m.staticGridCellSize.x
		downCollidedStaticGridCell = (collider.position.y + collider.collisionSize.y * collider.scale.y - m.staticGridPositionOffset.y) \ m.staticGridCellSize.y
		if (leftCollidedStaticGridCell >= 0 AND leftCollidedStaticGridCell < m.staticGridDimension.x) OR (rightCollidedStaticGridCell >= 0 AND rightCollidedStaticGridCell < m.staticGridDimension.x)
			if (topCollidedStaticGridCell >= 0 AND topCollidedStaticGridCell < m.staticGridDimension.y) OR (downCollidedStaticGridCell >= 0 AND downCollidedStaticGridCell < m.staticGridDimension.y)
				leftCollidedStaticGridCell = clampI(leftCollidedStaticGridCell, 0, m.staticGridDimension.x - 1)
				rightCollidedStaticGridCell = clampI(rightCollidedStaticGridCell, 0, m.staticGridDimension.x - 1)
				topCollidedStaticGridCell = clampI(topCollidedStaticGridCell, 0, m.staticGridDimension.y - 1)
				downCollidedStaticGridCell = clampI(downCollidedStaticGridCell, 0, m.staticGridDimension.y - 1)
				for y=topCollidedStaticGridCell to downCollidedStaticGridCell
					for x=leftCollidedStaticGridCell to rightCollidedStaticGridCell
						brickCode = m.staticGridColliders[y][x]
						if brickCode > 0
							isCollided = m.CollideStaticGridCellRing(collider, x, y)
							if isCollided = true
								collider.isCollided = true
								m.staticGridObj.CollisionHandler(x, y)
							end if
						end if
					end for
				end for
			end if
		end if
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

function CollisionManagerCollideStaticGridCellRing(_collider as object, x as integer, y as integer) as boolean
	brickLeftSideX = x * m.staticGridCellSize.x + m.staticGridPositionOffset.x
	brickRightSideX = brickLeftSideX + m.staticGridCellSize.x
	
	brickLeftSideY = y * m.staticGridCellSize.y + m.staticGridPositionOffset.y
	brickRightSideY = brickLeftSideY + m.staticGridCellSize.y

	'finding a brick's point closest to the circle' center
	nearestX = MaxF(brickLeftSideX, MinF(_collider.position.x, brickRightSideX))
	nearestY = MaxF(brickLeftSideY, MinF(_collider.position.y, brickRightSideY))

	brickBallPosDeltaX = _collider.position.x - nearestX
	brickBallPosDeltaY = _collider.position.y - nearestY
	
	brickBallPosDeltaDistanceInPow = brickBallPosDeltaX * brickBallPosDeltaX + brickBallPosDeltaY * brickBallPosDeltaY 
	
	colliderRadiusInPow = _collider.collisionRadius * _collider.scale.x
	colliderRadiusInPow *= colliderRadiusInPow

	_collider.isCollided = brickBallPosDeltaDistanceInPow < colliderRadiusInPow
	if (_collider.isCollided = false)
		return false
	end if

	brickNormal = {
		x : brickBallPosDeltaX
		y : brickBallPosDeltaY
	}

	brickBallPosDeltaLength = Sqr(brickBallPosDeltaDistanceInPow)

	brickNormal = NormalizeVector(brickNormal)
	reflectedBallSpeed = ReflectVector(_collider.speed, brickNormal)

	_collider.speed.x = reflectedBallSpeed.x
	_collider.speed.y = reflectedBallSpeed.y

	hitPos = {
		x : 0.0
		y : 0.0
	}
	hitPos.x = _collider.position.x + brickNormal.x * (_collider.collisionRadius - brickBallPosDeltaLength)
	hitPos.y = _collider.position.y + brickNormal.y * (_collider.collisionRadius - brickBallPosDeltaLength)
	_collider.position.x = hitPos.x
	_collider.position.y = hitPos.y
	return true
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