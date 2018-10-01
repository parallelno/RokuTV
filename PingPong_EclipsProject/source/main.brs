Library "v30/bslDefender.brs" 

function Main() as void
    bitmapset = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/bitmapset.xml"))
	hero1AnimDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/platform.xml"))
	textAnimDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/text.xml"))
	coinGoldAnimDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/coin_gold_anim.xml"))
	coinGreenAnimDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/coin_green_anim.xml"))
	coinRedAnimDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/coin_red_anim.xml"))
	cubeRedAnimDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/cube_red_anim.xml"))
	coinBlackAnimDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/coin_black_anim.xml"))
	coinWhiteAnimDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/coin_white_anim.xml"))
	coinPinkAnimDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/coin_pink_anim.xml"))
	coinBlueAnimDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/coin_blue_anim.xml"))
	magnetAnimDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/magnet_anim.xml"))
    
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
		STABLE_FPS		: 1.0 / 30.0 	'stable 30 fps
		PI				: 3.14159
	
		HIT_BALL_SCORE	: 50
		AI_FAIL_SCORE	: 100
		COIN_WHITE_SCORE: 500
		
		BALL_SPEEDS 	: [5, 10, 15] 'speed depends on game difficulty
		AI_HERO_SPEEDS	: [3.3, 7, 13] 'speed depends on game difficulty
		HERO_SPEED		: 10
	
		bestScore		: 0
		numScoreObj		: invalid
		
' --------- GAME VARS ---------------------------------------------------------------------------------
		NEW_LIFE_LOOP_DELAY	: 1
		GAME_FIELD_MAX_X	: screenWidth
		GAME_FIELD_MIN_X	: 0
		GAME_FIELD_MAX_Y	: screenHeight
		GAME_FIELD_MIN_Y	: 80

		MAX_LIFE_COUNT		: 6
		START_LIFE_COUNT	: 4
		
		MAX_BALL_COUNT		: 4
		isLastMissedBallHeroes	: false
		
		MAX_ROCKET_COUNT	: 4
		
		HERO1_ID			: 0
		HERO2_ID			: 1
		
		COIN_SPEED_X		: 3
		
		COIN_YELLOW_SPAWN_RATE	: 0.0003
		COIN_GREEN_SPAWN_RATE	: 0.01	
		COIN_RED_SPAWN_RATE		: 0.004
		COIN_WHITE_SPAWN_RATE	: 0.1
		COIN_PINK_SPAWN_RATE	: 0.1	
		COIN_BLACK_SPAWN_RATE	: 0.0003
		COIN_BLUE_SPAWN_RATE	: 0.03

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
	textWinObj = CreateVisObj("Win", screen, screenWidth/2, screenHeight/2, textAnimDataSet, "win", TextRoundObjUpdate)

	textScoreObj = CreateSpriteObj(textAnimDataSet.animations.score[0], screen, 36*6 + 30, 0, -0.5, -0.5, 0.5, 0.5)	
	numScoreObj = CreateNumberTextObj(0, textAnimDataSet.animations.numbers_anim, screen, 36*6 + 195, 5, -0.5, -0.5, 0.5, 0.5)
	numScoreObj.HIT_BALL_SCORE = GAME_VARS.HIT_BALL_SCORE
	numScoreObj.AI_FAIL_SCORE = GAME_VARS.AI_FAIL_SCORE
	numScoreObj.COIN_WHITE_SCORE = GAME_VARS.COIN_WHITE_SCORE
	GAME_VARS.numScoreObj = numScoreObj

	magnetObj1 = CreateVisObj("magnet1", screen, screenWidth/2, screenHeight/2, magnetAnimDataSet, "idle", MagnetObUpdate)
	magnetObj2 = CreateVisObj("magnet2", screen, screenWidth/2, screenHeight/2, magnetAnimDataSet, "idle", MagnetObUpdate)
	magnetObj1.Init = MagnetObInit
	magnetObj1.Init(GAME_VARS, 1)
	magnetObj2.Init = MagnetObInit
	magnetObj2.Init(GAME_VARS, -1)
	
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
	coin.Init = CoinYellowVisObjInit
	coin.Reset = CoinVisObjReset
	coin.Spawn = CoinVisObjSpawn
	coin.Init(GAME_VARS)
	
	
	' expand a desk length	
	coinGreen = CreateVisObj("coinGreen", screen, screenWidth/2, screenHeight/2, coinGreenAnimDataSet, "idle", CoinVisObjUpdate)
	coinGreen.Init = CoinGreenVisObjInit
	coinGreen.Reset = CoinVisObjReset
	coinGreen.Spawn = CoinVisObjSpawn
	coinGreen.Init(GAME_VARS)
	
	' gives two rockets
	coinRed = CreateVisObj("CoinRed", screen, screenWidth/2, screenHeight/2, coinRedAnimDataSet, "idle", CoinVisObjUpdate)
	coinRed.Init = CoinRedVisObjInit
	coinRed.Reset = CoinVisObjReset
	coinRed.Spawn = CoinVisObjSpawn
	coinRed.Init(GAME_VARS)

	' takes life
	coinBlack = CreateVisObj("CoinBlack", screen, screenWidth/2, screenHeight/2, coinBlackAnimDataSet, "idle", CoinVisObjUpdate)
	coinBlack.Init = CoinBlackVisObjInit
	coinBlack.Reset = CoinVisObjReset
	coinBlack.Spawn = CoinVisObjSpawn
	coinBlack.Init(GAME_VARS)

	' give points
	coinWhite = CreateVisObj("CoinWhite", screen, screenWidth/2, screenHeight/2, coinWhiteAnimDataSet, "idle", CoinVisObjUpdate)
	coinWhite.Init = CoinWhiteVisObjInit
	coinWhite.Reset = CoinVisObjReset
	coinWhite.Spawn = CoinVisObjSpawn
	coinWhite.Init(GAME_VARS)

	' give speed
	coinPink = CreateVisObj("CoinPink", screen, screenWidth/2, screenHeight/2, coinPinkAnimDataSet, "idle", CoinVisObjUpdate)
	coinPink.Init = CoinPinkVisObjInit
	coinPink.Reset = CoinVisObjReset
	coinPink.Spawn = CoinVisObjSpawn
	coinPink.Init(GAME_VARS)

	' give magnet
	coinBlue = CreateVisObj("CoinBlue", screen, screenWidth/2, screenHeight/2, coinBlueAnimDataSet, "idle", CoinVisObjUpdate)
	coinBlue.Init = CoinBlueVisObjInit
	coinBlue.Reset = CoinVisObjReset
	coinBlue.Spawn = CoinVisObjSpawn
	coinBlue.Init(GAME_VARS)

	balls = []
	for i=0 to GAME_VARS.MAX_BALL_COUNT-1
		ball = CreateVisObj("ball", screen, screenWidth/2, screenHeight/2, bitmapset, "idle2", BallVisObjUpdate)
		ball.Init = BallVisObjInit
		ball.Reset = BallVisObjReset
		ball.Init(GAME_VARS)
		ball.Start = BallVisObjStart
		balls.Push(ball)
	end for
	balls[0].state = balls[0].STATE_INTRO_PREPARING
	
	rocketLaunchers = []
	for i=0 to 3 
		rocketLauncher = CreateVisObj("RocketLauncher", screen, screenWidth/2, screenHeight/2, cubeRedAnimDataSet, "idle", RocketLauncherVisObjUpdate)
		rocketLauncher.Init = RocketLauncherVisObjInit
		rocketLauncher.Reset = RocketLauncherVisObjReset
		rocketLauncher.Spawn = RocketLauncherVisObjSpawn
		rocketLaunchers.Push(rocketLauncher)
	end for
	rocketLaunchers[0].Init(GAME_VARS, -1)
	rocketLaunchers[1].Init(GAME_VARS, 1)
	rocketLaunchers[2].Init(GAME_VARS, -1)
	rocketLaunchers[3].Init(GAME_VARS, 1)

	rockets = []
	for i=0 to GAME_VARS.MAX_ROCKET_COUNT-1
		rocket = CreateVisObj("Rocket", screen, screenWidth/2, screenHeight/2, cubeRedAnimDataSet, "idle", RocketVisObjUpdate)
		rocket.Init = RocketVisObjInit
		rocket.Reset = RocketVisObjReset
		rocket.Spawn = RocketVisObjSpawn
		rocket.Init(GAME_VARS)
		rockets.Push(rocket)
	end for
		
	Hero1RocketLaunchers = [rocketLaunchers[0], rocketLaunchers[1]]
	Hero2RocketLaunchers = [rocketLaunchers[2], rocketLaunchers[3]]
	
	heroObj1 = CreateVisObj("hero1", screen, 100, screenHeight/2, hero1AnimDataSet, "idle", HeroVisObjUpdate)
	heroObj1.Init = HeroVisObjInit
	heroObj1.Reset = HeroVisObjReset
	heroObj1.magnetObj = magnetObj1
			
	heroObj2 = CreateVisObj("hero2", screen, screenWidth - 100, screenHeight/2, hero1AnimDataSet, "idle", AIHeroVisObjUpdate)
	heroObj2.Init = HeroVisObjInit
	heroObj2.Reset = HeroVisObjReset
	heroObj2.magnetObj = magnetObj2
	
	heroObj1.Init(GAME_VARS.HERO1_ID, GAME_VARS, Hero1RocketLaunchers, heroObj2)
	heroObj2.Init(GAME_VARS.HERO2_ID, GAME_VARS, Hero2RocketLaunchers, heroObj1) 

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
	textRoundObj.Reset()
	heroObj1.Reset(GAME_VARS.HERO_SPEED)
	heroObj2.Reset(GAME_VARS.AI_HERO_SPEEDS[GAME_VARS.menuState])
	heroObj1.lifeCount = GAME_VARS.START_LIFE_COUNT
	heroObj2.lifeCount = GAME_VARS.START_LIFE_COUNT
	
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
	
NEW_LIFE_LOOP:
	loopTime = 0.0
	
	for i=0 to GAME_VARS.MAX_BALL_COUNT-1	
		balls[i].Reset()
	end for
	balls[0].state = balls[0].STATE_INTRO_PREPARING

	for i=0 to GAME_VARS.MAX_ROCKET_COUNT-1	
		rockets[i].Reset()
	end for
	
	heroObj1.Reset(GAME_VARS.HERO_SPEED)
	heroObj2.Reset(GAME_VARS.AI_HERO_SPEEDS[GAME_VARS.menuState])
	heroObj1.Update(0)
	heroObj2.Update(0, balls)
	
	coin.Reset()
	coinGreen.Reset()
	coinRed.Reset()
	coinBlack.Reset()
	coinWhite.Reset()
	coinPink.Reset()
	coinBlue.Reset()

    while true
		deltaTime = clock.TotalMilliseconds() / 1000.0
		if (deltaTime > GAME_VARS.STABLE_FPS)
			for i=0 to GAME_VARS.MAX_BALL_COUNT-1
				balls[i].Update(deltaTime, heroObj1, heroObj2, numScoreObj)
			endfor
			numScoreObj.Update(deltaTime)
			textScoreObj.Update(deltaTime)
			numBestScoreObj.Update(deltaTime)
			textBestScoreObj.Update(deltaTime)
			for i=0 to heroObj1.lifeCount-1
				hero1LivesObj[i].Update(deltaTime)
			end for
			for i=0 to heroObj2.lifeCount-1
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
			for i=0 to heroObj1.lifeCount-1
				hero1LivesObj[i].Draw()
			end for
			for i=0 to heroObj2.lifeCount-1
				hero2LivesObj[i].Draw()
			end for
			screen.SwapBuffers()

			if (loopTime > GAME_VARS.NEW_LIFE_LOOP_DELAY) Goto GAME_LOOP
			loopTime += deltaTime

			clock.Mark()
		endif        
	end while

GAME_LOOP:
	balls[0].Start()

    while true
        event = port.GetMessage()
        if (type(event) = "roUniversalControlEvent")
            id = event.GetInt()
			if (id = codes.BUTTON_UP_PRESSED)
				heroObj1.heroCurrentSpeed = -heroObj1.SPEED
			endif
			if (id = codes.BUTTON_DOWN_PRESSED)
				heroObj1.heroCurrentSpeed = heroObj1.SPEED
			endif
			if (id = 0) Goto MENU_LOOP
			if (id = 6)	
				for each rocketLauncher in heroObj1.rocketLaunchers
					if (rocketLauncher.state = rocketLauncher.STATE_GAME)
						rocket = GetDeadRocket(rockets, GAME_VARS)
						if (rocket <> invalid) 
							rocket.Spawn(rocketLauncher, rocket.OWNER_HERO1)
							rocketLauncher.state = rocketLauncher.STATE_DEATH
							Goto ROCKET_CHOSEN
						end if
					end if
				end for
			end if
ROCKET_CHOSEN:
        else if (event = invalid)
			deltaTime = clock.TotalMilliseconds() / 1000.0
            if (deltaTime > GAME_VARS.STABLE_FPS)
				heroObj1.Update(deltaTime)
				heroObj2.Update(deltaTime, balls, rockets)
				for i=0 to GAME_VARS.MAX_BALL_COUNT-1
					balls[i].Update(deltaTime, heroObj1, heroObj2, numScoreObj)
				end for
				
				for i=0 to GAME_VARS.MAX_ROCKET_COUNT-1	
					rockets[i].Update(deltaTime, heroObj1, heroObj2, balls)
				end for
				
				numScoreObj.Update(deltaTime)
				textScoreObj.Update(deltaTime)
				numBestScoreObj.Update(deltaTime)
				textBestScoreObj.Update(deltaTime)
				for i=0 to heroObj1.lifeCount-1
					hero1LivesObj[i].Update(deltaTime)
				end for
				for i=0 to heroObj2.lifeCount-1
					hero2LivesObj[i].Update(deltaTime)
				end for

				coin.Spawn()
				coinGreen.Spawn()
				coinRed.Spawn()
				coinBlack.Spawn()
				coinWhite.Spawn()
				coinPink.Spawn()
				coinBlue.Spawn()
				
				coin.Update(deltaTime, balls, heroObj1, heroObj2)
				coinGreen.Update(deltaTime, balls, heroObj1, heroObj2)
				coinRed.Update(deltaTime, balls, heroObj1, heroObj2)
				coinBlack.Update(deltaTime, balls, heroObj1, heroObj2)
				coinWhite.Update(deltaTime, balls, heroObj1, heroObj2)
				coinPink.Update(deltaTime, balls, heroObj1, heroObj2)
				coinBlue.Update(deltaTime, balls, heroObj1, heroObj2)
																
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
				for i=0 to heroObj1.lifeCount-1
					hero1LivesObj[i].Draw()
				end for
				for i=0 to heroObj2.lifeCount-1
					hero2LivesObj[i].Draw()
				end for
				coin.Draw()
				coinGreen.Draw()
				coinRed.Draw()
				coinBlack.Draw()
				coinWhite.Draw()
				coinPink.Draw()
				coinBlue.Draw()
				for each rocketLauncher in heroObj1.rocketLaunchers
					rocketLauncher.Draw()
				end for
				for each rocketLauncher in heroObj2.rocketLaunchers
					rocketLauncher.Draw()
				end for
				for i=0 to GAME_VARS.MAX_ROCKET_COUNT-1	
					rockets[i].Draw()
				end for
				heroObj1.magnetObj.Draw()
				heroObj2.magnetObj.Draw()
                screen.SwapBuffers()
				
				isAllBallsMissed = isAllBallsDead(balls)
				
				if (isAllBallsMissed = true)
					if (GAME_VARS.isLastMissedBallHeroes  = true) 
						heroObj1.lifeCount -= 1
						if (heroObj1.lifeCount < 0) 
							Goto GAME_OVER_LOOP
						else
							Goto NEW_LIFE_LOOP
						endif
					else
						heroObj2.lifeCount -= 1
						if (heroObj2.lifeCount < 0) 
							Goto GAME_WIN_LOOP
						else
							Goto NEW_LIFE_LOOP
						endif
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
				heroObj1.Update(0)
				heroObj2.Update(0)
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

GAME_WIN_LOOP:
	gameOverLoopTime = 0.0
	textWinObj.currentTime = 0.0
	textWinObj.time = 1
	textWinObj.scaleStart = 1.7
	textWinObj.scaleEnd = 1.0
	textWinObj.scale = textWinObj.scaleStart
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
				heroObj1.Update(0)
				heroObj2.Update(0)
				textWinObj.Update(deltaTime)
				numBestScoreObj.Update(deltaTime)
				textBestScoreObj.Update(deltaTime)
			
				backObj.Draw()
				textBestScoreObj.Draw()
				numBestScoreObj.Draw()
				textScoreObj.Draw()
				numScoreObj.Draw()
				heroObj1.Draw()
				heroObj2.Draw()
			
				textWinObj.Draw()
			
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

function CollisionBoxAndSphereCheck(_box as object, _sphere as object) as boolean
	if ((_box = invalid) OR (_sphere = invalid)) return false
	
	BSdistance = Distance(_box, _sphere) + MinF(_box.width, _box.height)  	
	if (BSdistance < _sphere.radius) return true
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
function TextRoundObjUpdate(_deltatime as float) as void
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

function TextRoundObjReset() as void
	m.currentTime = 0.0
	m.time = 0.3
	m.scaleStart = 1.7
	m.scaleEnd = 1.0
	m.scale = m.scaleStart
end function

function CoinVisObjInit(_coin as object, _globalVars as object) as void
	_coin.width = 20
	_coin.height = 30
	_coin.STATE_INTRO_PREPARING = 0
	_coin.STATE_INTRO = 1
	_coin.STATE_WAIT = 2
	_coin.STATE_GAME = 3
	_coin.STATE_DEATH = 4
	_coin.state = _coin.STATE_DEATH
	_coin.FLASHING_SPEED = 15
	_coin.flashingTimer = 1
	_coin.minX = 0
	_coin.maxX = _globalVars.GAME_FIELD_MAX_X
	_coin.minY = _globalVars.GAME_FIELD_MIN_Y + _coin.height
	_coin.maxY = _globalVars.GAME_FIELD_MAX_Y - _coin.height
	_coin.SPEED_X = _globalVars.COIN_SPEED_X
	_coin.SPEED_Y = _globalVars.COIN_SPEED_Y
	_coin.speedX = _coin.SPEED_X
	_coin.speedY = _coin.SPEED_Y
	_coin.spawnX = _globalVars.GAME_FIELD_MAX_X / 2
	_coin.spawnChance = 0.0001
	_coin.visible = false
	_coin.CollidedUpdate = invalid
	_coin.globalVars = _globalVars
end function

function CoinYellowVisObjInit(_globalVars as object) as void
	 CoinVisObjInit(m, _globalVars)
	 m.spawnChance = _globalVars.COIN_YELLOW_SPAWN_RATE
	 m.CollidedUpdate = CoinYellowCollidedUpdate
end function

function CoinGreenVisObjInit(_globalVars as object) as void
	CoinVisObjInit(m, _globalVars)
	m.spawnChance = _globalVars.COIN_GREEN_SPAWN_RATE
	m.CollidedUpdate = CoinGreenCollidedUpdate
end function

function CoinRedVisObjInit(_globalVars as object) as void
	CoinVisObjInit(m, _globalVars)
	m.spawnChance = _globalVars.COIN_RED_SPAWN_RATE
	m.CollidedUpdate = CoinRedCollidedUpdate
end function

function CoinBlackVisObjInit(_globalVars as object) as void
	CoinVisObjInit(m, _globalVars)
	m.spawnChance = _globalVars.COIN_BLACK_SPAWN_RATE
	m.CollidedUpdate = CoinBlackCollidedUpdate
end function

function CoinWhiteVisObjInit(_globalVars as object) as void
	CoinVisObjInit(m, _globalVars)
	m.spawnChance = _globalVars.COIN_WHITE_SPAWN_RATE
	m.CollidedUpdate = CoinWhiteCollidedUpdate
end function

function CoinPinkVisObjInit(_globalVars as object) as void
	CoinVisObjInit(m, _globalVars)
	m.spawnChance = _globalVars.COIN_PINK_SPAWN_RATE
	m.CollidedUpdate = CoinPinkCollidedUpdate
end function

function CoinBlueVisObjInit(_globalVars as object) as void
	CoinVisObjInit(m, _globalVars)
	m.spawnChance = _globalVars.COIN_BLUE_SPAWN_RATE
	m.CollidedUpdate = CoinBlueCollidedUpdate
end function

function CoinVisObjReset() as void
	m.state = m.STATE_DEATH
end function

function CoinVisObjSpawn() as void
	if ( (m.state = m.STATE_DEATH) AND (Rnd(0) < m.spawnChance) )
		m.state = m.STATE_INTRO_PREPARING
	end if
end function

function CoinVisObjUpdate(_deltatime as float, _balls as object, _hero1 as object, _hero2 as object) as void
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
		for i=0 to m.globalVars.MAX_BALL_COUNT-1
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
			m.CollidedUpdate(hero, m.globalVars)
		end if
	end if
		
	for each spriteObjName in m.spriteObjArray
		m.spriteObjArray[spriteObjName].Update(_deltatime, m.x, m.y)
	end for
end function

function CoinYellowCollidedUpdate(hero as object, _globalVars as object) as void
	hero.lifeCount = ClampF(hero.lifeCount + 1, 0, _globalVars.MAX_LIFE_COUNT)
end function

function CoinGreenCollidedUpdate(hero as object, _globalVars as object) as void
	HeroChangeSize(hero, _globalVars, 1)
end function

function CoinRedCollidedUpdate(hero as object, _globalVars as object) as void
	for each rocketLauncher in hero.rocketLaunchers
		if (rocketLauncher.state = rocketLauncher.STATE_DEATH) 
			rocketLauncher.Spawn(hero)
		end if
	end for
end function

function CoinBlackCollidedUpdate(hero as object, _globalVars as object) as void
	hero.lifeCount = ClampF(hero.lifeCount - 1, 0, _globalVars.MAX_LIFE_COUNT)
end function

function CoinWhiteCollidedUpdate(hero as object, _globalVars as object) as void
	_globalVars.numScoreObj.value += _globalVars.numScoreObj.COIN_WHITE_SCORE
end function

function CoinPinkCollidedUpdate(hero as object, _globalVars as object) as void
	hero.isFaster = true
end function

function CoinBlueCollidedUpdate(hero as object, _globalVars as object) as void
	hero.hasMagnet = true
end function

function RocketLauncherVisObjInit(_globalVars as object, _slotID as integer) as void
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
	m.globalVars = _globalVars
	m.parent = invalid
	m.spawnPosOffsetX = 0
	m.slotID = _slotID
end function

function RocketLauncherVisObjReset() as void
	m.state = m.STATE_DEATH
end function

function RocketLauncherVisObjSpawn(_hero as object) as void
	if ( (m.state = m.STATE_DEATH))
		m.state = m.STATE_INTRO_PREPARING
		m.parent = _hero
		m.spawnPosOffsetX = ( m.parent.width + m.width ) * (m.parent.heroID * 2 - 1) 
	end if
end function

function RocketLauncherVisObjUpdate(_deltatime as float) as void
	if (m.state = m.STATE_DEATH) 
		m.visible = false
		return
	end if
	
	if (m.state = m.STATE_INTRO_PREPARING)
		m.state = m.STATE_GAME
		m.x = m.parent.x + m.spawnPosOffsetX
		m.visible = true
		m.time = 0
	end if
	
	if (m.state = m.STATE_GAME)
		m.y = m.parent.y + (m.parent.height - m.height) * m.slotID
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
	m.OWNER_HERO1 = 1
	m.OWNER_HERO2 = 2
	m.owner = m.OWNER_HERO1
	m.globalVars = _globalVars
end function

function RocketVisObjReset() as void
	m.state = m.STATE_DEATH
end function

function RocketVisObjSpawn(_rocketLauncher as object, _owner as integer) as void
	if ( (m.state = m.STATE_DEATH))
		m.state = m.STATE_INTRO_PREPARING
		m.x = _rocketLauncher.x
		m.y = _rocketLauncher.y
		m.owner = _owner
		if (m.owner = m.OWNER_HERO1) 
			m.speedX = m.SPEED_X
		else 
			m.speedX = -m.SPEED_X
		end if
	end if
end function

function RocketVisObjUpdate(_deltatime as float, _hero1 as object, _hero2 as object, _balls as object) as void
	if (m.state = m.STATE_DEATH) 
		m.visible = false
		return
	end if
	
	if (m.state = m.STATE_INTRO_PREPARING)
		m.state = m.STATE_GAME
		m.visible = true
		m.time = 0
	end if
	
	if (m.state = m.STATE_GAME)
		m.x += m.speedX
		if ((m.x > m.globalVars.GAME_FIELD_MAX_X) OR (m.x < m.globalVars.GAME_FIELD_MIN_X)) 
			m.state = m.STATE_DEATH
			return
		end if
		if (m.owner = m.OWNER_HERO1) 
			targetHero = _hero2
		else 
			targetHero = _hero1
		end if
		isHeroCollided = CollisionBoxCheck(m, targetHero)
		if ( isHeroCollided = true)
			m.state = m.STATE_DEATH
			m.visible = false
			HeroChangeSize(targetHero, m.globalVars, -1)
		end if
		for each ball in _balls
			if ((ball.state = ball.STATE_GAME) AND (ball.isBallSmall = false))
				isBallCollided = CollisionBoxAndSphereCheck(m, ball)
				if (isBallCollided = true)
					m.state = m.STATE_DEATH
					m.visible = false
					BallVisObjSplits(m.globalVars, ball, ball, 1)
					ball2 = GetDeadBall(_balls)
					if (ball2 <> invalid)			
						BallVisObjSplits(m.globalVars, ball2, ball, -1)
					end if
				end if
			end if
		end for
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
	m.SMALL_RADIUS = 32
	m.DEFAULT_RADIUS = 64
	m.radius = m.DEFAULT_RADIUS
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
	m.GAME_SMALL_ANIMATION = "idle4"
	m.spawnX = _globalVars.GAME_FIELD_MAX_X / 2
	m.spawnY = _globalVars.GAME_FIELD_MAX_Y / 2
	m.Hero1Miss = false
	m.Hero2Miss = false
	m.globalVars = _globalVars
end function

function BallVisObjReset() as void
	m.state = m.STATE_DEATH
	m.x = m.spawnX
	m.y = m.spawnY
	m.ballCurrentSpeedX = 0
	m.ballCurrentSpeedY = 0
	m.Hero1Miss = false
	m.Hero2Miss = false
	m.isBallSmall = false
	m.flashingTimer = 1
	m.radius = m.DEFAULT_RADIUS
	m.maxX = m.globalVars.GAME_FIELD_MAX_X
	m.minX = m.globalVars.GAME_FIELD_MIN_X
	m.maxY = m.globalVars.GAME_FIELD_MAX_Y - m.radius
	m.minY = m.globalVars.GAME_FIELD_MIN_Y + m.radius
end function

function BallVisObjStart() as void
	ballSpeedAngle = m.globalVars.PI/4 + Rnd(0) * m.globalVars.PI/2
	m.ballCurrentSpeedX = Sin(ballSpeedAngle) * m.globalVars.BALL_SPEEDS[m.globalVars.menuState]
	m.ballCurrentSpeedY = Cos(ballSpeedAngle) * m.globalVars.BALL_SPEEDS[m.globalVars.menuState]
	m.state = m.STATE_GAME
	m.visible = true
	m.currentAnimationName = m.GAME_ANIMATION
end function

function BallVisObjSplits(_globalVars as object, _ball as object, _pivot as object, direction as float) as void
	_ball.ballCurrentSpeedX = _pivot.ballCurrentSpeedX * direction * 1.2
	_ball.ballCurrentSpeedY = _pivot.ballCurrentSpeedY * direction * Sgn(Rnd(0) - 0.5) * 1.2
	_ball.state = _ball.STATE_GAME
	_ball.visible = true
	_ball.currentAnimationName = _ball.GAME_SMALL_ANIMATION
	_ball.x = _pivot.x
	_ball.y = _pivot.y
	_ball.isBallSmall = true
	_ball.radius = _ball.SMALL_RADIUS
	_ball.maxX = _globalVars.GAME_FIELD_MAX_X
	_ball.minX = _globalVars.GAME_FIELD_MIN_X
	_ball.maxY = _globalVars.GAME_FIELD_MAX_Y - _ball.radius
	_ball.minY = _globalVars.GAME_FIELD_MIN_Y + _ball.radius
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
		distanceHero1X = Abs(_hero1.x - m.x)
		distanceHero2X = Abs(_hero2.x - m.x)
		distanceHero1Y = (_hero1.y - m.y) * _hero1.magnetObj.FORCE_Y
		distanceHero2Y = (_hero2.y - m.y) * _hero2.magnetObj.FORCE_Y
		
		if ( (_hero1.magnetTimer > 0) AND (distanceHero1X < _hero1.FORCE_DISTANCE) ) m.y += distanceHero1Y
		if ( (_hero2.magnetTimer > 0) AND (distanceHero2X < _hero2.FORCE_DISTANCE) ) m.y += distanceHero2Y
		if (m.x < m.minX) 
			m.Hero1Miss = true
			m.state = m.STATE_DEATH
			m.globalVars.isLastMissedBallHeroes = true
			return
		else if (m.x > m.maxX) 
			m.Hero2Miss = true
			_numScoreObj.value += _numScoreObj.AI_FAIL_SCORE
			m.state = m.STATE_DEATH
			m.globalVars.isLastMissedBallHeroes = false
			return
		end if
		if ( (m.y > m.maxY) OR (m.y < m.minY) ) 
			m.ballCurrentSpeedY *= -1
			m.y = ClampF(m.y, m.minY, m.maxY)
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

function isAllBallsDead(_balls as object) as boolean
	for each ball in _balls
		if (ball.state <> ball.STATE_DEATH) return false
	endfor
	return true
end function

function GetDeadBall(_balls as object) as object
	for each ball in _balls
		if (ball.state = ball.STATE_DEATH) return ball
	endfor
	return invalid
end function

function HeroVisObjInit(_heroID as integer, _globalVars as object, _rocketLaunchers as object, _enemy as object) as void
	m.heroID = _heroID 
	m.lifeCount = _globalVars.START_LIFE_COUNT
	m.width = 24
	m.SIZE_STATE_MAX = 2
	m.HEIGHTS = [43, 73, 132]
	m.ANIMS = ["idle3", "idle", "idle2"]
	m.SIZE_STATE_TIMES = [20, 0, 7]
	m.rocketLaunchers = _rocketLaunchers
	m.STATE_INTRO_PREPARING = 0
	m.STATE_INTRO = 1
	m.STATE_GAME = 2
	m.STATE_DEATH = 3
	m.state = m.STATE_INTRO_PREPARING
	m.SIZE_STATE_DEFAULT = 1
	m.globalVars = _globalVars
	m.enemy = _enemy
	m.FAST_TIME = 10
	m.FAST_SPEED_MODIFIER = 1.5
	m.MAGNET_TIME = 7
end function

function HeroVisObjReset(_speed) as void
	m.sizeState = 1
	m.height = m.HEIGHTS[m.sizeState]
	m.SPEED = _speed
	m.heroCurrentSpeed = 0
	m.maxY = m.globalVars.GAME_FIELD_MAX_Y - m.height
	m.minY = m.globalVars.GAME_FIELD_MIN_Y + m.height
	m.isBig = false
	m.sizeTimer = 0
	m.y = m.globalVars.GAME_FIELD_MAX_Y / 2
	m.currentAnimationName = m.ANIMS[m.sizeState]
	for each rocketLauncher in m.rocketLaunchers
		rocketLauncher.Reset()
	end for
	m.isFaster = false
	m.fastTimer = 0
	m.hasMagnet = false
	m.magnetTimer = 0
end function

function HeroVisObjUpdate(_deltatime as float) as void
	if (m.active = false) return
	
	if (m.isFaster = true) 
		m.fastTimer = m.FAST_TIME
		m.isFaster = false
	end if
	speed_modifier = 1
	if (m.fastTimer >0) 
		speed_modifier = m.FAST_SPEED_MODIFIER
		m.fastTimer -= _deltatime
	end if

	if (m.hasMagnet = true) 
		m.magnetTimer = m.MAGNET_TIME
		m.hasMagnet = false
	end if
	if (m.magnetTimer >0) 
		m.magnetObj.active = true
		m.magnetObj.visible = true
		m.magnetTimer -= _deltatime
	else
		m.magnetObj.active = false
		m.magnetObj.visible = false	
	end if
	
	m.y += m.heroCurrentSpeed * speed_modifier
	if (m.y > m.maxY) m.y = m.maxY
	if (m.y < m.minY) m.y = m.minY
	
	if (m.sizeState <> m.SIZE_STATE_DEFAULT) 
		m.sizeTimer -= _deltatime
		if (m.sizeTimer <= 0)
			m.sizeState = m.SIZE_STATE_DEFAULT
			m.currentAnimationName = m.ANIMS[m.sizeState]
			m.height = m.HEIGHTS[m.sizeState]
			m.maxY = m.globalVars.GAME_FIELD_MAX_Y - m.height
			m.minY = m.globalVars.GAME_FIELD_MIN_Y + m.height
			m.sizeTimer = 0
		end if
	end if
	
	for each rocketLauncher in m.rocketLaunchers
		rocketLauncher.Update(_deltatime)
	end for
	
	m.magnetObj.Update(_deltatime, m)
				
	for each spriteObjName in m.spriteObjArray
		m.spriteObjArray[spriteObjName].Update(_deltatime, m.x, m.y)
	end for
end function

function AIHeroVisObjUpdate(_deltatime as float, _balls=invalid as object, _rockets=invalid as object) as void
	if (m.active = false) return
	if (_balls = invalid) Goto SPRITES_UPDATE
	
	if (m.isFaster = true) 
		m.fastTimer = m.FAST_TIME
		m.isFaster = false
	end if
	speed_modifier = 1
	if (m.fastTimer >0)
		speed_modifier = m.FAST_SPEED_MODIFIER
		m.fastTimer -= _deltatime
	end if

	if (m.hasMagnet = true) 
		m.magnetTimer = m.MAGNET_TIME
		m.hasMagnet = false
	end if
	if (m.magnetTimer >0) 
		m.magnetObj.active = true
		m.magnetObj.visible = true
		m.magnetTimer -= _deltatime
	else
		m.magnetObj.active = false
		m.magnetObj.visible = false	
	end if
	
	nearestBallDistance = m.globalVars.GAME_FIELD_MAX_Y + m.globalVars.GAME_FIELD_MAX_X
	nearestBallNum = 0
	for i=0 to m.globalVars.MAX_BALL_COUNT-1
		if (_balls[i].state = m.STATE_GAME)
			ballDistance = Distance(_balls[i], m)
			if (ballDistance < nearestBallDistance )
				nearestBallNum = i
				nearestBallDistance = ballDistance
			end if
		end if
	end for
	
	m.heroCurrentSpeed = ClampF((_balls[nearestBallNum].y - m.y) * 0.4, -m.SPEED, m.SPEED)

	m.y += m.heroCurrentSpeed * speed_modifier
	if (m.y > m.maxY) m.y = m.maxY
	if (m.y < m.minY) m.y = m.minY
	
	if (m.globalVars <> invalid)
		if (m.sizeState <> m.SIZE_STATE_DEFAULT) 
			m.sizeTimer -= _deltatime
			if (m.sizeTimer <= 0)
				m.sizeState = m.SIZE_STATE_DEFAULT
				m.currentAnimationName = m.ANIMS[m.sizeState]
				m.height = m.HEIGHTS[m.sizeState]
				m.maxY = m.globalVars.GAME_FIELD_MAX_Y - m.height
				m.minY = m.globalVars.GAME_FIELD_MIN_Y + m.height
				m.sizeTimer = 0
			end if
		end if
	end if
	
	ememyDistance = Abs(m.enemy.y - m.y)
	if (ememyDistance < m.height + m.enemy.height)
		for each rocketLauncher in m.rocketLaunchers
			if (rocketLauncher.state = rocketLauncher.STATE_GAME)
				rocket = GetDeadRocket(_rockets, m.globalVars)
					if (rocket <> invalid) 
						rocket.Spawn(rocketLauncher, rocket.OWNER_HERO2)
						rocketLauncher.state = rocketLauncher.STATE_DEATH
						Goto AI_ROCKET_CHOSEN
					end if
				end if
			end for
	end if
AI_ROCKET_CHOSEN:
	
	for each rocketLauncher in m.rocketLaunchers
		rocketLauncher.Update(_deltatime)
	end for
	
	m.magnetObj.Update(_deltatime, m)
	
SPRITES_UPDATE:
	for each spriteObjName in m.spriteObjArray
		m.spriteObjArray[spriteObjName].Update(_deltatime, m.x, m.y)
	end for
end function

function HeroChangeSize(hero as object, _globalVars as object, sizeChanger as float) as void
	hero.sizeState = ClampI(hero.sizeState + sizeChanger, 0, hero.SIZE_STATE_MAX)
	hero.currentAnimationName = hero.ANIMS[hero.sizeState]
	hero.height = hero.HEIGHTS[hero.sizeState]
	hero.maxY = _globalVars.GAME_FIELD_MAX_Y - hero.height
	hero.minY = _globalVars.GAME_FIELD_MIN_Y + hero.height
	hero.sizeTimer = hero.SIZE_STATE_TIMES[hero.sizeState]
end function

function MagnetObInit(_globalVars as object, _offset as float) as void
	m.width = 32
	m.height = 32
	m.active = false
	m.visible = false
	m.globalVars = _globalVars
	m.offsetX = _offset
	m.FORCE_Y = 0.02
	m.FORCE_DISTANCE = (_globalVars.GAME_FIELD_MAX_Y - _globalVars.GAME_FIELD_MIN_Y) * 0.5
end function

function MagnetObUpdate(_deltatime as float, _hero as object) as void
	if (m.active = false) return
	m.x = _hero.x - (_hero.width + m.width) * m.offsetX
	m.y = _hero.y

	for each spriteObjName in m.spriteObjArray
		m.spriteObjArray[spriteObjName].Update(_deltatime, m.x, m.y)
	end for
end function