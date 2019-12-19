function CreateLevel(_globalVars as object) as object
    obj = {
		active  : true
		globalVars	: _globalVars
		position	: {x: 0.0, y: 0.0}
		gameObjects : [
			{' this is an interface of all gameObjects
				active	: true
				visible	: true
				Update	: invalid
				Draw	: invalid
			}
		]

		Draw    : LevelDraw
		Update  : LevelUpdate
	}
	return obj
end function