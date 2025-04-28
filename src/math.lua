
math = {}

math.moveToward = function(from, to, delta)

    if abs(to - from) <= delta then return to end
    return from + sgn(to - from) * delta
end
