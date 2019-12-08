function GlobalVars(_screen as object, _screenWidth as float, _screenHeight as float, _gameObjectsDataSet as object) as object
	obj = {
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
        screenWidth			: _screenWidth
        screenHeight		: _screenHeight
        
        ENERGY_ITEM_DATASET	: _gameObjectsDataSet
        ENERGY_ITEM_ANIMATION	: "energyItem"

        MAX_ENERGY			: 1.0
        
        ENERGY_BAR_POSITION	: {x: 974.0, y: 518.0}
        
    }
    obj.menuState = obj.GAME_STATE_MENU_L1
	
	obj.BRICK_WIDTH 		= 64
    obj.BRICK_HEIGHT 		= 25
        
	obj.GAME_FIELD_WIDTH	= obj.BRICK_WIDTH * obj.MAX_LEVEL_COLUMNS
	obj.GAME_FIELD_HEIGHT	= obj.BRICK_HEIGHT * obj.MAX_LEVEL_LINES
        
	obj.GAME_FIELD_MIN_X	= 63
	obj.GAME_FIELD_MAX_X	= obj.GAME_FIELD_MIN_X + obj.GAME_FIELD_WIDTH
	obj.GAME_FIELD_MIN_Y	= 34
	obj.GAME_FIELD_MAX_Y	= obj.GAME_FIELD_MIN_Y + obj.GAME_FIELD_HEIGHT
    obj.screen = _screen

    return obj
end function