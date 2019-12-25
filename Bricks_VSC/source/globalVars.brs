function GlobalVars() as object
	obj = {
' ------- NEW -----------------------------------
        MAX_DELTATIME   : 16.665 / 1000.0
        PI					: 3.14159265359
        
        MAX_LEVEL_COLUMNS	: 13
        MAX_LEVEL_LINES		: 17
        
        
        ENERGY_ITEM_RADIUS		: 20.0
        ENERGY_ITEM_START_SPEED	: 1.0
        ENERGY_ITEMS_MAX_AMOUNT	: 15
        ENERGY_ITEMS_ENERGY		: 0.01
		ENERGY_ITEM_SPRITE_FILENAME	: "pkg:/assets/gameObjects/energyItem.json"
		MAX_ENERGY			: 1.0
        
        screen              : CreateObject("roScreen", true)
        screenWidth			: invalid
		screenHeight		: invalid

        port                : CreateObject("roMessagePort")
        codes               : bslUniversalControlEventCodes() 'key codes from bslUniversalControlEventCodes()

        gameObjectInterfaces: {} ' there is a AArray of empty gameobjects which will be loaded to every level. They are used to override logic of sprites which loaded by loadLevel function.
        RegisterUniqueGameObject : GlobalVarsRegisterUniqueGameObject
    }
'    obj.menuState = obj.GAME_STATE_MENU_L1
	
'	obj.GAME_FIELD_WIDTH	= obj.BRICK_WIDTH * obj.MAX_LEVEL_COLUMNS
'	obj.GAME_FIELD_HEIGHT	= obj.BRICK_HEIGHT * obj.MAX_LEVEL_LINES
        
'	obj.GAME_FIELD_MIN_X	= 63
'	obj.GAME_FIELD_MAX_X	= obj.GAME_FIELD_MIN_X + obj.GAME_FIELD_WIDTH
'	obj.GAME_FIELD_MIN_Y	= 34
'	obj.GAME_FIELD_MAX_Y	= obj.GAME_FIELD_MIN_Y + obj.GAME_FIELD_HEIGHT

	obj.screen.SetMessagePort(obj.port)
	obj.screen.SetAlphaEnable(true)
    obj.screenWidth = obj.screen.GetWidth()
    obj.screenHeight = obj.screen.GetHeight()

' registration gameobjects. level needs to have all unique empty gameobjects to be added to that array
    obj.RegisterUniqueGameObject(CreateSprite(obj))
    obj.RegisterUniqueGameObject(CreateStaticSprite(obj))

    obj.RegisterUniqueGameObject(CreatePlayer(obj))
    obj.RegisterUniqueGameObject(CreateBall(obj))
    obj.RegisterUniqueGameObject(CreateStaticCollisionBox(obj))
    obj.RegisterUniqueGameObject(CreatePlayerDebugAABB(obj))
    obj.RegisterUniqueGameObject(CreateBricks(obj))
    obj.RegisterUniqueGameObject(CreateFpsCounter(obj))
    return obj
end function

function GlobalVarsRegisterUniqueGameObject(_gameObject)
    m.gameObjectInterfaces.AddReplace(_gameObject.type, _gameObject)
end function