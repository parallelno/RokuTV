function CreateEnergyItem(_globalVars as object, _sprite as object, _player as object, _level as object, _position as object) as object
    obj = {
        active  : true
        globalVars	: _globalVars
        position	: invalid
        speed		: {x: 0.0, y: 0.0}
        startSpeed : _globalVars.ENERGY_ITEM_START_SPEED
        radius : _globalVars.ENERGY_ITEM_RADIUS
        player	: _player
        level	: _level
        sprite	: _sprite
        
        Draw    : EnergyItemDraw
        Update  : EnergyItemUpdate
        Init : InitEnergyItem
    }

	obj.Init(_position)
    
    return obj
end function

function InitEnergyItem(_position as object) as void
    m.position = _position
    m.speed.x = 0.0
    m.speed.y = m.startSpeed
	m.active = true
end function

function EnergyItemDraw() as void
	if (m.active = false) return

	m.sprite.Update(0, m.position)
	m.sprite.Draw()
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
	m.sprite.Update(_deltaTime)
end function