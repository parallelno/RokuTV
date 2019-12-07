Library "v30/bslDefender.brs"

function Main() as void
    'mainMenuBackDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/mainMenu.xml"))
    gameLevelDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/gameLevel.xml"))
    gameObjectsDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/gameObjects.xml"))
    gameUIDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/gameUI.xml"))
    gameBallDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/ballAnim.xml"))
    gameFXDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/gameFX_Explosion2.xml"))
    
    
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
        BALL_START_SPEED	: 5.0
        BALL_RADIUSES		: [10.0, 20.0, 40.0]
        
        MAX_LEVEL_COLUMNS	: 13
        MAX_LEVEL_LINES		: 17
        
        PLAYER_MOVE_CODE_RIGHT	: 1
        PLAYER_MOVE_CODE_LEFT	: 2
        
        PLAYER_START_SPEED		: 10.0
        
        PLAYER_WIDTHS		: [116.0, 147.0, 225.0]
        PLAYER_HEIGHT		: 28.0
        
        PLAYER_COLLISION_INNER_BOX_HALF_WIDTHS : [39.0, 57.0, 95.0]
        
        PLAYER_POS_Y		: 670.0
        
        ENERGY_ITEM_RADIUS		: 20.0
        ENERGY_ITEM_START_SPEED	: 1.0
        ENERGY_ITEMS_MAX_AMOUNT	: 15
        ENERGY_ITEMS_ENERGY		: 0.01
        screenWidth			: screenWidth
        screenHeight		: screenHeight
        
        ENERGY_ITEM_DATASET	: gameObjectsDataSet
        ENERGY_ITEM_ANIMATION	: "energyItem"

        MAX_ENERGY			: 1.0
        
        ENERGY_BAR_POSITION	: {x: 974.0, y: 518.0}
        
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

    'mainMenuBackObj = CreateSpriteObj(mainMenuBackDataSet.regions.mainMenu_Back, screen, 0, 0, -0.5, -0.5, 1.0, 1.0)
    'mainMenu_GameTitleObj = CreateSpriteObj(mainMenuBackDataSet.regions.mainMenu_GameTitle, screen, screenWidth/2, screenHeight * 0.4, 0, 0, 1.0, 1.0)
	'mainMenu_OptionsObj = CreateSpriteObj(mainMenuBackDataSet.regions.mainMenu_Options, screen, screenWidth/2, screenHeight * 0.75, 0, 0, 1.0, 1.0)
	
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
	gameUI_TextBoosterObj = CreateSpriteObj(gameUIDataSet.regions.gameUI_TextBooster, screen, 1020, 573, -0.5, -0.5, 1.0, 1.0)
	gameUI_TextBoosterObj.Update()
	gameUI_TextBoosterXObj = CreateSpriteObj(gameUIDataSet.regions.gameUI_TextBoosterX, screen, 1072, 632, -0.5, -0.5, 1.0, 1.0)
	gameUI_TextBoosterXObj.Update()
	
	'old
	'gameUI_BottomLineObj = CreateSpriteObj(gameUIDataSet.regions.gameUI_BottomLine, screen, 41, 678, -0.5, 0, 875.0, 1.0)
	'gameUI_BottomLineObj.Update()
	'new	
	gameUI_BottomLineObj = CreateSprite([gameUIDataSet.regions.gameUI_BottomLine], screen, {x: 41, y: 678}, {x: -0.5, y: 0.0}, {x: 875.0, y: 1.0})

' DEBUG LINE AROUND GAME FIELD------------------------------------------------------------------------------------------
	gameLevel_DebugWhiteFieldObj = CreateSpriteObj(gameLevelDataSet.regions.whitePixel, screen, GAME_VARS.GAME_FIELD_MIN_X, GAME_VARS.GAME_FIELD_MIN_Y, -0.5, -0.5, GAME_VARS.GAME_FIELD_WIDTH, screenHeight - GAME_VARS.GAME_FIELD_MIN_Y)
	gameLevel_DebugWhiteFieldObj.Update()
' ------------------------------------------------------------------------------------------

	
	player = CreatePlayer(GAME_VARS, gameObjectsDataSet)
	firstLevel = CreateLevel(GAME_VARS, "pkg:/assets/testLevel.txt", gameObjectsDataSet, player)
	ball = CreateBall(GAME_VARS, gameBallDataSet, firstLevel, player, player.SpawnPos())
	
	gameUI_EnergyBar = CreateEnergyBar(GAME_VARS, gameUIDataSet.regions.gameUI_EnergyBar)
	gameUI_EnergyBar.Setup(firstLevel)
	gameUI_EnergyBar.Update()
	
	explosion = CreateSprite(gameFXDataSet.animations["explosion"], screen, {x: 300, y: 300})
	explosion.animationSpeed = 2.0
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
								
				gameUI_PlatformObj.Draw()
				gameUI_TextBoosterObj.Draw()
				gameUI_TextBoosterXObj.Draw()
				gameUI_TextEnergyObj.Draw()
				gameUI_TextHiscoreObj.Draw()
				gameUI_TextLevelObj.Draw()
				gameUI_TextScoreObj.Draw()
				
				if (lastID = 7) gameLevel_DebugWhiteFieldObj.Draw()
				' end line for uninteractive back and UI elements
				gameUI_EnergyBar.Update()
				gameUI_EnergyBar.Draw()
				
				
				firstLevel.Update(deltaTime)
				firstLevel.Draw()
				
				player.Update(deltaTime)
				player.Draw()
				
				ball.Update(deltaTime)
				ball.Draw()
				
				'effects
				explosion.Update(deltaTime)
				explosion.Draw()
				
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


'/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////`
' bricks project functions _________________________________________________________________________________________________________________
' _________________________________________________________________________________________________________________
function CreateLevel(_globalVars as object, _levelPath as string, _gameObjectDataSet as object, _player as object) as object
    obj = {
        active  : true
        globalVars	: _globalVars
        levelData : invalid
        gameObjectDataSet : _gameObjectDataSet
        egergyItems : CreateObject("roList")
		energy		: 0.0
		player		: _player
        
        Draw    : LevelDraw
        Update  : LevelUpdate
        CheckCollision 		: LevelCheckCollision
        CheckBlockCollision : CheckBlockCollision
        LevelBlocksDraw 	: LevelBlocksDraw
        LevelBlockDraw 		: LevelBlockDraw
        SpawnEnergyItem 	: SpawnEnergyItem
        GetLevelBlockPos	: GetLevelBlockPos
        AddEnergy			: LevelAddEnergy
    }
    
    obj.energyItems = CreateObject("roList")
    obj.testLevelASCII = ReadAsciiFile(_levelPath)
	obj.levelData = ParseTextLevel(obj.testLevelASCII, obj.globalVars)
	
	obj.brickObj = CreateVisObj("brick", obj.globalVars.screen, 0, 0, obj.gameObjectDataSet, "brickTest")
    return obj
end function

function LevelAddEnergy()
	m.energy += m.globalVars.ENERGY_ITEMS_ENERGY
	m.energy = MinF(m.energy, m.globalVars.MAX_ENERGY)
end function

function LevelUpdate(_deltatime as float) as void
	if (m.active = false) return
	
	for each energyItem in m.egergyItems
		energyItem.Update(_deltaTime)
	end for	
end function

function LevelDraw() as void
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
	
	for each energyItem in m.egergyItems
		energyItem.Draw()
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

function GetLevelBlockPos(_blockCellCoord as object) as object
	res = {x : 0.0, y : 0.0}
	res.x = m.globalVars.GAME_FIELD_MIN_X + _blockCellCoord.j * m.globalVars.BRICK_WIDTH + m.globalVars.BRICK_WIDTH * 0.5
	res.y = m.globalVars.GAME_FIELD_MIN_Y + _blockCellCoord.i * m.globalVars.BRICK_HEIGHT + m.globalVars.BRICK_HEIGHT * 0.5 - 0.5
	
	return res
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
			if (m.levelData[testedBlock.i][testedBlock.j] = "1")
				energyItemPos = m.GetLevelBlockPos(testedBlock)
				m.SpawnEnergyItem(energyItemPos)
				m.levelData[testedBlock.i][testedBlock.j] = " "	
				m.LevelBlockDraw(testedBlock)
			end if
			exit for
		end if
	end for
	
	return blockCollisionResult
end function

function SpawnEnergyItem(_position as object) as void
	allIsActive = true
	for each energyItem in m.egergyItems
		if (energyItem.active = false)
			allIsActive = false
			energyItem.Setup(_position)
			return
		end if 
	end for

	if (allIsActive = true AND m.egergyItems.Count() < m.globalVars.ENERGY_ITEMS_MAX_AMOUNT)
		m.egergyItems.AddTail(CreateEnergyItem(m.globalVars, m.player, m, _position))
	end if
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
        position			: {x: 0.0, y: 0.0}
        speed				: {x: 0.0, y: 0.0}
        visObj 				: invalid
        startSpeed 			: _globalVars.PLAYER_START_SPEED
        playerWidthCode		: 0
        playerWidth 		: invalid
        playerHeight 		: _globalVars.PLAYER_HEIGHT
        spawnPointOffset	: {x: 0.0, y: -30.0}
        playerCollisionInnerBoxHalfWidth : 0.0
                
        Draw    : SimplePlayerDraw
        Update  : SimplePlayerUpdate
        Move	: SimplePlayerMove
        SpawnPos	: GetPlayerSpawnPos
        CheckCollision	: CheckPlayerCollision
    }
    
    obj.playerWidth = _globalVars.PLAYER_WIDTHS[obj.playerWidthCode]
    obj.playerCollisionInnerBoxHalfWidth = _globalVars.PLAYER_COLLISION_INNER_BOX_HALF_WIDTHS[obj.playerWidthCode] 
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
	playerDown = m.position.y + m.playerHeight * 0.5
	'inner box 
	playerBoxLeft = m.position.x - m.playerCollisionInnerBoxHalfWidth
	playerBoxRight = m.position.x + m.playerCollisionInnerBoxHalfWidth
	
	'check aabb collision
	if (_collisionData.position.y + _collisionData.radius < playerTop) return _collisionData
	if (_collisionData.position.x - _collisionData.radius < playerLeft) return _collisionData
	if (_collisionData.position.x + _collisionData.radius > playerRight) return _collisionData
	if (_collisionData.position.y - _collisionData.radius > playerDown) return _collisionData

	'check inner box
	if (_collisionData.position.x > playerBoxLeft AND _collisionData.position.x < playerBoxRight)
		_collisionData.speed.y = -1.0 * Abs(_collisionData.speed.y)
		_collisionData.position.y = m.position.y - m.playerHeight * 0.5 - _collisionData.radius
		_collisionData.isCollided = true
		return _collisionData
	end if

	'check slopes
	if (_collisionData.speed.y < 0.0) return _collisionData
	ballSpeedLength = VectorLength(_collisionData.speed)
	ballSpeed = {
		x : 0.70710678118 * ballSpeedLength 
		y : -0.70710678118 * ballSpeedLength
	}
	if(_collisionData.position.x < m.position.x )
		ballSpeed.x *= -1.0
	end if
	
	_collisionData.speed = ballSpeed 
	_collisionData.isCollided = true
	
	return _collisionData
end function

function CreateBall(_globalVars as object, _gameObjectsDataSet as object, _level as object, _player as object, _pos as object) as object
    obj = {
        active  : true
        globalVars	: _globalVars
        gameObjectsDataSet : _gameObjectsDataSet
        position	: _pos
        speed		: {x: 0.0, y: 0.0}
        visObj : invalid
        startSpeed : _globalVars.BALL_START_SPEED
        ballRadiusCode	: 0
        ballRadius : invalid
        collisionTrackingAccuracy : 1.0 'in pixels
        level	: _level
        player	: _player
        
        Draw    : BallDraw
        Update  : BallUpdate
    }
    
    obj.ballRadius = _globalVars.BALL_RADIUSES[obj.ballRadiusCode]
    
    obj.speed.x = obj.startSpeed
    obj.speed.y = -obj.startSpeed
    
	obj.visObj = CreateVisObj("ball", obj.globalVars.screen, obj.position.x, obj.position.y, obj.gameObjectsDataSet, "idle")
    
    return obj
end function

function BallUpdate(_deltaTime=0 as float) as void
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

function BallDraw() as void
	if (m.active = false) return
	
	m.visObj.Draw()
end function

function CreateEnergyItem(_globalVars as object, _player as object, _level as object, _position as object) as object
    obj = {
        active  : true
        globalVars	: _globalVars
        position	: invalid
        speed		: {x: 0.0, y: 0.0}
        visObj : invalid
        startSpeed : _globalVars.ENERGY_ITEM_START_SPEED
        radius : _globalVars.ENERGY_ITEM_RADIUS
        player	: _player
        level	: _level
        
        Draw    : SimpleDraw
        Update  : EnergyItemUpdate
        Setup : SetupEnergyItem
    }

	obj.Setup(_position)
	    
	obj.visObj = CreateVisObj("energyItem", obj.globalVars.screen, obj.position.x, obj.position.y, _globalVars.ENERGY_ITEM_DATASET, "energyItem")
    
    return obj
end function

function SetupEnergyItem(_position as object)
    m.position = _position
    m.speed.x = 0.0
    m.speed.y = m.startSpeed
	m.active = true
end function

function SimpleDraw() as void
	if (m.active = false) return
	m.visObj.Draw()
end function

function EnergyItemUpdate(_deltaTime=0 as float) as void
	if (m.active = false) return
	'blocks collision
	m.position.x += m.speed.x
	m.position.y += m.speed.y
		
	collisionData = {
		position : m.position
		speed : m.speed
		radius : m.radius
		isCollided	: false
	}
	
	collisionData = m.player.CheckCollision(collisionData)
	if (collisionData.isCollided = true)
		m.active = false
		m.level.AddEnergy()
		return
	end if
	
	'border collision
	if (m.position.y - m.radius > m.globalVars.screenHeight)
		m.active = false
		return
	end if
		
	m.visObj.x = m.position.x
	m.visObj.y = m.position.y
	m.visObj.Update(_deltaTime)
end function

function CreateEnergyBar(_globalVars as object, _region as object) as object
    obj = {
        active  : true
        globalVars	: _globalVars
        position	: invalid
        sprite : invalid
        level	: invalid
        
        Draw    : ObjSpriteDraw
        Update  : EnergyBarUpdate
        Setup : SetupEnergyBar
    }

	obj.position = obj.globalVars.ENERGY_BAR_POSITION 
	    
	obj.sprite = CreateSpriteObj(_region, obj.globalVars.screen, obj.position.x, obj.position.y, -0.5, -0.5, 1.0, 1.0)
    return obj
end function

function SetupEnergyBar(_level as object)
	m.level = _level
end function

function EnergyBarUpdate(_deltaTime=0 as float) as void
	if (m.active = false) return
	'blocks collision
		
	m.sprite.x = m.position.x
	m.sprite.y = m.position.y
	m.sprite.scaleX = m.level.energy 
	m.sprite.Update(_deltaTime)
end function

function ObjSpriteDraw()
	m.sprite.Draw()
end function


