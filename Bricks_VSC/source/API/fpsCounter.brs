function CreateFpsCounter(_globalVars as object) as object
	obj = {
'		public
		type		: "fpsCounter"
		active		: true
		visible		: true
		globalVars	: _globalVars
		position	: {x: 0.0, y: 0.0}
        size	: {x: 0.0, y: 0.0}
'		private fields
		drawPosition: {x: 0.0, y: 0.0}
		screen		: _globalVars.screen
        fontRegistry: invalid
        font        : invalid
        fpsAverage : 0.0
        FPS_SMOOTHNESS  : 0.02
        BORDER_WIDTH    : 3.0
        BACK_COLOR      : &h0000FFFF
        FONT_COLOR      : &hFFFFFFFF
'		functions
		Draw    : FpsCounterDraw
		Update  : FpsCounterUpdate
		Load : LoadFpsCounter
		Init : FpsCounterInit
	}
	return obj
end function

function LoadFpsCounter(_globalVars as object, _path as String) as object
	'_path isn't used
	fpsCounter = CreateFpsCounter(_globalVars)
	return fpsCounter
end function

function FpsCounterUpdate(_deltatime=0 as float, _position=invalid as object) as void
    dt = _deltatime
    if (_deltatime = 0.0) dt = 0.001
    m.fpsAverage += (1.0/dt - m.fpsAverage) * m.FPS_SMOOTHNESS
end function

function FpsCounterDraw() as void
	if (m.visible = false) return
'return return return__________________________________SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS_____________________ return

'    m.globalVars.screen.DrawRect(m.position.x, m.position.y, m.size.x + 2.0 * m.BORDER_WIDTH, m.size.y + 2.0 * m.BORDER_WIDTH, m.BACK_COLOR)
    m.globalVars.screen.DrawText(m.fpsAverage.ToStr(), m.position.x + m.BORDER_WIDTH, m.position.y + m.BORDER_WIDTH, m.FONT_COLOR, m.font)

end function

function FpsCounterInit(_level as object) as void
    m.fontRegistry = CreateObject("roFontRegistry")
    m.font = m.fontRegistry.GetDefaultFont()

    text = "Hello world"
    m.size.x = m.font.GetOneLineWidth(text, m.globalVars.screen.GetWidth())
    m.size.y = m.font.GetOneLineHeight()
end function