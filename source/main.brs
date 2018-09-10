Library "v30/bslDefender.brs"

function Main() as void
    screen = CreateObject("roScreen", true)
    port = CreateObject("roMessagePort")
    bitmapset = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/bitmapset.xml"))
	hero1AnimDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/platform.xml"))
	textAnimDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/text.xml"))
    screenWidth = screen.GetWidth()
    screenHeight= screen.GetHeight()
    clock = CreateObject("roTimespan")
    screen.SetMessagePort(port)
    screen.SetAlphaEnable(true)
    codes = bslUniversalControlEventCodes()
	
	STABLE_FPS = 33.0 / 1000.0
	
	GAME_FIELD_MAX_X = screenWidth - 80
	GAME_FIELD_MIN_X = 80
	GAME_FIELD_MAX_Y = screenHeight - 80
	GAME_FIELD_MIN_Y = 200
	
	GAME_STATE_MENU = 0
	GAME_STATE_GAME_INTRO = 1
	GAME_STATE_GAME_PLAY = 2
	GAME_STATE_GAME_MISS = 3
	GAME_STATE_GAME_GOAL = 4
	GAME_STATE_GAME_GAMEOVER = 5
	
	GAME_STATE_MENU_L1 = 0
	GAME_STATE_MENU_L2 = 1
	GAME_STATE_MENU_L3 = 2

	GAME_STATE_MENU_Y = [ 489, 540, 600 ]
	menuState = GAME_STATE_MENU_L1
	
	GAME_INTRO_DELAY = 3
	
	score = 0
	gameState = GAME_STATE_MENU
	
	
	menuBackgroundRegion = textAnimDataSet.regions.menu_background
	menuBackObj = CreateSpriteObj(menuBackgroundRegion, screen, 0, 0, -0.5, -0.5, screenWidth / menuBackgroundRegion.GetWidth(), screenHeight / menuBackgroundRegion.GetHeight())
	
	menuCursorRegion = bitmapset.regions.menu_cursor
	menuCursorObj = CreateSpriteObj(menuCursorRegion, screen, 270, GAME_STATE_MENU_Y[menuState], 0, 0, 1, 1)

	textRoundRegion = textAnimDataSet.regions.game_text.r1
	textRoundObj = CreateSpriteObj(textRoundRegion, screen, screenWidth/2, screenHeight/2, 0, 0, 1, 1)
	
	backgroundRegion = bitmapset.regions.background
	backObj = CreateSpriteObj(backgroundRegion, screen, 0, 0, -0.5, -0.5, screenWidth / backgroundRegion.GetWidth(), screenHeight / backgroundRegion.GetHeight())
	
		
	ball = CreateVisObj("ball", screen, screenWidth/2, screenHeight/2, bitmapset, "idle2", BallVisObjUpdate)
	ball.ballSpeedX = 10
	ball.ballSpeedY = 10
	ball.ballCurrentSpeedX = 10
	ball.ballCurrentSpeedY = 10
	ball.maxX = GAME_FIELD_MAX_X
	ball.minX = GAME_FIELD_MIN_X
	ball.maxY = GAME_FIELD_MAX_Y
	ball.minY = GAME_FIELD_MIN_Y
	ball.radius = 64

	
	heroObj2 = CreateVisObj("hero2", screen, screenWidth - 100, screenHeight/2, hero1AnimDataSet)
	
	heroObj1 = CreateVisObj("hero1", screen, 100, screenHeight/2, hero1AnimDataSet, "idle", HeroVisObjUpdate)
	heroObj1.heroSpeed = 10
	heroObj1.heroCurrentSpeed = 0
	heroObj1.maxY = GAME_FIELD_MAX_Y
	heroObj1.minY = GAME_FIELD_MIN_Y
	heroObj1.height = 146
	
	clock.Mark()

MENU_LOOP:
    while true
        event = port.GetMessage()
        if (type(event) = "roUniversalControlEvent")
            id = event.GetInt()
			if (id = codes.BUTTON_UP_PRESSED)
				menuState -= 1
				if (menuState < 0 ) menuState = 0
			endif
			if (id = codes.BUTTON_DOWN_PRESSED)
				menuState += 1
				if (menuState > 2 ) menuState = 2
			endif
			if (id = 6)
				Goto GAME_INTRO_LOOP
			endif
        else if (event = invalid)
                deltaTime = clock.TotalMilliseconds() / 1000.0
            if (deltaTime > STABLE_FPS)
				
				menuCursorObj.y = GAME_STATE_MENU_Y[menuState]
				menuCursorObj.Update()
				
				menuBackObj.Draw()
                menuCursorObj.Draw()
				screen.SwapBuffers()
                clock.Mark()
            endif        
        endif
    end while

	gameIntroLoopTime = 0

GAME_INTRO_LOOP:
    while true
		deltaTime = clock.TotalMilliseconds() / 1000.0
        if (deltaTime > STABLE_FPS)
			heroObj1.Update(deltaTime)
			heroObj2.Update(deltaTime)
			
			backObj.Draw()
			heroObj1.Draw()
			heroObj2.Draw()
			
			textRoundObj.Draw()
			
			screen.SwapBuffers()
            clock.Mark()
		endif
		if (gameIntroLoopTime > GAME_INTRO_DELAY) Goto GAME_LOOP
		gameIntroLoopTime += deltaTime
	end while

GAME_LOOP:	
    while true
        event = port.GetMessage()
        if (type(event) = "roUniversalControlEvent")
            id = event.GetInt()
			if (id = codes.BUTTON_UP_PRESSED)
				heroObj1.heroCurrentSpeed = -heroObj1.heroSpeed
			endif
			if (id = codes.BUTTON_DOWN_PRESSED)
				heroObj1.heroCurrentSpeed = heroObj1.heroSpeed
			endif
        else if (event = invalid)
                deltaTime = clock.TotalMilliseconds() / 1000.0
            if (deltaTime > STABLE_FPS)
				heroObj1.Update(deltaTime)
				heroObj2.Update(deltaTime)
				ball.Update(deltaTime, heroObj1, heroObj2)
				
				backObj.Draw()
				
				heroObj1.Draw()
				heroObj2.Draw()
				ball.Draw()
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
	
	return obj
end function

function DrawSprite() as void
	m.screen.DrawScaledObject(m.drawX, m.drawY, m.scaleX, m.scaleY, m.currentRegion)
end function

function SimpleSpriteUpdate(_deltatime=0 as float, _x=0 as float, _y=0 as float) as void
	m.AnimationUpdate(_deltatime)
	m.drawX = m.x + (-m.localOffsetX - 0.5) * m.currentRegion.GetWidth() * m.scaleX + _x
	m.drawY = m.y + (-m.localOffsetY - 0.5) * m.currentRegion.GetHeight() * m.scaleY + _y
end function

function SimpleSpriteAnimationUpdate(_deltatime=0 as float) as void
	if (m.active = false) return
	if (m.regions = invalid) return
	
	m.time += _deltatime * m.speed
	if (m.time > m.length) 
		if (m.loop = true)
			m.time -= m.length
		else 
			m.time = m.length
		endif
	end if
	if (m.time < 0) 
		if (m.loop = true)
			m.time += m.length
		else 
			m.time = 0
		endif
	end if

	m.currentRegionNum = Int(m.time / m.length * m.regions.Count())
	if (m.currentRegionNum > ( m.regions.Count() - 1) ) m.currentRegionNum -= 1
	
	currentRegion = m.regions[m.currentRegionNum]
	if ( currentRegion <> invalid) m.currentRegion = currentRegion
end function

function CreateVisObj(_name as String, _screen as object, _x as float, _y as float, _animsData as object, _currentAnimationName="idle" as String, _Update=SimpleVisObjUpdate as object) as object
	obj = {
		active	: true
		visible	: true
		name	: _name
		screen	: _screen
		x		: _x
		y		: _y
		spriteObjArray	: {}
		currentAnimationName	: _currentAnimationName
				
		Draw	: VisObjDraw
		Update	: _Update
	}
	
	regionsArray = _animsData.animations
	
	for each regionsName in regionsArray
		spriteObj = CreateSpriteObj(regionsArray[regionsName][0], _screen,0,0,0,0,1,1, regionsArray[regionsName], regionsName)
		
		spriteObjSpeed = _animsData.extrainfo.Lookup(regionsName + "_speed")
		if (spriteObjSpeed <> invalid) spriteObj.speed = spriteObjSpeed.ToFloat()
		
		obj.spriteObjArray.AddReplace(regionsName,  spriteObj)
	end for
	
	return obj
end function

function SimpleVisObjUpdate(_deltatime=0 as float) as void
	if (m.active = false) return
	
	for each spriteObjName in m.spriteObjArray
		m.spriteObjArray[spriteObjName].Update(_deltatime, m.x, m.y)
	end for
end function

function VisObjDraw() as void
	if (m.visible = false) return
	
	spriteObj = m.spriteObjArray.Lookup(m.currentAnimationName)
	if (spriteObj <> invalid) spriteObj.Draw()
end function


'---------------------------------------------------------------------
function HeroVisObjUpdate(_deltatime=0 as float) as void
	if (m.active = false) return
	
	m.y += m.heroCurrentSpeed
	if (m.y > m.maxY) m.y = m.maxY
	if (m.y < m.minY) m.y = m.minY
	
	for each spriteObjName in m.spriteObjArray
		m.spriteObjArray[spriteObjName].Update(_deltatime, m.x, m.y)
	end for
end function

function BallVisObjUpdate(_deltatime=0 as float, _hero1=invalid as object, _hero2=invalid as object) as void
	if (m.active = false) return
	
	m.x += m.ballCurrentSpeedX
	m.y += m.ballCurrentSpeedY
	
	if ( (m.x > m.maxX) OR (m.x < m.minX) ) m.ballCurrentSpeedX *= -1
	if ( (m.y > m.maxY) OR (m.y < m.minY) ) m.ballCurrentSpeedY *= -1
	
	distanceX = Abs(_hero1.x - m.x)
	if (distanceX < m.radius)
		if ( (m.y < _hero1.y + _hero1.height / 2 ) AND (m.y > _hero1.y - _hero1.height / 2 ) ) m.ballCurrentSpeedX *= -1
	endif
	
	for each spriteObjName in m.spriteObjArray
		m.spriteObjArray[spriteObjName].Update(_deltatime, m.x, m.y)
	end for
end function

function Distance2D(_ball as object, _hero as object) as object
	coord = {
		x	: 0
		y	: 0
	}
	return coord
end function