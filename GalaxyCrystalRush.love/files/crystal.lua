-- Load crystals into the game world
function loadCrystals(world, crystals, lightCrystal)
    -- Check if the 'Crystals' layer exists in the map
    if map.layers['Crystals'] then
        -- Iterate over each crystal object in the 'Crystals' layer
        for i, obj in pairs(map.layers['Crystals'].objects) do
            -- Create a new crystal object
            local crystal = {}

            -- Check if the shape of the crystal is a rectangle
            if obj.shape == "rectangle" then
                -- Create a physics body for the crystal at the center of its position
                crystal.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                
                -- Create a rectangle shape for the crystal
                crystal.shape = love.physics.newRectangleShape(obj.width, obj.height)
                
                -- Create a fixture for the crystal's physics body
                crystal.fixture = love.physics.newFixture(crystal.body, crystal.shape, 1)
                
                -- Set the fixture as a sensor to detect collisions without physical responses
                crystal.fixture:setSensor(true)
                
                -- Set user data for the fixture to store information about the crystal
                crystal.fixture:setUserData({ object = crystal, type = "offCrystal", index = i })
                
                -- Add the crystal to the 'crystals' table
                table.insert(crystals, crystal)
            end

            -- Get the position of the crystal for light creation
            local xCrystal, yCrystal = crystal.body:getPosition()
            
            -- Load a light for the crystal and store it in the 'lightCrystal' table
            lightCrystal[i] = loadLight(100, xCrystal, yCrystal)
        end

        -- Return the updated 'crystals' and 'lightCrystal' tables
        return crystals, lightCrystal
    end
end


-- function loadCheckpointCrystals(world, checkpoints, lightCrystal)
--     if map.layers['Checkpoint'] then
--         for i, obj in pairs(map.layers['Checkpoint'].objects) do
--             checkpoint = {}
--             if obj.shape == "rectangle" then               
--                 checkpoint.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
--                 checkpoint.shape = love.physics.newRectangleShape(obj.width,obj.height)
--                 checkpoint.fixture = love.physics.newFixture(checkpoint.body, checkpoint.shape, 1)
--                 checkpoint.fixture:setSensor(true)
--                 checkpoint.fixture:setUserData(({object = checkpoint,type = "checkpoint", index = i}))

--                 table.insert(checkpoints, checkpoint)
--             end
--             --the lights go to the same position as the crystal
--             local xCrystal, yCrystal = crystal.body:getPosition()
--             lightCrystal[i] = loadLight(100, xCrystal, yCrystal)
--         end
--         return checkpoints, lightCrystal
--     end
-- end
