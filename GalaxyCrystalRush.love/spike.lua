function CreateSpike(world, x, y, t, i)  
    local spike = {}  
    spike.body = love.physics.newBody(world, x, y, "static")  
    spike.shape = love.physics.newRectangleShape(30, 20)  
    spike.fixture = love.physics.newFixture(spike.body, spike.shape, 3)  
    spike.body:setFixedRotation(true)  
    spike.fixture:setFriction(1)  
    spike.fixture:setUserData({object = spike,type = "spike", index = i})  
    spike.type = t  
    spike.moveTimer = 3  
    
    return spike 
 end 

 function DrawSpike(spike)
    for i = 1, #spike, 1 do
        love.graphics.setColor(0,1,0)
        love.graphics.polygon("fill", spike[i].body:getWorldPoints(spike[i].shape:getPoints()))
    end
end