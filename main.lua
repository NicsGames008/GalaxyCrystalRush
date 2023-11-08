local world
local player
local ground
local background
local playerX
local playerY
local playerVisible
local groundVisible
require "vector2"
require "graphicsLoader"
function love.load()
    background = love.graphics.newImage("Images/background.jpg")
    createElements()
    playerX = 0
    playerY = 0
    local canJump = true;

end

function love.update(dt)

    world:update(dt) -- Aktualisiere die Physik-Welt



    -- Spielersteuerung
    if love.keyboard.isDown("left") then
        player.body:applyForce(-player.speed, 0)
    elseif love.keyboard.isDown("right") then
        player.body:applyForce(player.speed, 0)
    end

    -- Springen, wenn der Spieler auf dem Boden ist
    if love.keyboard.isDown("space") and canJump then
        player.body:applyForce(0, player.jumpForce)
        canJump = false -- Prevent jumping until the spacebar is released and pressed again
    end

    if player.body:isTouching(ground.body) then
        canJump = true
    end
    
end

function love.draw()
    drawBackground()
    drawPlayer(playerX,playerY)
    drawGround(400,400)

end



function createElements()
    love.physics.setMeter(64) 
    world = love.physics.newWorld(0, 9.81 * 64, true) 
    player = {}
    player.body = love.physics.newBody(world, 100, 100, "dynamic")
    player.shape = love.physics.newCircleShape(20) -- Radius von 20 Pixel
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.body:setFixedRotation(true) -- Verhindere Drehung
    player.speed = 200 -- Horizontale Geschwindigkeit
    player.jumpForce = -2000 -- Sprungkraft

    -- Erstelle den Boden (Rechteck)
    ground = {}
    ground.body = love.physics.newBody(world, 400, 300, "static")
    ground.shape = love.physics.newRectangleShape(800, 10) -- Breite von 800 und Höhe von 10 Pixel
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)

end


function drawGround(x,y)
    love.graphics.setColor(0.008, 0.6, 0.012)
    love.graphics.rectangle("fill",x,y,1000,150)
    
end
function drawPlayer(x,y)
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", player.body:getX(), player.body:getY(), player.shape:getRadius())
    
end

function drawBackground()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))
end

function createGround(x, y)
    ground = {}
    ground.body = love.physics.newBody(world, x, y, "static")
    ground.shape = love.physics.newRectangleShape(800, 10)  -- Customize width and height as needed
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)
    return ground
end
