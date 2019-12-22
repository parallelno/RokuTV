function CollisionManagerCreate() as object
	obj = {
		activate	: true
		dynamicColliders : []
'			{
'				active			: false
'				collisionLayers : 1<<1 'Int32. Bits represent collision layers which this object can collides
'				collisionData	: {
'					collisionLayer	: 0 'Int. [0-31]. Represent collision layer which this object belong
'					collisionType	: 0 '0 for box, 1 for sphere
'					position		: {x: 0.0, y: 0.0}
'					speed 			: {x: 0.0, y: 0.0}					
'					collisionSize	: {x: 1.0, y: 1.0} 'it is half of each side
'					collisionRadius	: 1.0
'					isCollided	: false
'					obj			: invalid 'object. its CollisionHandler function will be called when this object collides
'				}
'				collisionReports : {
'					id	: { 'collision data of an collided object. 'unique number (as a string).
'						collisionLayer	: 1
'						collisionType	: 0 '0 for box, 1 for sphere
'						position		: {x: 0.0, y: 0.0}
'						speed 			: {x: 0.0, y: 0.0}
'						collisionSize	: {x: 1.0, y: 1.0} 'it is half of each side
'						collisionRadius	: 1.0
'						isCollided	: false
'						obj			: invalid 'collided object. its CollisionHandler function will be called when this object are collided 
'					}
'				}
'			}
'		]
		ids : 0
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
		
		Update	: CollisionManagerUpdate
		AddObject : CollisionManagerAddObject
		CollideBoxBox	: CollisionManagerBoxBoxCollide
	}
	return obj
end function

function CollisionManagerUpdate(_deltatime=0 as float) as void
	for each collider in m.dynamicColliders
		collider.collidedList = []
		collider.isCollided = false
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
	for each collider in m.dynamicColliders
		if (collider.isCollided = true) 
			collider.obj.CollisionHandler(collider.collidedList)
		end if
	end for
end function

function CollisionManagerBoxBoxCollide(_collider1 as object, _collider2 as object) as boolean
	colliderLeft1 = _collider1.position.x - _collider1.collisionSize.x
	colliderRight1 = _collider1.position.x + _collider1.collisionSize.x
	colliderUp1 = _collider1.position.y - _collider1.collisionSize.y
	colliderDown1 = _collider1.position.y + _collider1.collisionSize.y

	colliderLeft2 = _collider2.position.x - _collider2.collisionSize.x
	colliderRight2 = _collider2.position.x + _collider2.collisionSize.x
	colliderUp2 = _collider2.position.y - _collider2.collisionSize.y
	colliderDown2 = _collider2.position.y + _collider2.collisionSize.y
	
'	print "__________"
'	print _collider1.position
'	print _collider2.position
'	print _collider1.collisionSize
'	print _collider2.collisionSize

	if colliderLeft1 < colliderRight2 AND colliderRight1 > colliderLeft2 AND colliderUp1 < colliderDown2 AND colliderDown1 > colliderUp2
'		print _collider1.obj.type
'		print _collider2.obj.type
'		print "collided >>>>>"
		return true
	end if

	return false
end function

function CollisionManagerAddObject(_Object as object) as void
	if (_object.collisionSize = invalid) _object.collisionSize = {x: 1.0, y: 1.0}
	if (_object.collisionRadius = invalid) _object.collisionRadius = 1.0
	
	collisionData = {
		collisionLayer	: _object.collisionLayer 'Int. [0-31]. Represent collision layer which this object belong
		collisionLayers : _object.collisionLayers
		collisionType	: _object.collisionType
		position		: _object.position
		speed 			: _object.speed
		collisionSize	: _object.collisionSize 'it is half of each side
		collisionRadius	: _object.collisionRadius
		isCollided		: false
		obj : _object
		id	: m.ids
		collidedList	: []
	}
	m.ids++
	m.dynamicColliders.Push(collisionData)
end function