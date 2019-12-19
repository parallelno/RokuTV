Library "v30/bslDefender.brs"

function Main() as void
	port = CreateObject("roMessagePort")
	scoreRegSection = CreateObject("roRegistrySection", "ScoreTable")
	screen = CreateObject("roScreen", true)
'	screenWidth = screen.GetWidth()
'	screenHeight= screen.GetHeight()
	screen.SetMessagePort(port)
	screen.SetAlphaEnable(true)
	clock = CreateObject("roTimespan")
	codes = bslUniversalControlEventCodes()
    
'    gameObjectsDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/gameObjects.xml"))
'    gameBallDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/ballAnim.xml"))
    
	GAME_VARS = GlobalVars(screen)

' ------------------------------------------------------------------------------------------
' Best score saved/created into registry 
'	if ( scoreRegSection.Exists("BestScore")) 
'		GAME_VARS.bestScore = scoreRegSection.Read("BestScore").ToInt()
'	else 
'		scoreRegSection.write("BestScore", GAME_VARS.bestScore.ToStr())
'		scoreRegSection.Flush()
'	end if
' ------------------------------------------------------------------------------------------

' --------- MUSIC ---------------------------------------------------------------------------------
'	audioPlayer = CreateObject("roAudioPlayer")
'	audioPlayer.SetMessagePort(port)
'	song = CreateObject("roAssociativeArray")
'	song.url = "pkg:/sounds/level01.mp3"
'	audioplayer.addcontent(song)
'	audioplayer.setloop(true)
'	audioPlayer.play()
' --------- SOUNDS ---------------------------------------------------------------------------------
'	GAME_VARS.Sound_MainMenu_Intro = CreateObject("roAudioResource", "pkg:/sounds/main_menu_intro.wav")
'	GAME_VARS.Sound_GameOver = CreateObject("roAudioResource", "pkg:/sounds/game_over.wav")
'	GAME_VARS.Sound_goal = CreateObject("roAudioResource", "pkg:/sounds/goal.wav")
'	GAME_VARS.Sound_gun_shoot = CreateObject("roAudioResource", "pkg:/sounds/gun_shoot.wav")
'	GAME_VARS.Sound_hit = CreateObject("roAudioResource", "pkg:/sounds/hit.wav")
'	GAME_VARS.Sound_magnet = CreateObject("roAudioResource", "pkg:/sounds/magnet.wav")
'	GAME_VARS.Sound_score = CreateObject("roAudioResource", "pkg:/sounds/score.wav")
'	GAME_VARS.Sound_slow = CreateObject("roAudioResource", "pkg:/sounds/slow.wav")
'	GAME_VARS.Sound_speed = CreateObject("roAudioResource", "pkg:/sounds/speed.wav")
'	GAME_VARS.Sound_wide = CreateObject("roAudioResource", "pkg:/sounds/wide.wav")
'	GAME_VARS.Sound_win = CreateObject("roAudioResource", "pkg:/sounds/win.wav")
'	GAME_VARS.Sound_shorten = CreateObject("roAudioResource", "pkg:/sounds/shorten.wav")
'	GAME_VARS.Sound_levelup = CreateObject("roAudioResource", "pkg:/sounds/levelup.wav")
'	GAME_VARS.Sound_new_round = CreateObject("roAudioResource", "pkg:/sounds/new_round.wav")
' ------------------------------------------------------------------------------------------	

' DEBUG LINE AROUND GAME FIELD------------------------------------------------------------------------------------------
'	gameLevel_DebugWhiteFieldObj = CreateSpriteObj(gameLevelDataSet.regions.whitePixel, screen, GAME_VARS.GAME_FIELD_MIN_X, GAME_VARS.GAME_FIELD_MIN_Y, -0.5, -0.5, GAME_VARS.GAME_FIELD_WIDTH, screenHeight - GAME_VARS.GAME_FIELD_MIN_Y)
'	gameLevel_DebugWhiteFieldObj.Update()
' ------------------------------------------------------------------------------------------

	
'	player = CreatePlayer(GAME_VARS, gameObjectsDataSet)
'	firstLevel = CreateLevel(GAME_VARS, "pkg:/assets/testLevel.txt", gameObjectsDataSet, player)
'	ball = CreateBall(GAME_VARS, gameBallDataSet, firstLevel, player, player.SpawnPos())
	
'	gameUI_EnergyBar = CreateEnergyBar(GAME_VARS)
'	gameUI_EnergyBar.Init(firstLevel)
'	gameUI_EnergyBar.Update()
' ------------------------------------------------------------------------------------------	
'// test
    
'	spriteTest = LoadSprite(screen, "pkg:/assets/testSprite.json")	
	staticSpriteTest = LoadStaticSprite(screen, "pkg:/assets/levelSkins/levelSkin01.json")
	staticSpriteLevelUI = LoadStaticSprite(screen, "pkg:/assets/ui/gameStaticUI.json")
'// end test

	collisionManager = CollisionManagerCreate()
	player = CreatePlayer(GAME_VARS)

' ------------------------------------------------------------------------------------------
    clock.Mark()

MENU_LOOP:
	
GAME_TEST_LOOP:
'    GAME_VARS.Sound_MainMenu_Intro.Trigger(65)
	lastID = 0
    while true
        event = port.GetMessage()
        if (type(event) = "roUniversalControlEvent")
            id = event.GetInt()
            if (id = codes.BUTTON_LEFT_PRESSED)
'                player.Move(GAME_VARS.PLAYER_MOVE_CODE_LEFT)
            endif
            if (id = codes.BUTTON_RIGHT_PRESSED)
'                player.Move(GAME_VARS.PLAYER_MOVE_CODE_RIGHT)
            endif
            if (id = 6)             
                'Goto GAME_INTRO_LOOP
            endif
            if (id = 0) Goto EXIT_GAME
            lastID = id
        else 
        	deltaTime = clock.TotalMilliseconds() / 1000.0
            if (deltaTime > GAME_VARS.STABLE_FPS) 
                ' uninteractive back and UI elements
' test				
				staticSpriteTest.Update(deltatime)
				staticSpriteTest.Draw()
				
				staticSpriteLevelUI.Draw()
' end test
				
'				if (lastID = 7) gameLevel_DebugWhiteFieldObj.Draw()
				' end line for uninteractive back and UI elements
'				gameUI_EnergyBar.Update()
'				gameUI_EnergyBar.Draw()
				
				
'				firstLevel.Update(deltaTime)
'				firstLevel.Draw()
				
'				player.Update(deltaTime)
'				player.Draw()
				
'				ball.Update(deltaTime)
'				ball.Draw()
				
' test
'				spriteTest.Update(deltaTime)
'				spriteTest.Draw()
' end test
				player.Update(deltatime)
'------------------------------------------------
' all dynamic object updates called already
				collisionManager.Update(deltatime) ' collision handlers of all collided objects will be called by this object's update
'------------------------------------------------
				player.Draw()
				
                screen.SwapBuffers()
                clock.Mark()
            endif
        endif
    end while
    
EXIT_GAME:
    
end function