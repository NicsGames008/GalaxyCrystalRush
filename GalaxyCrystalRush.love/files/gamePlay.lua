require "files/light"
require "files/crystal"
local anim8 = require("libraries.anim8")
local sti = require "libraries/sti"
local Camera = require "libraries/Camera"
local sound = {}
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
local Width = love.graphics:getWidth()
local Height = love.graphics:getHeight()


function loadGame()
    --state = STATE_GAMEPLAY
   -- Set up window properties
   love.window.setMode(1080, 900)
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

   sound.jump = love.audio.newSource("sounds/JumpSound_01.mp3", "static")
   sound.walking = love.audio.newSource("sounds/waklingSound_01.mp3", "static")
   sound.crystalDing = love.audio.newSource("sounds/crystalDing_01.mp3", "static")

   -- Create player and load various game elements
   player = createPlayer(world, anim8)
   grounds = loadGround(world, grounds)
   walls = loadWalls(world, walls)
   spikes = loadSpikes(world, spikes)
   enemyBarriers, barriers = loadBarriers(world, enemyBarriers, barriers)
   crystals, lightCrystal = loadCrystals(world, crystals, lightCrystal)
   enemies = loadEnemies(world, enemies, anim8)
   finishs = createFinish(world, finishs)

   -- Get initial player position and set up light source
   local playerX, playerY = player.body:getPosition()
   local xLightPlayer, yLightPlayer = camera:toCameraCoords(playerX, playerY)
   lightPlayer = loadLight(400, xLightPlayer, yLightPlayer)
   music = love.audio.newSource("sounds/sound.mp3", "stream")


    -- Play the music in a loop
    music:setLooping(true)
    love.audio.play(music)

   return sound, world, lightPlayer, lightCrystal, player, crystals
end

function updateGame(dt, world, player, enemies, crystals, enemyBarriers, camera, lightPlayer, lightCrystal,brightLevel)
    -- Update physics world and camera
    world:update(dt)
    camera:update(dt)

    -- Get player position and adjust camera to follow player with an offset
    local pX, pY = player.body:getPosition()
    camera:follow(pX - 900, pY - 1400)

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
                checkEnemyDistanceToCrystal(xCrystal, yCrystal, enemies)
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

function drawGame(killed, success, crystals, enemies, finishs, brightLevel,onCrystalPercentage)

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

        drawCrystals(crystals)

        -- Draw enemies on the screen
        drawEnemies(enemies)

        -- Draw the player at their current position
        drawPlayer()

        --draw the finsih line
        drawFinish(finishs)

        -- If brightLevel is true, draw the lighting effects
        if brightLevel then
            drawLight(Width, Height)
        end

        -- Release the camera view
        camera:detach()

        -- Draw the camera view
        camera:draw()
        
        --call the funciton that draws the UI
        drawUI(onCrystalPercentage)
    end
end

-- Function to update game elements during pause
function updatePause(dt, player, lightPlayer, camera, crystals, lightCrystal)
    -- Get the current position of the player
    local pX, pY = player.body:getPosition()

    -- Convert player's position to camera coordinates
    local xLightPlayer, yLightPlayer = camera:toCameraCoords(pX, pY)
    
    -- Update the player's light source based on the camera coordinates
    updateLight(dt, xLightPlayer, yLightPlayer, lightPlayer)

    -- Iterate over each crystal in the 'crystals' table
    for i = 1, #crystals, 1 do
        -- Get the position of the current crystal
        local xCrystal, yCrystal = crystals[i].body:getPosition()
        
        -- Convert crystal's position to camera coordinates
        local xLightCrystal, yLightCrystal = camera:toCameraCoords(xCrystal, yCrystal)
        
        -- Update the light source for the current crystal based on camera coordinates
        updateLight(dt, xLightCrystal, yLightCrystal, lightCrystal[i])
    end
    
    -- Update the global light source in the game world
    updateLightWorld()
end

