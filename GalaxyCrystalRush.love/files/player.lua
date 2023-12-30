require "files/vector2"

-- Initialize player variable
local player

-- Function to create a player object in the game world
function CreatePlayer(world, anim8)
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
    player.spriteSheet = love.graphics.newImage("sprites/Sprite-0001-Sheet.png")
    player.gird = anim8.newGrid( 64, 64, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    
    player.animations = {}
    player.animations.idle = anim8.newAnimation(player.gird('1-7', 1), 0.2)

    
    player.anim = player.animations.idle

    -- Return the created player object
    return player
end

-- Function to update the player's position and state
function UpdatePlayer(dt, sound, canJump)
    -- Apply forces based on keyboard input for horizontal movement
    local forceMultiplier = 25  -- Adjust this value to control how quickly the player stops
    
    -- Check if the player is on the ground before applying forces

        if love.keyboard.isDown("left") then    
            player.body:applyForce(-player.speed, 0)
            sound.walking:play()
        elseif love.keyboard.isDown("right") then
            player.body:applyForce(player.speed, 0)
            sound.walking:play()
        elseif player.onground then
            local vx, vy = player.body:getLinearVelocity()
            player.body:applyForce(-vx * forceMultiplier, -vy * forceMultiplier)
        end

    
    
    player.anim:update(dt)
    -- -- Check for ground contact and update player state accordingly
    -- if player.body:isTouching(ground.body) and released then
    --     object = "ground"
    --     canJump = true
    --     canJump = 0
    --     canWallJump = true
    -- end

    -- -- Check for wall contact and update player state accordingly
    -- if player.body:isTouching(wall.body) and released then
    --     object = "wall"
    --     canJump = true
    --     canJump = 0
    --     canWallJump = true
    -- end
end

-- Function to draw the player on the screen
function drawPlayer(x, y)
    --love.graphics.setColor(1, 0, 0)
    --love.graphics.circle("fill", player.body:getX(), player.body:getY(), player.shape:getRadius())
    player.anim:draw(player.spriteSheet, player.body:getX(), player.body:getY(), nil, 3, 3, 30,45)
end
