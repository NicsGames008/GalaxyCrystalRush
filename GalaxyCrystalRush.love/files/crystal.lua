function crystalLoad(world, xPosition, yPosition, index)
    --all values and trigers for the crytal
	crystal = {}    
    crystal.body = love.physics.newBody(world, xPosition, yPosition, "static")
    crystal.shape = love.physics.newRectangleShape (20, 40)
	crystal.fixture = love.physics.newFixture (crystal.body, crystal.shape, 2)
	crystal.fixture:setSensor(true)
    crystal.fixture:setUserData({type = "offCrystal", index = index})

    return crystal
end

function DrawCrystal(crystal, crystalOn)
    --draws all the crystal created
    for i = 1, #crystal, 1 do
        if crystal[i] then    
            love.graphics.setColor(1,1,0)         
            love.graphics.polygon("fill", crystal[i].body:getWorldPoints(  crystal[i].shape:getPoints()))

            
            if crystalOn == 1 then    
                local xCrystal, yCrystal = crystals[i].body:getPosition()
                love.graphics.setColor(1,1,1)         
                love.graphics.circle("fill", xCrystal, yCrystal, 400)
            end

        end
    end 
end 

function crystalColiderLoad(world, xPosition, yPosition, index)
    --all values and trigers for the crytal
    crystalColider = {}
    crystalColider.body = love.physics.newBody(world, xPosition, yPosition  , "static")
    crystalColider.shape = love.physics.newCircleShape(200)
    crystalColider.fixture = love.physics.newFixture(crystalColider.body, crystalColider.shape, 2)
    crystalColider.fixture:setSensor(true)
    crystalColider.fixture:setUserData({type = "crystalColider", index = index})

    return crystal
end

function crystalTrigger(userDataA, userDataB)
    if userDataA and userDataB and userDataA.type == "enemy" and userDataB.type == "crystalColider" then
        --put the enemy death function here
        print("enemy dead")
    end 

    if userDataA and userDataB and userDataA.type == "crystalColider" and userDataB.type == "enemy" then
        --put the enemy death function here
        print("enemy dead")
    end 
end