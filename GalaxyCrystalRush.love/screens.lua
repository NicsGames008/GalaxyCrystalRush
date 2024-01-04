
-- Function to display the "Game Over" screen
function killedScreen()
    -- Get the width and height of the screen
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()

    -- Calculate the middle position for text placement
    middleX = screenWidth / 2 - 50
    middleY = screenHeight / 2

    -- Set the text color to white and display "Game Over!" at the calculated position
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Game over! Press 'r' to retry or press p to get to the last checkpoint", middleX, middleY)
end


function successScreen()
    -- Get the width and height of the screen
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()

    -- Calculate the middle position for text placement
    middleX = screenWidth / 2 - 50
    middleY = screenHeight / 2

    -- Set the text color to white and display "Game Over!" at the calculated position
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("You won!", middleX, middleY)
end
