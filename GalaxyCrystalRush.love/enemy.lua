require "vector2"  
function CreateEnemy(world, x, y, t, i)  
    local enemy = {}  
    enemy.body = love.physics.newBody(world, x, y, "dynamic")  
    enemy.shape = love.physics.newRectangleShape(30, 30)  
    enemy.fixture = love.physics.newFixture(enemy.body, enemy.shape, 3)  
    enemy.body:setFixedRotation(true)  enemy.fixture:setFriction(1)  
    enemy.fixture:setUserData({type = "enemy", index = i})  
    enemy.type = t  
    enemy.maxvelocity = 200  
    enemy.direction = vector2.new(-1, 0)  
    enemy.moveTimer = 3
     if t == 1 then  
        enemy.timeToMove = 1.5  
    elseif t == 2 then  
        enemy.timeToMove = 3  
    end  
    return enemy 
 end 

function UpdateEnemies(dt, enemies)  
    for i = 1, #enemies, 1 do  
        if enemies[i] then  
            if enemies[i].type == 1 then  
                local moveForce = vector2.mult(enemies[i].direction, 800)  
                enemies[i].body:applyForce(moveForce.x, moveForce.y)  
                enemies[i].moveTimer = enemies[i].moveTimer + dt  
                if enemies[i].moveTimer > enemies[i].timeToMove then  
                    enemies[i].direction = vector2.mult(enemies[i].direction, -1)  
                    enemies[i].moveTimer = 0  
                end  
                local velocity = vector2.new(  enemies[i].body:getLinearVelocity())  
                if velocity.x > 0 then 
                     enemies[i].body:setLinearVelocity(math.min(velocity.x,  enemies[i].maxvelocity), velocity.y)  
                    else  enemies[i].body:setLinearVelocity(math.max(velocity.x,  -enemies[i].maxvelocity), velocity.y)  
                    end

elseif enemies[i].type == 2 then  
    enemies[i].moveTimer = enemies[i].moveTimer + dt  
    if enemies[i].moveTimer > enemies[i].timeToMove then
        local jumpForce = vector2.new(0, -800)  enemies[i].body:applyLinearImpulse(jumpForce.x, jumpForce.y)  
        enemies[i].moveTimer = 0  
    end  
end  
end  
end  
end  
function DrawEnemies(enemies)  
    for i = 1, #enemies, 1 do  
        if enemies[i] then  
            if enemies[i].type == 1 
            then  love.graphics.setColor(0.8, 0.0, 0.0)  
            elseif enemies[i].type == 2 
            then  love.graphics.setColor(0.8, 0.8, 0.0)  
            end

love.graphics.polygon("fill", enemies[i].body:getWorldPoints(  enemies[i].shape:getPoints()))  
end  
end  
end 