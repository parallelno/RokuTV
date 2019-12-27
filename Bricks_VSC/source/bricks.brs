function CreateBricks(_globalVars as object) as object
	obj = {
'		public
		type		: "bricks"
		active		: true
		visible		: true
		globalVars	: _globalVars
		level		: invalid
		position	: {x: 0.0, y: 0.0}
'		private fields
		screen		: _globalVars.screen
		bricks		: [] 'array of ByteArrays with brick codes (0-9). zero is empty block
		bitmap 		: invalid 'bricks texture
		regions		: [] ' BRICK_TYPES_COUNT regions

		BITMAP_FILENAME	: "pkg:/assets/gameObjects/png/bricks.png"
		BRICK_TYPES_COUNT: 9 'max types of bricks
		BRICKS_POS_OFFSET_X	: 62
		BRICKS_POS_OFFSET_Y	: 34
		BRICK_WIDTH : 64
		BRICK_HEIGHT: 25
		MAX_LEVEL_COLUMNS	: 13
		MAX_LEVEL_LINES		: 17
		collisionLayer : 4

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
	if (m.active = false) return
end function

function BricksDraw() as void
	if (m.visible = false) return
	
	brickCode = 0
	for y=0 to m.MAX_LEVEL_LINES - 1
		for x=0 to m.MAX_LEVEL_COLUMNS - 1			
			brickCode = m.bricks[y][x]
			if brickCode > 0
				m.globalVars.screen.DrawObject(x * m.BRICK_WIDTH + m.BRICKS_POS_OFFSET_X, y * m.BRICK_HEIGHT + m.BRICKS_POS_OFFSET_Y, m.regions[brickCode-1])
			end if
		end for
	end for
end function

function BricksInit(_level as object) as void
	allBricksBitmapProp = {
		width	: m.MAX_LEVEL_COLUMNS * m.BRICK_WIDTH
		height	: m.MAX_LEVEL_LINES * m.BRICK_HEIGHT
		alphaenable : true
	}
	m.allBricksBitmap = CreateObject("roBitmap", allBricksBitmapProp)
	m.allBricksBitmap.Clear(&h000000FF)
	
'	parsing brick text data	
'	erase the bricks array
	bricks = []
	for y=0 to m.MAX_LEVEL_LINES - 1
		bricksDataLine = CreateObject("roByteArray")
		for x=0 to m.MAX_LEVEL_COLUMNS - 1
			bricksDataLine.Push(0)
		end for
		bricks.Push(bricksDataLine)
	end for
'	fill the bricks array with data 
	for y=0 to m.MAX_LEVEL_LINES - 1
		bricksDataLine = bricks[y]
		if y > m.bricks.Count()-1
			Exit for
		end if
		for x=0 to m.MAX_LEVEL_COLUMNS - 1
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

' load bitmap and creating regions
	m.bitmap = CreateObject("roBitmap", m.BITMAP_FILENAME)	

	for y=0 to 2
		for x=0 to 2
			m.regions.Push(CreateObject("roRegion", m.bitmap, x * m.BRICK_WIDTH, y * m.BRICK_HEIGHT, 64, 25))
		end for
	end for

	m.level = _level

	m.level.CollisionManager.AddStaticGridObjects(m.bricks, {x: m.BRICKS_POS_OFFSET_X, y: m.BRICKS_POS_OFFSET_Y}, {x: m.BRICK_WIDTH, y: m.BRICK_HEIGHT}, m.collisionLayer)
end function