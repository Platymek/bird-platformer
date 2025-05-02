
function createSpikeEntity(world, x, y)

    local spike = world.entity()

    local function onHit(me, you)
        
        you += Delete()
    end

    spike += Hitbox({
        team = 0, 
        rect = Rect:new(-2, -2, 4, 4),
        onHit = onHit})

    spike += Sprite({spr = Spr:new(3)})
    spike += Position({x = x, y = y})

    return spike
end
