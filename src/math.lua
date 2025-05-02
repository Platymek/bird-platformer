
math = {}

math.moveToward = 
function(from, to, delta)

    if abs(to - from) <= delta then return to end
    return from + sgn(to - from) * delta
end

-- rectangle a and b
math.isRectsOverlapping = 
function (
    ax1, ay1, ax2, ay2,
    bx1, by1, bx2, by2)

    if ax2 <= bx1 or bx2 <= ax1
    or ay2 <= by1 or by2 <= ay1
    then return false end

    -- Otherwise, they must be overlapping
    return true
end

math.isPointInArea = 
function (ax1, ay1, ax2, ay2, x, y)

    return
        x >= ax1
    and x <= ax2
    and y >= ay1
    and y <= ay2
end

math.lerp = function (a, b, speed)

    return (1 - speed) * a + speed * b
end


-- rectangles --

Rect = {}

Rect.new = 
function (self, x, y, w, h)
    
    r = {x = x, y = y, w = w, h = h}
    setmetatable(r, self)
    self.__index = self
    return r
end

Rect.isOverlapping = 
function (self, rect)
    
    return math.isRectsOverlapping(

        self.x, self.y, self.x + self.w, self.y + self.h,
        rect.x, rect.y, rect.x + rect.w, rect.y + rect.h
    )
end

Rect.getOffset =
function (self, x, y)

    return Rect:new(self.x + x, self.y + y, self.w, self.h)
end

Rect.isPointInRect =
function (self, x, y)
    
    return math.isPointInArea(

        self.x, self.y, self.x + self.w, self.y + self.h,
        x, y
    )
end

Rect.draw =
function (self, x, y, color)

    local rx = self.x + x
    local ry = self.y + y

    rect(rx, ry, 
    rx + self.w - 1, 
    ry + self.h - 1, 
    color)
end
