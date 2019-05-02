Library "v30/bslDefender.brs" 

function Main() as void
    mainMenuBackDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/mainMenu.xml"))
    gameLevelDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/gameLevel.xml"))
    gameObjectsDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/gameObjects.xml"))
    gameUIDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/gameUI.xml"))
    gameBallDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/ballAnim.xml"))
    
    
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
' ------- NEW -----------------------------------
        STABLE_FPS			: 1.0 / 30.0    'stable 30 fps
        PI					: 3.14159265359
        BALL_START_SPEED	: 10.0
        BALL_RADIUSES		: [10.0, 20.0, 40.0]
        
        MAX_LEVEL_COLUMNS	: 13
        MAX_LEVEL_LINES		: 17
        
        PLAYER_MOVE_CODE_RIGHT	: 1
        PLAYER_MOVE_CODE_LEFT	: 2
        
        PLAYER_START_SPEED		: 10.0
        
        PLAYER_WIDTHS		: [112.0, 147.0, 225.0]
        PLAYER_HEIGHT		: 28.0
        
        PLAYER_POS_Y		: 670.0
        
        PLAYER_COLLISION_SLOPE_WIDTH : 19.0
        PLAYER_COLLISION_SLOPE_OFFSET: [{x: 38.0, y: 7.0}, 
        								{x: 38.0, y: 7.0},
        								{x: 38.0, y: 7.0}]
        PLAYER_COLLISION_SLOPE_RADIUS : {x: 20.0, y: 34.0}
        
        screenWidth			: screenWidth
        screenHeight		: screenHeight
' NEED DELETE ------------------------------------------------------
' --------- GLOBAL VARS ---------------------------------------------------------------------------------
    
        HIT_BALL_SCORE  : 50
        AI_FAIL_SCORE   : 100
        COIN_WHITE_SCORE: 500
        
        BALL_SPEEDS     : [5, 10, 15] 'speed depends on game difficulty
		HERO_SPEED			: 10
        AI_HERO_SPEEDS  : [3.3, 7, 13] 'speed depends on game difficulty

    
        bestScore       : 0
        numScoreObj     : invalid
        MAX_SCORE       : 99999
        
' --------- GAME VARS ---------------------------------------------------------------------------------
        NEW_LIFE_LOOP_DELAY : 1


        MAX_LIFE_COUNT      : 6
        START_LIFE_COUNT    : 4
        
        MAX_BALL_COUNT      : 4
        isLastMissedBallHeroes  : false
        
        MAX_ROCKET_COUNT    : 4
        
        HERO1_ID            : 0
        HERO2_ID            : 1
        
        COIN_SPEED_X        : 3
        
        SLOW_TIME           : 10
        
        COIN_YELLOW_SPAWN_RATE  : 0.0003
        COIN_GREEN_SPAWN_RATE   : 0.01  
        COIN_RED_SPAWN_RATE     : 0.004
        COIN_WHITE_SPAWN_RATE   : 0.1
        COIN_PINK_SPAWN_RATE    : 0.1   
        COIN_BLACK_SPAWN_RATE   : 1 '0.0003
        COIN_BLUE_SPAWN_RATE    : 1 '0.01

' --------- MAIN MENU VARS ---------------------------------------------------------------------------------
        GAME_STATE_MENU_L1  : 0
        GAME_STATE_MENU_L2  : 1
        GAME_STATE_MENU_L3  : 2

        GAME_STATE_MENU_X   : [ 280, 560, 490 ]
        GAME_STATE_MENU_Y   : [ 489, 550, 610 ]
' --------- INTRO VARS ---------------------------------------------------------------------------------    
        GAME_INTRO_DELAY    : 1.0

' --------- GAME OVER VARS ---------------------------------------------------------------------------------    
        GAME_OVER_DELAY     : 3.0
        GOAL_DELAY          : 1.0
    }
    GAME_VARS.menuState = GAME_VARS.GAME_STATE_MENU_L1
	
	GAME_VARS.BRICK_WIDTH 		= 64
    GAME_VARS.BRICK_HEIGHT 		= 25
        
	GAME_VARS.GAME_FIELD_WIDTH	= GAME_VARS.BRICK_WIDTH * GAME_VARS.MAX_LEVEL_COLUMNS
	GAME_VARS.GAME_FIELD_HEIGHT	= GAME_VARS.BRICK_HEIGHT * GAME_VARS.MAX_LEVEL_LINES
        
	GAME_VARS.GAME_FIELD_MIN_X	= 63
	GAME_VARS.GAME_FIELD_MAX_X	= GAME_VARS.GAME_FIELD_MIN_X + GAME_VARS.GAME_FIELD_WIDTH
	GAME_VARS.GAME_FIELD_MIN_Y	= 34
	GAME_VARS.GAME_FIELD_MAX_Y	= GAME_VARS.GAME_FIELD_MIN_Y + GAME_VARS.GAME_FIELD_HEIGHT
    GAME_VARS.screen = screen

    if ( scoreRegSection.Exists("BestScore")) 
        GAME_VARS.bestScore = scoreRegSection.Read("BestScore").ToInt()
    else 
        scoreRegSection.write("BestScore", GAME_VARS.bestScore.ToStr())
        scoreRegSection.Flush()
    end if

' ------------------------------------------------------------------------------------------
' --------- MUSIC ---------------------------------------------------------------------------------
	audioPlayer = CreateObject("roAudioPlayer")
	audioPlayer.SetMessagePort(port)
	song = CreateObject("roAssociativeArray")
	song.url = "pkg:/sounds/level01.mp3"
	audioplayer.addcontent(song)
	audioplayer.setloop(true)
	audioPlayer.play()
' ------------------------------------------------------------------------------------------
' --------- SOUNDS ---------------------------------------------------------------------------------
	GAME_VARS.Sound_MainMenu_Intro = CreateObject("roAudioResource", "pkg:/sounds/main_menu_intro.wav")
	GAME_VARS.Sound_GameOver = CreateObject("roAudioResource", "pkg:/sounds/game_over.wav")
	GAME_VARS.Sound_goal = CreateObject("roAudioResource", "pkg:/sounds/goal.wav")
	GAME_VARS.Sound_gun_shoot = CreateObject("roAudioResource", "pkg:/sounds/gun_shoot.wav")
	GAME_VARS.Sound_hit = CreateObject("roAudioResource", "pkg:/sounds/hit.wav")
	GAME_VARS.Sound_magnet = CreateObject("roAudioResource", "pkg:/sounds/magnet.wav")
	GAME_VARS.Sound_score = CreateObject("roAudioResource", "pkg:/sounds/score.wav")
    GAME_VARS.Sound_slow = CreateObject("roAudioResource", "pkg:/sounds/slow.wav")
    GAME_VARS.Sound_speed = CreateObject("roAudioResource", "pkg:/sounds/speed.wav")
    GAME_VARS.Sound_wide = CreateObject("roAudioResource", "pkg:/sounds/wide.wav")
    GAME_VARS.Sound_win = CreateObject("roAudioResource", "pkg:/sounds/win.wav")
    GAME_VARS.Sound_shorten = CreateObject("roAudioResource", "pkg:/sounds/shorten.wav")
    GAME_VARS.Sound_levelup = CreateObject("roAudioResource", "pkg:/sounds/levelup.wav")
    GAME_VARS.Sound_new_round = CreateObject("roAudioResource", "pkg:/sounds/new_round.wav")
' ------------------------------------------------------------------------------------------

    mainMenuBackObj = CreateSpriteObj(mainMenuBackDataSet.regions.mainMenu_Back, screen, 0, 0, -0.5, -0.5, 1.0, 1.0)
    mainMenu_GameTitleObj = CreateSpriteObj(mainMenuBackDataSet.regions.mainMenu_GameTitle, screen, screenWidth/2, screenHeight * 0.4, 0, 0, 1.0, 1.0)
	mainMenu_OptionsObj = CreateSpriteObj(mainMenuBackDataSet.regions.mainMenu_Options, screen, screenWidth/2, screenHeight * 0.75, 0, 0, 1.0, 1.0)
	
' ------------------------------------------------------------------------------------------	
	gameLevel_BackObj = CreateSpriteObj(gameLevelDataSet.regions.gameLevel_Back, screen, 0, 0, -0.5, -0.5, 1.0, 1.0)
	gameLevel_BackObj.Update = ScrolledSpriteUpdate
	gameLevel_BackObj.Init = ScrolledSpriteInit
	gameLevel_BackObj.Init(0,-80)
	
	gameLevel_BorderCLObj = CreateSpriteObj(gameLevelDataSet.regions.gameLevel_BorderCL, screen, 9, 31, -0.5, 0, 1.0, 1.0)
	gameLevel_BorderCLObj.Update()
	gameLevel_BorderCRObj = CreateSpriteObj(gameLevelDataSet.regions.gameLevel_BorderCR, screen, 851, 31, -0.5, 0, 1.0, 1.0)
	gameLevel_BorderCRObj.Update()
	gameLevel_BorderHObj = CreateSpriteObj(gameLevelDataSet.regions.gameLevel_BorderH, screen, 0, 15, -0.5, 0, 1.0, 1.0)
	gameLevel_BorderLObj = CreateSpriteObj(gameLevelDataSet.regions.gameLevel_BorderL, screen, 7, 0, -0.5, -0.5, 1.0, 1.0)
	gameLevel_BorderRObj = CreateSpriteObj(gameLevelDataSet.regions.gameLevel_BorderR, screen, 881, 0, -0.5, -0.5, 1.0, 1.0)

	gameUI_LogoObj = CreateSpriteObj(gameUIDataSet.regions.gameUI_Logo, screen, 967, 14, -0.5, -0.5, 1.0, 1.0)
	gameUI_LogoObj.Update()
	gameUI_TextLevelObj = CreateSpriteObj(gameUIDataSet.regions.gameUI_TextLevel, screen, 1045, 147, -0.5, -0.5, 1.0, 1.0)
	gameUI_TextLevelObj.Update()
	gameUI_PlatformObj = CreateSpriteObj(gameUIDataSet.regions.gameUI_Platform, screen, 1023, 189, -0.5, -0.5, 1.0, 1.0)
	gameUI_PlatformObj.Update()
	gameUI_TextHiscoreObj = CreateSpriteObj(gameUIDataSet.regions.gameUI_TextHiscore, screen, 1041, 286, -0.5, -0.5, 1.0, 1.0)
	gameUI_TextHiscoreObj.Update()
	gameUI_TextScoreObj = CreateSpriteObj(gameUIDataSet.regions.gameUI_TextScore, screen, 1059, 386, -0.5, -0.5, 1.0, 1.0)
	gameUI_TextScoreObj.Update()
	gameUI_TextEnergyObj = CreateSpriteObj(gameUIDataSet.regions.gameUI_TextEnergy, screen, 1054, 487, -0.5, -0.5, 1.0, 1.0)
	gameUI_TextEnergyObj.Update()
	gameUI_EnergyBorderObj = CreateSpriteObj(gameUIDataSet.regions.gameUI_EnergyBorder, screen, 970, 520, -0.5, -0.5, 1.0, 1.0)
	gameUI_EnergyBorderObj.Update()
	gameUI_EnergyBarObj = CreateSpriteObj(gameUIDataSet.regions.gameUI_EnergyBar, screen, 974, 518, -0.5, -0.5, 1.0, 1.0)
	gameUI_EnergyBarObj.Update()
	gameUI_TextBoosterObj = CreateSpriteObj(gameUIDataSet.regions.gameUI_TextBooster, screen, 1020, 573, -0.5, -0.5, 1.0, 1.0)
	gameUI_TextBoosterObj.Update()
	gameUI_TextBoosterXObj = CreateSpriteObj(gameUIDataSet.regions.gameUI_TextBoosterX, screen, 1072, 632, -0.5, -0.5, 1.0, 1.0)
	gameUI_TextBoosterXObj.Update()
	gameUI_BottomLineObj = CreateSpriteObj(gameUIDataSet.regions.gameUI_BottomLine, screen, 41, 678, -0.5, 0, 875.0, 1.0)
	gameUI_BottomLineObj.Update()
' DEBUG LINE AROUND GAME FIELD------------------------------------------------------------------------------------------
	
	gameLevel_DebugWhiteFieldObj = CreateSpriteObj(gameLevelDataSet.regions.whitePixel, screen, GAME_VARS.GAME_FIELD_MIN_X, GAME_VARS.GAME_FIELD_MIN_Y, -0.5, -0.5, GAME_VARS.GAME_FIELD_WIDTH, screenHeight - GAME_VARS.GAME_FIELD_MIN_Y)
	gameLevel_DebugWhiteFieldObj.Update()
	
	
' ------------------------------------------------------------------------------------------	
	firstLevel = CreateLevel(GAME_VARS, "pkg:/assets/testLevel.txt", gameObjectsDataSet)
	player = CreatePlayer(GAME_VARS, gameObjectsDataSet)
	ball = CreateBall(GAME_VARS, gameBallDataSet, firstLevel, player, player.SpawnPos())
	
	
' ------------------------------------------------------------------------------------------	
    clock.Mark()

MENU_LOOP:
	
	Goto GAME_TEST_LOOP  ''sssssssssssssssssssssssssss delete it is test
	
    GAME_VARS.Sound_MainMenu_Intro.Trigger(65)
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
                Goto GAME_TEST_LOOP
            endif
            if (id = 0) Goto EXIT_GAME
        else if (event = invalid)
                deltaTime = clock.TotalMilliseconds() / 1000.0
            if (deltaTime > GAME_VARS.STABLE_FPS) 
                mainMenuBackObj.Update()
				mainMenu_GameTitleObj.Update()
				mainMenu_OptionsObj.Update()

                mainMenuBackObj.Draw()
				mainMenu_GameTitleObj.Draw()
				mainMenu_OptionsObj.Draw()
                screen.SwapBuffers()
                clock.Mark()
            endif        
        endif
    end while

GAME_TEST_LOOP:
    GAME_VARS.Sound_MainMenu_Intro.Trigger(65)
	lastID = 0
    while true
        event = port.GetMessage()
        if (type(event) = "roUniversalControlEvent")
            id = event.GetInt()
            if (id = codes.BUTTON_LEFT_PRESSED)
                player.Move(GAME_VARS.PLAYER_MOVE_CODE_LEFT)
            endif
            if (id = codes.BUTTON_RIGHT_PRESSED)
                player.Move(GAME_VARS.PLAYER_MOVE_CODE_RIGHT)
            endif
            if (id = 6)             
                'Goto GAME_INTRO_LOOP
            endif
            if (id = 0) Goto EXIT_GAME
            lastID = id
        else if (event = invalid)
                deltaTime = clock.TotalMilliseconds() / 1000.0
            if (deltaTime > GAME_VARS.STABLE_FPS) 
                ' uninteractive back and UI elements
                gameLevel_BackObj.Update(deltaTime)
                gameLevel_BackObj.Draw()
                gameUI_BottomLineObj.Draw()
				for i=0 to 4
					gameLevel_BorderLObj.y = i * gameLevel_BorderLObj.currentRegion.GetHeight() + 81 
					gameLevel_BorderLObj.Update()
					gameLevel_BorderLObj.Draw()
					gameLevel_BorderRObj.y = i * gameLevel_BorderRObj.currentRegion.GetHeight() + 81 
					gameLevel_BorderRObj.Update()
					gameLevel_BorderRObj.Draw()
				end for
				for i=0 to 5
					gameLevel_BorderHObj.x = i * gameLevel_BorderHObj.currentRegion.GetWidth() + 107 
					gameLevel_BorderHObj.Update()
					gameLevel_BorderHObj.Draw()
				end for
				gameLevel_BorderCLObj.Draw()
				gameLevel_BorderCRObj.Draw()
				
				gameUI_LogoObj.Draw()
				gameUI_EnergyBorderObj.Draw()
				gameUI_EnergyBarObj.Draw()
				gameUI_PlatformObj.Draw()
				gameUI_TextBoosterObj.Draw()
				gameUI_TextBoosterXObj.Draw()
				gameUI_TextEnergyObj.Draw()
				gameUI_TextHiscoreObj.Draw()
				gameUI_TextLevelObj.Draw()
				gameUI_TextScoreObj.Draw()
				
				if (lastID = 7) gameLevel_DebugWhiteFieldObj.Draw()
				' end line for uninteractive back and UI elements
				
				firstLevel.Draw()
				
				player.Update(deltaTime)
				player.Draw()
				
				ball.Update(deltaTime)
				ball.Draw()
				
                screen.SwapBuffers()
                clock.Mark()
            endif        
        endif
    end while

GAME_INTRO_LOOP:
    GAME_VARS.Sound_new_round.Trigger(60)
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
                            GAME_VARS.Sound_gun_shoot.Trigger(65)
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
                heroObj1.speedIconObj.Draw()
                heroObj2.speedIconObj.Draw()
                screen.SwapBuffers()
                                
                isAllBallsMissed = isAllBallsDead(balls)
                
                if (isAllBallsMissed = true)
                    if (GAME_VARS.isLastMissedBallHeroes  = true) 
                        heroObj1.lifeCount -= 1
                        if (heroObj1.lifeCount > 0) 
                            Goto NEW_LIFE_LOOP
                        endif
                    else
                        heroObj2.lifeCount -= 1
                        if (heroObj2.lifeCount > 0) 
                            Goto GAME_GOAL_LOOP
                        endif
                    endif
                end if
                if (heroObj1.lifeCount <= 0) Goto GAME_OVER_LOOP
                if (heroObj2.lifeCount <= 0) Goto GAME_WIN_LOOP

                clock.Mark()
            endif        
        endif
    end while
    
GAME_GOAL_LOOP:
    GAME_VARS.Sound_goal.Trigger(50)
    gameOverLoopTime = 0.0
    textGoalObj.currentTime = 0.0
    textGoalObj.time = 0.5
    textGoalObj.scaleStart = 1.7
    textGoalObj.scaleEnd = 0.999
    textGoalObj.scale = textGoalObj.scaleStart
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
                textGoalObj.Update(deltaTime)
                numBestScoreObj.Update(deltaTime)
                textBestScoreObj.Update(deltaTime)
                for i=0 to heroObj1.lifeCount-1
                    hero1LivesObj[i].Update(deltaTime)
                end for
                for i=0 to heroObj2.lifeCount-1
                    hero2LivesObj[i].Update(deltaTime)
                end for


                backObj.Draw()
                textBestScoreObj.Draw()
                numBestScoreObj.Draw()
                textScoreObj.Draw()
                numScoreObj.Draw()
                heroObj1.Draw()
                heroObj2.Draw()
                for i=0 to heroObj1.lifeCount-1
                    hero1LivesObj[i].Draw()
                end for
                for i=0 to heroObj2.lifeCount-1
                    hero2LivesObj[i].Draw()
                end for
            
                textGoalObj.Draw()
            
                screen.SwapBuffers()
            
                if (gameOverLoopTime > GAME_VARS.GOAL_DELAY) Goto NEW_LIFE_LOOP
                gameOverLoopTime += deltaTime
            
                clock.Mark()
            endif
        end if
    end while

GAME_OVER_LOOP:
    GAME_VARS.Sound_GameOver.Trigger(50)
    gameOverLoopTime = 0.0
    textGameOverObj.currentTime = 0.0
    textGameOverObj.time = 1
    textGameOverObj.scaleStart = 1.7
    textGameOverObj.scaleEnd = 0.999
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
                for i=0 to heroObj1.lifeCount-1
                    hero1LivesObj[i].Update(deltaTime)
                end for
                for i=0 to heroObj2.lifeCount-1
                    hero2LivesObj[i].Update(deltaTime)
                end for

                backObj.Draw()
                textBestScoreObj.Draw()
                numBestScoreObj.Draw()
                textScoreObj.Draw()
                numScoreObj.Draw()
                heroObj1.Draw()
                heroObj2.Draw()

                for i=0 to heroObj1.lifeCount-1
                    hero1LivesObj[i].Draw()
                end for
                for i=0 to heroObj2.lifeCount-1
                    hero2LivesObj[i].Draw()
                end for         
                textGameOverObj.Draw()
            
                screen.SwapBuffers()
            
                if (gameOverLoopTime > GAME_VARS.GAME_OVER_DELAY) Goto MENU_LOOP
                gameOverLoopTime += deltaTime
            
                clock.Mark()
            endif
        end if
    end while

GAME_WIN_LOOP:
    GAME_VARS.Sound_win.Trigger(65)
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
                for i=0 to heroObj1.lifeCount-1
                    hero1LivesObj[i].Update(deltaTime)
                end for
                for i=0 to heroObj2.lifeCount-1
                    hero2LivesObj[i].Update(deltaTime)
                end for
                
                backObj.Draw()
                textBestScoreObj.Draw()
                numBestScoreObj.Draw()
                textScoreObj.Draw()
                numScoreObj.Draw()
                heroObj1.Draw()
                heroObj2.Draw()
                for i=0 to heroObj1.lifeCount-1
                    hero1LivesObj[i].Draw()
                end for
                for i=0 to heroObj2.lifeCount-1
                    hero2LivesObj[i].Draw()
                end for         
            
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

function VectorLength(_obj1 as object) as float
    res = Sqr(_obj1.x * _obj1.x + _obj1.y * _obj1.y )
    return res
end function

function NormalizeVector(_vec as object) as object
	if (_vec.x = 0 AND _vec.y = 0)
		return _vec
	end if
	vecLength = VectorLength(_vec)
	_vec.x = _vec.x / vecLength
	_vec.y = _vec.y / vecLength
	return _vec
end function

function DotProduct(_vec1 as object, _vec2 as object) as float
	dot = _vec1.x * _vec2.x + _vec1.y * _vec2.y 
	return dot
end function 

function ReflectVector(_vec as object, _normal as object) as object
	dot = DotProduct(_vec, _normal)
	reflectVec = {x: 0.0, y: 0.0}
	reflectVec.x = _vec.x - 2 * dot * _normal.x
	reflectVec.y = _vec.y - 2 * dot * _normal.y	
	return reflectVec
end function
' COLLISION API /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function CreateCollisionEngine() as object
    obj = {
        id                      : 0 ' id for next created obj
        active                  : true
        collisionGroups         : {} ' {groupName : {id, obj}}
        COLLISION_TYPE_BOX      : 0
        COLLISION_TYPE_CIRCLE   : 1
        
        AddCollision    : AddCollision
        Update          : CollisionEngineUpdate
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
        active  : true
        collisionType   : _collisionType
        group   : _group
        collidingGroupList  : _collidingGroupList
        collisionEngine : _collisionEngine
        x       : _x
        y       : _y        
        scaleX  : _scaleX
        scaleY  : _scaleY
        speedX  : 0
        speedY  : 0
        collidingObjects    : []
        collidedObjObects   : []
        
        Update  : CollisionUpdate
        Destroy : CollisionDestroy
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
        active          : true
        visible         : true
        value           : _value
        x               : _x
        y               : _y
        localOffsetX    : _localOffsetX
        localOffsetY    : _localOffsetY
        drawX           : 0
        drawY           : 0
        scaleX          : _scaleX
        scaleY          : _scaleY
        length          : 1.0
        loop            : true
        speed           : 1.0
        time            : 0
        regions         : _regions
        screen          : _screen
        actualDrawRegions   : []
        beetweenCharOffset  : 0
        charWidth       : _regions[0].GetWidth()
        charHeight      : _regions[0].GetHeight()
        
        Draw            : DrawNumberText
        Update          : SimpleNumberTextUpdate
        AnimationUpdate : _AnimationUpdate
    }
    
    for each region in obj.regions
        region.SetScaleMode(1)
    end for
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
        active  : true
        visible : true
        name    : _name
        length  : 1.0
        loop    : true
        speed   : 1.0
        time    : 0
        x       : _x
        y       : _y
        localOffsetX    : _localOffsetX
        localOffsetY    : _localOffsetY
        drawX   : 0
        drawY   : 0
        scaleX  : _scaleX
        scaleY  : _scaleY
        regions : _regions
        currentRegion   : _region
        currentRegionNum    : 0
        screen  : _screen
        scrollSpeedX    : 0
        scrollSpeedY    : 0
        spriteWidth     : 0
        spriteHeight    : 0
        
        Draw    : SpriteDraw
        Update  : SimpleSpriteUpdate
        AnimationUpdate : _AnimationUpdate
    }
    obj.currentRegion.SetScaleMode(1)
    return obj
end function

function SpriteDraw() as void
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

function ScrolledSpriteInit(_scrollSpeedX as float, _scrollSpeedY as float)
    m.scrollSpeedX = _scrollSpeedX
    m.scrollSpeedY = _scrollSpeedY
    m.currentRegion.SetWrap(true)
    m.spriteWidth = m.currentRegion.GetWidth()
    m.spriteHeight = m.currentRegion.GetHeight()
end function

function ScrolledSpriteUpdate(_deltatime=0 as float, _x=0 as float, _y=0 as float) as void
    if (m.active = false) return

    m.drawX = m.x + (-m.localOffsetX - 0.5) * m.currentRegion.GetWidth() * m.scaleX + _x
    m.drawY = m.y + (-m.localOffsetY - 0.5) * m.currentRegion.GetHeight() * m.scaleY + _y
    currentSpriteOffsetX = _deltatime * m.scrollSpeedX
    currentSpriteOffsetY = _deltatime * m.scrollSpeedY
    currentSpriteOffsetX -= Int(currentSpriteOffsetX / m.spriteWidth) * m.spriteWidth
    currentSpriteOffsetY -= Int(currentSpriteOffsetY / m.spriteHeight) * m.spriteHeight
    m.currentRegion.Offset(currentSpriteOffsetX, currentSpriteOffsetY, 0, 0)
end function

function CreateVisObj(_name as String, _screen as object, _x as float, _y as float, _animsData as object, _currentAnimationName="idle" as String, _Update=SimpleVisObjUpdate as object) as object
    obj = {
        active  : true
        visible : true
        name    : _name
        screen  : _screen
        x       : _x
        y       : _y
        width   : 64
        height  : 64
        spriteObjArray  : {}
        currentAnimationName    : _currentAnimationName
                
        Draw    : VisObjDraw
        Update  : _Update
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
    m.scaleEnd = 0.999
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
    _coin.spawnX = _globalVars.GAME_FIELD_MAX_X / 2 + Sgn(Rnd(0)-0.5) * _coin.width 
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
        speedDirection = 0
        if ( (_hero1.magnetTimer > 0 ) AND (_hero1.y - _hero1.height < m.y ) AND (_hero1.y + _hero1.height > m.y ) ) speedDirection -= 1 
        if (_hero2.magnetTimer > 0 ) speedDirection += 1
        if (speedDirection <> 0)
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
    _globalVars.Sound_levelup.Trigger(65)
end function

function CoinGreenCollidedUpdate(hero as object, _globalVars as object) as void
    HeroChangeSize(hero, _globalVars, 1)
    _globalVars.Sound_wide.Trigger(65)
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
    hero.isLifeLost = true
    _globalVars.Sound_slow.Trigger(65)
end function

function CoinWhiteCollidedUpdate(hero as object, _globalVars as object) as void
    _globalVars.numScoreObj.value += _globalVars.numScoreObj.COIN_WHITE_SCORE
    _globalVars.numScoreObj.value = ClampI(_globalVars.numScoreObj.value, 0, _globalVars.MAX_SCORE)
    _globalVars.Sound_score.Trigger(65)
end function

function CoinPinkCollidedUpdate(hero as object, _globalVars as object) as void
    hero.isFaster = true
    _globalVars.Sound_speed.Trigger(65)
end function

function CoinBlueCollidedUpdate(hero as object, _globalVars as object) as void
    hero.hasMagnet = true
    _globalVars.Sound_magnet.Trigger(65)
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
            m.globalVars.Sound_shorten.Trigger(65)
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
        ballSpeedOld = {
            x : m.ballCurrentSpeedX
            y : m.ballCurrentSpeedY
        }
        distanceHero1X = _hero1.x - m.x
        distanceHero2X = _hero2.x - m.x
        distanceHero1Y = _hero1.y - m.y
        distanceHero2Y = _hero2.y - m.y
        changeSpeed = false
        
        if ( (_hero1.magnetTimer > 0) AND (Abs(distanceHero1X) < _hero1.magnetObj.FORCE_DISTANCE) AND (m.ballCurrentSpeedX<0) ) 
            m.ballCurrentSpeedX += distanceHero1X * _hero1.magnetObj.FORCE_X
            m.ballCurrentSpeedY += distanceHero1Y * _hero1.magnetObj.FORCE_Y
            changeSpeed = true
        end if
        if ( (_hero2.magnetTimer > 0) AND (Abs(distanceHero2X) < _hero2.magnetObj.FORCE_DISTANCE) AND (m.ballCurrentSpeedX>0))
            m.ballCurrentSpeedX += distanceHero2X * _hero2.magnetObj.FORCE_X
            m.ballCurrentSpeedY += distanceHero2Y * _hero2.magnetObj.FORCE_Y
            changeSpeed = true
        end if
        
        ballSpeed = {
            x : m.ballCurrentSpeedX
            y : m.ballCurrentSpeedY
        }
        if (changeSpeed = true)
            ballSpeedLengthOld = VectorLength(ballSpeedOld)
            ballSpeedLength = VectorLength(ballSpeed)  
            m.ballCurrentSpeedX = m.ballCurrentSpeedX / ballSpeedLength * ballSpeedLengthOld 
            m.ballCurrentSpeedY = m.ballCurrentSpeedY / ballSpeedLength * ballSpeedLengthOld
            if (Abs(m.ballCurrentSpeedY) > Abs(m.ballCurrentSpeedX))
                m.ballCurrentSpeedX = ballSpeedOld.x
                m.ballCurrentSpeedY = ballSpeedOld.y
            end if
        end if
        
        m.x += m.ballCurrentSpeedX
        m.y += m.ballCurrentSpeedY
        if (m.x < m.minX) 
            m.Hero1Miss = true
            m.state = m.STATE_DEATH
            m.globalVars.isLastMissedBallHeroes = true
            m.globalVars.Sound_slow.Trigger(65)
            return
        else if (m.x > m.maxX) 
            m.Hero2Miss = true
            _numScoreObj.value += _numScoreObj.AI_FAIL_SCORE
            _numScoreObj.value = ClampI(_numScoreObj.value, 0, m.globalVars.MAX_SCORE)
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
                m.globalVars.Sound_hit.Trigger(100)
            endif
        endif
    
        if (isHero1HitBall = true) _numScoreObj.value += _numScoreObj.HIT_BALL_SCORE
        _numScoreObj.value = ClampI(_numScoreObj.value, 0, m.globalVars.MAX_SCORE)

        isHero2HitBall = false
        toHero2distanceX = Abs(_hero2.x - m.x)
        if (toHero2distanceX < m.radius)
            if ( (m.y < _hero2.y + _hero2.height ) AND (m.y > _hero2.y - _hero2.height ) ) 
                m.ballCurrentSpeedX *= -1
                m.ballCurrentSpeedY += _hero2.heroCurrentSpeed * 0.3
                m.ballCurrentSpeedX *= 1.1
            
                m.x = _hero2.x - m.radius
                isHero2HitBall = true
                m.globalVars.Sound_hit.Trigger(100)
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
    m.LIFE_LOST_SHACKING_TIME = _globalVars.SLOW_TIME
    m.LIFE_LOST_SHACKING_SPEED = 30
    m.LIFE_LOST_SHACKING_AMPLITUDE = 5
    m.SPAWN_X = m.x
    m.SLOW_SPEED_MODIFIER = 0.5
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
    m.isLifeLost = false
    m.lifeLostShackingTimer = 0
    m.x = m.SPAWN_X
end function

function HeroVisObjUpdate(_deltatime as float) as void
    if (m.active = false) return
    
    speed_modifier = 1
    if (m.isLifeLost = true)
        m.isLifeLost = false
        m.lifeLostShackingTimer = m.LIFE_LOST_SHACKING_TIME
    end if
    
    if (m.lifeLostShackingTimer > 0)
        m.lifeLostShackingTimer -= _deltatime
        m.x = m.SPAWN_X + Sin(m.lifeLostShackingTimer * m.LIFE_LOST_SHACKING_SPEED) * m.LIFE_LOST_SHACKING_AMPLITUDE
        m.isFaster = false
        speed_modifier = m.SLOW_SPEED_MODIFIER
        m.fastTimer = 0
    end if
    
    if (m.isFaster = true) 
        m.fastTimer = m.FAST_TIME
        m.isFaster = false
    end if
    if (m.fastTimer >0) 
        speed_modifier = m.FAST_SPEED_MODIFIER
        m.fastTimer -= _deltatime
        m.speedIconObj.active = true
        m.speedIconObj.visible = true
    else
        m.speedIconObj.active = false
        m.speedIconObj.visible = false  
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
    m.speedIconObj.Update(_deltatime, m)
                
    for each spriteObjName in m.spriteObjArray
        m.spriteObjArray[spriteObjName].Update(_deltatime, m.x, m.y)
    end for
end function

function AIHeroVisObjUpdate(_deltatime as float, _balls=invalid as object, _rockets=invalid as object) as void
    if (m.active = false) return
    if (_balls = invalid) Goto SPRITES_UPDATE
    
    speed_modifier = 1
    if (m.isLifeLost = true)
        m.isLifeLost = false
        m.lifeLostShackingTimer = m.LIFE_LOST_SHACKING_TIME
    end if
    
    if (m.lifeLostShackingTimer > 0)
        m.lifeLostShackingTimer -= _deltatime
        m.x = m.SPAWN_X + Sin(m.lifeLostShackingTimer * m.LIFE_LOST_SHACKING_SPEED) * m.LIFE_LOST_SHACKING_AMPLITUDE
        m.isFaster = false
        speed_modifier = m.SLOW_SPEED_MODIFIER
        m.fastTimer = 0
    end if
    
    if (m.isFaster = true) 
        m.fastTimer = m.FAST_TIME
        m.isFaster = false
    end if
    
    if (m.fastTimer >0)
        speed_modifier = m.FAST_SPEED_MODIFIER
        m.fastTimer -= _deltatime
        m.speedIconObj.active = true
        m.speedIconObj.visible = true
    else
        m.speedIconObj.active = false
        m.speedIconObj.visible = false  
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
    m.speedIconObj.Update(_deltatime, m)
    
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

function MagnetObjInit(_globalVars as object, _offset as float) as void
    m.width = 32
    m.height = 32
    m.active = false
    m.visible = false
    m.globalVars = _globalVars
    m.offsetX = _offset
    m.FORCE_X = 0.02
    m.FORCE_Y = 0.02
    m.FORCE_DISTANCE = (_globalVars.GAME_FIELD_MAX_Y - _globalVars.GAME_FIELD_MIN_Y) * 0.5
    if (_offset > 0 ) 
        m.currentAnimationName = "idle"
    else 
        m.currentAnimationName = "idle2"
    end if
end function

function MagnetObjUpdate(_deltatime as float, _hero as object) as void
    if (m.active = false) return
    m.x = _hero.x - (_hero.width + m.width) * m.offsetX
    m.y = _hero.y

    for each spriteObjName in m.spriteObjArray
        m.spriteObjArray[spriteObjName].Update(_deltatime, m.x, m.y)
    end for
end function

function SpeedIconObjInit(_globalVars as object) as void
    m.active = false
    m.visible = false
    m.globalVars = _globalVars
end function

function SpeedIconObjUpdate(_deltatime as float, _hero as object) as void
    if (m.active = false) return
    m.x = _hero.x
    m.y = _hero.y

    for each spriteObjName in m.spriteObjArray
        m.spriteObjArray[spriteObjName].Update(_deltatime, m.x, m.y)
    end for
end function

function menuCursorObjInit(_globalVars as object) as void
    m.globalVars = _globalVars
    m.JUMP_TIME = m.globalVars.PI
    m.jumpTimer = m.JUMP_TIME
    m.JumpSpeedX = 5
    m.offsetAmplitudeX = 40
    m.offsetSpeedX = 0.4
    m.offsetSpeedY = 0.25
    m.lastMenuState = m.globalVars.menuState
end function

function menuCursorObjUpdate(_deltatime as float) as void
    if (m.active = false) return
    m.AnimationUpdate(_deltatime)
    
    if (m.lastMenuState <> m.globalVars.menuState)
        m.jumpTimer = Abs(m.jumpTimer - m.JUMP_TIME / 2) + m.JUMP_TIME / 2 
        m.lastMenuState = m.globalVars.menuState
    end if
    m.jumpTimer -= _deltatime * m.JumpSpeedX
    if (m.jumpTimer < 0 ) m.jumpTimer += m.JUMP_TIME
    offsetX = -Abs(Sin(m.jumpTimer)) * m.offsetAmplitudeX 
    m.y += (m.globalVars.GAME_STATE_MENU_Y[m.globalVars.menuState] - m.y) * m.offsetSpeedY 
    m.x += (m.globalVars.GAME_STATE_MENU_X[m.globalVars.menuState] - m.x) * m.offsetSpeedX
    m.drawX = m.x + (-m.localOffsetX - 0.5) * m.currentRegion.GetWidth() * m.scaleX + offsetX
    m.drawY = m.y + (-m.localOffsetY - 0.5) * m.currentRegion.GetHeight() * m.scaleY
end function

' bricks project functions _________________________________________________________________________________________________________________
' _________________________________________________________________________________________________________________
function CreateLevel(_globalVars as object, _levelPath as string, _gameObjectDataSet as object) as object
    obj = {
        active  : true
        globalVars	: _globalVars
        levelData : invalid
        gameObjectDataSet : _gameObjectDataSet
        
        Draw    : SimpleLevelDraw
        Update  : SimpleLevelUpdate
        CheckCollision : LevelCheckCollision
        CheckBlockCollision : CheckBlockCollision
        LevelBlocksDraw : LevelBlocksDraw
        LevelBlockDraw : LevelBlockDraw
    }
    
    obj.testLevelASCII = ReadAsciiFile(_levelPath)
	obj.levelData = ParseTextLevel(obj.testLevelASCII, obj.globalVars)
	
	obj.brickObj = CreateVisObj("brick", obj.globalVars.screen, 0, 0, obj.gameObjectDataSet, "brickTest")
    
    return obj
end function

function SimpleLevelUpdate () as void
	if (m.active = false) return
end function

function SimpleLevelDraw () as void
	if (m.active = false) return
	
	for i=0 to m.globalVars.MAX_LEVEL_LINES-1
		for j=0 to m.globalVars.MAX_LEVEL_COLUMNS-1
			c = m.levelData[i][j]
			if (c <> " ")										
				m.brickObj.x = m.globalVars.GAME_FIELD_MIN_X + j * m.globalVars.BRICK_WIDTH + m.globalVars.BRICK_WIDTH * 0.5
				m.brickObj.y = m.globalVars.GAME_FIELD_MIN_Y + i * m.globalVars.BRICK_HEIGHT + m.globalVars.BRICK_HEIGHT * 0.5 - 0.5
				m.brickObj.currentAnimationName = "brick" + m.levelData[i,j] 
				m.brickObj.Update(0)
				m.brickObj.Draw()
			end if
		end for
	end for
end function

function LevelBlocksDraw(_blockCellCoordList as object) as void
	for each blockCellCoord in _blockCellCoordList
		m.brickObj.x = m.globalVars.GAME_FIELD_MIN_X + blockCellCoord.j * m.globalVars.BRICK_WIDTH + m.globalVars.BRICK_WIDTH * 0.5
		m.brickObj.y = m.globalVars.GAME_FIELD_MIN_Y + blockCellCoord.i * m.globalVars.BRICK_HEIGHT + m.globalVars.BRICK_HEIGHT * 0.5 - 0.5
		
		m.brickObj.currentAnimationName = "brick8" 
		m.brickObj.Update(0)
		m.brickObj.Draw()
	end for
end function

function LevelBlockDraw(_blockCellCoord as object) as void
	m.brickObj.x = m.globalVars.GAME_FIELD_MIN_X + _blockCellCoord.j * m.globalVars.BRICK_WIDTH + m.globalVars.BRICK_WIDTH * 0.5
	m.brickObj.y = m.globalVars.GAME_FIELD_MIN_Y + _blockCellCoord.i * m.globalVars.BRICK_HEIGHT + m.globalVars.BRICK_HEIGHT * 0.5 - 0.5
		
	m.brickObj.currentAnimationName = "brick8" 
	m.brickObj.Update(0)
	m.brickObj.Draw()
end function

function LevelCheckCollision (_collisionData as object) as object
	'determining a list of cells which might be collided with a ball's AABB
	_collisionData.isCollided = false
	
	leftTestedBlock = (_collisionData.position.x - _collisionData.radius - m.globalVars.GAME_FIELD_MIN_X) \ m.globalVars.BRICK_WIDTH
	if (leftTestedBlock < 0 ) leftTestedBlock = 0
	rightTestedBlock = (_collisionData.position.x + _collisionData.radius - m.globalVars.GAME_FIELD_MIN_X) \ m.globalVars.BRICK_WIDTH
	if (rightTestedBlock > m.globalVars.MAX_LEVEL_COLUMNS-1 ) rightTestedBlock = m.globalVars.MAX_LEVEL_COLUMNS-1
	
	upperTestedBlock = (_collisionData.position.y - _collisionData.radius - m.globalVars.GAME_FIELD_MIN_Y) \ m.globalVars.BRICK_HEIGHT
	if (upperTestedBlock < 0 ) upperTestedBlock = 0
	lowerTestedBlock = (_collisionData.position.y + _collisionData.radius - m.globalVars.GAME_FIELD_MIN_Y) \ m.globalVars.BRICK_HEIGHT
	if (lowerTestedBlock > m.globalVars.MAX_LEVEL_LINES-1 ) lowerTestedBlock = m.globalVars.MAX_LEVEL_LINES-1

	testedBlockList = []
	for i=upperTestedBlock to lowerTestedBlock
		for j=leftTestedBlock to rightTestedBlock
			c = m.levelData[i][j]
			if (c <> " ")
				blockCoord = {
					i: i, 
					j: j}
				testedBlockList.Push(blockCoord)				
			end if
		end for
	end for

	if (testedBlockList.Count() = 0)
		return _collisionData
	end if

	'm.LevelBlocksDraw(testedBlockList)
	
	'calculate reflection speed if a ball collides. 
	blockCollisionResult = invalid
	for each testedBlock in testedBlockList
		_collisionData.testedBlock = testedBlock
		blockCollisionResult = m.CheckBlockCollision(_collisionData)
		if (blockCollisionResult.isCollided = true)
			m.levelData[testedBlock.i][testedBlock.j] = " "
			m.LevelBlockDraw(testedBlock)
			exit for
		end if
	end for
	
	return blockCollisionResult
end function

function CheckBlockCollision(_collisionData as object) as object
	blockX = m.globalVars.GAME_FIELD_MIN_X + _collisionData.testedBlock.j * m.globalVars.BRICK_WIDTH  + m.globalVars.BRICK_WIDTH * 0.5
	blockY = m.globalVars.GAME_FIELD_MIN_Y + _collisionData.testedBlock.i * m.globalVars.BRICK_HEIGHT + m.globalVars.BRICK_HEIGHT * 0.5

	blockLeftSideX = blockX - m.globalVars.BRICK_WIDTH * 0.5
	blockRightSideX = blockX + m.globalVars.BRICK_WIDTH * 0.5
	
	blockLeftSideY = blockY - m.globalVars.BRICK_HEIGHT * 0.5
	blockRightSideY = blockY + m.globalVars.BRICK_HEIGHT * 0.5

	'finding a box point closest to the circle' center
	nearestX = MaxF(blockLeftSideX, MinF(_collisionData.position.x, blockRightSideX))
	nearestY = MaxF(blockLeftSideY, MinF(_collisionData.position.y, blockRightSideY))

	boxBallPosDeltaX = _collisionData.position.x - nearestX
	boxBallPosDeltaY = _collisionData.position.y - nearestY
	
	boxBallPosDeltaDistanceInPow = boxBallPosDeltaX * boxBallPosDeltaX + boxBallPosDeltaY * boxBallPosDeltaY 
	  
	_collisionData.isCollided = boxBallPosDeltaDistanceInPow < (_collisionData.radius * _collisionData.radius)
	if (_collisionData.isCollided = false)
		return _collisionData
	end if

	boxNormal = {
		x : boxBallPosDeltaX
		y : boxBallPosDeltaY
	}

	boxBallPosDeltaLength = Sqr(boxBallPosDeltaDistanceInPow)

	boxNormal = NormalizeVector(boxNormal)
	reflectedBallSpeed = ReflectVector(_collisionData.speed, boxNormal)

	_collisionData.speed = reflectedBallSpeed

	hitPos = {
		x : 0.0
		y : 0.0
	}
	hitPos.x = _collisionData.position.x + boxNormal.x * (_collisionData.radius - boxBallPosDeltaLength)
	hitPos.y = _collisionData.position.y + boxNormal.y * (_collisionData.radius - boxBallPosDeltaLength)
	_collisionData.position = hitPos

	_collisionData.isCollided = true
	
	return _collisionData
end function

function ParseTextLevel(_levelASCII as string, _globalVars as object) as object
	levelData = []
	for i=1 to _globalVars.MAX_LEVEL_LINES
		levelLineData = []
		for j=1 to _globalVars.MAX_LEVEL_COLUMNS	
			levelLineData.Push(" ")
		end for
		levelData.Push(levelLineData)
	end for
	
	levelASCIILength = Len(_levelASCII)
	charPos = 1
	brickLine = 0
	brickColumn = 0
	while charPos <= levelASCIILength
		brickAnimChar = Mid(_levelASCII, charPos, 1)			
		if (brickAnimChar = Chr(13) )
			brickColumn = 0
			brickLine += 1
			Goto LEVEL_PARSING_NEXT_CHAR
		end if
		if (brickAnimChar = " " )
			brickColumn += 1 
			Goto LEVEL_PARSING_NEXT_CHAR
		end if
					
		if (Asc(brickAnimChar) < Asc("1") OR Asc(brickAnimChar) > Asc("9"))
			Goto LEVEL_PARSING_NEXT_CHAR
		end if
		if (brickColumn > _globalVars.MAX_LEVEL_COLUMNS-1)  
			Goto LEVEL_PARSING_NEXT_CHAR
		end if
		if (brickLine > _globalVars.MAX_LEVEL_LINES-1)  
			Exit While
		end if
		
		levelData[brickLine][brickColumn] = brickAnimChar
		brickColumn += 1
					
LEVEL_PARSING_NEXT_CHAR:
		charPos += 1
	end while
	return levelData
end function

function CreatePlayer(_globalVars as object, _gameObjectsDataSet as object) as object
    obj = {
        active  : true
        globalVars	: _globalVars
        gameObjectsDataSet : _gameObjectsDataSet
        position			: {x: 0, y: 0}
        speed				: {x: 0, y: 0}
        visObj 				: invalid
        startSpeed 			: _globalVars.PLAYER_START_SPEED
        playerWidthCode		: 0
        playerWidth 		: invalid
        playerHeight 		: _globalVars.PLAYER_HEIGHT
        spawnPointOffset	: {x: 0, y: -10.0}
        playerCollisionInnerBoxHalfWidth : 0.0
        rightSlopOffset			: invalid
        leftSlopOffset			: invalid
        
        Draw    : SimplePlayerDraw
        Update  : SimplePlayerUpdate
        Move	: SimplePlayerMove
        SpawnPos	: GetPlayerSpawnPos
        CheckCollision	: CheckPlayerCollision
    }
    
    obj.playerWidth = _globalVars.PLAYER_WIDTHS[obj.playerWidthCode]
    obj.playerCollisionInnerBoxHalfWidth = obj.playerWidth * 0.5 - _globalVars.PLAYER_COLLISION_SLOPE_WIDTH
    obj.leftSlopOffset = _globalVars.PLAYER_COLLISION_SLOPE_OFFSET[obj.playerWidthCode]
    obj.rightSlopOffset = _globalVars.PLAYER_COLLISION_SLOPE_OFFSET[obj.playerWidthCode]
    obj.rightSlopOffset.x = -1.0 * obj.rightSlopOffset.x
    
    obj.position.x = obj.globalVars.GAME_FIELD_MIN_X + obj.globalVars.GAME_FIELD_WIDTH * 0.5 
    obj.position.y = _globalVars.PLAYER_POS_Y
	obj.visObj = CreateVisObj("platform", obj.globalVars.screen, obj.position.x, obj.position.y, obj.gameObjectsDataSet, "platformSmall")
    
    return obj
end function

function SimplePlayerUpdate(_deltaTime=0 as float) as void
	if (m.active = false) return
	
	m.position.x += m.speed.x
	m.position.y += m.speed.y
	
	if (m.position.x > m.globalVars.GAME_FIELD_MAX_X - m.playerWidth * 0.5)
		m.position.x = m.globalVars.GAME_FIELD_MAX_X - m.playerWidth * 0.5
	end if

	if (m.position.x < m.globalVars.GAME_FIELD_MIN_X + m.playerWidth * 0.5)
		m.position.x = m.globalVars.GAME_FIELD_MIN_X + m.playerWidth * 0.5 
	end if
		
	m.visObj.x = m.position.x
	m.visObj.y = m.position.y
	m.visObj.Update(_deltaTime)
end function

function SimplePlayerDraw () as void
	if (m.active = false) return
	
	m.visObj.Draw()
end function

function SimplePlayerMove(_playerMoveCode as Integer) as void
	if (_playerMoveCode = m.globalVars.PLAYER_MOVE_CODE_RIGHT)
		m.speed.x = m.startSpeed
	end if
		if (_playerMoveCode = m.globalVars.PLAYER_MOVE_CODE_LEFT)
		m.speed.x = -m.startSpeed
	end if
end function

function GetPlayerSpawnPos() as object
	obj = {
		x : m.position.x + m.spawnPointOffset.x 
		y : m.position.y + m.spawnPointOffset.y
	}
	return obj
end function

function CheckPlayerCollision(_collisionData as object) as object
	'player's shape consists of an inner box and two ellipses
	_collisionData.isCollided = false
	playerTop = m.position.y - m.playerHeight * 0.5
	playerLeft = m.position.x - m.playerWidth * 0.5
	playerRight = m.position.x + m.playerWidth * 0.5
	'inner box 
	playerBoxLeft = m.position.x - m.playerCollisionInnerBoxHalfWidth
	playerBoxRight = m.position.x + m.playerCollisionInnerBoxHalfWidth
	
	'check aabb collision
	if (_collisionData.position.y + _collisionData.radius < playerTop) return _collisionData
	if (_collisionData.position.x - _collisionData.radius < playerLeft) return _collisionData
	if (_collisionData.position.x + _collisionData.radius > playerRight) return _collisionData
	if (_collisionData.position.y - _collisionData.radius > playerTop) return _collisionData
	'check inner box
	if (_collisionData.position.x - _collisionData.radius > playerBoxLeft AND _collisionData.position.x + _collisionData.radius < playerBoxRight)
		_collisionData.speed.y = -1.0 * Abs(_collisionData.speed.y)
		_collisionData.position.y = m.position.y - m.playerHeight * 0.5 - _collisionData.radius
		_collisionData.isCollided = true
		return _collisionData
	end if
	'check slopes
	leftSlopePos = {x: 0.0, y:0.0}
	leftSlopePos.x = m.leftSlopOffset.x + m.position.x
	leftSlopePos.y = m.leftSlopOffset.y + m.position.y
	ballSlopeCenterDistance = Distance(_collisionData.position, leftSlopePos)
	ballPosInSlopeSpace = {x: 0.0, y:0.0}
	ballPosInSlopeSpace.x = _collisionData.position.x - m.position.x
	ballPosInSlopeSpace.y = Abs(_collisionData.position.y - m.position.y)
	slopeCos = ballPosInSlopeSpace.x / ballSlopeCenterDistance
	slopeSin = ballPosInSlopeSpace.y / ballSlopeCenterDistance
	slopeNearToBallPos = {x: 0.0, y:0.0}
	slopeNearToBallPos.x = slopeCos * m.globalVars.PLAYER_COLLISION_SLOPE_RADIUS.x
	slopeNearToBallPos.y = slopeSin * m.globalVars.PLAYER_COLLISION_SLOPE_RADIUS.y
	slopeRadius = VectorLength(slopeNearToBallPos)
	if (ballSlopeCenterDistance > slopeRadius + _collisionData.radius) 
		return _collisionData
	end if
	
	slopNormal = {x:0.0, y:0.0}
	slopNormal.x = ballPosInSlopeSpace.x
	slopNormal.y = -1.0 * ballPosInSlopeSpace.x
	
	slopNormal = NormalizeVector(slopNormal)
	reflectedBallSpeed = ReflectVector(_collisionData.speed, slopNormal)

	_collisionData.speed = reflectedBallSpeed
	
	_collisionData.isCollided = true
	
	return _collisionData
end function

function CreateBall(_globalVars as object, _gameObjectsDataSet as object, _level as object, _player as object, _pos as object) as object
    obj = {
        active  : true
        globalVars	: _globalVars
        gameObjectsDataSet : _gameObjectsDataSet
        position	: _pos
        speed		: {x: 0, y: 0}
        visObj : invalid
        startSpeed : _globalVars.BALL_START_SPEED
        ballRadiusCode	: 0
        ballRadius : invalid
        collisionTrackingAccuracy : 1.0 'in pixels
        level	: _level
        player	: _player
        
        Draw    : SimpleBallDraw
        Update  : SimpleBallUpdate
    }
    
    obj.ballRadius = _globalVars.BALL_RADIUSES[obj.ballRadiusCode]
    
    obj.speed.x = obj.startSpeed
    obj.speed.y = -obj.startSpeed
    
	obj.visObj = CreateVisObj("ball", obj.globalVars.screen, obj.position.x, obj.position.y, obj.gameObjectsDataSet, "idle")
    
    return obj
end function

function SimpleBallUpdate (_deltaTime=0 as float) as void
	if (m.active = false) return
	'blocks collision
	pathLength = VectorLength(m.speed)
	collisionTrackingIterations = pathLength \ m.collisionTrackingAccuracy + 1
	
	iterationSpeed = {
		x: m.speed.x / collisionTrackingIterations
		y: m.speed.y / collisionTrackingIterations
	}
	
	collisionData = {
		position : m.position
		speed : iterationSpeed
		radius : m.ballRadius
		isCollided	: false
	}
	
	for i=0 to collisionTrackingIterations-1
		collisionData.position.x += collisionData.speed.x
		collisionData.position.y += collisionData.speed.y
		collisionData = m.level.CheckCollision(collisionData)
		collisionData = m.player.CheckCollision(collisionData)
	end for
	
	m.position = collisionData.position
	m.speed.x = collisionData.speed.x * collisionTrackingIterations
	m.speed.y = collisionData.speed.y * collisionTrackingIterations
	
	'border collision
	if ((m.position.x > m.globalVars.GAME_FIELD_MAX_X - m.ballRadius) OR (m.position.x < m.globalVars.GAME_FIELD_MIN_X + m.ballRadius)) 
		m.position.x -= m.speed.x
		m.speed.x *= -1.0
	end if
	
	if ((m.position.y > m.globalVars.screenHeight - m.ballRadius) OR (m.position.y < m.globalVars.GAME_FIELD_MIN_Y + m.ballRadius))
		m.position.y -= m.speed.y
		m.speed.y *= -1.0
	end if
		
	m.visObj.x = m.position.x
	m.visObj.y = m.position.y
	m.visObj.Update(_deltaTime)
end function

function SimpleBallDraw () as void
	if (m.active = false) return
	
	m.visObj.Draw()
end function