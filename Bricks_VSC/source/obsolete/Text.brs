function CreateNumberTextObj(_value as integer, _regions as object, _screen as object, _x=0 as float, _y=0 as float, _localOffsetX=0 as float, _localOffsetY=0 as float, _scaleX=1 as float, _scaleY=1 as float, _AnimationUpdate=SimpleNumTextAnimationUpdate as object ) as object
    obj = {
        active          : true
        visible         : true
        value           : _value
        x               : _x
        y               : _y
        localOffsetX    : _localOffsetX
        localOffsetY    : _localOffsetY
        drawX           : 0
        drawY           : 0
        scaleX          : _scaleX
        scaleY          : _scaleY
        lifetime		: 1.0
        loop            : true
        speed           : 1.0
        time            : 0
        regions         : _regions
        screen          : _screen
        actualDrawRegions   : []
        beetweenCharOffset  : 0
        charWidth       : _regions[0].GetWidth()
        charHeight      : _regions[0].GetHeight()
        
        Draw            : DrawNumberText
        Update          : SimpleNumberTextUpdate
        AnimationUpdate : _AnimationUpdate
    }
    
    for each region in obj.regions
        region.SetScaleMode(1)
    end for
    
    return obj
end function

function SimpleNumberTextUpdate(_deltatime=0 as float) as void
    if (m.active = false) return
    m.AnimationUpdate(_deltatime)
    
    m.value = ClampI(m.value, 0, 99999999)
    valueDigitsCount = 1
    
    if (m.value >= 10000000) 
        valueDigitsCount = 8
    else if (m.value >= 1000000) 
        valueDigitsCount = 7
    else if (m.value >= 100000) 
        valueDigitsCount = 6
    else if (m.value >= 10000) 
        valueDigitsCount = 5
    else if (m.value >= 1000) 
        valueDigitsCount = 4
    else if (m.value >= 100) 
        valueDigitsCount = 3
    else if (m.value >= 10) 
        valueDigitsCount = 2
    end if

    m.actualDrawRegions.Clear()
    tempValue = m.value
    divider = 10 ^ (valueDigitsCount - 1)
    
    charCode = 0
    for i=1 to valueDigitsCount
        charCode = tempValue \ divider
        m.actualDrawRegions.Push(m.regions[charCode])
        tempValue = tempValue - charCode * divider
        divider \= 10
    end for
    
    m.drawX = m.x + (-m.localOffsetX - 0.5) * (m.charWidth + m.beetweenCharOffset) * valueDigitsCount * m.scaleX
    m.drawY = m.y + (-m.localOffsetY - 0.5) * m.charHeight * m.scaleY
end function

function SimpleNumTextAnimationUpdate(_deltatime=0 as float) as void
    if (m.active = false) return
    
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
end function

function DrawNumberText() as void
    if (m.visible = false) return
    charOffsetX = 0
    for each actualDrawRegion in m.actualDrawRegions
        m.screen.DrawScaledObject(m.drawX + charOffsetX, m.drawY, m.scaleX, m.scaleY, actualDrawRegion)
        charOffsetX += (m.charWidth + m.beetweenCharOffset) * m.scaleX
    end for
end function