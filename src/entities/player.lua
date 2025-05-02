
local Player = world.component({

    -- player number, state and flap pressed
    pnum = 0, state = 0, flapped = false,

    -- time elapsed
    charge = 0, attack = 0, stun = 0})
--[[
0 - idle
1 - charge
2 - attack
3 - stun
4 - repel
]]


local function setState(ent, state)

    local pla = ent[Player]
    local gra = ent[Gravity]
    local vel = ent[Velocity]

    -- exit state
    if      pla.state == 1 then 

        gra.scale   = 1
        pla.charge  = 0

    elseif  pla.state == 2 then 

        vel.y       = 0
        gra.scale   = 1
        ent -= Hitbox

    elseif  pla.state == 3 then 

        vel.y       = 0
        gra.scale   = 1
    end

    pla.state = state

    -- enter state
    if      pla.state == 1 then

        gra.scale   = config.p.charge.graScale

    elseif  pla.state == 2 then

        vel.x       = 0
        vel.y       = -config.p.attack.speed
        gra.scale   = 0
        pla.attack  = 0

        ent += Hitbox({team = 1, rect = Rect:new(-4, -6, 8, 4)})

    elseif  pla.state == 3 then

        pla.stun    = 0
        vel.y       = 0
        gra.scale   = 0
    end
end

local function getPressure()

    local pressure = 0
    if btn(0) then pressure -= 1 end
    if btn(1) then pressure += 1 end
    return pressure
end

local function move(ent, pressure)

    local vel = ent[Velocity]

    vel.x = pressure * config.p.move.max
end

local function flap(ent)

    local vel = ent[Velocity]

    if vel.y > config.p.flap.tolHalt then 
        
        vel.y = -config.p.flap.halt

    else
        local strong = vel.y < -config.p.flap.tolWeak
        vel.y = -config.p.flap.strength

        if strong then 

            vel.y *= config.p.flap.mult
        end
    end
end

local function charge(ent, dt)

    local pla = ent[Player]
    move(ent, getPressure(), dt)

    pla.charge += dt

    if pla.state == 0 
    and pla.charge > config.p.charge.toCharge then

        setState(ent, 1)
    end
end

local states = {}

states.idle = function (ent, dt)
    
    local pla = ent[Player]
    move(ent, getPressure(), dt)

    if btn(4) then

        if not pla.flapped then 

            flap(ent)
            pla.flapped = true
        end

        charge(ent, dt)

    elseif pla.flapped then

        pla.flapped = false
        pla.charge = 0
    end
end

states.charge = function (ent, dt)

    local pla = ent[Player]

    if btn(4) then charge(ent, dt) 
    else
        if pla.charge > config.p.charge.toAttack then

            setState(ent, 2)
        else
            setState(ent, 0)
        end
    end
end

states.attack = function (ent, dt)

    local pla = ent[Player]

    if pla.attack > config.p.attack.time then

        setState(ent, 3)
    else
        pla.attack += dt
    end
end

states.stun = function (ent, dt)

    local pla = ent[Player]

    if pla.stun > config.p.stunDur then

        setState(ent, 0)
    else 
        pla.stun += dt 
    end
end


function createPlayerEntity(world, x, y)
    
    local player = world.entity()

    player += Player()

    player += Position({x = x, y = y})
    player += Velocity()
    player += Gravity({strength = config.grav, lim = config.p.terminal})


    local box = Rect:new(-3, -2, 6, 6)

    player += Collision({rect = box})
    player += Hurtbox({team = 1, rect = box})
    player += Sprite({spr = Spr:new(1)})

    setState(player, 0)

    return player
end


local PlayerSystem = world.system({Player}, function (ent, dt)

    local pla = ent[Player]
    local vel = ent[Velocity]

    -- states
    if      pla.state == 0  then states.idle  (ent, dt) 
    elseif  pla.state == 1  then states.charge(ent, dt) 
    elseif  pla.state == 2  then states.attack(ent, dt) 
    elseif  pla.state == 3  then states.stun  (ent, dt) 
    end
end)
