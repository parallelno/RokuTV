Library "v30/bslDefender.brs"

function Main() as void
	port = CreateObject("roMessagePort")
	scoreRegSection = CreateObject("roRegistrySection", "ScoreTable")
	screen = CreateObject("roScreen", true)
	screenWidth = screen.GetWidth()
	screenHeight= screen.GetHeight()
	screen.SetMessagePort(port)
	screen.SetAlphaEnable(true)
	clock = CreateObject("roTimespan")
	codes = bslUniversalControlEventCodes()
    
    gameObjectsDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/gameObjects.xml"))
    gameUIDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/gameUI.xml"))
    gameBallDataSet = dfNewBitmapSet(ReadAsciiFile("pkg:/assets/ballAnim.xml"))
    
	GAME_VARS = GlobalVars(screen, screenWidth, screenHeight, gameObjectsDataSet)

' ------------------------------------------------------------------------------------------
' Best score saved/created into registry 
    if ( scoreRegSection.Exists("BestScore")) 
        GAME_VARS.bestScore = scoreRegSection.Read("BestScore").ToInt()
    else 
        scoreRegSection.write("BestScore", GAME_VARS.bestScore.ToStr())
        scoreRegSection.Flush()
    end if
' ------------------------------------------------------------------------------------------

'// test
    
	spriteTest = LoadSprite(screen, "pkg:/assets/testSprite.json")	
'	spriteTest = CreateSprite(screen, spriteData)
	
	staticSpriteTest = LoadStaticSprite(screen, "pkg:/assets/levelSkins/levelSkin01.json")
	
	staticSpriteLevelUI = LoadStaticSprite(screen, "pkg:/assets/ui/gameUI.json")
'// end test


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

' DEBUG LINE AROUND GAME FIELD------------------------------------------------------------------------------------------
'	gameLevel_DebugWhiteFieldObj = CreateSpriteObj(gameLevelDataSet.regions.whitePixel, screen, GAME_VARS.GAME_FIELD_MIN_X, GAME_VARS.GAME_FIELD_MIN_Y, -0.5, -0.5, GAME_VARS.GAME_FIELD_WIDTH, screenHeight - GAME_VARS.GAME_FIELD_MIN_Y)
'	gameLevel_DebugWhiteFieldObj.Update()
' ------------------------------------------------------------------------------------------

	
	player = CreatePlayer(GAME_VARS, gameObjectsDataSet)
	firstLevel = CreateLevel(GAME_VARS, "pkg:/assets/testLevel.txt", gameObjectsDataSet, player)
	ball = CreateBall(GAME_VARS, gameBallDataSet, firstLevel, player, player.SpawnPos())
	
	gameUI_EnergyBar = CreateEnergyBar(GAME_VARS, gameUIDataSet.regions.gameUI_EnergyBar)
	gameUI_EnergyBar.Setup(firstLevel)
	gameUI_EnergyBar.Update()
' ------------------------------------------------------------------------------------------	
    clock.Mark()

MENU_LOOP:
	
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
' test				
				staticSpriteTest.Update(deltatime)
				staticSpriteTest.Draw()
				
				staticSpriteLevelUI.Draw()
' end test
				
'				if (lastID = 7) gameLevel_DebugWhiteFieldObj.Draw()
				' end line for uninteractive back and UI elements
				gameUI_EnergyBar.Update()
				gameUI_EnergyBar.Draw()
				
				
				firstLevel.Update(deltaTime)
				firstLevel.Draw()
				
				player.Update(deltaTime)
				player.Draw()
				
				ball.Update(deltaTime)
				ball.Draw()
				
' test
				spriteTest.Update(deltaTime)
				spriteTest.Draw()
' end test

                screen.SwapBuffers()
                clock.Mark()
            endif        
        endif
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

function SetupEnergyItem(_position as object) as void
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

function SetupEnergyBar(_level as object) as void
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


