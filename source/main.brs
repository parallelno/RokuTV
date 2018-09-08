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

function CreateSpriteObj(_region as object, _screen as object, _x=0 as float, _y=0 as float, _localOffsetX=0 as float, _localOffsetY=0 as float, _scaleX=1 as float, _scaleY=1 as float, _regions=invalid as object, _name="idle" as String, _AnimationUpdate=SimpleSpriteAnimationUpdate as object ) as object
	obj = {
		active	: true
		name	: _name
		length	: 1.0
		loop	: true
		speed	: 1.0
		time	: 0
		x		: _x
		y		: _y
		localOffsetX	: _localOffsetX
		localOffsetY	: _localOffsetY
		scaleX	: _scaleX
		scaleY	: _scaleY
		speedX	: 0.0
		speedY	: 0.0
		visible	: true
		regions	: _regions
		currentRegion	: _region
		currentRegionNum	: 0
		screen	: _screen
		drawX	: 0
		drawY	: 0
		
		Draw	: DrawSprite
		Update	: SimpleSpriteUpdate
		AnimationUpdate	: _AnimationUpdate
	}
	
	obj.Update(0)
	
	return obj
end function

function DrawSprite() as void
	m.screen.DrawScaledObject(m.drawX, m.drawY, m.scaleX, m.scaleY, m.currentRegion)
end function

function SimpleSpriteUpdate(_deltatime as float, _x=0 as float, _y=0 as float) as void
	m.AnimationUpdate(_deltatime)
	m.drawX = m.x + (-m.localOffsetX - 0.5) * m.currentRegion.GetWidth() * m.scaleX + _x
	m.drawY = m.y + (-m.localOffsetY - 0.5) * m.currentRegion.GetHeight() * m.scaleY + _y
end function

function SimpleSpriteAnimationUpdate(_deltatime as float) as void
	if (m.active = false) return
	if (m.regions = invalid) return
	
	m.time += _deltatime * m.speed
	if (m.time > m.lenght) 
		if (m.loop = true)
			m.time -= m.lenght
		else 
			m.time = m.lenght
		endif
	end if
	if (m.time < 0) 
		if (m.loop = true)
			m.time += m.lenght
		else 
			m.time = 0
		endif
	end if
	
	m.currentRegionNum = Int(m.time / m.length * m.regions.Count())
	
	currentRegion = m.regions[m.currentRegionNum]
	if ( currentRegion <> invlid) m.currentRegion = currentRegion
end function

function CreateVisObj(_name as String, _screen as object, _x=0 as float, _y=0 as float, _regionsArray as object) as object
	obj = {
		active	: true
		visible	: true
		name	: _name
		screen	: _screen
		x		: _x
		y		: _y
		spriteObjArray	: invalid
		currentAnimationName	: "idle"
				
		Draw	: DrawVisObj
		Update	: SimpleVisObjUpdate
	}
	
	for each regions in _regionsArray
		m.spriteObjArray.Push( CreateSpriteObj(regions[0], _screen, 0, 0, 0,0, 1,1, regions, regions + "") )
	end for
	
	obj.Update(0)
	
	return obj
end function

function SimpleVisObjUpdate(_deltatime as float) as void
	if (m.active = false) return
	for each spriteObj in m.spriteObjArray
		spriteObj.Update(_deltatime, m.x, m.y)
	end for
end function

function VisObjDraw() as void
	if (m.visible = false) return
	
	for each spriteObj in m.spriteObjArray
		spriteObj.Draw()
	end for
end function