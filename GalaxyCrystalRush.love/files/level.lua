require "files/vector2"

local ground
local wall
local spike
local void
local enemyBarrier
local barrier


-- Draw the layers from tiled
function DrawLevel(map)
    map:drawLayer(map.layers["Ground and walls"])
    map:drawLayer(map.layers["Spikes"])
    map:drawLayer(map.layers["Background"])
    map:drawLayer(map.layers["Void"])
    map:drawLayer(map.layers["Purple crystals"])
    map:drawLayer(map.layers["Blue crystal"])
    map:drawLayer(map.layers["Moving platform/ Spikes"])
end

-- Load ground layer
function loadGround(world, grounds)
    if map.layers['Ground'] then

        for i, obj in pairs(map.layers['Ground'].objects) do
            ground = {}


            if obj.shape == "rectangle" then

                ground.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                ground.shape = love.physics.newRectangleShape(obj.width,obj.height)
                ground.fixture = love.physics.newFixture(ground.body, ground.shape, 1)
                ground.fixture:setUserData(({object = ground,type = "ground", index = i}))

                table.insert(grounds, ground)
            end
            
        end
        return grounds
    end

    
end

-- Load wall layer


function loadWalls(world, walls)
    if map.layers['Wall'] then

        for i, obj in pairs(map.layers['Wall'].objects) do
            wall = {}


            if obj.shape == "rectangle" then


                wall.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                wall.shape = love.physics.newRectangleShape(obj.width,obj.height)
                wall.fixture = love.physics.newFixture(wall.body, wall.shape, 1)
                wall.fixture:setUserData(({object = wall,type = "wall", index = i}))

                table.insert(walls, wall)


            end

            if obj.shape == "polygon" then

                local vertices = {}

                for _, point in ipairs(obj.polygon) do

                    table.insert (vertices, point.x - obj.x)
                    table.insert (vertices, point.y - obj.y)

                end

                walls.body = love.physics.newBody(world, obj.x, obj.y, "static")
                walls.shape = love.physics.newPolygonShape(unpack(vertices))
                walls.fixture = love.physics.newFixture(walls.body, walls.shape, 1)
                table.insert(walls, wall)

            end

            if obj.shape == "ellipse" then

                walls.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")

                walls.shape = love.physics.newCircleShape(obj.width / 2)
                walls.fixture = love.physics.newFixture(walls.body, walls.shape, 1)
                table.insert(walls, wall)
            end
            
        end
        return walls
    end
end

-- Load spike layer

function loadSpikes(world, spikes)
    if map.layers['Spikes'] then

        for i, obj in pairs(map.layers['Spikes'].objects) do
            spike = {}

       
            if obj.shape == "rectangle" then

                spike.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                spike.shape = love.physics.newRectangleShape(obj.width,obj.height)
                spike.fixture = love.physics.newFixture(spike.body, spike.shape, 1)
                spike.fixture:setUserData(({object = spike,type = "spike", index = i}))

                table.insert(spikes, spike)

            end

         
        end
        
        return spikes
    end
end

-- Load void layer

function loadVoids( world, voids)
    if map.layers['Portal'] then

        for i, obj in pairs(map.layers['Portal'].objects) do
            void = {}


            if obj.shape == "rectangle" then

                void.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                void.shape = love.physics.newRectangleShape(obj.width,obj.height)
                void.fixture = love.physics.newFixture(void.body, void.shape, 1)
                void.fixture:setUserData(({object = void,type = "void", index = i}))

                table.insert(voids, void)
            end

        end
        return voids, void
    end
end

-- Load barrier layer


function loadBarriers(world, enemyBarriers, barriers)
    if map.layers['Enemy barriers'] then

        for i, obj in pairs(map.layers['Enemy barriers'].objects) do
            enemyBarrier = {}


            if obj.shape == "rectangle" then

                enemyBarrier.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                enemyBarrier.shape = love.physics.newRectangleShape(obj.width,obj.height)
                enemyBarrier.fixture = love.physics.newFixture(enemyBarrier.body, enemyBarrier.shape, 1)
                enemyBarrier.fixture:setSensor(true)
                enemyBarrier.fixture:setUserData(({object = enemyBarrier,type = "enemyBarrier", index = i,width = obj.width}))

                table.insert(enemyBarriers, enemyBarrier)

            end

        end
    end

    -- Load wall jump cancel layer


    if map.layers['Wall jump cancel'] then


        for i, obj in pairs(map.layers['Wall jump cancel'].objects) do
            barrier = {}



            if obj.shape == "rectangle" then

                barrier.body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
                barrier.shape = love.physics.newRectangleShape(obj.width,obj.height)
                barrier.fixture = love.physics.newFixture(barrier.body, barrier.shape, 1)
                barrier.fixture:setUserData(({object = barrier,type = "barrier", index = i}))

                table.insert(barriers, barrier)

            end
        end
    end
    return enemyBarriers, barriers
end


