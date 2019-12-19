function CollisionManagerCreate() as object
	obj = {
		activate	: true
		dynamicObjects : [
			{
				active			: false
				collisionLayers : 1<<1 'Int32. Bits represent collision layers which this object can collides
				collisionData	: {
					layer		: 0 'Int. [0-31]. Represent collision layer which this object belong
					collisionType	: 0 '0 for box, 1 for sphere
					position	: {x: 0.0, y: 0.0}
					size		: {x: 1.0, y: 1.0}
					speed 		: {x: 0.0, y: 0.0}
					radius		: 1.0
					isCollided	: false
				}
				collisionReports : {
					collisionReport	: { 'collision data of an object which collide with object
						layer		: 1
						collisionType: 0 '0 for box, 1 for sphere
						position	: {x: 0.0, y: 0.0}
						size		: {x: 1.0, y: 1.0}
						speed 		: {x: 0.0, y: 0.0}
						radius		: 1.0
						isCollided	: false
					}
				}
				CollisionHandler: invalid 'this function will be called when this object collides
			}
		]
		staticGridObjectsLayer	: 2 'Int. [0-31]. Represent collision layer which this object belong
		staticGridObjectHandlers: [
			[
				{
					active	: false
					CollisionHandler : invalid 'static objects collision handler function. this function will be called when this static grid object are collided
				}
			]
		]
		staticGridOrigin		: {x: 30, y: 30}
		staticGridSize			: {x: 13, y: 17}
		
		Update	: CollisionManagerUpdate
	}
	return obj
end function

function CollisionManagerUpdate(_deltatime=0 as float) as void
end function