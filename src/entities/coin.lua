
function createCoinEntity(world, x, y)

    local coin = world.entity()

    local function onCollect()

        coin += Delete()
    end

    coin += Collectable({onCollect = onCollect})
    coin += Sprite({spr = Spr:new(5)})
    coin += Position({x = x, y = y})

    return coin
end
