Library "v30/bslDefender.brs"

Function Main() as void
    screen = CreateObject("roScreen", true)
    port = CreateObject("roMessagePort")
    bitmapset = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/bitmapset.xml"))
    ballsize = bitmapset.extrainfo.ballsize.ToInt()
    compositor = CreateObject("roCompositor")
    compositor.SetDrawTo(screen, &h02041000)
    screenWidth = screen.GetWidth()
    screenHeight= screen.GetHeight()
    clock = CreateObject("roTimespan")
    clock.Mark()
    screen.SetMessagePort(port)
    screen.SetAlphaEnable(true)
    codes = bslUniversalControlEventCodes()
	
	backgroundRegion = bitmapset.regions.background

    ballAnim = bitmapset.animations.animated_3ball
    ballSprite = compositor.NewAnimatedSprite((screenWidth-ballSize)\2, (screenHeight-ballSize)\2, ballAnim)    

    stableFPS = 33
	
	backObj = CreateFrame(backgroundRegion, screen, 0, 0, screenWidth / backgroundRegion.GetWidth(), screenHeight / backgroundRegion.GetHeight())
	
    while true
        event = port.GetMessage()
        if (type(event) = "roUniversalControlEvent")
            id = event.GetInt()            
        else if (event = invalid)
                deltaTime = clock.TotalMilliseconds()
            if (deltaTime > stableFPS)
				backObj.Draw()
                screen.SwapBuffers()
                clock.Mark()
            endif
        
        endif
    end while
End Function

function CreateFrame(_region as object, _screen as object, _localOffsetX=_region.GetWidth()/2.0 as float, _localOffsetY=_region.GetHeight()/2.0 as float, _scaleX=1 as float, _scaleY=1 as float)
	'SPRITE_STATUS_DEATH = 0
	'SPRITE_STATUS_LIVE = 1
	
	obj = {
		x		: 0
		y		: 0
		localOffsetX	: _localOffsetX
		localOffsetY	: _localOffsetY
		scaleX	: _scaleX
		scaleY	: _scaleY
		speedX	: 0
		speedY	: 0
		'status	: SPRITE_STATUS_LIVE
		visible	: true
		currentRegion	: _region
		regions	: CreateObject("roArray", 1, true) ': m.regions[0] = m.currentRegion
		screen	: _screen
		Draw	: function() : m.screen.DrawScaledObject(m.x - m.localOffsetX * m.scaleX, m.y - m.localOffsetY * m.scaleY, m.scaleX, m.scaleY, m.currentRegion) : end function
	}
	return obj
end Function