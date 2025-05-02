
function createBreakWallEntity(world, x, y, w)

    local breakWall = world.entity()
    local sw = w * 8

    breakWall += Position({x = x, y = y})

    local sprs = {}
    for i = 0, w - 1 do

        sprs[#sprs + 1] = Spr:new(4, i * 8, 0)
    end

    breakWall += SpriteGroup({sprs = sprs})

    local area = Rect:new(0, 1, sw, 6)
    breakWall += Collision({rect = area})

    local function onHurt(me, you)
    
        breakWall += Delete()
    end

    breakWall += Hurtbox({team = 0, rect = area, onHurt = onHurt})
    return breakWall
end
