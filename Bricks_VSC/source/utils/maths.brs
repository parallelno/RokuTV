' SERVISE FUNCTIONS --------------------------------------------------------------
function MinF(_x as float, _y as float) as float
    if (_x > _y) return _y
    return _x
end function

function MaxF(_x as float, _y as float) as float
    if (_x > _y) return _x
    return _y
end function

function MinI(_x as integer, _y as integer) as integer
    if (_x > _y) return _y
    return _x
end function

function MaxI(_x as integer, _y as integer) as integer
    if (_x > _y) return _x
    return _y
end function

function ClampF(_v as float, _min=0 as float, _max=1 as float) as float
    min = MinF(_min, _max)
    max = MaxF(_min, _max)
    
    if (_v > max) 
        _v = max
    else if (_v < min) 
        _v = min
    end if
    return _v
end function

function ClampI(_v as integer, _min as integer, _max as integer) as integer
    min = MinI(_min, _max)
    max = MaxI(_min, _max)
    
    if (_v > max) _v = max
    if (_v < min) _v = min
    return _v
end function

function Blend(_x as float, _y as float, _blendFactor as float) as float
    return _x *(1.0 - _blendFactor) + _y * _blendFactor
end function

function Distance(_obj1 as object, _obj2 as object) as float
    vecX = _obj1.x - _obj2.x
    vecY = _obj1.y - _obj2.y
    res = Sqr(vecX * vecX + vecY * vecY )
    return res
end function

function VectorLength(_obj1 as object) as float
    res = Sqr(_obj1.x * _obj1.x + _obj1.y * _obj1.y )
    return res
end function

function NormalizeVector(_vec as object) as object
	if (_vec.x = 0 AND _vec.y = 0)
		return _vec
	end if
	vecLength = VectorLength(_vec)
	_vec.x = _vec.x / vecLength
	_vec.y = _vec.y / vecLength
	return _vec
end function

function DotProduct(_vec1 as object, _vec2 as object) as float
	dot = _vec1.x * _vec2.x + _vec1.y * _vec2.y 
	return dot
end function 

function ReflectVector(_vec as object, _normal as object) as object
	dot = DotProduct(_vec, _normal)
	reflectVec = {x: 0.0, y: 0.0}
	reflectVec.x = _vec.x - 2 * dot * _normal.x
	reflectVec.y = _vec.y - 2 * dot * _normal.y	
	return reflectVec
end function