local world
local player
local ground
local background
local playerX
local playerY
local playerVisible
local groundVisible
local touchingWall
local enemyX = 300
local enemyY = 280
local canWallJump =true
local turn = false
local killed = false
local object = "idk"
local jumpCount = 0
local released = true
local canJump = true;
local objects = {}
local grounds = {}
local enemies = {}
local walls = {}
local blocks = {}
local solids = {}
local spikes = {}



local enemy
require "vector2"


--- LOAD








function love.load()
    love.window.setMode(1024, 768)
    love.physics.setMeter(64) 
    world = love.physics.newWorld(0, 9.81 * 64, true) 
    world:setCallbacks(BeginContact, EndContact, nil, nil)

    ground = createGround(400, 300, 200, 10)
    wall = createWall(200, 200, 10, 200)
    player = createPlayer()
    enemy = createEnemy(400, 275, 50, 50)

    table.insert(grounds, createGround(70, 750, 150, 75))
    table.insert(grounds, createGround(300, 680, 100, 50))
    table.insert(grounds, createGround(500, 500, 250, 650))


    table.insert(solids, createSolids(50, 550))
    table.insert(solids, createSolids(320, 520))
    table.insert(solids, createSolids(150, 480))
    table.insert(solids, createSolids(30, 420))
    table.insert(solids, createSolids(100, 300))
    table.insert(solids, createSolids(280, 200))

    table.insert(solids, createSolids(600, 180))
    table.insert(solids, createSolids(660, 180))
    table.insert(solids, createSolids(750, 180))


    table.insert(solids, createSolids(950, 300))
    table.insert(solids, createSolids(850, 300))
    table.insert(solids, createSolids(750, 300))

    table.insert(solids, createSolids(650, 450))

    table.insert(solids, createSolids(850, 550))
    table.insert(solids, createSolids(950, 550))


    table.insert(solids, createSolids(750, 680))


    table.insert(solids, createSolids(950, 730))






    -- First jumping platform
    table.insert(solids, createSolids(0, 0))

    -- Higher platform with an enemy
    table.insert(enemies, createEnemy(0, 0, 50, 50))

    -- Tower of blocks to climb
    table.insert(blocks, createBlocks(0, 0))

    -- Top platform with spikes
    table.insert(spikes, createSpikes(0, 0))

  

   

end




-- UPDATE








function love.update(dt)

    world:update(dt) -- Aktualisiere die Physik-Welt



    -- Spielersteuerung
    if love.keyboard.isDown("left") then
        player.body:applyForce(-player.speed, 0)
    elseif love.keyboard.isDown("right") then
        player.body:applyForce(player.speed, 0)
    end



    local playerX, playerY = player.body:getPosition()
    
    if playerX < 0 or playerX > love.graphics.getWidth() or playerY < 0 or playerY > love.graphics.getHeight() then
        player.body:setPosition(0, 0)
    end


    if player.body:isTouching(ground.body) and released then
        object = "ground"
        canJump = true
        jumpCount = 0
        canWallJump = true
    end

    if player.body:isTouching(wall.body) and released then
        object = "ground"
        canJump = true
        jumpCount = 0
        canWallJump = true
    end

    enemyMove(dt)

            
end






---- DRAW ----







function love.draw()
    if killed then 
        killedScreen()
    else
    drawBackground()
    drawWall()
    drawPlayer()
    drawGround(grounds)
    drawEnemy(enemies)
    love.graphics.print(object,0,0)
    drawBlocks(blocks)
    drawSolids(solids)
    drawSpikes(spikes)
    end
end





function drawGround(grounds)
    love.graphics.setColor(0.008, 0.6, 0.012)
    for index, value in ipairs(grounds) do
        love.graphics.polygon("fill", value.body:getWorldPoints(value.shape:getPoints()))
        love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))

    end
    
    
end
function drawPlayer()
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", player.body:getX(), player.body:getY(), player.shape:getRadius())
    
end

function drawBackground()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
end

function drawWall()
    love.graphics.setColor(0.5, 0.5, 0.5)  -- Set a color for the wall
    love.graphics.polygon("fill", wall.body:getWorldPoints(wall.shape:getPoints()))
end


function drawEnemy(enemies)
    love.graphics.setColor(1,0,0)
    for index, value in ipairs(enemies) do
    love.graphics.polygon("fill",value.body:getWorldPoints(value.shape:getPoints()))
    end
    love.graphics.polygon("fill",enemy.body:getWorldPoints(enemy.shape:getPoints()))

end

function drawBlocks(blocks)
    love.graphics.setColor(1,1,0.5 )
    for index, value in ipairs(blocks) do
    love.graphics.polygon("fill",value.body:getWorldPoints(value.shape:getPoints()))
    end

end

function drawSolids(solids)
    love.graphics.setColor(0,1,1)
    for index, value in ipairs(solids) do
    love.graphics.polygon("fill",value.body:getWorldPoints(value.shape:getPoints()))
    end

end

function drawSpikes(spikes)
    love.graphics.setColor(1,1,1)
    for index, value in ipairs(spikes) do
    love.graphics.polygon("fill",value.body:getWorldPoints(value.shape:getPoints()))
    end

end

function killedScreen()
        love.graphics.setColor (1,1,1)
        love.graphics.print("Game over!", 350, 300)
end


 


----FURTHER FUNCTIONS-----
function love.keyreleased(key)
    if key == "space" then 
        released = true
    end
end

function love.keypressed(key)
    if key == "space" then
        object = "test"
        if jumpCount == 0 and canJump and released then
            jumpCount = jumpCount + 1
            local jumpForce = vector2.new(0, -100)
            player.body:applyLinearImpulse(jumpForce.x, jumpForce.y)
            player.onground = false 
            released = false
        end
    end
end





----COLLISIONS----











function BeginContact(fixtureA, fixtureB, contact)

    local userDataA = fixtureA:getUserData()
    local userDataB = fixtureB:getUserData()

    -- Finde das entsprechende Objekt im Array
    local objA = findObject(userDataA)
    local objB = findObject(userDataB)



    if fixtureA:getUserData() == "wall" and fixtureB:getUserData() == "player" then 
        canWallJump = true
    end

    if fixtureA:getUserData() == "enemy" and fixtureB:getUserData() == "player" then 

        local nx, ny = contact:getNormal()
        object = ny
    
        local verticalThreshold = -0.1
    
        if ny < verticalThreshold then
            object = "test"
            win = true
        else
           
            if nx < 0 then
                killed = true

            elseif nx > 0 then
                killed = true
            end
        end

    

        
    end

    if fixtureA:getUserData() == "ground" and fixtureB:getUserData() == "player" then
        print1 = true
        local normal = vector2.new(contact:getNormal())
        if normal.y == -1 then
        player.onground = true
        end 
    end 


end

    function EndContact(fixtureA, fixtureB, contact)

        if fixtureA:getUserData() == "wall" and fixtureB:getUserData() == "player" then 
            canWallJump = false
        
        end

        if fixtureA:getUserData() == "enemy" and fixtureB:getUserData() == "player" then 
        end
    end


function enemyMove(dt)
    if turn == false then
        enemy.body:setX(enemy.body:getX()+ (50*dt))

        if enemy.body:getX() >= 400 then
            turn = true
        end
    else 
        enemy.body:setX(enemy.body:getX()-(50*dt))

        if enemy.body:getX()<= 300 then
            turn = false 
        end
    end


end






-- Funktion zum Erstellen von Ground-Objekten
function createGround(x, y, width, height)
    local ground = {}
    ground.body = love.physics.newBody(world, x, y, "static")
    ground.shape = love.physics.newRectangleShape(width, height)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)
    ground.fixture:setUserData("ground")
    
    table.insert(objects, ground)  -- Füge das Objekt zum Array hinzu

    return ground

end 

-- Funktion zum Erstellen von Wall-Objekten
function createWall(x, y, width, height)
    local wall = {}
    wall.body = love.physics.newBody(world, x, y, "static")
    wall.shape = love.physics.newRectangleShape(width, height)
    wall.fixture = love.physics.newFixture(wall.body, wall.shape)
    wall.fixture:setUserData("wall")

    table.insert(objects, wall)  -- Füge das Objekt zum Array hinzu

    return wall
end 

-- Funktion zum Erstellen von Player-Objekten
function createPlayer()
    local player = {}
    player.body = love.physics.newBody(world, 100, 100, "dynamic")
    player.shape = love.physics.newCircleShape(20)
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.body:setFixedRotation(true)
    player.speed = 200
    player.jumpForce = -2000
    player.fixture:setUserData("player")

    table.insert(objects, player)  -- Füge das Objekt zum Array hinzu

    return player
end

-- Funktion zum Erstellen von Enemy-Objekten
function createEnemy(x, y, width, height)
    local enemy = {}
    enemy.body = love.physics.newBody(world, x, y, "static")
    enemy.shape = love.physics.newRectangleShape(width, height)
    enemy.fixture = love.physics.newFixture(enemy.body, enemy.shape)
    enemy.body:setFixedRotation(true)
    enemy.speed = 200
    enemy.fixture:setUserData("enemy")

    table.insert(objects, enemy)  -- Füge das Objekt zum Array hinzu

    return enemy
end

function createBlocks(x, y)
    local block = {}
    block.body = love.physics.newBody(world, x, y, "static")
    block.shape = love.physics.newRectangleShape(50, 50)
    block.fixture = love.physics.newFixture(block.body, block.shape)
    block.fixture:setUserData("block")

    table.insert(objects, block)  -- Füge das Objekt zum Array hinzu

    return block
end 

function createSolids(x, y)
    local solid = {}
    solid.body = love.physics.newBody(world, x, y, "static")
    solid.shape = love.physics.newRectangleShape(100, 30)
    solid.fixture = love.physics.newFixture(solid.body, solid.shape)
    solid.fixture:setUserData("solid")

    table.insert(objects, solid)  -- Füge das Objekt zum Array hinzu

    return solid
end 

function createSpikes(x, y)
    local spike = {}
    spike.body = love.physics.newBody(world, x, y, "static")
    spike.shape = love.physics.newRectangleShape(30, 30)
    spike.fixture = love.physics.newFixture(spike.body, spike.shape)
    spike.fixture:setUserData("solid")

    table.insert(objects, spike)  -- Füge das Objekt zum Array hinzu

    return spike
end 

-- Funktion zum Finden eines Objekts im Array anhand der userData
function findObject(userData)
    for _, obj in ipairs(objects) do
        if obj.fixture:getUserData() == userData then
            return obj
        end
    end
    return nil  -- Objekt nicht gefunden
end
