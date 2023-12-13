function loadCrystals(world, crystals, lightCrystal)
    if map.layers['Crystals'] then

        for i, obj in pairs(map.layers['Crystals'].objects) do
            crystal = {}

            if obj.shape == "rectangle" then

               
                crystal.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                crystal.shape = love.physics.newRectangleShape(obj.width,obj.height)
                crystal.fixture = love.physics.newFixture(crystal.body, crystal.shape, 1)
                crystal.fixture:setSensor(true)
                crystal.fixture:setUserData(({object = crystal,type = "offCrystal", index = i}))

                print(obj.id)

                table.insert(crystals, crystal)
            end

            --the lights go to the same position as the crystal
            local xCrystal, yCrystal = crystal.body:getPosition()
            lightCrystal[i] = loadLight(100, xCrystal, yCrystal)
        end
        return crystals, lightCrystal
    end
end

function loadCheckpointCrystals(world, checkpoints, lightCrystal)
    if map.layers['Checkpoint'] then

        for i, obj in pairs(map.layers['Checkpoint'].objects) do
            checkpoint = {}

            if obj.shape == "rectangle" then

               
                checkpoint.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                checkpoint.shape = love.physics.newRectangleShape(obj.width,obj.height)
                checkpoint.fixture = love.physics.newFixture(checkpoint.body, checkpoint.shape, 1)
                checkpoint.fixture:setSensor(true)
                checkpoint.fixture:setUserData(({object = checkpoint,type = "checkpoint", index = i}))

                print(obj.id)

                table.insert(checkpoints, checkpoint)
            end

            --the lights go to the same position as the crystal
            local xCrystal, yCrystal = crystal.body:getPosition()
            lightCrystal[i] = loadLight(100, xCrystal, yCrystal)
        end
        return checkpoints, lightCrystal
    end
end

    --draws all the crystal created

function DrawCrystal(crystal, crystalOn)
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