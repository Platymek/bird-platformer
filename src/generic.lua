
-- position --

local Position = world.component({x = 0, y = 0})


-- sprites --

local Sprite = world.component({index = 0, offx = 0, offy = 0})

local SpriteSystem = world.system({Position, Sprite}, function (entity)
    
    local pos = entity[Position]
    local sprite = entity[Sprite]

    spr(sprite.index, pos.x + sprite.offx, pos.y + sprite.offy)
end)


-- physics --

local Velocity = world.component({x = 0, y = 0})

local VelocitySystem = world.system({Position, Velocity}, function (entity, dt)
    
    local pos = entity[Position]
    local vel = entity[Velocity]

    pos.x += vel.x * dt
    pos.y += vel.y * dt
end)


local Gravity = world.component({strength = 16, lim = 16, scale = 1})

local GravitySystem = world.system({Gravity, Velocity}, function (entity, dt)

    local gra = entity[Gravity]
    if gra.scale == 0 then return end

    local vel = entity[Velocity]
    
    vel.y = math.moveToward(vel.y, gra.lim * gra.scale, gra.strength * dt * gra.scale)
end)
