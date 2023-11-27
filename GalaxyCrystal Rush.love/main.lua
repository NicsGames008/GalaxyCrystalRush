require "vector2"
require "graphicsLoader"
require"enemy"
require"player"
require"level"
require"spike"
require"void"
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
local cheat = false
local sti = require"libraries/sti"
local Camera = require "Camera"
local cam
local enemies
local floors
local walls
local spikes = {}
local voids = {}
local wallJump = false 





function love.load()
    background = love.graphics.newImage("background.png")
    local canJump = true;
    love.window.setMode(1080, 900)
    camera = Camera()
    -- Somewhere in your code
    camera.scale = 1








    map = sti("maps/map.lua", { "box2d" })



    love.physics.setMeter(64) 
    world = love.physics.newWorld(0, 9.81 * 64, true) 
    world:setCallbacks(BeginContact, EndContact, nil, nil)

    table.insert(spikes, CreateSpike(world,440, 275))
    table.insert(voids, CreateVoid(world,500, 275))



    map:box2d_init(world)

    map:addCustomLayer("Sprite Layer", 3)

    local spriteLayer = map.layers["Sprite Layer"]
	spriteLayer.sprites = {
		
	}

    function spriteLayer:update(dt)
		for _, sprite in pairs(self.sprites) do
			sprite.r = sprite.r + math.rad(90 * dt)
		end
	end

    function spriteLayer:draw()
		for _, sprite in pairs(self.sprites) do
			local x = math.floor(sprite.x)
			local y = math.floor(sprite.y)
			local r = sprite.r
			love.graphics.draw(sprite.image, x, y, r)
		end
	end


    cam = {}
    cam.x = 0
    cam.y = 0

    ground = {}
    ground.body = love.physics.newBody(world, 400, 300, "static")
    ground.shape = love.physics.newRectangleShape(800, 30) -- Breite von 800 und Höhe von 10 Pixel
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)
    ground.fixture:setUserData("ground") 

    wall = {}
    wall.body = love.physics.newBody(world, 200, 200, "static")
    wall.shape = love.physics.newRectangleShape(10, 200) -- Breite von 10 und Höhe von 200 Pixel
    wall.fixture = love.physics.newFixture(wall.body, wall.shape)
    wall.fixture:setUserData("wall") 


    player = {}
    player.body = love.physics.newBody(world, 100, 100, "dynamic")
    player.shape = love.physics.newCircleShape(20) -- Radius von 20 Pixel
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.body:setFixedRotation(true) -- Verhindere Drehung
    player.speed = 200 -- Horizontale Geschwindigkeit
    player.jumpForce = -2000 -- Sprungkraft
    player.fixture:setUserData ("player") 


    enemy = {}
    enemy.body = love.physics.newBody(world, 400, 275, "static")
    enemy.shape = love.physics.newRectangleShape(50,50) -- Radius von 20 Pixel
    enemy.fixture = love.physics.newFixture(enemy.body, enemy.shape)
    enemy.body:setFixedRotation(true) -- Verhindere Drehung
    enemy.speed = 200 -- Horizontale Geschwindigkeit
    enemy.fixture:setUserData("enemy")

end

function love.update(dt)

    world:update(dt) -- Aktualisiere die Physik-Welt

    map:update(dt)

    local camSpeed = 500
    if love.keyboard.isDown("w") then
        cam.y = cam.y - camSpeed * dt
    elseif love.keyboard.isDown("s") then
        cam.y = cam.y + camSpeed * dt
    end

    if love.keyboard.isDown("a") then
        cam.x = cam.x - camSpeed * dt
    elseif love.keyboard.isDown("d") then
        cam.x = cam.x + camSpeed * dt
    end


    local playerX, playerY = player.body:getPosition()
    object = playerX
    camera:update(dt)
    --camera:follow(playerX,playerY)
    camera:follow(cam.x,cam.y)





    -- Spielersteuerung
    if love.keyboard.isDown("left") then
        player.body:applyForce(-player.speed, 0)
    elseif love.keyboard.isDown("right") then
        player.body:applyForce(player.speed, 0)
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

function love.draw()
    camera:attach()

  
    love.graphics.setColor(1, 1, 1)
    map:draw(-cam.x * camera.scale, -cam.y * camera.scale)    love.graphics.setColor(1, 0, 0)
	map:box2d_draw()
    


    if killed then 
        killedScreen()
    else
    drawBackground()
    drawWall()
    drawPlayer(playerX,playerY)
    drawGround(400,400)
    drawEnemy(enemyX,enemyY)
    DrawSpike(spikes)
    DrawVoid(voids)
    object = tostring(voids[0])
    love.graphics.print(object,0,0)
    end
    camera:detach()
    camera:draw() -- Call this here if you're using camera:fade, camera:flash or debug drawing the deadzone
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

function drawWall()
    love.graphics.setColor(0.5, 0.5, 0.5)  -- Set a color for the wall
    love.graphics.polygon("fill", wall.body:getWorldPoints(wall.shape:getPoints()))
end

function createGround(x, y)
    ground = {}
    ground.body = love.physics.newBody(world, x, y, "static")
    ground.shape = love.physics.newRectangleShape(800, 10)  -- Customize width and height as needed
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)
    return ground
end

function drawEnemy(x,y)
    love.graphics.setColor(1,0,0)
    love.graphics.polygon("fill",enemy.body:getWorldPoints(enemy.shape:getPoints()))
end

function killedScreen()
        love.graphics.setColor (1,1,1)
        love.graphics.print("Game over!", 350, 300)
end



function love.keyreleased(key)
    if key == "space" then 
        released = true
    end
end

function love.keypressed(key)
    if key == "space" and cheat == false and wallJump == false then
        object = "test"
        if jumpCount == 0 and canJump and released then
            jumpCount = jumpCount + 1
            local jumpForce = vector2.new(0, -100)
            player.body:applyLinearImpulse(jumpForce.x, jumpForce.y)
            player.onground = false 
            released = false
        end
    end


    if key == "space" and cheat == false and wallJump then
        if canJump and released then
            local jumpForceY = -100  -- Adjust this value to control the jump height
            local jumpForceX = 0  -- Initialize X force to 0
            
            -- Check player's direction
            if love.keyboard.isDown("left") then
                jumpForceX = 50  -- Apply force to the right
            elseif love.keyboard.isDown("right") then
                jumpForceX = -50  -- Apply force to the left
            end
            
            player.body:applyLinearImpulse(jumpForceX, jumpForceY)
            canJump = false
            released = false
        end
    end
    



    if key == "c" and cheat == false then
        object = "cheats on"
        cheat = true
    end
   

    if key == "space" and cheat then
        local jumpForce = vector2.new(0, -100)
            player.body:applyLinearImpulse(jumpForce.x, jumpForce.y)
    end
end



function BeginContact(fixtureA, fixtureB, contact)

    if fixtureA:getUserData().type == "spike" and fixtureB:getUserData() == "player" then
        killed = true;
    end

    if fixtureA:getUserData().type == "void" and fixtureB:getUserData() == "player" then
        killed = true;
    end

    if fixtureA:getUserData() == "wall" and fixtureB:getUserData() == "player" then 
        canWallJump = true
        wallJump = true
        player.onground = false
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
        wallJump = false
        end 
    end 


end

    function EndContact(fixtureA, fixtureB, contact)

        if fixtureA:getUserData() == "wall" and fixtureB:getUserData() == "player" then 
            canWallJump = false
            wallJump = false
        
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


