function CreateStaticSprite(_screen as object) as object
    obj = {
'		public
		type		: "staticSprite"
        visible		: true
        time		: 0
        position		: {x: 0.0, y: 0.0}
        scale			: {x: 1.0, y: 1.0}
		regions			: {
			regionName	: invalid
		}
		tiles			: [
			{
				region	: "regionName"
				type	: "" 'invalid = no special features, "scrolling" = it's scrolled
				speed	: {x: 0.0, y: 0.0} ' it's used for type = "scrolling" as a scrolling speed 
				repeat	: {count: 1, x: 0.0, y: 0.0}
				order	: 0 'render order from -999 to 9999. -1 (background) will be rendered earlier than 0 (common layer)
				position: {x: 0.0, y: 0.0}
				localOffset: {x: 0.0, y: 0.0}
				scale: {x: 0.0, y: 0.0}
			}
		]
		filenames	: {
			regionName : ""
		}
'		private fields
        screen			: _screen
'		functions
		Update	: StaticSpriteUpdate
		Draw	: StaticSpriteDraw
    }
	return obj
end function

function StaticSpriteUpdate(_deltatime=0 as float) as void
    if (m.active = false) return
    for each tile in m.tiles
    	position = tile.position
    	localOffset = tile.localOffset
    	scale = tile.scale
    	region = m.regions[tile.region]
    	
    	drawPosition = {}
    	drawPosition.x = position.x + (-localOffset.x - 0.5) * region.GetWidth() * scale.x * m.scale.x + m.position.x
    	drawPosition.y = position.y + (-localOffset.y - 0.5) * region.GetHeight() * scale.y * m.scale.y + m.position.y
    	tile.drawPosition = drawPosition
    	if (tile.type = "scrolling") ScrolledStaticSpriteUpdate(_deltatime, tile, region)
    end for
end function

function ScrolledStaticSpriteUpdate(_deltatime as float, _tile as object, _region as object) as void
    if (m.active = false) return
    currentSpriteOffsetX = _deltatime * _tile.speed.x
    currentSpriteOffsetY = _deltatime * _tile.speed.y
    currentSpriteOffsetX -= Int(currentSpriteOffsetX / _region.GetWidth()) * _region.GetWidth()
    currentSpriteOffsetY -= Int(currentSpriteOffsetY / _region.GetHeight()) * _region.GetHeight()
    _region.Offset(currentSpriteOffsetX, currentSpriteOffsetY, 0, 0)
end function

function StaticSpriteDraw() as void
    if (m.visible = false) return
    for each tile in m.tiles
    	position = tile.position
    	localOffset = tile.localOffset
    	scale = tile.scale
    	region = m.regions[tile.region]
    	
		drawPosition = tile.drawPosition 
		repeatCount = tile.repeat.count
   		repeatOffsetX = tile.repeat.x
   		repeatOffsetY = tile.repeat.y

    	for	i=0 to repeatCount-1
    		m.screen.DrawScaledObject(drawPosition.x + repeatOffsetX * i, drawPosition.y + repeatOffsetY * i, scale.x * m.scale.x, scale.y * m.scale.y, region)
    	end for
    end for
end function

function LoadStaticSprite(_screen as object, _path as String) as object
	staticSprite = CreateStaticSprite(_screen)
	staticSpriteASCIIData = ReadAsciiFile(_path)
	if (staticSpriteASCIIData = invalid) 
		print "staticSpriteASCIIData " + _path + " wasn't created. Check file name."
		return invalid
	end if
	
	staticSpriteData = ParseJson(staticSpriteASCIIData)
	if (staticSpriteData = invalid OR staticSpriteData.type <> staticSprite.type)
		print "staticSpriteData " + _path + " wasn't created. Check the file structure and type." 
		return invalid
	end if
	
	staticSpriteData.regions = {}
	
	for each filename in staticSpriteData.filenames
		bitmap = CreateObject("roBitmap", staticSpriteData.filenames[filename])
		if (bitmap = invalid) print "bitmap " + staticSpriteData.filenames[filename] + " wasn't created. Check file name."
		region = CreateObject("roRegion", bitmap, 0, 0, bitmap.GetWidth(), bitmap.GetHeight())
		staticSpriteData.regions.AddReplace(filename, region)
	end for
	
	for each tile in staticSpriteData.tiles
		if (tile.type = "scrolling")
			staticSpriteData.regions[tile.region].SetWrap(true)
		end if
		
    	if (tile.position = invalid) tile.position = {x: 0.0, y: 0.0}
    	if (tile.localOffset = invalid) tile.localOffset = {x: 0.0, y: 0.0}
    	if (tile.scale = invalid) tile.scale = {x: 1.0, y: 1.0}
    	if (tile.order = invalid) tile.order = 0
    	
    	isRepeated = tile.repeat
    	repeat = {
    		count	: 1
    		x	: 0
    		y	: 0
    	}
    	if (isRepeated = invalid) 
    		tile.repeat = repeat
    	end if
    end for
    staticSpriteData.tiles.SortBy("order")
    
    staticSprite.Append(staticSpriteData)
    staticSprite.Update()
	return staticSprite
end function