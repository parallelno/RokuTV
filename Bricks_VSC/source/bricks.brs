function CreateBricks(_screen as object) as object
	obj = {
'		public
		type		: "bricks"
		active		: true
		visible		: true
		position	: {x: 0.0, y: 0.0}
'		private fields
		drawPosition: {x: 0.0, y: 0.0}
		screen		: _screen
		bricks		: [] 'array of ByteArrays


'		functions
		Draw    : BricksDraw
		Update  : BricksUpdate
		Load : LoadBricks
		Init : BricksInit
	}
	return obj
end function

function LoadBricks(_screen as object, _path as String) as object
	'_path isn't used. all the bricks data is in the bricks field
	bricks = CreateBricks(_screen)
	bricksData = []
	for each bricksTextLine in bricks.bricks
		bricksDataLine = CreateObject("roByteArray")
		bricksDataLine.FromAsciiString(bricksTextLine)
		bricksData.Push(bricksDataLine)
	end for
	
	return bricks
end function

function BricksUpdate(_deltatime=0 as float, _position=invalid as object) as void
	if (m.active = false) return
	
	if _position <> invalid
		m.position.x = _position.x
		m.position.y = _position.y
	end if
		
end function

function BricksDraw() as void
	if (m.visible = false) return
end function

function BricksInit(_level as object) as void
	
end function