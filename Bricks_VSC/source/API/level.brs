function CreateLevel(_globalVars as object) as object
    obj = {
		type	: "level"
		active  : true
		globalVars	: _globalVars
		position	: {x: 0.0, y: 0.0}
		objsId		: 0 'it uses to generate unique id for every gameobject
		objs : [
			{' this is an interface of all visual objects
				active	: true
				visible	: true
				type	: ""
				id		: "" 'unique number (as a string) in scope of level. it will be assiged by LevelLoader and LevelAddGameObject
				filename: ""
				position: {x: 0.0, y: 0.0}
				order	: 0 'render order from -999 to 9999. -1 (background) will be rendered earlier than 0 (common layer)
				Update	: invalid
				Draw	: invalid
			}
		]
		filenames: []

		listeners			: {} 'gameobjects which want to have their ControlListener functions being called when any keys pressed
		collisionManager	: CollisionManagerCreate()

		Draw    : LevelDraw
		Update  : LevelUpdate
		GetObjsByType	: LevelGetObjsByType
		SetID	: LevelSetID
		ControlListenerSet	: LevelControlListenerSet
	}

	return obj
end function

function LoadLevel(_globalVars as object, _path as string) as object
	level = CreateLevel(_globalVars)
	levelASCIIData = ReadAsciiFile(_path)
	if (levelASCIIData = invalid) 
		print "levelASCIIData " + _path + " wasn't created. Check file name."
		return invalid
	end if

	levelData = ParseJson(levelASCIIData)
	if (levelData = invalid OR levelData.type <> level.type)
		print "levelData " + _path + " wasn't created. Check the file structure and type." 
		return invalid
	end if	

	objs = []
	for each obj in levelData.objs
		if obj.type = "staticSprite"
			objData = LoadStaticSprite(_globalVars.screen, obj.filename)
		else if obj.type = "sprite"
			objData = LoadSprite(_globalVars.screen, obj.filename)
		end if
		if obj.override <> invalid
			overrideObj = _globalVars.gameObjectInterfaces[obj.override]
			if overrideObj = invalid 
				print "levelData " + _path + " has wrong override logic (" + obj.override + "). Check line with filename " + obj.filename
			end if 
			obj.Append(overrideObj)
		end if

		if objData = invalid
			return invalid
		end if
		objData.Append(obj)
		level.SetID(objData)
		objs.Push(objData)
	end for

	objs.SortBy("order")
	levelData.objs = objs
	level.Append(levelData)
	
	for each obj in level.objs
		if obj.Init <> invalid 
			obj.Init(level)
		end if
	end for

	return level
end function

function LevelUpdate(_deltaTime=0 as float) as void
' key press handler
    event = m.globalVars.port.GetMessage()
	if type(event) = "roUniversalControlEvent"
		id = event.GetInt()
		for each listener in m.listeners
			m.listeners[listener].ControlListener(id, m.globalVars.codes)
		end for
	end if
	
	if (m.active = false) return

' gameobject updates
	for each obj in m.objs
		obj.Update(_deltatime)
	end for

' collision handlers of all collided objects will be called by this object's update
	m.collisionManager.Update(_deltatime)
end function

function LevelDraw() as void
	for each obj in m.objs
		obj.Draw()
	end for	
end function

function LevelControlListenerSet(_listener) as object
    m.listeners.AddReplace(_listener.id, _listener)
end function

function LevelGetObjsByType(_type as string) as object
	res = []
	for each obj in m.objs
		if obj.type = _type
			res.Push(obj)
		end if
	end for
	return res
end function

function LevelSetID(_obj) as void
	_obj.id = m.objsId.ToStr()
	m.objsId += 1
end function

function LevelAddGameObject(_obj) as void
		m.SetID(_obj)
		m.objs.Push(_obj)
end function