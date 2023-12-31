require "files/vector2"  

-- Load enemy layer

local enemy

function loadEnemies(world, enemies, anim8)
    if map.layers['Enemies'] then

        for i, obj in pairs(map.layers['Enemies'].objects) do
            local enemy = {}

            if obj.shape == "rectangle" then

                
                enemy.sprite = love.graphics.newImage("map/Enemy tiled.png")
                enemy.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                enemy.shape = love.physics.newRectangleShape(enemy.sprite:getWidth()-100, enemy.sprite:getHeight()-50)
                enemy.fixture = love.physics.newFixture(enemy.body, enemy.shape, 1)
                enemy.fixture:setSensor(true)
                enemy.fixture:setUserData(({object = enemy,type = "enemy", index = i,x = obj.x + obj.width / 2 ,obj.y + obj.height / 2  }))
                enemy.killed = false        

                enemy.spriteSheet = love.graphics.newImage("sprites/EnemyShpiteSheet.png")
                enemy.gird = anim8.newGrid( 64, 64, enemy.spriteSheet:getWidth(), enemy.spriteSheet:getHeight())
                
                enemy.animations = {}
                enemy.animations.walkRight = anim8.newAnimation(enemy.gird('1-2', 1), 2)
                enemy.animations.walkLeft = anim8.newAnimation(enemy.gird('1-2', 2), 2)

                enemy.anim = enemy.animations.walkRight
                table.insert(enemies, enemy)
            end

        end
        return enemies
    end
end

function drawEnemies(enemies)
    love.graphics.setColor(1, 1, 1, 1)
    for _, enemy in ipairs(enemies) do
        if not enemy.killed then
            enemy.anim:draw(enemy.spriteSheet, enemy.body:getX(), enemy.body:getY(), nil, 3, 3, 30, 32)
        end
    end
end

-- makes the enemies move and change when hitting a barrier

function enemyMove(dt, enemies, enemyBarriers)
    for _, enemy in ipairs(enemies) do
        if not enemy.killed then
            if not enemy.speed then
                enemy.speed = 15
            end

            local enemyX, enemyY = enemy.body:getPosition()
            local nextX = enemyX + (enemy.speed * dt)

            local hitBarrier = false
            for _, barrier in ipairs(enemyBarriers) do
                local barrierX = barrier.body:getX()
                local barrierWidth = barrier.fixture:getUserData().width

                if nextX + enemy.shape:getRadius() > barrierX - barrierWidth / 2 and
                   nextX - enemy.shape:getRadius() < barrierX + barrierWidth / 2 then
                    hitBarrier = true
                    break
                end
            end

            if not hitBarrier then
                enemy.body:setX(nextX)
            else
                enemy.speed = -enemy.speed
            end

            if enemy.speed < 0 then
                enemy.anim = enemy.animations.walkLeft
            else
                enemy.anim = enemy.animations.walkRight
            end

            enemy.anim:update(dt)
        end
    end
end