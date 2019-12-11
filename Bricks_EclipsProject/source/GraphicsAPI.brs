' new API. Convert pairs of floats to roAssociativeArray 
function CreateStaticSprite(_screen as object, _staticSpriteData as object) as object
    obj = {
'		public
        visible		: true
        position		: {x: 0.0, y: 0.0}
		bitmaps			: {}
		tiles			: {}
'		private fields
        screen			: _screen
'		functions
		Draw    : StaticSpriteDraw
    }
    obj.Append(_staticSpriteData)
	
	return obj
end function

function StaticSpriteDraw() as void
    if (m.visible = false) return
    for each tileName in m.tiles
    	localOffset = m.tiles[tileName].localOffset
    	if (localOffset = invalid) localOffset = {x: 0.0, y: 0.0}

    	scale = m.tiles[tileName].scale
    	if (scale = invalid) scale = {x: 1.0, y: 1.0}
    	
    	bitmap = m.bitmaps[tileName]
    	
    	drawPosition = {}
    	drawPosition.x = m.position.x + (-localOffset.x - 0.5) * bitmap.GetWidth() * scale.x
    	drawPosition.y = m.position.y + (-localOffset.y - 0.5) * bitmap.GetHeight() * scale.y
    
    	m.screen.DrawScaledObject(drawPosition.x, drawPosition.y, scale.x, scale.y, bitmap)
    	'm.screen.DrawScaledObject(100, 100, scale.x, scale.y, bitmap)
    	return
    end for
end function

function LoadStaticSprite(_path as String) as object
	staticSpriteASCIIData = ReadAsciiFile(_path)
	if (staticSpriteASCIIData = invalid) return invalid
	
	staticSpriteData = ParseJson(staticSpriteASCIIData)
	if (staticSpriteData = invalid OR staticSpriteData.type <> "staticSprite") return invalid
	
	staticSpriteData.bitmaps = {}
	
	for each filename in staticSpriteData.filenames
		bitmap = CreateObject("roBitmap", staticSpriteData.filenames[filename])
		staticSpriteData.bitmaps.AddReplace(filename, bitmap)
	end for
	
	return staticSpriteData
end function

function CreateSprite(_screen as object, _spriteData as object) as object
    obj = {
'		public    
    	active		: true
        visible		: true
    	lifetime	: 1.0
    	loop		: true
    	position		: {x: 0.0, y: 0.0}
    	scale			: {x: 1.0, y: 1.0}
    	localOffset		: {x: 0.0, y: 0.0}
		regions			: {}
		animations		: {}
		currentAnimationName	: "idle"
'		private fields
    	time			: 0.0
		currentRegion	: invalid
		currentRegionNum	: 0
    	drawPosition	: {x: 0.0, y: 0.0}
        screen			: _screen
'		functions
		Draw    : SpriteDraw
		Update  : SpriteUpdate
		AnimationUpdate : SpriteAnimationUpdate
		AnimationSet : SpriteAnimationSet
    }
    obj.Append(_spriteData)
    obj.AnimationSet()
	obj.Update()
	
	return obj
end function

function LoadSprite(_path as String) as object
	spriteASCIIData = ReadAsciiFile(_path)
	if (spriteASCIIData = invalid) return invalid
	
	spriteData = ParseJson(spriteASCIIData)
	if (spriteData = invalid OR spriteData.type <> "sprite") return invalid
	
	spriteData.regions = {}
	
	for each bitmapName in spriteData.bitmaps
		bitmap = CreateObject("roBitmap", spriteData.bitmaps[bitmapName].filename)
		regionsData = spriteData.bitmaps[bitmapName].regions
		for each regionName in regionsData
			regionData = regionsData[regionName]
			region = CreateObject("roRegion", bitmap, regionData.offset.x, regionData.offset.y, regionData.size.x, regionData.size.y)
			spriteData.regions.AddReplace(bitmapName + "." + regionName, region)
		end for
	end for
	return spriteData
end function

function SpriteUpdate(_deltatime=0 as float, _position=invalid as object) as void
    if (m.active = false) return
    m.AnimationUpdate(_deltatime)
    if _position <> invalid
    	m.position = _position
    end if
    	
    m.drawPosition.x = m.position.x + (-m.localOffset.x - 0.5) * m.currentRegion.GetWidth() * m.scale.x
    m.drawPosition.y = m.position.y + (-m.localOffset.y - 0.5) * m.currentRegion.GetHeight() * m.scale.y
end function

function SpriteAnimationUpdate(_deltatime=0 as float) as void
    if (m.active = false) return
    currentAnimationFramesCount = m.animations[m.currentAnimationName].frames.Count()
    if (currentAnimationFramesCount = 1) return

    m.time += _deltatime * m.animations[m.currentAnimationName].speed
    if (m.time > m.lifetime) 
        if (m.loop = true)
            m.time -= m.lifetime
        else 
            m.time = m.lifetime
        endif
    end if
    if (m.time < 0) 
        if (m.loop = true)
            m.time += m.lifetime
        else 
            m.time = 0
        endif
    end if

    m.currentRegionNum = Int(m.time / m.lifetime * currentAnimationFramesCount)
    if (m.currentRegionNum > ( currentAnimationFramesCount - 1) ) m.currentRegionNum = currentAnimationFramesCount
    
    currentRegion = m.regions[m.animations[m.currentAnimationName].frames[m.currentRegionNum]]
    if ( currentRegion <> invalid) m.currentRegion = currentRegion
end function

function SpriteDraw() as void
    if (m.visible = false) return
    m.screen.DrawScaledObject(m.drawPosition.x, m.drawPosition.y, m.scale.x, m.scale.y, m.currentRegion)
end function

function SpriteAnimationSet(_animationName="idle" as String) as void
	m.currentAnimationName = _animationName
	m.currentRegion = m.regions[m.animations[_animationName].frames[0]]
	m.time = 0.0
end function

' old API

function CreateSpriteObj(_region as object, _screen as object, _x=0 as float, _y=0 as float, _localOffsetX=0 as float, _localOffsetY=0 as float, _scaleX=1 as float, _scaleY=1 as float, _regions=invalid as object, _name="idle" as String, _AnimationUpdate=SimpleSpriteAnimationUpdate as object ) as object
    obj = {
        active  : true
        visible : true
        name    : _name
        lifetime  : 1.0
        loop    : true
        speed   : 1.0
        time    : 0.0
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
        
        Draw    : SpriteDrawOld
        Update  : SimpleSpriteUpdate
        AnimationUpdate : _AnimationUpdate
    }
    obj.currentRegion.SetScaleMode(1)
        
    return obj
end function

function SpriteDrawOld() as void
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
    if (m.time > m.lifetime) 
        if (m.loop = true)
            m.time -= m.lifetime
        else 
            m.time = m.lifetime
        endif
    end if
    if (m.time < 0) 
        if (m.loop = true)
            m.time += m.lifetime
        else 
            m.time = 0
        endif
    end if

    m.currentRegionNum = Int(m.time / m.lifetime * m.regions.Count())
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

    m.drawX = m.x + (-m.localOffsetX - 0.5) * m.spriteWidth * m.scaleX + _x
    m.drawY = m.y + (-m.localOffsetY - 0.5) * m.spriteHeight * m.scaleY + _y
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
        scale	: {x: 1.0, y : 1.0}
        spriteObjArray  : {}
        currentAnimationName    : _currentAnimationName
                
        Draw    : VisObjDraw
        Update  : _Update
    }
    
    animations = _animsData.animations
    
    for each animationName in animations
        spriteObj = CreateSpriteObj(animations[animationName][0], _screen,0,0,0,0,1,1, animations[animationName], animationName)
        
        spriteObjSpeed = _animsData.extrainfo.Lookup(animationName + "_speed")
        if (spriteObjSpeed <> invalid) spriteObj.speed = spriteObjSpeed.ToFloat()
        obj.spriteObjArray.AddReplace(animationName,  spriteObj)
    end for

    return obj
end function

function SimpleVisObjUpdate(_deltatime=0 as float) as void
    if (m.active = false) return
    
    currentSprite = m.spriteObjArray.Lookup(m.currentAnimationName)
    currentSprite.Update(_deltatime, m.x, m.y)
    currentSprite.scaleX = m.scale.x
    currentSprite.scaleY = m.scale.x
    
end function

function VisObjDraw() as void
    if (m.visible = false) return
    
    spriteObj = m.spriteObjArray.Lookup(m.currentAnimationName)
    if (spriteObj <> invalid) spriteObj.Draw()
end function

'//////////////////////////////////////////////////////////////////////////////////////////////////
' PARTICLE SYSTEM
'//////////////////////////////////////////////////////////////////////////////////////////////////
function CreateParticleSystem(_globalVars as object, _animDataSet as object, _animationName as object, _position as object, _EmitterUpdate=PointEmitterUpdate as object) as object
    obj = {
        active  : true
        globalVars	: _globalVars
        position	: _position
        regions : _regions
        animationName : _animationName
        sprite		: invalid
        lifetime	: 1.0
        burst		: {time: 0.0, value: 5.0}
        particles	: []	
        
        Draw    : ParticlesSystemDraw
        Update  : ParticlesSystemUpdate
        EmitterUpdate	: _EmitterUpdate 
    } 
	    
	obj.sprite = CreateSpriteObj(_animDataSet.animations[_animationName][0], obj.globalVars.screen, obj.position.x, obj.position.y, -0.5, -0.5, 1.0, 1.0, _animDataSet.animations[_animationName], _animationName)
    return obj
end function

function ParticlesSystemDraw() as void
	for each particle in particles
	end for
	m.sprite.Draw()
end function 

function ParticlesSystemUpdate(_deltaTime=0 as float) as void

end function 

function PointEmitterUpdate(_deltaTime=0 as float) as void

end function 

function CreateParticle(_globalVars as object, _animation as object) as object
   obj = {
        active  : true
        globalVars  : _globalVars
        position : invalid
        speed   : invalid
        scale	: invalid        
        scaleDelta : invalid
        lifetime    : 1.0
        time : 0.0
        currentRegion : invalid
        
        Draw    : ParticleDraw
        Update  : ParticleUpdate
        Setup : ParticleSetup
    }
    'obj.currentRegion.SetScaleMode(1)
    return obj
end function

function ParticleSetup(_animationName as String, _lifetime as float, _position as object, _speed as object, _scale as object, _scaleDelta as object) as void
	m.time = 0.0
	m.active = true
	m.position = _position
    m.speed = _speed
    m.scale	= _scale
    m.scaleDelta = _scaleDelta
    m.lifetime = _lifetime
    m.currentRegion = _animation[_animationName][0]
end function

function ParticleDraw() as void
    m.globalVars.screen.DrawScaledObject(m.position.x, position.y, m.scale.x, m.scale.y, m.currentRegion)
end function 

function ParticleUpdate(_deltaTime=0 as float) as void
	if (m.active = false) return
    'm.AnimationUpdate(_deltatime)
    m.position.x += m.speed.x
    m.position.y += m.speed.y
end function 