--local crystal

function loadCrystals(world, crystals,  lightCrystal)
    if map.layers['Crystals'] then

        for i, obj in pairs(map.layers['Crystals'].objects) do
            crystal = {}

            if obj.shape == "rectangle" then

               
                crystal.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                crystal.shape = love.physics.newRectangleShape(obj.width,obj.height)
                crystal.fixture = love.physics.newFixture(crystal.body, crystal.shape, 1)
                crystal.fixture:setSensor(true)
                crystal.fixture:setUserData(({object = crystal,type = "offCrystal", index = i}))


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

                table.insert(checkpoints, checkpoint)
            end

            --the lights go to the same position as the crystal
            local xCrystal, yCrystal = crystal.body:getPosition()
            lightCrystal[i] = loadLight(100, xCrystal, yCrystal)
        end
        return checkpoints, lightCrystal
    end
end
