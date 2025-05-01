
-- position --

local Position = world.component({x = 0, y = 0})


-- sprites --

local Sprite = world.component({index = 0, offx = -4, offy = -4})

local SpriteSystem = world.system({Position, Sprite}, 
function (entity)
    
    local pos = entity[Position]
    local sprite = entity[Sprite]

    spr(sprite.index, pos.x + sprite.offx, pos.y + sprite.offy)
end)


-- physics --

local Collision = world.component({x = 0, y = 0, w = 8, h = 8})

local DrawCollision = world.system({Position, Collision}, 
function (ent, color)

    local pos = ent[Position]
    local col = ent[Collision]

    local x = pos.x + col.x
    local y = pos.y + col.y

    rect(x, y, x + col.w - 1, y + col.h - 1)
end
)


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

-- camera --

--[[
local Camera = world.component({maxSpeed = 16, offx = 0, offy = 0, x = 0, y = 0 })

local CameraSystem = world.system({Camera, Position},
function (ent, dt)
    
    local cam = ent[Camera]
    local pos = ent[Position]

    local function ease(c, p, ms)
    
        return math.moveToward(c, p, 
        -- slow with distance to entity, if it's smaller than max speed
            min(abs(c - p), ms))
    end

    cam.x = ease(cam.x, pos.x, cam.maxSpeed)
    cam.y = ease(cam.y, pos.y, cam.maxSpeed)

    camera
end)
]]

local Camera = world.component({offx = 0, offy = 0})

local CameraSystem = world.system({Camera, Position},
function (ent)
    
    local cam = ent[Camera]
    local pos = ent[Position]

    camera(pos.x + cam.offx - 64, pos.y + cam.offy - 64)
end)


-- hitbox and hurtbox --

-- onHurt and onHit have parameters: me, you
local Hitbox  = world.component({team = nil, rect = Rect:new(-4, -4, 8, 8), onHit  = nil})
local Hurtbox = world.component({team = nil, rect = Rect:new(-4, -4, 8, 8), onHurt = nil})

local DrawHitboxes = world.system({Position, Hitbox}, 
function (ent, color)

    local pos = ent[Position]

    ent[Hitbox].rect:draw(pos.x, pos.y, color)
end)

local DrawHurtboxes = world.system({Position, Hurtbox}, 
function (ent, color)

    local pos = ent[Position]

    ent[Hurtbox].rect:draw(pos.x, pos.y, color)
end)

local HurtboxSystem = world.system({Hurtbox, Position},
function (ent)
    
    local hitEntities = world.query({Hitbox, Position})

    for _, hitEnt in pairs(hitEntities) do
        
        if ent != hitEnt then

            local hit  = hitEnt[Hitbox]
            local hitPos = hitEnt[Position]

            local hurt = ent[Hurtbox]
            local hurtPos = ent[Position]

            if hit.team != hurt.team then

                -- if overlapping
                if hit.rect
                :getOffset(hitPos.x, hitPos.y)
                :isOverlapping(hurt.rect
                :getOffset(hurtPos.x, hurtPos.y))
                then
                    if hurt.onHurt then hit.onHurt(hitEnt, ent) end
                    if hit .onHit  then hit.onHit (hitEnt, ent) end
                end
            end
        end
    end
end)


-- deletion --

local Delete = world.component({onDelete = nil})

local function deleteEntity(world, entity)

    world.remove(entity)
end

local DeleteSystem = world.system({Delete},
function (ent)
    
    local del = ent[Delete]
    if del.onDelete then del.onDelete() end

    world.queue(deleteEntity(world, ent))
end)
