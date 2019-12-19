function CreatePlayer(_globalVars as object) as object
	obj = {
		active  : true
		globalVars	: _globalVars
		position	: {x: 0.0, y: 0.0}
		sprite : LoadSprite(_globalVars.screen, _globalVars.PLAYER_SPRITE_FILENAME)

		Draw    : PlayerDraw
		Update  : PlayerUpdate
	}
	obj.position.x = obj.globalVars.GAME_FIELD_MIN_X + obj.globalVars.GAME_FIELD_WIDTH * 0.5
	obj.position.y = obj.globalVars.PLAYER_POS_Y
	return obj
end function

function PlayerUpdate(_deltaTime=0 as float) as void
	if (m.active = false) return

	m.sprite.Update(_deltaTime, m.position)
end function

function PlayerDraw()
	m.sprite.Draw()
end function