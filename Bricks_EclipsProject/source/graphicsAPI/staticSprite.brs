function CreateStaticSprite(_screen as object) as object
    obj = {
'		public
		type		: "staticSprite"
        visible		: true
        position		: {x: 0.0, y: 0.0}
		bitmaps			: {
			bitmapName	: invalid
		}
		tiles			: {
				objectName: {
					bitmap	: "bitmapName"
					repeat	: {count: 1, x: 0.0, y: 0.0}
					order	: 0 'render order. -1 (background) will be rendered earlier than 0 (common layer)
					position: {x: 0.0, y: 0.0}
					localOffset: {x: 0.0, y: 0.0}
					scale: {x: 0.0, y: 0.0}
				}
			}
		filenames	: {
			bitmapName : ""
		}
'		private fields
        screen			: _screen
'		functions
		Update	: StaticSpriteUpdate
		Draw	: StaticSpriteDraw
    }
	return obj
end function

function StaticSpriteUpdate() as void
    if (m.active = false) return
    for each tileName in m.tiles
    	position = m.tiles[tileName].position
    	localOffset = m.tiles[tileName].localOffset
    	scale = m.tiles[tileName].scale
    	bitmap = m.bitmaps[tileName]
    	
    	drawPosition = {}
    	drawPosition.x = position.x + (-localOffset.x - 0.5) * bitmap.GetWidth() * scale.x + m.position.x
    	drawPosition.y = position.y + (-localOffset.y - 0.5) * bitmap.GetHeight() * scale.y + m.position.y
    	m.tiles[tileName].drawPosition = drawPosition
    end for
end function

function StaticSpriteDraw() as void
    if (m.visible = false) return
    for each tileName in m.tiles
    	position = m.tiles[tileName].position
    	localOffset = m.tiles[tileName].localOffset
    	scale = m.tiles[tileName].scale
    	bitmap = m.bitmaps[tileName]
    	
		drawPosition = m.tiles[tileName].drawPosition 
		repeatCount = m.tiles[tileName].repeat.count
   		repeatOffsetX = m.tiles[tileName].repeat.x
   		repeatOffsetY = m.tiles[tileName].repeat.y

    	for	i=0 to repeatCount-1
    		m.screen.DrawScaledObject(drawPosition.x + repeatOffsetX * i, drawPosition.y + repeatOffsetY * i, scale.x, scale.y, bitmap)
    	end for
    end for
end function

function LoadStaticSprite(_screen as object, _path as String) as object
	sprite = CreateStaticSprite(_screen)
	staticSpriteASCIIData = ReadAsciiFile(_path)
	if (staticSpriteASCIIData = invalid) return invalid
	
	staticSpriteData = ParseJson(staticSpriteASCIIData)
	if (staticSpriteData = invalid OR staticSpriteData.type <> sprite.type) return invalid
	
	staticSpriteData.bitmaps = {}
	
	for each filename in staticSpriteData.filenames
		bitmap = CreateObject("roBitmap", staticSpriteData.filenames[filename])
		staticSpriteData.bitmaps.AddReplace(filename, bitmap)
	end for
	
	for each tileName in staticSpriteData.tiles
    	if (staticSpriteData.tiles[tileName].position = invalid) staticSpriteData.tiles[tileName].position = {x: 0.0, y: 0.0}
    	if (staticSpriteData.tiles[tileName].localOffset = invalid) staticSpriteData.tiles[tileName].localOffset = {x: 0.0, y: 0.0}
    	if (staticSpriteData.tiles[tileName].scale = invalid) staticSpriteData.tiles[tileName].scale = {x: 1.0, y: 1.0}
    	
    	isRepeated = staticSpriteData.tiles[tileName].repeat
    	repeat = {
    		count	: 1
    		x	: 0
    		y	: 0
    	}
    	if (isRepeated = invalid) 
    		staticSpriteData.tiles[tileName].repeat = repeat
    	end if
    end for
    
    sprite.Append(staticSpriteData)
    sprite.Update()
	return sprite
end function