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
    light:SetPosition(xPosition,yPosition, 0.3)

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

function UpdateLightWorld()
    newLightWorld:Update()
end
