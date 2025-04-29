
math = {}

math.moveToward = function(from, to, delta)

    if abs(to - from) <= delta then return to end
    return from + sgn(to - from) * delta
end

math.inRect = function (x, y, rx, ry, rw, rh)

    
end
