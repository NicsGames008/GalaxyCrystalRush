require "vector2"

function CreatePlatform(world, x, y, w, h)
    local platform = {}
    platform.body = love.physics.newBody(world, x+(w/2), y+(h/2), "static")
    platform.shape = love.physics.newRectangleShape(w, h)
    platform.fixture = love.physics.newFixture(platform.body, platform.shape, 2)
    platform.fixture:setUserData("platform")
    return platform
end

function DrawLevel(level)
    for i = 1, #level, 1 do
        love.graphics.polygon("fill", level[i].body:getWorldPoints(level[i].shape:getPoints()))
    end
end
