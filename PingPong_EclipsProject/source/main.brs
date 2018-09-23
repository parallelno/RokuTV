Library "v30/bslDefender.brs" 

function Main() as void
    bitmapset = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/bitmapset.xml"))
	hero1AnimDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/platform.xml"))
	textAnimDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/text.xml"))
	coinGoldAnimDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/coin_gold_anim.xml"))
	coinGreenAnimDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/coin_green_anim.xml"))
	coinRedAnimDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/coin_red_anim.xml"))
    
	scoreRegSection = CreateObject("roRegistrySection", "ScoreTable")
    screen = CreateObject("roScreen", true)
    port = CreateObject("roMessagePort")
	screenWidth = screen.GetWidth()
    screenHeight= screen.GetHeight()
    clock = CreateObject("roTimespan")
    screen.SetMessagePort(port)
    screen.SetAlphaEnable(true)
    codes = bslUniversalControlEventCodes()

	GAME_VARS = {
' --------- GLOBAL VARS ---------------------------------------------------------------------------------
		STABLE_FPS		: (1000.0 / 30.0) / 1000.0 	'stable 30 fps
		PI				: 3.14159
	
		HIT_BALL_SCORE	: 50
		AI_FAIL_SCORE	: 100
		
		BALL_SPEEDS 	: [5, 10, 15] 'speed depends on game difficulty
		AI_HERO_SPEEDS	: [3.3, 7, 13] 'speed depends on game difficulty
		HERO_SPEED		: 10
	
		bestScore		: 0
		
' --------- GAME VARS ---------------------------------------------------------------------------------
		NEW_LIFE_LOOP_DELAY	: 1
		GAME_FIELD_MAX_X	: screenWidth
		GAME_FIELD_MIN_X	: 0
		GAME_FIELD_MAX_Y	: screenHeight
		GAME_FIELD_MIN_Y	: 80

		MAX_LIFE_COUNT		: 6
		START_LIFE_COUNT	: 4
		lifeCount			: 0
		
		MAX_BALL_COUNT		: 4
		ballCount			: 1

' --------- MAIN MENU VARS ---------------------------------------------------------------------------------
		GAME_STATE_MENU_L1	: 0
		GAME_STATE_MENU_L2	: 1
		GAME_STATE_MENU_L3	: 2

		GAME_STATE_MENU_Y	: [ 489, 540, 600 ]
' --------- INTRO VARS ---------------------------------------------------------------------------------	
		GAME_INTRO_DELAY	: 1.0

' --------- GAME OVER VARS ---------------------------------------------------------------------------------	
	GAME_OVER_DELAY		: 3.0
	}
	GAME_VARS.menuState = GAME_VARS.GAME_STATE_MENU_L1

	if ( scoreRegSection.Exists("BestScore")) 
		GAME_VARS.bestScore = scoreRegSection.Read("BestScore").ToInt()
	else 
		scoreRegSection.write("BestScore", GAME_VARS.bestScore.ToStr())
		scoreRegSection.Flush()
	end if
	
	menuBackgroundRegion = textAnimDataSet.regions.menu_background
	menuBackObj = CreateSpriteObj(menuBackgroundRegion, screen, 0, 0, -0.5, -0.5, screenWidth / menuBackgroundRegion.GetWidth(), screenHeight / menuBackgroundRegion.GetHeight())

	menuCursorRegion = bitmapset.regions.menu_cursor
	menuCursorObj = CreateSpriteObj(menuCursorRegion, screen, 270, GAME_VARS.GAME_STATE_MENU_Y[GAME_VARS.menuState], 0, 0, 1, 1)

	textBestScoreObj = CreateSpriteObj(textAnimDataSet.animations.best_score[0], screen, 700, 0, -0.5, -0.5, 0.5, 0.5)	
	numBestScoreObj = CreateNumberTextObj(GAME_VARS.bestScore, textAnimDataSet.animations.numbers_anim, screen, 1000, 5, -0.5, -0.5, 0.5, 0.5)

	textRoundObj = CreateVisObj("Round", screen, screenWidth/2, screenHeight/2, textAnimDataSet, "round", TextRoundObjUpdate)
	textRoundObj.Reset = TextRoundObjReset
	textGameOverObj = CreateVisObj("GameOver", screen, screenWidth/2, screenHeight/2, textAnimDataSet, "game_over", TextRoundObjUpdate)

	textScoreObj = CreateSpriteObj(textAnimDataSet.animations.score[0], screen, 10, 0, -0.5, -0.5, 0.5, 0.5)	
	numScoreObj = CreateNumberTextObj(0, textAnimDataSet.animations.numbers_anim, screen, 170, 5, -0.5, -0.5, 0.5, 0.5)
	numScoreObj.HIT_BALL_SCORE = GAME_VARS.HIT_BALL_SCORE
	numScoreObj.AI_FAIL_SCORE = GAME_VARS.AI_FAIL_SCORE

	backgroundRegion = bitmapset.regions.background
	backObj = CreateSpriteObj(backgroundRegion, screen, 0, 0, -0.5, -0.5, screenWidth / backgroundRegion.GetWidth(), screenHeight / backgroundRegion.GetHeight())

	LivesObj = []
	for i=0 to GAME_VARS.MAX_LIFE_COUNT-1
		lifeObj = CreateSpriteObj(menuCursorRegion, screen, 400 + 36*i, 25)
		LivesObj.Push(lifeObj)
	end for
	
	' it gives a life
	' chance has to be dependent on expirience, level and life count. the core idea - keep player surviving
	coin = CreateVisObj("coin", screen, screenWidth/2, screenHeight/2, coinGoldAnimDataSet, "idle", CoinVisObjUpdate)
	coin.scaleX = 64
	coin.scaleY = 64
	coin.STATE_INTRO_PREPARING = 0
	coin.STATE_INTRO = 1
	coin.STATE_GAME = 2
	coin.STATE_DEATH = 3
	coin.state = coin.STATE_DEATH
	coin.FLASHING_SPEED = 15
	coin.flashingTimer = 1
	coin.minX = 1
	coin.maxX = screenWidth
	coin.minY = GAME_VARS.GAME_FIELD_MIN_Y + coin.scaleY
	coin.maxY = GAME_VARS.GAME_FIELD_MAX_Y - coin.scaleY
	coin.SPEED_X = 3
	coin.SPEED_Y = 3
	coin.speedX = coin.SPEED_X
	coin.speedY = coin.SPEED_Y
	coin.spawnX = screenWidth/2
	coin.spawnChance = 0.0005
	coin.visible = false
	coin.width = 20
	coin.height = 30
	
	' expand a desk length	
	' make additional small expantion.
	coinGreen = CreateVisObj("coinGreen", screen, screenWidth/2, screenHeight/2, coinGreenAnimDataSet, "idle", CoinGreenVisObjUpdate)
	coinGreen.scaleX = 64
	coinGreen.scaleY = 64
	coinGreen.STATE_INTRO_PREPARING = 0
	coinGreen.STATE_INTRO = 1
	coinGreen.STATE_GAME = 2
	coinGreen.STATE_DEATH = 3
	coinGreen.state = coinGreen.STATE_DEATH
	coinGreen.FLASHING_SPEED = 15
	coinGreen.flashingTimer = 1
	coinGreen.minX = 0
	coinGreen.maxX = screenWidth
	coinGreen.minY = GAME_VARS.GAME_FIELD_MIN_Y + coinGreen.scaleY
	coinGreen.maxY = GAME_VARS.GAME_FIELD_MAX_Y - coinGreen.scaleY
	coinGreen.SPEED_X = 3
	coinGreen.SPEED_Y = 3
	coinGreen.speedX = coinGreen.SPEED_X
	coinGreen.speedY = coinGreen.SPEED_Y
	coinGreen.spawnX = screenWidth/2
	coinGreen.spawnChance = 0.004
	coinGreen.visible = false
	coinGreen.width = 20
	coinGreen.height = 30
	
	' gives two rockets
	coinRed = CreateVisObj("CoinRed", screen, screenWidth/2, screenHeight/2, coinRedAnimDataSet, "idle", CoinRedVisObjUpdate)
	coinRed.scaleX = 64
	coinRed.scaleY = 64
	coinRed.STATE_INTRO_PREPARING = 0
	coinRed.STATE_INTRO = 1
	coinRed.STATE_GAME = 2
	coinRed.STATE_DEATH = 3
	coinRed.state = coinRed.STATE_DEATH
	coinRed.FLASHING_SPEED = 15
	coinRed.flashingTimer = 1
	coinRed.minX = 0
	coinRed.maxX = screenWidth
	coinRed.minY = GAME_VARS.GAME_FIELD_MIN_Y + coinRed.scaleY
	coinRed.maxY = GAME_VARS.GAME_FIELD_MAX_Y - coinRed.scaleY
	coinRed.SPEED_X = 3
	coinRed.SPEED_Y = 3
	coinRed.speedX = coinRed.SPEED_X
	coinRed.speedY = coinRed.SPEED_Y
	coinRed.spawnX = screenWidth/2
	coinRed.spawnChance = 0.005
	coinRed.visible = false
	coinRed.width = 20
	coinRed.height = 30
	
	balls =  []
	for i=0 to GAME_VARS.MAX_BALL_COUNT-1
		ball = CreateVisObj("ball", screen, screenWidth/2, screenHeight/2, bitmapset, "idle2", BallVisObjUpdate)
		ball.Init = BallVisObjInit
		ball.Reset = BallVisObjReset
		ball.Init(GAME_VARS)
		balls.Push(ball)
	end for
	balls[0].state = balls[0].STATE_INTRO_PREPARING
		
	heroObj1 = CreateVisObj("hero1", screen, 100, screenHeight/2, hero1AnimDataSet, "idle", HeroVisObjUpdate)
	heroObj1.Init = HeroVisObjInit
	heroObj1.Reset = HeroVisObjReset
	heroObj1.Init(GAME_VARS)
			
	heroObj2 = CreateVisObj("hero2", screen, screenWidth - 100, screenHeight/2, hero1AnimDataSet, "idle", AIHeroVisObjUpdate)
	heroObj2.Init = AIHeroVisObjInit
	heroObj2.Reset = AIHeroVisObjReset
	heroObj2.Init(GAME_VARS) 

	clock.Mark()

MENU_LOOP:
    while true
        event = port.GetMessage()
        if (type(event) = "roUniversalControlEvent")
            id = event.GetInt()
			if (id = codes.BUTTON_UP_PRESSED)
				GAME_VARS.menuState -= 1
				if (GAME_VARS.menuState < 0 ) GAME_VARS.menuState = 0
			endif
			if (id = codes.BUTTON_DOWN_PRESSED)
				GAME_VARS.menuState += 1
				if (GAME_VARS.menuState > 2 ) GAME_VARS.menuState = 2
			endif
			if (id = 6)				
				Goto GAME_INTRO_LOOP
			endif
        else if (event = invalid)
                deltaTime = clock.TotalMilliseconds() / 1000.0
            if (deltaTime > GAME_VARS.STABLE_FPS)
				menuCursorObj.y = GAME_VARS.GAME_STATE_MENU_Y[GAME_VARS.menuState]
				menuCursorObj.Update()
				numBestScoreObj.Update(deltaTime)
				textBestScoreObj.Update(deltaTime)

				
				menuBackObj.Draw()
				textBestScoreObj.Draw()
				numBestScoreObj.Draw()
                menuCursorObj.Draw()
				screen.SwapBuffers()
                clock.Mark()
            endif        
        endif
    end while

GAME_INTRO_LOOP:
	loopTime = 0.0
	textRoundObj.Reset(GAME_VARS)
	heroObj1.Reset(GAME_VARS)
	heroObj2.Reset(GAME_VARS)
	
    while true
		deltaTime = clock.TotalMilliseconds() / 1000.0
        if (deltaTime > GAME_VARS.STABLE_FPS)
			heroObj1.Update(deltaTime)
			heroObj2.Update(deltaTime)
			textRoundObj.Update(deltaTime)
			
			backObj.Draw()
			heroObj1.Draw()
			heroObj2.Draw()
			
			textRoundObj.Draw()
			
			screen.SwapBuffers()
			
			if (loopTime > GAME_VARS.GAME_INTRO_DELAY) Goto NEW_GAME_LOOP
			loopTime += deltaTime
			
            clock.Mark()
		endif
	end while

NEW_GAME_LOOP:
	numScoreObj.value = 0
	GAME_VARS.lifeCount = GAME_VARS.START_LIFE_COUNT
	
NEW_LIFE_LOOP:
	loopTime = 0.0
	
	for i=0 to GAME_VARS.MAX_BALL_COUNT-1	
		balls[i].Reset(GAME_VARS)
	end for
	balls[0].state = balls[0].STATE_INTRO_PREPARING
	
	heroObj1.Reset(GAME_VARS)
	heroObj2.Reset(GAME_VARS)
	
	coin.state = coin.STATE_DEATH
	coinGreen.state = coinGreen.STATE_DEATH

    while true
		deltaTime = clock.TotalMilliseconds() / 1000.0
		if (deltaTime > GAME_VARS.STABLE_FPS)
			balls[0].Update(deltaTime, heroObj1, heroObj2, numScoreObj)
			numScoreObj.Update(deltaTime)
			textScoreObj.Update(deltaTime)
			numBestScoreObj.Update(deltaTime)
			textBestScoreObj.Update(deltaTime)
			for i=0 to GAME_VARS.lifeCount-1
				LivesObj[i].Update(deltaTime)
			end for
								
			backObj.Draw()
			textScoreObj.Draw()
			numScoreObj.Draw()
			textBestScoreObj.Draw()
			numBestScoreObj.Draw()
			heroObj1.Draw()
			heroObj2.Draw()
			for i=0 to GAME_VARS.MAX_BALL_COUNT-1
				balls[i].Draw()
			endfor
			for i=0 to GAME_VARS.lifeCount-1
				LivesObj[i].Draw()
			end for
			screen.SwapBuffers()

			if (loopTime > GAME_VARS.NEW_LIFE_LOOP_DELAY) Goto GAME_LOOP
			loopTime += deltaTime

			clock.Mark()
		endif        
	end while

GAME_LOOP:
EXIT_GAME:
	
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

function MinI(_x as integer, _y as integer) as integer
	if (_x > _y) return _y
	return _x
end function

function MaxI(_x as integer, _y as integer) as integer
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
	min = MinI(_min, _max)
	max = MaxI(_min, _max)
	
	if (_v > max) _v = max
	if (_v < min) _v = min
	return _v
end function

function Blend(_x as float, _y as float, _blendFactor as float) as float
	return _x *(1.0 - _blendFactor) + _y * _blendFactor
end function

' COLLISION API /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function CreateCollisionEngine() as object
	obj = {
		id						: 0 ' id for next created obj
		active					: true
		collisionGroups			: {} ' {groupName : {id, obj}}
		COLLISION_TYPE_BOX		: 0
		COLLISION_TYPE_CIRCLE	: 1
		
		AddCollision	: AddCollision
		Update			: CollisionEngineUpdate
	}
	return obj
end function

function CollisionEngineUpdate()
	for each collisionGroupName in collisionGroups
		collisionGroup = collisionGroups[collisionGroupName]
		for each collisionID in collisionGroup
			collision = collisionGroup[collisionID]
			collision.collidingObjects = {}
			collision.collidedObjObects = {}
			collidingObjects = m.collisionGroups.Lookup(collision.group)
			if (collidingObjects <> invalid) collision.collidingObjects.Append(collidingObjects)
		end for
	end for
	
	for each collisionGroupName in collisionGroups
		collisionGroup = collisionGroups[collisionGroupName]
		for each collisionID in collisionGroup
			collisionGroup[collisionID].Update()
		end for
	end for
end function

function AddCollision(_collisionType as integer, _group as String, _collidingGroupList as object, _x=0 as float, _y=0 as float, _scaleX=1 as float, _scaleY=1 as float) as void
	obj = {} 'CreateCollisionBox(m.id, _collisionType, _group, _collidingGroupList, m, _x, _y, _scaleX, _scaleY)
	group = m.collisionGroups.Lookup(_group)
	idName = m.id.ToStr()
	if (group = invalid)
		newGroup = {idName : obj}
		m.collisionGroups.AddReplace(_group, newGroup)
	else
		group.AddReplace(idName, obj)
		m.collisionGroups.AddReplace(_group, group)
	end if
	
	m.id +=1
end function

function CreateCollision(_id as integer, _collisionType as integer, _group as String, _collidingGroupList as object, _collisionEngine as object, _x as float, _y as float, _scaleX=1 as float, _scaleY=1 as float) as object
	obj = {
		id : _id
		active	: true
		collisionType	: _collisionType
		group	: _group
		collidingGroupList	: _collidingGroupList
		collisionEngine	: _collisionEngine
		x		: _x
		y		: _y		
		scaleX	: _scaleX
		scaleY	: _scaleY
		speedX	: 0
		speedY	: 0
		collidingObjects	: []
		collidedObjObects	: []
		
		Update	: CollisionUpdate
		Destroy	: CollisionDestroy
	}
	return obj
end function

function CollisionDestroy()
	group = m.collisionEngine.collisionGroups.Lookup(m.group)
	group.Delete(m.id.ToStr())
	if (group.Count() <> 0) 
		m.collisionEngine.collisionGroups.AddReplace(group)
	else
		m.collisionEngine.collisionGroups.Delete(m.group)
	end if
end function

function CollisionUpdate() as void
	' check collision with theSameCollisionGroupList (it need to be updated each AddCollisionObj call)
	' if it is, remove object from list in collided and add collided object to collided list
	' finaly we will have list only with collided objects
	
end function

function CollisionBoxCheck(player1 as object, player2 as object) as boolean
	if ((player1 = invalid) OR (player2 = invalid)) return false
	
	dx = Abs(player1.x - player2.x)
	dy = Abs(player1.y - player2.y)
	bx = player1.width + player2.width
	by = player1.height + player2.height
	
	if ( (dx < bx) AND (dy < by) ) return true
	return false
end function

' GRAPHICS API /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
	else if (m.value >= 1000000) 
		valueDigitsCount = 7
	else if (m.value >= 100000) 
		valueDigitsCount = 6
	else if (m.value >= 10000) 
		valueDigitsCount = 5
	else if (m.value >= 1000) 
		valueDigitsCount = 4
	else if (m.value >= 100) 
		valueDigitsCount = 3
	else if (m.value >= 10) 
		valueDigitsCount = 2
	end if

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
		width	: 64
		height	: 64
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

'/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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

function TextRoundObjReset(_globalVars as object) as void
	m.currentTime = 0.0
	m.time = 0.3
	m.scaleStart = 1.7
	m.scaleEnd = 1.0
	m.scale = m.scaleStart
end function

function CoinVisObjUpdate(_deltatime=0 as float, _hero1=invalid as object, _lifeCount=invalid as object, _globalVars=invalid as object) as void
	if (m.state = m.STATE_DEATH)
		m.visible = false
		return
	end if
	
	if (m.state = m.STATE_INTRO_PREPARING)
		m.state = m.STATE_INTRO
		m.y = Rnd(0) * (m.maxY - m.minY) + m.minY
		m.x = m.spawnX 
		m.visible = true
	end if
	
	if (m.state = m.STATE_INTRO)
		if (Sin(m.flashingTimer * m.FLASHING_SPEED) < 0) 
			m.visible = false
		else 
			m.visible = true
		end if
		m.flashingTimer -= _deltatime
		if (m.flashingTimer < 0) 
			m.state = m.STATE_GAME
			m.visible = true
		end if
	end if
	
	if (m.state = m.STATE_GAME)
		m.x -= m.speedX
		if (m.x < m.minX) 
			m.state = m.STATE_DEATH
			m.visible = false
		end if
	end if
	
	if ((_hero1 <> invalid) AND (_lifeCount <> invalid) AND (_globalVars <> invalid))
		isCollided = CollisionBoxCheck(m, _hero1)
		if ((isCollided = true) AND (m.state = m.STATE_GAME) )
				m.state = m.STATE_DEATH
				m.visible = false
				_lifeCount[0] = _lifeCount[0] + 1
				_lifeCount[0] = ClampF(_lifeCount[0], 0, _globalVars.MAX_LIFE_COUNT)
		end if
	end if
	
	for each spriteObjName in m.spriteObjArray
		m.spriteObjArray[spriteObjName].Update(_deltatime, m.x, m.y)
	end for
end function

function CoinGreenVisObjUpdate(_deltatime=0 as float, _hero1=invalid as object, _globalVars=invalid as object) as void
	if (m.state = m.STATE_DEATH) 
		m.visible = false
		return
	end if
	
	if (m.state = m.STATE_INTRO_PREPARING)
		m.state = m.STATE_INTRO
		m.y = Rnd(0) * (m.maxY - m.minY) + m.minY
		m.x = m.spawnX 
		m.visible = true
	end if
	
	if (m.state = m.STATE_INTRO)
		if (Sin(m.flashingTimer * m.FLASHING_SPEED) < 0) 
			m.visible = false
		else 
			m.visible = true
		end if
		m.flashingTimer -= _deltatime
		if (m.flashingTimer < 0) 
			m.state = m.STATE_GAME
			m.visible = true
		end if
	end if
	
	if (m.state = m.STATE_GAME)
		m.x -= m.speedX
		if (m.x < m.minX) 
			m.state = m.STATE_DEATH
			m.visible = false
		end if
	end if
	
	if ((_hero1 <> invalid) AND (_globalVars <> invalid))
		isCollided = CollisionBoxCheck(m, _hero1)
		if ( (isCollided = true) AND (m.state = m.STATE_GAME) )
				m.state = m.STATE_DEATH
				m.visible = false
				_hero1.currentAnimationName = _hero1.bigAnim
				_hero1.height = _hero1.bigHeight
				_hero1.maxY = _globalVars.GAME_FIELD_MAX_Y - _hero1.height
				_hero1.minY = _globalVars.GAME_FIELD_MIN_Y + _hero1.height
				_hero1.bigTimer = _hero1.BIG_TIME
		end if
	end if
	
	for each spriteObjName in m.spriteObjArray
		m.spriteObjArray[spriteObjName].Update(_deltatime, m.x, m.y)
	end for
end function

function CoinRedVisObjUpdate(_deltatime=0 as float, _hero1=invalid as object, _globalVars=invalid as object) as void
	if (m.state = m.STATE_DEATH) 
		m.visible = false
		return
	end if
	
	if (m.state = m.STATE_INTRO_PREPARING)
		m.state = m.STATE_INTRO
		m.y = Rnd(0) * (m.maxY - m.minY) + m.minY
		m.x = m.spawnX 
		m.visible = true
	end if
	
	if (m.state = m.STATE_INTRO)
		if (Sin(m.flashingTimer * m.FLASHING_SPEED) < 0) 
			m.visible = false
		else 
			m.visible = true
		end if
		m.flashingTimer -= _deltatime
		if (m.flashingTimer < 0) 
			m.state = m.STATE_GAME
			m.visible = true
		end if
	end if
	
	if (m.state = m.STATE_GAME)
		m.x -= m.speedX
		if (m.x < m.minX) 
			m.state = m.STATE_DEATH
			m.visible = false
		end if
	end if
	
	if ((_hero1 <> invalid) AND (_globalVars <> invalid))
		isCollided = CollisionBoxCheck(m, _hero1)
		if ( (isCollided = true) AND (m.state = m.STATE_GAME) )
				m.state = m.STATE_DEATH
				m.visible = false
				_hero1.currentAnimationName = _hero1.bigAnim
				_hero1.height = _hero1.bigHeight
				_hero1.maxY = _globalVars.GAME_FIELD_MAX_Y - _hero1.height
				_hero1.minY = _globalVars.GAME_FIELD_MIN_Y + _hero1.height
				_hero1.bigTimer = _hero1.BIG_TIME
		end if
	end if
	
	for each spriteObjName in m.spriteObjArray
		m.spriteObjArray[spriteObjName].Update(_deltatime, m.x, m.y)
	end for
end function

function BallVisObjInit(_globalVars as object) as void
	m.ballCurrentSpeedX = _globalVars.BALL_SPEEDS[_globalVars.menuState]
	m.ballCurrentSpeedY = _globalVars.BALL_SPEEDS[_globalVars.menuState]
	m.radius = 64
	m.maxX = _globalVars.GAME_FIELD_MAX_X
	m.minX = _globalVars.GAME_FIELD_MIN_X
	m.maxY = _globalVars.GAME_FIELD_MAX_Y - m.radius
	m.minY = _globalVars.GAME_FIELD_MIN_Y + m.radius
	m.STATE_INTRO_PREPARING = 0
	m.STATE_INTRO = 1
	m.STATE_GAME = 2
	m.STATE_DEATH = 3
	m.state = m.STATE_DEATH
	m.FLASHING_SPEED = 15
	m.flashingTimer = 1
	m.INTRO_ANIMATION = "idle3"
	m.GAME_ANIMATION = "idle2"
	m.spawnX = _globalVars.GAME_FIELD_MAX_X / 2
	m.spawnY = _globalVars.GAME_FIELD_MAX_Y / 2
	m.Hero1Miss = false
	m.Hero2Miss = false
end function

function BallVisObjReset(_globalVars as object) as void
		m.state = m.STATE_DEATH
		m.x = m.spawnX
		m.y = m.spawnY
		m.ballCurrentSpeedX = 0
		m.ballCurrentSpeedY = 0
end function

function BallVisObjUpdate(_deltatime as float, _hero1 as object, _hero2 as object, _numScoreObj as object) as void
	if (m.active = false) return
	
	if (m.state = m.STATE_DEATH)
		m.visible = false
		return
	end if
	
	if (m.state = m.STATE_INTRO_PREPARING)
		m.state = m.STATE_INTRO
		m.x = m.spawnX
		m.y = m.spawnY
		m.currentAnimationName = m.INTRO_ANIMATION
		m.visible = true
	end if
	
	if (m.state = m.STATE_INTRO)
		if (Sin(m.flashingTimer * m.FLASHING_SPEED) < 0) 
			m.visible = false
		else 
			m.visible = true
		end if
		m.flashingTimer -= _deltatime
		if (m.flashingTimer < 0) 
			m.state = m.STATE_GAME
			m.visible = true
			m.currentAnimationName = m.GAME_ANIMATION
		end if
	end if
	
	if (m.state = m.STATE_GAME)
		m.x += m.ballCurrentSpeedX
		m.y += m.ballCurrentSpeedY
		if (m.x < m.minX) m.Hero1Miss = true
		if (m.x > m.maxX) 
			m.Hero2Miss = true
			_numScoreObj.value += _numScoreObj.AI_FAIL_SCORE
		end if
		if ( (m.y > m.maxY) OR (m.y < m.minY) ) m.ballCurrentSpeedY *= -1
	
		isHero1HitBall = false
	
		toHero1distanceX = Abs(_hero1.x - m.x)
		if (toHero1distanceX < m.radius)
			if ( (m.y < _hero1.y + _hero1.height ) AND (m.y > _hero1.y - _hero1.height ) ) 
				m.ballCurrentSpeedX *= -1
				m.ballCurrentSpeedY += _hero1.heroCurrentSpeed * 0.3
				m.ballCurrentSpeedX *= 1.1
			
				m.x = _hero1.x + m.radius
				isHero1HitBall = true
			endif
		endif
	
		if (isHero1HitBall = true) _numScoreObj.value += _numScoreObj.HIT_BALL_SCORE

		isHero2HitBall = false
		toHero2distanceX = Abs(_hero2.x - m.x)
		if (toHero2distanceX < m.radius)
			if ( (m.y < _hero2.y + _hero2.height ) AND (m.y > _hero2.y - _hero2.height ) ) 
				m.ballCurrentSpeedX *= -1
				m.ballCurrentSpeedY += _hero2.heroCurrentSpeed * 0.3
				m.ballCurrentSpeedX *= 1.1
			
				m.x = _hero2.x - m.radius
				isHero2HitBall = true
			else
				isHero2HitBall = false
			end if
		end if
	end if
	
	for each spriteObjName in m.spriteObjArray
		m.spriteObjArray[spriteObjName].Update(_deltatime, m.x, m.y)
	end for
end function

function HeroVisObjUpdate(_deltatime=0 as float, _globalVars=invalid as object) as void
	if (m.active = false) return
	
	m.y += m.heroCurrentSpeed
	if (m.y > m.maxY) m.y = m.maxY
	if (m.y < m.minY) m.y = m.minY
	
	if (_globalVars <> invalid)
		if (m.currentAnimationName = m.bigAnim) 
			m.bigTimer -= _deltatime
			if (m.bigTimer <= 0)
				m.currentAnimationName = m.commonAnim
				m.height = m.commonHeight
				m.maxY = _globalVars.GAME_FIELD_MAX_Y - m.height
				m.minY = _globalVars.GAME_FIELD_MIN_Y + m.height
				m.bigTimer = 0
			end if
		end if
	end if
				
	for each spriteObjName in m.spriteObjArray
		m.spriteObjArray[spriteObjName].Update(_deltatime, m.x, m.y)
	end for
end function

function HeroVisObjInit(_globalVars as object) as void
	m.commonHeight = 73
	m.width = 24
	m.commonAnim = "idle"
	m.bigHeight = 132
	m.bigAnim = "idle2"
	m.BIG_TIME = 7
end function

function HeroVisObjReset(_globalVars as object) as void
	m.height = m.commonHeight
	m.heroSpeed = _globalVars.HERO_SPEED
	m.heroCurrentSpeed = 0
	m.maxY = _globalVars.GAME_FIELD_MAX_Y - m.height
	m.minY = _globalVars.GAME_FIELD_MIN_Y + m.height
	m.isBig = false
	m.bigTimer = 0
	m.y = _globalVars.GAME_FIELD_MAX_Y / 2
	m.currentAnimationName = m.commonAnim
end function

function AIHeroVisObjInit(_globalVars as object) as void
	m.commonHeight = 73
	m.width = 24
	m.commonAnim = "idle"
	m.bigHeight = 132
	m.bigAnim = "idle2"
	m.BIG_TIME = 7
end function

function AIHeroVisObjReset(_globalVars as object) as void
	m.height = m.commonHeight
	m.heroCurrentSpeed = 0
	m.maxY = _globalVars.GAME_FIELD_MAX_Y - m.height
	m.minY = _globalVars.GAME_FIELD_MIN_Y + m.height
	m.isBig = false
	m.bigTimer = 0
	m.y = _globalVars.GAME_FIELD_MAX_Y / 2
	m.heroSpeed = _globalVars.AI_HERO_SPEEDS[_globalVars.menuState]
	m.currentAnimationName = m.commonAnim
end function

function AIHeroVisObjUpdate(_deltatime=0 as float, _ball=invalid as object) as void
	if (m.active = false) return
	if (_ball = invalid) Goto SPRITES_UPDATE
	
	m.heroCurrentSpeed = (_ball.y - m.y) * 0.4
	if (Abs(m.heroCurrentSpeed) > m.heroSpeed) m.heroCurrentSpeed = Sgn(m.heroCurrentSpeed) * m.heroSpeed

	m.y += m.heroCurrentSpeed
	if (m.y > m.maxY) m.y = m.maxY
	if (m.y < m.minY) m.y = m.minY
	
SPRITES_UPDATE:
	for each spriteObjName in m.spriteObjArray
		m.spriteObjArray[spriteObjName].Update(_deltatime, m.x, m.y)
	end for
end function