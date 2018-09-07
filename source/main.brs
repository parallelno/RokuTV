Library "v30/bslDefender.brs"

function Main() as void
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
	
	stableFPS = 33
	
	backgroundRegion = bitmapset.regions.background
	backObj = CreateSpriteObj(backgroundRegion, screen, 0, 0, -0.5, -0.5, screenWidth / backgroundRegion.GetWidth(), screenHeight / backgroundRegion.GetHeight())

	ballAnim = bitmapset.animations.animated_3ball
	ballObj = CreateSpriteObj(ballAnim[0], screen, screenWidth/2, screenHeight/2)

	heroAnim = bitmapset.animations.hero_anim
	heroObj = CreateSpriteObj(heroAnim[0], screen, screenWidth/2, screenHeight/2, 0,0, 1,1, heroAnim)

	
    while true
        event = port.GetMessage()
        if (type(event) = "roUniversalControlEvent")
            id = event.GetInt()            
        else if (event = invalid)
                deltaTime = clock.TotalMilliseconds()
            if (deltaTime > stableFPS)
				backObj.Draw()
				ballObj.Draw()
				heroObj.Draw()
                screen.SwapBuffers()
                clock.Mark()
            endif
        
        endif
    end while
end function

function CreateSpriteObj(_region as object, _screen as object, _x=0 as float, _y=0 as float, _localOffsetX=0 as float, _localOffsetY=0 as float, _scaleX=1 as float, _scaleY=1 as float, _regions=invalid as object) as object
	obj = {
		name	: "idle"
		x		: _x
		y		: _y
		localOffsetX	: _localOffsetX
		localOffsetY	: _localOffsetY
		scaleX	: _scaleX
		scaleY	: _scaleY
		speedX	: 0
		speedY	: 0
		visible	: true
		currentRegion	: _region
		regions	: _regions
		screen	: _screen
		drawX	: 0 
		drawY	: 0
		
		Draw	: DrawSprite
		AddRegions	: AddRegions
		ReplaceRegions	: ReplaceRegions
		Update	: SimpleSpriteUpdate
	}
	
	obj.Update()
	
	return obj
end function

function DrawSprite() as void
	m.screen.DrawScaledObject(m.drawX, m.drawY, m.scaleX, m.scaleY, m.currentRegion)
end function

function SimpleSpriteUpdate() as void
	m.drawX = m.x + (-m.localOffsetX - 0.5) * m.currentRegion.GetWidth() * m.scaleX
	m.drawY = m.y + (-m.localOffsetY - 0.5) * m.currentRegion.GetHeight() * m.scaleY
end function

function AddRegions(_regions as object) as void
	for each region in _regions
		m.regions.Push(region)
	end for
end Function

function ReplaceRegions(_regions as object) as void
	m.regions = _regions
	m.currentRegion = _regions[0]
end Function