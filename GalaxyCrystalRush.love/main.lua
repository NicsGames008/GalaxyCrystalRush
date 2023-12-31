local sti = require"libraries/sti"
local Camera = require "libraries/Camera"
local anim8 = require("libraries.anim8")
require"files/enemy"
require"files/player"
require"files/level"
require "files/light"
require "files/crystal"
local STATE_MAIN_MENU = 0
local STATE_GAMEPLAY = 1
local STATE_PAUSE = 2
local STATE_KILLED = 3
local STATE_WIN = 4

local world
local player
local playerX, playerY
local killed = false
local canJump = false
local cheat = false
local cam
local enemies = {}
local grounds = {}
local walls = {}
local spikes = {}
local voids = {}
local barriers ={}
local crystals = {}
local wallJump = false
local brightLevel = true
local text = "false"
local lightPlayer
local lightCrystal = {}
local enemyBarriers =  {}
local jumpf = 1500
local cheatF = 1000
local walljumpf = 1500
local finishs= {}
local success = false
local sound = {}
local onCrystalpercentage = 0
local onCrystalCount = 0

-- load 
function love.load()
    -- Set up window properties
    love.window.setFullscreen(true)
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Initialize camera with default parameters
    camera = Camera(0, 0, 0, 0, 0.5)

    -- Load map using Simple Tiled Implementation (STI) library with Box2D physics
    map = sti("map/map.lua", { "box2d" })

    -- Set up physics world using Box2D
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 20 * love.physics.getMeter(), true)
    world:setCallbacks(BeginContact, EndContact, nil, nil)

    -- Initialize Box2D physics for the map
    map:box2d_init(world)

    -- Add a custom layer for sprites to the map
    map:addCustomLayer("Sprite Layer", 3)

    -- Set up camera coordinates
    cam = {}
    cam.x = 0
    cam.y = 0

    sound.jump = love.audio.newSource("sounds/JumpSound_01.mp3", "static")
    sound.walking = love.audio.newSource("sounds/waklingSound_01.mp3", "static")
    sound.crystalDing = love.audio.newSource("sounds/crystalDing_01.mp3", "static")

    -- Create player and load various game elements
    player = CreatePlayer(world, anim8)
    grounds = loadGround(world, grounds)
    walls = loadWalls(world, walls)
    spikes = loadSpikes(world, spikes)
    voids = loadVoids(world, voids)
    enemyBarriers, barriers = loadBarriers(world, enemyBarriers, barriers)
    crystals, lightCrystal = loadCrystals(world, crystals,  lightCrystal)
    enemies = loadEnemies(world, enemies, anim8)
    finishs = createFinish(world, finishs)


    -- Get initial player position and set up light source
    local playerX, playerY = player.body:getPosition()
    local xLightPlayer, yLightPlayer = camera:toCameraCoords(playerX, playerY)
    lightPlayer = loadLight(400, xLightPlayer, yLightPlayer)
end

-- update

function love.update(dt)
    -- Update physics world and camera
    world:update(dt)
    camera:update(dt)

    -- Get player position and adjust camera to follow player with an offset
    local pX, pY = player.body:getPosition()
    camera:follow(pX - 900, pY - 800)

    -- Update the map
    map:update(dt)

    -- Iterate through enemies and update their movement if they are not killed
    for i, enemy in ipairs(enemies) do
        if not enemy.killed then
            enemyMove(dt, enemies, enemyBarriers)
        end
    end

    -- Update the player's position and handle collisions with ground and walls
    UpdatePlayer(dt, sound, canJump)

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

    --Remove killed enemies from the table and destroy their bodies
    for i, enemy in ipairs(enemies) do
        if enemy.killed then
            table.remove(enemies, i)
            enemy.body:destroy()
        end
    end

    UpdateLightWorld()
end

--draw
function love.draw()
    -- Check if the player is killed
    if killed then
        if success then 
            successScreen()
        else
        -- Display the killed screen
        killedScreen()
        end
    else
        -- Set up the camera view
        camera:attach()

        -- Set color to white and draw the Box2D physics objects from the map
        love.graphics.setColor(1, 1, 1)
        map:box2d_draw()

        -- Draw the level layout
        DrawLevel(map)

        -- Draw enemies on the screen
        drawEnemies(enemies)

        -- Convert text to string and display it on the screen
        object = tostring(text)
        love.graphics.print(object, 0, 0)

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

        drawUI()
        
        -- Draw the camera view
        --camera:draw()
    end
end

function love.keypressed(key)
    -- Check if the space key is pressed and certain conditions are met
    if key == "space" and cheat == false and wallJump == false and canJump then
        -- Check jump conditions and apply linear impulse if allowed
        local jumpForce = vector2.new(0, -jumpf)
        player.body:applyLinearImpulse(jumpForce.x, jumpForce.y)
        player.onground = false
        canJump = false
        sound.jump:play()
    end

    -- Check if the space key is pressed, cheats are disabled, and wallJump is enabled
    --The wall jump has a max velocity, so the player does not abuse wall jumping 
    if key == "space" and cheat == false and wallJump then
        local jumpForceY = -walljumpf
        local jumpForceX = 0

        -- Adjust horizontal jump force based on arrow key input
        if love.keyboard.isDown("left") then
            jumpForceX = 1000
        elseif love.keyboard.isDown("right") then
            jumpForceX = -1000
        end

        player.body:applyLinearImpulse(jumpForceX, jumpForceY)
        
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

        canJump = false

        sound.jump:play()

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
        canJump = false
        player.onground = false
        player.body:applyLinearImpulse(jumpForce.x, jumpForce.y)
        sound.jump:play()
    end

    -- Toggle the brightLevel variable when the 'b' key is pressed
    if key == "b" then
        brightLevel = not brightLevel
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
        -- Enable wall jumping and set related variables
        canWallJump = true
        wallJump = true
        player.onground = false
    end

    -- Check if the player collides with the ground and handle accordingly
    if fixtureA:getUserData().type == "ground" and fixtureB:getUserData().type == "player" then
        -- Print a message for debugging

        -- Get the contact normal as a vector
        local normal = vector2.new(contact:getNormal())

        -- Set text indicating the player is on the floor

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
        lightCrystal[fixtureA:getUserData().index] = loadLight(2000, xCrystal, yCrystal)

        -- Change the type of the crystal to "onCrystal"
        fixtureA:getUserData().type = "onCrystal"

        onCrystalCount = onCrystalCount + 1

        onCrystalpercentage = math.floor((onCrystalCount / #lightCrystal)*100)

        sound.crystalDing:play()
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

function drawUI()
    love.graphics.setColor(1, 1, 1)
    local crystalImg = love.graphics.newImage("sprites/crystals/CrystalFrames1.png")
    if onCrystalpercentage >= 10 and onCrystalpercentage < 19 then
        crystalImg = love.graphics.newImage("sprites/crystals/CrystalFrames2.png")
    elseif onCrystalpercentage >= 20 and onCrystalpercentage < 29 then
        crystalImg = love.graphics.newImage("sprites/crystals/CrystalFrames3.png")   
    elseif onCrystalpercentage >= 30 and onCrystalpercentage < 39 then
        crystalImg = love.graphics.newImage("sprites/crystals/CrystalFrames4.png")            
    elseif onCrystalpercentage >= 40 and onCrystalpercentage < 49 then
        crystalImg = love.graphics.newImage("sprites/crystals/CrystalFrames5.png")            
    elseif onCrystalpercentage >= 50 and onCrystalpercentage < 59 then
        crystalImg = love.graphics.newImage("sprites/crystals/CrystalFrames6.png")            
    elseif onCrystalpercentage >= 60 and onCrystalpercentage < 69 then
        crystalImg = love.graphics.newImage("sprites/crystals/CrystalFrames7.png")            
    elseif onCrystalpercentage >= 70 and onCrystalpercentage < 74 then
        crystalImg = love.graphics.newImage("sprites/crystals/CrystalFrames8.png")            
    elseif onCrystalpercentage >= 75 and onCrystalpercentage < 93 then
        crystalImg = love.graphics.newImage("sprites/crystals/CrystalFrames9.png")
    elseif onCrystalpercentage >= 100 and onCrystalpercentage < 1000 then
        crystalImg = love.graphics.newImage("sprites/crystals/CrystalFrames10.png")
    end
    love.graphics.draw(crystalImg, 1750, 15, nil, 2.5, 2.5)
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