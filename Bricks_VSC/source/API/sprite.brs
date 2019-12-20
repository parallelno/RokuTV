function CreateSprite(_screen as object) as object
    obj = {
'		public
		type		: "sprite"
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
        bitmaps			: {
        		"bitmapName"	: {
        			filename	: ""
        			regions	: {
        				regionName : {
        					offset : {"x": 0, "y": 0}
        					size	 : {"x": 32, "y": 32}
        				}
        			}
        		}
        	}
        animation		: {
        	animationName : {
        		speed	: 1
        		frames	: [
        			"bitmapName.regionName"
        		]
        	}
        }
'		functions
		Draw    : SpriteDraw
		Update  : SpriteUpdate
		SpriteUpdate : SpriteUpdate 'clone of Update function. it is used if Update is overriden
		AnimationUpdate : SpriteAnimationUpdate
		AnimationSet : SpriteAnimationSet
    }
	return obj
end function

function LoadSprite(_screen as object, _path as String) as object
	sprite = CreateSprite(_screen)
	spriteASCIIData = ReadAsciiFile(_path)
	if (spriteASCIIData = invalid) 
		print "spriteASCIIData " + _path + " wasn't created. Check file name."
		return invalid
	end if
	
	spriteData = ParseJson(spriteASCIIData)
	if (spriteData = invalid OR spriteData.type <> sprite.type)
		print "spriteData " + _path + " wasn't created. Check the file structure and type." 
		return invalid
	end if
	
	spriteData.regions = {}
	
	for each bitmapName in spriteData.bitmaps
		bitmap = CreateObject("roBitmap", spriteData.bitmaps[bitmapName].filename)
		if (bitmap = invalid) print "bitmap " + spriteData.bitmaps[bitmapName].filename + " wasn't created. Check file name."
		regionsData = spriteData.bitmaps[bitmapName].regions
		for each regionName in regionsData
			regionData = regionsData[regionName]
			region = CreateObject("roRegion", bitmap, regionData.offset.x, regionData.offset.y, regionData.size.x, regionData.size.y)
			spriteData.regions.AddReplace(bitmapName + "." + regionName, region)
		end for
	end for
    sprite.Append(spriteData)
    sprite.AnimationSet()
    sprite.Update()
	return sprite
end function

function SpriteAnimationSet(_animationName="idle" as String) as void
	m.currentAnimationName = _animationName
	m.currentRegion = m.regions[m.animations[_animationName].frames[0]]
	m.time = 0.0
end function

function SpriteUpdate(_deltatime=0 as float, _position=invalid as object) as void
    if (m.active = false) return
    m.AnimationUpdate(_deltatime)
    if _position <> invalid
    	m.position.x = _position.x
    	m.position.y = _position.y
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