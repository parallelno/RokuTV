function CreateBricks(_globalVars as object) as object
	obj = {
'		public
		type		: "bricks"
		active		: true
		visible		: true
		globalVars	: _globalVars
		position	: {x: 0.0, y: 0.0}
'		private fields
		drawPosition: {x: 0.0, y: 0.0}
		screen		: _globalVars.screen
		bricks		: [] 'array of ByteArrays

		SPRITE_FILENAME	: "pkg:/assets/gameObjects/brick.json"
		BRICK_TYPES_COUNT: 9 'max types of bricks
		brickSprites : [] 'there are all of the brick sprites saved in the proper order. the first sprite plays "1" animation and so on.
		MIN_POS_X	: 94
		MIN_POS_Y	: 55
        BRICK_WIDTH : 64
        BRICK_HEIGHT: 25

'		functions
		Draw    : BricksDraw
		Update  : BricksUpdate
		Load : LoadBricks
		Init : BricksInit
	}
	return obj
end function

function LoadBricks(_globalVars as object, _path as String) as object
	'_path isn't used
	bricks = CreateBricks(_globalVars)
	return bricks
end function

function BricksUpdate(_deltatime=0 as float, _position=invalid as object) as void
return
	if (m.active = false) return
	
	if _position <> invalid
		m.position.x = _position.x
		m.position.y = _position.y
	end if
	
	for each bricksLine in m.bricks
		for each brickCode in bricksLine
			m.brickSprites[brickCode].Update(_deltatime)
		end for
	end for
end function

function BricksDraw() as void
	if (m.visible = false) return
	
return
	brickPosition = {x:0, y:0}
	brickCode = 0
	for y=0 to m.globalVars.MAX_LEVEL_LINES - 1
		for x=0 to m.globalVars.MAX_LEVEL_COLUMNS - 1
			brickPosition.x = m.MIN_POS_X + m.BRICK_WIDTH * x
			brickPosition.y = m.MIN_POS_Y + m.BRICK_HEIGHT * y
			
			brickCode = m.bricks[y][x]
			
			m.brickSprites[brickCode].Update(0, brickPosition)
			m.brickSprites[brickCode].Draw()
		end for
	end for
end function

function BricksInit(_level as object) as void
'	parsing brick text data	
'	erase the bricks array
	bricks = []
	for y=0 to m.globalVars.MAX_LEVEL_LINES - 1
		bricksDataLine = CreateObject("roByteArray")
		for x=0 to m.globalVars.MAX_LEVEL_COLUMNS - 1
			bricksDataLine.Push(0)
		end for
		bricks.Push(bricksDataLine)
	end for
'	fill the bricks array with data 
	for y=0 to m.globalVars.MAX_LEVEL_LINES - 1
		bricksDataLine = bricks[y]
		if y > m.bricks.Count()-1
			Exit for
		end if
		for x=0 to m.globalVars.MAX_LEVEL_COLUMNS - 1
			blockChar = " "
			if y <= m.bricks[y].Len()-1
				blockChar = m.bricks[y].Mid(x, 1)
			end if
			if (Asc(blockChar) >= Asc("1") AND Asc(blockChar) <= Asc("9"))
				bricksDataLine[x] = Asc(blockChar) - Asc("1") + 1
			end if
		end for
	end for
	m.bricks = bricks

' load sprites
	for i=1 to m.BRICK_TYPES_COUNT
		brickSprite = LoadSprite(m.globalVars, m.SPRITE_FILENAME)
		brickSprite.AnimationSet(i.ToStr())
		m.brickSprites.Push(brickSprite)
	end for
end function