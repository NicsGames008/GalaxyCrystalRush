require "files/light"
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
   voids = loadVoids(world, voids)
   enemyBarriers, barriers = loadBarriers(world, enemyBarriers, barriers)
   crystals, lightCrystal = loadCrystals(world, crystals, lightCrystal)
   enemies = loadEnemies(world, enemies, anim8)
   finishs = createFinish(world, finishs)

   -- Get initial player position and set up light source
   local playerX, playerY = player.body:getPosition()
   local xLightPlayer, yLightPlayer = camera:toCameraCoords(playerX, playerY)
   lightPlayer = loadLight(400, xLightPlayer, yLightPlayer)

   return sound, world, lightPlayer, lightCrystal, player
end


function updatePause(dt, player, lightPlayer, camera, crystals, lightCrystal)
    local pX, pY = player.body:getPosition()

    local xLightPlayer, yLightPlayer = camera:toCameraCoords(pX, pY)
    updateLight(dt, xLightPlayer, yLightPlayer, lightPlayer)

    for i = 1, #crystals, 1 do
        local xCrystal, yCrystal = crystals[i].body:getPosition()
        local xLightCrystal, yLightCrystal = camera:toCameraCoords(xCrystal, yCrystal)
        updateLight(dt, xLightCrystal, yLightCrystal, lightCrystal[i])
    end
    
    updateLightWorld()
end