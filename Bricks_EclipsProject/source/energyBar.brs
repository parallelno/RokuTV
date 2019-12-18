function CreateEnergyBar(_globalVars as object) as object
    obj = {
        active  : true
        globalVars	: _globalVars
        position	: invalid
        'sprite : invalid
        staticSprite : invalid
        level	: invalid
        
        Draw    : ObjSpriteDraw
        Update  : EnergyBarUpdate
        Init : InitEnergyBar
    }
	obj.staticSprite = LoadStaticSprite(obj.globalVars.screen, obj.globalVars.ENERGY_BAR_STATIC_SPRITE_FILENAME)
    return obj
end function

function InitEnergyBar(_level as object) as void
	m.level = _level
end function

function EnergyBarUpdate(_deltaTime=0 as float) as void
	if (m.active = false) return
		
	m.staticSprite.scale.x = m.level.energy 
	m.staticSprite.Update(_deltaTime)
end function

function ObjSpriteDraw()
	m.staticSprite.Draw()
end function