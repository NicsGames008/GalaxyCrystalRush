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
