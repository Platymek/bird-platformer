

local Player = world.component({pnum = 0, state = 0, flapped = false})
--[[
0 - idle
1 - charge
2 - attack
]]


local function setState(ent, state)

    ent[Player].state = state
end

local function flap(ent)

    local vel = ent[Velocity]

    if vel.y > config.p.flap.tolHalt then 
        
        vel.y = 0

    else
        local strong = vel.y < config.p.flap.tolWeak
        vel.y = -config.p.flap.strength

        if strong then 

            vel.y *= config.p.flap.mult
        end
    end
end


function createPlayerEntity(world, x, y)
    
    local player = world.entity()

    player += Player()

    player += Position({x = x, y = y})
    player += Velocity()
    player += Gravity({strength = config.grav, lim = config.p.terminal})

    player += Sprite({index = 1})

    setState(player, 0)

    return player
end


local PlayerSystem = world.system({Player}, function (ent)

    local pla = ent[Player]
    local vel = ent[Velocity]

    vel.x = 0

    if btn(0) then vel.x -= config.p.move.max end
    if btn(1) then vel.x += config.p.move.max end

    if pla.state == 0 then

        if btn(4) then

            if not pla.flapped then 

                flap(ent)
                pla.flapped = true
            end
        else
            pla.flapped = false
        end
    end
end)
