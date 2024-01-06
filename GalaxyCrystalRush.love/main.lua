local anim8 = require("libraries.anim8")
require "files/enemy"
require "files/player"
require "files/level"
require "files/light"
require "files/crystal"
require "files/mainMenu"
require "files/gamePlay"

local STATE_MAIN_MENU = 0
local STATE_GAMEPLAY = 1
local STATE_PAUSE = 2
local STATE_KILLED = 3
local STATE_WIN = 4
local state
local world
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
local cheatF = 1000
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
    sound, world, lightPlayer, lightCrystal, player, crystals = loadGame()
end

-- update

function love.update(dt)
    state = updateState(state)

    if state == STATE_GAMEPLAY then 
        updateGame(dt, world, player, enemies, crystals, enemyBarriers, camera, lightPlayer, lightCrystal,brightLevel)
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
        drawGame(killed, success, enemies, finishs, brightLevel, onCrystalPercentage)
        drawPauseMenu()
    end
    if state == STATE_GAMEPLAY then
        drawGame(killed, success, enemies, finishs, brightLevel, onCrystalPercentage)
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
        keyPressed(key, cheat, wallJump, player, sound, canJump, released, leftWallJump, rightWallJump)
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

    if key == "escape" and  state == STATE_GAMEPLAY then 
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

        -- Change the type of the crystal to "onCrystal"
        fixtureA:getUserData().type = "onCrystal"

        onCrystalCount = onCrystalCount + 1

        onCrystalPercentage = math.floor((onCrystalCount / #lightCrystal) * 100)

        sound.crystalDing:play()
    end

    -- if fixtureA:getUserData().type == "offCrystal" and fixtureB:getUserData().type == "player" then

    --     local checkpointX = fixtureA:getUserData().body:getX()   
    --     local checkpointY = fixtureA:getUserData().body:getY()   
    -- end


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

function reset()
    for i, light in pairs(lightCrystal)do    
        light:Remove()
    end
    --resets all the variables
    enemies = {}
    ground = {}
    killed = false
    released = true
    cheat = false
    grounds = {}
    walls = {}
    spikes = {}
    voids = {}
    brightLevel = true
    lightCrystal = {}
    barriers ={}
    crystals = {}
    enemyBarriers =  {}
    cheatF = 1000
    finishs= {}
    success = false
    checkpointX = -100
    checkpointY = -500
    onCrystalPercentage = 0
    onCrystalCount = 0 
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
end

-- function toCheckpoint()
--     enemies = {}
--     ground = {}
--     killed = false
--     object = "idk"
--     jumpCount = 0
--     released = true
--     cheat = false
--     grounds = {}
--     walls = {}
--     spikes = {}
--     voids = {}
--     wallJump = false
--     brightLevel = true
--     text = "false"
--     lightCrystal = {}
--     barriers ={}
--     crystals = {}
--     enemyBarriers =  {}
--     jumpf = 1500
--     cheatF = 1000
--     walljumpf = 1500
--     boosts = {}
--     boostDuration = 3 
--     boostMaxVelocity = 1000
--     boostTimer = 0
--     isBoostActive = false
--     finishs= {}
--     success = false
--     leftWallJump = false
--     rightWallJump = false
--     onCrystalPercentage = 0
--     world:destroy()


--     world = love.physics.newWorld(0, 15 * 64, true)
--    world:setCallbacks(BeginContact, EndContact, nil, nil)

--    -- Initialize Box2D physics for the map
--    map:box2d_init(world)

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

--    -- Get initial player position and set up light source
--    player.body:setPosition(checkpointX,checkpointY)
--    local playerX, playerY = player.body:getPosition()
--    local xLightPlayer, yLightPlayer = camera:toCameraCoords(playerX, playerY)
--    lightPlayer = loadLight(400, xLightPlayer, yLightPlayer)

-- end