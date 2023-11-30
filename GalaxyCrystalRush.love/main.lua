require "files/light"
require "files/crystal"
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
local grounds = {}
local walls = {}
local spikes = {}
local voids = {}
local wallJump = false 
local brightLevel = true
local text = "false"
local lightPlayer








function love.load()
    --createPhysics()
    background = love.graphics.newImage("background.png")
    local canJump = true;
    love.window.setMode(1080, 900)
    love.window.setFullscreen(true)

    camera = Camera(0, 0, 0, 0, 0.5)
    -- Somewhere in your code
    --camera.scale = 1








    --map = sti("mapTest/mmap.lua", { "box2d" })
    map = sti("mapTest/test.lua", { "box2d" })



    love.physics.setMeter(64) 
    world = love.physics.newWorld(0, 9.81 * 64, true) 
    world:setCallbacks(BeginContact, EndContact, nil, nil)

    table.insert(spikes, CreateSpike(world,1000, -320))
    table.insert(voids, CreateVoid(world,300, -100))



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
    ground.shape = love.physics.newRectangleShape(5000, 30) -- Breite von 800 und Höhe von 10 Pixel
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)
    ground.fixture:setUserData(({object = ground,type = "ground", index = i})) 

    wall = {}
    wall.body = love.physics.newBody(world, 200, 200, "static")
    wall.shape = love.physics.newRectangleShape(10, 200) -- Breite von 10 und Höhe von 200 Pixel
    wall.fixture = love.physics.newFixture(wall.body, wall.shape)
    wall.fixture:setUserData(({object = wall,type = "wall", index = i})) 
    table.insert(walls, wall)



    player = {}
    player.body = love.physics.newBody(world, -100, -500, "dynamic")
    player.shape = love.physics.newCircleShape(20) -- Radius von 20 Pixel
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.body:setFixedRotation(true) -- Verhindere Drehung
    player.speed = 200 -- Horizontale Geschwindigkeit
    player.jumpForce = -2000 -- Sprungkraft
    player.fixture:setUserData (({object = player,type = "player", index = i})) 


    enemy = {}
    enemy.body = love.physics.newBody(world, 700, -340, "static")
    enemy.shape = love.physics.newRectangleShape(50,50) -- Radius von 20 Pixel
    enemy.fixture = love.physics.newFixture(enemy.body, enemy.shape)
    enemy.body:setFixedRotation(true) -- Verhindere Drehung
    enemy.speed = 200 -- Horizontale Geschwindigkeit
    enemy.fixture:setUserData(({object = enemy,type = "enemy", index = i}))



    loadGround()
    loadWalls()
    loadSpikes()
    loadVoids()


    local playerX, playerY = player.body:getPosition()
    lightPlayer = loadLight(200, playerX, playerY)





end

function love.update(dt)

    world:update(dt) -- Aktualisiere die Physik-Welt
    camera:update(dt)
    local pX, pY = player.body:getPosition()
    camera:follow(pX - 900 ,pY - 800)
    --camera:follow(cam.x,cam.y)

    camera.follow_style = 'PLATFORMER'

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

            
    local xLightPlayer, yLightPlayer = camera:toCameraCoords(pX,pY)
    updateLight(dt, xLightPlayer, yLightPlayer, lightPlayer)

end

function love.draw()
    if killed then 
        killedScreen()
    else
    camera:attach()

  
    love.graphics.setColor(1, 1, 1)
    local offsetY = 1200
    local offsetX = 250


    map:drawLayer(map.layers["Miscelaneous"])  
    map:drawLayer(map.layers["Spikes"])  
    map:drawLayer(map.layers["Background"])  
    map:drawLayer(map.layers["void"])
    map:drawLayer(map.layers["Tile Layer 1"])  



    love.graphics.setColor(1, 0, 0)
	map:box2d_draw()
    


    drawBackground()
    drawPlayer(playerX,playerY)
    drawEnemy(enemyX,enemyY)
    DrawSpike(spikes)
    DrawVoid(voids)
    object = tostring(text)
    love.graphics.print(object,0,0)
    if brightLevel then
        -- licht anmachen
        local Height = love.graphics:getHeight()
        local Width = love.graphics:getWidth()
        drawLight(Width, Height)
    end

    camera:detach()
    camera:draw() -- Call this here if you're using camera:fade, camera:flash or debug drawing the deadzone
end
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

function drawWalls(walls)
    for i = 1, #walls, 1 do
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.polygon("fill", walls[i].body:getWorldPoints(walls[i].shape:getPoints()))
    end
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
            local jumpForce = vector2.new(0, -200)
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


    if key == "b" then 
        if brightLevel then            
            brightLevel = false
        elseif not brightLevel then            
            brightLevel = true
        end
    end
end



function BeginContact(fixtureA, fixtureB, contact)

    if fixtureA:getUserData().type == "spike" and fixtureB:getUserData().type == "player"  then
        if cheat == false then
        killed = true;
        end
    end

    if fixtureA:getUserData().type == "void" and fixtureB:getUserData().type == "player" then
        if cheat == false then
        killed = true;
        end
    end

    if fixtureA:getUserData().type == "wall" and fixtureB:getUserData().type == "player" then 
        canWallJump = true
        wallJump = true
        player.onground = false
    end


    if fixtureA:getUserData().type == "enemy" and fixtureB:getUserData().type == "player" then 

        if cheat == false then
            killed = true;
        end
    

        
    end




    if fixtureA:getUserData().type == "ground" and fixtureB:getUserData().type == "player" then
        print1 = true
        local normal = vector2.new(contact:getNormal())
        text = "floor"
        if normal.y == -1 then
        player.onground = true
        wallJump = false
        canJump = true
        jumpCount = 0
        canWallJump = true
        end 
    end 


end

    function EndContact(fixtureA, fixtureB, contact)

        if fixtureA:getUserData().type == "wall" and fixtureB:getUserData().type == "player" then 
            canWallJump = false
            wallJump = false
        
        end

        if fixtureA:getUserData().type == "enemy" and fixtureB:getUserData().type == "player" then 
        end
    end


function enemyMove(dt)
    if turn == false then
        enemy.body:setX(enemy.body:getX()+ (50*dt))

        if enemy.body:getX() >= 800 then
            turn = true
        end
    else 
        enemy.body:setX(enemy.body:getX()-(50*dt))

        if enemy.body:getX()<= 500 then
            turn = false 
        end
    end


end


function loadGround()
    if map.layers['Ground'] then

        -- iterate for every colition shapes you made in tiled --
        for i, obj in pairs(map.layers['Ground'].objects) do
            ground = {}

            -- check what type of shape it is --
            
            -- check for each rectangle shape --
            if obj.shape == "rectangle" then

                -- the center of the colition box will be on the top left of where it is suposed to be --
                -- so i added its width devided by 2 on the x pos and did the same for its y pos with height here --
                ground.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                ground.shape = love.physics.newRectangleShape(obj.width,obj.height)
                ground.fixture = love.physics.newFixture(ground.body, ground.shape, 1)
                ground.fixture:setUserData(({object = ground,type = "ground", index = i}))

                table.insert(grounds, ground)
                
            end

            -- check for each polygon shape --
        

        end

    end
end



function loadWalls()
    if map.layers['Wall'] then

        -- iterate for every colition shapes you made in tiled --
        for i, obj in pairs(map.layers['Wall'].objects) do
            wall = {}

            -- check what type of shape it is --
            
            -- check for each rectangle shape --
            if obj.shape == "rectangle" then

                -- the center of the colition box will be on the top left of where it is suposed to be --
                -- so i added its width devided by 2 on the x pos and did the same for its y pos with height here --
                wall.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                wall.shape = love.physics.newRectangleShape(obj.width,obj.height)
                wall.fixture = love.physics.newFixture(wall.body, wall.shape, 1)
                wall.fixture:setUserData(({object = wall,type = "wall", index = i}))

                table.insert(walls, wall)
                
            end

            -- check for each polygon shape --
            if obj.shape == "polygon" then
                
                -- make a table for the positions of each point for each polygon --
                local vertices = {}
                
                -- here you get the position of the polygon points and put them in the table --
                for _, point in ipairs(obj.polygon) do
                    
                    -- in here we subtract the polygon pos for it to go to the right place --
                    table.insert (vertices, point.x - obj.x)
                    table.insert (vertices, point.y - obj.y)
                    
                end

                walls.body = love.physics.newBody(world, obj.x, obj.y, "static")
                -- unpack here the x and y coordinates of each point to make the shape --
                walls.shape = love.physics.newPolygonShape(unpack(vertices))
                walls.fixture = love.physics.newFixture(walls.body, walls.shape, 1)
                table.insert(walls, wall)

            end

            -- check for each ellipse shape --
            if obj.shape == "ellipse" then
            
                -- here do the same as the rectangle to get it to the right position --
                walls.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                -- to make the shape take the width and devide it by 2 --
                walls.shape = love.physics.newCircleShape(obj.width / 2)
                walls.fixture = love.physics.newFixture(walls.body, walls.shape, 1)
                table.insert(walls, wall)

            end

        end

    end
end







function loadSpikes()
    if map.layers['Spikes'] then

        -- iterate for every colition shapes you made in tiled --
        for i, obj in pairs(map.layers['Spikes'].objects) do
            spike = {}

            -- check what type of shape it is --
            
            -- check for each rectangle shape --
            if obj.shape == "rectangle" then

                -- the center of the colition box will be on the top left of where it is suposed to be --
                -- so i added its width devided by 2 on the x pos and did the same for its y pos with height here --
                spike.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                spike.shape = love.physics.newRectangleShape(obj.width,obj.height)
                spike.fixture = love.physics.newFixture(spike.body, spike.shape, 1)
                spike.fixture:setUserData(({object = spike,type = "spike", index = i}))

                table.insert(spikes, spike)
                
            end

            -- check for each polygon shape --
            if obj.shape == "polygon" then
                
                -- make a table for the positions of each point for each polygon --
                local vertices = {}
                
                -- here you get the position of the polygon points and put them in the table --
                for _, point in ipairs(obj.polygon) do
                    
                    -- in here we subtract the polygon pos for it to go to the right place --
                    table.insert (vertices, point.x - obj.x)
                    table.insert (vertices, point.y - obj.y)
                    
                end

                walls.body = love.physics.newBody(world, obj.x, obj.y, "static")
                -- unpack here the x and y coordinates of each point to make the shape --
                walls.shape = love.physics.newPolygonShape(unpack(vertices))
                walls.fixture = love.physics.newFixture(walls.body, walls.shape, 1)
                table.insert(walls, wall)

            end

            -- check for each ellipse shape --
            if obj.shape == "ellipse" then
            
                -- here do the same as the rectangle to get it to the right position --
                walls.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                -- to make the shape take the width and devide it by 2 --
                walls.shape = love.physics.newCircleShape(obj.width / 2)
                walls.fixture = love.physics.newFixture(walls.body, walls.shape, 1)
                table.insert(walls, wall)

            end

        end

    end
end







function loadVoids()
    if map.layers['Portal'] then

        -- iterate for every colition shapes you made in tiled --
        for i, obj in pairs(map.layers['Portal'].objects) do
            void = {}

            -- check what type of shape it is --
            
            -- check for each rectangle shape --
            if obj.shape == "rectangle" then

                -- the center of the colition box will be on the top left of where it is suposed to be --
                -- so i added its width devided by 2 on the x pos and did the same for its y pos with height here --
                void.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                void.shape = love.physics.newRectangleShape(obj.width,obj.height)
                void.fixture = love.physics.newFixture(void.body, void.shape, 1)
                void.fixture:setUserData(({object = void,type = "void", index = i}))

                table.insert(voids, void)
                
            end

            -- check for each polygon shape --
            if obj.shape == "polygon" then
                
                -- make a table for the positions of each point for each polygon --
                local vertices = {}
                
                -- here you get the position of the polygon points and put them in the table --
                for _, point in ipairs(obj.polygon) do
                    
                    -- in here we subtract the polygon pos for it to go to the right place --
                    table.insert (vertices, point.x - obj.x)
                    table.insert (vertices, point.y - obj.y)
                    
                end

                walls.body = love.physics.newBody(world, obj.x, obj.y, "static")
                -- unpack here the x and y coordinates of each point to make the shape --
                walls.shape = love.physics.newPolygonShape(unpack(vertices))
                walls.fixture = love.physics.newFixture(walls.body, walls.shape, 1)
                table.insert(walls, wall)

            end

            -- check for each ellipse shape --
            if obj.shape == "ellipse" then
            
                -- here do the same as the rectangle to get it to the right position --
                walls.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                -- to make the shape take the width and devide it by 2 --
                walls.shape = love.physics.newCircleShape(obj.width / 2)
                walls.fixture = love.physics.newFixture(walls.body, walls.shape, 1)
                table.insert(walls, wall)

            end

        end

    end
end