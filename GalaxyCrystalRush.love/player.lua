require "vector2"

local player

function CreatePlayer(world)
    -- player = {}
    -- player.body = love.physics.newBody(world, 200, 100, "dynamic")
    -- player.shape = love.physics.newRectangleShape(30, 60)
    -- player.fixture = love.physics.newFixture(player.body, player.shape, 1)
    -- player.maxvelocity = 200
    -- player.onground = false
    -- player.fixture:setFriction(1)
    -- player.fixture:setUserData("player")
    -- player.body:setFixedRotation(true)

    player = {}
    player.body = love.physics.newBody(world, -100, -500, "dynamic")
    player.shape = love.physics.newCircleShape(20) -- Radius von 20 Pixel
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.body:setFixedRotation(true) -- Verhindere Drehung
    player.speed = 100 -- Horizontale Geschwindigkeit
    player.jumpForce = -2000 -- Sprungkraft
    player.fixture:setUserData ("player") 

    return player
end

function UpdatePlayer(dt)
    if love.keyboard.isDown("right") then
        local moveForce = vector2.new(700, 0)
        player.body:applyForce(moveForce.x, moveForce.y)
    end

    if love.keyboard.isDown("left") then
        local moveForce = vector2.new(-700, 0)
        player.body:applyForce(moveForce.x, moveForce.y)
    end

    if love.keyboard.isDown("up") and player.onground == true then
        local jumpForce = vector2.new(0, -500)
        player.body:applyLinearImpulse(jumpForce.x, jumpForce.y)
        player.onground = false
    end

    local velocity = vector2.new(player.body:getLinearVelocity())

    if velocity.x > 0 then
        player.body:setLinearVelocity(math.min(velocity.x, player.maxvelocity), velocity.y)
    else
        player.body:setLinearVelocity(math.max(velocity.x, player.maxvelocity), velocity.y)
    end
end

function DrawPlayer()
    love.graphics.polygon("fill", player.body:getWorldPoints(player.shape:getPoints()))
end

function BeginContactPlayer(fixtureA, fixtureB, contact)
    if fixtureA:getUserData() == "platform" and fixtureB:getUserData() == "player" then
        local normal = vector2.new(contact:getNormal())

        if normal.y == -1 then
            player.onground = true
        end
    end
end

function GetPlayerPosition()
    return vector2.new(player.body:getPosition())
end
