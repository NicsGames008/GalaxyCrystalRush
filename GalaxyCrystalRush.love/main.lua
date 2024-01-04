local anim8 = require("libraries.anim8")
require "files/enemy"
require "files/player"
require "files/level"
require "files/light"
require "files/crystal"
require "files/mainMenu"
require "files/gamePlay"
require "screens"
require "logic"

local STATE_MAIN_MENU = 0
local STATE_GAMEPLAY = 1
local STATE_PAUSE = 2
local STATE_KILLED = 3
local STATE_WIN = 4
local state
local world
local playerX, playerY
local killed = false
local canJump = false
local cheat = false
local player
local grounds = {}
local walls = {}
local spikes = {}
local voids = {}
local enemyBarriers = {}
local barriers = {}
local crystals = {}
local lightCrystal = {}
local enemies = {}
local finishs = {}
local wallJump = false
local brightLevel = true
local lightPlayer
local jumpf = 1500
local cheatF = 1000
local walljumpf = 1500
local success = false
local sound = {}
local onCrystalPercentage = 1
local onCrystalCount = 0
local leftWallJump = false
local rightWallJump = false
local checkpointX, checkpointY

-- load 
function love.load()
    state = STATE_MAIN_MENU
    loadMainMenu()
    sound, world, lightPlayer, lightCrystal, player = loadGame()
end

-- update

function love.update(dt)
    state = updateState(state)

    if state == STATE_GAMEPLAY then 
        updateGame(dt)
    elseif state == STATE_PAUSE then
        updatePause(dt, player, lightPlayer, camera, crystals, lightCrystal)
    end
end

--draw
function love.draw()
    if state == STATE_MAIN_MENU then
        drawMainMenu()
        reset()
    end

    if state == STATE_PAUSE then
        drawGame()
        drawPauseMenu()
    end
    if state == STATE_GAMEPLAY then
        drawGame()
    end
end

-- Function called when a key is released
function love.keyreleased(key)
    -- Check if the released key is the spacebar
    if key == "space" then
        -- Set a variable 'released' to true
        released = true
    end
end

function love.keypressed(key)
    if state == STATE_GAMEPLAY then

        -- Check if the space key is pressed and certain conditions are met
        if key == "space" and cheat == false and wallJump == false and player.onground then
            -- Check jump conditions and apply linear impulse if allowed
            local jumpForce = vector2.new(0, -jumpf)
            player.body:applyLinearImpulse(jumpForce.x, jumpForce.y)
            player.anim = player.animations.idle
            sound.jump:play()
        end

        -- Check if the space key is pressed, cheats are disabled, and wallJump is enabled
        --The wall jump has a max velocity, so the player does not abuse wall jumping
        if key == "space" and cheat == false and wallJump then

            if canJump and released and leftWallJump then
                local jumpForceY = -walljumpf
                local jumpForceX = 0
                jumpForceX = -1000
                player.body:applyLinearImpulse(jumpForceX, jumpForceY)
            elseif canJump and released and rightWallJump then
                local jumpForceY = -walljumpf
                local jumpForceX = 0
                jumpForceX = 1000
                player.body:applyLinearImpulse(jumpForceX, jumpForceY)
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

            canJump = true
            released = false
        end

    end

    -----------------------------------------------------------------------------------------------------
    -- Cheats
    -----------------------------------------------------------------------------------------------------

    -- Toggle cheats on/off when the 'c' key is pressed
    if key == "c" then
        if cheat == false then
            object = "cheats on"
            cheat = true
        else
            cheat = false
        end
    end

    -- If cheats are enabled, apply a cheat jump when the space key is pressed
    if key == "space" and cheat then
        local jumpForce = vector2.new(0, -cheatF)
        player.onground = false
        player.body:applyLinearImpulse(jumpForce.x, jumpForce.y)
        sound.jump:play()
    end

    -- Toggle the brightLevel variable when the 'b' key is pressed
    if key == "b" then
        brightLevel = not brightLevel
    end

    -- Print the player's position when the 'z' key is pressed
    if key == "z" then
        print(player.body:getPosition())
    end

    if key == "escape" then 
        state = STATE_PAUSE
        text = tostring(state)

    end 
    if key == "r" then 
        reset()

    end
    if key == "p" then 
        toCheckpoint()
    end 
    ------------------------------------------------------------------------------------------------------------------------
end

-- All of our Collision logic

function BeginContact(fixtureA, fixtureB, contact)
    -- Check if the player collides with a spike and handle accordingly
    if fixtureA:getUserData().type == "spike" and fixtureB:getUserData().type == "player" then
        -- Check if cheats are disabled
        if cheat == false then
            -- Mark the player as killed
            killed = true
        end
    end

    -- Check if the player falls into a void and handle accordingly
    if fixtureA:getUserData().type == "void" and fixtureB:getUserData().type == "player" then
        -- Check if cheats are disabled
        if cheat == false then
            -- Mark the player as killed
            killed = true
        end
    end

    -- Check if the player collides with an enemy and handle accordingly
    if fixtureA:getUserData().type == "enemy" and fixtureB:getUserData().type == "player" then
        -- Check if cheats are disabled
        if cheat == false then
            -- Mark the player as killed
            killed = true
        end
    end
    if fixtureA:getUserData().type == "finish" and fixtureB:getUserData().type == "player" then
        killed = true
        success = true
    end

    -- Check if the player collides with a wall and handle accordingly
    if fixtureA:getUserData().type == "wall" and fixtureB:getUserData().type == "player" then
        -- Get the contact normal as a vector
        local normal = vector2.new(contact:getNormal())

        -- Check if the contact normal points towards the left (-1) or right (1)
        if normal.x == -1 then
            -- Collided with a wall from the left
            leftWallJump = true
            rightWallJump = false
        elseif normal.x == 1 then
            -- Collided with a wall from the right
            leftWallJump = false
            rightWallJump = true
        end

        -- Enable wall jumping and set related variables
        canWallJump = true
        wallJump = true
    end

    -- Check if the player collides with the ground and handle accordingly
    if fixtureA:getUserData().type == "ground" and fixtureB:getUserData().type == "player" then
        -- Get the contact normal as a vector
        local normal = vector2.new(contact:getNormal())

        -- Check if the contact normal points upward (indicating contact with the floor)
        if normal.y == -1 then
            -- Update player status for floor contact
            player.onground = true
            wallJump = false
            canJump = true
            canWallJump = true
        end
    end

    -- Check if the player collides with an offCrystal and handle accordingly
    if fixtureA:getUserData().type == "offCrystal" and fixtureB:getUserData().type == "player" and brightLevel then
        local light = lightCrystal[fixtureA:getUserData().index]
        light:Remove()

        -- Get the position of the crystal and create a light source
        xCrystal, yCrystal = crystals[fixtureA:getUserData().index].body:getPosition()
        light:Remove()
        lightCrystal[fixtureA:getUserData().index] = loadLight(2000, xCrystal, yCrystal)

        -- Recalculate the light world
	    --UpdateLightWorld()

        -- Change the type of the crystal to "onCrystal"
        fixtureA:getUserData().type = "onCrystal"

        onCrystalCount = onCrystalCount + 1

        onCrystalPercentage = math.floor((onCrystalCount / #lightCrystal) * 100)

        sound.crystalDing:play()
    end

    if fixtureA:getUserData().type == "offCrystal" and fixtureB:getUserData().type == "player" then
        local checkpointX,CheckpointY = fixtureA.getUserData().object:getPosition()       
    end

end

-- functions called when a contact ends
function EndContact(fixtureA, fixtureB, contact)
    -- Check if the player is in contact with a wall and handle accordingly
    if fixtureA:getUserData().type == "wall" and fixtureB:getUserData().type == "player" then
        -- Disable the ability to perform wall jumps
        canWallJump = false
        -- Reset the wallJump variable
        wallJump = false
    end
    if fixtureA:getUserData().type == "ground" and fixtureB:getUserData().type == "player" then
        player.onground = false
    end
end

-- Helper function to get the sign of a number
function math.sign(x)
    return x > 0 and 1 or x < 0 and -1 or 0
end

-- Function to check the distance between enemies and a crystal
function checkEnemyDistanceToCrystal(crystalX, crystalY)
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

-- function loadGame()
--      --state = STATE_GAMEPLAY
--     -- Set up window properties
--     love.window.setMode(1080, 900)
--     love.window.setFullscreen(true)
--     love.graphics.setDefaultFilter("nearest", "nearest")

--     -- Initialize camera with default parameters
--     camera = Camera(0, 0, 0, 0, 0.5)

--     -- Load map using Simple Tiled Implementation (STI) library with Box2D physics
--     map = sti("map/map.lua", { "box2d" })

--     -- Set up physics world using Box2D
--     love.physics.setMeter(64)
--     world = love.physics.newWorld(0, 20 * love.physics.getMeter(), true)
--     world:setCallbacks(BeginContact, EndContact, nil, nil)

--     -- Initialize Box2D physics for the map
--     map:box2d_init(world)

--     -- Add a custom layer for sprites to the map
--     map:addCustomLayer("Sprite Layer", 3)

--     sound.jump = love.audio.newSource("sounds/JumpSound_01.mp3", "static")
--     sound.walking = love.audio.newSource("sounds/waklingSound_01.mp3", "static")
--     sound.crystalDing = love.audio.newSource("sounds/crystalDing_01.mp3", "static")

--     -- Create player and load various game elements
--     player = createPlayer(world, anim8)
--     grounds = loadGround(world, grounds)
--     walls = loadWalls(world, walls)
--     spikes = loadSpikes(world, spikes)
--     voids = loadVoids(world, voids)
--     enemyBarriers, barriers = loadBarriers(world, enemyBarriers, barriers)
--     crystals, lightCrystal = loadCrystals(world, crystals, lightCrystal)
--     enemies = loadEnemies(world, enemies, anim8)
--     finishs = createFinish(world, finishs)

--     -- Get initial player position and set up light source
--     local playerX, playerY = player.body:getPosition()
--     local xLightPlayer, yLightPlayer = camera:toCameraCoords(playerX, playerY)
--     lightPlayer = loadLight(400, xLightPlayer, yLightPlayer)
-- end

function updateGame(dt)
    -- Update physics world and camera
    world:update(dt)
    camera:update(dt)

    -- Get player position and adjust camera to follow player with an offset
    local pX, pY = player.body:getPosition()
    camera:follow(pX - 900, pY - 1200)

    -- Iterate through enemies and update their movement if they are not killed
    enemyMove(dt, enemies, enemyBarriers)

    -- Update the player's position and handle collisions with ground and walls
    updatePlayer(dt, sound)

    updateBackground(dt, player)

    if brightLevel then    
        -- Update the light position for the player
        local xLightPlayer, yLightPlayer = camera:toCameraCoords(pX, pY)
        updateLight(dt, xLightPlayer, yLightPlayer, lightPlayer)

        -- Iterate through crystals, update their light positions, and check enemy distance to crystals
        for i = 1, #crystals, 1 do
            local xCrystal, yCrystal = crystals[i].body:getPosition()
            local xLightCrystal, yLightCrystal = camera:toCameraCoords(xCrystal, yCrystal)
            updateLight(dt, xLightCrystal, yLightCrystal, lightCrystal[i])
            
            -- Check if the crystal is of type "onCrystal" and update enemies accordingly
            if crystals[i].fixture:getUserData().type == "onCrystal" then
                checkEnemyDistanceToCrystal(xCrystal, yCrystal)
            end
        end
    end

    -- Remove killed enemies from the table and destroy their bodies
    for i, enemy in ipairs(enemies) do
        if enemy.killed then
            table.remove(enemies, i)
            enemy.body:destroy()
        end
    end

    updateLightWorld()
end

function drawGame()

    -- Check if the player is killed
    if killed then
        if success then 
            successScreen()
        else
        -- Display the killed screen
        killedScreen()
        end
    else
        drawBackground()

        -- Set up the camera view
        camera:attach()

        -- Set color to white and draw the Box2D physics objects from the map
        love.graphics.setColor(1, 1, 1)

        -- Draw the level layout
        drawLevel(map)

        -- Draw enemies on the screen
        drawEnemies(enemies)

        -- Draw the player at their current position
        drawPlayer(playerX, playerY)

        --drawBoost()

        --draw the finsih line
        drawFinish(finishs)

        -- If brightLevel is true, draw the lighting effects
        if brightLevel then
            local Width = love.graphics:getWidth()
            local Height = love.graphics:getHeight()
            drawLight(Width, Height)
        end

        -- Release the camera view
        camera:detach()

        -- Draw the camera view
        camera:draw()
        
        drawUI(onCrystalPercentage)
    end
end

function reset()
    for i, light in pairs(lightCrystal)do    
        light:Remove()
    end
    enemies = {}
    ground = {}
    killed = false
    object = "idk"
    jumpCount = 0
    released = true
    cheat = false
    grounds = {}
    walls = {}
    spikes = {}
    voids = {}
    wallJump = false
    brightLevel = true
    text = "false"
    lightCrystal = {}
    barriers ={}
    crystals = {}
    enemyBarriers =  {}
    jumpf = 1500
    cheatF = 1000
    walljumpf = 1500
    boosts = {}
    boostDuration = 3 
    boostMaxVelocity = 1000
    boostTimer = 0
    isBoostActive = false
    finishs= {}
    success = false
    leftWallJump = false
    rightWallJump = false
    checkpointX = -100
    checkpointY = -500
    onCrystalPercentage = 0
    world:destroy()


    world = love.physics.newWorld(0, 15 * 64, true)
    world:setCallbacks(BeginContact, EndContact, nil, nil)

    -- Initialize Box2D physics for the map
    map:box2d_init(world)

 

    -- Create player and load various game elements
    player = createPlayer(world, anim8)
    grounds = loadGround(world, grounds)
    walls = loadWalls(world, walls)
    spikes = loadSpikes(world, spikes)
    voids = loadVoids(world, voids)
    enemyBarriers, barriers = loadBarriers(world, enemyBarriers, barriers)
    crystals, lightCrystal = loadCrystals(world, crystals, lightCrystal)
    enemies = loadEnemies(world, enemies, anim8)
    finishs = createFinish(world, finishs)


    -- Get initial player position and set up light source
    player.body:setPosition(checkpointX,checkpointY)
    local playerX, playerY = player.body:getPosition()
    local xLightPlayer, yLightPlayer = camera:toCameraCoords(playerX, playerY)
    --lightPlayer = loadLight(400, xLightPlayer, yLightPlayer)

end

function toCheckpoint()
    enemies = {}
    ground = {}
    killed = false
    object = "idk"
    jumpCount = 0
    released = true
    cheat = false
    grounds = {}
    walls = {}
    spikes = {}
    voids = {}
    wallJump = false
    brightLevel = true
    text = "false"
    lightCrystal = {}
    barriers ={}
    crystals = {}
    enemyBarriers =  {}
    jumpf = 1500
    cheatF = 1000
    walljumpf = 1500
    boosts = {}
    boostDuration = 3 
    boostMaxVelocity = 1000
    boostTimer = 0
    isBoostActive = false
    finishs= {}
    success = false
    leftWallJump = false
    rightWallJump = false
    onCrystalPercentage = 0
    world:destroy()


    world = love.physics.newWorld(0, 15 * 64, true)
   world:setCallbacks(BeginContact, EndContact, nil, nil)

   -- Initialize Box2D physics for the map
   map:box2d_init(world)

    -- Create player and load various game elements
    player = createPlayer(world, anim8)
    grounds = loadGround(world, grounds)
    walls = loadWalls(world, walls)
    spikes = loadSpikes(world, spikes)
    voids = loadVoids(world, voids)
    enemyBarriers, barriers = loadBarriers(world, enemyBarriers, barriers)
    crystals, lightCrystal = loadCrystals(world, crystals, lightCrystal)
    enemies = loadEnemies(world, enemies, anim8)
    finishs = createFinish(world, finishs)

   -- Get initial player position and set up light source
   player.body:setPosition(checkpointX,checkpointY)
   local playerX, playerY = player.body:getPosition()
   local xLightPlayer, yLightPlayer = camera:toCameraCoords(playerX, playerY)
   lightPlayer = loadLight(400, xLightPlayer, yLightPlayer)

end

-- function updatePause(dt)
--     local pX, pY = player.body:getPosition()

--     local xLightPlayer, yLightPlayer = camera:toCameraCoords(pX, pY)
--     updateLight(dt, xLightPlayer, yLightPlayer, lightPlayer)

--     for i = 1, #crystals, 1 do
--         local xCrystal, yCrystal = crystals[i].body:getPosition()
--         local xLightCrystal, yLightCrystal = camera:toCameraCoords(xCrystal, yCrystal)
--         updateLight(dt, xLightCrystal, yLightCrystal, lightCrystal[i])
--     end

--     updateLightWorld()
-- end
