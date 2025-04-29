
-- position --

local Position = world.component({x = 0, y = 0})


-- sprites --

local Sprite = world.component({index = 0, offx = 0, offy = 0})

local SpriteSystem = world.system({Position, Sprite}, 
function (entity)
    
    local pos = entity[Position]
    local sprite = entity[Sprite]

    spr(sprite.index, pos.x + sprite.offx, pos.y + sprite.offy)
end)


-- physics --

local Collision = world.component({x = 0, y = 0, w = 8, h = 8})
local Velocity = world.component({x = 0, y = 0, onFloor = false })

local function movex(col, pos, newPos, isSolidFunc)

    if flr(pos.x) ~= flr(newPos.x) then

        local y1 = pos.y + col.y
        local y2 = y1 + col.h - 1
        
        local x = newPos.x + col.x

        if pos.x < newPos.x then

            x += col.w - 1
        end
        
        if isSolidFunc(x, y1)
        or isSolidFunc(x, y2) then
            
            return pos.x
        end
    end

    return newPos.x
end

local function movey(col, pos, newPos, isSolidFunc)

    if flr(pos.y) ~= flr(newPos.y) then

        local x1 = pos.x + col.x
        local x2 = x1 + col.w - 1
        
        local y = newPos.y + col.y
        local falling = pos.y < newPos.y

        if falling then

            y += col.h - 1
        end
        
        if isSolidFunc(x1, y, falling)
        or isSolidFunc(x2, y, falling) then
            
            return pos.y
        end
    end

    return newPos.y
end

-- does not yet work for shapes larger than 8 pixels in w or h
local VelocitySystem = world.system({Position, Velocity}, 
function (entity, dt, isSolidFunc)
    
    local pos = entity[Position]
    local vel = entity[Velocity]
    local col = entity[Collision]
    
    local newPos = {
        x = pos.x + vel.x * dt, 
        y = pos.y + vel.y * dt}

    if isSolidFunc == nil or col == nil then

        pos.x = newPos.x
        pos.y = newPos.y
    else
        if vel.x ~= 0 then

            local nx = movex(col, pos, newPos, isSolidFunc)
            
            if pos.x == nx then

                vel.x = 0
            else
                pos.x = nx
            end
        end

        if vel.y ~= 0 then

            local ny = movey(col, pos, newPos, isSolidFunc)

            if pos.y == ny then

                if vel.y > 0 then vel.onFloor = true end
                
                vel.y = 0
            else
                pos.y = ny
            end
        end
    end
end)


local Gravity = world.component({strength = 16, lim = 16, scale = 1})

local GravitySystem = world.system({Gravity, Velocity}, 
function (entity, dt)

    local gra = entity[Gravity]
    if gra.scale == 0 then return end

    local vel = entity[Velocity]
    
    vel.y = math.moveToward(vel.y, gra.lim * gra.scale, gra.strength * dt * gra.scale)
end)
