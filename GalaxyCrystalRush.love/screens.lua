
-- Function to display the "Game Over" screen
function killedScreen()
    local image = love.graphics.newImage("map/deadScreen.png")
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(image, -100, 0)

end


function successScreen()
    -- Get the width and height of the screen
    local image = love.graphics.newImage("map/win.png")
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(image, -100, 0)
end
