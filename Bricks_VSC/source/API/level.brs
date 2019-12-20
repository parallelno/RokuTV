function CreateLevel(_globalVars as object) as object
    obj = {
		type	: "level"
		active  : true
		globalVars	: _globalVars
		position	: {x: 0.0, y: 0.0}
		objs : [
			{' this is an interface of all visual objects
				active	: true
				visible	: true
				type	: ""
				filename: ""
				position: {x: 0.0, y: 0.0}
				order	: 0 'render order from -999 to 9999. -1 (background) will be rendered earlier than 0 (common layer)
				Update	: invalid
				Draw	: invalid
			}
		]
		filenames: []

		Draw    : LevelDraw
		Update  : LevelUpdate
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
			if obj.Update <> invalid
				update1 = global["PlayerUpdate"]
				update = FindMemberFunction(GetGlobalAA(), "PlayerUpdate")
				'globalAA = GetGlobalAA()
'				update = function("PlayerUpdate")
				obj.Update = update
			end if
		end if
		if objData = invalid
			return invalid
		end if
		objData.Append(obj)
		objs.Push(objData)
	end for

	objs.SortBy("order")
	levelData.objs = objs
	level.Append(levelData)
	return level
end function

function LevelUpdate(_deltaTime=0 as float) as void
	if (m.active = false) return
	for each obj in m.objs
		obj.Update(_deltatime)
	end for
end function

function LevelDraw()
	for each obj in m.objs
		obj.Draw()
	end for	
end function
