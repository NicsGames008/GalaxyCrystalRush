require "/source/button"
local backgroundImg = love.graphics.newImage("sprites/bg_plain.png")

local BUTTON_HEIGHT = 64

local buttons = {}
local pauseButtons = {}
local font = nil
local STATE_GAMEPLAY = 1
local STATE_MAIN_MENU = 0
local state = STATE_MAIN_MENU
local changed = false
local buttonImg = love.graphics.newImage("sprites/buttonDesgin.png")

-- Function to load buttons for the main menu
function loadMainMenu()
    -- Load a font for the menu
    font = love.graphics.newFont(32)

    -- Insert buttons for the main menu
    table.insert(buttons, newButton("Start Game", startGame))
    table.insert(buttons, newButton("Exit", exit))
    table.insert(pauseButtons, newButton("Resume", resume))
    table.insert(pauseButtons, newButton("Main Menu", menu))
end

-- Function to update the game state
function updateState(current)
    -- Check if the state has changed
    if changed == false then
        -- Return the current state if no change
        return current
    else
        -- Reset the changed flag and return the new state
        changed = false
        return state
    end
end

-- Function to draw the main menu
function drawMainMenu()

    love.graphics.setColor(1,1,1,0.5)
    love.graphics.draw(backgroundImg, 0, 0)

    local ww = love.graphics.getWidth()
    local wh = love.graphics.getHeight()
    local button_width = ww * (1 / 7)
    local margin = 32
    local total_height = (BUTTON_HEIGHT + margin) * #buttons
    local cursor_y = 0

    -- Iterate over each button in the 'buttons' table
    for i, button in ipairs(buttons) do
        button.last = button.now
        local bx = (ww * 0.5) - (button_width * 0.5)
        local by = (wh * 0.5) - (total_height * 0.5) + cursor_y
        local color = { 0.4, 0.4, 0.5, 1.0 }
        local mx, my = love.mouse.getPosition()
        local hot = mx > bx and mx < bx + button_width and my > by and my < by + BUTTON_HEIGHT

        -- Change button color if mouse is over it
        if hot then
            color = { 0.8, 0.8, 0.9, 1.0 }
        end

        -- Update button state based on mouse input
        button.now = love.mouse.isDown(1)
        if button.now and not button.last and hot then
            button.fn()
        end

        -- Set button color and draw the button
        love.graphics.setColor(unpack(color))
        local btnw = buttonImg:getWidth()
        love.graphics.draw(buttonImg, (ww * 0.5) - btnw * 0.9, by, nil, 1.8, 1.8)

        -- Reset color to default and draw button text
        love.graphics.setColor(1, 1, 1, 1)
        local textw = font:getWidth(button.text)
        local texth = font:getHeight(button.text)
        love.graphics.print(button.text, font, (ww * 0.5) - textw * 0.5, by + texth * 0.6)

        -- Move cursor to the next button position
        cursor_y = cursor_y + (BUTTON_HEIGHT + margin)
    end
end

-- Function to draw the pause menu
function drawPauseMenu()
    local ww = love.graphics.getWidth()
    local wh = love.graphics.getHeight()

    -- Set color for a semi-transparent background
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", 0, 0, ww, wh)

    -- Reset color to default
    love.graphics.setColor(1, 1, 1)
    local button_width = ww * (1 / 3)
    local margin = 32
    local total_height = (BUTTON_HEIGHT + margin) * #buttons
    local cursor_y = 0

    -- Iterate over each button in the 'pauseButtons' table
    for i, button in ipairs(pauseButtons) do
        button.last = button.now
        local bx = (ww * 0.5) - (button_width * 0.5)
        local by = (wh * 0.5) - (total_height * 0.5) + cursor_y
        local color = { 0.4, 0.4, 0.5, 1.0 }
        local mx, my = love.mouse.getPosition()
        local hot = mx > bx and mx < bx + button_width and my > by and my < by + BUTTON_HEIGHT

        -- Change button color if mouse is over it
        if hot then
            color = { 0.8, 0.8, 0.9, 1.0 }
        end

        -- Update button state based on mouse input
        button.now = love.mouse.isDown(1)
        if button.now and not button.last and hot then
            button.fn()
        end

        -- Set button color and draw the button
        love.graphics.setColor(unpack(color))
        local btnw = buttonImg:getWidth()
        love.graphics.draw(buttonImg, (ww * 0.5) - btnw * 0.9, by, nil, 1.8, 1.8)

        -- Reset color to default and draw button text
        love.graphics.setColor(1, 1, 1, 1)
        local textw = font:getWidth(button.text)
        local texth = font:getHeight(button.text)
        love.graphics.print(button.text, font, (ww * 0.5) - textw * 0.5, by + texth * 0.6)

        -- Move cursor to the next button position
        cursor_y = cursor_y + (BUTTON_HEIGHT + margin)
    end
end

-- Function to start the game
function startGame()
    state = STATE_GAMEPLAY
    changed = true
end

-- Function to exit the game
function exit()
    love.event.quit()
end

-- Function to resume the game
function resume()
    state = STATE_GAMEPLAY
    changed = true
end

-- Function to go back to the main menu
function menu()
    state = STATE_MAIN_MENU
    changed = true
end
