function CreateVoid(world, x, y, t, i)  
    local void = {}  
    void.body = love.physics.newBody(world, x, y, "static")  
    void.shape = love.physics.newRectangleShape(30, 20)  
    void.fixture = love.physics.newFixture(void.body, void.shape, 3)  
    void.body:setFixedRotation(true)  
    void.fixture:setUserData({object = void,type = "void", index = i})  
    void.type = t      
    return void 
 end 

 function DrawVoid(voids)
    for i = 1, #voids, 1 do
        love.graphics.setColor(0,0,1)
        love.graphics.polygon("fill", voids[i].body:getWorldPoints(voids[i].shape:getPoints()))
    end
end