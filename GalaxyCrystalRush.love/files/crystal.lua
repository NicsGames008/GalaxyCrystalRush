local unLitCrystal = love.graphics.newImage("map/Unlit.png")
local litCrystal = love.graphics.newImage("map/lit.png")

-- Load crystals into the game world
function loadCrystals(world, crystals, lightCrystal)
    -- Check if the 'Crystals' layer exists in the map
    if map.layers['Crystals'] then
        -- Iterate over each crystal object in the 'Crystals' layer
        for i, obj in pairs(map.layers['PhysicalCrystals'].objects) do
            -- Create a new crystal object
            local crystal = {}

            -- Check if the shape of the crystal is a rectangle
            if obj.shape == "rectangle" then
                -- Create a physics body for the crystal at the center of its position
                crystal.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                crystal.shape = love.physics.newRectangleShape(obj.width, obj.height)
                crystal.fixture = love.physics.newFixture(crystal.body, crystal.shape, 1)

                crystal.isOn = false
                
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

function drawCrystals(crystals)
    -- Set the drawing color to white
    love.graphics.setColor(1, 1, 1, 1)

    -- Iterate over each enemy in the 'crystals' table
    for _, crystal in ipairs(crystals) do
        
        --Check if the crystal is on
        if crystal.fixture:getUserData().type == "offCrystal" then
            love.graphics.draw(unLitCrystal, crystal.body:getX(), crystal.body:getY(), nil ,nil ,nil, 120,120)
        else 
            love.graphics.draw(litCrystal, crystal.body:getX(), crystal.body:getY(), nil ,nil ,nil, 120,120)
        end
    end
end