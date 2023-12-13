require "files/vector2"

-- Initialize player variable
local player

-- Function to create a player object in the game world
function CreatePlayer(world)
    -- Create a new player object 
    player = {}

    -- Set up the player's physics body, shape, and fixture
    player.body = love.physics.newBody(world, -100, -500, "dynamic")
    player.shape = love.physics.newCircleShape(50) 
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.body:setFixedRotation(true) 
    player.speed = 2000
    player.jumpForce = -400
    player.fixture:setUserData(({object = player,type = "player", index = i})) 
    player.checkpointX = 0
    player.checkpointY = 0

    -- Return the created player object
    return player
end

-- Function to update the player's position and state
function UpdatePlayer(dt, ground, wall)
    -- Apply forces based on keyboard input for horizontal movement
    if love.keyboard.isDown("left") then
        player.body:applyForce(-player.speed, 0)
    elseif love.keyboard.isDown("right") then
        player.body:applyForce(player.speed, 0)
    end

    -- Check for ground contact and update player state accordingly
    if player.body:isTouching(ground.body) and released then
        object = "ground"
        canJump = true
        jumpCount = 0
        canWallJump = true
    end

    -- Check for wall contact and update player state accordingly
    if player.body:isTouching(wall.body) and released then
        object = "wall"
        canJump = true
        jumpCount = 0
        canWallJump = true
    end
end

-- Function to draw the player on the screen
function drawPlayer(x, y)
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", player.body:getX(), player.body:getY(), player.shape:getRadius())
end
