--get all the needed info from the light librarys
local Shadows = require("libraries/shadows")
local LightWorld = require("libraries/shadows.LightWorld")
local Light = require("libraries/shadows.Light")
local light

-- Create a light world
local newLightWorld = LightWorld:new()

function loadLight(radius, xPosition, yPosition)
    -- Create a light on the light world, with radius 300
    light = Light:new(newLightWorld, radius)
    light:SetPosition(xPosition, yPosition, 0.3)

    return light
end

function drawLight(Width, Height)
    -- Draw the light world with white color
    newLightWorld:Draw()
    newLightWorld:Resize(Width, Height)
end

function updateLight(dt, xPosition, yPosition, light)
    -- Move the light to the player position with altitude 35
    light:SetPosition(xPosition, yPosition, 0.3)
end

function updateLightWorld()
    newLightWorld:Update()
end
function lightTrigger(userDataA, userDataB, crystals, lightCrystal)
    -- userDataA and userDataB and userDataA.type == "offCrystal" and userDataB.type == "player" 
    if userDataA and userDataB and userDataA.type == "player" and userDataB.type == "offCrystal" then


        --gets the position of the activated crystal and make a new bigger light
        xCrystal, yCrystal = crystals[userDataB.index].body:getPosition()
        lightCrystal[userDataB.index] = loadLight(400, xCrystal, yCrystal)

        --make it so you can't activat the same light
        userDataB.type = "onCrystal"

        spawnColider = true

        return spawnColider, xCrystal,yCrystal
    end

    if userDataA and userDataB and userDataA.type == "offCrystal" and userDataB.type == "player" then


        --gets the position of the activated crystal and make a new bigger light
        xCrystal, yCrystal = crystals[userDataA.index].body:getPosition()
        lightCrystal[userDataA.index] = loadLight(400, xCrystal, yCrystal)

        --make it so you can't activat the same light
        userDataA.type = "onCrystal"

        spawnColider = true

        return spawnColider, xCrystal,yCrystal
    end
end


function deleteLight()
    --implement
end
