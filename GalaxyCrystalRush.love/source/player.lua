require "source/vector2"

-- Add these variables at the top of your file or in the appropriate scope
local jumpTimerMax = 0.2 -- Adjust this value based on your jump animation duration
local jumpTimer = 0

-- Function to create a player object in the game world
function createPlayer(world, anim8)
    -- Create a new player object
    player = {}

    -- Set up the player's physics body, shape, and fixture
    player.body = love.physics.newBody(world, -100, -500, "dynamic")
    player.shape = love.physics.newCircleShape(50)
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.body:setFixedRotation(true)
    player.fixture:setUserData(({ object = player, type = "player", index = i }))

    player.speed = 2000
    player.jumpForce = 1500
    player.walljumpf = 1500
    player.hasMoved = false
    player.direction = 0
    player.checkpointX = 0
    player.checkpointY = 0
    player.onground = false

    player.spriteSheet = love.graphics.newImage("sprites/Sprite-0001-Sheet.png")
    player.gird = anim8.newGrid(64, 64, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    player.animations = {}
    player.animations.idleRight = anim8.newAnimation(player.gird('1-7', 1), 0.09)
    player.animations.idleLeft = anim8.newAnimation(player.gird('1-7', 2), 0.09)
    player.animations.walikingRight = anim8.newAnimation(player.gird('1-7', 3), 0.09)
    player.animations.walikingLeft = anim8.newAnimation(player.gird('1-7', 4), 0.09)
    player.animations.jumpRight = anim8.newAnimation(player.gird('1-5', 5), 0.09)
    player.animations.jumpLeft = anim8.newAnimation(player.gird('5-1', 6), 0.09)

    player.anim = player.animations.idleRight

    -- Return the created player object
    return player
end

-- Function to update the player's position and state
function updatePlayer(dt, sound)
    -- Apply forces based on keyboard input for horizontal movement
    local forceMultiplier = 25

    -- Move left
    if love.keyboard.isDown("left") then
        player.body:applyForce(-player.speed, 0)
        player.hasMoved = true
        player.direction = -1
        -- Move right
    elseif love.keyboard.isDown("right") then
        player.body:applyForce(player.speed, 0)
        player.hasMoved = true
        player.direction = 1
        -- Apply force in the opposite direction if on the ground and not moving
    elseif player.onground then
        local vx, vy = player.body:getLinearVelocity()
        player.body:applyForce(-vx * forceMultiplier, -vy * forceMultiplier)
        player.hasMoved = false
    end

    -- Update the jump timer
    jumpTimer = math.max(0, jumpTimer - dt)

    -- Set animation based on jump direction
    if jumpTimer > 0 then
        if player.direction < 0 then
            player.anim = player.animations.jumpLeft
        elseif player.direction > 0 then
            player.anim = player.animations.jumpRight
        end
        -- Set animation based on walking direction
    elseif (love.keyboard.isDown("left") or love.keyboard.isDown("right")) and player.onground then
        if player.direction < 0 then
            player.anim = player.animations.walikingLeft
            sound.walking:play()
        elseif player.direction > 0 then
            player.anim = player.animations.walikingRight
            sound.walking:play()
        end
        -- Set idle animation
    else
        if player.direction < 0 then
            player.anim = player.animations.idleLeft
        elseif player.direction > 0 then
            player.anim = player.animations.idleRight
        end
    end

    -- Update the animation
    player.anim:update(dt)
end

-- Function to draw the player on the screen
function drawPlayer()
    player.anim:draw(player.spriteSheet, player.body:getX(), player.body:getY(), nil, 3, 3, 30, 45)
end

function keyPressed(key, cheat, wallJump, player, sound, canJump, released, leftWallJump, rightWallJump)
    -- Check if the space key is pressed and certain conditions are met
    if key == "space" and cheat == false and wallJump == false and player.onground then
        -- Check jump conditions and apply linear impulse if allowed
        local jumpForce = vector2.new(0, -player.jumpForce)
        player.body:applyLinearImpulse(jumpForce.x, jumpForce.y)
        sound.jump:play()
        jumpTimer = jumpTimerMax
    end

    if key == "space" and cheat == false and wallJump then
        -- Check for wall jump conditions and apply linear impulse accordingly
        if canJump and released and leftWallJump then
            local jumpForceY = -player.walljumpf
            local jumpForceX = 0
            jumpForceX = -1000
            player.body:applyLinearImpulse(jumpForceX, jumpForceY)
            player.direction = -1
        elseif canJump and released and rightWallJump then
            local jumpForceY = -player.walljumpf
            local jumpForceX = 0
            jumpForceX = 1000
            player.body:applyLinearImpulse(jumpForceX, jumpForceY)
            player.direction = 1
        end
        sound.jump:play()


        -- Limit the maximum velocity after applying the wall jump impulse
        local maxVelocityX = 800
        local maxVelocityY = 900
        local currentVelocityX, currentVelocityY = player.body:getLinearVelocity()

        -- Limiting the velocity in the x-direction
        if math.abs(currentVelocityX) > maxVelocityX then
            player.body:setLinearVelocity(maxVelocityX * math.sign(currentVelocityX), currentVelocityY)
        end

        -- Limiting the velocity in the y-direction
        if math.abs(currentVelocityY) > maxVelocityY then
            player.body:setLinearVelocity(currentVelocityX, maxVelocityY * math.sign(currentVelocityY))
        end

        -- Reset jump-related variables
        canJump = true
        released = false

        -- Makes so the animations can play
        jumpTimer = jumpTimerMax
    end
end
