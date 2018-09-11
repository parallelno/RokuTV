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
	
	GAME_FIELD_MAX_X = screenWidth - 80.0
	GAME_FIELD_MIN_X = 80
	GAME_FIELD_MAX_Y = screenHeight - 80
	GAME_FIELD_MIN_Y = 200
		
	GAME_STATE_MENU_L1 = 0
	GAME_STATE_MENU_L2 = 1
	GAME_STATE_MENU_L3 = 2

	GAME_STATE_MENU_Y = [ 489, 540, 600 ]
	menuState = GAME_STATE_MENU_L1
	
	GAME_INTRO_DELAY = 1.0
	GAME_OVER_DELAY = 3.0
	
	HIT_BALL_SCORE = 50
	BALL_SPEEDS = [5, 10, 15] 'speed depends on game difficulty
	
	HERO_SPEED = 10
		
	menuBackgroundRegion = textAnimDataSet.regions.menu_background
	menuBackObj = CreateSpriteObj(menuBackgroundRegion, screen, 0, 0, -0.5, -0.5, screenWidth / menuBackgroundRegion.GetWidth(), screenHeight / menuBackgroundRegion.GetHeight())
	
	menuCursorRegion = bitmapset.regions.menu_cursor
	menuCursorObj = CreateSpriteObj(menuCursorRegion, screen, 270, GAME_STATE_MENU_Y[menuState], 0, 0, 1, 1)

	textRoundObj = CreateVisObj("Round", screen, screenWidth/2, screenHeight/2, textAnimDataSet, "round", TextRoundObjUpdate)
	textGameOverObj = CreateVisObj("GameOver", screen, screenWidth/2, screenHeight/2, textAnimDataSet, "game_over", TextRoundObjUpdate)

	textScoreObj = CreateSpriteObj(textAnimDataSet.animations.score[0], screen, 10, 0, -0.5, -0.5, 0.5, 0.5)	
	numScoreObj = CreateNumberTextObj(0, textAnimDataSet.animations.numbers_anim, screen, 170, 5, -0.5, -0.5, 0.5, 0.5)
	numScoreObj.HIT_BALL_SCORE = HIT_BALL_SCORE

	textBestScoreObj = CreateSpriteObj(textAnimDataSet.animations.best_score[0], screen, 500, 0, -0.5, -0.5, 0.5, 0.5)	
	numBestScoreObj = CreateNumberTextObj(0, textAnimDataSet.animations.numbers_anim, screen, 800, 5, -0.5, -0.5, 0.5, 0.5)

	backgroundRegion = bitmapset.regions.background
	backObj = CreateSpriteObj(backgroundRegion, screen, 0, 0, -0.5, -0.5, screenWidth / backgroundRegion.GetWidth(), screenHeight / backgroundRegion.GetHeight())
	
		
	ball = CreateVisObj("ball", screen, screenWidth/2, screenHeight/2, bitmapset, "idle2", BallVisObjUpdate)
	
	ball.ballCurrentSpeedX = BALL_SPEEDS[0]
	ball.ballCurrentSpeedY = BALL_SPEEDS[0]
	ball.maxX = GAME_FIELD_MAX_X
	ball.minX = GAME_FIELD_MIN_X
	ball.maxY = GAME_FIELD_MAX_Y
	ball.minY = GAME_FIELD_MIN_Y
	ball.radius = 64

	
	heroObj2 = CreateVisObj("hero2", screen, screenWidth - 100, screenHeight/2, hero1AnimDataSet, "idle", AIHeroVisObjUpdate)
	heroObj2.heroSpeed = HERO_SPEED
	heroObj2.heroCurrentSpeed = 0
	heroObj2.maxY = GAME_FIELD_MAX_Y
	heroObj2.minY = GAME_FIELD_MIN_Y
	heroObj2.height = 146
	
	heroObj1 = CreateVisObj("hero1", screen, 100, screenHeight/2, hero1AnimDataSet, "idle", HeroVisObjUpdate)
	heroObj1.heroSpeed = HERO_SPEED
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
				ball.ballCurrentSpeedX = BALL_SPEEDS[menuState]
				ball.ballCurrentSpeedY = BALL_SPEEDS[menuState]
				
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

GAME_INTRO_LOOP:
	gameIntroLoopTime = 0.0
	textRoundObj.currentTime = 0.0
	textRoundObj.time = 0.3
	textRoundObj.scaleStart = 1.7
	textRoundObj.scaleEnd = 1.0
	textRoundObj.scale = textRoundObj.scaleStart

	
    while true
		deltaTime = clock.TotalMilliseconds() / 1000.0
        if (deltaTime > STABLE_FPS)
			heroObj1.Update(deltaTime)
			heroObj2.Update(deltaTime)
			textRoundObj.Update(deltaTime)
			
			backObj.Draw()
			heroObj1.Draw()
			heroObj2.Draw()
			
			textRoundObj.Draw()
			
			screen.SwapBuffers()
			
			if (gameIntroLoopTime > GAME_INTRO_DELAY) Goto GAME_LOOP
			gameIntroLoopTime += deltaTime
			
            clock.Mark()
		endif
	end while

GAME_LOOP:
	ball.Hero1Miss = false
	ball.Hero2Miss = false
	ball.x = screenWidth/2
	ball.y = screenHeight/2
	numScoreObj.value = 0

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
			if (id = 0) Goto MENU_LOOP
        else if (event = invalid)
                deltaTime = clock.TotalMilliseconds() / 1000.0
            if (deltaTime > STABLE_FPS)
				heroObj1.Update(deltaTime)
				heroObj2.Update(deltaTime, ball)
				ball.Update(deltaTime, heroObj1, heroObj2, numScoreObj)
				numScoreObj.Update(deltaTime)
				textScoreObj.Update(deltaTime)
				numBestScoreObj.Update(deltaTime)
				textBestScoreObj.Update(deltaTime)

								
				backObj.Draw()
				textScoreObj.Draw()
				numScoreObj.Draw()
				textBestScoreObj.Draw()
				numBestScoreObj.Draw()
				heroObj1.Draw()
				heroObj2.Draw()
				ball.Draw()
                screen.SwapBuffers()
                clock.Mark()
				
				if (ball.Hero1Miss = true) Goto GAME_OVER_LOOP
            endif        
        endif
    end while

GAME_OVER_LOOP:
	gameOverLoopTime = 0.0
	textGameOverObj.currentTime = 0.0
	textGameOverObj.time = 1
	textGameOverObj.scaleStart = 1.7
	textGameOverObj.scaleEnd = 1.0
	textGameOverObj.scale = textGameOverObj.scaleStart
	if (numBestScoreObj.value < numScoreObj.value) numBestScoreObj.value = numScoreObj.value
	
    while true
		event = port.GetMessage()
        if (type(event) = "roUniversalControlEvent")
            id = event.GetInt()
			if ( (id = 0) OR (id = 6) ) Goto MENU_LOOP
        elseif (event = invalid)
			deltaTime = clock.TotalMilliseconds() / 1000.0
			if (deltaTime > STABLE_FPS)
				heroObj1.Update(deltaTime)
				heroObj2.Update(deltaTime)
				textGameOverObj.Update(deltaTime)
				numBestScoreObj.Update(deltaTime)
				textBestScoreObj.Update(deltaTime)
			
				backObj.Draw()
				textBestScoreObj.Draw()
				numBestScoreObj.Draw()
				textScoreObj.Draw()
				numScoreObj.Draw()
				heroObj1.Draw()
				heroObj2.Draw()
			
				textGameOverObj.Draw()
			
				screen.SwapBuffers()
			
				if (gameOverLoopTime > GAME_OVER_DELAY) Goto MENU_LOOP
				gameOverLoopTime += deltaTime
			
				clock.Mark()
			endif
		endif
	end while
	
end function

' SERVISE FUNCTIONS --------------------------------------------------------------
function MinF(_x as float, _y as float) as float
	if (_x > _y) return _y
	return _x
end function

function MaxF(_x as float, _y as float) as float
	if (_x > _y) return _x
	return _y
end function

function ClampF(_v as float, _min=0 as float, _max=1 as float) as float
	min = MinF(_min, _max)
	max = MaxF(_min, _max)
	
	if (_v > max) _v = max
	if (_v < min) _v = min
	return _v
end function

function ClampI(_v as integer, _min as integer, _max as integer) as integer
	if (_v > _max) _v = _max
	if (_v < _min) _v = _min
	return _v
end function

function Blend(_x as float, _y as float, _blendFactor as float) as float
	return _x *(1.0 - _blendFactor) + _y * _blendFactor
end function

' ENGINE API ---------------------------------------------------------------------
function CreateNumberTextObj(_value as integer, _regions as object, _screen as object, _x=0 as float, _y=0 as float, _localOffsetX=0 as float, _localOffsetY=0 as float, _scaleX=1 as float, _scaleY=1 as float, _AnimationUpdate=SimpleNumTextAnimationUpdate as object ) as object
	obj = {
		active			: true
		visible			: true
		value			: _value
		x				: _x
		y				: _y
		localOffsetX	: _localOffsetX
		localOffsetY	: _localOffsetY
		drawX			: 0
		drawY			: 0
		scaleX			: _scaleX
		scaleY			: _scaleY
		length			: 1.0
		loop			: true
		speed			: 1.0
		time			: 0
		regions			: _regions
		screen			: _screen
		actualDrawRegions	: []
		beetweenCharOffset	: 0
		charWidth		: _regions[0].GetWidth()
		charHeight		: _regions[0].GetHeight()
		
		Draw			: DrawNumberText
		Update			: SimpleNumberTextUpdate
		AnimationUpdate	: _AnimationUpdate
	}
		
	return obj
end function

function SimpleNumberTextUpdate(_deltatime=0 as float) as void
	if (m.active = false) return
	m.AnimationUpdate(_deltatime)
	
	m.value = ClampI(m.value, 0, 99999999)
	valueDigitsCount = 1
	
	if (m.value >= 10000000) 
		valueDigitsCount = 8
	elseif (m.value >= 1000000) 
		valueDigitsCount = 7
	elseif (m.value >= 100000) 
		valueDigitsCount = 6
	elseif (m.value >= 10000) 
		valueDigitsCount = 5
	elseif (m.value >= 1000) 
		valueDigitsCount = 4
	elseif (m.value >= 100) 
		valueDigitsCount = 3
	elseif (m.value >= 10) 
		valueDigitsCount = 2
	endif

	m.actualDrawRegions.Clear()
	tempValue = m.value
	divider = 10 ^ (valueDigitsCount - 1)
	
	charCode = 0
	for i=1 to valueDigitsCount
		charCode = tempValue \ divider
		m.actualDrawRegions.Push(m.regions[charCode])
		tempValue = tempValue - charCode * divider
		divider \= 10
	end for
	
	m.drawX = m.x + (-m.localOffsetX - 0.5) * (m.charWidth + m.beetweenCharOffset) * valueDigitsCount * m.scaleX
	m.drawY = m.y + (-m.localOffsetY - 0.5) * m.charHeight * m.scaleY
end function

function SimpleNumTextAnimationUpdate(_deltatime=0 as float) as void
	if (m.active = false) return
	
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
end function

function DrawNumberText() as void
	if (m.visible = false) return
	charOffsetX = 0
	for each actualDrawRegion in m.actualDrawRegions
		m.screen.DrawScaledObject(m.drawX + charOffsetX, m.drawY, m.scaleX, m.scaleY, actualDrawRegion)
		charOffsetX += (m.charWidth + m.beetweenCharOffset) * m.scaleX
	end for
end function

function CreateSpriteObj(_region as object, _screen as object, _x=0 as float, _y=0 as float, _localOffsetX=0 as float, _localOffsetY=0 as float, _scaleX=1 as float, _scaleY=1 as float, _regions=invalid as object, _name="idle" as String, _AnimationUpdate=SimpleSpriteAnimationUpdate as object ) as object
	obj = {
		active	: true
		visible	: true
		name	: _name
		length	: 1.0
		loop	: true
		speed	: 1.0
		time	: 0
		x		: _x
		y		: _y
		localOffsetX	: _localOffsetX
		localOffsetY	: _localOffsetY
		drawX	: 0
		drawY	: 0
		scaleX	: _scaleX
		scaleY	: _scaleY
		regions	: _regions
		currentRegion	: _region
		currentRegionNum	: 0
		screen	: _screen
		
		Draw	: DrawSprite
		Update	: SimpleSpriteUpdate
		AnimationUpdate	: _AnimationUpdate
	}
	
	return obj
end function

function DrawSprite() as void
	if (m.visible = false) return
	m.screen.DrawScaledObject(m.drawX, m.drawY, m.scaleX, m.scaleY, m.currentRegion)
end function

function SimpleSpriteUpdate(_deltatime=0 as float, _x=0 as float, _y=0 as float) as void
	if (m.active = false) return
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
	
	m.spriteObjArray.Lookup(m.currentAnimationName).Update(_deltatime, m.x, m.y)
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

function AIHeroVisObjUpdate(_deltatime=0 as float, _ball=invalid as object) as void
	if (m.active = false) return
	
	if (_ball <> invalid) m.y = _ball.y
	if (m.y > m.maxY) m.y = m.maxY
	if (m.y < m.minY) m.y = m.minY
	
	for each spriteObjName in m.spriteObjArray
		m.spriteObjArray[spriteObjName].Update(_deltatime, m.x, m.y)
	end for
end function

function BallVisObjUpdate(_deltatime as float, _hero1 as object, _hero2 as object, _numScoreObj as object) as void
	if (m.active = false) return
	
	m.x += m.ballCurrentSpeedX
	m.y += m.ballCurrentSpeedY
	
	if (m.x > m.maxX) m.ballCurrentSpeedX *= -1
	if (m.x < m.minX) m.Hero1Miss = true
	if ( (m.y > m.maxY) OR (m.y < m.minY) ) m.ballCurrentSpeedY *= -1
	
	isHero1HitBall = false
	
	toHero1distanceX = Abs(_hero1.x - m.x)
	if (toHero1distanceX < m.radius)
		if ( (m.y < _hero1.y + _hero1.height / 2 ) AND (m.y > _hero1.y - _hero1.height / 2 ) ) 
			m.ballCurrentSpeedX *= -1
			m.x = _hero1.x + m.radius
			isHero1HitBall = true
		endif
	endif
	
	if (isHero1HitBall = true) _numScoreObj.value += _numScoreObj.HIT_BALL_SCORE

	toHero2distanceX = Abs(_hero2.x - m.x)
	if (toHero2distanceX < m.radius)
		if ( (m.y < _hero2.y + _hero2.height / 2 ) AND (m.y > _hero2.y - _hero2.height / 2 ) ) m.ballCurrentSpeedX *= -1
	endif
	
	for each spriteObjName in m.spriteObjArray
		m.spriteObjArray[spriteObjName].Update(_deltatime, m.x, m.y)
	end for
end function

function TextRoundObjUpdate(_deltatime=0 as float) as void
	if (m.currentTime < m.time) 
		blendFactor = m.currentTime / m.time
		m.scale = Blend(m.scaleStart, m.scaleEnd, blendFactor)
	else
		m.scale = ClampF(m.scale, m.scaleStart, m.scaleEnd)
	endif
	m.currentTime += _deltatime
	
	for each spriteObjName in m.spriteObjArray
		m.spriteObjArray[spriteObjName].Update(_deltatime, m.x, m.y)
		m.spriteObjArray[spriteObjName].scaleX = m.scale
		m.spriteObjArray[spriteObjName].scaleY = m.scale
	end for
end function