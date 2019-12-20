function CreateGameObject(_globalVars as object) as object
    obj = {
		type	: "gameObject"
		active  : true
        visible	: true
		globalVars	: _globalVars
		position	: {x: 0.0, y: 0.0}
		sprite      : invalid

    	Update	: GameObjectUpdate
	    Draw	: GameObjectDraw
	}
	return obj
end function

function LoadGameObject(_globalVars as object, _path as string) as object
	gameObject = CreateGameObject(_globalVars)
	gameObjectASCIIData = ReadAsciiFile(_path)
	if (gameObjectASCIIData = invalid) 
		print "gameObjectASCIIData " + _path + " wasn't created. Check file name."
		return invalid
	end if

	gameObjectData = ParseJson(gameObjectASCIIData)
	if (gameObjectData = invalid OR gameObjectData.type <> level.type)
		print "gameObjectData " + _path + " wasn't created. Check the file structure and type." 
		return invalid
	end if	

	for each filename in gameObjectData.spriteFilenames
		sprite = LoadGameObject(filename)
		
		gameObjects.Push(gameObject)
		m.gameObjects = gameObjects
	end for

	level.Append(levelData)
	return level
end function

function GameObjectUpdate(_deltaTime=0 as float) as void
	if (m.active = false) return

	m.sprite.Update(_deltaTime, m.position)
end function

function GameObjectDraw()
	m.sprite.Draw()
end function