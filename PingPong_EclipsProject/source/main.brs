Library "v30/bslDefender.brs" 

function Main() as void
    bitmapset = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/bitmapset.xml"))
	hero1AnimDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/platform.xml"))
	textAnimDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/text.xml"))
	coinGoldAnimDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/coin_gold_anim.xml"))
	coinGreenAnimDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/coin_green_anim.xml"))
	coinRedAnimDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/coin_red_anim.xml"))
	cubeRedAnimDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/cube_red_anim.xml"))
    
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
		hero1lifeCount		: 0
		hero2lifeCount		: 0
		
		MAX_BALL_COUNT		: 4
		isLastMissedBallHeroes	: false
		
		MAX_ROCKET_COUNT	: 4

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

	textBestScoreObj = CreateSpriteObj(textAnimDataSet.animations.best_score[0], screen, 600, 0, -0.5, -0.5, 0.5, 0.5)	
	numBestScoreObj = CreateNumberTextObj(GAME_VARS.bestScore, textAnimDataSet.animations.numbers_anim, screen, 900, 5, -0.5, -0.5, 0.5, 0.5)

	textRoundObj = CreateVisObj("Round", screen, screenWidth/2, screenHeight/2, textAnimDataSet, "round", TextRoundObjUpdate)
	textRoundObj.Reset = TextRoundObjReset
	textGameOverObj = CreateVisObj("GameOver", screen, screenWidth/2, screenHeight/2, textAnimDataSet, "game_over", TextRoundObjUpdate)

	textScoreObj = CreateSpriteObj(textAnimDataSet.animations.score[0], screen, 36*6 + 30, 0, -0.5, -0.5, 0.5, 0.5)	
	numScoreObj = CreateNumberTextObj(0, textAnimDataSet.animations.numbers_anim, screen, 36*6 + 195, 5, -0.5, -0.5, 0.5, 0.5)
	numScoreObj.HIT_BALL_SCORE = GAME_VARS.HIT_BALL_SCORE
	numScoreObj.AI_FAIL_SCORE = GAME_VARS.AI_FAIL_SCORE

	backgroundRegion = bitmapset.regions.background
	backObj = CreateSpriteObj(backgroundRegion, screen, 0, 0, -0.5, -0.5, screenWidth / backgroundRegion.GetWidth(), screenHeight / backgroundRegion.GetHeight())

	hero1LivesObj = []
	for i=0 to GAME_VARS.MAX_LIFE_COUNT-1
		lifeObj = CreateSpriteObj(menuCursorRegion, screen, 20 + 36*i, 25)
		hero1LivesObj.Push(lifeObj)
	end for

	hero2LivesObj = []
	for i=0 to GAME_VARS.MAX_LIFE_COUNT-1
		lifeObj = CreateSpriteObj(menuCursorRegion, screen, screenWidth-200 + 36*i, 25)
		hero2LivesObj.Push(lifeObj)
	end for
	
	' it gives a life
	coin = CreateVisObj("coin", screen, screenWidth/2, screenHeight/2, coinGoldAnimDataSet, "idle", CoinVisObjUpdate)
	coin.Init = CoinVisObjInit
	coin.Reset = CoinVisObjReset
	coin.Spawn = CoinVisObjSpawn
	coin.Init(GAME_VARS)
	
	
	' expand a desk length	
	coinGreen = CreateVisObj("coinGreen", screen, screenWidth/2, screenHeight/2, coinGreenAnimDataSet, "idle", CoinGreenVisObjUpdate)
	coinGreen.Init = CoinGreenVisObjInit
	coinGreen.Reset = CoinGreenVisObjReset
	coinGreen.Spawn = CoinGreenVisObjSpawn
	coinGreen.Init(GAME_VARS)
	
	' gives two rockets
	coinRed = CreateVisObj("CoinRed", screen, screenWidth/2, screenHeight/2, coinRedAnimDataSet, "idle", CoinRedVisObjUpdate)
	coinRed.Init = CoinRedVisObjInit
	coinRed.Reset = CoinRedVisObjReset
	coinRed.Spawn = CoinRedVisObjSpawn
	coinRed.Init(GAME_VARS)
	
	' gives two rockets
	rocketLaunchers = []
	for i=0 to 3 
		rocketLauncher = CreateVisObj("RocketLauncher", screen, screenWidth/2, screenHeight/2, cubeRedAnimDataSet, "idle", RocketLauncherUpVisObjUpdate)
		rocketLauncher.Init = RocketLauncherUpVisObjInit
		rocketLauncher.Reset = RocketLauncherUpVisObjReset
		rocketLauncher.Spawn = RocketLauncherUpVisObjSpawn
		rocketLaunchers.Push(rocketLauncher)
	end for
	rocketLaunchers[0].Init(GAME_VARS, 1)
	rocketLaunchers[1].Init(GAME_VARS, -1)
	rocketLaunchers[2].Init(GAME_VARS, 1)
	rocketLaunchers[3].Init(GAME_VARS, -1)

	rockets = []
	for i=0 to GAME_VARS.MAX_ROCKET_COUNT-1
		rocket = CreateVisObj("Rocket", screen, screenWidth/2, screenHeight/2, cubeRedAnimDataSet, "idle", RocketVisObjUpdate)
		rocket.Init = RocketVisObjInit
		rocket.Reset = RocketVisObjReset
		rocket.Spawn = RocketVisObjSpawn
		rocket.Init(GAME_VARS)
		rockets.Push(rocket)
	end for
	
	balls =  []
	for i=0 to GAME_VARS.MAX_BALL_COUNT-1
		ball = CreateVisObj("ball", screen, screenWidth/2, screenHeight/2, bitmapset, "idle2", BallVisObjUpdate)
		ball.Init = BallVisObjInit
		ball.Reset = BallVisObjReset
		ball.Init(GAME_VARS)
		ball.Start = BallVisObjStart
		balls.Push(ball)
	end for
	balls[0].state = balls[0].STATE_INTRO_PREPARING
		
	heroObj1 = CreateVisObj("hero1", screen, 100, screenHeight/2, hero1AnimDataSet, "idle", HeroVisObjUpdate)
	heroObj1.Init = HeroVisObjInit
	heroObj1.Reset = HeroVisObjReset
	heroObj1.Init(GAME_VARS, rocketLaunchers[0], rocketLaunchers[1])
			
	heroObj2 = CreateVisObj("hero2", screen, screenWidth - 100, screenHeight/2, hero1AnimDataSet, "idle", AIHeroVisObjUpdate)
	heroObj2.Init = AIHeroVisObjInit
	heroObj2.Reset = AIHeroVisObjReset
	heroObj2.Init(GAME_VARS, rocketLaunchers[2], rocketLaunchers[3]) 

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
			if (id = 0) Goto EXIT_GAME
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
			heroObj2.Update(deltaTime, GAME_VARS)
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
	GAME_VARS.hero1lifeCount = GAME_VARS.START_LIFE_COUNT
	GAME_VARS.hero2lifeCount = GAME_VARS.START_LIFE_COUNT
	
NEW_LIFE_LOOP:
	loopTime = 0.0
	
	for i=0 to GAME_VARS.MAX_BALL_COUNT-1	
		balls[i].Reset(GAME_VARS)
	end for
	balls[0].state = balls[0].STATE_INTRO_PREPARING

	for i=0 to GAME_VARS.MAX_ROCKET_COUNT-1	
		rockets[i].Reset()
	end for
	
	heroObj1.Reset(GAME_VARS)
	heroObj2.Reset(GAME_VARS)
	heroObj1.Update(0, GAME_VARS)
	heroObj2.Update(0, GAME_VARS, balls)
	
	coin.Reset()
	coinGreen.Reset()
	coinRed.Reset()
	heroObj1.rocketLauncherUp.Reset()
	heroObj1.rocketLauncherDown.Reset()

    while true
		deltaTime = clock.TotalMilliseconds() / 1000.0
		if (deltaTime > GAME_VARS.STABLE_FPS)
			for i=0 to GAME_VARS.MAX_BALL_COUNT-1
				balls[i].Update(deltaTime, heroObj1, heroObj2, numScoreObj, GAME_VARS)
			endfor
			numScoreObj.Update(deltaTime)
			textScoreObj.Update(deltaTime)
			numBestScoreObj.Update(deltaTime)
			textBestScoreObj.Update(deltaTime)
			for i=0 to GAME_VARS.hero1lifeCount-1
				hero1LivesObj[i].Update(deltaTime)
			end for
			for i=0 to GAME_VARS.hero2lifeCount-1
				hero2LivesObj[i].Update(deltaTime)
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
			for i=0 to GAME_VARS.hero1lifeCount-1
				hero1LivesObj[i].Draw()
			end for
			for i=0 to GAME_VARS.hero2lifeCount-1
				hero2LivesObj[i].Draw()
			end for
			screen.SwapBuffers()

			if (loopTime > GAME_VARS.NEW_LIFE_LOOP_DELAY) Goto GAME_LOOP
			loopTime += deltaTime

			clock.Mark()
		endif        
	end while

GAME_LOOP:
	balls[0].Start(GAME_VARS)

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
			if (id = 6)	
				if (heroObj1.rocketLauncherUp.state = heroObj1.rocketLauncherUp.STATE_GAME)
					rocket = GetDeadRocket(rockets, GAME_VARS)
					if (rocket <> invalid) 
						rocket.Spawn(heroObj1.rocketLauncherUp.y, 1)
						heroObj1.rocketLauncherUp.state = heroObj1.rocketLauncherUp.STATE_DEATH
					end if
				else if (heroObj1.rocketLauncherDown.state = heroObj1.rocketLauncherDown.STATE_GAME)
					rocket = GetDeadRocket(rockets, GAME_VARS)
					if (rocket <> invalid) 
						rocket.Spawn(heroObj1.rocketLauncherDown.y, 1)
						heroObj1.rocketLauncherDown.state = heroObj1.rocketLauncherDown.STATE_DEATH
					end if
				end if
			endif
        else if (event = invalid)
			deltaTime = clock.TotalMilliseconds() / 1000.0
            if (deltaTime > GAME_VARS.STABLE_FPS)
				heroObj1.Update(deltaTime, GAME_VARS)
				heroObj2.Update(deltaTime, GAME_VARS, balls)
				for i=0 to GAME_VARS.MAX_BALL_COUNT-1
					balls[i].Update(deltaTime, heroObj1, heroObj2, numScoreObj, GAME_VARS)
				end for
				
				for i=0 to GAME_VARS.MAX_ROCKET_COUNT-1	
					rockets[i].Update(deltaTime, heroObj1, heroObj2, GAME_VARS)
				end for
				
				numScoreObj.Update(deltaTime)
				textScoreObj.Update(deltaTime)
				numBestScoreObj.Update(deltaTime)
				textBestScoreObj.Update(deltaTime)
				for i=0 to GAME_VARS.hero1lifeCount-1
					hero1LivesObj[i].Update(deltaTime)
				end for
				for i=0 to GAME_VARS.hero2lifeCount-1
					hero2LivesObj[i].Update(deltaTime)
				end for

				coin.Spawn()
				coinGreen.Spawn()
				coinRed.Spawn()
				
				lifeCountObj = [GAME_VARS.hero1lifeCount]
				coin.Update(deltaTime, balls, heroObj1, heroObj2, lifeCountObj, GAME_VARS)
				coinGreen.Update(deltaTime, balls, heroObj1, heroObj2, lifeCountObj, GAME_VARS)
				coinRed.Update(deltaTime, heroObj1, GAME_VARS)
				heroObj1.rocketLauncherUp.Update(deltaTime, heroObj1, GAME_VARS)
				heroObj1.rocketLauncherDown.Update(deltaTime, heroObj1, GAME_VARS)
				GAME_VARS.hero1lifeCount = lifeCountObj[0]
								
				backObj.Draw()
				textScoreObj.Draw()
				numScoreObj.Draw()
				textBestScoreObj.Draw()
				numBestScoreObj.Draw()
				heroObj1.Draw()
				heroObj2.Draw()
				for i=0 to GAME_VARS.MAX_BALL_COUNT-1
					balls[i].Draw()
				end for
				for i=0 to GAME_VARS.hero1lifeCount-1
					hero1LivesObj[i].Draw()
				end for
				for i=0 to GAME_VARS.hero2lifeCount-1
					hero2LivesObj[i].Draw()
				end for
				coin.Draw()
				coinGreen.Draw()
				coinRed.Draw()
				heroObj1.rocketLauncherUp.Draw()
				heroObj1.rocketLauncherDown.Draw()
				for i=0 to GAME_VARS.MAX_ROCKET_COUNT-1	
					rockets[i].Draw()
				end for
                screen.SwapBuffers()
				
				isAllBallsMissed = isAllBallsDead(balls, GAME_VARS)
				
				if (isAllBallsMissed = true)
					if (GAME_VARS.isLastMissedBallHeroes  = true) 
						GAME_VARS.hero1lifeCount -= 1
						if (GAME_VARS.hero1lifeCount < 0) 
							Goto GAME_OVER_LOOP
						else
							Goto NEW_LIFE_LOOP
						endif
					else 
						Goto NEW_LIFE_LOOP
					endif
				end if
				clock.Mark()
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
	if (numBestScoreObj.value < numScoreObj.value) 
		numBestScoreObj.value = numScoreObj.value
		GAME_VARS.bestScore = numBestScoreObj.value
		scoreRegSection.Write("BestScore", GAME_VARS.bestScore.ToStr())
		scoreRegSection.Flush()
	endif
	
    while true
		event = port.GetMessage()
        if (type(event) = "roUniversalControlEvent")
            id = event.GetInt()
			if ( (id = 0) OR (id = 6) ) Goto MENU_LOOP
        else if (event = invalid)
			deltaTime = clock.TotalMilliseconds() / 1000.0
			if (deltaTime > GAME_VARS.STABLE_FPS)
				heroObj1.Update(deltaTime)
				heroObj2.Update(deltaTime, GAME_VARS)
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
			
				if (gameOverLoopTime > GAME_VARS.GAME_OVER_DELAY) Goto MENU_LOOP
				gameOverLoopTime += deltaTime
			
				clock.Mark()
			endif
		end if
	end while
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
	
	if (_v > max) 
		_v = max
	else if (_v < min) 
		_v = min
	end if
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

function Distance(_obj1 as object, _obj2 as object) as float
	vecX = _obj1.x - _obj2.x
	vecY = _obj1.y - _obj2.y
	res = Sqr(vecX * vecX + vecY * vecY )
	return res
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

function CoinVisObjInit(_globalVars as object) as void
	m.width = 20
	m.height = 30
	m.STATE_INTRO_PREPARING = 0
	m.STATE_INTRO = 1
	m.STATE_WAIT = 2
	m.STATE_GAME = 3
	m.STATE_DEATH = 4
	m.state = m.STATE_DEATH
	m.FLASHING_SPEED = 15
	m.flashingTimer = 1
	m.minX = 0
	m.maxX = _globalVars.GAME_FIELD_MAX_X
	m.minY = _globalVars.GAME_FIELD_MIN_Y + m.height
	m.maxY = _globalVars.GAME_FIELD_MAX_Y - m.height
	m.SPEED_X = 3
	m.SPEED_Y = 3
	m.speedX = m.SPEED_X
	m.speedY = m.SPEED_Y
	m.spawnX = _globalVars.GAME_FIELD_MAX_X / 2
	m.spawnChance = 1 ' old 0.0003
	m.visible = false
end function

function CoinVisObjReset() as void
	m.state = m.STATE_DEATH
end function

function CoinVisObjSpawn() as void
	if ( (m.state = m.STATE_DEATH) AND (Rnd(0) < m.spawnChance) )
		m.state = m.STATE_INTRO_PREPARING
	end if
end function

function CoinVisObjUpdate(_deltatime as float, _balls as object, _hero1 as object, _hero2 as object, _lifeCount as object, _globalVars as object) as void
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
			m.state = m.STATE_WAIT
			m.visible = true
		end if
	end if
	
	if (m.state = m.STATE_WAIT)
		isBallCollided = false
		speedDirection = 1
		for i=0 to _globalVars.MAX_BALL_COUNT-1
			if (_balls[i].state = _balls[i].STATE_GAME)
				isBallCollided = CollisionBoxCheck(m, _balls[i])
				if ( isBallCollided = true ) 
					speedDirection = Sgn(m.x - _balls[i].x)
					Goto BREAK_LOOP
				end if
			end if
		end for
BREAK_LOOP:
		if (isBallCollided = true)
			m.state = m.STATE_GAME
			m.speedX = m.SPEED_X * speedDirection
		end if
	end if

	if (m.state = m.STATE_GAME)
		m.x += m.speedX
		if (m.x < m.minX) OR ((m.x > m.maxX))
			m.state = m.STATE_DEATH
			m.visible = false
		end if
	
		isCollided = CollisionBoxCheck(m, _hero1)
		if ( isCollided = true )
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

function CoinGreenVisObjInit(_globalVars as object) as void
	m.width = 20
	m.height = 30
	m.STATE_INTRO_PREPARING = 0
	m.STATE_INTRO = 1
	m.STATE_WAIT = 2
	m.STATE_GAME = 3
	m.STATE_DEATH = 4
	m.state = m.STATE_DEATH
	m.FLASHING_SPEED = 15
	m.flashingTimer = 1
	m.minX = 0
	m.maxX = _globalVars.GAME_FIELD_MAX_X
	m.minY = _globalVars.GAME_FIELD_MIN_Y + m.height
	m.maxY = _globalVars.GAME_FIELD_MAX_Y - m.height
	m.SPEED_X = 3
	m.SPEED_Y = 3
	m.speedX = m.SPEED_X
	m.speedY = m.SPEED_Y
	m.spawnX = _globalVars.GAME_FIELD_MAX_X / 2
	m.spawnChance = 1 '0.004
	m.visible = false
end function

function CoinGreenVisObjReset() as void
	m.state = m.STATE_DEATH
end function

function CoinGreenVisObjSpawn() as void
	if ( (m.state = m.STATE_DEATH) AND (Rnd(0) < m.spawnChance) )
		m.state = m.STATE_INTRO_PREPARING
	end if
end function

function CoinGreenVisObjUpdate(_deltatime as float, _balls as object, _hero1 as object, _hero2 as object, _lifeCount as object, _globalVars as object) as void
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
			m.state = m.STATE_WAIT
			m.visible = true
		end if
	end if
	
	if (m.state = m.STATE_WAIT)
		isBallCollided = false
		speedDirection = 1
		for i=0 to _globalVars.MAX_BALL_COUNT-1
			if (_balls[i].state = _balls[i].STATE_GAME)
				isBallCollided = CollisionBoxCheck(m, _balls[i])
				if ( isBallCollided = true ) 
					speedDirection = Sgn(m.x - _balls[i].x)
					Goto BREAK_LOOP
				end if
			end if
		end for
BREAK_LOOP:
		if (isBallCollided = true)
			m.state = m.STATE_GAME
			m.speedX = m.SPEED_X * speedDirection
		end if
	end if

	if (m.state = m.STATE_GAME)
		m.x += m.speedX
		if (m.x < m.minX) OR ((m.x > m.maxX))
			m.state = m.STATE_DEATH
			m.visible = false
		end if
	
		isHero1Collided = CollisionBoxCheck(m, _hero1)
		isHero2Collided = CollisionBoxCheck(m, _hero2)
		hero = _hero1
		if (isHero1Collided = true)
			hero = _hero1
		end if
		if (isHero2Collided = true)
			hero = _hero2
		end if
		if ( (isHero1Collided = true) OR (isHero2Collided = true) )
			m.state = m.STATE_DEATH
			m.visible = false
			hero.currentAnimationName = hero.bigAnim
			hero.height = hero.bigHeight
			hero.maxY = _globalVars.GAME_FIELD_MAX_Y - hero.height
			hero.minY = _globalVars.GAME_FIELD_MIN_Y + hero.height
			hero.bigTimer = hero.BIG_TIME
		end if
	end if
	
	for each spriteObjName in m.spriteObjArray
		m.spriteObjArray[spriteObjName].Update(_deltatime, m.x, m.y)
	end for
end function

function CoinRedVisObjInit(_globalVars as object) as void
	m.width = 20
	m.height = 30
	m.STATE_INTRO_PREPARING = 0
	m.STATE_INTRO = 1
	m.STATE_GAME = 2
	m.STATE_DEATH = 3
	m.state = m.STATE_DEATH
	m.FLASHING_SPEED = 15
	m.flashingTimer = 1
	m.minX = 0
	m.maxX = _globalVars.GAME_FIELD_MAX_X
	m.minY = _globalVars.GAME_FIELD_MIN_Y + m.height
	m.maxY = _globalVars.GAME_FIELD_MAX_Y - m.height
	m.SPEED_X = 3
	m.SPEED_Y = 3
	m.speedX = m.SPEED_X
	m.speedY = m.SPEED_Y
	m.spawnX = _globalVars.GAME_FIELD_MAX_X / 2
	m.spawnChance = 1' 0.003
	m.visible = false
end function

function CoinRedVisObjReset() as void
	m.state = m.STATE_DEATH
end function

function CoinRedVisObjSpawn() as void
	if ( (m.state = m.STATE_DEATH) AND (Rnd(0) < m.spawnChance) )
		m.state = m.STATE_INTRO_PREPARING
	end if
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
	
	if ((m.state = m.STATE_GAME) AND (_hero1 <> invalid) AND (_globalVars <> invalid))
		isCollided = CollisionBoxCheck(m, _hero1)
		if ( isCollided = true)
			m.state = m.STATE_DEATH
			m.visible = false
			_hero1.rocketLauncherUp.Spawn()
			_hero1.rocketLauncherDown.Spawn()
		end if
	end if
	
	for each spriteObjName in m.spriteObjArray
		m.spriteObjArray[spriteObjName].Update(_deltatime, m.x, m.y)
	end for
end function

function RocketLauncherUpVisObjInit(_globalVars as object, _spawnOffsetSignY as float) as void
	m.width = 32
	m.height = 32
	m.STATE_INTRO_PREPARING = 0
	m.STATE_GAME = 2
	m.STATE_DEATH = 3
	m.state = m.STATE_DEATH
	m.minY = _globalVars.GAME_FIELD_MIN_Y + m.height
	m.maxY = _globalVars.GAME_FIELD_MAX_Y - m.height  
	m.visible = false
	m.LIFETIME = 10
	m.time = 0
	m.spawnOffsetSignY = _spawnOffsetSignY
end function

function RocketLauncherUpVisObjReset() as void
	m.state = m.STATE_DEATH
end function

function RocketLauncherUpVisObjSpawn() as void
	if ( (m.state = m.STATE_DEATH))
		m.state = m.STATE_INTRO_PREPARING
	end if
end function

function RocketLauncherUpVisObjUpdate(_deltatime=0 as float, _hero1=invalid as object, _globalVars=invalid as object) as void
	if (m.state = m.STATE_DEATH) 
		m.visible = false
		return
	end if
	
	if (m.state = m.STATE_INTRO_PREPARING)
		m.state = m.STATE_GAME
		m.x = _hero1.x - m.width * 2
		m.visible = true
		m.time = 0
	end if
	
	if (m.state = m.STATE_GAME)
		m.y = _hero1.y + ((-1) * _hero1.height + m.height ) * m.spawnOffsetSignY
		m.time += _deltatime
		if (m.time > m.LIFETIME) m.state = m.STATE_DEATH
	end if
	
	for each spriteObjName in m.spriteObjArray
		m.spriteObjArray[spriteObjName].Update(_deltatime, m.x, m.y)
	end for
end function

function RocketVisObjInit(_globalVars as object) as void
	m.width = 32
	m.height = 32
	m.STATE_INTRO_PREPARING = 0
	m.STATE_GAME = 2
	m.STATE_DEATH = 3
	m.state = m.STATE_DEATH
	m.visible = false
	m.time = 0
	m.SPEED_X = 15
	m.speedX = m.SPEED_X
	m.owner = 1 ' 1= hero1, 2 = hero2, etc.
end function

function RocketVisObjReset() as void
	m.state = m.STATE_DEATH
end function

function RocketVisObjSpawn(_y as float, _owner as integer) as void
	if ( (m.state = m.STATE_DEATH))
		m.state = m.STATE_INTRO_PREPARING
		m.y = _y
		m.owner = _owner
	end if
end function

function RocketVisObjUpdate(_deltatime as float, _hero1 as object, _hero2 as object, _globalVars as object) as void
	if (m.state = m.STATE_DEATH) 
		m.visible = false
		return
	end if
	
	if (m.state = m.STATE_INTRO_PREPARING)
		m.state = m.STATE_GAME
		m.x = _hero1.x - m.width * 2
		m.visible = true
		m.time = 0
	end if
	
	if (m.state = m.STATE_GAME)
		m.x += m.speedX
		if ((m.x > _globalVars.GAME_FIELD_MAX_X) OR (m.x < _globalVars.GAME_FIELD_MIN_X)) 
			m.state = m.STATE_DEATH
			return
		end if
		if (m.owner = 1) 
			targetHero = _hero2
		else 
			targetHero = _hero1
		end if
		isHeroCollided = CollisionBoxCheck(m, targetHero)
		if ( isHeroCollided = true)
			m.state = m.STATE_DEATH
			targetHero.state = _hero2.STATE_DEATH
		end if
	end if
	
	for each spriteObjName in m.spriteObjArray
		m.spriteObjArray[spriteObjName].Update(_deltatime, m.x, m.y)
	end for
end function

function GetDeadRocket(_rockets as object, _globalVars as object) as object
	deadRocket = invalid 
	for i=0 to _globalVars.MAX_ROCKET_COUNT-1
		if (_rockets[i].state = _rockets[i].STATE_DEATH)
			deadRocket = _rockets[i] 
		end if
	end for
	return deadRocket 
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
		m.Hero1Miss = false
		m.Hero2Miss = false
end function

function BallVisObjStart(_globalVars as object) as void
	ballSpeedAngle = _globalVars.PI/4 + Rnd(0) * _globalVars.PI/2
	m.ballCurrentSpeedX = Sin(ballSpeedAngle) * _globalVars.BALL_SPEEDS[_globalVars.menuState]
	m.ballCurrentSpeedY = Cos(ballSpeedAngle) * _globalVars.BALL_SPEEDS[_globalVars.menuState]
	m.state = m.STATE_GAME
	m.visible = true
	m.currentAnimationName = m.GAME_ANIMATION
end function

function BallVisObjUpdate(_deltatime as float, _hero1 as object, _hero2 as object, _numScoreObj as object, _globalVars as object) as void
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
		if (m.x < m.minX) 
			m.Hero1Miss = true
			m.state = m.STATE_DEATH
			_globalVars.isLastMissedBallHeroes = true
			return
		else if (m.x > m.maxX) 
			m.Hero2Miss = true
			_numScoreObj.value += _numScoreObj.AI_FAIL_SCORE
			m.state = m.STATE_DEATH
			_globalVars.isLastMissedBallHeroes = false
			return
		end if
		if ( (m.y > m.maxY) OR (m.y < m.minY) ) 
			m.ballCurrentSpeedY *= -1
			m.y = ClampF(m.y, _globalVars.GAME_FIELD_MIN_Y, _globalVars.GAME_FIELD_MAX_Y)
		end if
	
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

function isAllBallsDead(_balls as object, _globalVars as object) as boolean
	for i=0 to _globalVars.MAX_BALL_COUNT-1
		if (_balls[i].state <> _balls[i].STATE_DEATH) return false
	endfor
	return true
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

function HeroVisObjInit(_globalVars as object, _rocketLauncherUp as object, _rocketLauncherDown as object) as void
	m.commonHeight = 73
	m.width = 24
	m.commonAnim = "idle"
	m.bigHeight = 132
	m.bigAnim = "idle2"
	m.BIG_TIME = 7
	m.rocketLauncherUp = _rocketLauncherUp
	m.rocketLauncherDown = _rocketLauncherDown
	m.STATE_INTRO_PREPARING = 0
	m.STATE_INTRO = 1
	m.STATE_GAME = 2
	m.STATE_DEATH = 3
	m.state = m.STATE_INTRO_PREPARING
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

function AIHeroVisObjInit(_globalVars as object, _rocketLauncherUp as object, _rocketLauncherDown as object) as void
	m.commonHeight = 73
	m.width = 24
	m.commonAnim = "idle"
	m.bigHeight = 132
	m.bigAnim = "idle2"
	m.BIG_TIME = 7
	m.rocketLauncherUp = _rocketLauncherUp
	m.rocketLauncherDown = _rocketLauncherDown
	m.STATE_INTRO_PREPARING = 0
	m.STATE_INTRO = 1
	m.STATE_GAME = 2
	m.STATE_DEATH = 3
	m.state = m.STATE_INTRO_PREPARING
end function

function AIHeroVisObjReset(_globalVars as object) as void
	m.height = m.commonHeight
	m.heroSpeed = _globalVars.AI_HERO_SPEEDS[_globalVars.menuState]
	m.heroCurrentSpeed = 0
	m.maxY = _globalVars.GAME_FIELD_MAX_Y - m.height
	m.minY = _globalVars.GAME_FIELD_MIN_Y + m.height
	m.isBig = false
	m.bigTimer = 0
	m.y = _globalVars.GAME_FIELD_MAX_Y / 2
	m.currentAnimationName = m.commonAnim
end function

function AIHeroVisObjUpdate(_deltatime as float, _globalVars as object, _balls=invalid as object) as void
	if (m.active = false) return
	if (_balls = invalid) Goto SPRITES_UPDATE
	
	nearestBallDistance = _globalVars.GAME_FIELD_MAX_Y + _globalVars.GAME_FIELD_MAX_X
	nearestBallNum = 0
	for i=0 to _globalVars.MAX_BALL_COUNT-1
		if (_balls[i].state = m.STATE_GAME)
			ballDistance = Distance(_balls[i], m)
			if (ballDistance < nearestBallDistance )
				nearestBallNum = i
				nearestBallDistance = ballDistance
			end if
		end if
	end for
	
	m.heroCurrentSpeed = ClampF((_balls[nearestBallNum].y - m.y) * 0.4, -m.heroSpeed, m.heroSpeed)

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
	
SPRITES_UPDATE:
	for each spriteObjName in m.spriteObjArray
		m.spriteObjArray[spriteObjName].Update(_deltatime, m.x, m.y)
	end for
end function