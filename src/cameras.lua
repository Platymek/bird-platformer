
local RisingAnchor = world.component({target = nil, offset = 0})

function createRisingAnchorEntity(world, targetEnt, x, y)

    local ra = world.entity()

    ra += RisingAnchor({target = targetEnt, offset = config.c.offset})
    ra += Camera()
    ra += Position({x = x, y = y})

    return ra
end

local RisingAnchorSystem = world.system({Position, RisingAnchor}, 
function (ent)

    local ran = ent[RisingAnchor]
    print(ran.target[Position], 0, 0, 8)
    if ran.target[Position] == nil then return end

    local tPos = ran.target[Position]
    local pos = ent[Position]
    pos.y = min(pos.y, tPos.y - ran.offset)
    print(tPos.y - ran.offset, 0, 0, 8)
end)
