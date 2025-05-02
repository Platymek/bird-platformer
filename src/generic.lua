
-- position --

local Position = world.component({x = 0, y = 0})


-- sprites --

Spr = {}

Spr.new = 
function (self, index, x, y, w, h, flip_x, flip_y)
    
    local s = {
        index = index, x = x or -4, y = y or -4, w = w or 1, h = h or 1, 
        flip_x = flip_x or false, flip_y = flip_y or false}

    setmetatable(s, self)
    self.__index = self
    return s
end

Spr.draw =
function (self, x, y)

    spr(self.index, self.x + x, self.y + y, 
    self.w, self.h, self.flip_x, self.flip_y)
end

local Sprite = world.component({spr = Spr:new(0, -4, -4)})

local SpriteSystem = world.system({Position, Sprite}, 
function (entity)
    
    local pos = entity[Position]
    local sprite = entity[Sprite]

    sprite.spr:draw(pos.x, pos.y)
end)

local SpriteGroup = world.component({sprs = {}})

local SpriteGroupSystem = world.system({Position, SpriteGroup}, 
function (entity)
    
    local pos = entity[Position]
    local spg = entity[SpriteGroup]

    for _, sprite in pairs(spg.sprs) do
    
        sprite:draw(pos.x, pos.y) 
    end
end)


-- physics --

local Collision = world.component({rect = Rect:new(-4, -4, 8, 8)})

local DrawCollision = world.system({Position, Collision}, 
function (ent, color)

    local pos = ent[Position]

    ent[Collision].rect:draw(pos.x, pos.y, color)
end
)

local isPointInCollision =
function (world, x, y, ent)

    local colEntities = world.query({Collision, Position})
    
    for _, colEnt in pairs(colEntities) do

        if ent ~= colEnt and ent ~= nil then 

            local pos = colEnt[Position]
            
            if colEnt[Collision].rect
                :getOffset      (pos.x, pos.y)
                :isPointInRect  (x, y)

            then return true end
        end
    end

    return false
end


local Velocity = world.component({x = 0, y = 0, onFloor = false })

local function movex(ent, col, pos, newPos, isSolidFunc)

    if flr(pos.x) ~= flr(newPos.x) then

        local y1 = pos.y + col.rect.y
        local y2 = y1 + col.rect.h - 1
        
        local x = newPos.x + col.rect.x

        if pos.x < newPos.x then

            x += col.rect.w - 1
        end
        
        if isSolidFunc(x, y1, ent)
        or isSolidFunc(x, y2, ent) then
            
            return pos.x
        end
    end

    return newPos.x
end

local function movey(ent, col, pos, newPos, isSolidFunc)

    if flr(pos.y) ~= flr(newPos.y) then

        local x1 = pos.x + col.rect.x
        local x2 = x1 + col.rect.w - 1
        
        local y = newPos.y + col.rect.y
        local falling = pos.y < newPos.y

        if falling then

            y += col.rect.h - 1
        end
        
        if isSolidFunc(x1, y, ent, falling)
        or isSolidFunc(x2, y, ent, falling) then
            
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

            local nx = movex(entity, col, pos, newPos, isSolidFunc)
            
            if pos.x == nx then

                vel.x = 0
            else
                pos.x = nx
            end
        end

        if vel.y ~= 0 then

            local ny = movey(entity, col, pos, newPos, isSolidFunc)

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
                    if hurt.onHurt then hurt.onHurt(ent, hitEnt) end
                    if hit .onHit  then hit .onHit (hitEnt, ent) end
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
