Library "v30/bslDefender.brs"

function Main() as void
' ------------------------------------------------------------------------------------------
' scoreRegSection = CreateObject("roRegistrySection", "ScoreTable")
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

	clock = CreateObject("roTimespan")
	GAME_VARS = GlobalVars()
	
	level = LoadLevel(GAME_VARS, "pkg:/assets/levels/level01.json")

' ------------------------------------------------------------------------------------------
	clock.Mark()

'MENU_LOOP:
	
'GAME_TEST_LOOP:
'   GAME_VARS.Sound_MainMenu_Intro.Trigger(65)
	while true
	   	deltaTime = clock.TotalMilliseconds() / 1000.0
		if (deltaTime > GAME_VARS.STABLE_FPS) 
'				gameUI_EnergyBar.Update()
'				gameUI_EnergyBar.Draw()
				
				
'				firstLevel.Update(deltaTime)
'				firstLevel.Draw()
				
'				player.Update(deltaTime)
'				player.Draw()
				
'				ball.Update(deltaTime)
'				ball.Draw()
				
			level.Update(deltaTime)
			level.Draw()
				
			GAME_VARS.screen.SwapBuffers()
			clock.Mark()
		endif
	end while
	
'EXIT_GAME:
	
end function