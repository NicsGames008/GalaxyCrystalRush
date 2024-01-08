require "source/vector2"

-- Function to load enemies into the game world
function loadEnemies(world, enemies, anim8)
    -- Check if the 'Enemy' layer exists in the map
    if map.layers['Enemy'] then
        -- Iterate over each enemy object in the 'Enemy' layer
        for i, obj in pairs(map.layers['Enemy'].objects) do
            -- Create a new enemy object
            local enemy = {}

            -- Check if the shape of the enemy is a rectangle
            if obj.shape == "rectangle" then
                -- Load enemy sprite
                enemy.sprite = love.graphics.newImage("map/Enemy tiled.png")

                -- Create a physics body for the enemy at the center of its position
                enemy.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")

                -- Create a rectangle shape for the enemy based on its sprite dimensions
                enemy.shape = love.physics.newRectangleShape(enemy.sprite:getWidth() - 100, enemy.sprite:getHeight() - 50)

                -- Create a fixture for the enemy's physics body
                enemy.fixture = love.physics.newFixture(enemy.body, enemy.shape, 1)

                -- Set the fixture as a sensor to detect collisions without physical responses
                enemy.fixture:setSensor(true)

                -- Set user data for the fixture to store information about the enemy
                enemy.fixture:setUserData({
                    object = enemy,
                    type = "enemy",
                    index = i,
                    x = obj.x + obj.width / 2,
                    y = obj.y + obj.height / 2
                })

                -- Set initial state for enemy
                enemy.killed = false

                -- Load enemy sprite sheet and create animations
                enemy.spriteSheet = love.graphics.newImage("sprites/EnemyShpiteSheet.png")
                enemy.gird = anim8.newGrid(64, 64, enemy.spriteSheet:getWidth(), enemy.spriteSheet:getHeight())
                enemy.animations = {}
                enemy.animations.walkRight = anim8.newAnimation(enemy.gird('1-2', 1), 0.3)
                enemy.animations.walkLeft = anim8.newAnimation(enemy.gird('1-2', 2), 0.3)

                -- Set the initial animation for the enemy
                enemy.anim = enemy.animations.walkRight

                -- Add the enemy to the 'enemies' table
                table.insert(enemies, enemy)
            end
        end

        -- Return the updated 'enemies' table
        return enemies
    end
end

-- Function to draw enemies on the screen
function drawEnemies(enemies)
    -- Set the drawing color to white
    love.graphics.setColor(1, 1, 1, 1)

    -- Iterate over each enemy in the 'enemies' table
    for _, enemy in ipairs(enemies) do
        -- Check if the enemy is not killed
        if not enemy.killed then
            -- Draw the current animation frame of the enemy at its position
            enemy.anim:draw(
                enemy.spriteSheet, -- Sprite sheet for the enemy
                enemy.body:getX(), -- X coordinate of the enemy's position
                enemy.body:getY(), -- Y coordinate of the enemy's position
                nil,               -- Rotation angle (nil means no rotation)
                3,                 -- Scale factor for the x-axis
                3,                 -- Scale factor for the y-axis
                30,                -- X offset for the drawing position
                40                 -- Y offset for the drawing position
            )
        end
    end
end

-- Function to handle enemy movement
function enemyMove(dt, enemies, enemyBarriers)
    -- Iterate over each enemy in the 'enemies' table
    for _, enemy in ipairs(enemies) do
        -- Check if the enemy is not killed
        if not enemy.killed then
            -- Initialize enemy speed if not set
            if not enemy.speed then
                enemy.speed = 100
            end

            -- Get current position of the enemy
            local enemyX, enemyY = enemy.body:getPosition()

            -- Calculate the next X position based on speed and time (dt)
            local nextX = enemyX + (enemy.speed * dt)

            -- Check for collisions with barriers
            local hitBarrier = false
            for _, barrier in ipairs(enemyBarriers) do
                local barrierX = barrier.body:getX()
                local barrierWidth = barrier.fixture:getUserData().width

                -- Check if the next X position collides with a barrier
                if nextX + enemy.shape:getRadius() > barrierX - barrierWidth / 2 and
                    nextX - enemy.shape:getRadius() < barrierX + barrierWidth / 2 then
                    hitBarrier = true
                    break
                end
            end

            -- Update enemy position or reverse direction if hitting a barrier
            if not hitBarrier then
                enemy.body:setX(nextX)
            else
                enemy.speed = -enemy.speed
            end

            -- Set the appropriate animation based on the direction of movement
            if enemy.speed < 0 then
                enemy.anim = enemy.animations.walkLeft
            else
                enemy.anim = enemy.animations.walkRight
            end

            -- Update the animation based on time
            enemy.anim:update(dt)
        end
    end
end

-- Function to check the distance between enemies and a crystal
function checkEnemyDistanceToCrystal(crystalX, crystalY, enemies)
    -- Create a vector representing the position of the crystal
    local crystalPosition = vector2.new(crystalX, crystalY)

    -- Iterate through each enemy in the 'enemies' table
    for _, enemy in ipairs(enemies) do
        -- Get the position of the current enemy
        local enemyPosition = vector2.new(enemy.body:getX(), enemy.body:getY())

        -- Calculate the vector between the crystal and the enemy
        local distanceVector = vector2.sub(crystalPosition, enemyPosition)

        -- Calculate the distance between the crystal and the enemy
        local distance = vector2.magnitude(distanceVector)

        -- Check if the distance is within a certain range (20000 units in this case)
        if distance <= 2500 then
            -- Mark the enemy as killed
            enemy.killed = true
        end
    end
end
