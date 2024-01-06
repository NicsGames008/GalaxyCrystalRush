require "files/vector2"

local ground
local wall
local spike
local void
local enemyBarrier
local barrier
local finish
local image = love.graphics.newImage("sprites/rock-6.png")
local backgroundX = 0
local backgroundSpeed = 20

-- Draw the layers from tiled
function drawLevel(map)
    map:drawLayer(map.layers["Map"])
    map:drawLayer(map.layers["Crystals"])
    map:drawLayer(map.layers["Backvoid"])
    map:drawLayer(map.layers["Void"])

end

function drawBackground()
    -- Draw background
    love.graphics.draw(image, backgroundX, 0, nil, 1.3, 1.3)
end

function updateBackground(dt, player)
    -- Background movement
    if player.hasMoved then
        backgroundX = backgroundX - player.direction * backgroundSpeed * dt
    end
end

function drawUI(onCrystalPercentage)
    -- Load the crystal frames image
    local crystalFramesImage = love.graphics.newImage("sprites/CrystalFrames.png")

    -- Create an array (table) to store quads for crystal frames
    local crystalQuads = {}

    -- Calculate the number of quads in each row and column
    local rows = crystalFramesImage:getHeight() / 32
    local columns = crystalFramesImage:getWidth() / 64

    -- Populate the quads array
    for row = 1, rows do
        for col = 1, columns do
            local quad = love.graphics.newQuad((col - 1) * 64, (row - 1) * 32, 64, 32, crystalFramesImage:getDimensions())
            table.insert(crystalQuads, quad)
        end
    end

    -- Makes the inicial frame to the 0%
    local currentCrystalFrame = 1

    if onCrystalPercentage >= 10 and onCrystalPercentage < 19 then
        currentCrystalFrame = 2
    elseif onCrystalPercentage >= 20 and onCrystalPercentage < 29 then
        currentCrystalFrame = 3
    elseif onCrystalPercentage >= 30 and onCrystalPercentage < 39 then
        currentCrystalFrame = 4
    elseif onCrystalPercentage >= 40 and onCrystalPercentage < 49 then
        currentCrystalFrame = 5
    elseif onCrystalPercentage >= 50 and onCrystalPercentage < 59 then
        currentCrystalFrame = 6
    elseif onCrystalPercentage >= 60 and onCrystalPercentage < 69 then
        currentCrystalFrame = 7
    elseif onCrystalPercentage >= 70 and onCrystalPercentage < 74 then
        currentCrystalFrame = 8
    elseif onCrystalPercentage >= 75 and onCrystalPercentage < 93 then
        currentCrystalFrame = 9
    elseif onCrystalPercentage >= 100 and onCrystalPercentage < 1000 then
        currentCrystalFrame = 10
    end

    -- Calculate the X-coordinate for drawing at the top-right corner + a 15 px offsite
    local windowWidth = love.graphics.getWidth()
    local imageWidth = 175
    local x = windowWidth - imageWidth

    -- Set color to white (no tint)
    love.graphics.setColor(1, 1, 1)
    -- Draw the selected crystal frame scaled at the top-right corner
    love.graphics.draw(crystalFramesImage, crystalQuads[currentCrystalFrame], x, 15, nil, 2.5, 2.5)
end

-- Load ground layer
function loadGround(world, grounds)
    if map.layers['Ground'] then
        for i, obj in pairs(map.layers['Ground'].objects) do
            ground = {}

            if obj.shape == "rectangle" then
                ground.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                ground.shape = love.physics.newRectangleShape(obj.width, obj.height)
                ground.fixture = love.physics.newFixture(ground.body, ground.shape, 1)
                ground.fixture:setUserData(({ object = ground, type = "ground", index = i }))

                table.insert(grounds, ground)
            end
        end
        return grounds
    end
end

-- Load wall layer
function loadWalls(world, walls)
    if map.layers['Walls'] then
        for i, obj in pairs(map.layers['Walls'].objects) do
            wall = {}

            if obj.shape == "rectangle" then
                wall.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                wall.shape = love.physics.newRectangleShape(obj.width, obj.height)
                wall.fixture = love.physics.newFixture(wall.body, wall.shape, 1)
                wall.fixture:setUserData(({ object = wall, type = "wall", index = i }))

                table.insert(walls, wall)
            end

            if obj.shape == "polygon" then
                local vertices = {}

                for _, point in ipairs(obj.polygon) do
                    table.insert(vertices, point.x - obj.x)
                    table.insert(vertices, point.y - obj.y)
                end

                walls.body = love.physics.newBody(world, obj.x, obj.y, "static")
                walls.shape = love.physics.newPolygonShape(unpack(vertices))
                walls.fixture = love.physics.newFixture(walls.body, walls.shape, 1)
                table.insert(walls, wall)
            end

            if obj.shape == "ellipse" then
                walls.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")

                walls.shape = love.physics.newCircleShape(obj.width / 2)
                walls.fixture = love.physics.newFixture(walls.body, walls.shape, 1)
                table.insert(walls, wall)
            end
        end

        return walls
    end
end

-- Load spike layer
function loadSpikes(world, spikes)
    if map.layers['Death'] then
        for i, obj in pairs(map.layers['Death'].objects) do
            spike = {}

            if obj.shape == "rectangle" then
                spike.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                spike.shape = love.physics.newRectangleShape(obj.width, obj.height)
                spike.fixture = love.physics.newFixture(spike.body, spike.shape, 1)
                spike.fixture:setUserData(({ object = spike, type = "spike", index = i }))

                table.insert(spikes, spike)
            end
        end

        return spikes
    end
end

-- Load void layer
function loadVoids(world, voids)
    if map.layers['Portal'] then
        for i, obj in pairs(map.layers['Portal'].objects) do
            void = {}
            if obj.shape == "rectangle" then
                void.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                void.shape = love.physics.newRectangleShape(obj.width, obj.height)
                void.fixture = love.physics.newFixture(void.body, void.shape, 1)
                void.fixture:setUserData(({ object = void, type = "void", index = i }))

                table.insert(voids, void)
            end
        end

        return voids
    end
end

-- Load barrier layer
function loadBarriers(world, enemyBarriers, barriers)
    if map.layers['EnemyWall'] then
        for i, obj in pairs(map.layers['EnemyWall'].objects) do
            enemyBarrier = {}

            if obj.shape == "rectangle" then
                enemyBarrier.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                enemyBarrier.shape = love.physics.newRectangleShape(obj.width, obj.height)
                enemyBarrier.fixture = love.physics.newFixture(enemyBarrier.body, enemyBarrier.shape, 1)
                enemyBarrier.fixture:setSensor(true)
                enemyBarrier.fixture:setUserData(({ object = enemyBarrier, type = "enemyBarrier", index = i, width = obj.width }))

                table.insert(enemyBarriers, enemyBarrier)
            end
        end
    end

    -- Load wall jump cancel layer
    if map.layers['Wall jump cancel'] then
        for i, obj in pairs(map.layers['Wall jump cancel'].objects) do
            barrier = {}



            if obj.shape == "rectangle" then
                barrier.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                barrier.shape = love.physics.newRectangleShape(obj.width, obj.height)
                barrier.fixture = love.physics.newFixture(barrier.body, barrier.shape, 1)
                barrier.fixture:setUserData(({ object = barrier, type = "barrier", index = i }))

                table.insert(barriers, barrier)
            end
        end
    end
    return enemyBarriers, barriers
end

function createFinish(world, finishs)
    finish = {}

    finish.body = love.physics.newBody(world, 37500, -1820, "static")
    finish.shape = love.physics.newRectangleShape(30, 300)
    finish.fixture = love.physics.newFixture(finish.body, finish.shape, 1)
    finish.fixture:setUserData(({ object = finish, type = "finish" }))
    table.insert(finishs, finish)

    return finishs
end

function drawFinish(finishs)
    love.graphics.setColor(1, 0, 0)
    for _, finish in ipairs(finishs) do
        love.graphics.polygon("fill", finish.body:getWorldPoints(finish.shape:getPoints()))
    end
end

-- Function to display the "Game Over" screen
function killedScreen()
    -- Get the width and height of the screen
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()

    -- Calculate the middle position for text placement
    middleX = screenWidth / 2 - 50
    middleY = screenHeight / 2

    -- Set the text color to white and display "Game Over!" at the calculated position
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Game over!", middleX, middleY)
end

function successScreen()
    -- Get the width and height of the screen
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()

    -- Calculate the middle position for text placement
    middleX = screenWidth / 2 - 50
    middleY = screenHeight / 2

    -- Set the text color to white and display "Game Over!" at the calculated position
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("You won!", middleX, middleY)
end
